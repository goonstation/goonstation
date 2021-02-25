/turf
	icon = 'icons/turf/floors.dmi'
	plane = PLANE_FLOOR //See _plane.dm, required for shadow effect
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	var/intact = 1
	var/allows_vehicles = 1

	var/tagged = 0 // Gang wars thing

	level = 1.0

	unsimulated
		var/can_replace_with_stuff = 0	//If ReplaceWith() actually does a thing or not.
#ifdef RUNTIME_CHECKING
		can_replace_with_stuff = 1  //Shitty dumb hack bullshit
#endif
		allows_vehicles = 0

	proc/burn_down()
		return

		//Properties for open tiles (/floor)
	#define _UNSIM_TURF_GAS_DEF(GAS, ...) var/GAS = 0;
	APPLY_TO_GASES(_UNSIM_TURF_GAS_DEF)

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	#undef _UNSIM_TURF_GAS_DEF

	//Properties for both
	var/temperature = T20C

	var/blocks_air = 0
	var/icon_old = null
	var/name_old = null
	var/tmp/pathweight = 1
	var/tmp/pathable = 1
	var/can_write_on = 0
	var/tmp/messy = 0 //value corresponds to how many cleanables exist on this turf. Exists for the purpose of making fluid spreads do less checks.
	var/tmp/checkingexit = 0 //value corresponds to how many objs on this turf implement checkexit(). lets us skip a costly loop later!
	var/tmp/checkingcanpass = 0 // "" how many implement canpass()
	var/tmp/checkinghasentered = 0 // "" hasproximity as well as items with a mat that hasproximity
	var/tmp/checkinghasproximity = 0
	var/wet = 0
	throw_unlimited = 0 //throws cannot stop on this tile if true (also makes space drift)

	var/step_material = 0
	var/step_priority = 0 //compare vs. shoe for step sounds

	var/special_volume_override = -1 //if greater than or equal to 0, override

	var/turf_flags = 0

	disposing() // DOES NOT GET CALLED ON TURFS!!!
		SHOULD_NOT_OVERRIDE(TRUE)
		..()

	Del()
		if (length(cameras))
			for (var/obj/machinery/camera/C as() in by_type[/obj/machinery/camera])
				if(C.coveredTiles)
					C.coveredTiles -= src
		cameras = null
		..()

	onMaterialChanged()
		..()
		if(istype(src.material))
			if(initial(src.opacity))
				src.RL_SetOpacity(src.material.alpha <= MATERIAL_ALPHA_OPACITY ? 0 : 1)

		blocks_air = material.hasProperty("permeable") ? material.getProperty("permeable") >= 33 : blocks_air
		return

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].type"] << type
		serialize_icon(F, path, sandbox)
		F["[path].name"] << name
		F["[path].dir"] << dir
		F["[path].desc"] << desc
		F["[path].color"] << color
		F["[path].density"] << density
		F["[path].opacity"] << opacity
		F["[path].pixel_x"] << pixel_x
		F["[path].pixel_y"] << pixel_y

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		deserialize_icon(F, path, sandbox)
		F["[path].name"] >> name
		F["[path].dir"] >> dir
		F["[path].desc"] >> desc
		F["[path].color"] >> color
		F["[path].density"] >> density
		F["[path].opacity"] >> opacity
		RL_SetOpacity(opacity)
		F["[path].pixel_x"] >> pixel_x
		F["[path].pixel_y"] >> pixel_y
		return DESERIALIZE_OK

	proc/canpass()
		if( density )
			return 0
		for( var/thing in contents )
			var/atom/A = thing
			if( A.density && !ismob(A) )
				return 0
		return 1

	proc/tilenotify(turf/notifier)

	proc/selftilenotify()

	proc/generate_worldgen()

	proc/inherit_area() //jerko built a thing
		if(!loc:expandable) return
		for(var/dir in (cardinal + 0))
			var/turf/thing = get_step(src, dir)
			var/area/fuck_everything = thing?.loc
			if(fuck_everything?.expandable && (fuck_everything.type != /area))
				fuck_everything.contents += src
				return

		var/area/built_zone/zone = new//TODO: cache a list of these bad boys because they don't get GC'd because WHY WOULD THEY?!
		zone.contents += src//get in the ZONE


/obj/overlay/tile_effect
	name = ""
	anchored = 1
	density = 0
	mouse_opacity = 0
	alpha = 255
	layer = TILE_EFFECT_OVERLAY_LAYER
	animate_movement = NO_STEPS // fix for things gliding around all weird

	pooled(var/poolname)
		overlays.len = 0
		..()

	Move()
		return 0

