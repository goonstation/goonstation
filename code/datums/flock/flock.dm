/////////////////////////////
// FLOCK DATUM
/////////////////////////////

/// associative list of flock names to their flock
/var/list/flocks = list()
/// Has a flock relay been unleashed yet this round
var/flock_signal_unleashed = FALSE

/// manages and holds information for a flock
/datum/flock
	var/name
	var/used_compute = 0
	var/total_compute = 0
	var/list/all_owned_tiles = list()
	var/list/busy_tiles = list()
	var/list/priority_tiles = list()
	var/list/deconstruct_targets = list()
	var/list/traces = list()
	/// number of zero compute flocktraces the flock has
	var/free_traces = 0
	var/queued_trace_deaths = 0
	/// max number of flocktraces the flock can support
	var/max_trace_count = 0
	/// Store a list of all minds who have been flocktraces of this flock at some point, indexed by name
	var/list/trace_minds = list()
	/// Store the mind of the current flockmind
	var/datum/mind/flockmind_mind = null
	/// Stores associative lists of type => list(units) - do not edit directly, use removeDrone() and registerUnit()
	var/list/units = list()
	/// The current cost of laying a flockdrone egg, automatically updated when drones are added and removed
	var/current_egg_cost = FLOCK_LAY_EGG_COST
	/// associative list of used names (for traces, drones, and bits) to true values
	var/list/active_names = list()
	var/list/enemies = list()
	var/list/atom/movable/ignores = list()
	///Associative list of objects to an associative list of their annotation names to images
	var/list/annotations = list()
	///Static cache of annotation images
	var/static/list/annotation_imgs = null
	var/list/obj/flock_structure/structures = list()
	var/list/datum/unlockable_flock_structure/unlockableStructures = list()
	var/bullets_hit = 0
	///list of strings that lets flock record achievements for structure unlocks
	var/list/achievements = list()
	var/mob/living/intangible/flock/flockmind/flockmind
	var/relay_in_progress = FALSE
	var/relay_finished = FALSE
	var/datum/tgui/flockpanel
	var/ui_tab = "drones"

	var/center_x = 0
	var/center_y = 0

	var/obj/dummy/center_marker = null

	var/datum/flockstats/stats

/datum/flock/New()
	..()
	src.center_marker = new(locate(0,0,1))
	src.center_marker.anchored = TRUE
	src.center_marker.mouse_opacity = 0
	src.center_marker.icon = 'icons/misc/featherzone-160x160.dmi'
	src.center_marker.icon_state = "structure-relay"
	src.center_marker.color = COLOR_MATRIX_FLOCKMIND
	src.center_marker.alpha = 0
	src.center_marker.pixel_x = -64
	src.center_marker.pixel_y = -64

	src.name = src.pick_name("flock")
	flocks[src.name] = src
	src.stats = new(src)
	processing_items |= src
	src.load_structures()
	if (!annotation_imgs)
		annotation_imgs = build_annotation_imgs()
	src.units[/mob/living/critter/flock/drone] = list() //this one needs initialising


/datum/flock/proc/load_structures()
	src.unlockableStructures = list()
	for(var/DT in childrentypesof(/datum/unlockable_flock_structure))
		src.unlockableStructures += new DT(src)

/datum/flock/ui_status(mob/user)
	if(istype(user, /mob/living/intangible/flock/flockmind) || tgui_admin_state.can_use_topic(src, user))
		return UI_INTERACTIVE

/datum/flock/ui_data(mob/user)
	return describe_state(src.ui_tab)

/datum/flock/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FlockPanel")
		ui.open()

