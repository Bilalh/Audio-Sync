#!/usr/local/bin/macruby
framework 'Cocoa'
framework 'ScriptingBridge'
require "set"

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
	framework 'Cocoa'
	framework 'ScriptingBridge'
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
		
		def add_music!(hash)
			hash.each do |o|
				self[o[0]] = o.dup
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
	
		def merge_music(other)
			other.each_pair do |x, o_arist|
				if  (artist = self[x]) then
					o_arist.each_pair do |y, o_album|
						if album = artist[y] then
							album.add_music! o_album
						else 
							artist[y] = o_album.dup
						end
					end
					
				else
					self[x] = o_arist.dup
				end
			end
		end
	
	end
	
	class Itunes
		attr_reader :app, :music, :playlists, :synced
		
		def print_musica(hash)
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
		
		def initialize(base = File.expand_path("~/Desktop/music_t") )
			@app       = get_app 'com.apple.itunes','itunes'
			@base      = base
			@music     = Music.new
			@playlists = @app.sources.first.playlists
			@synced    = Music.new
			@m3u       = Hash.new
			@file      = NSFileManager.new
		end
		
		# Makes the playlist with name
		def make_playlist_data(name)
			
			ply = "#EXTM3U\n"
			@playlists[name].tracks.each do |track|
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
			
			@m3u[name] = ply
			return self
		end

		def save_synced(path="#{@base}/sync.yaml")
			synced =  @synced.size == 0 ? @music : @synced
			File.open(path, "w") do |file|
				file.write(synced.to_yaml)
			end
			return self
		end
		
		def load_synced(path="#{@base}/sync.yaml")
			@synced =  File.open(path){|y| YAML.load(y) }
			return self
		end
		
		def find_unsyced(synced = @synced)
			
			puts "osynced" 
			print_musica synced
			puts
			
			puts "music" 
			print_musica  @music
			puts
			temp = @music.dup.merge_music synced

			@music.minus! synced
			@synced = temp
			puts "synced" 
			print_musica @synced
			puts
			
			puts "new" 
			print_musica  @music
			return self
		end
		
		def write_unsynced
			Dir.chdir(@base)
			@music.each_pair do |ar, artist|
				mkdir(ar)
				artist.each_pair do |al, album|
					mkdir("#{ar}/#{al}")
					album.each do |track|
						puts @file.copyItemAtPath(
							"/Users/bilalh/Music/iTunes/iTunes Music/" + track[1],
							toPath:track[1],
							error:nil
						)
					end	
				end
			end
			
			return self
		end
	
		def make_m3u()
			ply = "#EXTM3U\n"
			@music.each_pair do |ar, artist|
				artist.each_pair do |al, album|
					album.each do |track|
						ply << "#EXTINF:-1,#{track} - #{ar}\n"
						ply << "../#{ar}/#{al}/#{track}\n"
					end
				end
			end
			@m3u["Ωnew"] = ply
			return self
		end
		
		def print_music(music = @music)
			music.print_music()
			return self
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
itunes.make_playlist_data "ar"
itunes.load_synced
itunes.find_unsyced
# # itunes.make_m3u
# itunes.print_music
# itunes.print_music
# # itunes.write_unsynced
# itunes.save_synced
