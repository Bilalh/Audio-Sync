#!/usr/local/bin/macruby
# encoding: utf-8
framework 'Cocoa'
framework 'ScriptingBridge'

class Object
	def my_methods()
		(self.methods(true,true) - Object.methods(true,true)).sort
	end
end 

class SBElementArray
  def [](value)
    self.objectWithName(value)
  end
end

 
module Sync
	require 'set'
	require "yaml"
	
	# gets the app 
	def get_app(app_id, bridge_name, run = true)
		appa = SBApplication.applicationWithBundleIdentifier(app_id)
		load_bridge_support_file "#{bridge_name}.bridgesupport"
		appa.run if run
		return appa
	end


	class Music < Hash
		def add_artist(name)
			val = self[name]
			return val if val
			return (self[name] = Music.new)
		end
		
		def add_album(name)
			val = self[name]
			return val if val
			return (self[name] = Music.new)
		end
		
		def subtract(hash)
			hash.each do |o|
				self.delete(o[0])
			end
		end
		
		# remove the elements from the other inplace
		def minus!(other)
			other.each_pair do |x, o_arist|
				if  artist = self[x] then
					o_arist.each_pair do |y, o_album|
						if album = artist[y] then
							album.subtract o_album
						end
						artist.delete y if album.size == 0
					end
					self.delete x if artist.size == 0
				end
			end	
		end
		
		def print_music
			self.each_pair do |name, artist|
				puts "artist: #{name}"
				artist.each do |name, album|
					puts "  album: #{name}"
					album.each do |track|
						puts "     #{track[0]}"
					end
				end
			end
		end
		
		# returns a new hash with elements of other and self
		def merge_music(other)
			nhash = Music.new
			other.each_pair do |x, o_arist|
				artist = nhash.add_artist x 
				o_arist.each_pair do |y, o_album|
					album = artist.add_album y
					o_album.each_pair do |z, track|
						album.store z, track
					end
				end
			end
			
			self.each_pair do |x, o_arist|
				artist = nhash.add_artist x 
				o_arist.each_pair do |y, o_album|
					album = artist.add_album y
					o_album.each_pair do |z, track|
						album.store z, track
					end
				end
			end
			
			return nhash
		end
	
	end
	
	class Itunes
		attr_reader :app,:delete, :music, :playlists, :pnames, :synced

		def initialize(base = File.expand_path("~/Desktop/music_t") )
			@app       = get_app 'com.apple.itunes','itunes'
			@base      = base
			@file      = NSFileManager.new
			@m3u       = Hash.new
			@music     = Music.new
			@playlists = @app.sources.first.playlists
			@synced    = Music.new
			@delete    = Array.new
			@pnames    = Hash.new
			@playlists.each do |p|
				@pnames[p.name] = p.size
			end
		end
		
		# Makes the playlist with name
		def make_playlist_data(p_name)
			raise NoPlayList unless @pnames.include? p_name
			
			ply = "#EXTM3U\n"
			@playlists[p_name].tracks.each do |track|
				url   = track.get.location
				parts = url.pathComponents
				name  = parts[-1]; album = parts[-2]; artist = parts[-3]
				full   = "#{artist}/#{album}/#{name}"

				@music.add_artist(artist)
					.add_album(album)
					.store(name,full)

				ply << "#EXTINF:-1,#{track.name} - #{artist}\n"
				ply << "../#{full}\n"
			end
			
			@m3u[p_name] = ply
			return self
		end

		def load_synced(path="#{@base}/sync.yaml")
			@synced = 
				if File.exist?(path)   then
					File.open(path){|y| YAML.load(y) }
				else
					 Music.new
				end
			return self
		end
		
		def find_unsyced(synced = @synced)
			puts "music" 
			print_music  @music
			puts
			
			temp = @music.merge_music synced
			@music.minus! synced
			
			@synced = temp
			puts "synced" 
			print_music temp
			puts
			
			puts "new" 
			print_music  @music
			puts
			
			puts "delete" 
			p delete
			puts
			
			return self
		end
		
		# find all songs that are not in any playlist
		def find_not_in_playlist
			@synced.each_pair do |ar, artist|
				
				if ( m_ar = @music[ar] ) then
					artist.each_pair do |al, album|
						if ( m_al = m_ar[al] ) then
							album.each do |name, full|
								unless  m_al[name]
									@delete << full
									album.delete name
								end
							end
						else 
							if ar and al then
								@delete << "#{ar}/#{al}" 
								artist.delete al
							end
						end
					end
					
				else 
					if ar then
						@delete << "#{ar}" 
						@synced.delete ar
					end
				end
				
			end
			return self
		end
		
		def write_unsynced
			Dir.chdir(@base)
			@music.each_pair do |ar, artist|
				mkdir(ar)
				artist.each_pair do |al, album|
					mkdir("#{ar}/#{al}")
					album.each do |name, full|
						print name, " "
						puts @file.copyItemAtPath(
							"/Users/bilalh/Music/iTunes/iTunes Music/" + full,
							toPath:full,
							error:nil
						)
					end	
				end
			end
			return self
		end
	
		def save_synced(path="#{@base}/sync.yaml")
			synced =  @synced.size == 0 ? @music : @synced
			
			File.open(path, "w") do |file|
				file.write(synced.to_yaml)
			end
			return self
		end
		
		def delete_not_found
			Dir.chdir(@base)
			@delete.each do |file|
				@file.removeItemAtPath(
					file,
					error:nil
				);
			end
		end
		
		def make_new_playlist
			return if @music.size == 0 
			ply = "#EXTM3U\n"
			@music.each_pair do |ar, artist|
				artist.each_pair do |al, album|
					album.each do |name, full|
						ply << "#EXTINF:-1,#{name} - #{ar}\n"
						ply << "../#{full}\n"
					end
				end
			end
			
			now = Time.now
			name = sprintf "Ω_%02d_%02d", now.month, now.day
			@m3u[name] = ply
			return self
		end
		
		def save_m3us
			mkdir("playlists")
			Dir.chdir("#{@base}/playlists")
			@m3u.each_pair do |name, ply|
				File.open("#{name}.m3u", "w") do |file|
					file.write(ply)
				end
			end
		end
		
		def print_music(hash = @music)
			hash.each_pair do |name, artist|
				puts "artist: #{name}"
				artist.each do |name, album|
					puts "  album: #{name}"
					album.each do |track|
						puts "     #{track[0]}"
					end
				end
			end
		end
		
		private
		def mkdir(dir)
			@file.createDirectoryAtPath(
				dir,
				withIntermediateDirectories:false,
				attributes:nil,
				error:nil
			)
		end
		
	end

end

#Main
include Sync 

itunes = Itunes.new

itunes.make_playlist_data "pc [701,2500]"
itunes.make_playlist_data "↑ "

itunes.load_synced
itunes.find_not_in_playlist
itunes.find_unsyced

# any order 
itunes.delete_not_found
itunes.write_unsynced

itunes.save_synced
itunes.make_new_playlist
itunes.save_m3us


