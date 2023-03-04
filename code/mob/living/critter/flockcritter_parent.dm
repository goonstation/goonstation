/mob/living/critter/flock
	var/resources = 0
	name = "concept of a bird machine"
	desc = "Well, that's a thing."
	icon = 'icons/misc/featherzone.dmi'
	density = FALSE
	say_language = "feather"
	voice_name = "synthetic chirps"
	speechverb_say = "chirps"
	speechverb_exclaim = "screeches"
	speechverb_ask = "inquires"
	speechverb_gasp = "clatters"
	speechverb_stammer = "buzzes"
	custom_gib_handler = /proc/flockdronegibs
	custom_vomit_type = /obj/decal/cleanable/flockdrone_debris/fluid
	mat_appearances_to_ignore = list("gnesis")
	mat_changename = FALSE
	mat_changedesc = FALSE
	see_invisible = INVIS_FLOCK
	// HEALTHS
	health_brute = 1
	health_burn = 1
	var/repair_per_resource

	metabolizes = FALSE // under assumption drones dont metabolize chemicals due to gnesis internals
	//base compute provided
	var/compute = 0
	// if we're extinguishing ourselves don't extinguish ourselves repeatedly
	var/extinguishing = FALSE
	// FLOCK-SPECIFIC STUFF
	var/datum/flock/flock

	var/mob/living/intangible/flock/controller = null

	var/atom/movable/name_tag/flock_examine_tag/flock_name_tag

	// do i pay for building?
	var/pays_to_construct = TRUE

	is_npc = TRUE

	use_stamina = FALSE

	can_lie = FALSE
	blood_id = "flockdrone_fluid"

/mob/living/critter/flock/setup_healths()
	var/datum/healthHolder/brute = src.add_health_holder(/datum/healthHolder/flesh_flock)
	brute.value = src.health_brute
	brute.maximum_value = src.health_brute
	brute.last_value = src.health_brute
	brute.damage_multiplier = 1.2

	var/datum/healthHolder/burn = src.add_health_holder(/datum/healthHolder/flesh_burn_flock)
	burn.value = src.health_burn
	burn.maximum_value = src.health_burn
	burn.last_value = src.health_burn
	burn.damage_multiplier = 0.4

/mob/living/critter/flock/New(var/atom/L, var/datum/flock/F=null)
	..()
	remove_lifeprocess(/datum/lifeprocess/radiation)
	setMaterial(getMaterial("gnesis"), copy = FALSE)
	src.material.setProperty("reflective", 5)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_AI_UNTRACKABLE, src)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION, src)

	// do not automatically set up a flock if one is not provided
	// flockless drones act differently
	src.flock = F
	// wait for like one tick for the unit to set up properly before registering
	SPAWN(1 DECI SECOND)
		if(!isnull(src.flock))
			src.flock.registerUnit(src)

	src.update_health_icon()

/mob/living/critter/flock/proc/describe_state()
	var/list/state = list()
	state["update"] = "flockcritter"
	state["ref"] = "\ref[src]"
	state["name"] = src.name
	state["health"] = round(src.get_health_percentage()*100)
	state["resources"] = src.resources
	var/area/myArea = get_area(src)
	if(isarea(myArea))
		state["area"] = myArea.name
	else
		state["area"] = "???"
	return state

/mob/living/critter/flock/get_examine_tag(mob/examiner)
	if (isdead(src) || !src.flock || !(istype(examiner, /mob/living/intangible/flock) || istype(examiner, /mob/living/critter/flock/drone)))
		return ..()
	if (istype(examiner, /mob/living/intangible/flock))
		var/mob/living/intangible/flock/flock_intangible = examiner
		if (src.flock != flock_intangible.flock)
			return ..()
	if (istype(examiner, /mob/living/critter/flock/drone))
		var/mob/living/critter/flock/drone/flockdrone = examiner
		if (src.flock != flockdrone.flock)
			return ..()
	return src.flock_name_tag

/mob/living/critter/flock/hand_attack(atom/target, params)
	var/datum/handHolder/HH = get_active_hand()
	if (HH.can_attack && !HH.can_hold_items && ismob(target) && src.a_intent == INTENT_GRAB)
		var/datum/limb/L = src.equipped_limb()
		L.grab(target, src)
	. = ..()
	if (istype(target, /obj/item) && target.loc == src) //no batong for radio birds
		target.emp_act()