/datum/flock/ui_act(action, list/params, datum/tgui/ui)
	var/mob/user = ui.user;
	if (!istype(user, /mob/living/intangible/flock/flockmind))
		var/mob/living/critter/flock/drone/F = user
		if (!istype(F) || !istype(F.controller, /mob/living/intangible/flock/flockmind))
			return
	switch(action)
		if("jump_to")
			if (istype(user, /mob/living/critter/flock/drone/))
				var/mob/living/critter/flock/drone/F = user
				user = F.controller
				F.release_control()
			var/atom/movable/origin = locate(params["origin"])
			if(!QDELETED(origin))
				if(!src.z_level_check(origin))
					boutput(user, "<span class='alert'>They seem to be beyond your capacity to reach.</span>")
				else
					user.set_loc(get_turf(origin))
		if("rally")
			var/mob/living/critter/flock/C = locate(params["origin"])
			if(C?.flock == src) // not sure when it'd apply but in case
				C.rally(get_turf(user))
		if("remove_enemy")
			var/mob/living/E = locate(params["origin"])
			if(E)
				src.removeEnemy(E)
		if("eject_trace")
			var/mob/living/intangible/flock/trace/T = locate(params["origin"])
			if(T)
				var/mob/living/critter/flock/drone/host = T.loc
				if(istype(host))
					boutput(host, "<span class='flocksay'><b>\[SYSTEM: The flockmind has removed you from your previous corporeal shell.\]</b></span>")
					host.release_control()
		if("promote_trace")
			var/message = "Are you sure?"

			var/mob/living/intangible/flock/trace/trace_to_promote = locate(params["origin"])
			if(!istype(trace_to_promote.loc, /mob/living/critter/flock/drone))
				if (!trace_to_promote.client || trace_to_promote.afk_counter > FLOCK_AFK_COUNTER_THRESHOLD)
					message += " This Flocktrace is unresponsive."
			else
				var/mob/living/critter/flock/drone/host = trace_to_promote.loc
				if (!host.client || host.controller.afk_counter > FLOCK_AFK_COUNTER_THRESHOLD)
					message += " This Flocktrace is unresponsive."

			if (tgui_alert(user, message, "Promote Flocktrace", list("Yes", "Cancel")) == "Yes")
				var/choice = tgui_alert(user, "Leave the Flock?", "Promote Flocktrace", list("No", "Yes", "Cancel"))
				if (choice && choice != "Cancel")
					if (!trace_to_promote)
						return
					trace_to_promote.promoteToFlockmind(choice == "No" ? FALSE : TRUE)

		if("delete_trace")
			var/mob/living/intangible/flock/trace/T = locate(params["origin"])
			if(T)
				if(tgui_alert(user, "This will destroy the Flocktrace. Are you sure you want to do this?", "Confirmation", list("Yes", "No")) == "Yes")
					var/mob/living/critter/flock/drone/host = T.loc
					if(istype(host))
						host.release_control()
					flock_speak(null, "Partition [T.real_name] has been reintegrated into flock background processes.", src)
					boutput(T, "<span class='flocksay'><b>\[SYSTEM: Your higher cognition has been forcibly reintegrated into the collective will of the flock.\]</b></span>")
					T.death()
		if ("cancel_tealprint")
			var/obj/flock_structure/ghost/tealprint = locate(params["origin"])
			if (tealprint)
				tealprint.cancelBuild()
		if ("change_tab")
			if (src.ui_tab != params["tab"]) //don't force a ui update if the tab hasn't changed
				src.ui_tab = params["tab"]
				. = TRUE

/datum/flock/proc/describe_state(var/category)
	var/list/state = list()
	state["update"] = "flock"
	state["partitions"] = list()
	state["drones"] = list()
	state["structures"] = list()
	state["enemies"] = list()
	state["stats"] = list()
	state["category_lengths"] = list(
		"traces" = length(src.traces),
		"drones" = length(src.units[/mob/living/critter/flock/drone]),
		"structures" = length(src.structures),
		"enemies" = length(src.enemies),
	)
	state["category"] = category
	//we only return data needed by the current tab, cursed but faster
	switch (category)
		if ("traces")
			// DESCRIBE TRACES
			for(var/mob/living/intangible/flock/trace/T as anything in src.traces)
				state["partitions"] += list(T.describe_state())

		if ("drones")
			// DESCRIBE DRONES
			for(var/mob/living/critter/flock/drone/F as anything in src.units[/mob/living/critter/flock/drone])
				state["drones"] += list(F.describe_state())

		if ("structures")
			// DESCRIBE STRUCTURES
			for(var/obj/flock_structure/structure as anything in src.structures)
				state["structures"] += list(structure.describe_state())

		if ("enemies")
			// DESCRIBE ENEMIES
			for(var/name in src.enemies)
				var/list/enemy_stats = src.enemies[name]
				var/atom/M = enemy_stats["mob"]
				if(!QDELETED(M))
					var/list/enemy = list()
					enemy["name"] = M.name
					enemy["area"] = enemy_stats["last_seen"]
					enemy["ref"] = "\ref[M]"
					state["enemies"] += list(enemy)
				else
					// enemy no longer exists, let's do something about that
					src.enemies -= name

		if ("stats")
			var/list/stats = list(
				"Drones realized: " = src.stats.drones_made,
				"Bits formed: " = src.stats.bits_made,
				"Total deaths: " = src.stats.deaths,
				"Resources gained: " = src.stats.resources_gained,
				"Partitions created: " = src.stats.partitions_made,
				"Tiles converted: " = src.stats.tiles_converted,
				"Structures created: " = src.stats.structures_made,
				"Highest compute: " = src.stats.peak_compute
				)

			for (var/stat in stats)
				state["stats"] += list(list("name" = stat, "value" = stats[stat]))

	// DESCRIBE VITALS
	var/list/vitals = list()
	vitals["name"] = src.name
	state["vitals"] = vitals

	return state

/datum/flock/disposing()
	flocks[src.name] = null
	processing_items -= src
	..()

/datum/flock/proc/total_health_percentage()
	var/hp = 0
	var/max_hp = 0
	for(var/pathkey in src.units)
		for(var/mob/living/critter/flock/F as anything in src.units[pathkey])
			F.count_healths()
			hp += F.health
			max_hp += F.max_health
	if(max_hp != 0)
		return hp/max_hp
	else
		return 0

/datum/flock/proc/total_resources()
	. = 0
	for(var/mob/living/critter/flock/drone/F as anything in src.units[/mob/living/critter/flock/drone])
		. += F.resources


/datum/flock/proc/total_compute()
	if (src.hasAchieved(FLOCK_ACHIEVEMENT_CHEAT_COMPUTE))
		return 1000000
	else
		return src.total_compute

/datum/flock/proc/can_afford_compute(var/cost)
	return (cost <= src.total_compute() - src.used_compute)

