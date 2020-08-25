/mob/living/critter/flock
	var/resources = 0
	name = "concept of a bird machine"
	desc = "Well, that's a thing."
	icon = 'icons/misc/featherzone.dmi'
	density = 0
	say_language = "feather"
	voice_name = "synthetic chirps"
	see_invisible = 9
	speechverb_say = "chirps"
	speechverb_exclaim = "screeches"
	speechverb_ask = "inquires"
	speechverb_gasp = "clatters"
	speechverb_stammer = "buzzes"
	custom_gib_handler = /proc/flockdronegibs
	custom_vomit_type = /obj/decal/cleanable/flockdrone_debris/fluid
	// HEALTHS
	var/health_brute = 1
	var/health_brute_vuln = 1.2 // glass
	var/health_burn = 1
	var/health_burn_vuln = 0.2 // don't burn very well at all
	// if we're extinguishing ourselves don't extinguish ourselves repeatedly
	var/extinguishing = 0
	// FLOCK-SPECIFIC STUFF
	var/datum/flock/flock
	// this body sucks i want a different one
	var/mob/living/intangible/flock/controller = null
	// do i pay for building?
	var/pays_to_construct = 1
	// AI STUFF
	is_npc = 1

	use_stamina = 0 //haha no

	can_lie = 0 // no rotate when dead

/mob/living/critter/flock/setup_healths()
	add_hh_robot(-(src.health_brute), src.health_brute, src.health_brute_vuln)
	add_hh_robot_burn(-(src.health_burn), src.health_burn, src.health_burn_vuln)

/mob/living/critter/flock/New(var/atom/L, var/datum/flock/F=null)
	..()

	// throw away the ability holder
	qdel(abilityHolder)

	// do not automatically set up a flock if one is not provided
	// flockless drones act differently
	src.flock = F
	// wait for like one tick for the unit to set up properly before registering
	SPAWN_DBG(1 DECI SECOND)
		if(!isnull(src.flock))
			src.flock.registerUnit(src)

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

// can we afford the resource cost of a thing?
/mob/living/critter/flock/proc/can_afford(var/resources)
	return (!src.pays_to_construct) || (src.pays_to_construct && src.resources >= resources)

/mob/living/critter/flock/proc/pay_resources(var/amount)
	if(!src.pays_to_construct)
		return
	src.resources -= amount

/mob/living/critter/flock/say(message, involuntary = 0)
	if(isdead(src) && src.is_npc)
		return // NO ONE CARES
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	..(message) // caw at the non-drones

	if (involuntary || message == "" || stat)
		return
	if (dd_hasprefix(message, "*"))
		return
	else if (dd_hasprefix(message, ":lh") || dd_hasprefix(message, ":rh") || dd_hasprefix(message, ":in"))
		message = copytext(message, 4)
	else if (dd_hasprefix(message, ":"))
		message = copytext(message, 3)
	else if (dd_hasprefix(message, ";"))
		message = copytext(message, 2)

	if(!src.is_npc)
		message = gradientText("#3cb5a3", "#124e43", message)
	flock_speak(src, message, src.flock)

/mob/living/critter/flock/understands_language(var/langname)
	if (langname == say_language || langname == "feather" || langname == "english")
		return 1
	return 0

// common features all flock bots get include automatic fire extinguishers
// (fire is not their weakness, guys, you just need to hit them really hard)
// (they're the anti-blob)
/mob/living/critter/flock/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	// automatic extinguisher! after some time, anyway
	if(getStatusDuration("burning") > 0 && !src.extinguishing)
		playsound(get_turf(src), "sound/weapons/rev_flash_startup.ogg", 40, 1, -3)
		boutput(src, "<span class='flocksay'><b>\[SYSTEM: Fire detected in critical systems. Integrated extinguishing systems are engaging.\]</b></span>")
		src.extinguishing = 1
		SPAWN_DBG(5 SECONDS)
			var/obj/fire_foam/F = (locate(/obj/fire_foam) in src.loc)
			if (!F)
				F = unpool(/obj/fire_foam)
				F.set_loc(src.loc)
				SPAWN_DBG(10 SECONDS)
					if (F && !F.disposed)
						pool(F)
			playsound(get_turf(src), "sound/effects/spray.ogg", 50, 1, -3)
			update_burning(-100)
			sleep(2 SECONDS)
			src.extinguishing = 0

// all flock bots should have the ability to rally somewhere (it's applicable to anything with flock AI)
/mob/living/critter/flock/proc/rally(atom/movable/target)
	if(src.is_npc)
		// tell the npc AI to go after the target
		if(src.ai)
			var/datum/aiHolder/flock/flockai = ai
			flockai.rally(target)
	else
		// tell whoever's controlling the critter to come to the flockmind, pronto
		boutput(src, "<span class='flocksay'><b>\[SYSTEM: The flockmind requests your presence immediately.\]</b></span>")

