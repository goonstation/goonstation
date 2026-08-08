#ifdef MAP_OVERRIDE_MENHIR
///List of people who are present on station for events, updated once a cycle for events to check. SHOULD NOT BE ACCESSED DIRECTLY - use helper.
var/global/list/menhir_local_event_candidates = list()
///Time at which the list of people present on station for events was last updated.
var/global/menhir_candidates_last_built = 0

//-----------Bitflags for filtering events------------
//Does our candidate need to be human?
#define EVFILTER_HUMAN 1
//Does our candidate need to be directly on a turf, and not inside anything else?
#define EVFILTER_ONTURF 2
//By default, anyone in Precursor areas counts as "present" as well. This filter prevents that.
#define EVFILTER_NO_MOON 4

///Grabs (and updates, if necessary) the list of people who are present for on-station events. Provide a filter to narrow the returned pool further.
/proc/get_menhir_event_candidates(var/filter = 0)
	//Build stage
	if(menhir_candidates_last_built < (world.time - 20 SECONDS) && !length(menhir_local_event_candidates))
		menhir_candidates_last_built = world.time
		menhir_local_event_candidates = list()

		for (var/mob/living/L in mobs)
			if(!isalive(L) || !L.client || ismobcritter(L))
				continue
			var/area/mobarea = get_area(L)
			if(istype(mobarea,/area/station) || istype(mobarea,/area/unspace) || istype(mobarea, /area/research_outpost) || istype(mobarea, /area/precursor))
				menhir_local_event_candidates += L
	. = menhir_local_event_candidates

	//Filter stage
	if(filter)
		for(var/mob/M in .)
			if(filter & EVFILTER_HUMAN && !istype(M,/mob/living/carbon/human))
				. -= M
				continue
			if(filter & EVFILTER_ONTURF && !isturf(M.loc))
				. -= M
				continue
			if(filter & EVFILTER_NO_MOON)
				var/area/mobarea = get_area(M)
				if(istype(mobarea,/area/precursor))
					. -= M
					continue

	return

#define MENHIR_STANDARD_ALERT_VOLUME 40
#define MENHIR_CORE_X 158
#define MENHIR_CORE_Y 169
#define MENHIR_EVENT_NOTIFY_NONE 0
#define MENHIR_EVENT_NOTIFY_PDA 1
#define MENHIR_EVENT_NOTIFY_GLOBAL 2

ABSTRACT_TYPE(/datum/random_event/menhir)
/datum/random_event/menhir
	centcom_headline = "Artifact Condition Advisory"
	centcom_message = "A spike in electromagnetic activity from TOREADOR-7I-22408 was recently recorded. Personnel on site are advised to monitor artifact for changes in structure or activity."
	centcom_origin = ALERT_ANOMALY
	///Events may be entirely unannounced, directed only to the science team by PDA, or broadcast stationwide.
	var/announcement_style = MENHIR_EVENT_NOTIFY_PDA

	New()
		. = ..()
		if(src.announcement_style != MENHIR_EVENT_NOTIFY_GLOBAL)
			src.centcom_headline = null //deactivates announcement

	event_effect()
		if(src.announcement_style == MENHIR_EVENT_NOTIFY_PDA)
			SPAWN(src.message_delay)
				var/obj/machinery/networked/radio/sciradio = locate("lrad_bouncepoint")
				if(sciradio && istype(sciradio) && sciradio.powered())
					var/datum/signal/pdaSignal = get_free_signal()
					pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="LRAD-TOREADOR", "group"=list(MGD_RESEARCH), "sender"="00000000", "message"="[src.centcom_message]")
					radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)
		. = ..()

	///Outreach turfs are locations that start open and are suitable for an event to occur at. Events should pick and check one blindly at first, and fall back to this if necessary.
	proc/get_open_outreach()
		. = FALSE
		var/list/eligible_sites = list()
		for (var/turf/T in landmarks[LANDMARK_MENHIR_OUTREACH])
			if(istype(T,/turf/simulated/floor) && !is_blocked_turf(T))
				eligible_sites += T
		if(length(eligible_sites))
			. = pick(eligible_sites)

	///For events localized to a particular site, update the message to direct people towards the site, more or less.
	proc/localize_reading(var/atom/target)
		///Text given to orientate the announcement.
		var/sumtext = "spinal"
		///X-axis report text (may remain null).
		var/x_string = null
		///Y-axis report text (may remain null).
		var/y_string = null
		///X-axis distance (east-west) between the center of the Crown and the incidence site.
		var/x_main = clamp(target.x - MENHIR_CORE_X, -50, 50)
		///Y-axis distance (north-south) between the center of the Crown and the incidence site.
		var/y_main = clamp(target.y - MENHIR_CORE_Y, -50, 50)

		//Tie odds of successful directional indication to the axial distance, with 100% base certainty of the localization at 50+ tiles from center.
		//This sometimes will fail despite that, but never explicitly direct people in the opposite direction.
		var/x_positive_clamped = max(0,x_main) * 2
		var/x_negative_clamped = max(0,-x_main) * 2
		var/y_positive_clamped = max(0,y_main) * 2
		var/y_negative_clamped = max(0,-y_main) * 2

		//Y string first (directional convention)
		if(prob(10)) //10% chance for localization on the axis to fail
			y_string = null
		else if(prob(y_positive_clamped))
			y_string = "north"
		else if(prob(y_negative_clamped))
			y_string = "south"

		//X string after
		if(prob(10)) //10% chance for localization on the axis to fail
			x_string = null
		else if(prob(x_positive_clamped))
			x_string = "east"
		else if(prob(x_negative_clamped))
			x_string = "west"

		//pull them all together
		if (x_string || y_string)
			sumtext = ""
			if(y_string) sumtext += y_string
			if(x_string) sumtext += x_string

		src.centcom_message = "A spike in electromagnetic activity from TOREADOR-7I-22408 was recently recorded, with notable projection on the [sumtext] axis."
		src.centcom_message += " Structural alteration is probable, and may not be confined to the artifact itself."