/obj/overlay/tile_gas_effect
	name = ""
	anchored = 1
	density = 0
	mouse_opacity = 0

	pooled(var/poolname)
		overlays.len = 0
		..()

	Move()
		return 0

/turf/unsimulated/meteorhit(obj/meteor as obj)
	return

/turf/unsimulated/ex_act(severity)
	return

/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "placeholder"
	fullbright = 1
#ifndef HALLOWEEN
	color = "#BBBBBB"
#endif
	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0
	throw_unlimited = 1
	plane = PLANE_SPACE
	special_volume_override = 0
	text = ""

	flags = ALWAYS_SOLID_FLUID
	turf_flags = CAN_BE_SPACE_SAMPLE
	event_handler_flags = IMMUNE_SINGULARITY

	dense
		icon_state = "dplaceholder"
		density = 1
		opacity = 1

	cavern // cavernous interior spaces
		icon_state = "cavern"
		name = "cavern"
		fullbright = 0

/turf/space/no_replace

/turf/space/New()
	..()
	//icon = 'icons/turf/space.dmi'
	if (icon_state == "placeholder") icon_state = "[rand(1,25)]"
	if (icon_state == "aplaceholder") icon_state = "a[rand(1,10)]"
	if (icon_state == "dplaceholder") icon_state = "[rand(1,25)]"
	if (icon_state == "d2placeholder") icon_state = "near_blank"
	if (blowout == 1) icon_state = "blowout[rand(1,5)]"
	if (derelict_mode == 1)
		icon = 'icons/turf/floors.dmi'
		icon_state = "darkvoid"
		name = "void"
		desc = "Yep, this is fine."
	if(buzztile == null && prob(1) && prob(1) && src.z == 1) //Dumb shit to trick nerds.
		buzztile = src
		icon_state = "wiggle"
		src.desc = "There appears to be a spatial disturbance in this area of space."
		new/obj/item/device/key/random(src)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// override for space turfs, since they should never hide anything
/turf/space/ReplaceWithSpace()
	return

/turf/space/proc/process_cell()
	return

/turf/cordon
	name = "CORDON"
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "cordonturf"
	fullbright = 1
	invisibility = 101
	explosion_resistance = 999999
	density = 1
	opacity = 1

	Enter()
		return 0 // nope

	proc/process_cell()
		return

/turf/New()
	..()
	if (density)
		pathable = 0
	for(var/atom/movable/AM as mob|obj in src)
		if (AM) // ???? x2
			src.Entered(AM)
	RL_Init()
	return

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover)
		return 1

	var/turf/cturf = get_turf(mover)
	if (cturf == src)
		return 1

	//First, check objects to block exit
	if (cturf?.checkingexit > 0) //dont bother checking unless the turf actually contains a checkable :)
		for(var/thing in cturf)
			var/obj/obstacle = thing
			if(obstacle == mover)
				continue
			if((mover != obstacle) && (forget != obstacle))
				if(obstacle.event_handler_flags & USE_CHECKEXIT)
					if(!obstacle.CheckExit(mover, src))
						mover.Bump(obstacle, 1)
						return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry
	if (src.checkingcanpass > 0)  //dont bother checking unless the turf actually contains a checkable :)
		for(var/thing in src)
			var/atom/movable/obstacle = thing
			if(obstacle == mover) continue
			if(!mover)	return 0
			if ((forget != obstacle))
				if(obstacle.event_handler_flags & USE_CANPASS)
					if(!obstacle.CanPass(mover, cturf, 1, 0))

						mover.Bump(obstacle, 1)
						return 0
				else //cheaper, skip proc call lol lol
					if (obstacle.density)

						mover.Bump(obstacle,1)
						return 0

	if (mirrored_physical_zone_created) //checking visual mirrors for blockers if set
		if (length(src.vis_contents))
			var/turf/T = locate(/turf) in src.vis_contents
			if (T)
				for(var/thing in T)

					var/atom/movable/obstacle = thing
					if(obstacle == mover) continue
					if(!mover)	return 0
					if ((forget != obstacle))
						if(obstacle.event_handler_flags & USE_CANPASS)
							if(!obstacle.CanPass(mover, cturf, 1, 0))

								mover.Bump(obstacle, 1)
								return 0
						else //cheaper, skip proc call lol lol
							if (obstacle.density)

								mover.Bump(obstacle,1)
								return 0

	return 1 //Nothing found to block so return success!

