/turf/simulated/wall/false_wall
	name = "wall"
	icon = 'icons/obj/doors/Doorf.dmi'
	icon_state = "door1"
	blocks_air = 0
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
	var/list/known_by = list()
	var/can_be_auto = 1
	var/mod = null
	var/obj/overlay/floor_underlay = null
	var/dont_follow_map_settings_for_icon_state = 0

	temp
		var/was_rwall = 0

	reinforced
		icon_state = "rdoor1"
		mod = "R"

	New()
		..()
		//Hide the wires or whatever THE FUCK
		src.levelupdate()
		src.blocks_air = 1
		src.layer = src.layer - 0.1
		SPAWN_DBG(0)
			src.find_icon_state()
		SPAWN_DBG(1 SECOND)
			// so that if it's getting created by the map it works, and if it isn't this will just return
			src.setFloorUnderlay('icons/turf/floors.dmi', "plating", 0, 100, 0, "plating")
			if (src.can_be_auto)
				sleep(1 SECOND)
				for (var/turf/simulated/wall/auto/W in orange(1,src))
					W.update_icon()

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

	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		var/known = (user in known_by)
		if (src.density)
			//door is closed
			if (known)
				if (open())
					boutput(user, "<span class='notice'>The wall slides open.</span>")
			else if (prob(prob_opens))
				//it's hard to open
				if (open())
					boutput(user, "<span class='notice'>The wall slides open!</span>")
					known_by += user
			else
				return ..()
		else
			if (close())
				boutput(user, "<span class='notice'>The wall slides shut.</span>")
		return

	attackby(obj/item/S as obj, mob/user as mob)
		src.add_fingerprint(user)
		var/known = (user in known_by)
		if (isscrewingtool(S))
			//try to disassemble the false wall
			if (!src.density || prob(prob_opens))
				//without this, you can detect a false wall just by going down the line with screwdrivers
				//if it's already open, you can disassemble it no problem
				if (src.density && !known) //if it was closed, let them know that they did something
					boutput(user, "<span class='notice'>It was a false wall!</span>")
				//disassemble it
				boutput(user, "<span class='notice'>Now dismantling false wall.</span>")
				var/floorname1	= src.floorname
				var/floorintact1	= src.floorintact
				var/floorburnt1	= src.floorburnt
				var/icon/flooricon1	= src.flooricon
				var/flooricon_state1	= src.flooricon_state
				src.set_density(0)
				src.RL_SetOpacity(0)
				src.update_nearby_tiles()
				if (src.floor_underlay)
					qdel(src.floor_underlay)
				var/turf/simulated/floor/F = src.ReplaceWithFloor()
				F.name = floorname1
				F.icon = flooricon1
				F.icon_state = flooricon_state1
				F.intact = floorintact1
				F.burnt = floorburnt1
				//a false wall turns into a sheet of metal and displaced girders
				var/atom/A = new /obj/item/sheet(F)
				var/atom/B = new /obj/structure/girder/displaced(F)
				if(src.material)
					A.setMaterial(src.material)
					B.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)
					B.setMaterial(M)
				F.levelupdate()
				logTheThing("station", user, null, "dismantles a False Wall in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
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
			return src.attack_hand(user)

	proc/open()
		if (src.operating)
			return 0
		src.operating = 1
		src.name = "false wall"
		animate(src, time = delay, pixel_x = 25, easing = BACK_EASING)
		SPAWN_DBG(delay)
			//we want to return 1 without waiting for the animation to finish - the textual cue seems sloppy if it waits
			//actually do the opening things
			src.set_density(0)
			src.blocks_air = 0
			src.pathable = 1
			src.update_air_properties()
			src.RL_SetOpacity(0)
			if(!floorintact)
				src.intact = 0
				src.levelupdate()
			if(checkForMultipleDoors())
				update_nearby_tiles()
			src.operating = 0
		return 1

	proc/close()
		if (src.operating)
			return 0
		src.operating = 1
		src.name = "wall"
		animate(src, time = delay, pixel_x = 0, easing = BACK_EASING)
		src.set_density(1)
		src.blocks_air = 1
		src.pathable = 0
		src.update_air_properties()
		if (src.visible)
			src.RL_SetOpacity(1)
		src.intact = 1
		update_nearby_tiles()
		SPAWN_DBG(delay)
			//we want to return 1 without waiting for the animation to finish - the textual cue seems sloppy if it waits
			src.operating = 0
		return 1

	proc/find_icon_state()
		if(dont_follow_map_settings_for_icon_state)
			return
		if (!map_settings)
			return

		var/turf/wall_path = ispath(map_settings.walls) ? map_settings.walls : /turf/simulated/wall/auto
		var/turf/r_wall_path = ispath(map_settings.rwalls) ? map_settings.rwalls : /turf/simulated/wall/auto/reinforced
		src.icon = initial(wall_path.icon)
		if (src.can_be_auto)
			var/dirs = 0
			for (var/dir in cardinal)
				var/turf/T = get_step(src, dir)
				if (istype(T, /turf/simulated/wall/auto))
					var/turf/simulated/wall/auto/W = T
					// neither of us are reinforced
					if (!istype(W, r_wall_path) && !istype(src, /turf/simulated/wall/false_wall/reinforced))
						dirs |= dir
					// both of us are reinforced
					else if (istype(W, r_wall_path) && istype(src, /turf/simulated/wall/false_wall/reinforced))
						dirs |= dir
					if (W.light_mod) //If the walls have a special light overlay, apply it.
						src.RL_SetSprite("[W.light_mod][num2text(dirs)]")
			src.icon_state = "[mod][num2text(dirs)]"
		return src.icon_state

	get_desc()
		if (!src.density)
			return "It's a false wall. It's open."

	//Temp false walls turn back to regular walls when closed.
	temp/New()
		..()
		SPAWN_DBG(1.1 SECONDS)
			src.open()

	temp/close()
		if (src.operating)
			return 0
		src.operating = 1
		src.name = "wall"
		animate(src, time = delay, pixel_x = 0, easing = BACK_EASING)
		src.icon_state = "door1"
		src.set_density(1)
		src.blocks_air = 1
		src.pathable = 0
		src.update_air_properties()
		if (src.visible)
			src.opacity = 0
			src.RL_SetOpacity(1)
		src.intact = 1
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

	find_icon_state()
		return

/turf/simulated/wall/false_wall/centcom
	desc = "There seems to be markings on one of the edges, huh."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "leadwall"
	can_be_auto = 0

	find_icon_state()
		return

/turf/simulated/wall/false_wall/tempus
	desc = "The pattern on the wall seems to have a seam on it"
	icon = 'icons/turf/walls_tempus-green.dmi'
	icon_state = "0"

	find_icon_state()
		return
