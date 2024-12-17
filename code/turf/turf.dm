/turf
	icon = 'icons/turf/floors.dmi'
	plane = PLANE_FLOOR //See _plane.dm, required for shadow effect
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	var/intact = TRUE
	var/allows_vehicles = TRUE

	/// Gang wars thing
	var/tagged = 0

	level = 1

	// Properties for open tiles (/floor)
	#define _UNSIM_TURF_GAS_DEF(GAS, ...) var/GAS = 0;
	APPLY_TO_GASES(_UNSIM_TURF_GAS_DEF)
	#undef _UNSIM_TURF_GAS_DEF

	// Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1
	/// Sum of all unstable atoms on the turf.
	pass_unstable = TRUE
	/// Whether this turf is passable. Used in the pathfinding system.
	var/tmp/passability_cache

	// Properties for both simmed and unsimmed
	var/temperature = T20C
	var/icon_old = null
	var/name_old = null
	var/path_old = null
	var/tmp/pathweight = 1
	var/tmp/pathable = TRUE
	var/can_write_on = FALSE
	///value corresponds to how many cleanables exist on this turf. Exists for the purpose of making fluid spreads do less checks.
	var/tmp/messy = 0
	/// directions of this turf being blocked by directional blocking objects. So we don't need to loop through the entire contents
	var/tmp/blocked_dirs = 0
	/// this turf is allowing unrestricted hotbox reactions
	var/tmp/allow_unrestricted_hotbox = FALSE
	/// an associative list of gangs to gang claims, representing who has a claim to, or other ownership on this tile
	var/list/datum/gangtileclaim/controlling_gangs
	var/wet = 0
	throw_unlimited = FALSE //throws cannot stop on this tile if true (also makes space drift)

	var/step_material = 0
	var/step_priority = 0 //compare vs. shoe for step sounds

	/// Whether this turf is currently being evaluated for changing hands from the "unconnected zone" area (constructed) to a "real" area
	var/tmp/transfer_evaluation = FALSE

	// Vars used for breaking and burning turfs, only used for floors at the moment
	var/can_burn = FALSE
	var/can_break = FALSE
	var/broken = FALSE
	var/burnt = FALSE

	var/can_build = FALSE

	var/special_volume_override = -1 //if greater than or equal to 0, override

	var/turf_flags = 0
	var/list/list/datum/disjoint_turf/connections

	var/tmp/image/disposal_image = null // 'ghost' image of disposal pipes originally at these coords, visible with a T-ray scanner.
	flags = OPENCONTAINER


	New()
		..()
		src.path_old = src.type
		if(global.dont_init_space)
			return
		src.init_lighting()

	disposing() // DOES NOT GET CALLED ON TURFS!!!
		SHOULD_NOT_OVERRIDE(TRUE)
		SHOULD_CALL_PARENT(FALSE)

	set_opacity(newopacity)
		. = ..()
		on_set_opacity()

	proc/contents_set_opacity_smart(oldopacity, atom/movable/thing)
		on_set_opacity()
		SEND_SIGNAL(src, COMSIG_TURF_CONTENTS_SET_OPACITY_SMART, oldopacity, thing)

	onMaterialChanged()
		..()
		if(istype(src.material))
			if(initial(src.opacity))
				src.set_opacity(src.material.getAlpha() <= MATERIAL_ALPHA_OPACITY ? 0 : 1)
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
		set_opacity(opacity)
		F["[path].pixel_x"] >> pixel_x
		F["[path].pixel_y"] >> pixel_y
		return DESERIALIZE_OK

	proc/can_crossed_by(atom/movable/AM)
		if(!src.Cross(AM))
			return 0
		for(var/atom/A in contents)
			if(!A.Cross(AM))
				return 0
		return 1

	proc/tilenotify(turf/notifier)

	proc/selftilenotify()

	/// Gets called after the world is finished loading and the game is basically ready to start
	proc/generate_worldgen()

	proc/burn_down()

	proc/inherit_area() //jerko built a thing
		if(!loc:expandable) return
		unconnected_zone.contents += src
		unconnected_zone.propagate_zone(src)

	proc/break_tile(var/force)
		if (!src.can_break && !force)
			return
		if (src.broken)
			return
		var/image/damage_overlay
		if (intact)
			damage_overlay = image('icons/turf/floors.dmi', "damaged[pick(1,2,3,4,5)]")
		else
			damage_overlay = image('icons/turf/floors.dmi', "platingdmg[pick(1,2,3)]")
		damage_overlay.alpha = 200
		src.broken = TRUE
		AddOverlays(damage_overlay, "damage")

	proc/burn_tile(var/force)
		if (!src.can_burn && !force)
			return
		if (src.burnt)
			return
		var/image/burn_overlay
		if (intact)
			burn_overlay = image('icons/turf/floors.dmi', "floorscorched[pick(1,2)]")
		else
			burn_overlay = image('icons/turf/floors.dmi', "panelscorched")
		burn_overlay.alpha = 200
		src.burnt = TRUE
		AddOverlays(burn_overlay, "burn")

	proc/restore_tile()
		if(intact)
			return
		setIntact(TRUE)
		src.broken = FALSE
		src.burnt = FALSE
		icon = initial(icon)
		if(icon_old)
			icon_state = icon_old
		else
			icon_state = "floor"
		ClearSpecificOverlays("burn", "damage")
		if (name_old)
			name = name_old
		levelupdate()

	proc/setIntact(var/new_intact_value)
		if (new_intact_value)
			src.intact = TRUE
			src.layer = TURF_LAYER
		else
			src.intact = FALSE
			src.layer = PLATING_LAYER

	proc/UpdateDirBlocks()
		src.blocked_dirs = 0
		for (var/obj/O in src.contents)
			if(!O.density)
				continue
			if (istype(O, /obj/window) && !is_cardinal(O.dir)) // full window
				src.blocked_dirs = NORTH | SOUTH | EAST | WEST
				return
			if (HAS_FLAG(O.object_flags, HAS_DIRECTIONAL_BLOCKING))
				ADD_FLAG(src.blocked_dirs, O.dir)

	proc/on_set_opacity(turf/thisTurf, old_opacity)
		if (length(src.camera_coverage_emitters))
			camera_coverage_controller?.update_emitters(src.camera_coverage_emitters)

	proc/MakeCatwalk(var/obj/item/rods/rods)
		if (rods)
			rods.change_stack_amount(-1)

		var/obj/mesh/catwalk/catwalk = new
		catwalk.setMaterial(rods?.material)
		catwalk.set_loc(src)

	///A very loose approximation of "is there some light shining on this thing", taking into account all lighting systems and byond internal crap
	///Performance warning since simple light checks are NOT CHEAP
	proc/is_lit(RL_threshold = 0.3)
		if (src.fullbright || src.RL_GetBrightness() > RL_threshold)
			return TRUE

		var/area/area = get_area(src)
		if (area.force_fullbright)
			return TRUE

		for (var/dir in cardinal) //check for neighbouring starlit turfs
			var/turf/T = get_step(src, dir)
			if (istype(T, /turf/space))
				var/turf/space/space_turf = T
				if (length(space_turf.underlays))
					return TRUE

		if (src.SL_lit())
			return TRUE
		return FALSE

