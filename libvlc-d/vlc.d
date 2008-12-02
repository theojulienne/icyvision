module vlc;

import std.string;
import std.stdio;

alias std.string.toString cStringToD;
alias std.string.toStringz dStringToC;


class VLCEngine {
	class VLCEngineException : Exception {
		this( char[] message ) {
			super( message );
		}
	}
	
	class VLCNoActiveInputException : VLCEngineException {
		this( char[] message ) {
			super( message );
		}
	}
	
	libvlc_instance_t* engine;
	
	this( bool videoCallback=false ) {
		libvlc_exception_t ex = libvlc_exception_t.blank;
        char*[] argv = [
			"-I", "dummy",
			"--ignore-config",
			"--plugin-path=/Applications/VLC.app/Contents/MacOS/modules/",
			"--vout=vgltex",
			"-vvvv"
			//"--vmem-lock", clock,
			//"--vmem-unlock", cunlock,
			//"--vmem-data", cdata,
		];
		
		int len = argv.length;
		
		if ( !videoCallback ) {
			//len -= 4;
		}
		
        engine = libvlc_new( len, argv.ptr, &ex );
        handleException( &ex );

		assert( engine !is null );
	}
	
	~this( ) {
		//libvlc_release( engine ); // crashes at the moment ?
	}
	
	void handleException( libvlc_exception_t *ex ) {
		if ( ex.raised ) {
			VLCEngineException vlcex;
			
			if ( ex.message == "No active input" ) {
				vlcex = new VLCNoActiveInputException( ex.message );
			} else {
				vlcex = new VLCEngineException( ex.message );
			}
			
			ex.clear( );
			throw vlcex;
        }
    }

	char[] versionString( ) {
		return cStringToD( libvlc_get_version( ) );
	}
	
	char[] compilerString( ) {
		return cStringToD( libvlc_get_compiler( ) );
	}
	
	char[] changesetString( ) {
		return cStringToD( libvlc_get_changeset( ) );
	}

	int volume( ) {
		libvlc_exception_t ex = libvlc_exception_t.blank;
		scope( exit ) handleException( &ex );
		
		return libvlc_audio_get_volume( engine, &ex );
	}
	
	void volume( int value ) {
		libvlc_exception_t ex = libvlc_exception_t.blank;
		scope( exit ) handleException( &ex );
		
		libvlc_audio_set_volume( engine, value, &ex );
	}
	
	bool mute( ) {
		libvlc_exception_t ex = libvlc_exception_t.blank;
		scope( exit ) handleException( &ex );
		
		return cast(bool)libvlc_audio_get_mute( engine, &ex );
	}
	
	void mute( bool value ) {
		libvlc_exception_t ex = libvlc_exception_t.blank;
		scope( exit ) handleException( &ex );
		
		libvlc_audio_set_mute( engine, value, &ex );
	}
	/*
	long time( ) {
		try {
			libvlc_exception_t ex = libvlc_exception_t.blank;
			
			libvlc_input_t *input = libvlc_playlist_get_input( engine, &ex );
			handleException( &ex );
			
			long ret = 0;
			if ( input !is null ) {
				ret = libvlc_input_get_time( input, &ex );
				handleException( &ex );
				libvlc_input_free( input );
			}
			
			return ret;
		} catch ( VLCNoActiveInputException) {
			return 0;
		}
	}
	
	void time( long value ) {
		libvlc_exception_t ex = libvlc_exception_t.blank;
		
		libvlc_input_t *input = libvlc_playlist_get_input( engine, &ex );
		handleException( &ex );
		
		libvlc_input_set_time( input, value, &ex );
		handleException( &ex );
		
		libvlc_input_free( input );
	}*/
	
	Media createMedia( char[] mrl ) {
		return new Media( mrl );
	}
	
	MediaPlayer createMediaPlayer( Media m ) {
		return new MediaPlayer( m );
	}
	
	/* Media */
	class Media {
		libvlc_media_t *_media;
		
		this( char[] mrl ) {
			libvlc_exception_t ex = libvlc_exception_t.blank;
			scope( exit ) handleException( &ex );
			
			_media = libvlc_media_new( engine, dStringToC(mrl), &ex );

			//libvlc_media_add_option( _media, "vout=opengl", &ex );
		}
		
		~this( ) {
			libvlc_media_release( _media );
		}
	}
	
	/* Media Player */
	class MediaPlayer {
		libvlc_media_player_t *_player;
		
		this( Media media ) {
			libvlc_exception_t ex = libvlc_exception_t.blank;
			scope( exit ) handleException( &ex );
			
			_player = libvlc_media_player_new_from_media( media._media, &ex );
		}
		
		~this( ) {
			libvlc_media_player_release( _player );
		}
		
		void play( ) {
			libvlc_exception_t ex = libvlc_exception_t.blank;
			scope( exit ) handleException( &ex );
			
			libvlc_media_player_play( _player, &ex );
		}
		
