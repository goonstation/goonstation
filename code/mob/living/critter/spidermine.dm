/mob/living/critter/spidermine
	name = "spidermine"
	real_name = "spidermine"
	desc = "This looks incredibly bad for your health."
	density = 1
	icon = 'icons/misc/critter.dmi'
	icon_state = "mars_sec_bot"
	custom_gib_handler = /proc/robogibs
	hand_count = 3
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	blood_id = "oil"
	metabolizes = 0

	death(var/gibbed)
		..(gibbed, 0)
		if (!gibbed)
			playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 50, 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/machines/glitch5" , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()


	setup_healths()
		add_hh_robot(-40, 40, 1)
		add_hh_robot_burn(-40, 40, 1)

	get_melee_protection(zone, damage_type)
		return 1

	get_ranged_protection()
		return 1