/turf/Exited(atom/movable/Obj, atom/newloc)
	var/i = 0

	//MBC : nothing in the game even uses PrxoimityLeave meaningfully. I'm disabling the proc call here.
	//for(var/atom/A as mob|obj|turf|area in range(1, src))
	if (src.checkinghasentered > 0)  //dont bother checking unless the turf actually contains a checkable :)
		for(var/thing in src)
			var/atom/A = thing
			if(A == Obj)
				continue
			// I Said No sanity check
			if(i >= 50)
				break
			i++
			if(A.loc == src && A.event_handler_flags & USE_HASENTERED)
				A.HasExited(Obj, newloc)
			//A.ProximityLeave(Obj)

	if (global_sims_mode)
		var/area/Ar = loc
		if (!Ar.skip_sims)
			if (isitem(Obj))
				if (!(locate(/obj/table) in src) && !(locate(/obj/rack) in src))
					Ar.sims_score = min(Ar.sims_score + 4, 100)


	return ..(Obj, newloc)

/turf/Entered(atom/movable/M as mob|obj, atom/OldLoc)
	if(ismob(M) && !src.throw_unlimited && !M.no_gravity)
		var/mob/tmob = M
		tmob.inertia_dir = 0
	///////////////////////////////////////////////////////////////////////////////////
	..()
	return_if_overlay_or_effect(M)
	src.material?.triggerOnEntered(src, M)

	if (global_sims_mode)
		var/area/Ar = loc
		if (!Ar.skip_sims)
			if (isitem(M))
				if (!(locate(/obj/table) in src) && !(locate(/obj/rack) in src))
					Ar.sims_score = max(Ar.sims_score - 4, 0)

	var/i = 0
	if (src.checkinghasentered > 0)  //dont bother checking unless the turf actually contains a checkable :)
		for(var/thing in src)
			var/atom/A = thing
			if(A == M)
				continue
			// I Said No sanity check
			if(i++ >= 50)
				break

			if (A.event_handler_flags & USE_HASENTERED)
				A.HasEntered(M, OldLoc)
			if(A.material)
				A.material.triggerOnEntered(A, M)
	i = 0
	for (var/turf/T in range(1,src))
		if (T.checkinghasproximity > 0)
			for(var/thing in T)
				var/atom/A = thing
				// I Said No sanity check
				if(i++ >= 50)
					break
				if (A.event_handler_flags & USE_PROXIMITY)
					A.HasProximity(M, 1) //IMPORTANT MBCNOTE : ADD USE_PROXIMITY FLAG TO ANY ATOM USING HASPROX THX BB

	if(!src.throw_unlimited && M?.no_gravity)
		BeginSpacePush(M)

#ifdef NON_EUCLIDEAN
	if(warptarget)
		if(OldLoc)
			switch (warptarget_modifier)
				if(LANDMARK_VM_WARP_NON_ADMINS) //warp away nonadmin
					if (ismob(M))
						var/mob/mob = M
						if (!mob.client?.holder && mob.last_client)
							M.set_loc(warptarget)
						if (rank_to_level(mob.client.holder.rank) < LEVEL_SA)
							M.set_loc(warptarget)
				else
					M.set_loc(warptarget)
#endif

// Ported from unstable r355
/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	if ((!(A) || istype(null, /obj/projectile)))
		return

	if (!(A.last_move))
		return

	//if(!(src in A.locs))
	//	return

//	if (locate(/obj/movable, src))
//		return 1

	//if (!istype(src,/turf/space/fluid))//ignore inertia if we're in the ocean
	if (src.throw_unlimited)//ignore inertia if we're in the ocean (faster but kind of dumb check)
		if ((ismob(A) && src.x > 2 && src.x < (world.maxx - 1))) //fuck?
			var/mob/M = A
			if( M.client && M.client.flying )
				return//aaaaa
			BeginSpacePush(M)

	if (src.x <= 1)
		edge_step(A, world.maxx- 2, 0)
	else if (A.x >= (world.maxx - 1))
		edge_step(A, 3, 0)
	else if (src.y <= 1)
		edge_step(A, 0, world.maxy - 2)
	else if (A.y >= (world.maxy - 1))
		edge_step(A, 0, 3)

/turf/hitby(atom/movable/AM, datum/thrown_thing/thr)
	. = ..()
	if(src.density)
		if(AM.throwforce >= 80)
			src.meteorhit(AM)
		. = 'sound/impact_sounds/Generic_Stab_1.ogg'

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

/turf/unsimulated/ReplaceWith(var/what, var/keep_old_material = 1, var/handle_air = 1, handle_dir = 1, force = 0)
	if (can_replace_with_stuff || force)
		return ..(what, keep_old_material = keep_old_material, handle_air = handle_air)
	return

