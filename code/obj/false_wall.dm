ADMIN_INTERACT_PROCS(/turf/simulated/wall/false_wall, proc/open, proc/close)
/turf/simulated/wall/false_wall
	name = "wall"
	icon = 'icons/obj/doors/Doorf.dmi'
	icon_state = "door1"
	gas_impermeable = 0
	var/operating = null
	var/visible = 1
	var/floorname
	var/floorintact
	var/floorhealth
	var/floorburnt
	var/icon/flooricon
	var/flooricon_state
	var/const/delay = 15
	var/const/prob_opens = 25
	var/list/datum/mind/known_by = list()
	var/can_be_auto = 1
	var/mod = null
	var/obj/overlay/floor_underlay = null
	// this is a special case where we EXPLICITLY do NOT use HELP_MESSAGE_OVERRIDE because we don't want the rightclick menu Help button to give it away

	temp
		var/was_rwall = 0

	reinforced
		icon_state = "rdoor1"
		mod = "R"

	New()
		..()
		//Hide the wires or whatever THE FUCK
		src.levelupdate()
		src.gas_impermeable = 1
		src.layer = src.layer - 0.1
		SPAWN(0)
			src.UpdateIcon()
		SPAWN(1 SECOND)
			// so that if it's getting created by the map it works, and if it isn't this will just return
			src.setFloorUnderlay('icons/turf/floors.dmi', "plating", 0, 100, 0, "plating")
			if (src.can_be_auto)
				for (var/turf/simulated/wall/auto/W in orange(1,src))
					W.UpdateIcon()
				for (var/obj/mesh/M in orange(1,src))
					M.UpdateIcon()
				for (var/obj/window/auto/W in orange(1,src))
					W.UpdateIcon()
				for (var/turf/simulated/wall/false_wall/F in orange(1,src))
					F.UpdateIcon()

	Del()
		src.RL_SetSprite(null)
		if (floor_underlay)
			qdel(floor_underlay)
		..()

	proc/setFloorUnderlay(FloorIcon, FloorIcon_State, Floor_Intact, Floor_Health, Floor_Burnt, Floor_Name)
		if(floor_underlay)
			//only one underlay
			return 0
		if(!(FloorIcon || FloorIcon_State))
			return 0
		if(!Floor_Health)
			Floor_Health = 150
		if(!Floor_Burnt)
			Floor_Burnt = 0
		if(!Floor_Intact)
			Floor_Intact = 1
		if(!Floor_Name)
			Floor_Name = "floor"

		// SCREAM
		floor_underlay = new /obj/overlay(src)
		floor_underlay.icon = FloorIcon
		floor_underlay.icon_state = FloorIcon_State
		floor_underlay.layer = src.layer - 0.1
		floor_underlay.mouse_opacity = 0
		floor_underlay.plane = PLANE_FLOOR

		src.flooricon = FloorIcon
		src.flooricon_state = FloorIcon_State
		src.floorintact = Floor_Intact
		src.floorhealth = Floor_Health
		src.floorburnt = Floor_Burnt
		src.floorname = Floor_Name
		return 1

	get_help_message(dist, mob/user)
		. = ..()
		if(!src.density)
			. = "You can use a <b>screwdriver</b> to disassemble it."

	attack_hand(mob/user)
		src.add_fingerprint(user)
		var/known = user.mind && (user.mind in known_by)
		if (src.density)
			//door is closed
			if (known)
				if (open())
					boutput(user, SPAN_NOTICE("The wall slides open."))
			else if (prob(prob_opens))
				//it's hard to open
				if (open())
					boutput(user, SPAN_NOTICE("The wall slides open!"))
					if(user.mind)
						known_by |= user.mind
			else
				return ..()
		else
			if (close())
				boutput(user, SPAN_NOTICE("The wall slides shut."))
		return

	attackby(obj/item/S, mob/user)
		src.add_fingerprint(user)
		var/known = user.mind && (user.mind in known_by)
		if (isscrewingtool(S))
			//try to disassemble the false wall
			if (!src.density || prob(prob_opens))
				//without this, you can detect a false wall just by going down the line with screwdrivers
				//if it's already open, you can disassemble it no problem
				if (src.density && !known) //if it was closed, let them know that they did something
					boutput(user, SPAN_NOTICE("It was a false wall!"))
				//disassemble it
				boutput(user, SPAN_NOTICE("Now dismantling false wall."))

				//a false wall turns into a sheet of metal and displaced girders
				var/atom/A = new /obj/item/sheet(src)
				var/atom/B = new /obj/structure/girder/displaced(src)
				var/datum/material/defaultMaterial = getMaterial("steel")
				A.setMaterial(src.material ? src.material : defaultMaterial)
				B.setMaterial(src.girdermaterial ? src.girdermaterial : defaultMaterial)

				var/floorname1	= src.floorname
				var/floorintact1	= src.floorintact
				var/floorburnt1	= src.floorburnt
				var/icon/flooricon1	= src.flooricon
				var/flooricon_state1	= src.flooricon_state
				src.set_density(0)
				src.set_opacity(0)
				src.update_nearby_tiles()
				if (src.floor_underlay)
					qdel(src.floor_underlay)
				var/turf/simulated/floor/F = src.ReplaceWithFloor()
				F.name = floorname1
				F.icon = flooricon1
				F.icon_state = flooricon_state1
				F.setIntact(floorintact1)
				F.burnt = floorburnt1

				F.levelupdate()
				logTheThing(LOG_STATION, user, "dismantles a False Wall in [user.loc.loc] ([log_loc(user)])")
				return
			else
				return ..()
		// grabsmash
		else if (istype(S, /obj/item/grab/))
			var/obj/item/grab/G = S
			if  (!grab_smash(G, user))
				return ..(S, user)
			else return
		else
			return src.Attackhand(user)

	proc/open()
		if (src.operating)
			return 0
		src.operating = 1
		src.name = src.material ? "false [src.material.getName()] wall" : "false wall"
		animate(src, time = delay, pixel_x = 25, easing = BACK_EASING)
		SPAWN(delay)
			//we want to return 1 without waiting for the animation to finish - the textual cue seems sloppy if it waits
			//actually do the opening things
			src.set_density(0)
			src.flags &= ~FLUID_DENSE
			src.gas_impermeable = 0
			src.pathable = 1
			src.update_air_properties()
			src.set_opacity(0)
			if(!floorintact)
				src.setIntact(FALSE)
				src.levelupdate()
			update_nearby_tiles()
			src.operating = 0
		return 1

	proc/close()
		if (src.operating)
			return 0
		src.operating = 1
		src.name = src.material ? "[src.material.getName()] wall" : "steel wall"
		animate(src, time = delay, pixel_x = 0, easing = BACK_EASING)
		src.set_density(1)
		src.flags |= FLUID_DENSE
		src.gas_impermeable = 1
		src.pathable = 0
		src.update_air_properties()
		if (src.visible)
			if (src.material)
				src.set_opacity(src.material.getAlpha() <= MATERIAL_ALPHA_OPACITY ? FALSE : TRUE)
			else
				src.set_opacity(1)
		src.setIntact(TRUE)
		for(var/obj/decal/cleanable/clean in src)
			clean.plane = PLANE_FLOOR
		update_nearby_tiles()
		SPAWN(delay)
			//we want to return 1 without waiting for the animation to finish - the textual cue seems sloppy if it waits
			src.operating = 0
		return 1

	update_icon()
		..()
		if (!map_settings)
			return

		if (src.can_be_auto) /// is the false wall able to mimic autowalls
			var/turf/simulated/wall/auto/wall_path = ispath(map_settings.walls) ? map_settings.walls : /turf/simulated/wall/auto
			src.icon = initial(wall_path.icon)

			var/static/list/s_connects_to = typecacheof(list(/turf/simulated/wall/auto/supernorn, /turf/simulated/wall/auto/reinforced/supernorn,
			/turf/simulated/wall/auto/jen, /turf/simulated/wall/auto/reinforced/jen,
			/turf/simulated/wall/false_wall, /turf/simulated/wall/auto/shuttle, /obj/machinery/door,
			/obj/window, /obj/mapping_helper/wingrille_spawn, /turf/simulated/wall/auto/reinforced/supernorn/yellow,
			/turf/simulated/wall/auto/reinforced/supernorn/blackred, /turf/simulated/wall/auto/reinforced/supernorn/orange,
			/turf/simulated/wall/auto/old, /turf/simulated/wall/auto/reinforced/old,
			/turf/unsimulated/wall/auto/supernorn,/turf/unsimulated/wall/auto/reinforced/supernorn))

			var/static/list/s_connects_with_overlay = typecacheof(list(/turf/simulated/wall/auto/shuttle,
			/turf/simulated/wall/auto/shuttle, /obj/machinery/door, /obj/window, /obj/mapping_helper/wingrille_spawn))

			if (istype(src, /turf/simulated/wall/false_wall/reinforced))
				wall_path = ispath(map_settings.rwalls) ? map_settings.rwalls : /turf/simulated/wall/auto/reinforced
				/// donut3 walls, remove if they ever connect together like supernorn walls
				s_connects_with_overlay += /turf/simulated/wall/auto/jen
			else
				s_connects_with_overlay += /turf/simulated/wall/auto/reinforced/jen

			/// this was borrowed from autowalls as the code that was barely worked

			/// basically this is doing what an autowall of the path wall_path would do
			var/typeinfo/turf/simulated/wall/auto/typinfo = get_type_typeinfo(wall_path)
			var/s_connect_overlay = typinfo.connect_overlay
			var/static/list/s_connects_with_overlay_exceptions = list()
			var/static/list/s_connects_to_exceptions = typecacheof(/turf/simulated/wall/auto/shuttle)

			var/s_connect_diagonal =  typinfo.connect_diagonal
			var/image/s_connect_image = initial(wall_path.connect_image)

			var/light_mod = initial(wall_path.light_mod)
			mod = initial(wall_path.mod)


			var/connectdir = get_connected_directions_bitflag(s_connects_to, s_connects_to_exceptions, TRUE, s_connect_diagonal)
			var/the_state = "[mod][connectdir]"
			icon_state = the_state

			if (light_mod)
				src.RL_SetSprite("[light_mod][connectdir]", initial(wall_path.RL_OverlayIcon))

			if (s_connect_overlay)
				var/overlaydir = get_connected_directions_bitflag(s_connects_with_overlay, s_connects_with_overlay_exceptions, TRUE)
				if (overlaydir)
					if (!s_connect_image)
						s_connect_image = image(src.icon, "connect[overlaydir]")
					else
						s_connect_image.icon_state = "connect[overlaydir]"
					src.AddOverlays(s_connect_image, "connect")
				else
					src.ClearSpecificOverlays("connect")


	get_desc()
		if (!src.density)
			return "It's a false wall. It's open."

	//Temp false walls turn back to regular walls when closed.
	temp/New()
		..()
		SPAWN(1.1 SECONDS)
			src.open()

	temp/close()
		if (src.operating)
			return 0
		src.operating = 1
		src.name = "wall"
		animate(src, time = delay, pixel_x = 0, easing = BACK_EASING)
		src.icon_state = "door1"
		src.set_density(1)
		src.gas_impermeable = 1
		src.pathable = 0
		src.update_air_properties()
		if (src.visible)
			src.set_opacity(0)
			src.set_opacity(1)
		src.setIntact(TRUE)
		update_nearby_tiles()
		if(src.was_rwall)
			src.ReplaceWithRWall()
		else
			src.ReplaceWithWall()
		return 1

