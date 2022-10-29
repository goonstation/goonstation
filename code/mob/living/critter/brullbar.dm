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
		abilityHolder.addAbility(/datum/targetable/critter/fadeout/brullbar)
		abilityHolder.addAbility(/datum/targetable/critter/tackle)
		abilityHolder.addAbility(/datum/targetable/critter/frenzy)

	setup_healths()
		add_hh_flesh(100, 0.85)
		add_hh_flesh_burn(100, 1.4)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)