/turf/proc/ReplaceWith(var/what, var/keep_old_material = 1, var/handle_air = 1, handle_dir = 1, force = 0)
	var/turf/simulated/new_turf
	var/old_dir = dir

	var/oldmat = src.material

	var/datum/gas_mixture/oldair = null //Set if old turf is simulated and has air on it.
	var/datum/air_group/oldparent = null //Ditto.

	//For unsimulated static air tiles such as ice moon surface.
	var/temp_old = null
	#define _OLD_GAS_VAR_DEF(GAS, ...) var/GAS ## _old = null;
	APPLY_TO_GASES(_OLD_GAS_VAR_DEF)

	if (handle_air)
		if (istype(src, /turf/simulated)) //Setting oldair & oldparent if simulated.
			var/turf/simulated/S = src
			oldair = S.air
			oldparent = S.parent

		else if (istype(src, /turf/unsimulated)) //Apparently unsimulated turfs can have static air as well!
			#define _OLD_GAS_VAR_ASSIGN(GAS, ...) GAS ## _old = src.GAS;
			APPLY_TO_GASES(_OLD_GAS_VAR_ASSIGN)
			temp_old = src.temperature
			#undef _OLD_GAS_VAR_ASSIGN

	#undef _OLD_GAS_VAR_DEF

	if (istype(src, /turf/simulated/floor))
		icon_old = icon_state // a hack but OH WELL, leagues better than before
		name_old = name

	/*
	if (!src.fullbright)
		var/area/old_loc = src.loc
		if(old_loc)
			old_loc.contents -= src.loc
	*/
	if (map_currently_underwater && what == "Space")
		what = "Ocean"

	var/rlapplygen = RL_ApplyGeneration
	var/rlupdategen = RL_UpdateGeneration
	var/rlmuloverlay = RL_MulOverlay
	var/rladdoverlay = RL_AddOverlay
	var/rllumr = RL_LumR
	var/rllumg = RL_LumG
	var/rllumb = RL_LumB
	var/rladdlumr = RL_AddLumR
	var/rladdlumg = RL_AddLumG
	var/rladdlumb = RL_AddLumB
	var/rlneedsadditive = RL_NeedsAdditive
	//var/rloverlaystate = RL_OverlayState  //we actually want these cleared
	var/list/rllights = RL_Lights

	var/old_opacity = src.opacity

	var/old_checkingexit = src.checkingexit
	var/old_checkingcanpass = src.checkingcanpass
	var/old_checkinghasentered = src.checkinghasentered
	var/old_checkinghasproximity = src.checkinghasproximity

	var/new_type = ispath(what) ? what : text2path(what) //what what, what WHAT WHAT WHAAAAAAAAT
	if (new_type)
		new_turf = new new_type(src)
		if (!isturf(new_turf))
			new_turf = new /turf/space(src)

	else switch(what)
		if ("Ocean")
			new_turf = new /turf/space/fluid(src)
		if ("Floor")
			new_turf = new /turf/simulated/floor(src)
		if ("MetalFoam")
			new_turf = new /turf/simulated/floor/metalfoam(src)
		if ("EngineFloor")
			new_turf = new /turf/simulated/floor/engine(src)
		if ("Circuit")
			new_turf = new /turf/simulated/floor/circuit(src)
		if ("RWall")
			if (map_settings)
				new_turf = new map_settings.rwalls (src)
			else
				new_turf = new /turf/simulated/wall/r_wall(src)
		if("Concrete")
			new_turf = new /turf/simulated/floor/concrete(src)
		if ("Wall")
			if (map_settings)
				new_turf = new map_settings.walls (src)
			else
				new_turf = new /turf/simulated/wall(src)
		else
			new_turf = new /turf/space(src)

	if(keep_old_material && oldmat && !istype(new_turf, /turf/space)) new_turf.setMaterial(oldmat)

	new_turf.icon_old = icon_old //TODO: Change it so original turf path is remembered, for turfening floors
	new_turf.name_old = name_old

	if (handle_dir)
		new_turf.set_dir(old_dir)

	new_turf.levelupdate()

	new_turf.RL_ApplyGeneration = rlapplygen
	new_turf.RL_UpdateGeneration = rlupdategen
	new_turf.RL_MulOverlay = rlmuloverlay
	new_turf.RL_AddOverlay = rladdoverlay

	new_turf.RL_LumR = rllumr
	new_turf.RL_LumG = rllumg
	new_turf.RL_LumB = rllumb
	new_turf.RL_AddLumR = rladdlumr
	new_turf.RL_AddLumG = rladdlumg
	new_turf.RL_AddLumB = rladdlumb
	new_turf.RL_NeedsAdditive = rlneedsadditive
	//new_turf.RL_OverlayState = rloverlaystate //we actually want these cleared
	new_turf.RL_Lights = rllights
	new_turf.opaque_atom_count = opaque_atom_count
	new_turf.N = N
	new_turf.S = S
	new_turf.W = W
	new_turf.E = E
	new_turf.NE = NE


	new_turf.checkingexit = old_checkingexit
	new_turf.checkingcanpass = old_checkingcanpass
	new_turf.checkinghasentered = old_checkinghasentered
	new_turf.checkinghasproximity = old_checkinghasproximity

	//cleanup old overlay to prevent some Stuff
	//This might not be necessary, i think its just the wall overlays that could be manually cleared here.
	new_turf.RL_Cleanup() //Cleans up/mostly removes the lighting.
	new_turf.RL_Init()
	if (RL_Started) RL_UPDATE_LIGHT(new_turf) //Then applies the proper lighting.

	//The following is required for when turfs change opacity during replace. Otherwise nearby lights will not be applying to the correct set of tiles.
	//example of failure : fire destorying a wall, the fire goes away, the area BEHIND the wall that used to be blocked gets strip()ped and now it leaves a blue glow (negative fire color)
	if (new_turf.opacity != old_opacity)
		new_turf.opacity = old_opacity
		new_turf.RL_SetOpacity(!new_turf.opacity)


	if (handle_air)
		if (istype(new_turf, /turf/simulated)) //Anything -> Simulated tile
			var/turf/simulated/N = new_turf
			if (oldair) //Simulated tile -> Simulated tile
				N.air = oldair
			else if(istype(N.air)) //Unsimulated tile (likely space) - > Simulated tile  // fix runtime: Cannot execute null.zero()
				N.air.zero()

			#define _OLD_GAS_VAR_NOT_NULL(GAS, ...) GAS ## _old ||
			if (N.air && (APPLY_TO_GASES(_OLD_GAS_VAR_NOT_NULL) 0)) //Unsimulated tile w/ static atmos -> simulated floor handling
				#define _OLD_GAS_VAR_RESTORE(GAS, ...) N.air.GAS += GAS ## _old;

				APPLY_TO_GASES(_OLD_GAS_VAR_RESTORE)
				if (!N.air.temperature)
					N.air.temperature = temp_old

				#undef _OLD_GAS_VAR_RESTORE
			#undef _OLD_GAS_VAR_NOT_NULL

			// tell atmos to update this tile's air settings
			if (air_master)
				air_master.tiles_to_update |= N

		if (air_master && oldparent) //Handling air parent changes for oldparent for Simulated -> Anything
			air_master.groups_to_rebuild |= oldparent //Puts the oldparent into a queue to update the members.

	if (istype(new_turf, /turf/simulated))
		// tells the atmos system "hey this tile changed, maybe rebuild the group / borders"
		new_turf.update_nearby_tiles(1)

	return new_turf