/datum/flock/proc/update_computes(forceTextUpdate = FALSE)
	var/totalCompute = src.total_compute()

	var/datum/abilityHolder/flockmind/aH = src.flockmind.abilityHolder
	aH?.updateCompute(src.used_compute, totalCompute, forceTextUpdate)

	for (var/mob/living/intangible/flock/trace/T as anything in src.traces)
		aH = T.abilityHolder
		aH?.updateCompute(src.used_compute, totalCompute, forceTextUpdate)

	src.max_trace_count = round(min(src.total_compute(), FLOCK_RELAY_COMPUTE_COST) / FLOCKTRACE_COMPUTE_COST) + src.free_traces

/datum/flock/proc/registerFlockmind(var/mob/living/intangible/flock/flockmind/F)
	if(!F)
		return
	src.flockmind = F

//since flocktraces need to be given their flock in New this is useful for debug
/datum/flock/proc/spawnTrace()
	var/mob/living/intangible/flock/trace/T = new(usr.loc, src)
	return T

/datum/flock/proc/addTrace(var/mob/living/intangible/flock/trace/T)
	if(!T)
		return
	src.traces |= T
	src.update_computes(TRUE)

/datum/flock/proc/removeTrace(var/mob/living/intangible/flock/trace/T)
	if(!T)
		return
	src.traces -= T
	src.active_names -= T.real_name
	hideAnnotations(T)
	src.update_computes(TRUE)

/datum/flock/proc/ping(var/atom/target, var/mob/living/intangible/flock/pinger)
	//awful typecheck because turfs and movables have vis_contents defined seperately because god hates us
	if (!istype(pinger) || (!istype(target, /atom/movable) && !istype(target, /turf)))
		return

	target.AddComponent(/datum/component/flock_ping)

	for (var/mob/living/intangible/flock/F in (src.traces + src.flockmind))
		if (F != pinger)
			var/image/arrow = image(icon = 'icons/mob/screen1.dmi', icon_state = "arrow", loc = F, layer = HUD_LAYER)
			arrow.color = "#00ff9dff"
			arrow.pixel_y = 20
			arrow.transform = matrix(arrow.transform, 2,2, MATRIX_SCALE)
			var/angle = 180 + get_angle(F, target)
			arrow.transform = matrix(arrow.transform, angle, MATRIX_ROTATE)
			F.client?.images += arrow
			animate(arrow, time = 3 SECONDS, alpha = 0)
			SPAWN(3 SECONDS)
				F.client?.images -= arrow
				qdel(arrow)
		var/class = "flocksay ping [istype(F, /mob/living/intangible/flock/flockmind) ? "flockmind" : ""]"
		var/prefix = "<span class='bold'>\[[src.name]\] </span><span class='name'>[pinger.name]</span>"
		boutput(F, "<span class='[class]'><a href='?src=\ref[F];origin=\ref[target];ping=[TRUE]'>[prefix]: Interrupt request, target: [target] in [get_area(target)].</a></span>")
	playsound_global(src.traces + src.flockmind, 'sound/misc/flockmind/ping.ogg', 50, 0.5)

// ANNOTATIONS

///Init annotation images to copy
/datum/flock/proc/build_annotation_imgs()
	. = list()

	var/image/deconstruct = image('icons/misc/featherzone.dmi', icon_state = "deconstruct")
	deconstruct.blend_mode = BLEND_ADD
	deconstruct.plane = PLANE_ABOVE_LIGHTING
	deconstruct.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
	deconstruct.pixel_y = 16
	.[FLOCK_ANNOTATION_DECONSTRUCT] = deconstruct

	var/image/hazard = image('icons/misc/featherzone.dmi', icon_state = "hazard")
	hazard.blend_mode = BLEND_ADD
	hazard.plane = PLANE_ABOVE_LIGHTING
	hazard.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
	hazard.pixel_y = 16
	.[FLOCK_ANNOTATION_HAZARD] = hazard

	var/image/priority = image('icons/misc/featherzone.dmi', icon_state = "frontier")
	priority.appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE
	priority.alpha = 180
	priority.plane = PLANE_ABOVE_LIGHTING
	priority.mouse_opacity = FALSE
	.[FLOCK_ANNOTATION_PRIORITY] = priority

	var/image/reserved = image('icons/misc/featherzone.dmi', icon_state = "frontier")
	reserved.appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE
	reserved.alpha = 80
	reserved.plane = PLANE_ABOVE_LIGHTING
	reserved.mouse_opacity = FALSE
	.[FLOCK_ANNOTATION_RESERVED] = reserved

	var/image/flock_face = image('icons/misc/featherzone.dmi', icon_state = "flockmind_face")
	flock_face.blend_mode = BLEND_ADD
	flock_face.plane = PLANE_ABOVE_LIGHTING
	flock_face.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
	flock_face.pixel_y = 16
	.[FLOCK_ANNOTATION_FLOCKMIND_CONTROL] = flock_face

	var/image/trace_face = image('icons/misc/featherzone.dmi', icon_state = "flocktrace_face")
	trace_face.blend_mode = BLEND_ADD
	trace_face.plane = PLANE_ABOVE_LIGHTING
	trace_face.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
	trace_face.pixel_y = 16
	.[FLOCK_ANNOTATION_FLOCKTRACE_CONTROL] = trace_face

	var/image/health = image('icons/misc/featherzone.dmi', icon_state = "hp-100")
	health.blend_mode = BLEND_ADD
	health.pixel_x = 10
	health.pixel_y = 16
	health.plane = PLANE_ABOVE_LIGHTING
	health.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
	.[FLOCK_ANNOTATION_HEALTH] = health

	var/image/ignore = image('icons/misc/featherzone.dmi', icon_state = "ignore")
	ignore.blend_mode = BLEND_ADD
	ignore.plane = PLANE_ABOVE_LIGHTING
	ignore.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
	ignore.pixel_y = 16
	.[FLOCK_ANNOTATION_IGNORE] = ignore

