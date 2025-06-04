ABSTRACT_TYPE(/datum/component/mimic_stomach)
/datum/component/mimic_stomach
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/trap_whitelist = list(/obj/machinery/disposal, /obj/storage/)
	var/datum/allocated_region/region
	var/turf/center
	var/obj/current_container
	var/turf/limb_target_turf
	var/list/non_walls
	/// Hold the mimic's last disguise to reapply once they're out
	var/last_appearance
	var/list/obj/item/parts/limbs_eaten
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
	RegisterSignal(src.parent, COMSIG_MOB_DEATH, PROC_REF(death_barf))

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
		user.HealBleeding()
		user.HealDamage("All", user.max_health, user.max_health)
	return

/datum/component/mimic_stomach/proc/mimic_move(mob/user, obj/target, var/exit = FALSE)
	if (!exit)
		src.current_container = target
		src.present_mimic = user
		src.present_mimic.set_loc(src.center)
		src.on_entered(user)
		RegisterSignal(src.current_container, COMSIG_ATOM_ENTERED, PROC_REF(add_limb))
		src.current_container.visible_message(SPAN_ALERT("<b>[src.present_mimic.name] turns themself inside out!</b>"))
	else
		src.present_mimic.set_loc(get_turf(src.current_container))
		UnregisterSignal(src.current_container, COMSIG_ATOM_ENTERED)
		src.current_container.visible_message(SPAN_ALERT("<b>[src.present_mimic.name] turns themself outside in!</b>"))
		src.current_container = null
		src.present_mimic = null

/datum/component/mimic_stomach/proc/add_limb(atom/target, var/trap = TRUE)
	if (!target)
		return
	var/datum/human_limbs/torn_limb = null
	var/obj/item/parts/human_parts/limb_obj = null
	if (ishuman(target))
		var/mob/living/carbon/human/targetHuman = target
		var/list/randLimbBase = list("r_arm", "r_leg", "l_arm", "l_leg")
		var/list/randLimb
		for (var/potential_limb in randLimbBase) // build a list of limbs the target actually has
			if (targetHuman.limbs.get_limb(potential_limb))
				LAZYLISTADD(randLimb, potential_limb)
		torn_limb = targetHuman.limbs.get_limb(pick(randLimb))
		limb_obj = torn_limb.sever()

		if (src.present_mimic)
			if (GET_COOLDOWN(src.current_container, "mimicTrap"))
				boutput(target, SPAN_ALERT("<B>You narrowly avoid something biting at you inside the [current_container]!</B>"))
				return
			if (limb_obj)
				ON_COOLDOWN(src.current_container, "mimicTrap", 5 SECONDS)
				boutput(target, SPAN_ALERT("Something in the [src.current_container] tears off [limb_obj]!"))
				playsound(src.current_container, 'sound/voice/burp_alien.ogg', 60, 1)
			else
				boutput(target, SPAN_ALERT("Something in the [src.current_container] bites at you, but you have no limbs to eat!"))
				return
	else
		if (!istype(target, /obj/item/parts/human_parts))
			boutput(src.parent, SPAN_ALERT("Doesn't look edible..."))
			return
		else
			limb_obj = target

	LAZYLISTADD(src.limbs_eaten, limb_obj)
	limb_obj.set_loc(src.limb_target_turf)
	limb_obj.pixel_x = rand(-12,12)
	limb_obj.pixel_y = rand(-12,12)
	src.limb_target_turf = get_turf(pick(src.non_walls))
	playsound(current_container, 'sound/voice/burp_alien.ogg', 60, 1)

/datum/component/mimic_stomach/proc/death_barf()
	UnregisterSignal(src.parent, COMSIG_MOB_DEATH)
	var/pitch_counter = 2
	for (var/obj/item/parts/eaten_thing in src.limbs_eaten)
		eaten_thing.set_loc(get_turf(src.parent))
		ThrowRandom(eaten_thing, 10, 2, bonus_throwforce=10)
		if (!ON_COOLDOWN(global, "burp", 1 SECONDS))
			playsound(src.parent, 'sound/voice/burp_alien.ogg', 60, 1, pitch=pitch_counter)
			if (pitch_counter >= 0)
				pitch_counter -= 0.5
		sleep(0.2 SECONDS)
	playsound(src, 'sound/voice/burp_alien.ogg', 60, 1, pitch=-2)
	src.RemoveComponent(/datum/component/mimic_stomach)

/datum/component/mimic_stomach/UnregisterFromParent()
	if (region)
		region.clean_up(/turf/space, /turf/space)
		qdel(region)
	. = ..()
