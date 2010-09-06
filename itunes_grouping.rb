#!/usr/local/bin/macruby
# encoding: utf-8
if __FILE__ == $0 then
	require "itunes.rb"
	include Sync
	itunes = Itunes.new "/tmp"
	itunes.sort_grouping
	
end