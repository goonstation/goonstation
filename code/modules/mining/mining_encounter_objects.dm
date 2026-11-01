/obj/flock_encounter_pedestal
	name = "mysterious pedestal"
	desc = "Some sort of pedestal. Maybe it can be interacted with?"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "pedestal-off"
	anchored = ANCHORED_ALWAYS
	density = TRUE
	var/obj/machinery/door/feather/invincible/connected_door
	var/list/adjacent_pedestals
	var/on = FALSE

	attack_hand(mob/user)
		..()
		src.toggle(user)

	proc/toggle(mob/user, recursion_check = FALSE)
		src.on = !src.on
		src.icon_state = src.on ? "pedestal-on" : "pedestal-off"
		src.connected_door.check_puzzle_solved()
		if (recursion_check)
			return
		for (var/obj/flock_encounter_pedestal/pedestal as anything in src.adjacent_pedestals)
			pedestal.toggle(null, TRUE)
		if (src.on)
			boutput(user, SPAN_NOTICE("You activate [src]!"))
		else
			boutput(user, SPAN_NOTICE("You deactivate [src]!"))

	disposing()
		..()
		src.connected_door = null
		src.adjacent_pedestals = null

/obj/machinery/door/feather/invincible
	name = "strong imposing wall"
	health = INFINITY
	health_max = INFINITY
	hardened = TRUE
	autoclose = FALSE
	var/list/pedestals = list()

	New()
		..()
		src.desc += " This looks quite tough, you probably won't be able to break it down!"

		SPAWN(5 SECONDS) // to give it enough time for the map loader to load the prefab in
			var/turf/pedestal_1_loc = locate(src.x, src.y + 4, src.z)
			var/turf/pedestal_2_loc = locate(src.x + 3, src.y + 1, src.z)
			var/turf/pedestal_3_loc = locate(src.x, src.y - 2, src.z)
			var/turf/pedestal_4_loc = locate(src.x - 3, src.y + 1, src.z)

			var/obj/flock_encounter_pedestal/pedestal_1 = locate(/obj/flock_encounter_pedestal) in pedestal_1_loc
			pedestal_1.connected_door = src
			src.pedestals += pedestal_1
			var/obj/flock_encounter_pedestal/pedestal_2 = locate(/obj/flock_encounter_pedestal) in pedestal_2_loc
			pedestal_2.connected_door = src
			src.pedestals += pedestal_2
			var/obj/flock_encounter_pedestal/pedestal_3 = locate(/obj/flock_encounter_pedestal) in pedestal_3_loc
			pedestal_3.connected_door = src
			src.pedestals += pedestal_3
			var/obj/flock_encounter_pedestal/pedestal_4 = locate(/obj/flock_encounter_pedestal) in pedestal_4_loc
			pedestal_4.connected_door = src
			src.pedestals += pedestal_4

			pedestal_1.adjacent_pedestals = list(pedestal_2, pedestal_4)
			pedestal_2.adjacent_pedestals = list(pedestal_1, pedestal_3)
			pedestal_3.adjacent_pedestals = list(pedestal_2, pedestal_4)
			pedestal_4.adjacent_pedestals = list(pedestal_1, pedestal_3)

			shuffle_list(src.pedestals)
			for (var/i in 1 to 2)
				var/obj/flock_encounter_pedestal/pedestal = src.pedestals[i]
				pedestal.toggle(null, TRUE)

	take_damage(amount, mob/user)
		return // stop showing as broken

	disposing()
		..()
		src.pedestals = null

	allowed(mob/M)
		return FALSE

	proc/check_puzzle_solved()
		var/pedestals_on = 0
		SPAWN(0.1 SECOND) // to prevent race condition for opening the door upon making an activation and deactivation at the same time
			for (var/obj/flock_encounter_pedestal/pedestal as anything in src.pedestals)
				if (pedestal.on)
					pedestals_on++
			if (pedestals_on >= 4 && src.density)
				src.open()
			else if (pedestals_on < 4 && !src.density)
				src.close()

/obj/item/flock_converter
	name = "strange tool"
	desc = "This seems to be a tool of combined Flock, and somehow human, origin, but used for what purpose, you don't know."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flock_converter"
	var/contained_mats = 50

	New()
		..()
		src.create_inventory_counter()
		src.inventory_counter.update_number(src.contained_mats)

	attackby(obj/item/W, mob/user)
		..()
		if (istype(W, /obj/item/rcd_ammo))
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			var/obj/item/rcd_ammo/ammo = W
			src.contained_mats += ammo.matter
			qdel(ammo)
			src.inventory_counter.update_number(src.contained_mats)

	afterattack(atom/target, mob/user)
		..()
		if (!isturf(target))
			target = get_turf(target)
		if (!(istype(target, /turf/simulated) || istype(target, /turf/space)) || isfeathertile(target) || !flockTurfAllowed(target))
			return
		if (src.contained_mats < 5)
			return
		actions.start(new/datum/action/bar/flock_rcd(target, src), user)

/datum/action/bar/flock_rcd
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	duration = 5 SECONDS
	resumable = FALSE

	var/turf/simulated/target
	var/obj/item/flock_converter/converter
	var/obj/decal/decal

	New(turf/simulated/target, obj/item/flock_converter/converter)
		..()
		src.target = target
		src.converter = converter

	onStart()
		..()
		if (src.interrupt_check())
			interrupt(INTERRUPT_ALWAYS)
			return
		src.decal = start_flock_conversion(src.target)

	onUpdate()
		..()
		if (src.interrupt_check())
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(var/flag)
		..()
		QDEL_NULL(src.decal)

	onEnd()
		..()
		if (src.interrupt_check())
			interrupt(INTERRUPT_ALWAYS)
			return
		QDEL_NULL(src.decal)
		flock_convert_turf(target)
		playsound(target, 'sound/items/Deconstruct.ogg', 30, TRUE, extrarange = -10)
		if (prob(10))
			flockdronegibs(target)
		if (prob(0.5))
			new /obj/flock_structure/sentinel/angry(target)
		src.converter.contained_mats -= 5
		src.converter.inventory_counter.update_number(src.converter.contained_mats)
		src.converter = null

	proc/interrupt_check()
		var/mob/living/L = src.owner
		return QDELETED(L) || isdead(L) || isfeathertile(src.target) || !in_interact_range(L, src.target) || !flockTurfAllowed(src.target) || src.converter.contained_mats < 5
