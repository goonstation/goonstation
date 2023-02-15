/mob/living/critter/brullbar
	name = "brullbar"
	real_name = "brullbar"
	desc = "Oh god."
	density = 1
	icon_state = "brullbar"
	icon_state_dead = "brullbar"
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	blood_id = "beff"
	burning_suffix = "humanoid"
	skinresult = /obj/item/material_piece/cloth/brullbarhide
	max_skins = 3
	health_brute = 50
	health_brute_vuln = 0.6
	health_burn = 50
	health_burn_vuln = 1.3
	ai_type = /datum/aiHolder/brullbar
	is_npc = TRUE
	var/is_king = FALSE

	on_sleep()
		..()
		var/datum/targetable/critter/fadeout = src.abilityHolder.getAbility(/datum/targetable/critter/fadeout/brullbar)
		if (!fadeout.disabled && fadeout.cooldowncheck())
			fadeout.handleCast(src)

	attackby(obj/item/W as obj, mob/living/user as mob)
		retaliate(user)
		..()

	attack_hand(var/mob/user as mob)
		if (user.a_intent != INTENT_HELP) // pets only or you get the claws, but you would get those anyway so...
			retaliate(user)
		..()

	on_pet()
		if (..())
			return 1
		if (prob(20) && !ON_COOLDOWN(src, "playsound", 3 SECONDS))
			playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 60, 1)
			src.visible_message("<span class='alert'><b>[src] laughs!</b></span>", 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/brullbar_roar.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b><span class='alert'>[src] howls!</span></b>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/suit(src)
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/brullbar
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left brullbar arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/brullbar
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right brullbar arm"

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/fadeout/brullbar)
		abilityHolder.addAbility(/datum/targetable/critter/tackle)
		abilityHolder.addAbility(/datum/targetable/critter/frenzy)
		if (src.is_king) // kings are built like tanks
			src.add_stam_mod_max("brullbar", 100)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "brullbar", 50)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "brullbar", 50)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "brullbar", 10)
		else // normal ones are still strong
			src.add_stam_mod_max("brullbar", 40)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "brullbar", 20)
			APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "brullbar", 20)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	seek_target(var/range = 7)
		if (src.lastattacker && GET_DIST(src, src.lastattacker) <= range)
			return list(src.lastattacker)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isdead(C)) continue
			if (isintangible(C)) continue //don't attack what you can't touch
			if (istype(C, /mob/living/critter/brullbar)) continue //don't kill other brullbars
			if (ishuman(C))
				var/mob/living/carbon/human/H = C
				if(!is_king && iswerewolf(H))
					src.visible_message("<span class='alert'><b>[src] backs away in fear!</b></span>")
					step_away(src, H, 15)
					src.set_dir(get_dir(src, H))
					continue
			. += C

		if (length(.) && prob(10))
			playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 75, 1)
			src.visible_message("<span class='alert'><B>[src]</B> roars!</span>")

	critter_attack(var/mob/target)
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(/datum/targetable/critter/frenzy)
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!tackle.disabled && tackle.cooldowncheck() && prob(20) && !is_incapacitated(target))
			tackle.handleCast(target) // no return to wack people with the frenzy after the tackle sometimes
		if (!frenzy.disabled && frenzy.cooldowncheck() && prob(40))
			frenzy.handleCast(target)
			return
		else
			return ..()

	critter_scavenge(var/mob/target)
		if (prob(30))
			src.visible_message("<span class='alert'><b>[src] devours [target]! Holy shit!</b></span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			new /obj/decal/fakeobjects/skeleton(target.loc)
			target.ghostize()
			target.gib()
			return
		else
			src.visible_message("<span class='alert'<b>[src] bites a chunk out of [target]!</b></span>")
			playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1)
			for(var/damage_type in src.healthlist)
				var/datum/healthHolder/hh = src.healthlist[damage_type]
				hh.HealDamage(10)
			return


	proc/retaliate(var/mob/living/attacker) // somewhat stolen from sawfly behaviour, no beating on a confused brullbar
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (prob(50) && !tackle.disabled && tackle.cooldowncheck() && !isdead(src))
			src.lastattacker = attacker
			src.visible_message("<span class='alert'><b>[src] lunges at [attacker]!</b></span>")
			playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 50, 1)
			tackle.handleCast(attacker)
			ai.interrupt()

	can_critter_attack()
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(/datum/targetable/critter/frenzy)
		return can_act(src,TRUE) && !frenzy.disabled


/mob/living/critter/brullbar/king
	name = "brullbar king"
	real_name = "brullbar king"
	desc = "You should run."
	icon_state = "brullbarking"
	icon_state_dead = "brullbarking"
	skinresult = /obj/item/material_piece/cloth/kingbrullbarhide
	max_skins = 5
	health_brute = 250
	health_brute_vuln = 0.7
	health_burn = 250
	health_burn_vuln = 1.4
	is_king = TRUE

/mob/living/critter/brullbar/strong //orginal health for admin spawns
	health_brute = 100
	health_brute_vuln = 0.7
	health_burn = 100
	health_burn_vuln = 1.4