/obj/overlay/tile_effect
	name = ""
	anchored = ANCHORED
	density = 0
	mouse_opacity = 0
	alpha = 255
	layer = TILE_EFFECT_OVERLAY_LAYER
	animate_movement = NO_STEPS // fix for things gliding around all weird

	Move()
		SHOULD_CALL_PARENT(FALSE)
		return FALSE

/obj/overlay/tile_gas_effect
	name = ""
	anchored = ANCHORED
	density = 0
	mouse_opacity = 0

	Move()
		SHOULD_CALL_PARENT(FALSE)
		return FALSE

/turf/unsimulated
	pass_unstable = FALSE
	event_handler_flags = IMMUNE_SINGULARITY
	/// If ReplaceWith() actually does a thing or not.
	var/can_replace_with_stuff = FALSE
#ifdef CI_RUNTIME_CHECKING
	can_replace_with_stuff = TRUE  //Shitty dumb hack bullshit (/proc/placeAllPrefabs)
#endif
	allows_vehicles = FALSE

/turf/unsimulated/meteorhit(obj/meteor as obj)
	return

/turf/unsimulated/ex_act(severity)
	return

/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "placeholder"
	pass_unstable = FALSE
	fullbright = TRUE
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
	var/static/list/space_color = generate_space_color()
	var/static/image/starlight

	flags = FLUID_DENSE
	turf_flags = CAN_BE_SPACE_SAMPLE
	event_handler_flags = IMMUNE_SINGULARITY
	can_build = TRUE
	dense
		icon_state = "dplaceholder"
		density = 1
		opacity = 1

	cavern // cavernous interior spaces
		icon_state = "cavern"
		name = "cavern"
		fullbright = 0

	safe
		temperature = T20C
		oxygen = MOLES_O2STANDARD
		nitrogen = MOLES_N2STANDARD

	asteroid
		icon_state = "aplaceholder"

	plasma
		temperature = T20C
		toxins = ONE_ATMOSPHERE/3
		New()
			..()
			var/obj/overlay/tile_gas_effect/gas_icon_overlay = new
			gas_icon_overlay.icon = 'icons/effects/tile_effects.dmi'
			gas_icon_overlay.icon_state = "plasma-alpha"
			gas_icon_overlay.dir = pick(cardinal)
			gas_icon_overlay.alpha = 100
			gas_icon_overlay.set_loc(src)

/turf/space/no_replace