//trying out a world where you can't stun flockdrones
/mob/living/critter/flock/do_disorient(stamina_damage, weakened, stunned, paralysis, disorient, remove_stamina_below_zero, target_type, stack_stuns)
	src.changeStatus("slowed", max(weakened, stunned, paralysis, disorient))

/mob/living/critter/flock/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	..()
	src.update_health_icon()

/mob/living/critter/flock/proc/dormantize()
	src.dormant = TRUE
	src.ai?.die()
	actions.stop_all(src)
	src.is_npc = FALSE
	src.flock_name_tag.set_name(src.name)
	src.flock_name_tag.set_info_tag(he_or_she(src))
	if (!src.flock)
		return

	src.update_health_icon()
	src.flock.removeDrone(src)

/mob/living/critter/flock/projCanHit(datum/projectile/P)
	if (istype(P, /datum/projectile/energy_bolt/flockdrone))
		return FALSE
	if (!isalive(src)) //we cant_lie but still want to have projectiles act as if we are lying when dead
		return prob(P.hit_ground_chance)
	return ..()

/mob/living/critter/flock/bullet_act(var/obj/projectile/P)
	if(istype(P.proj_data, /datum/projectile/energy_bolt/flockdrone))
		src.visible_message("<span class='notice'>[src] harmlessly absorbs [P].</span>")
		return FALSE
	..()
	return TRUE

//compute - override if behaviour is weird
/mob/living/critter/flock/proc/compute_provided()
	return src.compute

// can we afford the resource cost of a thing?
/mob/living/critter/flock/proc/can_afford(var/resources)
	return (!src.pays_to_construct) || (src.pays_to_construct && src.resources >= resources)

/mob/living/critter/flock/proc/pay_resources(var/amount)
	if(!src.pays_to_construct)
		return
	src.resources -= amount

/mob/living/critter/flock/say(message, involuntary = FALSE)
	if(isdead(src) && src.is_npc)
		return
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	..(message) // caw at the non-drones

	if (message == "" || stat)
		return
	if (dd_hasprefix(message, "*"))
		return

	var/prefixAndMessage = separate_radio_prefix_and_message(message)
	message = prefixAndMessage[2]

	flock_speak(src, message, src.flock, involuntary)

/mob/living/critter/flock/understands_language(var/langname)
	if (langname == say_language || langname == "feather" || langname == "english")
		return TRUE
	return FALSE

/mob/living/critter/flock/Life(datum/controller/process/mobs/parent)
	if (..(parent) || isdead(src))
		return TRUE

	// automatic extinguisher! after some time, anyway
	if(getStatusDuration("burning") > 0 && !src.extinguishing)
		playsound(src, 'sound/weapons/rev_flash_startup.ogg', 40, 1, -3)
		boutput(src, "<span class='flocksay'><b>\[SYSTEM: Fire detected in critical systems. Integrated extinguishing systems are engaging.\]</b></span>")
		src.extinguishing = TRUE
		SPAWN(5 SECONDS)
			var/obj/fire_foam/F = (locate(/obj/fire_foam) in src.loc)
			if (!F)
				F = new /obj/fire_foam
				F.set_loc(src.loc)
				SPAWN(10 SECONDS)
					qdel(F)
			playsound(src, 'sound/effects/spray.ogg', 50, 1, -3)
			update_burning(-100)
			sleep(2 SECONDS)
			src.extinguishing = FALSE

/mob/living/critter/flock/proc/update_health_icon()
	if (!src.flock)
		return

	if (isdead(src) || src.dormant || src.disposed)
		src.flock.removeAnnotation(src, FLOCK_ANNOTATION_HEALTH)
		return

	var/list/annotations = flock.getAnnotations(src)
	if (!annotations[FLOCK_ANNOTATION_HEALTH])
		src.flock.addAnnotation(src, FLOCK_ANNOTATION_HEALTH)
	var/image/annotation = annotations[FLOCK_ANNOTATION_HEALTH]
	annotation.icon_state = "hp-[round(src.get_health_percentage() * 10) * 10]"

