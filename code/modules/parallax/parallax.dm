
/// before doing this, i had no idea what tuples even were. i still dont know, but now i know not to question what they are.
#define PARALLAX_GET_COORDS TUPLE_GET_1
#define PARALLAX_GET_ICON TUPLE_GET_2
#define PARALLAX_GET_ICON_STATE TUPLE_GET_3
#define PARALLAX_GET_SCALE TUPLE_GET_4
#define PARALLAX_GET_SIZE TUPLE_GET_5
#define PARALLAX_GET_LAYER TUPLE_GET_6

#define PARALLAX_PLANET(p) createPlanet(PARALLAX_GET_COORDS(p),PARALLAX_GET_ICON(p),PARALLAX_GET_ICON_STATE(p),PARALLAX_GET_SCALE(p),PARALLAX_GET_SIZE(p),PARALLAX_GET_LAYER(p))

#define PARALLAX_OBJ_COUNT 21
/// guide to the format here: | Coordinates | icon to use              |    icon      |scale|size|layer
// planets
#define PARALLAX_OBJ_1(x) x(map_settings.X0_coords, 'icons/misc/1024x1024.dmi',"plasma_giant", 0.1, 1, 1)
#define PARALLAX_OBJ_2(x) x(map_settings.X5_coords, 'icons/misc/512x512.dmi',"moon-green", 0.25, 1, 1)
#define PARALLAX_OBJ_3(x) x(list(list(0,0),list(23,292),list(0,0),list(0,0),list(71,43)), 'icons/obj/large/160x160.dmi',"bigasteroid_1", 0.25, 2, 1)
#define PARALLAX_OBJ_4(x) x(map_settings.X3_coords, 'icons/misc/512x512.dmi',"moon-chunky", 0.25, 1, 1)
#define PARALLAX_OBJ_5(x) x(list(list(0,0),list(0,0),list(277, 282)), 'icons/misc/512x512.dmi',"domusDei", 0.25, 1, 1)
#define PARALLAX_OBJ_6(x) x(list(list(0,0),list(0,0),list(72, 119)), 'icons/misc/512x512.dmi',"quadriga", 0.25, 1, 1)
#define PARALLAX_OBJ_7(x) x(map_settings.mundus_coords, 'icons/misc/512x512.dmi',"mundus", 0.25, 1, 1)
#define PARALLAX_OBJ_8(x) x(map_settings.iustitia_coords, 'icons/misc/512x512.dmi',"iustitia", 0.25, 1, 1)
#define PARALLAX_OBJ_9(x) x(map_settings.iudicium_coords, 'icons/misc/512x512.dmi',"iudicium", 0.25, 1, 1)
#define PARALLAX_OBJ_10(x) x(map_settings.fortuna_coords, 'icons/misc/512x512.dmi',"fortuna", 0.25, 1, 1)
#define PARALLAX_OBJ_11(x) x(list(list(0,0),list(0,0),list(161,215)), 'icons/misc/512x512.dmi',"fatuus", 0.25, 1, 1)
#define PARALLAX_OBJ_12(x) x(list(list(0,0),list(0,0),list(0,0),list(0,0),list(198,116)), 'icons/misc/512x512.dmi',"magus", 0.25, 1, 1)
#define PARALLAX_OBJ_13(x) x(list(list(0,0),list(0,0),list(0,0),list(0,0),list(195,188)), 'icons/misc/512x512.dmi',"regis", 0.25, 1, 1)
#define PARALLAX_OBJ_14(x) x(list(list(0,0),list(0,0),list(0,0),list(0,0),list(76,280)), 'icons/misc/512x512.dmi',"amantes", 0.25, 1, 1)
#define PARALLAX_OBJ_15(x) x(list(list(0,0),list(0,0),list(21,29)), 'icons/misc/512x512.dmi',"antistes", 0.25, 1, 1)
#define PARALLAX_OBJ_16(x) x(list(list(0,0)), 'icons/misc/512x512.dmi',"moon-ice", 0.25, 1, 1)
/// stations
#define PARALLAX_OBJ_17(x) x(map_settings.ss14_coords, 'icons/obj/backgrounds.dmi',"ss14", 0.28, 1, 2)
#define PARALLAX_OBJ_18(x) x(map_settings.ss12_coords, 'icons/obj/backgrounds.dmi',"ss12-broken", 0.28, 1, 2)
#define PARALLAX_OBJ_19(x) x(map_settings.ss10_coords, 'icons/obj/backgrounds.dmi',"ss10", 0.28, 1, 2)
// stars
#define PARALLAX_OBJ_20(x) x(map_settings.star_red_coords, 'icons/misc/galactic_objects_large.dmi',"star-red", 0.08, 1, 0)
#define PARALLAX_OBJ_21(x) x(map_settings.star_blue_coords, 'icons/misc/galactic_objects_large.dmi',"star-blue", 0.08, 1, 0)



