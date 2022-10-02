
/atom/movable/screen/hud/parallax
	var/zlevel // zlevel this is visible on

/// this is a hud that when given to a client will add parallax to their view.
/datum/hud/parallax
	var/list/parallax_objects = list()
	var/layers = list()

	// tiles per tile of visual change
	var/static/list/speeds = list(64,48,32,16) // farthest to closest
	var/mob/master // the nerd with this hud
	var/active = FALSE // turns active if the client has it on
	var/turf/lastturf // for tracking the change between moves
	var/instantchange = TRUE // the next update will be instant, then it resets
	var/atom/movable/screen/hud/background // background sprite

	// background sprite options
	var/static/BGicon = "background"
	var/static/Voidicon = "voidbackground"

	/// generate shown_objects list using existing background objects
	proc/createPlanets(var/pCoords,var/Picon,var/Picon_state,var/Pscale,var/Psize,var/Player)
		parallax_objects = list()
		for_by_tcl(O, /obj/effects/background_objects)
			var/atom/movable/screen/hud/parallax/N = create_screen(icon=O.icon,state=O.icon_state,layer=HUD_LAYER,customType=/atom/movable/screen/hud/parallax)


			N.plane = PLANE_PARALLAX_PLANETS
			if(istype(O,/obj/effects/background_objects/station))
				N.plane = PLANE_PARALLAX_STATIONS
			else if(istype(O,/obj/effects/background_objects/star_red) || istype(O,/obj/effects/background_objects/star_blue))
				N.plane = PLANE_PARALLAX_STARS
			else if(istype(O,/obj/effects/background_objects/x0))
				N.plane = PLANE_PARALLAX_GIANT

			N.mouse_opacity = 1
			N.appearance_flags = TILE_BOUND
			N.invisibility = INVIS_ALWAYS

			N.zlevel = O.z
			parallax_objects += N

			var/speed = speeds[N.plane-PLANE_SPACE]
			var/pX = (O.x-master.x)/speed
			var/pY = (O.y-master.y)/speed
			N.screen_loc = "CENTER:[round(pX*32,1)],CENTER:[round(pY*32,1)]"

	New(M)
		..()
		if(isnull(M))
			CRASH("parallax HUD created with no master")
		master = M
		clients += master.client
		lastturf = get_turf(master)
		// background setup, this will be "in" every zlevel, but wont necessarily be visible
		background = create_screen("background", "Space", 'icons/effects/overlays/parallaxBackground.dmi', "background", "1,1", HUD_LAYER)
		background.plane = PLANE_SPACE // sorry not sorry
		background.layer = HUD_LAYER
		background.appearance_flags += TILE_BOUND
		background.mouse_opacity = 0

		background.icon_state = BGicon //todo actually get a better sprite
		if (derelict_mode)
			background.icon_state = Voidicon //todo actually get a better sprite

		if (master.client && !length(src.layers)) // the update proc wont work without these
			layers += master.client?.get_plane(PLANE_PARALLAX_STARS)
			layers += master.client?.get_plane(PLANE_PARALLAX_GIANT)
			layers += master.client?.get_plane(PLANE_PARALLAX_PLANETS)
			layers += master.client?.get_plane(PLANE_PARALLAX_STATIONS)

		src.createPlanets()
		src.update()
		lastturf = get_turf(master)

	/// updates parallax object transform values
	proc/update()
		if(!active || !master.client) return

		var/turf/master_turf = get_turf(master)
		if (!master_turf) return

		#ifdef UNDERWATER_MAP
		if (master_turf.z != 2) // dont want space over z1 and z5
			background.alpha = 0
			return
		#else
		if (blowout)
			background.color = "#ff4646"
		else
			background.color = null
		#endif
		background.transform = matrix(master.client?.widescreen ? 3 : 3,0,(150-master_turf.x)/4,0,3,(150-master_turf.y)/4)

		if (master_turf.z != lastturf.z)
			instantchange = TRUE
		if (instantchange)
			for (var/atom/movable/screen/hud/parallax/P as anything in parallax_objects)
				if (P.zlevel != master_turf.z)
					P.invisibility = INVIS_ALWAYS
				else
					P.invisibility = INVIS_NONE

		// the difference between where we are and where we were earlier
		var/deltaX = (master_turf.x-lastturf.x)
		var/deltaY = (master_turf.y-lastturf.y)

		for(var/atom/movable/screen/plane_parent/P as anything in src.layers)
			var/curX = P.transform.c // values from earlier
			var/curY = P.transform.f
			// used for scroll speed, plane size
			var/speed = 1/speeds[P.plane-PLANE_SPACE]

			var/offsetX = round(deltaX / speed*32,1) // apply speed and icon scaling
			var/offsetY = round(deltaY / speed*32,1)

			var/matrix/matrix = matrix(1, 0, curX-offsetX, 0, 1, curY-offsetY)

			if (instantchange) // instant sliding
				P.transform = matrix
			else
				P.transform = matrix
				//animate(P,transform=matrix,time=smoothtime*dfps) // smoothing

			if (P.plane == PLANE_PARALLAX_PLANETS) // DEBUG, REMOVE LATER
				boutput(master,"[P.transform.c],[P.transform.f]")
			continue

		lastturf = master_turf
		instantchange = FALSE

	add_client() // make absolutely sure we sync with settings
		..()
		src.toggle()

	/// turns parallax on or off so update() doesnt have to loop through extra stuff
	proc/toggle()
		if (!master.client) return

		var/setting = master.client?.parallax
		var/turf/master_turf = get_turf(master)
		if (!master_turf) return

		if(!setting) // turn it off
			for (var/atom/movable/screen/hud/parallax/P as anything in parallax_objects)
				P.invisibility = INVIS_ALWAYS
			background.invisibility = INVIS_ALWAYS
			active = FALSE
			UnregisterSignal(master,"mov_moved")
			UnregisterSignal(master,"mob_move_vehicle")
			UnregisterSignal(master,"mov_set_loc")
		else // turn it on
			if (master.client && !length(src.layers)) // update proc wont work without these
				layers += master.client?.get_plane(PLANE_PARALLAX_STARS)
				layers += master.client?.get_plane(PLANE_PARALLAX_GIANT)
				layers += master.client?.get_plane(PLANE_PARALLAX_PLANETS)
				layers += master.client?.get_plane(PLANE_PARALLAX_STATIONS)
			RegisterSignal(master,"mov_moved", .proc/update)
			RegisterSignal(master,"mob_move_vehicle", .proc/update)
			RegisterSignal(master,"mov_set_loc", .proc/update)
			background.invisibility = INVIS_NONE
			active = TRUE
			instantchange = TRUE
			src.update()
