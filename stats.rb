#!/usr/local/bin/macruby
# encoding: utf-8
# Bilal Husssain

# Prints out the albums per year, songs per year and artists per year using tab as the sep e.g
# 1995 1996 1997
# 6    5    2
# 94   53   87
# 2    1    1

module Stats
	require "itunes.rb"
	include Sync
	Fields = %w{
		album  albumArtist  albumRating  albumRatingKind  artist  bitRate  bookmark  sortName
		bpm  category  comment  compilation  composer  databaseID  dateAdded  objectDescription
		discCount  discNumber  duration  enabled  episodeID  episodeNumber  finish bookmarkable
		gapless  genre  grouping  kind  longDescription  lyrics  modificationDate  playedCount
		playedDate  podcast  rating  ratingKind  releaseDate  sampleRate  seasonNumber  year
		skippedCount  skippedDate  show  sortAlbum  sortArtist  sortAlbumArtist  shufflable
		sortShow  size  start  time  trackCount  trackNumber  unplayed  videoKind  sortComposer
		volumeAdjustment  EQ
	}.map { |e| e.to_sym }


	def make_years
		years = {}
		years[1810] = 0
		(1984..2011).each { |num| years[num] = 0 }
		return years
	end

	def make_tracks_yaml(tracks)
		require "yaml"
		tracks_array = []

		tracks.each do |track|
			track_hash = {}
			Fields.each do |field|	
				 track_hash[field] = track.send field
			end
			tracks_array << track_hash
		end
		tracks_array.to_yaml
	end

	def write_tracks_yaml data
		require "date"
		name =  Time.now.strftime '%Y-%m-%d'
		File.open("tracks_#{name}.yaml", "w") { |io| io.write data }

	end
end

if __FILE__ == $0 then
	include Stats
	require "yaml"
	
	(puts "#{File.basename $0} tracks_date.yaml"; exit) if ARGV.length == 0
	tracks = YAML::load( File.open( ARGV[0] ) )
	
	artists = {}
	tracks.each do |track|
		parts = track[:artist].split(/[,&] ?/)
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
	
	
	# Years
	make_years.each do |e|
		print "#{e[0]}\t"
	end
	
	puts

	# Albums per year
	albums = {}
	tracks.each do |track|
		album = albums[track[:album]]
		unless album
			album = (albums[track[:album]]=[])
		end
		album << track
	end
	
	years = make_years
	albums.each do |album, ts|
		ts.each do |track|
			years[track[:year]] +=1
			break
		end
	end
	
	years.each do |e|
		print "#{e[1] != 0 ? e[1] : "" }\t"
	end
	puts

	
	# Songs per year
	years = make_years
	tracks.each do |track|
		years[track[:year]] += 1
	end
	
	years.each do |e|
		print "#{e[1] != 0 ? e[1] : "" }\t"
	end
	puts
	
	# Artists per year
	years = make_years
	artists.each_pair do |artist, ts|
		ts.each do |track|
			years[track[:year]] +=1
			break
		end
	end
	
	years.each do |e|
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