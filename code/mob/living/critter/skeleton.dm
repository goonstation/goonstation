/proc/bonegibs(turf/T, viral_list, list/ejectables, bdna, btype)
	var/list/dirlist = list(list(NORTH, NORTHEAST, NORTHWEST), \
		                    list(SOUTH, SOUTHEAST, SOUTHWEST), \
		                    list(WEST, NORTHWEST, SOUTHWEST),  \
		                    list(EAST, NORTHEAST, SOUTHEAST))

	var/list/produce = list()

	for (var/i = 1, i <= 4, i++)
		var/PT = /obj/item/material_piece/bone
		var/obj/item/material_piece/bone/P = new PT
		P.set_loc(T)
		SPAWN(0)
			for (var/k = 1, k <= 3, k++)
			P.streak_object(dirlist[i])
		produce += P

	var/extra = rand(2,4)
	for (var/i = 1, i <= extra, i++)
		var/PT = /obj/item/material_piece/bone
		var/obj/item/material_piece/bone/P  = new PT
		P.set_loc(T)
		P.streak_object(alldirs)
		produce += P

	return produce


/mob/living/critter/skeleton
	name = "skeleton"
	real_name = "skeleton"
	desc = "Clak clak, motherfucker."
	death_text = "%src% explodes into bones!"
	icon_state = "skeleton"
	icon_state_dead = "skeleton"
	custom_gib_handler = /proc/bonegibs
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	blood_id = "calcium"
	burning_suffix = "humanoid"
	metabolizes = FALSE
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 0.7
	mob_flags = IS_BONEY
	is_npc = TRUE
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/sawfly
	skinresult = /obj/item/material_piece/bone
	max_skins = 3
	var/revivalChance = 0 // Chance to revive when killed, out of 100. Wizard spell will set to 100, defaults to 0 because skeletons appear in telesci/other sources
	var/revivalDecrement = 20 // Decreases revival chance each successful revival. Set to 0 and revivalChance=100 for a permanently reviving skeleton

	New()
		..()
		playsound(src.loc, 'sound/items/Scissor.ogg', 50, 0)

	Move()
		playsound(src.loc, 'sound/impact_sounds/Crystal_Hit_1.ogg', 50, 0)
		. = ..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream", "clak")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/items/Scissor.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='alert'>[src] claks!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream", "clak")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/suit(src)
		equipment += new /datum/equipmentHolder/ears(src)
		var/list/hats = list(new /datum/equipmentHolder/head/skeleton(src))
		equipment += hats[1]
		for (var/i = 1, i <= 10, i++)
			var/datum/equipmentHolder/head/skeleton/S = hats[i]
			var/datum/equipmentHolder/head/skeleton/S1 = S.spawn_next()
			hats += S1
			equipment += S1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

	seek_target(var/range = 6)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isdead(C)) continue
			if (isintangible(C)) continue //don't attack what you can't touch
			if (istype(C, /mob/living/critter/skeleton)) continue //don't kill other brullbars
			if (iswizard(C)) continue
			. += C

	death(var/gibbed)
		if (rand(100) =< src.revivalChance)
			..()
			src.revivalChance -= src.revivalDecrement
			SPAWN(rand(400,800))
				src.full_heal()
				src.set_density(1)
				src.visible_message("<span class='alert'>[src] re-assembles and is ready to fight once more!</span>")
				return
		if (!gibbed)
			src.unequip_all()
			src.gib()
		return ..()


	proc/CustomizeSkeleton(var/mob/living/carbon/human/target, var/is_monkey)
		src.name = "[capitalize(target)]'s skeleton"
		src.desc = "A horrible skeleton, raised from the corpse of [target] by a wizard."
		src.revivalChance = 100

		if (is_monkey)
			icon = 'icons/mob/monkey.dmi'
		return

/mob/living/critter/skeleton/wraith
	desc = "It looks rather crumbly."
	icon = 'icons/mob/human_decomp.dmi'
	icon_state = "decomp4"
	death_text = "%src% vanishes into bones!"
	revivalChance = 0

	seek_target(var/range = 6)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isdead(C)) continue
			if (isintangible(C)) continue //don't attack what you can't touch
			if (islivingobject(C)) continue //don't attack wraith objects
			if (istype(C, /mob/living/critter/skeleton)) continue
			. += C

	death()
		..()
		particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, locate(x, y, z)))
		qdel(src)

/////////////////// EGG ///////////////////
/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/skeleton
	name = "skeleton egg"
	desc = "Uh. What?"
	critter_type = /mob/living/critter/skeleton
	warm_count = 5
	critter_reagent = "ash"
