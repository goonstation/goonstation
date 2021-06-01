/obj/artifact/borgifier
	name = "artifact human2cyborg converter"
	associated_datum = /datum/artifact/borgifier

/datum/artifact/borgifier
	associated_object = /obj/artifact/borgifier
	type_name = "Cyborg converter"
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
	var/conversioncycles //Relative time it takes to get borged- sped up by existing robot limbs

	New()
		..()
		if (prob(15))
			escapable = FALSE
		conversioncycles = escapable ? rand(6, 10) : rand(2, 6)

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
			user.set_loc(O.loc)
			if (!escapable)
				user.anchored = TRUE //you ain't going nowhere
			converting = TRUE
			var/list/obj/item/parts/convertable_limbs = list(humanuser.limbs.l_arm, humanuser.limbs.r_arm, humanuser.limbs.l_leg, humanuser.limbs.r_leg)
			//figure out which limbs are already robotic and remove them from the list
			for (var/obj/item/parts/limb in convertable_limbs)
				if (limb.kind_of_limb & LIMB_ROBOT)
					convertable_limbs -= limb
			var/loops = conversioncycles * convertable_limbs.len //people with existing robolimbs get converted faster
			while (loops > 0)
				if (escapable && user.loc != O.loc)
					converting = FALSE
					return
				loops--
				random_brute_damage(humanuser, 10)
				user.changeStatus("paralysis", 7 SECONDS)
				playsound(user.loc, pick(work_sounds), 50, 1, -1)
				//TODO remove
				boutput(world, "<span class='alert'>Borgifying! loops % conversioncycles is: [loops % conversioncycles]</span>")
				if (loops % conversioncycles == 0) //floating points
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
						else //TODO remove
							CRASH("You fucked up the modulo somehow and there's nothing left to replace.")
				sleep(0.4 SECONDS)

			var/bdna = null // For forensics (Convair880).
			var/btype = null
			if (user.bioHolder.Uid && user.bioHolder.bloodType)
				bdna = user.bioHolder.Uid
				btype = user.bioHolder.bloodType
			var/turf/T = get_turf(user)
			gibs(T, null, null, bdna, btype)

			ArtifactLogs(user, null, O, "touched", "robotizing user", 0) // Added (Convair880).

			if (ismonkey(user) || jobban_isbanned(user, "Cyborg"))
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