///proc to get the indexed list of annotations on a particular mob
/datum/flock/proc/getAnnotations(atom/target)
	var/active = src.annotations[target]
	if(!islist(active))
		active = list()
		src.annotations[target] = active
	return active

///Toggle a named annotation
/datum/flock/proc/toggleAnnotation(atom/target, var/annotation)
	var/active = getAnnotations(target)
	if (annotation in active)
		removeAnnotation(target, annotation)
	else
		addAnnotation(target, annotation)

///Add a named annotation
/datum/flock/proc/addAnnotation(atom/target, var/annotation)
	var/active = getAnnotations(target)
	if(!(annotation in active))
		var/image/icon = image(src.annotation_imgs[annotation], loc=target)
		if (isturf(target))
			var/turf/T = target
			icon.loc = T.RL_MulOverlay || T
		active[annotation] = icon
		get_image_group(src).add_image(icon)

///Remove a named annotation
/datum/flock/proc/removeAnnotation(atom/target, var/annotation)
	var/active = getAnnotations(target)
	var/image/image = active[annotation]
	if (image)
		get_image_group(src).remove_image(image)
		active -= annotation
		qdel(image)
	if (!length(active))
		src.annotations -= target

/datum/flock/proc/showAnnotations(var/mob/M)
	get_image_group(src).add_mob(M)

/datum/flock/proc/hideAnnotations(var/mob/M)
	get_image_group(src).remove_mob(M, TRUE)

// naming

/datum/flock/proc/pick_name(flock_type)
	var/name
	var/name_found = FALSE
	var/tries = 0
	var/max_tries = 5000 // really shouldn't occur

	while (!name_found && tries < max_tries)
		if (flock_type == "flock")
			name = "[pick(consonants_lower)][pick(vowels_lower)].[pick(consonants_lower)][pick(vowels_lower)]"
			if (!flocks[name])
				name_found = TRUE
		else
			if (flock_type == "flocktrace")
				name = "[pick(consonants_upper)][pick(vowels_lower)].[pick(vowels_lower)]"
			if (flock_type == "flockdrone")
				name = "[pick(consonants_lower)][pick(vowels_lower)].[pick(consonants_lower)][pick(vowels_lower)].[pick(consonants_lower)][pick(vowels_lower)]"
			else if (flock_type == "flockbit")
				name = "[pick(consonants_upper)].[rand(10,99)].[rand(10,99)]"

			if (!src.active_names[name])
				name_found = TRUE
				src.active_names[name] = TRUE
		tries++
		if(phrase_log.is_uncool(jointext(splittext(name,"."),"")))
			name_found = FALSE

	if (!name_found && tries == max_tries)
		logTheThing(LOG_DEBUG, null, "Too many tries were reached in trying to name a flock or one of its units.")
		return "error"
	return name

// UNITS

/datum/flock/proc/registerUnit(var/mob/living/critter/flock/D, check_name_uniqueness = FALSE)
	if(isflockmob(D))
		if(!src.units[D.type])
			src.units[D.type] = list()
		src.units[D.type] |= D
		if (istype(D, /mob/living/critter/flock/drone))
			src.updateEggCost()
		if (check_name_uniqueness && src.active_names[D.real_name])
			D.real_name = istype(D, /mob/living/critter/flock/drone) ? src.pick_name("flockdrone") : src.pick_name("flockbit")
		D.AddComponent(/datum/component/flock_interest, src)
		var/comp_provided = D.compute_provided()
		if (comp_provided)
			if (comp_provided < 0)
				src.used_compute += abs(comp_provided)
			else
				src.total_compute += comp_provided
			src.update_computes()

/datum/flock/proc/removeDrone(var/mob/living/critter/flock/D)
	if(isflockmob(D))
		src.units[D.type] -= D
		src.active_names -= D.real_name
		if (istype(D, /mob/living/critter/flock/drone))
			src.updateEggCost()
		D.GetComponent(/datum/component/flock_interest)?.RemoveComponent(/datum/component/flock_interest)
		if(D.real_name && busy_tiles[D.real_name])
			src.unreserveTurf(D.real_name)
		var/comp_provided = D.compute_provided()
		if (comp_provided)
			if (comp_provided < 0)
				src.used_compute -= abs(comp_provided)
			if (comp_provided > 0)
				src.total_compute -= comp_provided
			src.update_computes()
		D.flock = null

// TRACES