//////////////////////////////////////////////////////
// VARIOUS FLOCK ACTIONS
//////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////
// CONVERT ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_convert
	id = "flock_convert"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 45

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
		if (target == null || owner == null || get_dist(owner, target) > 1 || (F && !F.can_afford(20)))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(owner && target)
			boutput(owner, "<span class='notice'>You begin spraying nanite strands onto the structure. You need to stay still for this.</span>")
			playsound(target, "sound/misc/flockmind/flockdrone_convert.ogg", 50, 1)

			// do effect
			var/flick_anim = "spawn-floor"
			if(istype(target, /turf/simulated/floor) || istype(target, /turf/space))
				src.decal = unpool(/obj/decal/flock_build_floor)
			if(istype(target, /turf/simulated/wall))
				src.decal = unpool(/obj/decal/flock_build_wall)
				flick_anim = "spawn-wall"
			if(src.decal)
				src.decal.set_loc(target)
				flick(flick_anim, src.decal)

			var/mob/living/critter/flock/drone/F = owner
			if(F)
				if(F.flock)
					F.flock.reserveTurf(target, F.real_name)

	onInterrupt(var/flag)
		..()
		var/mob/living/critter/flock/drone/F = owner
		if(F)
			if(src.decal)
				pool(src.decal)
			if(F.flock)
				F.flock.unreserveTurf(target, F.real_name)

	onEnd()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if(F)
			if(src.decal)
				pool(src.decal)
			if(F.flock)
				F.flock.convert_turf(target, F.real_name)
			else
				flock_convert_turf(target) // bypasses any of the ownership logic
			F.pay_resources(20)

/////////////////////////////////////////////////////////////////////////////////
// CONSTRUCT ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_construct
	id = "flock_construct"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 30

	var/turf/simulated/target
	var/obj/decal/decal
	var/obj/structurepath = /obj/grille/flock
	var/cost = 25


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
		var/mob/living/critter/flock/F = owner
		if (target == null || owner == null || get_dist(owner, target) > 1 || (F && !F.can_afford(src.cost)) || locate(structurepath) in target)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(owner && target)
			boutput(owner, "<span class='notice'>You begin weaving nanite strands into a solid structure. You need to stay still for this.</span>")
			if(duration <= 30)
				playsound(target, "sound/misc/flockmind/flockdrone_quickbuild.ogg", 50, 1)
			else
				playsound(target, "sound/misc/flockmind/flockdrone_build.ogg", 50, 1)

			// do effect
			var/flick_anim = "spawn-wall"
			src.decal = unpool(/obj/decal/flock_build_wall)
			if(src.decal)
				src.decal.set_loc(target)
				flick(flick_anim, src.decal)

	onInterrupt(var/flag)
		..()
		if(src.decal)
			pool(src.decal)

	onEnd()
		..()
		if(src.decal)
			pool(src.decal)
		var/mob/living/critter/flock/drone/F = owner
		if(F)
			F.pay_resources(cost)
			var/obj/O = new structurepath(target)
			animate_flock_convert_complete(O)
			playsound(target, "sound/misc/flockmind/flockdrone_build_complete.ogg", 70, 1)

/////////////////////////////////////////////////////////////////////////////////
// EGG ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_egg
	id = "flock_egg"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 80

	New(var/duration_i)
		..()
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if (F && !F.can_afford(100))
			interrupt(INTERRUPT_ALWAYS)
			F.canmove = 1
			return
		if(F && prob(40))
			animate_shake(F)
			playsound(get_turf(F), pick("sound/machines/mixer.ogg", "sound/machines/repairing.ogg", "sound/impact_sounds/Metal_Clang_1.ogg"), 30, 1)

	onStart()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if(F)
			F.canmove = 0
		boutput(owner, "<span class='notice'>Your internal fabricators spring into action. If you move the process will be ruined!</span>")

	onEnd()
		..()
		var/mob/living/critter/flock/drone/F = owner
		if(F && F.flock)
			F.canmove = 1
			F.visible_message("<span class='alert'>[owner] deploys some sort of device!</span>", "<span class='notice'>You deploy a second-stage assembler.</span>")
			new /obj/flock_structure/egg(get_turf(F), F.flock)
			playsound(get_turf(F), "sound/impact_sounds/Metal_Clang_1.ogg", 60, 1)
			F.pay_resources(100)

