#!/usr/bin/macruby
 
# We iterate over every track, stripping bounding whitespace and putting things into proper title case.
 
 
framework 'Foundation'
framework 'cocoa'
framework "ScriptingBridge" 

load_bridge_support_file 'iTunes.bridgesupport'
 
 
itunes = SBApplication.applicationWithBundleIdentifier("com.apple.itunes")
 
music_playlist_tracks = itunes.sources.objectWithName("Library").userPlaylists
 

p music_playlist_tracks