/turf/space/New()
	..()
	if(global.dont_init_space)
		return
	switch(icon_state)
		if ("placeholder", "dplaceholder")
			icon_state = "[(((x + y) ^ ~(x * y) + z) % 25)+1]" // rand(1,25)
		if ("aplaceholder")
			icon_state = "a[(((x + y) ^ ~(x * y) + z) % 10)+1]" // rand(1,10)

	if (derelict_mode == 1)
		icon = 'icons/turf/floors.dmi'
		icon_state = "darkvoid"
		name = "void"
		desc = "Yep, this is fine."

	#ifndef CI_RUNTIME_CHECKING
	if(buzztile == null && prob(0.01) && src.z == Z_LEVEL_STATION) //Dumb shit to trick nerds.
		buzztile = src
		icon_state = "wiggle"
		src.desc = "There appears to be a spatial disturbance in this area of space."
		new/obj/item/device/key/random(src)
	#endif

	// // forbidden zone // //
	update_icon() // HIGHLY ILLEGAL NEVER DO THIS, SPECIAL CASE IGNORE ME (for starlight)
	// // do not pass go // //

proc/repaint_space(regenerate=TRUE, starlight_alpha)
	for(var/turf/space/T)
		if(regenerate)
			T.space_color = generate_space_color()
			RECOLOUR_PARALLAX_RENDER_SOURCES_IN_GROUP(Z_LEVEL_STATION, T.space_color, 10 SECONDS)
			RECOLOUR_PARALLAX_RENDER_SOURCES_IN_GROUP(Z_LEVEL_DEBRIS, T.space_color, 10 SECONDS)
			RECOLOUR_PARALLAX_RENDER_SOURCES_IN_GROUP(Z_LEVEL_MINING, T.space_color, 10 SECONDS)
			regenerate = FALSE
		if(istype(T, /turf/space/fluid))
			continue
		T.UpdateIcon(starlight_alpha)

proc/generate_space_color()
#ifndef HALLOWEEN
	return "#898989"
#else
	var/bg = list(0, 0, 0)
	bg[1] += rand(0, 35)
	bg[3] += rand(0, 35)
	var/main_star = list(255, 255, 255)
	main_star = list(150 + rand(-40, 40), 100 + rand(-40, 40), 50 + rand(-40, 40))
	var/hsv_main = rgb2hsv(main_star[1], main_star[2], main_star[3])
	hsv_main[2] = 100
	main_star = hsv2rgblist(hsv_main[1], hsv_main[2], hsv_main[3])
	if(prob(5))
		main_star = list(230, 0, 0)
	var/misc_star_1 = main_star
	var/misc_star_2 = main_star
	if(prob(33))
		misc_star_2 = list(main_star[2], main_star[3], main_star[1])
		misc_star_1 = list(main_star[3], main_star[1], main_star[2])
	else if(prob(50))
		misc_star_1 = list(main_star[2], main_star[3], main_star[1])
		misc_star_2 = list(main_star[3], main_star[1], main_star[2])
	else
		misc_star_1 = list(150 + rand(-40, 40), 100 + rand(-40, 40), 50 + rand(-40, 40))
		misc_star_2 = list(150 + rand(-40, 40), 100 + rand(-40, 40), 50 + rand(-40, 40))
	if(prob(5))
		misc_star_1 = list(230, 0, 0)
	misc_star_1 = list(misc_star_1[1] + rand(-25, 25), misc_star_1[2] + rand(-25, 25), misc_star_1[3] + rand(-25, 25))
	misc_star_2 = list(misc_star_2[1] + rand(-25, 25), misc_star_2[2] + rand(-25, 25), misc_star_2[3] + rand(-25, 25))
	if(prob(5))
		misc_star_2 = list(230, 0, 0)
	if(prob(1.5))
		bg = list(200 - bg[1], 200 - bg[2], 200 - bg[3])
		if(prob(50))
			main_star = list(180 - main_star[1], 180 - main_star[2], 180 - main_star[3])
			misc_star_1 = list(255 - misc_star_1[1], 255 - misc_star_1[2], 255 - misc_star_1[3])
			misc_star_2 = list(255 - misc_star_2[1], 255 - misc_star_2[2], 255 - misc_star_2[3])
	if(prob(2))
		bg = list(120 + rand(-30, 30), rand(20, 50), rand(20, 50))
	return affine_color_mapping_matrix(
		list("#000000", "#ffffff", "#ff0000", "#0080FF"), // original misc_star_2 = "#64C5D2", but that causes issues for some frames
		list(bg, main_star, misc_star_1, misc_star_2)
	)
#endif