/turf/proc/ReplaceWithFloor()
	var/turf/simulated/floor = ReplaceWith("Floor")
	if (icon_old)
		floor.icon_state = icon_old
	if (name_old)
		floor.name = name_old
	for (var/obj/lattice/L in src.contents)
		qdel(L)

	if (map_settings)
		if (map_settings.auto_walls)
			for (var/turf/simulated/wall/auto/W in orange(1))
				W.update_icon()
		if (map_settings.auto_windows)
			for (var/obj/window/auto/W in orange(1))
				W.update_icon()
	return floor

/turf/proc/ReplaceWithMetalFoam(var/mtype)
	var/turf/simulated/floor/metalfoam/floor = ReplaceWith("MetalFoam")
	if(icon_old)
		floor.icon_state = icon_old
	if(name_old)
		floor.name_old = name_old

	for (var/obj/lattice/L in src.contents)
		qdel(L)

	floor.metal = mtype
	floor.update_icon()

	return floor

/turf/proc/ReplaceWithEngineFloor()
	var/turf/simulated/floor = ReplaceWith("EngineFloor")
	if(icon_old)
		floor.icon_state = icon_old
	for (var/obj/lattice/L in src.contents)
		qdel(L)
	return floor

/turf/proc/ReplaceWithCircuit()
	var/turf/simulated/floor = ReplaceWith("Circuit")
	if(icon_old)
		floor.icon_state = icon_old
	for (var/obj/lattice/L in src.contents)
		qdel(L)
	return floor

/turf/proc/ReplaceWithSpace()
	if( air_master.is_busy )
		air_master.tiles_to_space |= src
		return

	var/area/my_area = loc
	var/turf/floor
	if (my_area)
		if (my_area.filler_turf)
			floor = ReplaceWith(my_area.filler_turf)
		else
			floor = ReplaceWith("Space")
	else
		floor = ReplaceWith("Space")

	return floor