/datum/flock/proc/getActiveTraces()
	var/list/active_traces = list()
	for (var/mob/living/intangible/flock/trace/T as anything in src.traces)
		if (T.client && T.afk_counter < FLOCK_AFK_COUNTER_THRESHOLD)
			active_traces += T
		else if (istype(T.loc, /mob/living/critter/flock/drone))
			var/mob/living/critter/flock/drone/flockdrone = T.loc
			if (flockdrone.client && T.afk_counter < FLOCK_AFK_COUNTER_THRESHOLD)
				active_traces += T
	return active_traces

// STRUCTURES

///This function only notifies the flock of the unlock, actual unlock logic is handled in the datum
/datum/flock/proc/notifyUnlockStructure(var/datum/unlockable_flock_structure/SD)
	flock_speak(null, "New structure devised: [SD.friendly_name]", src)

///This function only notifies the flock of the relock, actual unlock logic is handled in the datum
/datum/flock/proc/notifyRelockStructure(var/datum/unlockable_flock_structure/SD)
	flock_speak(null, "Alert, structure tealprint disabled: [SD.friendly_name]", src)

/datum/flock/proc/registerStructure(obj/flock_structure/S)
	if(isflockstructure(S))
		src.structures |= S
		S.AddComponent(/datum/component/flock_interest, src)
		var/comp_provided = S.compute_provided()
		if (comp_provided)
			if (comp_provided < 0)
				src.used_compute += abs(comp_provided)
			else
				src.total_compute += comp_provided
			src.update_computes()

/datum/flock/proc/removeStructure(obj/flock_structure/S)
	if(isflockstructure(S))
		src.structures -= S
		S.GetComponent(/datum/component/flock_interest)?.RemoveComponent(/datum/component/flock_interest)
		S.flock = null
		var/comp_provided = S.compute_provided()
		if (comp_provided)
			if (comp_provided < 0)
				src.used_compute -= abs(comp_provided)
			else
				src.total_compute -= comp_provided
			src.update_computes()

/datum/flock/proc/getComplexDroneCount()
	if (!src.units)
		return 0
	return length(src.units[/mob/living/critter/flock/drone/])

/datum/flock/proc/updateEggCost()
	var/egg_count = 0
	for (var/obj/flock_structure/egg/egg in src.structures)
		if (!QDELETED(egg))
			egg_count++
	src.current_egg_cost = round(FLOCK_LAY_EGG_COST + (src.getComplexDroneCount() + egg_count) ** 1.4, 10)

/datum/flock/proc/toggleDeconstructionFlag(var/atom/target)
	toggleAnnotation(target, FLOCK_ANNOTATION_DECONSTRUCT)
	src.deconstruct_targets ^= target

// ENEMIES

/datum/flock/proc/updateEnemy(atom/M)
	if(!M)
		return
	if (src.isIgnored(M))
		return
	if (isvehicle(M))
		for (var/mob/occupant in M) // making assumption flock knows who everyone in the pod is
			src.updateEnemy(occupant)
	//vehicles can be enemies but drones will only attack them if they are occupied
	if(!isliving(M) && !iscritter(M) && !isvehicle(M))
		return
	var/enemy_name = M
	var/list/enemy_deets
	if(!(enemy_name in src.enemies))
		var/area/enemy_area = get_area(M)
		enemy_deets = list()
		enemy_deets["mob"] = M
		enemy_deets["last_seen"] = enemy_area
		src.enemies[enemy_name] = enemy_deets
		addAnnotation(M, FLOCK_ANNOTATION_HAZARD)
	else
		enemy_deets = src.enemies[enemy_name]
		enemy_deets["last_seen"] = get_area(M)

/datum/flock/proc/removeEnemy(atom/M)
	if(!isliving(M) && !iscritter(M) && !isvehicle(M))
		return
	src.enemies -= M

	removeAnnotation(M, FLOCK_ANNOTATION_HAZARD)

/datum/flock/proc/isEnemy(atom/M)
	var/enemy_name = M
	return (enemy_name in src.enemies)

/datum/flock/proc/addIgnore(atom/A)
	if (isvehicle(A))
		for (var/mob/occupant in A)
			src.addIgnore(occupant)
	if (ismob(A))
		var/mob/M = A
		if (M.find_radio())
			boutput(A, "<span class='flocksay italic'>A thousand whispers you never noticed suddenly fall silent and the feeling of being watched fades.</span>")
	src.ignores |= A
	src.addAnnotation(A, FLOCK_ANNOTATION_IGNORE)

/datum/flock/proc/removeIgnore(atom/A)
	if (isvehicle(A))
		for (var/mob/occupant in A)
			src.removeIgnore(occupant)
	if (ismob(A))
		var/mob/M = A
		if (M.find_radio())
			boutput(A, "<span class='flocksay italic'>You hear harsh echoes of the Signal in your mind. The gaze of something you can't see is once again painfully fixed on you.</span>")
	src.ignores -= A
	src.removeAnnotation(A, FLOCK_ANNOTATION_IGNORE)

/datum/flock/proc/isIgnored(atom/A)
	return A in src.ignores

