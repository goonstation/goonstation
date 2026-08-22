// Safari animals: large, dangerous, typically unobtainable. To do: make savannah terrainify

/mob/living/critter/hippo
	name = "hippo"
	desc = "Scourge of rivers and watering holes, hippos have adapted to survive in space station swimming pools."
	icon = 'icons/misc/bigcritter.dmi'
	icon_state = "hippo"
	icon_state_dead = "hippo-dead"
	health_brute = 250
	health_burn = 250
	health_brute_vuln = 0.4
	health_burn_vuln = 0.8
	no_stamina_stuns = TRUE
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	is_npc = TRUE
	ai_type = /datum/aiHolder/hippo
	pull_w_class = W_CLASS_BULKY
	hand_count = 1
	add_abilities = list(/datum/targetable/critter/bite/hippo, /datum/targetable/critter/powerstomp)
	layer = 10

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "hippo", 40)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "hippo", 40)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY, "hippo", 20)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_DISORIENT_RESIST_BODY_MAX, "hippo", 20)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "hippo", 15)
		src.add_stam_mod_max("hippo", 100)
		src.pixel_x -= 16


	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_hands.dmi'
		HH.limb = new /datum/limb/mouth/hippo
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mouth"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/bite/hippo = src.abilityHolder.getAbility(/datum/targetable/critter/bite/hippo)
		var/datum/targetable/critter/powerstomp = src.abilityHolder.getAbility(/datum/targetable/critter/powerstomp)
		if (!hippo.disabled && hippo.cooldowncheck())
			hippo.handleCast(target)
			return TRUE
		if (!powerstomp.disabled && powerstomp.cooldowncheck())
			powerstomp.handleCast(target)
			src.emote("scream")
			return TRUE

	seek_target(var/range = 7)
		. = ..()
		if (length(.) && prob(10))
			playsound(src.loc, 'sound/voice/animal/hippo_roar.ogg', 75, 1)
			src.visible_message(SPAN_ALERT("<B>[src]</B> roars!"))
	seek_food_target(range)
		. = list()
		for (var/obj/item/item in view(range, get_turf(src)))
			//hippos are *mostly* herbivores
			if (istype(item, /obj/item/reagent_containers/food/snacks/plant))
				. += item

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/hippo_roar.ogg', 75, 1, channel=VOLUME_CHANNEL_EMOTE)
					src.visible_message(SPAN_ALERT("<B>[src]</B> roars!"))
		return null