		void stop( ) {
			libvlc_exception_t ex = libvlc_exception_t.blank;
			scope( exit ) handleException( &ex );
			
			libvlc_media_player_stop( _player, &ex );
		}
		
		int width(  ) {
			libvlc_exception_t ex = libvlc_exception_t.blank;
			scope( exit ) handleException( &ex );

			return libvlc_video_get_width( _player, &ex );
		}
		
		int height(  ) {
			libvlc_exception_t ex = libvlc_exception_t.blank;
			scope( exit ) handleException( &ex );

			return libvlc_video_get_height( _player, &ex );
		}
		
		void drawable( int value ) {
			libvlc_exception_t ex = libvlc_exception_t.blank;
			scope( exit ) handleException( &ex );
			
			libvlc_media_player_set_drawable( _player, cast(libvlc_drawable_t)value, &ex );
		}
	}
}

extern (C) {
	typedef long libvlc_time_t;
	alias int vlc_bool_t;
	alias long vlc_int64_t;

	typedef void libvlc_instance_t;
	typedef void libvlc_media_t;
	typedef void libvlc_media_list_t;
	typedef void libvlc_event_manager_t;
	typedef void libvlc_media_player_t;
	typedef void* libvlc_drawable_t;
	
	enum libvlc_meta_t {
	    libvlc_meta_Title,
	    libvlc_meta_Artist,
	    libvlc_meta_Genre,
	    libvlc_meta_Copyright,
	    libvlc_meta_Album,
	    libvlc_meta_TrackNumber,
	    libvlc_meta_Description,
	    libvlc_meta_Rating,
	    libvlc_meta_Date,
	    libvlc_meta_Setting,
	    libvlc_meta_URL,
	    libvlc_meta_Language,
	    libvlc_meta_NowPlaying,
	    libvlc_meta_Publisher,
	    libvlc_meta_EncodedBy,
	    libvlc_meta_ArtworkURL,
	    libvlc_meta_TrackID
	};
	
	enum libvlc_state_t
	{
	    libvlc_NothingSpecial=0,
	    libvlc_Opening,
	    libvlc_Buffering,
	    libvlc_Playing,
	    libvlc_Paused,
	    libvlc_Stopped,
	    libvlc_Forward,
	    libvlc_Backward,
	    libvlc_Ended,
	    libvlc_Error
	};
	
	/* libvlc */
	libvlc_instance_t * libvlc_new( int , char **, libvlc_exception_t *);
	void libvlc_release( libvlc_instance_t * );
	void libvlc_retain( libvlc_instance_t * );
	char *libvlc_get_version( );
	char *libvlc_get_compiler( );
	char *libvlc_get_changeset( );
	
	/* video */
	int libvlc_video_get_height( libvlc_media_player_t *, libvlc_exception_t * );
	int libvlc_video_get_width( libvlc_media_player_t *, libvlc_exception_t * );
	char *libvlc_video_get_aspect_ratio( libvlc_media_player_t *, libvlc_exception_t * );
	
	
	/* Exception handling */
	struct libvlc_exception_t {
		int b_raised;
		int i_code;
		char *psz_message;
		
		static libvlc_exception_t blank( ) {
			libvlc_exception_t e;
			e.init( );
			return e;
		}
		
		void init( ) {
			libvlc_exception_init( this );
		}
		
		bool raised( ) {
			return libvlc_exception_raised( this ) != 0;
		}
		
		char[] message( ) {
			return cStringToD( psz_message );
		}
		
		void clear( ) {
			libvlc_exception_clear( this );
		}
	}
	
	void libvlc_exception_init( libvlc_exception_t *p_exception );
	int libvlc_exception_raised( libvlc_exception_t *p_exception );
	void libvlc_exception_raise( libvlc_exception_t *p_exception, char *psz_format, ... );
	void libvlc_exception_clear( libvlc_exception_t * );
	char* libvlc_exception_get_message( libvlc_exception_t *p_exception );
	
	/* Audio Handling */
	void libvlc_audio_toggle_mute( libvlc_instance_t *, libvlc_exception_t * );
	vlc_bool_t libvlc_audio_get_mute( libvlc_instance_t *, libvlc_exception_t * );
	void libvlc_audio_set_mute( libvlc_instance_t *, vlc_bool_t , libvlc_exception_t * );
	int libvlc_audio_get_volume( libvlc_instance_t *, libvlc_exception_t * );
	void libvlc_audio_set_volume( libvlc_instance_t *, int , libvlc_exception_t *);
	
	/* Media Handling */
	libvlc_media_t * libvlc_media_new(
	                                   libvlc_instance_t *p_instance,
	                                   char * psz_mrl,
	                                   libvlc_exception_t *p_e );
	libvlc_media_t * libvlc_media_new_as_node(
	                                   libvlc_instance_t *p_instance,
	                                   char * psz_name,
	                                   libvlc_exception_t *p_e );
	void libvlc_media_add_option(
	                                   libvlc_media_t * p_md,
	                                   char * ppsz_options,
	                                   libvlc_exception_t * p_e );
	void libvlc_media_retain( libvlc_media_t *p_meta_desc );
	void libvlc_media_release( libvlc_media_t *p_meta_desc );
	char * libvlc_media_get_mrl( libvlc_media_t * p_md, libvlc_exception_t * p_e );
	libvlc_media_t * libvlc_media_duplicate( libvlc_media_t * );
	char * libvlc_media_get_meta(
	                                   libvlc_media_t *p_meta_desc,
	                                   libvlc_meta_t e_meta,
	                                   libvlc_exception_t *p_e );
	libvlc_state_t libvlc_media_get_state(
	                                   libvlc_media_t *p_meta_desc,
	                                   libvlc_exception_t *p_e );

	libvlc_media_list_t * libvlc_media_subitems( libvlc_media_t *p_md, libvlc_exception_t *p_e );
	libvlc_event_manager_t * libvlc_media_event_manager( libvlc_media_t * p_md, libvlc_exception_t * p_e );

	libvlc_time_t libvlc_media_get_duration( libvlc_media_t * p_md, libvlc_exception_t * p_e );

	int libvlc_media_is_preparsed( libvlc_media_t * p_md, libvlc_exception_t * p_e );

	void libvlc_media_set_user_data( libvlc_media_t * p_md,
	                                 void * p_new_user_data,
	                                 libvlc_exception_t * p_e);

	void * libvlc_media_get_user_data( libvlc_media_t * p_md, libvlc_exception_t * p_e);
	
	/* Media Player Handling */
	libvlc_media_player_t * libvlc_media_player_new( libvlc_instance_t *, libvlc_exception_t * );
	libvlc_media_player_t * libvlc_media_player_new_from_media( libvlc_media_t *, libvlc_exception_t * );
	void libvlc_media_player_release( libvlc_media_player_t * );
	void libvlc_media_player_retain( libvlc_media_player_t * );
	void libvlc_media_player_set_media( libvlc_media_player_t *, libvlc_media_t *, libvlc_exception_t * );
	libvlc_media_t * libvlc_media_player_get_media( libvlc_media_player_t *, libvlc_exception_t * );
	libvlc_event_manager_t * libvlc_media_player_event_manager ( libvlc_media_player_t *, libvlc_exception_t * );
	void libvlc_media_player_play ( libvlc_media_player_t *, libvlc_exception_t * );
	void libvlc_media_player_pause ( libvlc_media_player_t *, libvlc_exception_t * );
	void libvlc_media_player_stop ( libvlc_media_player_t *, libvlc_exception_t * );
	void libvlc_media_player_set_drawable ( libvlc_media_player_t *, libvlc_drawable_t, libvlc_exception_t * );
	libvlc_drawable_t libvlc_media_player_get_drawable ( libvlc_media_player_t *, libvlc_exception_t * );
	libvlc_time_t libvlc_media_player_get_length( libvlc_media_player_t *, libvlc_exception_t *);
	libvlc_time_t libvlc_media_player_get_time( libvlc_media_player_t *, libvlc_exception_t *);
	void libvlc_media_player_set_time( libvlc_media_player_t *, libvlc_time_t, libvlc_exception_t *);
	float libvlc_media_player_get_position( libvlc_media_player_t *, libvlc_exception_t *);
	void libvlc_media_player_set_position( libvlc_media_player_t *, float, libvlc_exception_t *);
	void libvlc_media_player_set_chapter( libvlc_media_player_t *, int, libvlc_exception_t *);
	int libvlc_media_player_get_chapter( libvlc_media_player_t *, libvlc_exception_t * );
	int libvlc_media_player_get_chapter_count( libvlc_media_player_t *, libvlc_exception_t *);
	int libvlc_media_player_will_play        ( libvlc_media_player_t *, libvlc_exception_t *);
	float libvlc_media_player_get_rate( libvlc_media_player_t *, libvlc_exception_t *);
	void libvlc_media_player_set_rate( libvlc_media_player_t *, float, libvlc_exception_t *);
	libvlc_state_t libvlc_media_player_get_state( libvlc_media_player_t *, libvlc_exception_t *);
	float libvlc_media_player_get_fps( libvlc_media_player_t *, libvlc_exception_t *);
	int  libvlc_media_player_has_vout( libvlc_media_player_t *, libvlc_exception_t *);
	int libvlc_media_player_is_seekable( libvlc_media_player_t *p_mi, libvlc_exception_t *p_e );
	int libvlc_media_player_can_pause( libvlc_media_player_t *p_mi, libvlc_exception_t *p_e );
}