/// this is a hud that when given to a client will add parallax to their view.
/datum/hud/parallax
	var/list/parallax_objects = list(list(),list(),list(),list(),list())
	var/list/hidden_objects = list(list(),list(),list(),list(),list())
	var/list/parallax_coords = list(list(),list(),list(),list(),list())
	var/list/scale = list()
	var/list/size = list()
	var/list/iconsize = list()

	var/mob/master
	var/active = TRUE
	var/lastzlevel

	var/atom/movable/screen/hud/background
	var/BGicon = "background"

	/// generate parallax_objects list out of settings
	proc/createPlanet(var/pCoords,var/Picon,var/Picon_state,var/Pscale,var/Psize,var/Player)
		var/atom/movable/screen/hud/N = create_screen(null,null, Picon,Picon_state, "CENTER,CENTER", HUD_LAYER)
		N.plane = PLANE_SPACE
		N.layer = HUD_LAYER + Player
		N.appearance_flags += TILE_BOUND
		N.mouse_opacity = 0
		N.screen_loc = "CENTER"
		/// generate visible / hidden on zlevel lists for z1 to z5
		for(var/i in 1 to 5)
			if (length(pCoords) >= i)
				parallax_coords[i][N] = pCoords[i]
				if (pCoords[i][1] == 0 || pCoords[i][2] == 0)
					hidden_objects[i][N] = N
				else
					parallax_objects[i][N] = N
			else
				hidden_objects[i][N] = N

		scale[N] = Pscale
		size[N] = Psize

		var/icon/Picon2 = icon(Picon)
		iconsize[N] = list(Picon2.Width(),Picon2.Height())

		N.transform = matrix(0,0,0,0,0,0)

	New(M)
		..()
		if(isnull(M))
			CRASH("parallax HUD created with no master")
		master = M
		RegisterSignal(M,"mov_moved", .proc/update)
		RegisterSignal(M,"mob_move_vehicle", .proc/update)
		clients += master.client

		/// background setup, this will be "in" every zlevel, but wont necessarily be visible
		background = create_screen("background", "Space", 'icons/effects/overlays/parallaxBackground.dmi', "background", "1,1", HUD_LAYER-1)
		background.transform = matrix(0,0,0,0,0,0)
		background.screen_loc = "CENTER"
		background.plane = PLANE_SPACE
		background.appearance_flags += TILE_BOUND
		background.mouse_opacity = 0
		background.icon_state = BGicon

		/// parallax settings setup
		PARALLAX_PLANET(PARALLAX_OBJ_1)
		PARALLAX_PLANET(PARALLAX_OBJ_2)
		PARALLAX_PLANET(PARALLAX_OBJ_3)
		PARALLAX_PLANET(PARALLAX_OBJ_4)
		PARALLAX_PLANET(PARALLAX_OBJ_5)
		PARALLAX_PLANET(PARALLAX_OBJ_6)
		PARALLAX_PLANET(PARALLAX_OBJ_7)
		PARALLAX_PLANET(PARALLAX_OBJ_8)
		PARALLAX_PLANET(PARALLAX_OBJ_9)
		PARALLAX_PLANET(PARALLAX_OBJ_10)
		PARALLAX_PLANET(PARALLAX_OBJ_11)
		PARALLAX_PLANET(PARALLAX_OBJ_12)
		PARALLAX_PLANET(PARALLAX_OBJ_13)
		PARALLAX_PLANET(PARALLAX_OBJ_14)
		PARALLAX_PLANET(PARALLAX_OBJ_15)
		PARALLAX_PLANET(PARALLAX_OBJ_16)
		PARALLAX_PLANET(PARALLAX_OBJ_17)
		PARALLAX_PLANET(PARALLAX_OBJ_18)
		PARALLAX_PLANET(PARALLAX_OBJ_19)
		PARALLAX_PLANET(PARALLAX_OBJ_20)
		PARALLAX_PLANET(PARALLAX_OBJ_21)

		src.update()

	/// updates parallax object transform values
	proc/update(var/zlevelchanged)
		if(!active || !master.client) return

		var/turf/master_turf = get_turf(master)

		/// due to the fact that the hud tracks the last zlevel it updated on, we dont need to use a complex signal
		if (lastzlevel != master_turf?.z)
			lastzlevel = master_turf.z
			zlevelchanged = TRUE
			for(var/atom/movable/screen/hud/Ph as anything in hidden_objects[master_turf.z])
				Ph.alpha = 0
				continue

		/// background scrolling and oshan handling
		#ifdef UNDERWATER_MAP
		if (master_turf.z != 2)
			background.alpha = 0
			return
		#else
		if (background)
			background.transform = matrix(master.client?.widescreen ? 2.61 : 2.5,0,(150-master_turf.x)/2,0,2.5,(150-master_turf.y)/2)
		#endif

		/// list of objects that are intended to show up on this zlevel
		for(var/atom/movable/screen/hud/P as anything in parallax_objects[master_turf.z])

			var/coordx = parallax_coords[master_turf.z][P][1]
			var/coordy = parallax_coords[master_turf.z][P][2]

			/// half screen width
			var/Hsw = master.client.widescreen ? 10 : 7

			var/IWidth = iconsize[P][1]
			var/IHeight = iconsize[P][2]
			var/offsetX = ((coordx-master_turf.x)*scale[P])*32-IWidth/2
			var/offsetY = ((coordy-master_turf.y)*scale[P])*32-IWidth/2

			/// if the object is far enough away, we can hide it
			if ((offsetX < -(Hsw*32+IWidth)) || (offsetY < -(7*32+IHeight)))
				P.alpha = 0
				continue
			else if ((offsetX > (Hsw*32+IWidth)) || (offsetY > (7*32+IHeight)))
				P.alpha = 0
				continue

			var/matrix/matrix = matrix(size[P], 0, offsetX, 0, size[P], offsetY)

			/// zlevelchanged means the master's zlevel changed
			if (zlevelchanged == TRUE || P.alpha == 0)
				P.transform = matrix
				P.alpha = 255
				continue

			/// smooth out the stuff if we didnt change zlevel
			var/smoothtime = round(world.icon_size/max(master.glide_size*world.tick_lag,0.01),world.tick_lag)
			animate(P,transform=matrix,time=smoothtime)

			continue

	/// turns parallax on or off so update() doesnt have to loop through extra stuff
	proc/toggle()
		var/setting = master?.client?.parallax
		var/turf/master_turf = get_turf(master.loc)
		if(!setting)
			var/Slist = parallax_objects[master_turf.z]
			for(var/atom/movable/screen/hud/P as anything in Slist)
				P.alpha = 0
			active = FALSE
			background.transform = matrix(0,0,0,0,0,0)
		else
			active = TRUE
			src.update(TRUE)