/////////////////////////////////////////////////////////////////////////////////
// REPAIR ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_repair
	id = "flock_repair"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 10

	var/atom/target

	New(var/mob/living/critter/flock/drone/ntarg, var/duration_i)
		..()
		if (ntarg)
			target = ntarg
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/flock/F = owner
		if (target == null || owner == null || get_dist(owner, target) > 1 || (F && !F.can_afford(10)))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(target)
			var/mob/living/critter/flock/F = owner
			var/T = target
			var/mob/living/critter/flock/C
			if(istype(T, /mob/living/critter/flock))
				C = T
			if(F)
				if(C)
					F.tri_message("<span class='notice'>[owner] begins spraying glowing fibres onto [C].</span>",
						F, "<span class='notice'>You begin repairing [C.real_name]. You will both need to stay still for this to work.</span>",
						T, "<span class='notice'>[F.real_name] begins repairing you. You will both need to stay still for this to work.</span>",
						"You hear hissing and spraying.")
				else
					F.tri_message("<span class='notice'>[owner] begins spraying glowing fibres onto [T].</span>",
						F, "<span class='notice'>You begin repairing [T]. You will both need to stay still for this to work.</span>",
						T, "<span class='notice'>[F.real_name] begins repairing you. You will both need to stay still for this to work.</span>",
						"You hear hissing and spraying.")
				playsound(T, "sound/misc/flockmind/flockdrone_quickbuild.ogg", 50, 1)
				if(C?.is_npc)
					C.ai.wait()

	onEnd()
		..()
		var/mob/living/critter/flock/F = owner
		var/mob/living/critter/flock/T
		if(istype(target, /mob/living/critter/flock))
			T = target
		if(F)
			if(istype(target, /obj/machinery/door/feather))
//				dothin
				var/obj/machinery/door/feather/D = target
				D.health  = min(20, D.health_max - D.health) + D.health
				if(D.broken && D.health_max/2 < D.health)
					D.broken = 0 //fix the damn thing
					D.icon_state = "door1"//make it not look broke
			else
				T.HealDamage("All", T.health_brute / 3, T.health_burn / 3)
			F.pay_resources(10)

/////////////////////////////////////////////////////////////////////////////////
// ENTOMB ACTION
/////////////////////////////////////////////////////////////////////////////////

/datum/action/bar/flock_entomb
	id = "flock_entomb"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 60

	var/mob/living/target
	var/obj/decal/decal

	New(var/mob/living/ntarg, var/duration_i)
		..()
		if (ntarg)
			target = ntarg
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/flock/F = owner
		if (target == null || owner == null || get_dist(owner, target) > 1 || (F && !F.can_afford(15)))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(target)
			var/mob/living/critter/flock/F = owner
			if(F)
				F.tri_message("<span class='notice'>[owner] begins forming a cuboid structure around [target].</span>",
					F, "<span class='notice'>You begin imprisoning [target]. You will both need to stay still for this to work.</span>",
					target, "<span class='alert'>[F] is forming a structure around you!</span>",
					"You hear strange building noises.")
				// do effect
				src.decal = unpool(/obj/decal/flock_build_wall)
				if(src.decal)
					src.decal.set_loc(target)
					flick("spawn-wall", src.decal)
				playsound(get_turf(target), "sound/misc/flockmind/flockdrone_build.ogg", 50, 1)

	onInterrupt()
		..()
		if(src.decal)
			pool(src.decal)

	onEnd()
		..()
		if(src.decal)
			pool(src.decal)
		var/mob/living/critter/flock/F = owner
		if(F && target && in_range(owner, target))
			var/obj/icecube/flockdrone/cage = new /obj/icecube/flockdrone(target.loc, target, F.flock)
			cage.visible_message("<span class='alert'>[cage] forms around [target], entombing them completely!</span>")
			F.pay_resources(15)
			playsound(get_turf(target), "sound/misc/flockmind/flockdrone_build_complete.ogg", 70, 1)

///
//decon action
///
/datum/action/bar/flock_decon
	id = "flock_decon"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 60

	var/atom/target

	New(var/mob/living/ntarg, var/duration_i)
		..()
		if (ntarg)
			target = ntarg
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		if (target == null || owner == null || get_dist(owner, target) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		owner.visible_message("<span style='color:blue'>[owner] begins deconstructing [target].</span>")

	onInterrupt()
		..()

	onEnd()
		..()
		switch(target.type)
			if(/obj/storage/closet/flock)
				var/turf/T = get_turf(target)
				var/obj/storage/closet/flock/c = target
				playsound(T, "sound/impact_sounds/Glass_Shatter_3.ogg", 25, 1)
				var/obj/item/raw_material/shard/S = unpool(/obj/item/raw_material/shard)
				S.set_loc(T)
				S.setMaterial(getMaterial("gnesisglass"))
				c.dump_contents()
				qdel(target)
				target = null
			if(/turf/simulated/wall/auto/feather)
				var/turf/simulated/wall/auto/feather/f = target
				f.dismantle_wall()
			if(/obj/machinery/door/feather)
				var/turf/T = get_turf(target)
				playsound(T, "sound/impact_sounds/Glass_Shatter_3.ogg", 25, 1)
				var/obj/item/raw_material/shard/S = unpool(/obj/item/raw_material/shard)
				S.set_loc(T)
				S.setMaterial(getMaterial("gnesisglass"))
				S = unpool(/obj/item/raw_material/shard)
				S.set_loc(T)
				S.setMaterial(getMaterial("gnesis"))
				qdel(target)
				target = null
			if(/obj/table/flock, /obj/table/flock/auto)
				var/obj/table/flock/f = target
				playsound(get_turf(f), "sound/items/Deconstruct.ogg", 50, 1)
				f.deconstruct()
