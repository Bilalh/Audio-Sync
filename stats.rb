#!/usr/local/bin/macruby
# encoding: utf-8
# Bilal Husssain

# Prints out the albums per year, songs per year and artists per year using tab sep text e.g
# 1995 1996 1997
# 6    5    2
# 94   53   87
# 2    1    1

if __FILE__ == $0 then
	require "itunes.rb"
	include Sync
	itunes = Itunes.new "/Users/bilalh/Desktop/"
	tracks  = itunes.playlists['Music'].tracks
	artists = {}
	tracks.each do |track|
		parts = track.artist.split(/[,&] ?/)
		parts.each do |part|
			part.strip!
			artist = artists[part]
			unless artist
				artist = (artists[part]=[])
			end
			artist << track
		end
	end
	# puts "Artists# #{artists.size}"
	
	years = {}
	years[1810] = 0
	(1984..2011).each { |num| years[num] = 0 }
	artists.each_pair do |artist, ts|
		ts.each do |track|
			years[track.year] +=1
			break
		end
	end
	
	# Artists per year
	artist_sorted = years.sort
	artist_sorted.each do |e|
		print "#{e[0]}\t"
	end
	puts

	# Albums per year
	albums = {}
	tracks.each do |track|
		album = albums[track.album]
		unless album
			album = (albums[track.album]=[])
		end
		album << track
	end
	
	years = {}
	years[1810] = 0
	(1984..2011).each { |num| years[num] = 0 }
	albums.each do |album, ts|
		ts.each do |track|
			years[track.year] +=1
			break
		end
	end
	
	albums_sorted = years.sort
	albums_sorted.each do |e|
		print "#{e[1] != 0 ? e[1] : "" }\t"
	end
	puts

	
	# Songs per year
	years = {}
	years[1810] = 0
	(1984..2011).each { |num| years[num] = 0 }
	tracks.each do |track|
		years[track.year] += 1
	end
	
	songs_sorted = years.sort
	songs_sorted.each do |e|
		print "#{e[1] != 0 ? e[1] : "" }\t"
	end
	puts
	
	# Artists per year
	artist_sorted.each do |e|
		print "#{e[1] != 0 ? e[1] : "" }\t"
	end
	puts
	
end

# Fixes artist names for y20xx seasons
# if __FILE__ == $0 then
# 	require "itunes.rb"
# 	include Sync
# 	itunes = Itunes.new "/Users/bilalh/Desktop/"
# 	tracks  = itunes.playlists['rid'].tracks
# 	tracks.each do |track|
# 		p track.artist
# 		new_artist = track.artist.gsub(/[a-z ]*?\(([a-z ]*?)\)/i,'\1')
# 		new_artist.gsub!(/([,&])([a-z])/i,'\1 \2')
# 		track.artist = new_artist.strip
# 	end
# end