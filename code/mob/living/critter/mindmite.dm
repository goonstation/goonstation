/mob/living/critter/mindmite
	name = "mindmite"
	desc = "Some sort of mite. You can't tell whether it's part of your own mind or something conjured from the Intruder's realm. It's real though."
	icon_state = ""
	color = "#923fff"

	hand_count = 1

	health_brute = 5
	health_burn = 5
	health_brute_vuln = 1
	health_burn_vuln = 1

	ai_type = /datum/aiHolder/mindmite
	is_npc = TRUE

	faction = list(FACTION_NEUTRAL)
	use_stamina = FALSE
	has_genes = FALSE

	event_handler_flags = MOVE_NOCLIP // phases through things

	var/mob/living/carbon/human/target_mob
	var/datum/ailment/mindmites/mindmites_ailment
	var/image/hidden_appearance

	New(turf/newLoc, datum/appearanceHolder/AH_passthru, datum/preferences/init_preferences, ignore_randomizer=FALSE, role_for_traits, mob/target_mob, datum/ailment/mindmites/mindmites_ailment)
		..()
		src.target_mob = target_mob
		src.mindmites_ailment = mindmites_ailment

		remove_lifeprocess(/datum/lifeprocess/organs)
		remove_lifeprocess(/datum/lifeprocess/blindness)

		src.hidden_appearance = image('icons/misc/critter.dmi', src, "roach")
		src.hidden_appearance.alpha = 0
		animate(src.hidden_appearance, alpha = 255, time = 1 SECOND)

		get_image_group(CLIENT_IMAGE_GROUP_MINDMITE_VISION).add_image(src.hidden_appearance)

	Life(datum/controller/process/mobs/parent)
		..()
		if (QDELETED(src))
			return
		if (src.z != src.target_mob.z || !istype(src.target_mob.loc, /turf) || GET_DIST(src, src.target_mob) > 50) // person is on another z level or inside closet or something
			qdel(src)
		else if (!length(get_path_to(src, src.target_mob, 0))) // cases like person walling themselves off, moves through obstacles
			step_towards(src, src.target_mob, 32)

	death()
		..()
		qdel(src)

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_MINDMITE_VISION).remove_image(src.hidden_appearance)
		QDEL_NULL(src.hidden_appearance)
		src.target_mob = null
		src.mindmites_ailment.active_mindmites -= src
		src.mindmites_ailment = null
		..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/mindmite
		HH.name = "mindmite paw"
		HH.limb_name = HH.name
		HH.can_hold_items = FALSE

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	is_spacefaring()
		return TRUE

	seek_target()
		return list(src.target_mob)

/datum/limb/small_critter/mindmite
	dam_low = 0
	dam_high = 0
	actions = list("bites", "bites", "bites", "bites")
	sound_attack = 'sound/impact_sounds/Flesh_Tear_3.ogg'
	dmg_type = DAMAGE_CRUSH
	stam_damage_mult = 0

	harm(mob/target, mob/living/user, no_logs)
		..()
		var/pick = rand(1, 4)
		switch (pick)
			if (1)
				target.take_brain_damage(1)
			if (2)
				target.TakeDamage("All", 1)
			if (3)
				target.TakeDamage("All", burn = 1)
			if (4)
				target.TakeDamage("All", tox = 1)
