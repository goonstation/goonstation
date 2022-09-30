
// before doing this, i had no idea what tuples even were. i still dont know, but now i know not to question what they are.
#define PARALLAX_VIEW_WIDTH (WIDE_TILE_WIDTH + 4)
#define PARALLAX_VIEW_HEIGHT (SQUARE_TILE_WIDTH + 4)

/// this is a hud that when given to a client will add parallax to their view.
/datum/hud/parallax
	var/list/parallax_objects = list()
	// planet position is tracked relative to when initialized

	var/layers = list()
	var/static/list/layerscale = list(0.12,0.09,0.08,0.05) // closest to farthest scroll speed
	var/mob/master
	var/active = TRUE
	var/lastzlevel

	var/atom/movable/screen/hud/background

	// backgrounds that get stretched
	var/BGicon = "background"
	var/Voidicon = "voidbackground"

	/// generate parallax_objects list out of settings
	proc/createPlanets(var/pCoords,var/Picon,var/Picon_state,var/Pscale,var/Psize,var/Player)
		parallax_objects = list()
		for_by_tcl(O, /obj/effects/background_objects)
			O.plane = PLANE_PARALLAX_PLANETS
			if(istype(O,/obj/effects/background_objects/station))
				O.plane = PLANE_PARALLAX_STATIONS
			else if(istype(O,/obj/effects/background_objects/star_red) || istype(O,/obj/effects/background_objects/star_blue))
				O.plane = PLANE_PARALLAX_STARS
			else if(istype(O,/obj/effects/background_objects/x0))
				O.plane = PLANE_PARALLAX_GIANT
			O.layer = HUD_LAYER
			O.mouse_opacity = 0
			parallax_objects += O

	New(M)
		..()
		if(isnull(M))
			CRASH("parallax HUD created with no master")
		master = M
		clients += master.client

		/// background setup, this will be "in" every zlevel, but wont necessarily be visible
		background = create_screen("background", "Space", 'icons/effects/overlays/parallaxBackground.dmi', "background", "1,1", HUD_LAYER-1)
		background.transform = matrix(0,0,0,0,0,0)
		background.screen_loc = "CENTER"
		background.plane = PLANE_SPACE // sorry not sorry
		background.layer = HUD_LAYER
		background.appearance_flags += TILE_BOUND
		background.mouse_opacity = 0

		background.icon_state = BGicon //todo actually get a better sprite
		if (derelict_mode)
			background.icon_state = Voidicon //todo actually get a better sprite

		src.createPlanets()

		src.update()

	/// updates parallax object transform values
	proc/update(var/zlevelchanged)
		if(!active || !master.client) return

		var/turf/master_turf = get_turf(master)

		/// due to the fact that the hud tracks the last zlevel it updated on, we dont need to use a complex signal
		if (lastzlevel != master_turf?.z)
			lastzlevel = master_turf.z
			zlevelchanged = TRUE

		/// background scrolling and oshan handling
		#ifdef UNDERWATER_MAP
		if (master_turf.z != 2)
			background.alpha = 0
			return
		#endif

		if (background)
			background.transform = matrix(master.client?.widescreen ? 2.61 : 2.5,0,(150-master_turf.x)/2,0,2.5,(150-master_turf.y)/2)


		var/smoothtime = round(world.icon_size/max(master.glide_size*world.tick_lag,1),world.tick_lag)

		for(var/atom/movable/screen/plane_parent/P as anything in src.layers)

			var/offsetX = ((world.maxx/2-master_turf.x))*layerscale[P.plane-PLANE_SPACE]
			var/offsetY = ((world.maxy/2-master_turf.y))*layerscale[P.plane-PLANE_SPACE]
			var/matrix/matrix = matrix(1, 0, offsetX*32, 0, 1, offsetY*32)

			animate(P,transform=matrix,time=smoothtime/4)

			continue

	/// turns parallax on or off so update() doesnt have to loop through extra stuff
	proc/toggle()
		var/setting = master.client?.parallax
		if(!setting) // turn it off
			for(var/atom/movable/screen/plane_parent/P as anything in src.layers)
				P.transform = matrix()
				qdel(P)
			background.invisibility = INVIS_ALWAYS
			active = FALSE
			UnregisterSignal(master,"mov_moved")
			UnregisterSignal(master,"mob_move_vehicle")
			UnregisterSignal(master,"mov_set_loc")
		else // turn it on
			if (!length(src.layers)) // no unnecessary planes on the client please
				layers += master.client?.get_plane(PLANE_PARALLAX_STARS)
				layers += master.client?.get_plane(PLANE_PARALLAX_GIANT)
				layers += master.client?.get_plane(PLANE_PARALLAX_PLANETS)
				layers += master.client?.get_plane(PLANE_PARALLAX_STATIONS)
			RegisterSignal(master,"mov_moved", .proc/update)
			RegisterSignal(master,"mob_move_vehicle", .proc/update)
			RegisterSignal(master,"mov_set_loc", .proc/update)
			background.invisibility = 0
			active = TRUE
			src.update(TRUE)