/turf/proc/ReplaceWithConcreteFloor()
	var/turf/simulated/floor = ReplaceWith("Concrete")
	if(icon_old)
		floor.icon_state = icon_old
	return floor

//This is for admin replacements (deletions) ONLY. I swear to god if any actual in-game code uses this I will be pissed - Wire
/turf/proc/ReplaceWithSpaceForce()
	var/area/my_area = loc
	var/turf/floor
	if (my_area)
		if (my_area.filler_turf)
			floor = ReplaceWith(my_area.filler_turf, force=1)
		else
			floor = ReplaceWith("Space", force=1)
	else
		floor = ReplaceWith("Space", force=1)

	return floor

/turf/proc/ReplaceWithLattice()
	new /obj/lattice(src)
	return ReplaceWithSpace()

/turf/proc/ReplaceWithWall()
	var/wall = ReplaceWith("Wall")
	if (map_settings)
		if (map_settings.auto_walls)
			for (var/turf/simulated/wall/auto/W in orange(1))
				W.update_icon()
		if (map_settings.auto_windows)
			for (var/obj/window/auto/W in orange(1))
				W.update_icon()
	return wall

/turf/proc/ReplaceWithRWall()
	var/wall = ReplaceWith("RWall")
	if (map_settings)
		if (map_settings.auto_walls)
			for (var/turf/simulated/wall/auto/W in orange(1))
				W.update_icon()
		if (map_settings.auto_windows)
			for (var/obj/window/auto/W in orange(1))
				W.update_icon()
	return wall

///turf/simulated/floor/Entered(atom/movable/A, atom/OL) //this used to run on every simulated turf (yes walls too!) -zewaka
//	..()
//moved step and slip functions into Carbon and Human files!

/turf/simulated
	name = "station"
	allows_vehicles = 0
	stops_space_move = 1
	var/mutable_appearance/wet_overlay = null
	var/default_melt_cap = 30
	can_write_on = 1
	mat_appearances_to_ignore = list("steel")
	text = "<font color=#aaa>."

	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

	turf_flags = IS_TYPE_SIMULATED

	attackby(var/obj/item/W, var/mob/user, params)
		if (istype(W, /obj/item/pen))
			var/obj/item/pen/P = W
			P.write_on_turf(src, user, params)
			return
		else
			//if turf has kudzu, transfer attack from turf to kudzu
			if (src.temp_flags & HAS_KUDZU)
				var/obj/spacevine/K = locate(/obj/spacevine) in src.contents
				if (K)
					K.attackby(W, user, params)
			return ..()

/turf/simulated/aprilfools/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/simulated/aprilfools/dirt
	name = "dirt"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"

/turf/simulated/aprilfools/brick_wall
	name = "brick wall"
	icon = 'icons/misc/aprilfools.dmi'
	icon_state = "brick_wall"
	opacity = 1
	density = 1
	pathable = 0
	var/d_state = 0

/turf/simulated/aprilfools/floor/concrete_floor
	name = "concrete floor"
	icon = 'icons/misc/aprilfools.dmi'
	icon_state = "concrete"

/turf/unsimulated/aprilfools/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"
	opacity = 0
	density = 0

/turf/unsimulated/aprilfools/dirt
	name = "dirt"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"
	opacity = 0
	density = 0

/turf/simulated/bar
	name = "bar"
	icon = 'icons/turf/floors.dmi'
	icon_state = "bar"

/turf/simulated/grimycarpet
	name = "grimy carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy"

/turf/unsimulated/grimycarpet
	name = "grimy carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy"

/turf/simulated/grass
	name = "grass"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "grass"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/unsimulated
	name = "command"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	fullbright = 0 // cogwerks changed as a lazy fix for newmap- if this causes problems change back to 1
	stops_space_move = 1
	text = "<font color=#aaa>."

/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"
	text = "<font color=#aaa>."
	plane = PLANE_FLOOR

/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	text = "<font color=#aaa>#"
	density = 1
	pathable = 0
	turf_flags = ALWAYS_SOLID_FLUID
#ifndef IN_MAP_EDITOR // display disposal pipes etc. above walls in map editors
	plane = PLANE_WALL
#else
	plane = PLANE_FLOOR
#endif

/turf/unsimulated/wall/solidcolor
	name = "invisible solid turf"
	desc = "A solid... nothing? Is that even a thing?"
	icon = 'icons/turf/walls.dmi'
	icon_state = "white"
	plane = PLANE_LIGHTING + 1
	mouse_opacity = 0
	fullbright = 1

/turf/unsimulated/wall/solidcolor/white
	icon_state = "white"

/turf/unsimulated/wall/solidcolor/black
	icon_state = "black"

