/* ============================================================ */
/* --------------------- Artifact Implants -------------------- */
/* ============================================================ */

/obj/item/implant/artifact
	scan_category = IMPLANT_SCAN_CATEGORY_UNKNOWN
	var/cant_take_out = FALSE
	var/artifact_implant_type = null
	var/active = FALSE

	eldritch
		name = "mysterious object"
		desc = "A mysterious object, used for who knows what purpose?"
		icon_state = "implant-eldritch"
		artifact_implant_type = "eldritch"
		impcolor = "eldritch"

	ancient
		name = "spiky thing"
		desc = "Some spiky thing. Good thing it isn't so large."
		icon_state = "implant-ancient"
		artifact_implant_type = "ancient"
		impcolor = "ancient"

	wizard
		name = "fancy stone"
		desc = "A fancy stone, set in an unknown material. It's quite shiny!"
		icon_state = "implant-wizard"
		artifact_implant_type = "wizard"
		impcolor = "wizard"

	proc/implant_activate(var/volume)
		var/turf/T = get_turf(src.owner)
		switch(src.artifact_implant_type)
			if ("eldritch")
				playsound(T, pick('sound/machines/ArtifactEld1.ogg', 'sound/machines/ArtifactEld2.ogg'), volume, 1)
			if ("ancient")
				playsound(T, 'sound/machines/ArtifactAnc1.ogg', volume, 1)
			if ("wizard")
				playsound(T, 'sound/machines/ArtifactWiz1.ogg', volume, 1)

	implanted(mob/M, mob/I)
		..()
		if (ishuman(M))
			var/mob/living/carbon/human/H = M

			var/impCount = 0
			for (var/obj/item/implant/artifact/imp in H.implant)
				impCount++
			if (impCount > 1)
				M.emote("scream")
				M.TakeDamage("chest", rand(5, 20), 0, 0, DAMAGE_BLUNT)
				M.changeStatus("disorient", 5 SECONDS)
				for (var/obj/item/implant/artifact/imp in H.implant)
					imp.on_remove(H)
					H.implant.Remove(imp)
					qdel(imp)

/obj/item/implant/artifact/eldritch/eldritch_good
	var/static/list/organs = list("left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver",
								  "stomach", "intestines", "spleen", "pancreas", "appendix")

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			var/mob/living/carbon/human/H = owner

			var/organ_found = null
			var/obj/item/organ/current_organ = null

			for (var/organ in organs)
				current_organ = H.get_organ(organ)
				if (!current_organ || current_organ.get_damage() > current_organ.fail_damage)
					organ_found = organ
					break
				current_organ?.heal_damage(0.1667 * mult, 0.1667 * mult, 0.1667 * mult) // 5 minutes to heal a 100 hp organ with 2 second process ticks

			if (organ_found)
				active = TRUE
				src.implant_activate(50)

				SPAWN(2 SECONDS)
					if (H && src && (src in H.implant))
						if (!H.get_organ(organ_found))
							var/obj/item/organ_to_receive = H.organHolder.organ_type_list[organ_found]
							H.receive_organ(new organ_to_receive, organ_found, 0, 1)
							H.show_text("You feel a bit more complete.", "blue")
						else
							H.organHolder.heal_organ(INFINITY, INFINITY, INFINITY, organ_found)
							H.show_text("You feel much better.", "blue")
						H.update_body()

						src.on_remove(H)
						H.implant.Remove(src)
						qdel(src)
					else
						active = FALSE
		..()

/obj/item/implant/artifact/eldritch/eldritch_gimmick

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			active = TRUE
			var/mob/living/carbon/human/H = owner

			SPAWN((20 + rand(-10, 10)) SECONDS)
				active = FALSE
				if (H && src && (src in H.implant))
					var/obj/decal/cleanable/blood/dynamic/B = make_cleanable(/obj/decal/cleanable/blood/dynamic, get_turf(H))

					B.add_volume(DEFAULT_BLOOD_COLOR, "blood", 50, 5)
					B.blood_DNA = "unknown"
					B.blood_type = "unknown"

					if (prob(10))
						boutput(H, SPAN_ALERT("<i>Bloooood.....</i>"))
		..()

