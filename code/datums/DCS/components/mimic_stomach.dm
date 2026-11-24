/datum/component/mimic_stomach
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/trap_whitelist = list(/obj/machinery/disposal, /obj/storage/)
	var/list/trap_blacklist = list(/obj/storage/closet/port_a_sci, /obj/storage/closet/extradimensional)
	var/datum/allocated_region/region
	var/turf/center
	var/obj/current_container
	/// Target for eaten limbs to be teleported to, rerolled to another turf after
	var/turf/limb_target_turf
	/// Place eaten things in here so they don't break through the stomach wall!!
	var/list/non_walls
	/// Hold the mimic's last disguise to reapply once they're out
	var/last_appearance
	var/list/obj/things_eaten
	var/mob/living/critter/mimic/antag_spawn/present_mimic

TYPEINFO(/datum/component/mimic_stomach)
	initialization_args = list(
		ARG_INFO("width", DATA_INPUT_NUM, "Dimension width", 9),
		ARG_INFO("height", DATA_INPUT_NUM, "Dimension height", 9),
	)

/datum/component/mimic_stomach/Initialize(width=9, height=9, region_init_proc=null)
	. = ..()
	region = global.region_allocator.allocate(width, height)
	if(region_init_proc)
		call(region_init_proc)(region, parent)
	else
		src.default_init_region()

/datum/component/mimic_stomach/proc/default_init_region()
	region.clean_up(/turf/unsimulated/floor/setpieces/bloodfloor)

	for (var/x in 1 to region.width)
		for (var/y in 1 to region.height)
			var/turf/T = region.turf_at(x, y)
			if (region.turf_on_border(T))
				T.ReplaceWith(/turf/unsimulated/wall/setpieces/bloodwall)
			else
				LAZYLISTADD(non_walls, T)
			var/chance = rand(1,6)
			if (chance == 3)
				make_cleanable(/obj/decal/cleanable/blood/gibs, T)
	limb_target_turf = get_turf(pick(non_walls))
	center = region.get_center()

/datum/component/mimic_stomach/proc/on_entered(mob/user)
	if (istype(user, /mob/living/critter/mimic))
		user.HealBleeding(INFINITY)
		user.HealDamage("All", user.max_health, user.max_health)

/datum/component/mimic_stomach/proc/mimic_move(mob/user, obj/target, var/exit = FALSE)
	if (!exit)
		src.current_container = target
		src.present_mimic = user
		src.present_mimic.set_loc(src.center)
		src.on_entered(user)
		RegisterSignal(src.current_container, COMSIG_ATOM_ENTERED, PROC_REF(trap_chomp))
		for (var/obj/item in src.present_mimic.contents)
			if (istype(item, /obj/item/parts/human_parts)) // I wanted to make this take any item, but ran into too many problems
				var/obj/item/parts/human_parts/limb = item
				if (limb.holder == user)
					continue
				src.add_limb(limb, FALSE)
				LAZYLISTREMOVE(src.present_mimic.contents, item)
		src.current_container.visible_message(SPAN_ALERT("<b>[src.present_mimic.name] turns themself inside out!</b>"))
	else
		for (var/obj/item in src.things_eaten)
			LAZYLISTADD(src.present_mimic.contents, item)
		src.present_mimic.set_loc(get_turf(src.current_container))
		UnregisterSignal(src.current_container, COMSIG_ATOM_ENTERED)
		src.current_container.visible_message(SPAN_ALERT("<b>[src.present_mimic.name] turns themself outside in!</b>"))
		src.current_container = null
		src.present_mimic = null

/datum/component/mimic_stomach/proc/add_limb(atom/target)
	if (!target)
		return
	var/obj/item/parts/human_parts/limb_obj
	limb_obj = target
	LAZYLISTADD(src.things_eaten, limb_obj)
	limb_obj.set_loc(src.limb_target_turf)
	limb_obj.pixel_x = rand(-12,12)
	limb_obj.pixel_y = rand(-12,12)
	src.limb_target_turf = get_turf(pick(src.non_walls))
	playsound(current_container, 'sound/voice/burp_alien.ogg', 60, 1)

/datum/component/mimic_stomach/proc/trap_chomp(atom/target, atom/user)
	var/mob/living/carbon/human/targetHuman = locate(/mob/living/carbon/human) in src.current_container
	if (!istype(user, /mob/living/carbon/human) || !targetHuman) // user is the entered thing in this case. I know
		return
	var/list/randLimbBase = list("r_arm", "r_leg", "l_arm", "l_leg")
	var/list/randLimb
	var/datum/human_limbs/torn_limb
	var/obj/item/parts/human_parts/limb_obj
	for (var/potential_limb in randLimbBase) // build a list of limbs the target actually has
		if (targetHuman.limbs.get_limb(potential_limb))
			LAZYLISTADD(randLimb, potential_limb)
	torn_limb = targetHuman.limbs.get_limb(pick(randLimb))

	if (src.present_mimic)
		if (GET_COOLDOWN(src.current_container, "mimicTrap"))
			boutput(targetHuman, SPAN_ALERT("<B>[targetHuman] narrowly avoids something biting at [him_or_her(targetHuman)] inside the [current_container]!</B>"))
			return
		if (torn_limb)
			ON_COOLDOWN(src.current_container, "mimicTrap", 5 SECONDS)
			limb_obj = torn_limb.sever(src.parent, FALSE)
			src.add_limb(limb_obj)
			boutput(targetHuman, SPAN_ALERT("Something in the [src.current_container] tears off [limb_obj]!"))
			playsound(src.current_container, 'sound/voice/burp_alien.ogg', 60, 1)
		else
			boutput(targetHuman, SPAN_ALERT("Something in the [src.current_container] bites at [targetHuman], but [he_or_she_dont_or_doesnt(targetHuman)] have limbs to eat!"))
			return

/datum/component/mimic_stomach/UnregisterFromParent()
	if (region)
		region.clean_up(/turf/space, /turf/space)
		qdel(region)
	. = ..()