/turf/simulated/wall/false_wall/hive
	name = "strange hive wall"
	desc = "Looking more closely, these are actually really squat octagons, not hexagons! What!!"
	icon = 'icons/turf/walls.dmi'
	icon_state = "hive"
	can_be_auto = 0


/turf/simulated/wall/false_wall/centcom
	desc = "There seems to be markings on one of the edges, huh."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "leadwall"
	can_be_auto = 0

/obj/shifting_wall
	name = "r wall"
	desc = ""
	opacity = 1
	density = 1
	anchored = ANCHORED

	icon = 'icons/turf/walls.dmi'
	icon_state = "r_wall"

	New()
		..()
		update()

	proc/update()
		var/list/possible = new/list()

		for(var/A in cardinal)
			var/turf/current = get_step(src,A)
			if(current.density) continue
			if(is_blocked_turf(current)) continue
			possible +=  current

		if(!possible.len)
			SPAWN(3 SECONDS) update()
			return

		var/turf/picked = pick(possible)
		if(src.loc.invisibility) src.loc.invisibility = INVIS_NONE
		src.set_loc(picked)
		SPAWN(0.5 SECONDS) picked.invisibility = INVIS_ALWAYS_ISH

		SPAWN(rand(50,80)) update()

/obj/shifting_wall/sneaky

	var/sightrange = 8

	proc/find_suitable_tiles()
		var/list/possible = new/list()

		for(var/A in cardinal)
			var/turf/current = get_step(src,A)
			if(current.density) continue
			if(is_blocked_turf(current)) continue
			if(someone_can_see(current)) continue
			possible +=  current

		return possible

	proc/someone_can_see(var/atom/A)
		for(var/mob/living/L in view(sightrange,A))
			if(!L.sight_check(1)) continue
			if(A in view(sightrange,L)) return 1
		return 0

	proc/someone_can_see_me()
		for(var/mob/living/L in view(sightrange,src))
			if(L.sight_check(1)) continue
			if(src in view(sightrange,L)) return 1
		return 0

	update()
		if(someone_can_see_me()) //Award for the most readable code GOES TO THIS LINE.
			SPAWN(rand(50,80)) update()
			return

		var/list/possible = find_suitable_tiles()

		if(!possible.len)
			SPAWN(3 SECONDS) update()
			return

		var/turf/picked = pick(possible)
		if(src.loc.invisibility) src.loc.invisibility = INVIS_NONE
		if(src.loc.opacity) src.loc.set_opacity(0)

		src.set_loc(picked)

		SPAWN(0.5 SECONDS)
			picked.invisibility = INVIS_ALWAYS_ISH
			picked.set_opacity(1)

		SPAWN(rand(50,80)) update()
