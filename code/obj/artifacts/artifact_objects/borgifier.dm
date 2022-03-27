/obj/artifact/borgifier
	name = "artifact human2cyborg converter"
	associated_datum = /datum/artifact/borgifier

/datum/artifact/borgifier
	associated_object = /obj/artifact/borgifier
	type_name = "Cyborg converter"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 200
	validtypes = list("ancient")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch)
	activated = 0
	react_xray = list(13,60,80,6,"COMPLEX")
	touch_descriptors = list("You seem to have a little difficulty taking your hand off its surface.")
	var/converting = FALSE
	var/list/work_sounds = list('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/effects/airbridge_dpl.ogg','sound/impact_sounds/Slimy_Splat_1.ogg','sound/impact_sounds/Flesh_Tear_2.ogg','sound/impact_sounds/Slimy_Hit_3.ogg')
	examine_hint = "It looks vaguely foreboding."
	var/escapable = TRUE //Can you be dragged out to cancel the borgifying
	var/loops_per_conversion_step //Number of 0.4 second loops per 'step'- on each step a robolimb is added, and if all 4 limbs are robotic, they're borged

	New()
		..()
		if (prob(15))
			escapable = FALSE
		loops_per_conversion_step = escapable ? rand(4, 7) : rand(2, 4)

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!user)
			return
		if (converting)
			return
		if (ishuman(user))
			var/mob/living/carbon/human/humanuser = user
			if(!isalive(user) && user.ghost && user.ghost.mind && user.ghost.mind.dnr)
				O.visible_message("<span class='alert'><b>[O]</b> refuses to process [user.name]!</span>")
				return
			O.visible_message("<span class='alert'><b>[O]</b> suddenly pulls [user.name] inside[escapable ? "!" : " and slams shut!"]</span>")
			user.emote("scream")
			user.changeStatus("paralysis", 5 SECONDS)
			user.force_laydown_standup()
			if (!escapable)
				user.set_loc(O)
			else
				user.set_loc(get_turf(O.loc))
			converting = TRUE
			// keep it truthy to avoid null values due to missing limbs
			var/list/obj/item/parts/convertable_limbs = keep_truthy(list(humanuser.limbs.l_arm, humanuser.limbs.r_arm, humanuser.limbs.l_leg, humanuser.limbs.r_leg))
			//figure out which limbs are already robotic and remove them from the list
			for (var/obj/item/parts/limb in convertable_limbs)
				if (!limb || (limb.kind_of_limb & LIMB_ROBOT))
					convertable_limbs -= limb
			//people with existing robolimbs get converted faster.
			//(loops_per_conversion_step - 1) bit adds some 'buffer time' before any limbs are converted.
			var/loops = (loops_per_conversion_step * (convertable_limbs.len + 1)) + (loops_per_conversion_step - 1)
			while (loops > 0)
				if ((user.loc != O.loc && user.loc != O) || !activated)
					converting = FALSE
					return
				loops--
				//inescapable version slices em up more
				random_brute_damage(humanuser, (escapable ? 10 : 15))
				take_bleeding_damage(humanuser, null, (escapable ? 3 : 4))
				user.changeStatus("stunned", 7 SECONDS)
				playsound(user.loc, pick(work_sounds), 50, 1, -1)
				if (loops % loops_per_conversion_step == 0)
					if (!convertable_limbs.len) //avoid runtiming once all limbs are converted
						continue
					var/obj/item/parts/limb_to_replace = pick(convertable_limbs)
					switch(limb_to_replace.slot)
						if ("l_arm")
							humanuser.limbs.replace_with("l_arm", /obj/item/parts/robot_parts/arm/left/light, null, 0)
						if ("r_arm")
							humanuser.limbs.replace_with("r_arm", /obj/item/parts/robot_parts/arm/right/light, null, 0)
						if ("l_leg")
							humanuser.limbs.replace_with("l_leg", /obj/item/parts/robot_parts/leg/left/light, null, 0)
						if ("r_leg")
							humanuser.limbs.replace_with("r_leg", /obj/item/parts/robot_parts/leg/right/light, null, 0)
					convertable_limbs -= limb_to_replace
					humanuser.update_body()
				sleep(0.4 SECONDS)

			var/bdna = null // For forensics (Convair880).
			var/btype = null
			if (user.bioHolder.Uid && user.bioHolder.bloodType)
				bdna = user.bioHolder.Uid
				btype = user.bioHolder.bloodType
			var/turf/T = get_turf(user)
			gibs(T, null, null, bdna, btype)

			ArtifactLogs(user, null, O, "touched", "robotizing user", 0) // Added (Convair880).

			user.set_loc(get_turf(O.loc))
			if (isnpcmonkey(user) || jobban_isbanned(user, "Cyborg"))
				user.death()
				user.ghostize()
				var/robopath = pick(/obj/machinery/bot/guardbot,/obj/machinery/bot/secbot,
				/obj/machinery/bot/medbot,/obj/machinery/bot/firebot,/obj/machinery/bot/cleanbot,
				/obj/machinery/bot/floorbot,/obj/machinery/bot/mining)
				new robopath (T)
				qdel(user)
			else
				var/mob/living/carbon/human/M = user
				M.Robotize_MK2(1)
			converting = FALSE
		else if (issilicon(user))
			boutput(user, "<span class='alert'>An imperious voice rings out in your head... \"<b>UPGRADE COMPLETE, RETURN TO ASSIGNED TASK</b>\"</span>")
		else
			return

	effect_deactivate(obj/O)
		if (..())
			return
		for (var/mob/M in O.contents)
			O.visible_message("<span class='alert'><b>[O]</b> grumbles before releasing [M]!</span>")
			M.set_loc(get_turf(O))
