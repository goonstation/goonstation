/mob/living/critter/brullbar
	name = "brullbar"
	real_name = "brullbar"
	desc = "Oh god."
	density = 1
	icon_state = "brullbar"
	icon_state_dead = "brullbar-dead"
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	blood_id = "beff"
	burning_suffix = "humanoid"
	health_brute = 70
	health_brute_vuln = 0.7
	health_burn = 70
	health_burn_vuln = 1.2
	ai_type = /datum/aiHolder/brullbar
	is_npc = TRUE

	on_pet()
		if(..())
			return 1
		if(prob(20) && !ON_COOLDOWN(src, "playsound", 3 SECONDS))
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
		src.add_stam_mod_max("brullbar", 60)
		abilityHolder.addAbility(/datum/targetable/critter/fadeout/brullbar)
		abilityHolder.addAbility(/datum/targetable/critter/tackle)
		abilityHolder.addAbility(/datum/targetable/critter/frenzy)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	seek_target(var/range = 7)
		. = list()
		for (var/mob/living/C in hearers(range, src))
			if (isintangible(C)) continue //don't attack what you can't touch
			if (istype(C, /mob/living/critter/brullbar)) continue //don't kill other brullbars
			. += C

		if(length(.) && prob(20))
			playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 75, 1)
			src.visible_message("<span class='alert'><B>[src]</B> roars!</span>")

	critter_attack(var/mob/target)
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(/datum/targetable/critter/frenzy)
		if(isdead(target))
			if (prob(30))
				src.visible_message("<span class='alert'><b>[src] devours [target]! Holy shit!</b></span>")
				playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				if (ishuman(target)) new /obj/decal/fakeobjects/skeleton(target.loc)
				target.ghostize()
				target.gib()
				return
			else
				src.visible_message("<span class='alert'<b>[src] tears a chunk out of [target] and eats it!</b></span>")
				return
		if (!frenzy.disabled && frenzy.cooldowncheck() && prob(30))
			frenzy.handleCast(target)
			return
		else
			return ..()

	can_critter_attack()
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(/datum/targetable/critter/frenzy)
		return can_act(src,TRUE) && !frenzy.disabled


/mob/living/critter/brullbar/king
	name = "brullbar king"
	real_name = "brullbar king"
	desc = "You should run."
	icon_state = "brullbarking"
	health_brute = 250
	health_brute_vuln = 0.7
	health_burn = 250
	health_burn_vuln = 1.2

	New()
		..()
		src.add_stam_mod_max("brullbarking", 120)
