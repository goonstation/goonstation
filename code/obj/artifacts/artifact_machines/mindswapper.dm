/obj/machinery/artifact/mindswapper
	name = "mindswapper"
	associated_datum = /datum/artifact/mindswapper

/datum/artifact/mindswapper
	associated_object = /obj/machinery/artifact/mindswapper
	type_name = "Mindswapper"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 50 //Powerful effect, thus rare.
	validtypes = list("martian" ,"precursor" ,"wizard" ,"eldritch", "ancient")
	validtriggers = list(/datum/artifact_trigger/carbon_touch)
	//validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/language)
	activ_text = "extends several antennas!"
	deact_text = "retracts its antennas."
	react_xray = list(15,75,90,3,"ANTENNAS")
	var/mob/living/carbon/human/last_touched_body
	var/mindswap_cooldown = 30 SECONDS
	var/cooldowns = list()

	post_setup()
		..()

	effect_touch(obj/O, mob/living/user)
		. = ..()
		var/turf/T = get_turf(O)
		//Is the thing that touched a valid target? //TODO add monkeys
		if(!GET_COOLDOWN(src, "mindswap"))
			if(ishuman(user) && isalive(user))
				var/mob/living/carbon/human/H = user
				if(H.mind && H != src.last_touched_body)
					//Does the person who last touched still exist?
					if(src.last_touched_body)
						if(isalive(src.last_touched_body) && src.last_touched_body.mind)
							ON_COOLDOWN(src, "mindswap", src.mindswap_cooldown)
							//TODO add some creepy animation and sound effects.
							T.visible_message("<b>[O]</b>'s antennas glow!")
							boutput(user, SPAN_ALERT("[O] drags you out of your body!"))
							boutput(src.last_touched_body, SPAN_ALERT("[O] drags you out of your body!"))
							H.mind.swap_with(src.last_touched_body)
							SPAWN(src.mindswap_cooldown)
								T.visible_message("<b>[O]</b>'s antennas become active again!")
					//Remember the last valid person to touch the artifact.
					src.last_touched_body = H
					boutput(src.last_touched_body, SPAN_ALERT("[O] peers into your mind!"))
				else
					boutput(user, SPAN_ALERT("[O] rejects your soul!"))
					return
			else
				boutput(user, SPAN_ALERT("[O] rejects your soul!"))
				return
		else
			T.visible_message("<b>[O]</b>'s antennas remain inactive.")

