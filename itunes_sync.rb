#!/usr/local/bin/macruby
# encoding: utf-8


def nicer(num, dec = 2)
	sizes = %w{bytes Kb Mb Gb Tb}
	i = 0
	while (num > 1000 && i < sizes.length)
		num = num.to_f /  1000
		i   += 1
	end
	
	return "#{num.round dec} #{sizes[i]}"
end

if __FILE__ == $0 then
	require "itunes.rb"
	include Sync 
	
	(puts "itunes_sync base_path [-i]"; exit) unless ARGV.length > 0
	
	itunes = Itunes.new ARGV[0]
	itunes.load_pref
	
	if (  (ARGV.length > 1 and ARGV[1] == "-i") )
		file_attributes = NSFileManager.new.fileSystemAttributesAtPath(itunes.base)
		free_space = file_attributes[NSFileSystemFreeSize].longLongValue
		olds   = itunes.old_size == -1 ? 0 :  itunes.old_size
		news   = itunes.total_size 
		afters = (free_space - (olds - news ).abs)
		puts olds, news, afters
		puts "Current Size     #{nicer olds }"
		puts "New Size         #{nicer news}"
		puts "free space       #{nicer free_space , 4}"
		puts "free space after #{nicer afters, 4 }"
		puts "Playlists:"
		itunes.selected.each do |p|
			printf " %20s: %s\n", p, nicer(itunes.pnames[p])
		end
		exit
	elsif (  (ARGV.length > 1 and ARGV[1] == "-a") )
		itunes.playlists.each do |p|
			printf " %-20s: %s\n", p.name, nicer(itunes.pnames[p.name])
		end	
		exit
	end
	
	itunes.load_synced
	itunes.find_not_in_playlist
	itunes.find_unsyced

	itunes.delete_not_found
	itunes.write_unsynced

	itunes.save_synced
	itunes.make_new_playlist
	itunes.save_m3us
end