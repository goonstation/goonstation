// strings here correlate with the id of the status effects they're tied to
#define BLOOD_CURSE "art_blood_curse"
#define AGING_CURSE "art_aging_curse"
#define NIGHTMARE_CURSE "art_nightmare_curse"
#define MAZE_CURSE "art_maze_curse"
#define DISP_CURSE "art_displacement_curse"
#define LIGHT_CURSE "art_light_curse"

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
	// general vars
	var/chosen_curse
	var/list/active_cursees = list()
	// blood curse vars
	var/blood_curse_active = FALSE
	// aging curse vars
	var/aging_curse_active = FALSE
	var/list/participants = list()
	// maze curse vars
	var/datum/allocated_region/maze

	// displacement curse vars
	var/disp_curse_active = FALSE

	New()
		..()
		src.chosen_curse = pick(BLOOD_CURSE, AGING_CURSE, NIGHTMARE_CURSE, MAZE_CURSE, DISP_CURSE, LIGHT_CURSE)

	effect_touch(obj/O, mob/living/user)
		. = ..()
		if (.)
			return TRUE
		if (!ishuman(user))
			return
		if (src.active_curse_check(O, user))
			return
		if (!user.client)
			return

		if (ON_COOLDOWN(O, "art_curse_activated", rand(180, 300) SECONDS) || length(src.active_cursees))
			boutput(user, "[O] seems dormant. You're sure you can feel some presence inside though... creepy.")
			return

		src.active_cursees = list()

		for (var/mob/living/carbon/human/H in range(5, O))
			if (!H.last_ckey)
				continue
			//if (H.hasStatus("art_talisman_held"))
			//	boutput(user, SPAN_ALERT("The artifact you're carrying wards you from a curse!"))
			user.setStatus(src.chosen_curse, 3 MINUTES)
			if (src.chosen_curse == MAZE_CURSE)
				//if (!src.created_maze)
				//	src.create_maze(50)
			src.active_cursees += H
			if (src.chosen_curse == BLOOD_CURSE)
				src.blood_curse_active = TRUE
			else if (src.chosen_curse == AGING_CURSE)
				src.aging_curse_active = TRUE
			else if (src.chosen_curse == DISP_CURSE)
				src.disp_curse_active = TRUE

			boutput(H, SPAN_ALERT("You have been cursed by an Eldritch artifact!"))

		O.visible_message(SPAN_ALERT("<b>[O]</b> screeches, releasing the curse that was locked inside it!"))
		playsound(src, pick('sound/effects/ghost.ogg', 'sound/effects/ghostlaugh.ogg'), 60, TRUE)

	proc/active_curse_check(obj/O, mob/living/carbon/human/user)
#undef BLOOD_CURSE
#undef AGING_CURSE
#undef NIGHTMARE_CURSE
#undef MAZE_CURSE
#undef DISP_CURSE
#undef LIGHT_CURSE
