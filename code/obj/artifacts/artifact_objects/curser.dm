#define BLOOD_CURSE 1
#define AGING_CURSE 2
#define NIGHTMARE_CURSE 3
#define MAZE_CURSE 4
#define DISP_CURSE 5
#define LIGHT_CURSE 6

/obj/artifact/curser
	name = "artifact curser"
	associated_datum = /datum/artifact/curser

/datum/artifact/curser
	associated_object = /obj/artifact/curser
	type_name = "Curser"
	rarity_weight = 250
	validtypes = list("eldritch")
	// activation text disguises it as container, but it is covered in suspicious markings which gives it away
	activ_text = "seems like it has something inside of it..."
	deact_text = "locks back up."
	react_xray = list(2, 20, 55, 7, "HOLLOW")
	examine_hint = "It is covered in very conspicuous markings."

	effect_touch(obj/O, mob/living/user)
		..()
		// talisman check
		// if you have talisman, it wards off the curse

		var/list/mobs_nearby = list()
		for (var/mob/living/carbon/human/H in range(5, src))
			if (!H.mind)
				continue
			mobs_nearby += H
		if (length(mobs_nearby))
			var/mob/living/cursed = pick(mobs_nearby)

		// talisman check
		// if you have talisman, it wards off the curse

		var/curse = pick(BLOOD_CURSE, AGING_CURSE, NIGHTMARE_CURSE, MAZE_CURSE, DISP_CURSE, LIGHT_CURSE)
		switch (curse)
			if (BLOOD_CURSE)
				user.setStatus("art_blood_curse", 3 MINUTES)
			if (AGING_CURSE)
				user.setStatus("art_aging_curse", 3 MINUTES)
			if (NIGHTMARE_CURSE)
				user.setStatus("art_nightmare_curse", 3 MINUTES)
			if (MAZE_CURSE)
				user.setStatus("art_maze_curse", 3 MINUTES)
			if (DISP_CURSE)
				user.setStatus("art_displacement_curse", 3 MINUTES)
			if (LIGHT_CURSE)
				user.setStatus("art_light_curse", 3 MINUTES)

		boutput(user, SPAN_ALERT("You have been cursed by an Eldritch artifact!"))
		O.visible_message(SPAN_ALERT("<b>[O]</b> screeches, releasing the curse that was locked inside it!"))
		playsound(src, pick('sound/effects/ghost.ogg', 'sound/effects/ghostlaugh.ogg'), 60, TRUE)

#undef BLOOD_CURSE
#undef AGING_CURSE
#undef NIGHTMARE_CURSE
#undef MAZE_CURSE
#undef DISP_CURSE
#undef LIGHT_CURSE