/turf/space/update_icon(starlight_alpha=255, starlight_color_override=null)
	..()
	if(!isnull(space_color) && !istype(src, /turf/space/fluid))
		src.color = space_color

	// underlays are chacked in CI for duplicate turfs on a dmm tile
	#ifndef CI_RUNTIME_CHECKING
	if(fullbright)
		if(!starlight)
			starlight = mutable_appearance('icons/effects/overlays/simplelight.dmi', "starlight")
			starlight.pixel_x = -32
			starlight.pixel_y = -32
			starlight.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | KEEP_APART // PIXEL_SCALE omitted intentionally
			starlight.layer = LIGHTING_LAYER_BASE
			starlight.plane = PLANE_LIGHTING
			starlight.blend_mode = BLEND_ADD

		if(!isnull(starlight_alpha))
			starlight.alpha = starlight_alpha
		starlight.color = starlight_color_override ? starlight_color_override : src.color

		if(length(src.underlays))
			src.underlays = list(starlight)
		else
			src.underlays += starlight
	else
		src.underlays = list()
	#endif

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == UNDERFLOOR)
			O.hide(0)

// override for space turfs, since they should never hide anything
/turf/space/ReplaceWithSpace()
	return

/turf/space/proc/process_cell()
	return

/turf/proc/delay_space_conversion()
	return

/turf/simulated/delay_space_conversion()
	if(air_master?.is_busy)
		air_master.tiles_to_space |= src
		return TRUE

/turf/cordon
	name = "CORDON"
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "cordonturf"
	fullbright = 1
	invisibility = INVIS_ALWAYS
	explosion_resistance = 999999
	density = 1
	opacity = 1
	gas_impermeable = 1
	allows_vehicles = FALSE

	Enter()
		return 0 // nope

	proc/process_cell()
		return

	meteorhit(obj/meteor)
		return

/turf/New()
	..()
	if (density)
		pathable = 0
	for(var/atom/movable/AM as mob|obj in src)
		src.Entered(AM)
	if(current_state < GAME_STATE_WORLD_NEW)
		RL_Init()
	#ifdef CHECK_MORE_RUNTIMES
	if(current_state > GAME_STATE_MAP_LOAD && in_replace_with == 0)
		stack_trace("turf [src] ([src.type]) created directly instead of using ReplaceWith")
	#endif

/turf/Exit(atom/movable/AM, atom/newloc)
	SHOULD_CALL_PARENT(TRUE)
	// per DM reference Exit gets called before Uncross so we use this temporary var to smuggle newloc there
	AM.movement_newloc = newloc
	. = ..()

/turf/Enter(atom/movable/mover, atom/forget)

	if (!mover)
		return TRUE

	var/turf/cturf = get_turf(mover)
	if (cturf == src)
		return TRUE

	if (mirrored_physical_zone_created) //checking visual mirrors for blockers if set
		if (length(src.vis_contents))
			var/turf/T = locate(/turf) in src.vis_contents
			if (T)
				for(var/thing in T)
					var/atom/movable/obstacle = thing
					if(obstacle == mover) continue
					if(!mover)	return FALSE
					if ((forget != obstacle))
						if(!obstacle.Cross(mover))
							mover.Bump(obstacle)
							return FALSE

	return ..() //Nothing found to block so return success!

/turf/Exited(atom/movable/Obj, atom/newloc)
	//MBC : nothing in the game even uses PrxoimityLeave meaningfully. I'm disabling the proc call here.

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

	if (global_sims_mode)
		var/area/Ar = loc
		if (!Ar.skip_sims)
			if (isitem(M))
				if (!(locate(/obj/table) in src) && !(locate(/obj/rack) in src))
					Ar.sims_score = max(Ar.sims_score - 4, 0)

	if(!src.throw_unlimited && M?.no_gravity)
		BeginSpacePush(M)

#ifdef NON_EUCLIDEAN
	if(warptarget)
	#ifdef MIDSUMMER
		var/mob/ms_mob = M
		if ((warptarget_modifier == LANDMARK_VM_ONLY_WITCHES) && (ms_mob.job != "Witch"))
			return
	#endif
		if (warptarget_modifier == LANDMARK_VM_WARP_NONE) return
		if(OldLoc)
			if(warptarget_modifier == LANDMARK_VM_WARP_NON_ADMINS) //warp away nonadmin
				if (ismob(M))
					var/mob/mob = M
					if (!mob.client?.holder && mob.last_client)
						M.set_loc(warptarget)
					if (rank_to_level(mob.client.holder.rank) < LEVEL_SA)
						M.set_loc(warptarget)
			else if (isturf(warptarget) && (abs(OldLoc.x - warptarget.x) > 1 || abs(OldLoc.y - warptarget.y) > 1))
				// double set_loc is a fix for the warptarget gliding bug
				M.set_loc(get_step(warptarget, get_dir(src, OldLoc)))
				SPAWN(0.001) // rounds to the nearest tick, about as smooth as it's gonna get
					M.set_loc(warptarget)
			else
				M.set_loc(warptarget)
#endif
	// https://www.byond.com/forum/post/2382205
	// Default behavior of turf/Entered() is to call Crossed() this will maintain that behavior
	Crossed(M)