// DEATH
///if real is FALSE then perish will not deallocate needed lists (used for pity respawn)
/datum/flock/proc/perish(real = TRUE)
	for(var/pathkey in src.units)
		for(var/mob/living/critter/flock/F as anything in src.units[pathkey])
			F.dormantize()
	for(var/obj/flock_structure/S as anything in src.structures)
		S.gib()
	for(var/turf/T in src.priority_tiles)
		src.togglePriorityTurf(T)
	for (var/name in src.busy_tiles)
		src.unreserveTurf(src.busy_tiles[name])
	src.bullets_hit = 0
	src.achievements = list()
	src.unlockableStructures = list()
	src.total_compute = 0
	src.used_compute = 0
	for (var/turf/simulated/floor/feather/feathertile as anything in src.all_owned_tiles)
		feathertile.flock = null
	all_owned_tiles = list()
	if (!real)
		src.load_structures()
		return
	for(var/mob/living/intangible/flock/trace/T as anything in src.traces)
		T.death()
	if (src.flockmind)
		hideAnnotations(src.flockmind)
	qdel(get_image_group(src))
	annotations = null
	busy_tiles = null
	priority_tiles = null
	units = null
	active_names = null
	enemies = null
	flockmind = null
	//do not qdel(src), we still need the flock datum for tracking flocktrace mind connections

// TURFS

/datum/flock/proc/reserveTurf(var/turf/simulated/T, var/name)
	if(T in all_owned_tiles)
		return
	if(name in src.busy_tiles)
		return
	src.busy_tiles[name] = T
	addAnnotation(T, FLOCK_ANNOTATION_RESERVED)

/datum/flock/proc/unreserveTurf(var/name)
	var/turf/simulated/T = src.busy_tiles[name]
	src.busy_tiles -= name
	removeAnnotation(T, FLOCK_ANNOTATION_RESERVED)

/datum/flock/proc/claimTurf(var/turf/simulated/T)
	if (!T)
		return
	src.flockmind.tutorial?.PerformSilentAction(FLOCK_ACTION_TURF_CLAIM, T)

	if (!src.relay_in_progress && !src.relay_finished && ((abs(T.x - src.center_x) + abs(T.y - src.center_y))/2 < 50)) //ignore extreme outliers
		var/length = length(src.all_owned_tiles)
		src.center_x += (T.x - src.center_x)/(length + 1)
		src.center_y += (T.y - src.center_y)/(length + 1)
		src.center_marker.set_loc(locate(src.center_x, src.center_y, 1))
	src.all_owned_tiles |= T
	src.priority_tiles -= T

	if (isfeathertile(T))
		src.stats.tiles_converted++
	if (istype(T, /turf/simulated/floor/feather))
		var/turf/simulated/floor/feather/featherturf = T
		featherturf.flock = src
	T.AddComponent(/datum/component/flock_interest, src)
	for(var/obj/O in T.contents)
		if(HAS_ATOM_PROPERTY(O, PROP_ATOM_FLOCK_THING))
			O.AddComponent(/datum/component/flock_interest, src)
		if(istype(O, /obj/flock_structure))
			var/obj/flock_structure/structure = O
			structure.flock = src
			src.registerStructure(structure)
	removeAnnotation(T, FLOCK_ANNOTATION_PRIORITY)

// whether the turf is reserved/being converted or not, will still count as free to provided drone name if they have reserved/are converting it
/datum/flock/proc/isTurfFree(var/turf/simulated/T, var/queryName)
	for(var/name in src.busy_tiles)
		if(name == queryName)
			continue
		if(src.busy_tiles[name] == T)
			return FALSE
	return TRUE

/datum/flock/proc/togglePriorityTurf(var/turf/T)
	if (!T)
		return TRUE
	toggleAnnotation(T, FLOCK_ANNOTATION_PRIORITY)
	priority_tiles ^= T

// get closest unclaimed tile to requester
/datum/flock/proc/getPriorityTurfs(var/mob/living/critter/flock/drone/requester)
	if(!requester)
		return
	if(src.busy_tiles[requester.name])
		return src.busy_tiles[requester.name]
	if(length(priority_tiles))
		var/list/available_tiles = priority_tiles
		for(var/owner in src.busy_tiles)
			available_tiles -= src.busy_tiles[owner]
		return available_tiles

// PROCESS

/datum/flock/proc/process()
	if (!src.relay_in_progress && !src.relay_finished)
		if ((src.total_compute() >= FLOCK_RELAY_COMPUTE_COST) && !src.flockmind.tutorial)
			src.relay_in_progress = TRUE
			src.center_marker.alpha = 0
			for (var/turf/T in range(3, src.center_marker))
				for (var/atom/A in T)
					if ((ismob(A) || isflockstructure(A)) && !isintangible(A)) //stupid, but flock structures define gib too
						var/mob/M = A
						M.gib()
					else if (A.density)
						qdel(A)
				T.ReplaceWith(/turf/simulated/floor/feather)
			new /obj/flock_structure/relay(get_turf(src.center_marker), src)
		else
			src.center_marker.alpha = max(0, src.total_compute() - 300)

	for(var/datum/unlockable_flock_structure/ufs as anything in src.unlockableStructures)
		ufs.process()

	for(var/atom/S in src.deconstruct_targets)
		if(QDELETED(S))
			src.toggleDeconstructionFlag(S)

	var/atom/M
	for(var/enemy in src.enemies)
		M = src.enemies[enemy]["mob"]
		if (QDELETED(M))
			src.removeEnemy(M)
	for(var/atom/ignore as anything in src.ignores)
		if (QDELETED(ignore))
			src.removeIgnore(ignore)

