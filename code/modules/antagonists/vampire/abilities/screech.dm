/datum/targetable/vampire/vampire_scream
	name = "Chiropteran Screech"
	desc = "Deafens nearby foes, smashes windows and lights. Blocked by ear protection."
	icon_state = "screech"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 300
	pointCost = 60
	not_when_in_an_object = FALSE
	when_stunned = 1
	var/duration = 10 SECONDS
	not_when_handcuffed = 0
	unlock_message = "You have gained chiropteran screech. It deafens nearby foes, damages windows and lights."
	var/level = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		if (M.wear_mask && istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			boutput(M, SPAN_ALERT("How do you expect this to work? You're muzzled!"))
			M.visible_message(SPAN_ALERT("<b>[M]</b> makes a loud noise."))
			return 0 // Cooldown because spam is bad.

		. = ..()
		playsound(M.loc, 'sound/effects/screech_tone.ogg', 90, 1, pitch = 1)

		var/obj/itemspecialeffect/screech/E = new /obj/itemspecialeffect/screech
		E.color = "#FFFFFF"
		E.setup(M.loc)

		if (level == 2)
			//add effect
			SPAWN(1 DECI SECOND)
				var/obj/itemspecialeffect/screech/EE = new /obj/itemspecialeffect/screech
				EE.color = "#AAAAFF"
				EE.setup(M.loc)

			var/turf/T = get_turf(M)
			for (var/turf/tile in range(3, T)) //get radios
				var/i = 0
				for (var/atom/O in tile.contents)
					if (istype(O,/obj/item/device/radio))
						O.emp_act()
					i++
					if (i > 20)
						break
		else
			SPAWN(1 DECI SECOND)
				var/obj/itemspecialeffect/screech/EE = new /obj/itemspecialeffect/screech
				EE.color = "#FFFFFF"
				EE.setup(M.loc)

		for (var/mob/living/HH in hearers(M, null))
			if (HH == M) continue

			if (level == 2)
				OTHER_START_TRACKING_CAT(M, TR_CAT_RADIO_JAMMERS)
				SPAWN(src.duration)
					if (M && istype(M) && radio_controller && istype(radio_controller) && (M in by_cat[TR_CAT_RADIO_JAMMERS]))
						OTHER_STOP_TRACKING_CAT(M, TR_CAT_RADIO_JAMMERS)
			if (isvampire(HH) && HH.check_vampire_power(3) == 1)
				boutput(HH, SPAN_NOTICE("You are immune to [M]'s screech!"))
				continue
			if (HH.bioHolder && HH.traitHolder.hasTrait("training_chaplain"))
				boutput(HH, SPAN_NOTICE("[M]'s scream only strengthens your resolve!"))
				JOB_XP(HH, "Chaplain", 2)
				continue

			HH.apply_sonic_stun(0, 0, 40, 0, 50, 8, 12)

		sonic_attack_environmental_effect(M, 2, list("light", "window", "r_window"))

		logTheThing(LOG_COMBAT, M, "uses chiropteran screech at [log_loc(M)].")
		return 0

/datum/targetable/vampire/vampire_scream/mk2
	name = "Chiropteran Screech Mk2"
	desc = "Deafens nearby foes, silences radios, smashes windows and lights. Blocked by ear protection."
	unlock_message = "Your Chiropteran Screech power disables nearby radios in addition to its original effect."
	level = 2