/turf/unsimulated/wall/titlecard
	appearance_flags = TILE_BOUND
	fullbright = 1
	icon = 'icons/misc/widescreen.dmi' //fullscreen.dmi
	icon_state = "title_main"
	layer = 60
	name = "Space Station 13"
	desc = "The title card for it, at least."
	plane = PLANE_OVERLAY_EFFECTS
	pixel_x = -96

	New()
		..()
	// ifdef doesn't have an elifdef (or if it does it isn't listed) so... these are functionally equivalent
	#if defined(MAP_OVERRIDE_OSHAN)
		icon_state = "title_oshan"
		name = "Oshan Laboratory"
		desc = "An underwater laboratory on the planet Abzu."
	#elif defined(MAP_OVERRIDE_MANTA)
		icon_state = "title_manta"
		name = "The NSS Manta"
		desc = "Some fancy comic about the NSS Manta and its travels on the planet Abzu."
	#endif
	#if defined(REVERSED_MAP)
		transform = list(-1, 0, 0, 0, 1, 0)
	#endif
		lobby_titlecard = src

		if (!player_capa)
			encourage()

	proc/encourage()
		var/obj/overlay/clickable = new/obj/overlay(src)

		// This is gross. I'm sorry.
		var/list/servers = list()
		servers["main"]		= {"<a style='color: #88f;' href='byond://winset?command=Change-Server "main'>Goonstation</a>"}
		servers["main3"]	= {"<a style='color: #88f;' href='byond://winset?command=Change-Server "main3'>Goonstation Overflow</a>"}
		servers["rp"]		= {"<a style='color: #88f;' href='byond://winset?command=Change-Server "rp'>Goonstation Roleplay</a>"}
		servers["main2"]	= {"<a style='color: #88f;' href='byond://winset?command=Change-Server "main2'>Goonstation Roleplay Overflow</a></span>"}

		var/serverList = ""
		for (var/serverId in servers)
			if (serverId == config.server_id)
				continue
			serverList += "\n[servers[serverId]]"

		clickable.maptext = {"<span class='ol vga'>
Welcome to Goonstation!
New? <a style='color: #88f;' href="https://mini.xkeeper.net/ss13/tutorial/">Check the tutorial</a>!
Have questions? Ask mentors with \[F3]!
Need an admin? Message us with \[F1].

Other Goonstation servers:[serverList]"}
		clickable.maptext_width = 600
		clickable.maptext_height = 400
		clickable.plane = 100
		clickable.layer = src.layer + 1
		clickable.x -= 3


	proc/educate()
		maptext = "<span class='ol c ps2p'>Hello! Press F3 to ask for help. You can change game settings using the file menu on the top left, and see our wiki + maps by clicking the buttons on the top right.</span>"
		maptext_width = 300
		maptext_height = 300

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/unsimulated/bombvr
	name = "Virtual Floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "vrfloor"

/turf/unsimulated/floor/carpet
	name = "carpet"
	icon = 'icons/turf/carpet.dmi'
	icon_state = "red1"

/turf/unsimulated/wall/bombvr
	name = "Virtual Wall"
	icon = 'icons/turf/floors.dmi'
	icon_state = "vrwall"

/turf/unsimulated/attack_hand(var/mob/user as mob)
	if (src.density == 1)
		return
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (isobj(user.pulling.loc))
		var/obj/container = user.pulling.loc
		if (user.pulling in container.contents)
			return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(M, get_dir(fuck_u, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(fuck_u, src))
	return

// imported from space.dm

/turf/space/attack_hand(mob/user as mob)
	if ((user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (isobj(user.pulling.loc))
		var/obj/container = user.pulling.loc
		if (user.pulling in container.contents)
			return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/t = M.pulling
		M.pulling = null
		step(M, get_dir(fuck_u, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(fuck_u, src))
	return

/turf/space/attackby(obj/item/C as obj, mob/user as mob)
	var/area/A = get_area (user)
	if (istype(A, /area/supply/spawn_point || /area/supply/delivery_point || /area/supply/sell_point))
		boutput(usr, "<span class='alert'>You can't build here.</span>")
		return
	if (istype(C, /obj/item/rods))
		boutput(user, "<span class='notice'>Constructing support lattice ...</span>")
		playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
		ReplaceWithLattice()
		if(C.material) src.setMaterial(C.material)
		C:amount--

		if (C:amount < 1)
			user.u_equip(C)
			qdel(C)
			return
		return

	if (istype(C, /obj/item/tile))
		//var/obj/lattice/L = locate(/obj/lattice, src)
		var/obj/item/tile/T = C
		if (T.amount >= 1)
			for(var/obj/lattice/L in src)
				qdel(L)
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
			T.build(src)
			if(T.material) src.setMaterial(T.material)

		if (T.amount < 1 && !issilicon(user))
			user.u_equip(T)
			qdel(T)
			return
		return
	return

/turf/proc/edge_step(var/atom/movable/A, var/newx, var/newy)
	var/zlevel = 3 //((A.z=3)?5:3)//(3,4)

	if(A.z == 3) zlevel = 5
	else zlevel = 3

	if (world.maxz < zlevel) // if there's less levels than the one we want to go to
		zlevel = 1 // just boot people back to z1 so the server doesn't lag to fucking death trying to place people on maps that don't exist
	if (istype(A, /obj/machinery/vehicle))
		var/obj/machinery/vehicle/V = A
		if (V.going_home)
			zlevel = 1
			V.going_home = 0
	if (istype(A, /obj/newmeteor))
		qdel(A)
		return

	if (A.z == 1 && zlevel != A.z)
		if (!(isitem(A) && A:w_class <= 2))
			for_by_tcl(C, /obj/machinery/communications_dish)
				C.add_cargo_logs(A)

	A.z = zlevel
	if (newx)
		A.x = newx
	if (newy)
		A.y = newy
	SPAWN_DBG(0)
		if ((A?.loc))
			A.loc.Entered(A)

//Vr turf is a jerk and pretends to be broken.
/turf/unsimulated/bombvr/ex_act(severity)
	switch(severity)
		if(1.0)
			src.icon_state = "vrspace"
		if(2.0)
			switch(pick(1;75,2))
				if(1)
					src.icon_state = "vrspace"
				if(2)
					if(prob(80))
						src.icon_state = "vrplating"

		if(3.0)
			if (prob(50))
				src.icon_state = "vrplating"
	return

/turf/unsimulated/wall/bombvr/ex_act(severity)
	switch(severity)
		if(1.0)
			opacity = 0
			set_density(0)
			src.icon_state = "vrspace"
		if(2.0)
			switch(pick(1;75,2))
				if(1)
					opacity = 0
					set_density(0)
					src.icon_state = "vrspace"
				if(2)
					if(prob(80))
						opacity = 0
						set_density(0)
						src.icon_state = "vrplating"

		if(3.0)
			if (prob(50))
				src.icon_state = "vrwallbroken"
				opacity = 0
	return



////////////////////////////////////////////////

//stuff ripped out of keelinsstuff.dm
/turf/unsimulated/floor/pool
	name = "water"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

/turf/unsimulated/pool/no_animate
	name = "pool floor"
	icon = 'icons/obj/fluid.dmi'
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))
/turf/simulated/pool
	name = "water"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

/turf/simulated/pool/no_animate
	name = "pool floor"
	icon = 'icons/obj/fluid.dmi'
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

/turf/unsimulated/grasstodirt
	name = "grass"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "grasstodirt"

/turf/unsimulated/grass
	name = "grass"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "grass"

/turf/unsimulated/dirt
	name = "Dirt"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "dirt"

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/shovel))
			if (src.icon_state == "dirt-dug")
				boutput(user, "<span class='alert'>That is already dug up! Are you trying to dig through to China or something?  That would be even harder than usual, seeing as you are in space.</span>")
				return

			user.visible_message("<b>[user]</b> begins to dig!", "You begin to dig!")
			//todo: A digging sound effect.
			if (do_after(user, 4 SECONDS) && src.icon_state != "dirt-dug")
				src.icon_state = "dirt-dug"
				user.visible_message("<b>[user]</b> finishes digging.", "You finish digging.")
				for (var/obj/tombstone/grave in orange(src, 1))
					if (istype(grave) && !grave.robbed)
						grave.robbed = 1
						//idea: grave robber medal.
						if (grave.special)
							new grave.special (src)
						else
							switch (rand(1,5))
								if (1)
									new /obj/item/skull {desc = "A skull.  That was robbed.  From a grave.";} ( src )
								if (2)
									new /obj/item/plank {name = "rotted coffin wood"; desc = "Just your normal, everyday rotten wood.  That was robbed.  From a grave.";} ( src )
								if (3)
									new /obj/item/clothing/under/suit/pinstripe {name = "old pinstripe suit"; desc  = "A pinstripe suit.  That was stolen.  Off of a buried corpse.";} ( src )
						break

		else
			return ..()

/turf/unsimulated/nicegrass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"

/turf/unsimulated/nicegrass/random
	New()
		..()
		src.set_dir(pick(cardinal))

/turf/unsimulated/floor/ballpit
	name = "ball pit"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "ballpitfloor"

/turf/simulated/floor/concrete
	name = "concrete floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"