// Ported from unstable r355
/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	if ((!(A) || istype(A, /obj/projectile)))
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
			if((M.client && M.client.flying) || (ismob(M) && HAS_ATOM_PROPERTY(M, PROP_MOB_NOCLIP)))
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
		if(AM.throwforce >= 80 && !isrestrictedz(src.z))
			src.meteorhit(AM)
		. = 'sound/impact_sounds/Generic_Stab_1.ogg'

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == UNDERFLOOR)
			O.hide(src.intact)

/turf/unsimulated/ReplaceWith(what, keep_old_material = 0, handle_air = 1, handle_dir = 0, force = 0)
	if (can_replace_with_stuff || force)
		return ..(what, keep_old_material = keep_old_material, handle_air = handle_air)
	return

#ifdef CHECK_MORE_RUNTIMES
var/global/in_replace_with = 0
#endif

/turf/proc/ReplaceWith(what, keep_old_material = 0, handle_air = 1, handle_dir = 0, force = 0)
	var/new_type = ispath(what) ? what : text2path(what)

	if(ispath(new_type, /turf/variableTurf))
		var/typeinfo/turf/variableTurf/typeinfo = get_type_typeinfo(new_type)
		typeinfo.place(src)
		// ReplaceWith is not reentrant with same coordidnates so we do this instead of /turf/variableTurf/New calling ReplaceWith
		return

	SEND_SIGNAL(src, COMSIG_TURF_REPLACED, what)

	#ifdef CHECK_MORE_RUNTIMES
	in_replace_with++
	#endif

	var/turf/simulated/new_turf
	var/old_dir = dir
	var/old_liquid = active_liquid // replacing stuff wasn't clearing liquids properly

	var/oldmat = src.material
	src.material?.UnregisterSignal(src, COMSIG_ATOM_CROSSED)

	var/datum/gas_mixture/oldair = null //Set if old turf is simulated and has air on it.
	var/datum/air_group/oldparent = null //Ditto.
	var/zero_new_turf_air = (turf_flags & CAN_BE_SPACE_SAMPLE)

	//For unsimulated static air tiles such as ice moon surface.
	var/temp_old = null
	#define _OLD_GAS_VAR_DEF(GAS, ...) var/GAS ## _old = null;
	APPLY_TO_GASES(_OLD_GAS_VAR_DEF)

	if (handle_air)
		if (istype(src, /turf/simulated)) //Setting oldair & oldparent if simulated.
			var/turf/simulated/S = src
			oldair = S.air
			S.air = null
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

	var/old_savedpath = src.path_old
	var/old_opacity = src.opacity
	var/old_opaque_atom_count = src.opaque_atom_count

	var/old_blocked_dirs = src.blocked_dirs

	var/old_aiimage = src.aiImage
	var/old_cameras = src.cameras
	var/old_camera_coverage_emitters = src.camera_coverage_emitters
	var/old_pass_unstable = src.pass_unstable

	var/image/old_disposal_image = src.disposal_image

#ifdef ATMOS_PROCESS_CELL_STATS_TRACKING
	var/old_process_cell_operations = src.process_cell_operations
#endif

	var/old_comp_lookup = src.comp_lookup

	if (new_type)
		if(ispath(new_type, /turf/space) && !ispath(new_type, /turf/space/fluid) && delay_space_conversion()) return
		new_turf = new new_type(src)
		if (!isturf(new_turf))
			if (delay_space_conversion())
				#ifdef CHECK_MORE_RUNTIMES
				in_replace_with--
				#endif
				return
			new_turf = new /turf/space(src)
		if(!istype(new_turf, new_type))
			#ifdef CHECK_MORE_RUNTIMES
			in_replace_with--
			#endif
			return new_turf
			// New() replaced the turf with something else, its ReplaceWith handled everything for us already (otherwise we'd screw up lighting)

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
		if ("Initial")
			var/oldpath = old_savedpath
			new_turf = new oldpath(src)
		if ("Unsimulated Floor")
			new_turf = new /turf/unsimulated/floor(src)
		else
			if (delay_space_conversion())
				#ifdef CHECK_MORE_RUNTIMES
				in_replace_with--
				#endif
				return
			if(station_repair.station_generator && src.z == Z_LEVEL_STATION)
				station_repair.repair_turfs(list(src), clear=TRUE)
				keep_old_material = FALSE
				new_turf = src
			else if(PLANET_LOCATIONS.repair_planet(src))
				keep_old_material = FALSE
				new_turf = src
			else
				new_turf = new /turf/space(src)

	for (var/obj/ladder/embed/L in orange(1))
		L.UpdateIcon()

	if(keep_old_material && oldmat && !istype(new_turf, /turf/space)) new_turf.setMaterial(oldmat)

	new_turf.icon_old = icon_old
	new_turf.name_old = name_old
	new_turf.path_old = old_savedpath

	if (handle_dir)
		new_turf.set_dir(old_dir)

	new_turf.levelupdate()
	new_turf.active_liquid = old_liquid

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
	new_turf.opaque_atom_count = old_opaque_atom_count
	new_turf.pass_unstable += old_pass_unstable

	new_turf.blocked_dirs = old_blocked_dirs

	new_turf.aiImage = old_aiimage
	new_turf.cameras = old_cameras
	new_turf.camera_coverage_emitters = old_camera_coverage_emitters

	new_turf.disposal_image = old_disposal_image

