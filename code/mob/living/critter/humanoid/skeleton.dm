/proc/bonegibs(turf/T, list/ejectables, bdna, btype)
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
	icon = 'icons/mob/critter/humanoid/skeleton.dmi'
	icon_state = "skeleton"
	custom_gib_handler = /proc/bonegibs
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	blood_id = "calcium"
	burning_suffix = "humanoid"
	metabolizes = FALSE
	health_brute = 25
	health_brute_vuln = 1
	health_burn = 25
	health_burn_vuln = 0.7
	mob_flags = IS_BONEY
	is_npc = TRUE
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/aggressive
	skinresult = /obj/item/material_piece/bone
	add_abilities = list(/datum/targetable/critter/tackle)
	max_skins = 3
	no_stamina_stuns = TRUE
	var/hatcount = 1
	var/revivalChance = 0 // Chance to revive when killed, out of 100. Wizard spell will set to 100, defaults to 0 because skeletons appear in telesci/other sources
	var/revivalDecrement = 20 // Decreases revival chance each successful revival. Set to 0 and revivalChance=100 for a permanently reviving skeleton

	reviving
		revivalChance = 100

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
					playsound(src, 'sound/items/Scissor.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("[src] claks!")
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
		for (var/i = 1, i <= hatcount, i++)
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

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/skeleton)) return FALSE
		return ..()

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!tackle.disabled && tackle.cooldowncheck())
			tackle.handleCast(target)
			return TRUE

	death(var/gibbed)
		if (prob(src.revivalChance))
			..()
			src.revivalChance -= src.revivalDecrement
			SPAWN(rand(40 SECONDS, 80 SECONDS))
				src.full_heal()
				src.visible_message(SPAN_ALERT("[src] re-assembles and is ready to fight once more!"))
			return
		if (!gibbed)
			src.visible_message(SPAN_ALERT("[src] explodes into bones!"))
			src.unequip_all()
			src.gib()
		return ..()

	proc/CustomiseSkeleton(var/mob/living/carbon/human/target, var/is_monkey)
		src.name = "[capitalize(target)]'s skeleton"
		src.desc = "A horrible skeleton, raised from the corpse of [target] by a wizard."
		src.revivalChance = 100
		LAZYLISTADDUNIQUE(src.faction, FACTION_WIZARD)

		if (is_monkey)
			icon = 'icons/mob/monkey.dmi'

/mob/living/critter/skeleton/multihat
	hatcount = 10

/mob/living/critter/skeleton/wraith
	desc = "It looks rather crumbly."
	icon = 'icons/mob/human_decomp.dmi'
	icon_state = "decomp4"
	health_brute = 15
	health_burn = 15

	faction = list(FACTION_WRAITH)

	death()
		particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, get_turf(src)))
		..()

/////////////////// EGG ///////////////////
/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/skeleton
	name = "skeleton egg"
	desc = "Uh. What?"
	critter_type = /mob/living/critter/skeleton
	warm_count = 5
	critter_reagent = "ash"
