/datum/targetable/vampire/vampire_scream
	name = "Chiropteran Screech"
	desc = "Deafens nearby foes, smashes windows and lights. Blocked by ear protection."
	icon_state = "screech"
	cooldown = 30 SECONDS
	pointCost = 60
	not_when_in_an_object = FALSE
	incapacitation_restriction = ABILITY_CAN_USE_WHEN_STUNNED
	var/duration = 10 SECONDS
	can_cast_while_cuffed = TRUE
	unlock_message = "You have gained chiropteran screech. It deafens nearby foes, damages windows and lights."
	var/level = 1

	cast(mob/target)
		var/mob/living/user = holder.owner
		var/turf/T = get_turf(user)

		playsound(user, 'sound/effects/screech_tone.ogg', 90, 1, pitch = 1)

		var/obj/itemspecialeffect/screech/E = new /obj/itemspecialeffect/screech
		E.color = "#FFFFFF"
		E.setup(T)

		var/screech_color
		if (level == 2)
			screech_color = "#AAAAFF"
			for (var/obj/O in orange(3, T))
				if (istype(O, /obj/item/device/radio))
					O.emp_act()
		else
			screech_color = "#FFFFFF"

		// we do 2 of these? ok
		SPAWN(0.1 SECONDS)
			var/obj/itemspecialeffect/screech/EE = new /obj/itemspecialeffect/screech
			EE.color = screech_color
			EE.setup(T)

		for (var/mob/living/hearer in ohearers(user, null))
			if (level == 2)
				OTHER_START_TRACKING_CAT(user, TR_CAT_RADIO_JAMMERS)
				SPAWN(src.duration)
					if (user in by_cat[TR_CAT_RADIO_JAMMERS])
						OTHER_STOP_TRACKING_CAT(user, TR_CAT_RADIO_JAMMERS)

			if (isvampire(hearer) && hearer.check_vampire_power(3))
				boutput(hearer, "<span class='notice'>You are immune to [user]'s screech!</span>")
				continue
			if (hearer.traitHolder.hasTrait("training_chaplain"))
				boutput(hearer, "<span class='notice'>[user]'s scream only strengthens your resolve!</span>")
				JOB_XP(hearer, "Chaplain", 2)
				continue

			hearer.apply_sonic_stun(0, 0, 40, 0, 50, 8, 12)

		sonic_attack_environmental_effect(user, 2, list("light", "window", "r_window"))

		logTheThing(LOG_COMBAT, user, "uses chiropteran screech at [log_loc(user)].")
		return FALSE

	castcheck(atom/target)
		. = ..()
		var/mob/living/user = src.holder.owner
		if (user.wear_mask && istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
			boutput(user, "<span class='alert'>How do you expect this to work? You're muzzled!</span>")
			user.visible_message("<span class='alert'><b>[user]</b> makes a loud noise.</span>")
			return FALSE // Cooldown because spam is bad.

/datum/targetable/vampire/vampire_scream/mk2
	name = "Chiropteran Screech Mk2"
	desc = "Deafens nearby foes, silences radios, smashes windows and lights. Blocked by ear protection."
	unlock_message = "Your Chiropteran Screech power disables nearby radios in addition to its original effect."
	level = 2
