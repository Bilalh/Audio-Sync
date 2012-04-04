#!/usr/local/bin/macruby
# encoding: utf-8
# Bilal Syed Hussain
# Finds all artists where 
#  first_name last_name  and last_name first_name are used.

def swap_first_and_last_name name
	arr = name.split /[&,] ?/
	swap_first_and_last_name_arr arr
end

def swap_first_and_last_name_arr arr
	dst = []
	
	arr.each do |e|
		e.strip!
		matches =  e.match /^(\w+) (\w+)$/
		return arr unless matches
		if matches.length != 3 then
			dst << e
		else
			dst << "#{matches[2]} #{matches[1]}"
		end
	end
	return dst
end

def name_array_to_string dst, sep=', '
	result = ""
	if dst.length == 2 then
		result = "#{dst[0]}, #{dst[1]}"
	elsif dst.length > 2 
		result = dst.join "#{sep}"
	else
		result = dst[0]
	end
	result
end

if __FILE__ == $0 then
		require "pp"
		require "itunes.rb"
		include Sync
		require 'set'
		
		itunes  = Itunes.new "/Users/bilalh/Desktop/"
		tracks  = itunes.playlists['Music'].tracks
		artists = {}
		tracks.each do |track|
			artist_arr = track.artist.strip.split /[&,] ?/
			artist_arr.each do |artist|
				arr    = artists[artist]
				unless arr
					arr = []
					artists[artist] = arr
				end
				arr  << track
			end
		end

		done = Set.new
		artists.each_pair do |artist, tracks|
			# p artist
			rev = swap_first_and_last_name(artist)[0]
			# p rev
			# puts
			if !done.include? rev and artist != rev and artists.has_key? rev then
				puts "#{artist}\t#{rev}"
			end
			done << artist
		end
end