#ifdef ATMOS_PROCESS_CELL_STATS_TRACKING
	new_turf.process_cell_operations = old_process_cell_operations
#endif

	//combine the old comp_lookup with the new one because turfs sometimes register signals in New
	if (!src.comp_lookup)
		src.comp_lookup = old_comp_lookup
	else
		for (var/signal_type in old_comp_lookup)
			//nothing there, just copy the old one
			if (!src.comp_lookup[signal_type])
				src.comp_lookup[signal_type] = old_comp_lookup[signal_type]
			//it's a list, append (this is byond so it shouldn't matter if the old one was a list or not)
			else if (islist(comp_lookup[signal_type]))
				logTheThing(LOG_DEBUG, null, "turf/ReplaceWith signal shit: [new_turf]: [json_encode(comp_lookup)] + [json_encode(old_comp_lookup)]")

				src.comp_lookup[signal_type] |= old_comp_lookup[signal_type]
			//it's just a datum
			else
				if (islist(old_comp_lookup[signal_type])) //but the old one was a list, so append
					src.comp_lookup[signal_type] = (old_comp_lookup[signal_type] | src.comp_lookup[signal_type])
				else //the old one wasn't a list, make it so
					src.comp_lookup[signal_type] = (list(old_comp_lookup[signal_type]) | src.comp_lookup[signal_type])


	//cleanup old overlay to prevent some Stuff
	//This might not be necessary, i think its just the wall overlays that could be manually cleared here.
	new_turf.RL_Cleanup() //Cleans up/mostly removes the lighting.
	new_turf.RL_Init()

	//The following is required for when turfs change opacity during replace. Otherwise nearby lights will not be applying to the correct set of tiles.
	//example of failure : fire destorying a wall, the fire goes away, the area BEHIND the wall that used to be blocked gets strip()ped and now it leaves a blue glow (negative fire color)
	if (new_turf.opacity != old_opacity)
		new_turf.set_opacity(old_opacity)
		new_turf.set_opacity(!new_turf.opacity)


	if (handle_air)
		if (istype(new_turf, /turf/simulated)) //Anything -> Simulated tile
			var/turf/simulated/N = new_turf
			if (oldair) //Simulated tile -> Simulated tile
				N.air = oldair
			else if(zero_new_turf_air && istype(N.air)) // fix runtime: Cannot execute null.zero()
				N.air.reset_to_space_gas()

			#define _OLD_GAS_VAR_NOT_NULL(GAS, ...) GAS ## _old ||
			if (N.air && (APPLY_TO_GASES(_OLD_GAS_VAR_NOT_NULL) 0)) //Unsimulated tile w/ static atmos -> simulated floor handling
				#define _OLD_GAS_VAR_RESTORE(GAS, ...) N.air.GAS += GAS ## _old;

				APPLY_TO_GASES(_OLD_GAS_VAR_RESTORE)
				if (!N.air.temperature)
					N.air.temperature = temp_old

				#undef _OLD_GAS_VAR_RESTORE
			#undef _OLD_GAS_VAR_NOT_NULL
			if(N.air)
				N.update_visuals(N.air)
			// tell atmos to update this tile's air settings
			if (air_master)
				air_master.tiles_to_update |= N
		else if (air_master)
			air_master.high_pressure_delta -= src //lingering references to space turfs kept ending up in atmos lists after simulated turfs got replaced. wack!
			air_master.active_singletons -= src
			if (length(air_master.tiles_to_update))
				air_master.tiles_to_update -= src

		if (air_master && oldparent) //Handling air parent changes for oldparent for Simulated -> Anything
			air_master.groups_to_rebuild |= oldparent //Puts the oldparent into a queue to update the members.
			oldparent.members -= src //can we like not have space in these lists pleaseeee :) -cringe
			oldparent.borders?.Remove(src)


	new_turf.update_nearby_tiles(1)

	#ifdef CHECK_MORE_RUNTIMES
	in_replace_with--
	#endif
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
				W.UpdateIcon()
		if (map_settings.auto_windows)
			for (var/obj/window/auto/W in orange(1))
				W.UpdateIcon()
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
	floor.UpdateIcon()

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
	var/area/my_area = loc
	var/turf/floor
	var/turf/replacement = map_settings.space_turf_replacement
	if (my_area)
		if (my_area.filler_turf)
			floor = ReplaceWith(my_area.filler_turf)
		else if (replacement)
			floor = ReplaceWith(replacement)
		else
			floor = ReplaceWith("Space")
	else if (replacement)
		floor = ReplaceWith(replacement)
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
				W.UpdateIcon()
		if (map_settings.auto_windows)
			for (var/obj/window/auto/W in orange(1))
				W.UpdateIcon()
	return wall

