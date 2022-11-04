#define CDBG1(msg)
#define CDBG2(msg)
#define CDBG3(msg)
#ifdef DEBUG
#define CHUI_VERBOSITY 3

#define CDBG(verbosity, msg) world << "<b>chui <u>[verbosity]</u></b>: [msg]"

#if CHUI_VERBOSITY >= 1
	#undef CDBG1
	#define CDBG1(msg) CDBG( "(INFO)", msg )
#endif

#if CHUI_VERBOSITY >= 2
	#undef CDBG2
	#define CDBG2(msg) CDBG( "(DEBUG)", msg )
#endif

#if CHUI_VERBOSITY >= 3
	#undef CDBG3
	#define CDBG3(msg) CDBG( "(VERBOSE)", msg )
#endif

#endif

#define CHUI_FLAG_SIZABLE 1
#define CHUI_FLAG_MOVABLE 2
#define CHUI_FLAG_FADEIN 4
#define CHUI_FLAG_CLOSABLE 8

/// depreceated, bye
/chui

chui/engine
	var/global/list/chui/theme/themes
	var/chui/window/staticinst

	New()
		..()
		themes = list()
		for( var/thm in typesof( "/chui/theme" ) )
			themes += new thm()
		SPAWN(0)
			staticinst = new
		//staticinst.theme = themes[1]//fart

	proc/GetTheme( var/name )
		for( var/i = 1, i < themes.len, i++ )
			var/chui/theme/theme = themes[ i ]
			if( theme.name == name )
				return theme
		return themes[1]

	/*
	proc/RscStream( var/client/victim, var/list/resources )
		CDBG2( "Transfering resources..." )
		for( var/rsc in resources )
			rsc = file("[rsc]")
			CDBG3( "Transfering [rsc]" )
			victim << browse( rsc, "display=0" )
		CDBG2( "Complete." )
	*/


var/global/chui/engine/chui
world/New()

	if(!chui) chui = new()
	. = ..()
