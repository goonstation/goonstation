#define PARALLAX_VIEW_WIDTH (WIDE_TILE_WIDTH + 4) // stolen from pali
#define PARALLAX_VIEW_HEIGHT (SQUARE_TILE_WIDTH + 4)

/datum/parallax_object // stores all the objects for parallax that arent the background
	var/icon = 'icons/misc/1024x1024.dmi'
	var/icon_state = "plasma_giant"
	var/coords = list("X" = 150,"Y" = 150) // coords to stay near
	var/layer = 1 // layering
	var/scale = 0.25 // this makes things like planets barely move, higher is faster
	var/size = 1
	var/zlevel = 1

	ss14
		icon = 'icons/obj/backgrounds.dmi'
		icon_state = "ss14"
		coords = list("X"=150,"Y" = 130)
		layer = 2
		scale = 0.3

	ss12
		icon = 'icons/obj/backgrounds.dmi'
		icon_state = "ss12-broken"
		coords = list("X"=130,"Y" = 150)
		layer = 2
		scale = 0.3

	star
		icon = 'icons/misc/galactic_objects_large.dmi'
		icon_state = "star-red"
		coords = list("X"=160,"Y" = 130)
		scale = 0.125
		layer = 0

		blue
			icon = 'icons/misc/galactic_objects_large.dmi'
			icon_state = "star-blue"
			coords = list("X"=160,"Y" = 135)

	planet
		icon = 'icons/misc/512x512.dmi'
		size = 1
		scale = 0.5
		// x1-x2 dont seen to have sprites? what
		x3
			icon_state = "moon-green"
			coords = list("X"=20,"Y" = 260)
			layer = 2
			scale = 0.5
			zlevel = 2
		x4
			icon = 'icons/obj/large/160x160.dmi'
			icon_state = "bigasteroid_1"

		x5
			icon_state = "moon-chunky"

		x15
			icon_state = "moon-ice"

		domus_dei
			icon_state = "domusDei"

		quadriga
			icon_state = "quadriga"

		mundus
			icon_state = "mundus"

		iustitia
			icon_state = "iustitia"

		iudicium
			icon_state = "iudicium"

		fortuna
			icon_state = "fortuna"

		fatuus
			icon_state = "fatuus"

		magus
			icon_state = "magus"

		regis
			icon_state ="regis"

		amantes
			icon_state = "amantes"

		antistes
			icon_state = "antistes"

// wow there are so many different objects in space

/datum/hud/parallax
	// this is a hud that when given to a client will add parallax to their view.
	var/list/parallax_objects = list()
	var/list/parallax_settings = list()
	var/list/parallax_coords = list(list())
	var/list/parallax_zlevel = list()
	var/list/scale = list()
	var/list/size = list()

	var/mob/master
	var/active = TRUE

	var/atom/movable/screen/hud/background

	New(M)
		..()
		if(isnull(M))
			CRASH("parallax HUD created with no master")
		master = M
		clients += master.client
		SPAWN(0)
			background = create_screen("background", "Space", 'icons/effects/overlays/parallaxBackground.dmi', "background", "1,1", HUD_LAYER-1)
			background.transform = matrix(0,0,0,0,0,0)
			background.screen_loc = master?.client?.view ? "4,1" : "1,1"
			background.plane = PLANE_SPACE
			background.appearance_flags += TILE_BOUND


			// parallax for z1
			parallax_settings += new /datum/parallax_object
			parallax_settings += new /datum/parallax_object/planet/iudicium
			parallax_settings += new /datum/parallax_object/ss14
			parallax_settings += new /datum/parallax_object/ss12
			parallax_settings += new /datum/parallax_object/planet/iustitia
			parallax_settings += new /datum/parallax_object/planet/magus
			parallax_settings += new /datum/parallax_object/planet/mundus
			parallax_settings += new /datum/parallax_object/star/blue
			parallax_settings += new /datum/parallax_object/star
			parallax_settings += new /datum/parallax_object/planet/x3


			// generate parallax_objects list out of settings
			for(var/datum/parallax_object/P as anything in parallax_settings)
				var/centerx = round((PARALLAX_VIEW_WIDTH - 4)/2)
				var/centery = round((PARALLAX_VIEW_HEIGHT - 4)/2)
				var/atom/movable/screen/hud/N = create_screen(null,null, P.icon,P.icon_state, "[centerx],[centery]", HUD_LAYER)
				N.plane = PLANE_SPACE
				N.layer = HUD_LAYER + P.layer
				N.appearance_flags += TILE_BOUND
				N.mouse_opacity = 0

				parallax_coords[N] = P.coords
				scale[N] = P.scale
				size[N] = P.size
				parallax_zlevel[N] = P.zlevel

				parallax_objects[N] = N
				N.transform = matrix(0,0,0,0,0,0)

	proc/update(var/turf/master_turf) // hopefully this is fast enough
		if(!active) return

		for(var/atom/movable/screen/hud/P as anything in parallax_objects)

			if(parallax_zlevel[P] != master_turf.z)
				P.transform = matrix(0,0,0,0,0,0)
				continue
			else
				var/matrix = matrix(size[P],0,(parallax_coords[P]["X"]-master_turf.x)*(scale[P])*32-icon(P.icon,P.icon_state).Width()/2,0, size[P],(parallax_coords[P]["Y"]-master_turf.y)*(scale[P])*32-icon(P.icon,P.icon_state).Height()/2)
				animate(P,transform=matrix,time=round(world.icon_size/master.glide_size*world.tick_lag,world.tick_lag))
				continue

		// background scrolling
		background.transform = matrix(master?.client.view ?2.1:1.5,0,(150-master_turf.x)/2,0,1.5,(150-master_turf.y)/2)

		//animate(background,transform=matrix,time=round(world.icon_size/master.glide_size*world.tick_lag,world.tick_lag))

	proc/toggle() // makes it so update() doesnt have to loop through extra stuff
		var/setting = master?.client?.parallax
		if(!setting)
			for(var/atom/movable/screen/hud/P as anything in parallax_objects)
				P.transform = matrix(0,0,0,0,0,0)
			active = FALSE
		else
			active = TRUE


// below stuff is everything that will trigger the update() proc
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
		for(var/mob/M as anything in src.contents)
			if(!isnull(M.client))
				M.parallax.update(NewLoc)
			for(var/mob/Mo as anything in M.observers)
				if(isnull(Mo.client))
					continue
				Mo.parallax.update(NewLoc)
/obj/vehicle
	Move(var/NewLoc)
		. = ..()
		for(var/mob/M as anything in src.contents)
			if(!isnull(M?.client))
				M.parallax.update(NewLoc)
			for(var/mob/Mo as anything in M.observers)
				if(isnull(Mo.client))
					continue
				Mo.parallax.update(NewLoc)