/turf/proc/ReplaceWithRWall()
	var/wall = ReplaceWith("RWall")
	if (map_settings)
		if (map_settings.auto_walls)
			for (var/turf/simulated/wall/auto/W in orange(1))
				W.UpdateIcon()
		if (map_settings.auto_windows)
			for (var/obj/window/auto/W in orange(1))
				W.UpdateIcon()
	return wall

///Returns a turf to its initial path, if it is a simulated floor or wall. Returns FALSE if requested turf was not one of these initially.
/turf/proc/ReplaceWithInitial()
	var/oldpath = src.path_old
	var/turf/simulated/theturf = ReplaceWith("Initial")
	if(ispath(oldpath,/turf/simulated/floor) || ispath(oldpath,/turf/simulated/wall))
		if(ispath(oldpath,/turf/simulated/floor))
			for (var/obj/lattice/L in src.contents)
				qdel(L)
		else if(ispath(oldpath,/turf/simulated/wall))
			if (map_settings.auto_walls)
				for (var/turf/simulated/wall/auto/W in orange(1))
					W.UpdateIcon()
			if (map_settings.auto_windows)
				for (var/obj/window/auto/W in orange(1))
					W.UpdateIcon()
		return theturf
	else
		return FALSE

/turf/proc/is_sanctuary()
  var/area/AR = src.loc
  return AR.sanctuary

///turf/simulated/floor/Entered(atom/movable/A, atom/OL) //this used to run on every simulated turf (yes walls too!) -zewaka
//	..()
//moved step and slip functions into Carbon and Human files!

TYPEINFO(/turf/simulated)
	mat_appearances_to_ignore = list("steel")
/turf/simulated
	name = "station"
	allows_vehicles = 0
	stops_space_move = 1
	var/mutable_appearance/wet_overlay = null
	/// default melt chance from fire
	var/default_melt_chance = 30
	can_write_on = 1
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
					K.Attackby(W, user, params)
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

/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	text = "<font color=#aaa>#"
	density = 1
	pathable = 0
	explosion_resistance = 999999
	flags = FLUID_DENSE
	gas_impermeable = TRUE
#ifndef IN_MAP_EDITOR // display disposal pipes etc. above walls in map editors
	plane = PLANE_WALL
#else
	plane = PLANE_FLOOR
#endif

/turf/unsimulated/wall/generic

/turf/unsimulated/wall/solidcolor
	name = "invisible solid turf"
	desc = "A solid... nothing? Is that even a thing?"
	icon = 'icons/turf/walls.dmi'
	icon_state = "white"
	plane = PLANE_ABOVE_LIGHTING
	mouse_opacity = 0
	fullbright = 1

/turf/unsimulated/wall/solidcolor/white
#ifdef IN_MAP_EDITOR
	icon_state = "white-map"
#else
	icon_state = "white"
#endif

/turf/unsimulated/wall/solidcolor/black
#ifdef IN_MAP_EDITOR
	icon_state = "black-map"
#else
	icon_state = "black"
#endif

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

/turf/unsimulated/attack_hand(var/mob/user)
	if (src.density == 1)
		return
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && BOUNDS_DIST(user, user.pulling) > 0))
		return
	if (!isturf(user.pulling.loc))
		var/obj/container = user.pulling.loc
		if (user.pulling in container.contents)
			return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.remove_pulling()
		step(M, get_dir(fuck_u, src))
		M.set_pulling(t)
	else
		step(user.pulling, get_dir(fuck_u, src))
	return

// imported from space.dm

/turf/space/attack_hand(mob/user)
	if ((user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && BOUNDS_DIST(user, user.pulling) > 0))
		return
	if (!isturf(user.pulling.loc))
		return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/t = M.pulling
		M.remove_pulling()
		step(M, get_dir(fuck_u, src))
		M.set_pulling(t)
	else
		step(user.pulling, get_dir(fuck_u, src))
	return

/turf/attackby(obj/item/C, mob/user)
	if(src.can_build)
		var/area/A = get_area (user)
		var/obj/item/rods/R = C
		if (istype(R))
			if (istype(A, /area/supply/spawn_point || /area/supply/delivery_point || /area/supply/sell_point))
				boutput(user, SPAN_ALERT("You can't build here."))
				return
			if (locate(/obj/lattice, src)) return // If there is any lattice on the turf, do an early return.

			boutput(user, SPAN_NOTICE("Constructing support lattice ..."))
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, TRUE)
			R.change_stack_amount(-1)
			var/obj/lattice/lattice = new(src)
			lattice.auto_connect(to_walls=TRUE, to_all_turfs=TRUE, force_connect=TRUE)
			if (R.material)
				src.setMaterial(C.material)
			return

		if (istype(C, /obj/item/tile))
			if (istype(A, /area/supply/spawn_point || /area/supply/delivery_point || /area/supply/sell_point))
				boutput(user, SPAN_ALERT("You can't build here."))
				return
			var/obj/item/tile/T = C
			if (T.amount >= 1)
				for(var/obj/lattice/L in src)
					qdel(L)
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, TRUE)
				T.build(src)

