#define PARALLAX_VIEW_WIDTH (WIDE_TILE_WIDTH + 4) // stolen from pali
#define PARALLAX_VIEW_HEIGHT (SQUARE_TILE_WIDTH + 4)

/datum/parallax_object
	name = "IMCODER"
	icon = 'icons/misc/1024x1024.dmi'
	icon_state = "plasma_giant"
	var/p_coords = list("X" = 150,"Y" = 150) // coords to stay near
	var/p_layer = 1
	var/p_scale = 300

	ss14
		icon = 'icons/obj/backgrounds.dmi'
		icon_state = "ss14"
		p_coords = list("X"=150,"Y" = 130)
		p_layer = 2
		p_scale = 120

	ss12
		icon = 'icons/obj/backgrounds.dmi'
		icon_state = "ss12-broken"
		p_coords = list("X"=130,"Y" = 150)
		p_layer = 2
		p_scale = 120

	planet
		icon = 'icons/misc/512x512.dmi'
		// x1-x2 dont seen to have sprites? what
		x3
			icon_state = "moon-green"
			p_coords = list("X"=150,"Y" = 130)
			p_layer = 2
			p_scale = 300
		x4
			icon = 'icons/obj/large/160x160.dmi'
			icon_state = "bigasteroid_1"
		x5
			icon_state = "moon-chunky"
		x15
			icon_state = "moon-ice"
		star_red
			icon = 'icons/misc/galactic_objects_large.dmi'
			icon_state = "star-red"

		star_blue
			icon = 'icons/misc/galactic_objects_large.dmi'
			icon_state = "star-blue"

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

/datum/hud/parallax
	// this is a hud that when given to a client will add parallax to their view.
	var/list/parallax_objects = list(list())
	var/list/scale = list(list())
	var/list/size = list(list())
	var/list/parallax_coords = list(list())
	var/mob/master
	var/atom/movable/screen/hud
		background
		parallaxP1
		parallaxP2
		parallaxP3
	New(M)
		..()
		if(isnull(M))
			CRASH("parallax HUD created with no master")
		master = M
		clients += master.client
		SPAWN(0)
			background = create_screen("background", "Space", 'icons/effects/overlays/parallaxBackground.dmi', "background", "1,1", HUD_LAYER)
			background.transform = matrix(master?.client.view ?2.1:1.5,0,0,0,1.5,0)
			background.screen_loc = master?.client.view ? "4,1" : "1,1"
			parallax_objects[1] += background
			parallax_objects[1] += create_screen("parallaxP1", "SS14", 'icons/obj/backgrounds.dmi', "ss14", "11,8", HUD_LAYER+2)
			parallax_objects[1] += create_screen("parallaxP2", "Planet", 'icons/misc/1024x1024.dmi', "plasma_giant", "1,1", HUD_LAYER+1)
			parallax_objects[1] += create_screen("parallaxP3", "SS12", 'icons/obj/backgrounds.dmi', "ss12-broken", "21,8", HUD_LAYER+2)
			scale[1][parallaxP1] = 120
			size[1][parallaxP1] = 0.3
			parallax_coords[1][parallaxP1] = list("X" = 150,"Y" = 170)
			scale[1][parallaxP3] = 50
			size[1][parallaxP3] = 0.7
			parallax_coords[1][parallaxP3] = list("X" = 150,"Y" = 130)
			scale[1][parallaxP2] = 300
			size[1][parallaxP2] = 1
			parallax_coords[1][parallaxP2] = list("X" = 130,"Y" = 100)

			parallax_objects[3] += background
			parallax_objects[3] += create_screen("parallaxP1", "SS14", 'icons/obj/backgrounds.dmi', "ss14", "11,8", HUD_LAYER+2)
			parallax_objects[3] += create_screen("parallaxP1", "SS14", 'icons/obj/backgrounds.dmi', "ss14", "11,8", HUD_LAYER+2)
			parallax_objects[3] += create_screen("parallaxP1", "SS14", 'icons/obj/backgrounds.dmi', "ss14", "11,8", HUD_LAYER+2)
			scale[3][parallaxP1] = 120
			size[3][parallaxP1] = 0.3
			parallax_coords[3][parallaxP1] = list("X" = 150,"Y" = 170)
			scale[3][parallaxP3] = 50
			size[3][parallaxP3] = 0.7
			parallax_coords[3][parallaxP3] = list("X" = 150,"Y" = 130)
			scale[3][parallaxP2] = 300
			size[3][parallaxP2] = 1
			parallax_coords[3][parallaxP2] = list("X" = 130,"Y" = 100)

			for(var/list/A in parallax_objects)
				for(var/atom/movable/screen/hud/P in parallax_objects[A])
					P.plane = PLANE_SPACE
					P.appearance_flags += TILE_BOUND
					P.mouse_opacity = 0

	proc/update()
		var/turf/M = get_turf(master) // i hate byond i hate byond i hate byond
		for(var/atom/movable/screen/hud/P in src.parallax_objects[M.z])
			if(P.id == "background")
				var/TargX = (150-M.x)/2
				var/TargY = (150-M.y)/2
				P.transform = matrix(master?.client.view ?2.1:1.5,0,TargX,0,1.5,TargY)
			else
				var/TargX = parallax_coords[P]["X"]
				var/TargY = parallax_coords[P]["Y"]
				P.transform = matrix(size[P], 0, (TargX-M.x)/scale[P]*((PARALLAX_VIEW_WIDTH - 4)/2)*32, 0, size[P], (TargY-M.y)/scale[P]*((PARALLAX_VIEW_HEIGHT - 4)/2)*32 )

/mob
	OnMove()
		..()
		if(!isnull(src.client))
			for(var/datum/hud/parallax/hud in src.huds)
				hud.update()
				continue
		for(var/mob/M in src.observers)
			if(!isnull(M.client))
				for(var/datum/hud/parallax/hud in M.huds)
					hud.update()
					continue
/obj/machinery/vehicle
	Move()
		..()
		for(var/mob/M in src.contents)
			if(!isnull(M.client))
				for(var/datum/hud/parallax/hud in M.huds)
					hud.update()
					continue
			for(var/mob/Mo in M.observers)
				if(!isnull(Mo.client))
					for(var/datum/hud/parallax/hud in Mo.huds)
						hud.update()
						continue
/obj/vehicle
	relaymove(mob/user, direction, delay, running)
		. = ..()
		for(var/mob/M in src.contents)
			if(!isnull(M?.client))
				for(var/datum/hud/parallax/hud in M.huds)
					hud.update()
					continue
			for(var/mob/Mo in Mo.observers)
				if(!isnull(Mo.client))
					for(var/datum/hud/parallax/hud in Mo.huds)
						hud.update()
						continue