// all flock bots should have the ability to rally somewhere (it's applicable to anything with flock AI)
/mob/living/critter/flock/proc/rally(atom/movable/target)
	if(istype(src,/mob/living/critter/flock/drone))
		var/mob/living/critter/flock/drone/D = src
		if(D.ai_paused)
			D.wake_from_ai_pause()

	if(src.is_npc)
		// tell the npc AI to go after the target
		if(src.ai)
			var/datum/aiHolder/flock/flockai = ai
			flockai.rally(target)
	else
		boutput(src, "<span class='flocksay'><b>\[SYSTEM: The flockmind requests your presence immediately.\]</b></span>")

/mob/living/critter/flock/death(var/gibbed)
	..()
	src.ai.die()
	walk(src, 0)
	src.update_health_icon()
	qdel(src.flock_name_tag)
	src.flock_name_tag = null
	if (src.flock)
		src.flock.stats.deaths++
		src.flock.removeDrone(src)
	playsound(src, 'sound/impact_sounds/Glass_Shatter_3.ogg', 50, 1)

/mob/living/critter/flock/disposing()
	if (src.flock)
		src.update_health_icon()
		src.flock.removeDrone(src)
	qdel(src.flock_name_tag)
	src.flock_name_tag = null
	..()

//////////////////////////////////////////////////////
// VARIOUS FLOCK ACTIONS
//////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////
// CONVERT ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_convert
	id = "flock_convert"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 4.5 SECONDS
	resumable = FALSE

	var/turf/simulated/target
	var/obj/decal/decal

	New(var/turf/simulated/ntarg, var/duration_i)
		..()
		if (ntarg)
			target = ntarg
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/flock/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target) || isfeathertile(target) || !F.can_afford(FLOCK_CONVERT_COST) || !flockTurfAllowed(target))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/mob/living/critter/flock/F = owner
		if(!F || isdead(F) || !target || !in_interact_range(F, target) || isfeathertile(target) || !F.can_afford(FLOCK_CONVERT_COST) || !flockTurfAllowed(target))
			interrupt(INTERRUPT_ALWAYS)
			return

		boutput(F, "<span class='notice'>You begin spraying nanite strands onto the structure. You need to stay still for this.</span>")
		playsound(target, 'sound/misc/flockmind/flockdrone_convert.ogg', 30, 1, extrarange = -10)

		var/flick_anim = "spawn-floor"
		if(istype(target, /turf/space))
			var/make_floor = FALSE
			for (var/obj/O in target)
				if (istype(O, /obj/lattice) || istype(O, /obj/grille/catwalk))
					make_floor = TRUE
					src.decal = new /obj/decal/flock_build_floor
					flick_anim = "spawn-floor"
					break
			if (!make_floor)
				src.decal = new /obj/decal/flock_build_fibrenet
				flick_anim = "spawn-fibrenet"
		else if(istype(target, /turf/simulated/floor))
			src.decal = new /obj/decal/flock_build_floor
			flick_anim = "spawn-floor"
		else if(istype(target, /turf/simulated/wall))
			src.decal = new /obj/decal/flock_build_wall
			flick_anim = "spawn-wall"
		if(src.decal)
			src.decal.set_loc(target)
			flick(flick_anim, src.decal)

		F.flock?.reserveTurf(target, F.real_name)

	onInterrupt(var/flag)
		..()
		if(src.decal)
			qdel(src.decal)
			src.decal = null
		var/mob/living/critter/flock/F = owner
		F?.flock?.unreserveTurf(F.real_name)

	onEnd()
		..()
		if(src.decal)
			qdel(src.decal)
			src.decal = null
		var/mob/living/critter/flock/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target) || isfeathertile(target))
			return

		if(F.flock)
			F.flock.convert_turf(target, F.real_name)
		else
			flock_convert_turf(target)
		F.pay_resources(FLOCK_CONVERT_COST)

