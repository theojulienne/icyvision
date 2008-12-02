module test;

import vlc;

import std.compat;
import std.string;
import std.stdio;
import tango.io.Stdout;

import std.c.time;

int main( string[] args ) {
	VLCEngine eng = new VLCEngine( );
	writefln( "Found VLC version: %s", eng.versionString );
	
	auto m = eng.createMedia( "/Users/theo/Media/Simpsons Season 15 - Complete/Simpsons 15x13 - Smart and Smarter.avi" );
	auto mp = eng.createMediaPlayer( m );
	//writefln( "%sx%s", mp.width, mp.height );
	
	mp.drawable = 123;
	
	mp.play( );
	
	sleep( 10 );
	
	return 0;
}