//some little fellas!
/datum/random_event/menhir/probes
	name = "Emissaries of the Crown"
	weight = 300
	var/list/deployed_probes = list()

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (length(src.deployed_probes)) //we're already deployed!
				. = FALSE

	event_effect()
		var/list/candidate_landmarks = list()
		for (var/turf/T in landmarks[LANDMARK_HALLOWEEN_SPAWN])
			candidate_landmarks += T
		for (var/turf/T in landmarks[LANDMARK_MENHIR_OUTREACH])
			if(istype(get_area(T),/area/station/maintenance)) continue
			candidate_landmarks += T

		var/probe_deployments = rand(8,11)
		var/have_deployed = 0
		SPAWN(1) //don't hold up other operations
			var/turf/rolling_target
			while(have_deployed < probe_deployments)
				rolling_target = pick(candidate_landmarks)
				candidate_landmarks -= rolling_target
				showswirl(rolling_target)
				var/mob/living/critter/robotic/probe/deployed_probe
				if(have_deployed < 2)
					deployed_probe = new /mob/living/critter/robotic/probe/arbitor(rolling_target)
				else
					deployed_probe = new /mob/living/critter/robotic/probe(rolling_target)
				deployed_probe.emissary = TRUE
				src.deployed_probes += deployed_probe
				have_deployed++
				sleep(1)

		SPAWN(rand(3 MINUTES, 5 MINUTES))
			for (var/mob/M in deployed_probes)
				if(!QDELETED(M))
					var/turf/T = get_turf(M)
					showswirl_out(T)
					deployed_probes -= M
					qdel(M)
					sleep(1)
			deployed_probes = list()
			logTheThing(LOG_STATION, null, "Menhir probes event concluded.")
			message_admins("Menhir probes event concluded.")

		logTheThing(LOG_STATION, null, "Menhir probes event deployed [probe_deployments] probes.")
		message_admins("Menhir probes event deployed [probe_deployments] probes.")

		message_delay = rand(2 SECONDS, 4 SECONDS)
		..()

//////////////////////////////////////////////
///////////////////////////////////////////////////////
//////Common (150 starting weight)/////////////////////
///////////////////////////////////////////////////////
//////////////////////////////////////////////