/////////////////////////////////////////////////////////////////////////////////
// CONSTRUCT ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_construct
	id = "flock_construct"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 3 SECONDS
	resumable = FALSE

	var/turf/simulated/target
	var/obj/decal/decal
	var/obj/structurepath = /obj/grille/flock


	New(var/turf/simulated/ntarg, var/structurepath_i, var/duration_i)
		..()
		if (ntarg)
			target = ntarg
		if (structurepath_i)
			structurepath = structurepath_i
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target) || !F?.can_afford(FLOCK_BARRICADE_COST) || locate(structurepath) in target)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if(!F || isdead(F) || !target || !in_interact_range(F, target) || !F?.can_afford(FLOCK_BARRICADE_COST) || locate(structurepath) in target)
			interrupt(INTERRUPT_ALWAYS)
			return

		boutput(F, "<span class='notice'>You begin weaving nanite strands into a solid structure. You need to stay still for this.</span>")
		if(duration <= 30)
			playsound(target, 'sound/misc/flockmind/flockdrone_quickbuild.ogg', 30, 1, extrarange = -10)
		else
			playsound(target, 'sound/misc/flockmind/flockdrone_build.ogg', 30, 1, extrarange = -10)

		var/flick_anim = "spawn-barricade"
		src.decal = new /obj/decal/flock_build_barricade
		if(src.decal)
			src.decal.set_loc(target)
			flick(flick_anim, src.decal)

	onInterrupt(var/flag)
		..()
		if(src.decal)
			qdel(src.decal)

	onEnd()
		..()
		if(src.decal)
			qdel(src.decal)
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target) || locate(structurepath) in target)
			return

		F.pay_resources(FLOCK_BARRICADE_COST)
		var/obj/O = new structurepath(target)
		animate_flock_convert_complete(O)
		playsound(target, 'sound/misc/flockmind/flockdrone_build_complete.ogg', 30, 1, extrarange = -10)
		O.AddComponent(/datum/component/flock_interest, F?.flock)
/////////////////////////////////////////////////////////////////////////////////
// EGG ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_egg
	id = "flock_egg"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 8 SECONDS
	resumable = FALSE

	New(var/duration_i)
		..()
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !F.flock || !F.can_afford(F.flock.current_egg_cost))
			interrupt(INTERRUPT_ALWAYS)
			return
		if(prob(40))
			animate_shake(F)
			playsound(F, pick('sound/machines/mixer.ogg', 'sound/machines/repairing.ogg', 'sound/impact_sounds/Metal_Clang_1.ogg'), 30, 1, extrarange = -10)

	onStart()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !F.flock || !F.can_afford(F.flock.current_egg_cost))
			interrupt(INTERRUPT_ALWAYS)
			return
		boutput(F, "<span class='notice'>Your internal fabricators spring into action. If you move the process will be ruined!</span>")

	onEnd()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !F.flock)
			return

		F.visible_message("<span class='alert'>[owner] deploys some sort of device!</span>", "<span class='notice'>You deploy a second-stage assembler.</span>")
		new /obj/flock_structure/egg(get_turf(F), F.flock)
		playsound(F, 'sound/impact_sounds/Metal_Clang_1.ogg', 30, 1, extrarange = -10)
		F.pay_resources(F.flock.current_egg_cost)

