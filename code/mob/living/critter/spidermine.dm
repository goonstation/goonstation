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
		else
			// Duplication of /obj/item/old_grenade/stinger explosion
			var/turf/T = ..()
			if (T)
				playsound(T, "sound/weapons/grenade.ogg", 25, 1)
				explosion(src, T, -1, -1, -0.25, 1)
				var/obj/overlay/O = new/obj/overlay(get_turf(T))
				O.anchored = 1
				O.name = "Explosion"
				O.layer = NOLIGHT_EFFECTS_LAYER_BASE
				O.icon = 'icons/effects/64x64.dmi'
				O.icon_state = "explo_fiery"
				var/datum/projectile/special/spreader/uniform_burst/circle/PJ = new /datum/projectile/special/spreader/uniform_burst/circle(T)
				PJ.pellets_to_fire = 20
				var/targetx = src.y - rand(-5,5)
				var/targety = src.y - rand(-5,5)
				var/turf/newtarget = locate(targetx, targety, src.z)
				shoot_projectile_ST(src, PJ, newtarget)
				SPAWN_DBG(0.5 SECONDS)
					qdel(O)
					qdel(src)
			else
				qdel(src)
			return

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

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/tackle)
