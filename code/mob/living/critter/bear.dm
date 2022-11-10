/mob/living/critter/bear
	name = "space bear"
	real_name = "space bear"
	desc = "Oh god."
	density = 1
	icon_state = "abear"
	icon_state_dead = "abear-dead"
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	blood_id = "methamphetamine"
	burning_suffix = "humanoid"

	on_pet(mob/user)
		if (..())
			return 1
		user.unlock_medal("Bear Hug", 1) //new method to get since obesity is removed

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/MEraaargh.ogg', 70, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b><span class='alert'>[src] roars!</span></b>"
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
		HH.limb = new /datum/limb/bear
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left bear arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/bear
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right bear arm"

	setup_healths()
		add_hh_flesh(75, 0.85)
		add_hh_flesh_burn(75, 1.25)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/suffocation)
		add_health_holder(/datum/healthHolder/brain)

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/tackle)