//pulled one out of cold storage for ya
/datum/random_event/menhir/gift
	name = "A Gift from the Crown"
	message_delay = 3 MINUTES
	weight = 150
	var/has_noded = FALSE

	event_effect()
		///Site the gift artifact spawns at; will be in a "node" (outer ball) one time if it can, adding a door to it and disqualifying node from further events
		var/turf/nodelandmark
		///Tag for the node the event is occurring in, when a node is selected
		var/node_tag = null
		///List of eligible walls in node mode; divided by relative position.
		var/list/eligible_walls = list("S" = list(), "N" = list(), "E" = list(), "W" = list())
		///When we've populated a direction with at least one wall from each facing, we're good to go
		var/list/eligibility_flags = 0

		var/can_node = TRUE
		if(src.has_noded) can_node = FALSE
		else if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) can_node = FALSE

		if(!can_node) //outreach mode: drop it somewhere on the station
			nodelandmark = pick_landmark(LANDMARK_MENHIR_OUTREACH)
			if (!istype(nodelandmark,/turf/simulated/floor) || is_blocked_turf(nodelandmark))
				nodelandmark = get_open_outreach()
				if(!nodelandmark)
					logTheThing(LOG_DEBUG, null, "Menhir gift event couldn't find an outreach turf; aborting event.")
					message_admins("Menhir gift event couldn't find an outreach turf; aborting event.")
					return
		else //node mode: pick a ball, any ball
			nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)
			node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

			for (var/turf/T in landmarks[LANDMARK_MENHIR_DOOR])
				if (landmarks[LANDMARK_MENHIR_DOOR][T] == node_tag)
					//categorize nodes based on positional block (set up this way to allow east/west entrance sides to be more than 1 door)
					if(T.x > nodelandmark.x)
						eligible_walls["E"] += T
						eligibility_flags |= EAST
					else if(T.x < nodelandmark.x)
						eligible_walls["W"] += T
						eligibility_flags |= WEST
					else
						if(T.y > nodelandmark.y)
							eligible_walls["N"] += T
							eligibility_flags |= NORTH
						else
							eligible_walls["S"] += T
							eligibility_flags |= SOUTH

			if (eligibility_flags < (NORTH|SOUTH|EAST|WEST))
				logTheThing(LOG_DEBUG, null, "Menhir gift event didn't find all directions for the [node_tag] node! This shouldn't happen.")
				message_admins("Menhir gift event didn't find all directions for the [node_tag] node! This shouldn't happen. Aborting event")
				return

		if(prob(60))
			playsound(nodelandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		if(node_tag)
			var/facing_dir = pick("S","N","E","W")

			for(var/turf/wallturf in eligible_walls[facing_dir])
				var/save_dir = wallturf.icon_state
				var/obj/newdoor = new /obj/machinery/door/unpowered/blue(wallturf)
				if (save_dir == "interior-3") //vertical wall detection
					newdoor.dir = 4

			landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again
		else
			showswirl(nodelandmark)
		Artifact_Spawn(nodelandmark,"precursor")
		src.localize_reading(nodelandmark)

		message_delay = rand(2 SECONDS, 4 SECONDS)
		..() //don't send out the message until we have confirmed we can do the event

		if(node_tag)
			logTheThing(LOG_STATION, null, "Menhir gift event at [node_tag] arm - [log_loc(nodelandmark)]")
			message_admins("Menhir gift event triggered at [node_tag] arm - [log_loc(nodelandmark)]")
		else
			logTheThing(LOG_STATION, null, "Menhir gift event (out-of-node) at [log_loc(nodelandmark)]")
			message_admins("Menhir gift event triggered (out-of-node) - [log_loc(nodelandmark)]")

		src.weight = 50 //After we've had one artifact, weight it down
		src.has_noded = TRUE //and avoid using up scarce nodes

//pick somebody out and see how they respond
/datum/random_event/menhir/analysis
	name = "The Crown Inquires"
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
		var/list/eligible_examinees = get_menhir_event_candidates(EVFILTER_HUMAN | EVFILTER_ONTURF | EVFILTER_NO_MOON)
		var/candidate_num = length(eligible_examinees)

		if (candidate_num < src.required_candidates)
			logTheThing(LOG_STATION, null, "Menhir analysis event has inadequate candidates ([candidate_num]/[src.required_candidates]); skipping event.")
			message_admins("Menhir analysis event has inadequate candidates ([candidate_num]/[src.required_candidates]); skipping event.")
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
		logTheThing(LOG_STATION, null, "Menhir analysis event: [return_string]")
		message_admins("Menhir analysis event: [return_string]")

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
						var/response_tester_reagent = pick("love","colors","transparium","psilocybin","lumen","ethanol")
						var/quantity = 10
						switch(response_tester_reagent)
							if("transparium")
								quantity = 40
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
				logTheThing(LOG_STATION, null, "Menhir analysis event relocated [moved_objects] atoms out of node post-event.")
				message_admins("Menhir analysis event relocated [moved_objects] atoms out of node post-event.")

//it appears you may need a top up! let's help with that
/datum/random_event/menhir/supercharge
	name = "One Flame Begets Another"
	message_delay = 1 MINUTE
	weight = 150

	event_effect()
		var/list/station_areas = get_accessible_station_areas()
		var/list/candidate_apcs = list()
		for (var/area_name in station_areas)
			var/area/A = station_areas[area_name]
			if (!istype(A,/area/station/maintenance) && istype(A.area_apc))
				var/obj/machinery/power/apc/our_apc = A.area_apc
				if(!our_apc.cell) continue
				var/powerfraction = ((1 - (our_apc.cell.charge / our_apc.cell.maxcharge)) * 20)
				var/apc_weight = max(1,round(powerfraction ** 2)) //lower power is dramatically higher odds
				if(A.workplace) //weight a little higher towards workplaces as well
					apc_weight *= 2
				candidate_apcs[our_apc] = apc_weight

		var/zones_to_electrify = rand(6,8)
		if(length(candidate_apcs) < zones_to_electrify)
			logTheThing(LOG_DEBUG, null, "Menhir supercharge event couldn't find enough APCs to electrify! This shouldn't happen.")
			message_admins("Menhir supercharge event couldn't find enough APCs to electrify! This shouldn't happen. Aborting event")
			return

		SPAWN(1) //don't hold up other operations
			var/report_string = ""
			for(var/i = 1 to zones_to_electrify)
				var/obj/machinery/power/apc/our_target = weighted_pick(candidate_apcs)
				candidate_apcs[our_target] = 0
				var/area/apc_loc_area = get_area(our_target) //align to the physical position of the APC, not where it powers
				var/orb_spawns = list()
				for(var/turf/T in orange(6,our_target))
					if(!is_blocked_turf(T) && get_area(T) == apc_loc_area) orb_spawns += T
				var/turf/orb_spawn_here = pick(orb_spawns)
				if(orb_spawn_here)
					new /obj/machinery/menhir_energy_sphere(orb_spawn_here,our_target)
					report_string += "[log_loc(orb_spawn_here)]"
					if(i != zones_to_electrify) report_string += ", "
				sleep(2)

			logTheThing(LOG_STATION, null, "Menhir supercharge event triggered at: [report_string]")
			message_admins("Menhir supercharge event triggered at: [report_string]")

		message_delay = rand(6 SECONDS,9 SECONDS)
		..()

//////////////////////////////////////////////
///////////////////////////////////////////////////////
//////Standard (100 starting weight)///////////////////
///////////////////////////////////////////////////////
//////////////////////////////////////////////

//the crown could just use a minute ok
/datum/random_event/menhir/closure
	name = "The Crown Reclusive"
	message_delay = 1 MINUTE
	announcement_style = MENHIR_EVENT_NOTIFY_NONE

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			var/obj/machinery/door/unpowered/blue/entrance = locate("menhir_entrance_bluedoor")
			if(entrance && entrance.density) //event hasn't triggered & no entrance has been made
				. = FALSE

	event_effect()
		var/obj/machinery/door/unpowered/blue/entrance = locate("menhir_entrance_bluedoor")
		if (!entrance) //in case of manual call
			logTheThing(LOG_DEBUG, null, "Menhir closure event couldn't find the Crown's entrance door; aborting event.")
			message_admins("Menhir closure event couldn't find the Crown's entrance door; aborting event.")
			return
		var/turf/eventlandmark = get_turf(entrance)
		entrance.locks_on_open = FALSE
		var/delay = rand(2,12)
		SPAWN(delay)
			entrance.close()
			entrance.locked = TRUE
		SPAWN(delay+38)
			entrance.revoke_door()
		SPAWN(rand(2 MINUTES, 3 MINUTES))
			playsound(eventlandmark, 'sound/effects/ring_happi.ogg', 55, 0, extrarange = 24, pitch = 0.3)
			new /obj/machinery/door/unpowered/blue(eventlandmark)

		playsound(eventlandmark, 'sound/effects/ring_happi.ogg', 45, 0, extrarange = 24, pitch = 0.3)

		..()

		logTheThing(LOG_STATION, null, "Menhir closure event at [log_loc(eventlandmark)]")
		message_admins("Menhir closure event triggered at [log_loc(eventlandmark)]")

#define RAND_3_BY_3 1
#define RAND_3_BY_5 2
#define RAND_5_BY_3 3

//you like rooms, right?
/datum/random_event/menhir/extrusion
	name = "A Place of Paths Not Taken"
	message_delay = 3 MINUTES

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_EXTRUSION] || length(landmarks[LANDMARK_MENHIR_EXTRUSION]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		var/turf/extlandmark = pick(landmarks[LANDMARK_MENHIR_EXTRUSION])
		var/alignment = landmarks[LANDMARK_MENHIR_EXTRUSION][extlandmark]
		var/are_we_west = FALSE
		if (alignment == "WEST") are_we_west = TRUE
		var/roomtype = rand(1,3)

		var/list/frametiles = src.get_walls(extlandmark, are_we_west, roomtype)
		var/list/to_area_swap = src.get_whole_coverage(extlandmark, are_we_west, roomtype)
		var/turf/rroom_site = src.get_room_spot(extlandmark, are_we_west, roomtype)

		var/area/hostarea = get_area(extlandmark)

		for (var/turf/T in to_area_swap)
			if(isarea(T.loc))
				var/area/A = T.loc
				A.contents -= T
			hostarea.contents += T

		var/do_rwalls = FALSE
		if (istype(extlandmark,/turf/simulated/wall/auto/reinforced)) do_rwalls = TRUE

		for (var/turf/T in frametiles)
			if((T.density && !do_rwalls) || locate(/obj/window) in T || locate(/obj/machinery/door) in T) continue
			if(do_rwalls)
				T.ReplaceWithRWall()
			else
				T.ReplaceWithWall()
			leaveresidual(T)

		var/already_have_door = FALSE
		for (var/obj/O in extlandmark)
			if(istype(O,/obj/mesh) || istype(O,/obj/window))
				qdel(O)
			if(istype(O,/obj/machinery/door))
				already_have_door = TRUE
		if (extlandmark.density)
			extlandmark.ReplaceWith(/turf/simulated/floor/plating)
		if (!already_have_door)
			var/obj/newdoor = new /obj/machinery/door/airlock/pyro/maintenance(extlandmark)
			newdoor.dir = EAST

		var/obj/landmark/random_room/mark_plier
		switch(roomtype)
			if(RAND_3_BY_3) mark_plier = new /obj/landmark/random_room/size3x3(rroom_site)
			if(RAND_3_BY_5) mark_plier = new /obj/landmark/random_room/size3x5(rroom_site)
			if(RAND_5_BY_3) mark_plier = new /obj/landmark/random_room/size5x3(rroom_site)
		mark_plier.apply()

		if(prob(60))
			playsound(extlandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(extlandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		src.localize_reading(extlandmark)

		message_delay = rand(90 SECONDS, 140 SECONDS)
		..()

		landmarks[LANDMARK_MENHIR_EXTRUSION].Remove(extlandmark)

		logTheThing(LOG_STATION, null, "Menhir extrusion event at [log_loc(extlandmark)]")
		message_admins("Menhir extrusion event triggered at [log_loc(extlandmark)]")

	///Retrieves the turfs to frame out the new room.
	proc/get_walls(var/turf/T, var/offset_to_west, var/roomtype)
		. = list()
		var/offset_H = 4
		if(roomtype == RAND_5_BY_3) offset_H = 6
		var/offset_V = 2 //applies in each direction, so total vertical span is double this plus 1
		if(roomtype == RAND_3_BY_5) offset_V = 3

		. += block(T.x, T.y - offset_V, T.z, T.x, T.y + offset_V, T.z) //vertical along landmark column (consistent across directions)
		if(offset_to_west)
			. += block(T.x - offset_H, T.y - offset_V, T.z, T.x - offset_H, T.y + offset_V, T.z) //vertical at far end
			offset_H -= 1
			. += block(T.x - offset_H, T.y - offset_V, T.z, T.x - 1, T.y - offset_V, T.z) //below, from far to close
			. += block(T.x - offset_H, T.y + offset_V, T.z, T.x - 1, T.y + offset_V, T.z) //above, from far to close
		else
			. += block(T.x + offset_H, T.y - offset_V, T.z, T.x + offset_H, T.y + offset_V, T.z) //vertical at far end
			offset_H -= 1
			. += block(T.x + 1, T.y - offset_V, T.z, T.x + offset_H, T.y - offset_V, T.z) //below, from close to far
			. += block(T.x + 1, T.y + offset_V, T.z, T.x + offset_H, T.y + offset_V, T.z) //above, from close to far
		return

	///Retrieves all turfs associated with the new room (for addition to associated area).
	proc/get_whole_coverage(var/turf/T, var/offset_to_west, var/roomtype)
		. = list()
		var/offset_H = 4
		if(roomtype == RAND_5_BY_3) offset_H = 6
		var/offset_V = 2 //applies in each direction, so total vertical span is double this plus 1
		if(roomtype == RAND_3_BY_5) offset_V = 3

		if(offset_to_west)
			. = block(T.x - offset_H, T.y - offset_V, T.z, T.x, T.y + offset_V, T.z)
		else
			. = block(T.x, T.y - offset_V, T.z, T.x + offset_H, T.y + offset_V, T.z)
		return

	///Retrieves the turf the event should place a random room spawner onto.
	proc/get_room_spot(var/turf/T, var/offset_to_west, var/roomtype)
		var/horz_bump = 1
		if(offset_to_west)
			if(roomtype == RAND_5_BY_3)
				horz_bump = -5
			else
				horz_bump = -3

		if(roomtype == RAND_3_BY_5)
			. = locate(T.x + horz_bump, T.y - 2, T.z)
		else
			. = locate(T.x + horz_bump, T.y - 1, T.z)
		return

#undef RAND_3_BY_3
#undef RAND_3_BY_5
#undef RAND_5_BY_3

///please pardon the inconvenience, shedding some extra gravitons
/datum/random_event/menhir/gravity
	name = "A Shift in the Sands"
	message_delay = 1 MINUTE
	announcement_style = MENHIR_EVENT_NOTIFY_GLOBAL

	event_effect()
		var/list/candidate_landmarks = list()
		for (var/turf/T in landmarks[LANDMARK_HALLOWEEN_SPAWN])
			candidate_landmarks += T
		for (var/turf/T in landmarks[LANDMARK_MENHIR_OUTREACH])
			if(istype(get_area(T),/area/station/maintenance) && prob(50)) continue
			candidate_landmarks += T

		var/anomaly_count = rand(10,14)
		if(length(candidate_landmarks) < anomaly_count)
			logTheThing(LOG_DEBUG, null, "Menhir gravity event couldn't find enough anomaly sites! This shouldn't happen.")
			message_admins("Menhir gravity event couldn't find enough anomaly sites! This shouldn't happen. Aborting event")
			return

		playsound_global(world, 'sound/musical_instruments/artifact/Artifact_Precursor_3.ogg', 65, 0, pitch = 0.3)
		SPAWN(2) //approximately syncs sound
			for (var/mob/M in mobs)
				SPAWN(0)
					if (M.z == Z_LEVEL_STATION && !inafterlife(M) && !isVRghost(M))
						shake_camera(M, 6, 6)

		logTheThing(LOG_STATION, null, "Menhir gravity event triggered for [anomaly_count] locations. Baseline gravity amplified.")
		message_admins("Menhir gravity event triggered for [anomaly_count] locations. Baseline gravity amplified.")

		var/list/station_areas = get_accessible_station_areas()

		SPAWN(0.5 SECONDS)
			for (var/area_name in station_areas)
				LAGCHECK(LAG_LOW)
				var/area/A = station_areas[area_name]
				A.set_gforce_minimum(rand(150,250))

		SPAWN(1 SECOND)
			var/turf/rolling_target
			for(var/i = 1 to anomaly_count)
				rolling_target = pick(candidate_landmarks)
				candidate_landmarks.Remove(rolling_target)
				new /obj/anomaly/gravitational/minor(rolling_target, rand(10 SECONDS, 20 SECONDS))
				sleep(rand(4 SECONDS - anomaly_count, 4 SECONDS))

			for (var/area_name in station_areas)
				LAGCHECK(LAG_LOW)
				var/area/A = station_areas[area_name]
				A.set_gforce_minimum(GFORCE_GRAVITY_MINIMUM)
			logTheThing(LOG_STATION, null, "Menhir gravity event has finished spawning anomalies. Baseline gravity reset.")
			message_admins("Menhir gravity event has finished spawning anomalies. Baseline gravity reset.")

		message_delay = rand(12 SECONDS, 18 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_curious.ogg', MENHIR_STANDARD_ALERT_VOLUME)

//there are wisps of consciousness around. let's see if we can entice one
/datum/random_event/menhir/dreamcatcher
	name = "Thoughts Which Fall Like Rain"
	announcement_style = MENHIR_EVENT_NOTIFY_NONE

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (game_stats.GetStat("playerdeaths") < 1) //none have fallen, none may return
				. = FALSE
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		///Site the dreamcatcher spawns at; selects one of the outer nodes, adding a door to it and disqualifying it from further events
		var/turf/nodelandmark
		///Tag for the node the event is occurring in
		var/node_tag = null
		///List of eligible walls; divided by relative position.
		var/list/eligible_walls = list("S" = list(), "N" = list(), "E" = list(), "W" = list())
		///When we've populated a direction with at least one wall from each facing, we're good to go
		var/list/eligibility_flags = 0

		if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) return //manual call safeguard

		nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)
		node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

		for (var/turf/T in landmarks[LANDMARK_MENHIR_DOOR])
			if (landmarks[LANDMARK_MENHIR_DOOR][T] == node_tag)
				//categorize nodes based on positional block (set up this way to allow east/west entrance sides to be more than 1 door)
				if(T.x > nodelandmark.x)
					eligible_walls["E"] += T
					eligibility_flags |= EAST
				else if(T.x < nodelandmark.x)
					eligible_walls["W"] += T
					eligibility_flags |= WEST
				else
					if(T.y > nodelandmark.y)
						eligible_walls["N"] += T
						eligibility_flags |= NORTH
					else
						eligible_walls["S"] += T
						eligibility_flags |= SOUTH

		if (eligibility_flags < (NORTH|SOUTH|EAST|WEST))
			logTheThing(LOG_DEBUG, null, "Menhir dreamcatcher event didn't find all directions for the [node_tag] node! This shouldn't happen.")
			message_admins("Menhir dreamcatcher event didn't find all directions for the [node_tag] node! This shouldn't happen. Aborting event")
			return

		if(prob(60))
			playsound(nodelandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		var/facing_dir = pick("S","N","E","W")

		for(var/turf/wallturf in eligible_walls[facing_dir])
			var/save_dir = wallturf.icon_state
			var/obj/newdoor = new /obj/machinery/door/unpowered/blue(wallturf)
			if (save_dir == "interior-3") //vertical wall detection
				newdoor.dir = 4

		for(var/obj/effects/menhir_fog/O in range(1,nodelandmark)) //stick out to ghosts
			animate(O, alpha = 0, time = 3 SECONDS)
			SPAWN(4 SECONDS)
				qdel(O)

		SPAWN(5 SECONDS)
			for(var/obj/effects/menhir_fog/O in orange(2,nodelandmark))
				O.UpdateIcon()

		landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again

		new /obj/dreamcatcher(nodelandmark)

		..()

		logTheThing(LOG_STATION, null, "Menhir dreamcatcher event at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir dreamcatcher event triggered at [node_tag] arm - [log_loc(nodelandmark)]")

//////////////////////////////////////////////
///////////////////////////////////////////////////////
//////Uncommon (90-50 starting weight)/////////////////
///////////////////////////////////////////////////////
//////////////////////////////////////////////

//reaching farther, farther, for voice, for memory
/datum/random_event/menhir/tractorbeam
	name = "A Hand Outstretched In Yearning"
	message_delay = 5 SECONDS
	weight = 70
	announcement_style = MENHIR_EVENT_NOTIFY_GLOBAL
	centcom_message = "TOREADOR-7I-22408 has begun to project an intense directional electromagnetic field."
	var/list/fxobjects = list()

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (length(src.fxobjects))
				. = FALSE
			if (!landmarks[LANDMARK_MENHIR_BEYOND] || length(landmarks[LANDMARK_MENHIR_BEYOND]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		var/turf/farlandmark = pick(landmarks[LANDMARK_MENHIR_BEYOND])
		if(!farlandmark)
			logTheThing(LOG_DEBUG, null, "Menhir tractorbeam event couldn't find a turf to happen at; this shouldn't happen if event is random. Aborting event.")
			message_admins("Menhir tractorbeam event couldn't find a turf to happen at; this shouldn't happen if event is random. Aborting event.")
			return

		var/list/wanted_tags = get_prefab_tags()
		var/datum/mapPrefab/mining/mprefab = pick_map_prefab(/datum/mapPrefab/mining, wanted_tags_any=wanted_tags)
		for(var/i = 1 to 3) //try again a bit if we got a drone, we don't want those picked too often
			if(mprefab.prefabSizeX > 1)
				break
			mprefab = pick_map_prefab(/datum/mapPrefab/mining, wanted_tags_any=wanted_tags)
		if (!mprefab)
			logTheThing(LOG_DEBUG, null, "Menhir tractorbeam event had no mining-Z prefab to select; event was unable to fully conclude.")
			message_admins("Menhir tractorbeam event had no mining-Z prefab to select; event was unable to fully conclude.")
			return

		centcom_message = "TOREADOR-7I-22408 has begun to project an unusually intense electromagnetic field on the "
		centcom_message += landmarks[LANDMARK_MENHIR_BEYOND][farlandmark]
		centcom_message += " axis. Personnel are advised to discontinue any EVA and secure equipment for possible turbulence."

		message_delay = rand(2 SECONDS, 3 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_curious.ogg', MENHIR_STANDARD_ALERT_VOLUME)

		landmarks[LANDMARK_MENHIR_BEYOND].Remove(farlandmark)

		logTheThing(LOG_STATION, null, "Menhir tractorbeam event at [log_loc(farlandmark)]")
		message_admins("Menhir tractorbeam event triggered at [log_loc(farlandmark)]")

		var/turf/focal_nexus = locate(MENHIR_CORE_X, MENHIR_CORE_Y, Z_LEVEL_STATION)
		new /obj/effects/menhir_tractor_field(focal_nexus,8)
		var/far_fx_scale = ceil(max(mprefab.prefabSizeX,mprefab.prefabSizeY))
		new /obj/effects/menhir_tractor_field(farlandmark,far_fx_scale/3)

		SPAWN(1)
			var/list/coalesce_starts = new/list(12)
			var/list/coalesce_ends = new/list(12)
			for(var/turf/T in landmarks[LANDMARK_MENHIR_COALESCE])
				var/index = landmarks[LANDMARK_MENHIR_COALESCE][T]
				if(index > 12)
					coalesce_ends[index-12] = T
				else
					coalesce_starts[index] = T
			for(var/i in 1 to 20)
				var/chargevolume = 30
				if(i <= 12)
					var/turf/t_start = coalesce_starts[i]
					var/turf/t_end = coalesce_ends[i]
					var/obj/startfx = new /obj/effects(t_start)
					var/obj/endfx = new /obj/effects(t_end)
					src.fxobjects.Add(startfx)
					src.fxobjects.Add(endfx)
					src.fxobjects |= drawLineObj(startfx, endfx, /obj/line_obj/railgun, 'icons/obj/projectiles.dmi',"WholeRailG",1,1,"HalfStartRailG","HalfEndRailG",ABOVE_OBJ_LAYER,1)
					playsound(t_start, 'sound/weapons/energy/howitzer_firing.ogg', 40, 0, pitch = 0.45, extrarange = 24)
				chargevolume = 30 + (i * 3)
				playsound(focal_nexus, 'sound/items/med_scanner.ogg', chargevolume, 0, pitch = 0.5, extrarange = 48)
				sleep(1 SECOND)

			playsound_global(world, 'sound/machines/shielddown.ogg', 65, 0)
			SPAWN(2) //approximately syncs sound
				playsound_global(world, 'sound/effects/explosionfar.ogg', 65, 0)
				for (var/mob/M in mobs)
					SPAWN(0)
						if (M.z == Z_LEVEL_STATION && !inafterlife(M) && !isVRghost(M))
							shake_camera(M, 6, 6)

			for (var/obj/O in src.fxobjects)
				qdel(O)
			src.fxobjects = list()

			var/x_target_adj = farlandmark.x - floor(mprefab.prefabSizeX / 2)
			var/y_target_adj = farlandmark.y - floor(mprefab.prefabSizeY / 2)

			var/turf/target = locate(x_target_adj, y_target_adj, Z_LEVEL_STATION)
			var/ret = mprefab.applyTo(target)
			if(ret == 0)
				logTheThing(LOG_DEBUG, null, "Menhir tractorbeam event couldn't apply prefab (applyTo failure); event was unable to fully conclude.")
				message_admins("Menhir tractorbeam event couldn't apply prefab (applyTo failure); event was unable to fully conclude.")
				return

/obj/effects/menhir_tractor_field
	icon = 'icons/effects/96x96.dmi'
	icon_state = "circle"
	color = "#c300ff"
	layer = EFFECTS_LAYER_1
	blend_mode = BLEND_OVERLAY
	alpha = 0
	pixel_x = -32
	pixel_y = -32

	New(var/loc,var/end_scale = 1)
		..()
		animate(src, alpha = 80, time = 20 SECONDS, transform = matrix()*end_scale, easing = SINE_EASING | EASE_OUT)
		SPAWN(21 SECONDS)
			animate(src, alpha = 0, color = "#f5d3ff", time = 1 SECOND, easing = BACK_EASING)
			SPAWN(2 SECONDS)
				qdel(src)
			return

	disposing()
		if(particleMaster.CheckSystemExists(/datum/particleSystem/rads_warning, src))
			particleMaster.RemoveSystem(/datum/particleSystem/rads_warning)
		..()

//it's time to share your perspective.
/datum/random_event/menhir/resight
	name = "Through Another's Eyes"
	weight = 70

	event_effect()
		//First verify we have some people to mess with.
		var/list/eligible_examinees = get_menhir_event_candidates(EVFILTER_ONTURF)
		var/candidate_num = length(eligible_examinees)

		if (candidate_num < 3)
			logTheThing(LOG_STATION, null, "Menhir resight event has inadequate candidates ([candidate_num]/3); skipping event.")
			message_admins("Menhir resight event has inadequate candidates ([candidate_num]/3); skipping event.")
			return

		//And consider how many we'll swap. This is, at most, how many PAIRS of people will have their perspective exchanged.
		var/swapcount = floor(candidate_num/3)
		if (swapcount < 1) //always at least 1 pair
			swapcount = 1

		///String for recording who got swapped
		var/return_string = ""
		for(var/i in 1 to swapcount)
			if(!length(eligible_examinees)) break
			var/mob/candidate_A = pick(eligible_examinees)
			var/mob/candidate_B = null
			eligible_examinees -= candidate_A
			for(var/mob/M in eligible_examinees)
				if(GET_DIST(candidate_A,M) < 9) //we only want to swap people who are in visual range of each other
					candidate_B = M
					eligible_examinees -= M
					break

			if(candidate_A && candidate_B)
				SPAWN(1 SECOND)
					src.perception_swap(candidate_A,candidate_B)
				return_string += "[key_name(candidate_A)] and [key_name(candidate_A)]"
				if(i < swapcount) return_string += " | "

		message_delay = rand(18 SECONDS, 24 SECONDS)
		..()

		logTheThing(LOG_STATION, null, "Menhir resight event - perceptions swapped: [return_string]")
		message_admins("Menhir resight event - perceptions swapped: [return_string]")

	proc/perception_swap(var/mob/swapped_A,var/mob/swapped_B)
		var/swap_duration = rand(40 SECONDS,50 SECONDS)
		swapped_A.set_eye(swapped_B)
		swapped_B.set_eye(swapped_A)
		SPAWN(1)
			swapped_A.playsound_local_not_inworld('sound/musical_instruments/artifact/Artifact_Precursor_5.ogg', 55, 0, pitch = 0.45)
			swapped_B.playsound_local_not_inworld('sound/musical_instruments/artifact/Artifact_Precursor_5.ogg', 55, 0, pitch = 0.45)
		sleep(swap_duration)
		if(swapped_A) swapped_A.set_eye(null)
		if(swapped_B) swapped_B.set_eye(null)

//untangle the snare, untangle a prize
/datum/random_event/menhir/knot
	name = "A Receptacle of Reflection"
	message_delay = 3 MINUTES
	weight = 70

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		///Site the puzzle room spawns at
		var/turf/nodelandmark
		///Tag for the node the event is occurring in
		var/node_tag = null
		///List of walls associated with the node (we'll be installing doors onto these)
		var/list/walls_to_door = list()

		if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //fallback mode: pick a curated station tile instead
			logTheThing(LOG_DEBUG, null, "Menhir knot event couldn't find a fallback turf after all nodes expended; aborting event.")
			message_admins("Menhir knot event couldn't find a fallback turf after all nodes expended; aborting event.")
			return

		nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)
		node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

		for (var/turf/T in landmarks[LANDMARK_MENHIR_DOOR])
			if (landmarks[LANDMARK_MENHIR_DOOR][T] == node_tag)
				walls_to_door += T

		if (length(walls_to_door) < 4)
			logTheThing(LOG_DEBUG, null, "Menhir knot event couldn't find expected door count! This shouldn't happen.")
			message_admins("Menhir knot event couldn't find expected door count! This shouldn't happen. Aborting event")
			return

		landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again

		for(var/D in cardinal)
			var/turf/onestep = get_step(nodelandmark, D)
			var/turf/twostep = get_step(onestep, D)
			var/obj/precursor_puzzle/rotator/speen = new /obj/precursor_puzzle/rotator(twostep)
			speen.id = node_tag
			speen.dir = D
			speen.opacity = 0

		new /obj/rack/precursor/pressure/knot(nodelandmark)

		var/obj/precursor_puzzle/controller/hub = new /obj/precursor_puzzle/controller(nodelandmark)
		hub.pixel_y = -15
		hub.layer = 3.2
		hub.id = "[node_tag]"
		hub.tag = "controller_[node_tag]"
		hub.self_removing = TRUE
		hub.opacity = 0

		for(var/D in alldirs)
			var/turf/proxturf = get_step(nodelandmark,D)
			var/obj/precursor_puzzle/shield/S = new /obj/precursor_puzzle/shield(proxturf)
			S.id = node_tag
			S.dir = D

		if(prob(60))
			playsound(nodelandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		for(var/turf/wallturf in walls_to_door)
			var/save_dir = wallturf.icon_state
			var/obj/newdoor = new /obj/machinery/door/unpowered/blue(wallturf)
			if (save_dir == "interior-3") //vertical wall detection
				newdoor.dir = 4

		src.localize_reading(nodelandmark)

		message_delay = rand(2 MINUTES, 3 MINUTES)
		..() //don't send out the message until we have confirmed we can do the event

		logTheThing(LOG_STATION, null, "Menhir knot event at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir knot event triggered at [node_tag] arm - [log_loc(nodelandmark)]")

//////////////////////////////////////////////
///////////////////////////////////////////////////////
//////Rare (40-20 starting weight)/////////////////////
///////////////////////////////////////////////////////
//////////////////////////////////////////////

//the crown tries out one of its more novel machines
/datum/random_event/menhir/powersink
	name = "A Spire of Synthesis"
	message_delay = 1 MINUTE
	weight = 40
	announcement_style = MENHIR_EVENT_NOTIFY_GLOBAL
	centcom_message = "A sustained period of elevated electromagnetic activity from TOREADOR-7I-22408 is currently underway. Personnel are advised to monitor station power grid and deactivate supply if anomalous behavior is detected."

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			var/list/eligible_caretakers = get_menhir_event_candidates()
			if (!length(eligible_caretakers))
				. = FALSE

	event_effect()
		///Location of "outreach".
		var/turf/eventlandmark = pick_landmark(LANDMARK_MENHIR_OUTREACH)
		if (!istype(eventlandmark,/turf/simulated/floor) || is_blocked_turf(eventlandmark))
			eventlandmark = get_open_outreach()
			if(!eventlandmark)
				logTheThing(LOG_DEBUG, null, "Menhir powersink event couldn't find a turf to happen at; aborting event.")
				message_admins("Menhir powersink event couldn't find a turf to happen at; aborting event.")
				return

		showswirl(eventlandmark)
		playsound(eventlandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_4.ogg', 55, 0, extrarange = 24, pitch = 0.45)
		SPAWN(2)
			var/obj/sinkyboye = Artifact_Spawn(eventlandmark,forceartitype = /datum/artifact/synthesizer)
			sinkyboye.anchored = ANCHORED //give it a sec
			SPAWN(1 SECOND)
				sinkyboye.ArtifactActivated()

		//reading is deliberately not localized

		message_delay = rand(12 SECONDS,16 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', MENHIR_STANDARD_ALERT_VOLUME)
			SPAWN(message_delay + 20)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', MENHIR_STANDARD_ALERT_VOLUME)

		logTheThing(LOG_STATION, null, "Menhir powersink event at [log_loc(eventlandmark)]")
		message_admins("Menhir powersink event triggered at [log_loc(eventlandmark)]")

//////////////////////////////////////////////
///////////////////////////////////////////////////////
//////Megarare (10 starting weight)////////////////////
///////////////////////////////////////////////////////
//////////////////////////////////////////////

//sometimes, the door just unlocks itself
/datum/random_event/menhir/road
	name = "For Parted Are The Gates"
	message_delay = 30 SECONDS
	weight = 10
	announcement_style = MENHIR_EVENT_NOTIFY_GLOBAL

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_PASSAGE] || length(landmarks[LANDMARK_MENHIR_PASSAGE]) < 1)
				. = FALSE //the road is already open

	event_effect()
		if (!landmarks[LANDMARK_MENHIR_PASSAGE] || length(landmarks[LANDMARK_MENHIR_PASSAGE]) < 1) return //manual call safeguard
		for (var/turf/T in landmarks[LANDMARK_MENHIR_PASSAGE])
			if (istype(T,/turf/unsimulated/wall))
				var/save_dir = T.icon_state
				var/obj/newdoor = new /obj/machinery/door/unpowered/blue(T)
				if (save_dir == "interior-3") //vertical wall detection
					newdoor.dir = 4
			else
				showswirl(T)
				Artifact_Spawn(T,"precursor")

		playsound_global(world, 'sound/musical_instruments/artifact/Artifact_Precursor_5.ogg', 45, 0, 0.45)
		landmarks[LANDMARK_MENHIR_PASSAGE] = null

		message_delay = rand(5 SECONDS, 8 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_curious.ogg', MENHIR_STANDARD_ALERT_VOLUME)

		logTheThing(LOG_STATION, null, "Menhir road event triggered.")
		message_admins("Menhir road event triggered.")

//the ancient ones remembered in the deep of the Crown have noticed your presence. and SHIT IS GOIN DOWN
/datum/random_event/menhir/shadow
	name = "Of Memory Is Borne Lament"
	message_delay = 30 SECONDS
	required_elapsed_round_time = 22 MINUTES
	announcement_style = MENHIR_EVENT_NOTIFY_GLOBAL
	centcom_headline = "ARTIFACT CONDITION ALERT"
	centcom_message = "A massive spike in electromagnetic activity that does not match prior readings has been detected from TOREADOR-7I-22408. All personnel should immediately make ready for hazardous conditions."
	weight = 10

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			var/obj/machinery/door/unpowered/blue/seal = locate("vestibule_of_grief")
			if (!seal || seal.density) //the way has not been opened; is the disturbance great enough regardless?
				var/list/eligible_caretakers = get_menhir_event_candidates()
				if (length(eligible_caretakers) < 16)
					. = FALSE

			if (!landmarks[LANDMARK_MENHIR_DARK] || length(landmarks[LANDMARK_MENHIR_DARK]) < 1)
				. = FALSE //they have already made their ingress
	event_effect()
		if (!landmarks[LANDMARK_MENHIR_DARK] || length(landmarks[LANDMARK_MENHIR_DARK]) < 1) return //manual call safeguard
		for (var/turf/T in landmarks[LANDMARK_MENHIR_DARK])
			if (istype(T,/turf/unsimulated/wall))
				var/save_dir = T.icon_state
				var/obj/newdoor = new /obj/machinery/door/unpowered/blue(T)
				if (save_dir == "interior-3") //vertical wall detection
					newdoor.dir = 4
			else
				SPAWN(rand(0,200))
					new /mob/living/critter/shade/invader(T)

		playsound_global(world, 'sound/musical_instruments/artifact/Artifact_Void_2.ogg', 70, 0, 0.45)
		var/remusic = 110 SECONDS
		SPAWN(remusic)
			playsound_global(world, 'sound/musical_instruments/artifact/Artifact_Void_2.ogg', 70, 0, 0.45)

		SPAWN(rand(2 SECONDS, 3 SECONDS))
			playsound_global(world, pick(list('sound/voice/creepywhisper_1.ogg', 'sound/voice/creepywhisper_2.ogg', 'sound/voice/creepywhisper_3.ogg')), 60)
			for (var/obj/machinery/power/apc/apc in machine_registry[MACHINES_POWER])
				if (!istype(apc.area,/area/station/hallway/primary))
					continue
				apc.overload_lighting()

		for_by_tcl(light,/obj/map/light/cyan/menhir)
			SPAWN(rand(1,10))
				light.alterlight(0.42,0.3,0.3)

		message_delay = rand(5 SECONDS, 8 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.3)
			SPAWN(message_delay + 15)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.3)
			SPAWN(message_delay + 30)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.3)

		landmarks[LANDMARK_MENHIR_DARK] = null
		logTheThing(LOG_STATION, null, "Menhir shadow event triggered.")
		message_admins("Menhir shadow event triggered.")

#undef EVFILTER_HUMAN
#undef EVFILTER_ONTURF
#undef EVFILTER_NO_MOON

#endif
