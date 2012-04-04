#!/usr/local/bin/macruby
# encoding: utf-8
# Bilal Syed Hussain
if __FILE__ == $0 then
		require "stats.rb"
		include Stats		
		itunes = Itunes.new "/Users/bilalh/Desktop/"
		tracks  = itunes.playlists['Music'].tracks
		write_tracks_yaml make_tracks_yaml tracks
end
