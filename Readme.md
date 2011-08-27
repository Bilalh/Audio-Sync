Audio Sync {#readmeTitle}
==========
Syncs the specified playlist in iTunes to the specified location, only copying the songs that have changed.
{#description}

Usage
-----
	itunes_sync base_path [-i|-a|-d|-e]

Prerequisites
-------------
MacRuby 0.10+

Install 
-------
* Put the scripts in your `$PATH`

Options
-------
* -i prints info 
* -a prints all music 
* -d prints all the music that would be deleted
* -e prints the size of all the playlist

Issues
------
If you change the case of the song e.g The song to, the Song, they might treated as the same song.

Licence
-------
[Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/ "Full details")

Authors
-------
* Bilal Hussain
