/obj/mapping_helper/wingrille_spawn
	name = "window grille spawner"
	icon = 'icons/obj/window.dmi'
	icon_state = "wingrille"
	gas_impermeable = TRUE
	var/win_path = /obj/window
	var/grille_path = /obj/mesh/grille/steel
	var/full_win = 0 // adds a full window as well
	var/no_dirs = 0 //ignore directional

	setup()
		if (!locate(src.grille_path) in get_turf(src))
			new grille_path(src.loc)

		if (!no_dirs)
			for (var/dir in cardinal)
				var/turf/T = get_step(src, dir)
				if ((!locate(/obj/mapping_helper/wingrille_spawn) in T) && (!locate(/obj/mesh/grille) in T))
					new win_path(src.loc, dir)

		if (src.full_win)
			if(!no_dirs || !locate(src.win_path) in get_turf(src))
				// if we have directional windows, there's already a window (or windows) from directional windows
				// only check if there's no window if we're expecting there to be no window so spawn a full window
				new win_path(src.loc)

// OLD SPAWNERS - flat windows

// Glass window
/obj/mapping_helper/wingrille_spawn/full
	icon_state = "wingrille_f"
	full_win = TRUE

// Reinforced Glass window
/obj/mapping_helper/wingrille_spawn/reinforced
	name = "reinforced window grille spawner"
	icon_state = "r-wingrille"
	win_path = /obj/window/reinforced

/obj/mapping_helper/wingrille_spawn/reinforced/full
	icon_state = "r-wingrille_f"
	full_win = TRUE

// Plasmaglass window
/obj/mapping_helper/wingrille_spawn/crystal
	name = "crystal window grille spawner"
	icon_state = "p-wingrille"
	win_path = /obj/window/crystal

/obj/mapping_helper/wingrille_spawn/crystal/full
	icon_state = "p-wingrille_f"
	full_win = TRUE

// Reinforced Plasmaglass window
/obj/mapping_helper/wingrille_spawn/reinforced_crystal
	name = "reinforced crystal window grille spawner"
	icon_state = "pr-wingrille"
	win_path = /obj/window/crystal/reinforced

/obj/mapping_helper/wingrille_spawn/reinforced_crystal/full
	icon_state = "pr-wingrille_f"
	full_win = TRUE

// Ultra tough Uqillglass window
/obj/mapping_helper/wingrille_spawn/bulletproof
	name = "bulletproof window grille spawner"
	icon_state = "br-wingrille"
	win_path = /obj/window/bulletproof

/obj/mapping_helper/wingrille_spawn/bulletproof/full
	name = "bulletproof window grille spawner"
	icon_state = "br-wingrille"
	icon_state = "b-wingrille_f"
	full_win = TRUE

// Flock window used by the flock trader
/obj/mapping_helper/wingrille_spawn/flock
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "wingrille"
	win_path = /obj/window/feather
	grille_path = /obj/mesh/flock/barricade
	full_win = TRUE
	no_dirs = TRUE

// NEW SPAWNERS - auto perspective windows

// Normal windows

// Glass window
/obj/mapping_helper/wingrille_spawn/auto
	name = "autowindow grille spawner"
	win_path = /obj/window/auto
	full_win = TRUE
	no_dirs = TRUE
	layer = LATTICE_LAYER	// to stop it rendering over things in map editors
#ifdef PERSPECTIVE_EDITOR_WALL
	icon_state = "wingrille_new"
	color = "#A3DCFF"
#else
	icon_state = "wingrille_f"
#endif

	walp
		name = "walp autowindow grille spawner"
		win_path = /obj/window/auto/walp
		icon = 'icons/obj/window_walp.dmi'
		icon_state = "wingrille"

// Plasmaglass window
/obj/mapping_helper/wingrille_spawn/auto/crystal
	name = "crystal autowindow grille spawner"
	win_path = /obj/window/auto/crystal
#ifdef PERSPECTIVE_EDITOR_WALL
	icon_state = "wingrille_new"
	color = "#A114FF"
#else
	icon_state = "p-wingrille_f"
#endif

	walp
		win_path = /obj/window/auto/crystal/walp
		icon = 'icons/obj/window_walp.dmi'
		icon_state = "p-wingrille"

// Uqill glass, bohrum reinforced window
/obj/mapping_helper/wingrille_spawn/auto/hardened
	name = "hardened autowindow grille spawner"
	win_path = /obj/window/auto/hardened
	icon_state = "br-wingrille"
#ifdef PERSPECTIVE_EDITOR_WALL
	icon_state = "wingrille_new"
	color = "#66a94e"
#endif

// Reinforced windows

// Reinforced Glass window
/obj/mapping_helper/wingrille_spawn/auto/reinforced
	name = "reinforced autowindow grille spawner"
	win_path = /obj/window/auto/reinforced
#ifdef PERSPECTIVE_EDITOR_WALL
	icon_state = "r-wingrille_new"
	color = "#72c8fd"
#else
	icon_state = "r-wingrille_f"
#endif

	walp
		win_path = /obj/window/auto/reinforced/walp
		icon = 'icons/obj/window_walp.dmi'
		icon_state = "r-wingrille"

// Reinforced Plasmaglass window
/obj/mapping_helper/wingrille_spawn/auto/reinforced/crystal
	name = "reinforced crystal autowindow grille spawner"
	win_path = /obj/window/auto/crystal/reinforced
#ifdef PERSPECTIVE_EDITOR_WALL
	color = "#8713d4"
#else
	icon_state = "pr-wingrille_f"
#endif

	walp
		win_path = /obj/window/auto/crystal/reinforced/walp
		icon = 'icons/obj/window_walp.dmi'
		icon_state = "pr-wingrille"

//Tuff windows with increased explosion resistance

// Tough glass window
/obj/mapping_helper/wingrille_spawn/auto/tuff
	name = "tuff stuff reinforced autowindow grille spawner"
	win_path = /obj/window/auto/reinforced/the_tuff_stuff

/obj/mapping_helper/wingrille_spawn/auto/hardened/tuff
	name = "tuff hardened autowindow grille spawner"
	win_path = /obj/window/auto/hardened/the_tuff_stuff
#ifdef PERSPECTIVE_EDITOR_WALL
	icon_state = "r-wingrille_new"
	color = "#3D692D"
#else
	icon_state = "br-wingrille"
#endif
