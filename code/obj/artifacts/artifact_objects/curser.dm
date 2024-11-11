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
			user.setStatus(src.chosen_curse)
			//if (src.chosen_curse == MAZE_CURSE)
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
		playsound(O, pick('sound/effects/ghost.ogg', 'sound/effects/ghostlaugh.ogg'), 60, TRUE)

	proc/active_curse_check(obj/O, mob/living/carbon/human/user)
		if (src.blood_curse_active)
			if (user.client && tgui_alert(user, "Donate 100u of your blood?", "Blood Curse Appeasement", list("Yes", "No")) == "Yes")
				user.blood_volume -= 100
				boutput(user, SPAN_ALERT("You place your hand on the artifact, and it draws blood from you. Ouch..."))
				for (var/mob/living/carbon/human/H in src.active_cursees)
					var/datum/statusEffect/art_curse/blood/curse = H.getStatus(src.active_cursees[H])
					curse.blood_to_collect -= 100
				return TRUE
		else if (src.aging_curse_active)
			var/mob/living/carbon/human/H1 = user
			var/mob/living/carbon/human/H2 = src.active_cursees[1]

			if (H1.bioHolder.age >= H2.bioHolder.age || (H1.ckey in src.participants))
				boutput(user, "[O] doesn't respond.")
				return TRUE
			boutput(user, "Your knuckles hurt kinda")
			participants.Add(H1.ckey)
			if (src.participants >= 3)
				src.lift_curse(TRUE)
				src.participants = list()
				src.aging_curse_active = FALSE
			else
				O.visible_message(SPAN_NOTICE("[O] softly stirs."))
			return TRUE

	proc/blood_curse_sacrifice(obj/O, mob/living/user)
		boutput(user, SPAN_ALERT("[O] pulls you inside!!!"))
		O.visible_message(SPAN_ALERT("<b>[O]</b> suddenly yanks [user] inside and blends them!!! <b>HOLY FUCK!!</b>"))
		user.set_loc(get_turf(src))
		user.gib(include_ejectables = FALSE)
		for (var/i in 1 to rand(3, 4))
			var/obj/decal/cleanable/blood_splat = make_cleanable(/obj/decal/cleanable/blood/splatter, get_turf(O))
			blood_splat.streak_cleanable(pick(cardinal), full_streak = prob(25), dist_upper = rand(4, 6))
		playsound(O, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 40, TRUE)
		src.blood_curse_active = FALSE

		src.lift_curse(FALSE)
	proc/lift_curse(do_playsound)
		if (do_playsound)
			playsound(src, 'sound/effects/lit.ogg', 70, TRUE)
		for (var/mob/L as anything in src.active_cursees)
			L.delStatus(src.chosen_curse)
		src.active_cursees = list()
#undef BLOOD_CURSE
#undef AGING_CURSE
#undef NIGHTMARE_CURSE
#undef MAZE_CURSE
#undef DISP_CURSE
#undef LIGHT_CURSE
