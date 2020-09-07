/obj/artifact/borgifier
	name = "artifact human2cyborg converter"
	associated_datum = /datum/artifact/borgifier

/datum/artifact/borgifier
	associated_object = /obj/artifact/borgifier
	rarity_class = 3
	validtypes = list("ancient")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch)
	activated = 0
	react_xray = list(13,60,80,6,"COMPLEX")
	touch_descriptors = list("You seem to have a little difficulty taking your hand off its surface.")
	var/converting = 0
	var/list/work_sounds = list('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/effects/airbridge_dpl.ogg','sound/impact_sounds/Slimy_Splat_1.ogg','sound/impact_sounds/Flesh_Tear_2.ogg','sound/impact_sounds/Slimy_Hit_3.ogg')
	examine_hint = "It looks vaguely foreboding."

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!user)
			return
		if (converting)
			return
		if (ishuman(user))
			if(!isalive(user) && user.ghost && user.ghost.mind && user.ghost.mind.dnr)
				O.visible_message("<span class='alert'><b>[O]</b> refuses to process [user.name]!</span>")
				return
			O.visible_message("<span class='alert'><b>[O]</b> suddenly pulls [user.name] inside and slams shut!</span>")
			user.emote("scream")
			user.set_loc(O.loc)
			converting = 1
			var/loops = rand(10,20)
			while (loops > 0)
				loops--
				random_brute_damage(user, 15)
				user.changeStatus("paralysis", 70)
				playsound(user.loc, pick(work_sounds), 50, 1, -1)
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
				/obj/machinery/bot/floorbot)
				new robopath (T)
				qdel(user)
			else
				var/mob/living/carbon/human/M = user
				M.Robotize_MK2(1)
			converting = 0
		else if (issilicon(user))
			boutput(user, "<span class='alert'>An imperious voice rings out in your head... \"<b>UPGRADE COMPLETE, RETURN TO ASSIGNED TASK</b>\"</span>")
		else
			return
