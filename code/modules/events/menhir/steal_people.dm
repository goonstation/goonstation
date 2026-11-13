//pick somebody out and see how they respond
/datum/random_event/menhir/analysis
	name = "The Crown Inquires"
	description = "Absconds with several people (up to one per open Crown node, pop dependent) to test their response to stimuli."
	weight = 150
	///Increase the minimum required candidates each time the event goes off, to a cap.
	var/required_candidates = 1

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (emergency_shuttle.direction == SHUTTLE_DIRECTION_TO_STATION && emergency_shuttle.timeleft() < (SHUTTLEARRIVETIME / 2))
				. = FALSE //it's very rude to steal people when they've got somewhere to be
			if (emergency_shuttle.location == SHUTTLE_LOC_STATION)
				. = FALSE //or when their ride is here
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1)
				. = FALSE //or into a room where they can just walk out

	event_effect()
		//First see who we can yoink
		var/list/eligible_examinees = EVENT.MENHIR.FILTER.get_event_candidates(EVENT::MENHIR::FILTER::HUMAN | EVENT::MENHIR::FILTER::ON_TURF | EVENT::MENHIR::FILTER::NO_MOON | EVENT::MENHIR::FILTER::YOINK_SAFE)
		var/candidate_num = length(eligible_examinees)

		if (candidate_num < src.required_candidates)
			logTheThing(LOG_STATION, null, "Menhir event [src.name] has inadequate candidates ([candidate_num]/[src.required_candidates]); skipping event.")
			message_admins("Menhir event [src.name] has inadequate candidates ([candidate_num]/[src.required_candidates]); skipping event.")
			return

		//Then see where we can put them
		var/landmark_count = length(landmarks[LANDMARK_MENHIR_NODE])

		//And consider how many people will be absconded with
		var/yoinkcount = floor(min(candidate_num/2,landmark_count))
		if (yoinkcount < 1) //always at least 1
			yoinkcount = 1

		//Now, we do the thing

		///String for recording who got sent where
		var/return_string = ""
		var/block_count = 0
		var/list/eligible_nodes = landmarks[LANDMARK_MENHIR_NODE]
		for(var/i in 1 to yoinkcount)
			var/turf/nodelandmark = pick(eligible_nodes)
			var/node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]
			var/mob/yoinked_one = pick(eligible_examinees)
			eligible_examinees -= yoinked_one
			if(yoinked_one.hasStatus("spatial_protection")) //get parried idiot
				block_count++
				for_by_tcl(IX, /obj/machinery/interdictor)
					if(IX.notify_interdictor(yoinked_one))
						break
				var/turf/parryzone = get_turf(yoinked_one)
				playsound(parryzone, 'sound/weapons/lasersound.ogg', 55, 0, pitch = 0.45)
				SPAWN(2)
					new /obj/effects/energy_bolt_aoe_burst(parryzone)
			else
				eligible_nodes -= nodelandmark

				return_string += "[key_name(yoinked_one)] at [node_tag] arm "
				if(i < yoinkcount) return_string += "| "

				SPAWN(0)
					src.visit_scheduling(yoinked_one,nodelandmark)
		if(block_count)
			return_string += "([block_count] target(s) blocked by spatial protection)"

		message_delay = rand(18 SECONDS, 24 SECONDS)
		..()

		src.required_candidates = min(src.required_candidates + 2, 15)
		logTheThing(LOG_STATION, null, "Menhir event [src.name] triggered: [return_string]")
		message_admins("Menhir event [src.name] triggered: [return_string]")

	proc/visit_scheduling(var/mob/living/carbon/human/our_guest,var/turf/selected_node)
		var/hold_attempts = 0
		while(hold_attempts < 3)
			hold_attempts++
			var/nerd_broke_out = src.do_a_visit(our_guest,selected_node,hold_attempts)
			if(!nerd_broke_out)
				break
			sleep(rand(12,24))

	proc/do_a_visit(var/mob/living/carbon/human/our_guest,var/turf/selected_node,var/assertiveness)
		var/time_of_stay = rand(40 SECONDS,50 SECONDS)
		var/time_of_spook = time_of_stay * 0.3 + rand(0,15 SECONDS)

		var/turf/whisked_from = get_turf(our_guest)
		showswirl_out(whisked_from)
		showswirl(selected_node)
		our_guest.set_loc(selected_node)
		SPAWN(5)
			playsound(selected_node, 'sound/musical_instruments/artifact/Artifact_Precursor_5.ogg', 55, 0, pitch = 0.45, extrarange = 24)
		SPAWN(time_of_spook) //mess with our guest a little to see how they respond
			if(our_guest)
				var/area/A = get_area(our_guest)
				if(istype(A,/area/station/crown)) //make sure the guest is still here
					///Odds that, if we're not doing healing or gene tampering, we'll just do a noise instead of trialing chems on the guest
					var/noise_odds = min((4 - assertiveness) * 20, 10)

					if(our_guest.health < 60 && assertiveness == 1) //before anything else, see how our guest is doing. if it's not so well, take care of that.
						var/list/cure_reagents = list("epinephrine" = 4, "saline" = 4)
						if(our_guest.get_brute_damage() > 5)
							cure_reagents["salicylic_acid"] = 4
						if(our_guest.get_burn_damage() > 5)
							cure_reagents["menthol"] = 4
						if(our_guest.get_toxin_damage() > 5)
							cure_reagents["charcoal"] = 4
						if(our_guest.get_oxygen_deprivation() > 5)
							cure_reagents["salbutamol"] = 4
						for(var/reagent in cure_reagents)
							our_guest.reagents.add_reagent(reagent, cure_reagents[reagent])
						our_guest.playsound_local_not_inworld('sound/items/hypo.ogg', 30, 0)
						boutput(our_guest,SPAN_ALERT("You feel a small poke and see a tiny mechanical arm receding into the floor.[pick(" A strange feeling suffuses you.","")]"))

					else if(prob(40) && assertiveness == 1) //elsewise, let's perhaps see what's poking around in that genome - not more than one try per visit, though.
						var/datum/bioHolder/B = our_guest.bioHolder
						var/bioEffectId = pick(B.effectPool)
						var/datum/bioEffect/E = B.effectPool[bioEffectId]
						var/manipulation_sound = pick('sound/items/mesonactivate.ogg','sound/items/med_scanner.ogg','sound/effects/crackle3.ogg')
						our_guest.playsound_local_not_inworld(manipulation_sound, 40, 0, 0.7)
						boutput(our_guest,SPAN_ALERT("A strange [pick("pulse","wave","swell")] of energy washes over you.[pick(" You feel different."," What the hell?","")]"))
						SPAWN(rand(8,12))
							B.ActivatePoolEffect(E, 1, 0)

					else if(prob(noise_odds)) //sing them a little sound; less likely to do this if our guest has been rambunctious
						var/response_tester_sound = pick('sound/effects/explosionfar.ogg','sound/effects/explosionfar.ogg','sound/musical_instruments/Gong_Rumbling.ogg')
						our_guest.playsound_local_not_inworld(response_tester_sound, 80, 0)

					else //test chemical reaction
						var/response_tester_reagent = pick("love","colors","transparium","psilocybin","lumen","ethanol","solipsizine","catdrugs","THC","reversium")
						var/quantity = 10
						switch(response_tester_reagent)
							if("transparium")
								quantity = 25
							if("lumen")
								quantity = 30
						our_guest.reagents.add_reagent(response_tester_reagent, quantity)
						our_guest.playsound_local_not_inworld('sound/items/hypo.ogg', 30, 0)
						boutput(our_guest,SPAN_ALERT("You feel a small poke and see a tiny mechanical arm receding into the floor.[pick(" That can't be good."," What the hell?","")]"))
		sleep(time_of_stay)
		if(our_guest)
			var/area/A = get_area(our_guest)
			if(istype(A,/area/station/crown)) //our guest remains
				if(prob(1))
					var/turf/nearby_spot = null
					for(var/D in alldirs)
						var/turf/proxturf = get_step(whisked_from,D)
						if(!is_blocked_turf(proxturf))
							nearby_spot = proxturf
							break
					SPAWN(6)
						showswirl(nearby_spot)
					SPAWN(8)
						var/obj/ourpop = new /obj/item/reagent_containers/food/snacks/candy/lollipop(nearby_spot)
						ourpop.icon_state = "lpop-5"
				showswirl(whisked_from)
				showswirl_out(selected_node)
				our_guest.set_loc(whisked_from)
			else //our guest broke out, let's try that again
				. = TRUE
		SPAWN(5)
			var/moved_objects = 0
			for(var/atom/movable/AM in range(2,selected_node))
				if(!AM.anchored)
					var/turf/dumpspot = pick(landmarks[LANDMARK_MENHIR_OUTREACH])
					showswirl(dumpspot)
					AM.set_loc(dumpspot)
					moved_objects++

			if(moved_objects)
				logTheThing(LOG_STATION, null, "Menhir event [src.name] relocated [moved_objects] atoms out of node post-event.")
				message_admins("Menhir event [src.name] relocated [moved_objects] atoms out of node post-event.")