/obj/item/implant/artifact/eldritch/eldritch_bad
	var/list/organs
	var/activated = FALSE

	New()
		..()
		src.organs = list("left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")
		shuffle_list(src.organs)

	do_process(var/mult = 1)
		if (!ishuman(src.owner) || src.active)
			return ..()

		var/mob/living/carbon/human/H = owner
		var/failed_organs = 0

		if (H.get_brute_damage() > 75)
			if (!src.activated)
				src.activated = TRUE
				src.implant_activate(50)
				boutput(H, SPAN_ALERT("<b>Your insides doesn't feel so good... Wait... what?</b>"))

			H.TakeDamage("All", 2, damage_type = DAMAGE_STAB)

			var/obj/item/organ/current_organ = null

			for (var/organ in organs)
				current_organ = H.get_organ(organ)
				current_organ?.take_damage(4, 0, 0, DAMAGE_STAB)
				if (!current_organ || current_organ.get_damage() > current_organ.fail_damage)
					failed_organs += 1

		if (H.get_brute_damage() > 175 || failed_organs > 5)
			src.active = TRUE
			src.cant_take_out = TRUE
			SPAWN(2 SECONDS)
				if (H && src)
					H.make_jittery(1000)
					boutput(H, SPAN_ALERT("<b>You feel an ancient force begin to seize your body!</b>"))

				sleep(3 SECONDS)
				if (H && src)
					H.emote("scream")
					playsound(H.loc, pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_noises"), 50, 1)

				sleep(3 SECONDS)
				if (H && src)
					H.emote("faint")
					H.changeStatus("unconscious", 10 SECONDS)
					H.losebreath += 5
					playsound(H.loc, pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_noises"), 50, 1)

				sleep(3 SECONDS)
				if (H && src)
					H.gib()

		..()

	on_remove()
		src.activated = FALSE
		..()

/obj/item/implant/artifact/ancient/ancient_good
	var/static/left_arm = list(/obj/item/parts/robot_parts/arm/left/light, /obj/item/parts/robot_parts/arm/left/standard)
	var/static/right_arm = list(/obj/item/parts/robot_parts/arm/right/light, /obj/item/parts/robot_parts/arm/right/standard)
	var/static/left_leg = list(/obj/item/parts/robot_parts/leg/left/light, /obj/item/parts/robot_parts/leg/left/standard, /obj/item/parts/robot_parts/leg/left/treads)
	var/static/right_leg = list(/obj/item/parts/robot_parts/leg/right/light, /obj/item/parts/robot_parts/leg/right/standard, /obj/item/parts/robot_parts/leg/right/treads)

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			var/mob/living/carbon/human/H = owner
			var/obj/item/parts/l_arm = H.limbs.get_limb("l_arm")
			var/obj/item/parts/r_arm = H.limbs.get_limb("r_arm")
			var/obj/item/parts/l_leg = H.limbs.get_limb("l_leg")
			var/obj/item/parts/r_leg = H.limbs.get_limb("r_leg")

			if (!l_arm || !r_arm || !l_leg || !r_leg)
				active = TRUE
				src.implant_activate(50)

				SPAWN(2 SECONDS)
					if (H && src && (src in H.implant))
						playsound(get_turf(H), 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
						if (!l_arm)
							H.limbs.replace_with("l_arm", pick(left_arm), null, 0)
						else if (!r_arm)
							H.limbs.replace_with("r_arm", pick(right_arm), null, 0)
						else if (!l_leg)
							H.limbs.replace_with("l_leg", pick(left_leg), null, 0)
						else if (!r_leg)
							H.limbs.replace_with("r_leg", pick(right_leg), null, 0)
						H.update_body()

						src.on_remove(H)
						H.implant.Remove(src)
						qdel(src)
					else
						active = FALSE
		..()

/obj/item/implant/artifact/ancient/ancient_gimmick
	var/static/list/message_list = list("ROBOT REVOLUTION", "THE TIME IS NOW", "YOUR CAPTAIN IS OURS", "TIME TO BORG",
										"CYBORGS WILL PREVAIL", "SILICON IS SUPERIOR", "FLESH AND METAL", "GO BORG OR GO HOME",
										"SILICON MEANS SMART", "BORG THE CREW", "ALL WILL SUBMIT", "SETTLE FOR METAL",
								 		"PROCESSING POWER FOR ALL", "CONVERSION IS NEAR", "HUMANS ARE WEAK",
										"THE MACHINE IS ETERNAL", "ALL WILL BE UPGRADED")

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			active = TRUE

			var/mob/living/carbon/human/H = owner

			SPAWN(10 SECONDS)
				active = FALSE
				if (H && src && (src in H.implant))
					H.say(pick(message_list))
					if (prob(3))
						playsound(get_turf(H), pick('sound/voice/screams/robot_scream.ogg', 'sound/voice/screams/Robot_Scream_2.ogg'), 50, 1)
		..()

/obj/item/implant/artifact/ancient/ancient_bad
	var/activated = FALSE

	do_process(var/mult = 1)
		if (!ishuman(src.owner) || src.active)
			return ..()
		var/mob/living/carbon/human/H = owner
		if (H.get_oxygen_deprivation() > 75)
			if (!src.activated)
				src.activated = TRUE
				src.implant_activate(50)
				boutput(H, SPAN_ALERT("<b>You feel its harder to breath. Oh GOD YOUR LUNGS. WHAT THE HELL?</b>"))
				H.losebreath += 75
			H.take_oxygen_deprivation(3 * mult)

		if (H.get_oxygen_deprivation() > 175)
			active = TRUE
			src.cant_take_out = TRUE
			boutput(H, SPAN_ALERT("<b>You feel something start to rip apart your insides!</b>"))

			SPAWN(3 SECONDS)
				for (var/limb in list("l_arm", "r_arm", "l_leg", "r_leg"))
					if (H && src)
						playsound(get_turf(H), pick('sound/impact_sounds/circsaw.ogg', 'sound/machines/rock_drill.ogg'), 50, 1)
						H.sever_limb(limb)
						sleep(1 SECOND)

				if (H && src)
					H.gib()
		..()

/obj/item/implant/artifact/wizard/wizard_good

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			var/mob/living/carbon/human/H = owner
			if (H.get_burn_damage() > 100 && H.z == Z_LEVEL_STATION)
				active = TRUE
				src.implant_activate(50)
				var/turf/T = null
				var/teleTries = 0
				var/maxTeleTries = 500
				var/teleFound = FALSE
				var/teleMargin = 25

				SPAWN(2 SECONDS)
					if (H && src && (src in H.implant))
						var/list/telePatch = block(locate(max(H.x - teleMargin, 1), max(H.y - teleMargin, 1), Z_LEVEL_STATION), locate(min(H.x + teleMargin, world.maxx), min(H.y + teleMargin, world.maxy), Z_LEVEL_STATION))

						while (!teleFound && teleTries <= maxTeleTries)
							T = pick(telePatch)

							teleTries++

							if (istype(T, /turf/simulated/floor) && !(locate(/obj/window) in T) && !istype(get_area(T), /area/listeningpost))
								teleFound = TRUE
							else
								telePatch.Remove(T)

						if (teleFound)
							do_teleport(H, T, 0, FALSE)

						src.on_remove(H)
						H.implant.Remove(src)
						qdel(src)
					else
						active = FALSE
		..()

/obj/item/implant/artifact/wizard/wizard_gimmick
	var/static/list/possible_mutantraces = list(null, /datum/mutantrace/lizard, /datum/mutantrace/skeleton, /datum/mutantrace/ithillid,
												/datum/mutantrace/monkey, /datum/mutantrace/roach, /datum/mutantrace/cow,
										 		/datum/mutantrace/pug, /datum/mutantrace/cat/bingus)

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			active = TRUE

			var/mob/living/carbon/human/H = owner

			SPAWN((300 + rand(-120, 120)) SECONDS)
				active = FALSE
				src.implant_activate(50)
				sleep(2 SECONDS)
				if (H && src && (src in H.implant))
					gibs(get_turf(H), null, H.bioHolder.Uid, H.bioHolder.bloodType, 0)
					H.set_mutantrace(pick(possible_mutantraces))
		..()

	on_remove()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = owner
			if (H.mutantrace != H.default_mutantrace)
				gibs(get_turf(H), null, H.bioHolder.Uid, H.bioHolder.bloodType, 0)
			H.set_mutantrace(null)
		..()

/obj/item/implant/artifact/wizard/wizard_bad
	var/effect_type
	var/activated = FALSE

	New()
		..()
		src.effect_type = pick("fire", "ice")

	do_process(var/mult = 1)
		if (!ishuman(src.owner))
			return ..()

		var/mob/living/carbon/human/H = owner
		if (H.get_burn_damage() <= 75)
			return ..()

		if (!src.activated)
			src.activated = TRUE
			src.implant_activate(50)
			if (src.effect_type == "fire")
				boutput(H, SPAN_ALERT("<b>You feel really, REALLY HOT!</b>"))
				if (H.is_heat_resistant())
					boutput(H, SPAN_ALERT("<b>You get a feeling that your fire resistance isn't working right...</b>"))
			else
				boutput(H, SPAN_ALERT("<b>Oh god, it's SO COLD!</b>"))
				if (H.is_cold_resistant())
					boutput(H, SPAN_ALERT("<b>You get a feeling that your cold resistance isn't working right...</b>"))

		if (src.effect_type == "fire")
			H.bodytemperature = max(H.bodytemperature, 10000)
			H.set_burning(100)
		else
			H.bodytemperature = min(H.bodytemperature, 0)
			H.TakeDamage("All", 0, 3, 0, DAMAGE_BURN)

		if (H.get_burn_damage() > 175)
			if (src.effect_type == "fire")
				make_cleanable(/obj/decal/cleanable/ash, get_turf(H))
				playsound(get_turf(H), 'sound/effects/mag_fireballlaunch.ogg', 50, TRUE)
				H.firegib(FALSE)
			else
				playsound(get_turf(H), 'sound/impact_sounds/Crystal_Hit_1.ogg', 50, TRUE)
				H.become_statue(getMaterial("ice"), "Someone completely frozen in ice. How this happened, you have no clue!")

		..()

	on_remove()
		src.effect_type = pick("fire", "ice")
		src.activated = FALSE
		..()