/////////////////////////////////////////////////////////////////////////////////
// REPAIR ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_repair
	id = "flock_repair"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 1 SECOND
	resumable = FALSE
	color_success = "#4444FF"

	var/atom/target

	New(var/atom/ntarg, var/duration_i)
		..()
		if (ntarg)
			target = ntarg
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/flock/drone/F = owner
		var/mob/living/critter/flock/C = target
		if (!F || isdead(F) || !target || (istype(C) && isdead(C)) || !in_interact_range(F, target) || F.resources <= 0)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/mob/living/critter/flock/drone/F = owner
		var/mob/living/critter/flock/C = target
		if(!F || isdead(F) || !target || (istype(C) && isdead(C)) || !in_interact_range(F, target) || F.resources <= 0)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(istype(C))
			F.tri_message(C, "<span class='notice'>[F] begins spraying glowing fibers onto [C].</span>",
				"<span class='notice'>You begin repairing [C.real_name]. You will both need to stay still for this to work.</span>",
				"<span class='notice'>[F.real_name] begins repairing you. You will both need to stay still for this to work.</span>",
				"You hear hissing and spraying.")
			if (C.is_npc)
				C.ai.wait()
		else
			F.visible_message("<span class='notice'>[F] begins spraying glowing fibers onto [target].</span>",
				"<span class='notice'>You begin repairing [target]. You will need to stay still for this to work.</span>",
				"You hear hissing and spraying.")
		playsound(target, 'sound/misc/flockmind/flockdrone_quickbuild.ogg', 30, 1, extrarange = -10)

	onEnd()
		..()
		var/mob/living/critter/flock/drone/F = owner
		var/mob/living/critter/flock/C = target
		if(!F || isdead(F) || !target || (istype(C) && isdead(C)) || !in_interact_range(F, target) || F.resources <= 0)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/keep_repairing = FALSE
		if (istype(target, /mob/living/critter/flock))
			var/mob/living/critter/flock/flockcritter = target
			var/health_given = min(min(F.resources, FLOCK_REPAIR_COST) * flockcritter.repair_per_resource, clamp(1 - flockcritter.get_health_percentage(), 0, 1) * (flockcritter.health_brute + flockcritter.health_burn))
			if(health_given)
				var/datum/healthHolder/brute = flockcritter.healthlist["brute"]
				var/brute_weight = min((brute.value > 0 ? brute.maximum_value - brute.value : brute.maximum_value + abs(brute.value)) / health_given, 1)
				var/burn_weight = 1 - brute_weight

				flockcritter.HealDamage("All", health_given * brute_weight, health_given * burn_weight)
				F.pay_resources(ceil(health_given / flockcritter.repair_per_resource))
				keep_repairing = flockcritter.get_health_percentage() < 1
			if (flockcritter.is_npc)
				flockcritter.ai.interrupt()
		else if (istype(target, /obj/flock_structure))
			var/obj/flock_structure/structure = target
			F.pay_resources(structure.repair(F.resources))
			keep_repairing = structure.health < structure.health_max
		else
			switch (target.type)
				if (/obj/machinery/door/feather)
					var/obj/machinery/door/feather/flockdoor = target
					F.pay_resources(flockdoor.repair(F.resources))
					keep_repairing = flockdoor.health < flockdoor.health_max
				if (/turf/simulated/floor/feather)
					var/turf/simulated/floor/feather/floor = target
					F.pay_resources(floor.repair(F.resources))
					keep_repairing = floor.health < initial(floor.health)
				if (/turf/simulated/wall/auto/feather)
					var/turf/simulated/wall/auto/feather/wall = target
					F.pay_resources(wall.repair(F.resources))
					keep_repairing = wall.health < wall.max_health
				if (/obj/window/feather)
					var/obj/window/feather/window = target
					F.pay_resources(window.repair(F.resources))
					keep_repairing = window.health < window.health_max
				if (/obj/window/auto/feather)
					var/obj/window/auto/feather/window = target
					F.pay_resources(window.repair(F.resources))
					keep_repairing = window.health < window.health_max
				if (/obj/grille/flock)
					var/obj/grille/flock/barricade = target
					F.pay_resources(barricade.repair(F.resources))
					keep_repairing = barricade.health < barricade.health_max
				if (/obj/storage/closet/flock)
					var/obj/storage/closet/flock/closet = target
					F.pay_resources(closet.repair(F.resources))
					keep_repairing = closet.health_attack < closet.health_max
				else
					return

		if (keep_repairing && F.resources > 0)
			src.onRestart()

/////////////////////////////////////////////////////////////////////////////////
// ENTOMB ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_entomb
	id = "flock_entomb"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 4 SECONDS
	resumable = FALSE

	var/atom/target
	var/obj/decal/decal

	New(var/atom/ntarg, var/duration_i)
		..()
		if (ntarg)
			target = ntarg
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target) || !istype(target.loc, /turf))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(target)
			var/mob/living/critter/flock/F = owner
			if(F)
				F.tri_message(target, "<span class='notice'>[owner] begins forming a cuboid structure around [target].</span>",
						"<span class='notice'>You begin imprisoning [target]. You will need to stay still for this to work.</span>",
						"<span class='alert'>[F] is forming a structure around you!</span>",
						"You hear strange building noises.")
				if(istype(target,/mob/living))
					var/mob/living/M = target
					M.was_harmed(F, null, "flock", INTENT_DISARM)

		playsound(target, 'sound/misc/flockmind/flockdrone_build.ogg', 30, 1, extrarange = -10)

	onInterrupt()
		..()
		if(src.decal)
			qdel(src.decal)

	onEnd()
		..()
		if(src.decal)
			qdel(src.decal)
		var/mob/living/critter/flock/drone/F = owner
		if(!F || isdead(F) || !target || !in_interact_range(F, target) || !istype(target.loc, /turf))
			return

		var/obj/flock_structure/cage/cage = new /obj/flock_structure/cage(target.loc, target, F.flock)
		F.flock?.flockmind?.tutorial?.PerformSilentAction(FLOCK_ACTION_CAGE)
		cage.visible_message("<span class='alert'>[cage] forms around [target], entombing them completely!</span>")
		playsound(target, 'sound/misc/flockmind/flockdrone_build_complete.ogg', 70, 1)
		logTheThing(LOG_COMBAT, owner, "entombs [constructTarget(target)] in a flock cage at [log_loc(owner)]")