/datum/flock/proc/convert_turf(var/turf/T, var/converterName)
	src.unreserveTurf(converterName)
	src.claimTurf(flock_convert_turf(T))
	playsound(T, 'sound/items/Deconstruct.ogg', 30, 1, extrarange = -10)

// Z LEVEL CHECK

/datum/flock/proc/z_level_check(var/atom/A)
	var/turf/T = get_turf(A)
	if (src.flockmind.tutorial || T.z == Z_LEVEL_STATION)
		return TRUE
	return FALSE

// ACHIEVEMENTS

///Unlock an achievement (string) if it isn't already unlocked
/datum/flock/proc/achieve(var/str)
	src.achievements |= str

/datum/flock/proc/unAchieve(var/str)
	src.achievements -= str

///Unlock an achievement (string) if it isn't already unlocked
/datum/flock/proc/hasAchieved(var/str)
	return (str in src.achievements)

/datum/flock/proc/check_for_bullets_hit_achievement(obj/projectile/P)
	if (!istype(P.proj_data, /datum/projectile/bullet))
		return
	if (src.bullets_hit > FLOCK_BULLETS_HIT_THRESHOLD)
		return

	var/attacker = P.shooter
	if(!(ismob(attacker) || iscritter(attacker) || isvehicle(attacker)))
		attacker = P.mob_shooter // shooter is updated on reflection, so we fall back to mob_shooter if it turns out to be a wall or something
	if (istype(attacker, /mob/living/critter/flock))
		var/mob/living/critter/flock/flockcritter = attacker
		if (flockcritter.flock == src)
			return
	src.bullets_hit++
	if (src.bullets_hit == FLOCK_BULLETS_HIT_THRESHOLD)
		src.achieve(FLOCK_ACHIEVEMENT_BULLETS_HIT)
////////////////////
// GLOBAL PROCS!!
////////////////////

// made into a global proc so a reagent can use it
// simple enough: if object path matches key, replace with instance of value
// if value is null, just delete object
// !!!! priority is determined by list order !!!!
// if you have a subclass, it MUST go first in the list, or the first type that matches will take priority (ie, the superclass)
// see /obj/machinery/light/small/floor and /obj/machinery/light for examples of this
/var/list/flock_conversion_paths = list(
	/obj/grille = /obj/grille/flock,
	/obj/window = /obj/window/auto/feather,
	/obj/machinery/door = /obj/machinery/door/feather,
	/obj/stool = /obj/stool/chair/comfy/flock,
	/obj/table = /obj/table/flock/auto,
	/obj/machinery/light/small/floor = /obj/machinery/light/flock/floor,
	/obj/machinery/light = /obj/machinery/light/flock,
	/obj/storage/closet = /obj/storage/closet/flock,
	/obj/storage/secure/closet = /obj/storage/closet/flock,
	/obj/machinery/computer3 = /obj/flock_structure/compute,
	/obj/machinery/computer = /obj/flock_structure/compute,
	/obj/machinery/networked/teleconsole = /obj/flock_structure/compute,
	/obj/machinery/networked/mainframe = /obj/flock_structure/compute/mainframe,
	/obj/machinery/vending = /obj/flock_structure/fabricator,
	/obj/machinery/manufacturer = /obj/flock_structure/fabricator,
	/obj/submachine/seed_vendor = /obj/flock_structure/fabricator,
	/obj/machinery/dispenser = /obj/flock_structure/fabricator,
	/obj/machinery/disposal_pipedispenser = /obj/flock_structure/fabricator,
	/obj/machinery/chem_dispenser = /obj/flock_structure/fabricator,
	/obj/machinery/chemicompiler_stationary = /obj/flock_structure/fabricator,
	/obj/reagent_dispensers/foamtank = /obj/flock_structure/fabricator,
	/obj/reagent_dispensers/watertank = /obj/flock_structure/fabricator,
	/obj/reagent_dispensers/fueltank = /obj/flock_structure/fabricator,
	/obj/reagent_dispensers/heliumtank = /obj/flock_structure/fabricator,
	/obj/reagent_dispensers/compostbin = /obj/flock_structure/fabricator,
	/obj/reagent_dispensers/beerkeg = /obj/flock_structure/fabricator,
	/obj/spacevine = null
	)

/proc/flockTurfAllowed(var/turf/T)
	var/area/area = get_area(T)
	return !(istype(area, /area/listeningpost) || istype(area, /area/ghostdrone_factory))

