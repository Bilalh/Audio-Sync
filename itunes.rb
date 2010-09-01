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
			return (self[name] = Set.new)
		end

		# remove the elements from the other inplace
		def minus!(other)
			
			other.each_pair do |x, o_arist|
				if artist = self[x] then
					o_arist.each_pair do |y, o_album|
						if album = artist[y] then
							album.subtract o_album
						end
						artist.delete y if album.size == 0
						
					end
				end
				self.delete x if artist.size == 0
				
			end	
		end
		
		def print_music
			self.each_pair do |name, artist|
				puts "artist: #{name}"
				artist.each do |name, album|
					puts "  album: #{name}"
					album.each do |track|
						puts "     #{track}"
					end
				end
			end
		end
	
	end
	
	class Itunes
		attr_reader :app, :music, :playlists, :synced
		
		def initialize(base = File.expand_path("~/Desktop/music_t") )
			@app       = get_app 'com.apple.itunes','itunes'
			@music     = Music.new
			@base      = base
			@playlists = @app.sources.first.playlists
			@synced    = Music.new
		end
		
		# Makes the playlist with name
		def make_playlist_data(name)
			@playlists[name].tracks.each do |track|
				url   = track.get.location
				parts = url.pathComponents
				name = parts[-1]; album = parts[-2]; artist = parts[-3]
				
				@music.add_artist(artist)
					.add_album(album)
					.add(name)
			end
			return self
		end
	
		def sync
			file = NSFileManager.new
			# file.copyItemAtPath(
			# 	url.path,
			# 	toPath:path,
			# 	error:error
			# )
			return self
		end
		
		def save_synced(path="#{@base}/sync.yaml")
			File.open(path, "w") do |file|
				file.write(@music.to_yaml)
			end
			return self
		end
		
		def load_synced(path="#{@base}/sync.yaml")
			@synced =  File.open(path){|y| YAML.load(y) }
			return self
		end
		
		def find_unsyced(synced = @synced)
			@music.minus! synced
			return self
		end
		
		def print_music(music = @music)
			music.print_music()
			return self
		end
		
	end

end


#Main
include Sync 

itunes = Itunes.new
itunes.make_playlist_data "L5"
itunes.load_synced()
itunes.find_unsyced()
itunes.print_music