///
//decon action
///
/datum/action/bar/flock_decon
	id = "flock_decon"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 60
	resumable = FALSE

	var/atom/target

	New(var/atom/ntarg, var/duration_i)
		..()
		if (ntarg)
			target = ntarg
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target))
			interrupt(INTERRUPT_ALWAYS)
			return
		F.visible_message("<span class='alert'>[F] begins deconstructing [target].</span>")

	onInterrupt()
		..()

	onEnd()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target))
			return

		if(istype(target, /obj/storage/closet/flock))
			var/obj/storage/closet/flock/closet = target
			closet.deconstruct()
		else if(istype(target, /turf/simulated/wall/auto/feather))
			var/turf/simulated/wall/auto/feather/f = target
			f.deconstruct()
		else if(istype(target, /obj/machinery/door/feather))
			var/obj/machinery/door/feather/door = target
			door.deconstruct()
		else if(istype(target, /obj/table/flock))
			var/obj/table/flock/f = target
			playsound(f, 'sound/items/Deconstruct.ogg', 30, 1, extrarange = -10)
			f.deconstruct()
		else if(istype(target, /obj/flock_structure))
			var/obj/flock_structure/f = target
			f.deconstruct()
		else if(istype(target, /obj/stool/chair/comfy/flock))
			var/obj/stool/chair/comfy/flock/c = target
			c.deconstruct()
		else if(istype(target, /obj/machinery/light/flock))
			var/obj/machinery/light/flock/l = target
			l.deconstruct()
		else if(istype(target, /obj/lattice/flock))
			qdel(target)
		else if(istype(target, /obj/grille/flock))
			qdel(target)
		else if(istype(target, /obj/window/feather) || istype(target, /obj/window/auto/feather))
			var/obj/window/the_window = target
			//copied wholesale from the /obj/window deconstruction code
			var/obj/item/sheet/A = new /obj/item/sheet(get_turf(the_window))
			if(the_window.material)
				A.setMaterial(the_window.material)
			else
				var/datum/material/M = getMaterial("glass")
				A.setMaterial(M)
			if(!(the_window.dir in cardinal)) // full window takes two sheets to make
				A.amount += 1
			if(the_window.reinforcement)
				A.set_reinforcement(the_window.reinforcement)
			qdel(the_window)
//
//deposit action
//

/datum/action/bar/flock_deposit
	id = "flock_repair"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/const/default_duration = 1 SECOND
	duration = default_duration
	resumable = FALSE
	color_success = "#4444FF"
	var/obj/flock_structure/ghost/target = null

	New(var/obj/flock_structure/ghost/target, var/duration = default_duration)
		..()
		src.target = target
		src.duration = duration

	onUpdate()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		playsound(target, 'sound/misc/flockmind/flockdrone_quickbuild.ogg', 50, 1)

	onEnd()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (!F || isdead(F) || !target || !in_interact_range(F, target))
			return

		F.visible_message("<span class='alert'>[F] deposits materials to the [target]!</span>", "<span class='notice'>You deposit materials to the tealprint</span>")
		var/amounttopay = 0
		var/difference = target.goal - target.currentmats
		amounttopay = min(F.resources, difference, FLOCK_GHOST_DEPOSIT_AMOUNT)
		F.pay_resources(amounttopay)
		target.add_mats(amounttopay)
		if(F.resources)
			src.onRestart() //restart the action akin to automenders

// flock health holders

/datum/healthHolder/flesh_flock
	name = "brute"
	associated_damage_type = "brute"

/datum/healthHolder/flesh_burn_flock
	name = "burn"
	associated_damage_type = "burn"
