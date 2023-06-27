/obj/mapping_helper/wingrille_spawn
	name = "window grille spawner"
	icon = 'icons/obj/window.dmi'
	icon_state = "wingrille"
	anchored = ANCHORED
	invisibility = INVIS_ALWAYS
	var/win_path = "/obj/window"
	var/grille_path = "/obj/grille/steel"
	var/full_win = 0 // adds a full window as well
	var/no_dirs = 0 //ignore directional

	proc/setup()
		if (!locate(text2path(src.grille_path)) in get_turf(src))
			var/obj/grille/new_grille = text2path(src.grille_path)
			new new_grille(src.loc)

		if (!no_dirs)
			for (var/dir in cardinal)
				var/turf/T = get_step(src, dir)
				if ((!locate(/obj/wingrille_spawn) in T) && (!locate(/obj/grille) in T))
					var/obj/window/new_win = text2path("[src.win_path]/[dir2text(dir)]")
					if(new_win)
						new new_win(src.loc)
					else
						CRASH("Invalid path: [src.win_path]/[dir2text(dir)]")

		if (src.full_win)
			if(!no_dirs || !locate(text2path(src.win_path)) in get_turf(src))
				// if we have directional windows, there's already a window (or windows) from directional windows
				// only check if there's no window if we're expecting there to be no window so spawn a full window
				var/obj/window/new_win = text2path(src.win_path)
				new new_win(src.loc)

	full
		icon_state = "wingrille_f"
		full_win = 1

	reinforced
		name = "reinforced window grille spawner"
		icon_state = "r-wingrille"
		win_path = "/obj/window/reinforced"

		full
			icon_state = "r-wingrille_f"
			full_win = 1

	crystal
		name = "crystal window grille spawner"
		icon_state = "p-wingrille"
		win_path = "/obj/window/crystal"

		full
			icon_state = "p-wingrille_f"
			full_win = 1

	reinforced_crystal
		name = "reinforced crystal window grille spawner"
		icon_state = "pr-wingrille"
		win_path = "/obj/window/crystal/reinforced"

		full
			icon_state = "pr-wingrille_f"
			full_win = 1

	bulletproof
		name = "bulletproof window grille spawner"
		icon_state = "br-wingrille"
		win_path = "/obj/window/bulletproof"

		full
			name = "bulletproof window grille spawner"
			icon_state = "br-wingrille"
			icon_state = "b-wingrille_f"
			full_win = 1

	hardened
		name = "hardened window grille spawner"
		icon_state = "br-wingrille"
		win_path = "/obj/window/hardened"

		full
			name = "hardened window grille spawner"
			icon_state = "br-wingrille"
			icon_state = "b-wingrille_f"
			full_win = 1

	auto
		name = "autowindow grille spawner"
		win_path = "/obj/window/auto"
		full_win = 1
		no_dirs = 1
		icon_state = "wingrille_f"

		reinforced
			name = "reinforced autowindow grille spawner"
			win_path = "/obj/window/auto/reinforced"
#ifdef PERSPECTIVE_EDITOR_WALL
			icon_state = "r-wingrille_new"
			color = "#72c8fd"
#else
			icon_state = "r-wingrille_f"
#endif

		crystal
			name = "crystal autowindow grille spawner"
			win_path = "/obj/window/auto/crystal"
#ifdef PERSPECTIVE_EDITOR_WALL
			icon_state = "wingrille_new"
			color = "#A114FF"
#else
			icon_state = "wingrille_f"
#endif

			reinforced
				name = "reinforced crystal autowindow grille spawner"
				win_path = "/obj/window/auto/crystal/reinforced"
#ifdef PERSPECTIVE_EDITOR_WALL
				icon_state = "r-wingrille_new"
				color = "#8713d4"
#else
				icon_state = "r-wingrille_f"
#endif

		tuff
			name = "tuff stuff reinforced autowindow grille spawner"
			win_path = "/obj/window/auto/reinforced/the_tuff_stuff"