#if defined(MAP_OVERRIDE_POD_WARS)
/turf/proc/edge_step(var/atom/movable/A, var/newx, var/newy)

	//testing pali's solution for getting the direction opposite of the map edge you are nearest to.
	// A.set_loc(A.loc)
	var/atom/target = get_edge_target_turf(A, (A.x + A.y > world.maxx ? SOUTH | WEST : NORTH | EAST) & (A.x - A.y > 0 ? NORTH | WEST : SOUTH | EAST))
	if (!istype(A, /obj/machinery/vehicle) && target)	//Throw everything but vehicles(pods)
		A.throw_at(target, 1, 1)

	return
#else
/turf/proc/edge_step(var/atom/movable/A, var/newx, var/newy)
	var/zlevel = 3 //((A.z=3)?5:3)//(3,4)
	var/turf/target_turf
	if(A.z == 3) zlevel = 5
	else zlevel = 3

	if (world.maxz < zlevel) // if there's less levels than the one we want to go to
		zlevel = 1 // just boot people back to z1 so the server doesn't lag to fucking death trying to place people on maps that don't exist
	if (istype(A, /obj/machinery/vehicle))
		var/obj/machinery/vehicle/V = A
		if (V.going_home)
			zlevel = 1
			target_turf = V.go_home()
			if(target_turf)
				zlevel = target_turf.z
			V.going_home = 0
	if (istype(A, /obj/newmeteor))
		qdel(A)
		return

	if (A.z == 1 && zlevel != A.z)
		if (!(isitem(A) && A:w_class <= W_CLASS_SMALL))
			for_by_tcl(C, /obj/machinery/communications_dish)
				C.add_cargo_logs(A)

	if(!target_turf)
		var/target_x = newx || A.x
		var/target_y = newy || A.y
		target_turf = locate(target_x, target_y, zlevel)
	if(target_turf)
		A.set_loc(target_turf)
#endif
//Vr turf is a jerk and pretends to be broken.
/turf/unsimulated/bombvr/ex_act(severity)
	switch(severity)
		if(1)
			src.icon_state = "vrspace"
		if(2)
			switch(pick(1;75,2))
				if(1)
					src.icon_state = "vrspace"
				if(2)
					if(prob(80))
						src.icon_state = "vrplating"

		if(3)
			if (prob(50))
				src.icon_state = "vrplating"
	return

/turf/unsimulated/wall/bombvr/ex_act(severity)
	switch(severity)
		if(1)
			set_opacity(0)
			set_density(0)
			src.icon_state = "vrspace"
		if(2)
			switch(pick(1;75,2))
				if(1)
					set_opacity(0)
					set_density(0)
					src.icon_state = "vrspace"
				if(2)
					if(prob(80))
						set_opacity(0)
						set_density(0)
						src.icon_state = "vrplating"

		if(3)
			if (prob(50))
				src.icon_state = "vrwallbroken"
				set_opacity(0)
	return



////////////////////////////////////////////////

//stuff ripped out of keelinsstuff.dm

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

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/shovel))
			if (src.icon_state == "dirt-dug")
				boutput(user, SPAN_ALERT("That is already dug up! Are you trying to dig through to China or something?  That would be even harder than usual, seeing as you are in space."))
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
							switch (rand(1, 5))
								if (1)
									new /obj/item/skull {desc = "A skull.  That was robbed.  From a grave.";} ( src )
								if (2)
									new /obj/item/sheet/wood {name = "rotted coffin wood"; desc = "Just your normal, everyday rotten wood.  That was robbed.  From a grave.";} ( src )
								if (3)
									new /obj/item/clothing/under/suit/pinstripe {name = "old pinstripe suit"; desc  = "A pinstripe suit.  That was stolen.  Off of a buried corpse.";} ( src )
								else
									; // default
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

/turf/simulated/nicegrass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"

/turf/simulated/nicegrass/random
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

/turf/unsimulated/null_hole
	name = "expedition chute"
	icon = 'icons/obj/delivery.dmi'
	icon_state = "floorflush_o"

	Entered(atom/movable/mover, atom/forget)
		. = ..()
		if(!mover.anchored)
			if(istype(mover, /obj/centcom_clone_wrapper))
				qdel(mover) // so the mob inside can GC in case references got freed up since qdel
			else
				mover.set_loc(null)
