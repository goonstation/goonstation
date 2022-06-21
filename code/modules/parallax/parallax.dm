#define PARALLAX_VIEW_WIDTH (WIDE_TILE_WIDTH + 4)
#define PARALLAX_VIEW_HEIGHT (SQUARE_TILE_WIDTH + 4)

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
#define PARALLAX_OBJ_1(x) x(map_settings.X0_coords, 'icons/misc/1024x1024.dmi',"plasma_giant", 0.14, 1, 1)
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
#define PARALLAX_OBJ_20(x) x(map_settings.star_red_coords, 'icons/misc/galactic_objects_large.dmi',"star-red", 0.12, 1, 0)
#define PARALLAX_OBJ_21(x) x(map_settings.star_blue_coords, 'icons/misc/galactic_objects_large.dmi',"star-blue", 0.12, 1, 0)



/// this is a hud that when given to a client will add parallax to their view.
/datum/hud/parallax
	var/list/parallax_objects = list()
	var/list/parallax_settings = list()
	var/list/parallax_coords = list(list())
	var/list/scale = list()
	var/list/size = list()

	var/mob/master
	var/active = TRUE

	var/atom/movable/screen/hud/background
	var/BGicon = "background"

	/// generate parallax_objects list out of settings
	proc/createPlanet(var/pCoords,var/Picon,var/Picon_state,var/Pscale,var/Psize,var/Player)
		var/atom/movable/screen/hud/N = create_screen(null,null, Picon,Picon_state, "CENTER,CENTER", HUD_LAYER)
		N.plane = PLANE_SPACE
		N.layer = HUD_LAYER + Player
		N.appearance_flags += TILE_BOUND
		N.mouse_opacity = 1

		parallax_coords[N] = pCoords
		scale[N] = Pscale
		size[N] = Psize

		parallax_objects[N] = N
		N.transform = matrix(0,0,0,0,0,0)

	New(M)
		..()
		if(isnull(M))
			CRASH("parallax HUD created with no master")
		master = M
		clients += master.client
		SPAWN(0)

			/// background setup, this will be "in" every zlevel, but wont necessarily be visible
			background = create_screen("background", "Space", 'icons/effects/overlays/parallaxBackground.dmi', "background", "1,1", HUD_LAYER-1)
			background.transform = matrix(0,0,0,0,0,0)
			background.screen_loc = master?.client?.view ? "4,1" : "1,1"
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

	/// updates parallax object transform values
	proc/update(var/turf/master_turf)
		if(!active) return
		#ifdef UNDERWATER_MAP
		return
		#endif

		for(var/atom/movable/screen/hud/P as anything in parallax_objects)

			if(length(parallax_coords[P]) >= master_turf.z)
				if (parallax_coords[P][master_turf.z] == null)
					P.transform = matrix(0,0,0,0,0,0)
					continue

				var/coordx = parallax_coords[P][master_turf.z][1]
				var/coordy = parallax_coords[P][master_turf.z][2]
				if (coordx == 0 || coordy == 0)
					P.transform = matrix(0,0,0,0,0,0)
					continue

				var/icon/pIcon = icon(P.icon)
				var/offsetX = ((coordx-master_turf.x)*scale[P])*32-pIcon.Width()/2
				var/offsetY = ((coordy-master_turf.y)*scale[P])*32-pIcon.Height()/2
				var/matrix = matrix(size[P], 0, offsetX, 0, size[P], offsetY)

				animate(P,transform=matrix,time=round(world.icon_size/master.glide_size*world.tick_lag,world.tick_lag))
				continue

			else

				P.transform = matrix(0,0,0,0,0,0)
				continue


		/// background scrolling so we dont loop through another time
		background.transform = matrix(master?.client.view ?2.1:1.5,0,(150-master_turf.x)/2,0,1.5,(150-master_turf.y)/2)
		//animate(background,transform=matrix,time=round(world.icon_size/master.glide_size*world.tick_lag,world.tick_lag))

	/// turns parallax on or off so update() doesnt have to loop through extra stuff
	proc/toggle()
		var/setting = master?.client?.parallax
		if(!setting)
			for(var/atom/movable/screen/hud/P as anything in parallax_objects)
				P.transform = matrix(0,0,0,0,0,0)
			active = FALSE
			background.transform = matrix(0,0,0,0,0,0)
		else
			active = TRUE


/// below stuff is everything that will trigger the update() proc
/mob
	OnMove()
		..()
		if(!isnull(src.client))
			var/turf/NewLoc = get_turf(src)
			src.parallax.update(NewLoc)
		for(var/mob/M as anything in src.observers)
			if(isnull(M.client))
				continue
			var/turf/NewLoc = get_turf(M)
			M.parallax.update(NewLoc)
/obj/machinery/vehicle
	Move(var/NewLoc)
		..()
		for(var/mob/M in src)
			if(!isnull(M.client))
				M.parallax.update(NewLoc)
			for(var/mob/Mo as anything in M.observers)
				if(isnull(Mo.client))
					continue
				Mo.parallax.update(NewLoc)
/obj/vehicle
	Move(var/NewLoc)
		. = ..()
		for(var/mob/M in src)
			if(!isnull(M?.client))
				M.parallax.update(NewLoc)
			for(var/mob/Mo as anything in M.observers)
				if(isnull(Mo.client))
					continue
				Mo.parallax.update(NewLoc)