/proc/flock_convert_turf(var/turf/T, tutorial=FALSE, force=FALSE, fancy=FALSE)
	if(!T)
		return
	if (!force && !flockTurfAllowed(T))
		return

	var/static/list/fancy_flock_matrix = list(-0.2,-0.2,-0.2,-0.2,-0.2,-0.2,-0.25,-0.2,-0.15,0.368627,0.764706,0.666667)

	if(istype(T, /turf/simulated/wall) || force && (T.density || locate(/obj/indestructible/shuttle_corner) in T))
		if(tutorial)
			T.ReplaceWith(/turf/simulated/wall/auto/feather/tutorial, FALSE, force=force)
		else
			T.ReplaceWith(/turf/simulated/wall/auto/feather, FALSE, force=force)
		animate_flock_convert_complete(T)
		if(force)
			for(var/obj/indestructible/shuttle_corner/C in T)
				qdel(C)

	if(istype(T, /turf/simulated/floor) || force && istype(T, /turf/unsimulated/floor))
		T.ReplaceWith(/turf/simulated/floor/feather, FALSE, force=force)
		animate_flock_convert_complete(T)

	// regular and flock lattices
	var/obj/lattice/lat = locate(/obj/lattice) in T
	if(lat)
		if(istype(lat, /obj/lattice/flock) || !fancy)
			qdel(lat)
			T.ReplaceWith(/turf/simulated/floor/feather, FALSE, force=force)
			animate_flock_convert_complete(T)
		else
			qdel(lat)
			new /obj/lattice/flock(T)

	var/obj/grille/catwalk/catw = locate(/obj/grille/catwalk) in T
	if(catw)
		qdel(catw)
		T.ReplaceWith(/turf/simulated/floor/feather, FALSE, force=force)
		animate_flock_convert_complete(T)

	if(istype(T, /turf/space))
		var/obj/lattice/flock/FL = locate(/obj/lattice/flock) in T
		if(!FL)
			FL = new /obj/lattice/flock(T)

	for(var/obj/O in T)
		if(istype(O, /obj/effect) || istype(O, /obj/overlay) || istype(O, /obj/particle) || istype(O, /obj/lattice/flock))
			continue
		if (istype(O, /obj/machinery/camera))
			var/obj/machinery/camera/cam = O
			if (cam.camera_status)
				cam.break_camera()
			continue
		var/success = FALSE
		for(var/keyPath in flock_conversion_paths)
			if (!istype(O, keyPath))
				continue
			if (isnull(flock_conversion_paths[keyPath]))
				qdel(O)
				continue
			if (istype(O, /obj/machinery))
				if (istype(O, /obj/machinery/door))
					if (istype(O, /obj/machinery/door/firedoor/pyro) || istype(O, /obj/machinery/door/window) || istype(O, /obj/machinery/door/airlock/pyro/glass/windoor) || istype(O, /obj/machinery/door/poddoor/pyro/shutters) || istype(O, /obj/machinery/door/unpowered/wood))
						qdel(O)
						success = TRUE
						break
				if (istype(O, /obj/machinery/computer))
					if (istype(O, /obj/machinery/computer/card/portable) || istype(O, /obj/machinery/computer/security/wooden_tv) || istype(O, /obj/machinery/computer/secure_data/detective_computer) || istype(O, /obj/machinery/computer/airbr) || istype(O, /obj/machinery/computer/tanning) || istype(O, /obj/machinery/computer/tour_console) || istype(O, /obj/machinery/computer/arcade) || istype(O, /obj/machinery/computer/tetris))
						break
				if (istype(O, /obj/machinery/light/lamp) || istype(O, /obj/machinery/computer3/generic/personal) || istype(O, /obj/machinery/computer3/luggable))
					break
			var/dir = O.dir
			var/replacementPath = flock_conversion_paths[keyPath]
			var/obj/converted = new replacementPath(T, null, O)
			// if the object is a closet, it might not have spawned its contents yet
			// so force it to do that first
			if(istype(O, /obj/storage))
				var/obj/storage/S = O
				if(!isnull(S.spawn_contents))
					S.make_my_stuff()
			// if the object has contents, move them over!!
			for (var/obj/stored_obj in O)
				stored_obj.set_loc(converted)
				if(fancy)
					stored_obj.color = fancy_flock_matrix
			for (var/mob/M in O)
				M.set_loc(converted)
			qdel(O)
			converted.set_dir(dir)
			animate_flock_convert_complete(converted)
			success = TRUE
			break
		if(!success && fancy)
			O.color = fancy_flock_matrix
	return T

/proc/mass_flock_convert_turf(var/turf/T, datum/flock/F, force=FALSE, radius=15, delay=0.2 SECONDS, fancy=FALSE)
	if(!T)
		T = get_turf(usr)
	if(!T)
		return

	flock_spiral_conversion(T, F, radius=radius, delay=delay, force=force, fancy=fancy)

/proc/flock_spiral_conversion(turf/T, datum/flock/F, radius = 15, delay = 0.2 SECONDS, tutorial=FALSE, force=FALSE, fancy=FALSE)
	if(!T) return
	// spiral algorithm adapted from https://stackoverflow.com/questions/398299/looping-in-a-spiral
	var/ox = T.x
	var/oy = T.y
	var/x = 0
	var/y = 0
	var/z = T.z
	var/dx = 0
	var/dy = -1
	var/temp = 0

	while(isturf(T) && x <= radius)
		if((istype(T, /turf/simulated) || force) && !isfeathertile(T))
			if (F)
				F.claimTurf(flock_convert_turf(T, tutorial))
			else
				flock_convert_turf(T, tutorial=tutorial, force=force, fancy=fancy)
			sleep(delay)
		LAGCHECK(LAG_LOW)
		// figure out where next turf is
		if (x == y || (x < 0 && x == -y) || (x > 0 && x == 1-y))
			temp = dx
			dx = -dy
			dy = temp
		x += dx
		y += dy
		// get next turf
		T = locate(ox + x, oy + y, z)
