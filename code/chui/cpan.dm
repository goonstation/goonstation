//#define GOONSTATION
#if 0
proc/boutput( target, msg )
	target << msg
chui/cpan//TODO: Merge with Window?
	//it is being merged with window
	//use this and be fat

	var/name = "fat" //must be unique!
	var/desiredTheme = "default"//default is wire's ugly theme. this var only matters if the window is unthemed!

	var/list/sections= list("example")
	var/chui/window/window

	//proc/exampleSection( var/list/hreflist )
	//	src.SetBody( "Feel ashamed of your words and deeds!" )

	proc/SetBody( var/body )
		window.SetBody( body )

	proc/OnTopic()
		//:D

	Topic( href, href_list[] )
		var/action = href_list[ "_cact" ]
		if( !isnull( action ) )
			if( action == "section" && !isnull( href_list[ "section" ] ) && href_list[ "section" ] in sections )
				if( !hascall( src, href_list[ "section" ] + "Section" ) )
					boutput( src, "<span style='color: #f00'>Call 1-800 CODER.</span>" )
					throw EXCEPTION( "1-800 Coder: you allowed a section that doesn't exist!!! RAAHHHH" )
				call( href_list[ "section" ], src )( href_list )
			else if( action == "request" )
				var/method = href_list[ "_path" ]
				var/id = href_list[ "_id" ]
				if( isnull( method ) || isnull( id ) )
					world << "FATAL: Null ID/Method for BYREQ."
					return

			else
				OnTopic( href, href_list )
		else
			OnTopic( href, href_list )
#endif
