/mob/living/critter/mindmite
	name = "mindmite"
	desc = "Some sort of mite. You can't tell whether it's part of your own mind or something conjured from the Intruder's realm. It's real though."
	icon_state = "roach"
	color = "#923fff"

	hand_count = 1

	health_brute = 5
	health_burn = 5
	health_brute_vuln = 1
	health_burn_vuln = 1

	ai_type = /datum/aiHolder/mindmite
	is_npc = TRUE

	faction = list(FACTION_INTRUDER)
	use_stamina = FALSE
	has_genes = FALSE

	var/mob/living/carbon/human/target_mob
	var/datum/statusEffect/piercing_the_veil/associated_status

	New(turf/newLoc, datum/appearanceHolder/AH_passthru, datum/preferences/init_preferences, ignore_randomizer=FALSE, role_for_traits, mob/target_mob, datum/statusEffect/piercing_the_veil/associated_status)
		..()
		src.target_mob = target_mob
		src.associated_status = associated_status

		remove_lifeprocess(/datum/lifeprocess/organs)
		remove_lifeprocess(/datum/lifeprocess/blindness)

		src.alpha = 0
		animate(src, alpha = 255, time = 1 SECOND)

	Life(datum/controller/process/mobs/parent)
		..()
		if (QDELETED(src))
			return

	death()
		..()
		qdel(src)

	disposing()
		src.target_mob = null
		src.associated_status.active_mindmites -= src
		src.associated_status = null
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
				target.take_brain_damage(3)
			if (2)
				target.TakeDamage("All", 5)
			if (3)
				target.TakeDamage("All", burn = 5)
			if (4)
				target.TakeDamage("All", tox = 5)
