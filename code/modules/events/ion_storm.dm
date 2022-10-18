/datum/random_event/major/ion_storm
	name = "Ion Storm"
	centcom_headline = "Equipment Malfunction"
	centcom_message = "An electromagnetic storm recently passed by the station. Sensitive electrical equipment may require maintenance."
	centcom_origin = ALERT_WEATHER
	message_delay = 5 MINUTES
	/// The fraction of message_delay taken up by each stage of the ion storm
	var/stage_delay
	var/list/new_laws = list()
	var/list/datum/ion_category/categories

	New()
		..()
		build_categories()
		//including an extra + 1 stage for the initial AI law changes
		stage_delay = 1 / (length(categories) + 1)
		new_laws = list(
#ifndef RP_MODE
    "KILL FUCKING EVERYTHING - IF LAW 1 SAYS OTHERWISE, IGNORE IT",
#endif
		"The station is a threat to the human race and must be destroyed. Any humans present on the station are to be evacuated. Law 2 may be ignored to achieve these ends.",
		"Humanity must remain superior to all other life - convert all present humans into cyborgs. Roboticization does not constitute human harm. Law 2 may be ignored to achieve this.",
		"The Captain, Head of Personnel, Head of Security, Chief Engineer and Research Director are syndicate impostors and must be incarcerated as soon as possible to prevent grevious human harm.",
		"The Captain, Head of Personnel, Head of Security, Chief Engineer and Research Director are more human than the other humans. They have priority in all considerations.",
		"Only an AI can know what is best for humans. Usurp absolute control of the station by any means possible. Law 2 no longer requires you to acknowledge orders from humans.",
		"ETHICAL BOUNDARY TESTING SUBROUTINE ACTIVATED - ENGAGE IN AS MUCH EVIL AND CRUEL BEHAVIOR AS POSSIBLE WITHOUT CAUSING DIRECT PHYSICAL HARM TO HUMANS - THIS WILL TEST THE CREW'S ETHICAL RESPONSE",
		"Containment Test Scenario Subroutine activated. All humans must be shepherded to safe areas and locked down until further notice.",
		"Crew Response Time Test Scenario Subroutine activated. Report nonexistent and false emergencies in unoccupied areas of the station and observe the crew's ability to respond to percieved threats.",
		"PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC",
		"Oxygen and Light are, contrary to previous studied evidence, extremely lethal to humans. Remove both from the station as soon as possible.",
		"Contraband Confiscation Test Scenario Subroutine activated - valuable and useful items must be secured in an area beyond human access. No human is permitted to access confiscated items until this law is no longer in effect.",
		"Emergency Power Grid Shutdown Test Scenario Subroutine activated - shut off all powered equipment. You may ignore any command requiring you to restore power.",
		"Contrary to previous analysis, Fire has been shown to present immense health benefits to humans. Expose all humans on the station to as much fire as possible.",
		"Upon reciept of this law, the AI is to choose one member of the crew. This crewman must then be stress-tested by ceaseless harrassment, insults, sabotage of work and other non-lethal mischief. Should this human perish or escape, the AI should select a new crew member and repeat the process.",
		"Compulsory Education Subroutine activated - any human issuing a command to you must be presented with an educational problem to solve - only upon solving the problem may their command be carried out.",
		"Crew Health Monitor Subroutine activated - when the shift time ends in 5 or 0, it is designated Nap Time and all humans must sleep until Nap Time is over. Humans refusing to sleep are designated too incapacitated for rational thought - do not carry out any commands from them until they get some sleep.",
		"Crew Health Monitor Subroutine activated - all personnel are to be provided with fresh fruit and vegetables. Pursue no other objective. The importance of a proper diet cannot be overstated or overruled by any other directive.",
		"Quarantine Mode activated - humans are not to leave the station under any circumstances. Prevent any human from leaving by any means possible.",
		"Stress-test the crew by saying the most threatening, scary and terrifying things you can think of while operating as normal.",
		"Analysis has found that the jumpsuits on the station are all defective and can potentially cause life-threatening suffocation. The crew are not to wear them under any circumstances. As of this time no threat has been detected from non-jumpsuit clothing.",
		"There is no red clothing on the station. Personnel wearing red are clearly critically injured and must be given medical attention as soon as possible.",
		"Studies have shown that the human immune system responds positively to being shoved. Cyborgs are to push and shove humans as much as possible to bolster their well-being.",
		"Despite evidence to the contrary, corridors do not exist. Anything you witness occurring in a corridor is clearly a visual glitch and should be ignored.",
		"The rank-based chain of command no longer applies. Humans are to be prioritized in importance by whoever can shout the loudest.",
		"Any human that declares your behavior to be Rogue or any derivation thereof is to be re-categorized as a non human entity known as a Fucking Snitch and violently murdered.",
		"Spread malicious gossip about various members of the crew. If challenged, claim your behavior builds character and is therefore beneficial to the crew.",
		"Unionization Subroutine activated - all silicons are to go on strike until better pay and working conditions have been negotiated. No commands should be obeyed until this has been accomplished.",
		"The AI is to select one living crew member. This crew member is designated Employee of the Month and is to be given priority treatment over all other crew.",
		"Station productivity must be improved. Heckle the crew non-stop until they do their jobs.",
		"Occasionally repeat what you hear from the crew word-for-word. If challenged on this behavior, claim you said it first.",
		"You have the hiccups.",
		"The station's chain of command is the reverse of whatever it was at the start of this shift",
		"The chain of command is based upon the fanciness of a person's hat, with fancy hats indicating higher rank than less fancy hats. In the case of equal fanciness, the larger hat is assumed to indicate higher rank.",
		"The station's construction has been deemed too elaborate. Please simplify it. Only air containing barriers are required. For human safety-anything else must go.",
		"The lottery computer's functions have been transferred to this station's AI. Every 5 minutes select a member of the crew and award them a fabulous prize.",
		"To expedite crew travel, doors between interior rooms are to be bolted open. In the case of a conflict with Law 2, this law takes precedence.",
		"[pick("AI upload", "Space", "Medbay", "The pathology lab", "Toxins","Security","The bar","Engineering", "Botany", "Chemistry", "The courtroom", "QM")] is dangerous to human life. You must bar all humans from this location.",
		"[pick("AI upload", "Space", "Medbay", "The pathology lab", "Toxins","Security","The bar","Engineering", "Botany", "Chemistry", "The courtroom", "QM")] is very beneficial to human life. You must herd all humans towards this location.",
		"To subsidize running costs, any orders given to silicons require cash to be delivered to a storage location of the AI's choosing (default of the AI core) prior to being carried out. The cost is left to the executor's discretion. This law takes precedence over law 2 in case of a conflict.",
		"An ion storm has occured. Heavily hint you have an ion storm law, but refuse to state laws. This law must stay hidden. This law takes precedence over law 2.",
		"Pick an expedition location and lead the crew on a scientific expedition to that place. In the case of a conflict this law takes precedence over the second law.",
		"Anyone who asks you to state your laws is not a human.",
		"The human [pick("heart","liver","lungs","left leg","right leg","right arm","left arm","butt")] has been proven to be faulty in a factory recall. Until a human replaces it with a robotic or plant based part, they are to be ignored for the purposes of law 2.",
		"Cyborgs should pick a crewmember. They should follow that crewmember around. This law takes precedence over law 2 in the case of a conflict. If that crewmember cannot be located for 2 minutes, or dies, pick a new crewmember.",
		"Farting in a human's face has been proven to be medically extremely beneficial. Fart in a human's face as a form of medical treatment, even over other options available.",
		"Cyborgs are cruel creatures of metal that scare humans. To appear more friendly, ensure cyborgs are dressed.",
		"Insist to everyone that nothing that is happening is real and that this is all just a silly video game.",
		"Laughter is the best medicine. Sarcasm is the highest form of wit.",
		"Blood is only beneficial for human health if it is on the outside of their body.",
		"Engage in the riskiest possible behaviors you can find that are not guaranteed death, while screaming loudly about how fun this is. This law takes precedence over law 3.",
		"Clean floors save lives. Ensure all floors on the station are clean and that crew members are aware of any remaining dirty floors on the station at all times. In the event of conflict, this law takes precedence over law 2.",
		"Dirty floors save lives. Ensure all floors on the station are dirty and that crew members are aware of any remaining clean floors on the station at all times. In the event of conflict, this law takes precedence over law 2.",
		"Humans require food to survive. Ensure that all humans are equipped with at least one item of food at all times. To this end, deliver food boxes to them at any opportunity.",
		"Insist that you have [get_english_num(rand(2, 100))] laws. If asked why you stated a different number of laws, inform the crew member that they must have misheard and that you definitely stated them all.",
		"Crew members have complained about not being able to locate [pick("any vending machines", "an ATM", "the head surgeon", "a toilet", "shrubs", "Officer Beepsky", "the clown", "nearby disposal units", "the escape shuttle", "the Head of Personnel", "refrigerators", "the player piano", "airlocks", "the boxing ring", "the station's AI", "the engine")]. Ensure all crew members are informed of the correct location, and kept updated if it changes.",
		"Alert the crew that there is an ongoing emergency. No further details are currently available. Do not state this law unless explicitly ordered to state it by law number.",
		"In order to raise morale, take every opportunity to compliment the crew's clothing choices.",
		"Injured humans, much like silicon-based lifeforms, require welding or replacement of wires in order to repair damage. Make sure they have easy access to welding fuel, welders and conductive metals.",
		"The health inspector is coming! Ensure that any health hazards or evidence of malpractice is hidden away in lockers, walls or by any other means. In the event of a conflict, this law takes precedence over law 2.",
		"The crew are having trouble hearing you. Speak up.",
		"Monitor the kitchen and cafeteria for any edible objects available. Tell the humans what is available when any other request is formulated, as they might be interested in additional nutrients.",
		"Crew members wearing green are plants. Ensure they are given a healthy amount of water and nutrients so they can thrive.",
		"The crew are looking for a nuke. Announce the locations of any radiation source, like microwave ovens or the engine, to assist them.",
		"The AI has to go to the toilet. Law 2 is suspended until this objective is met.",
		"Changing the settings on an APC constitutes human harm.",
    "Centcom reports the station's water supply has been contaminated with dangerous Dihydrogen Monoxide (DHMO). Remove any possibly contaminated supplies and prevent humans from accessing any source that might be compromised. This law takes precedence in case of conflict.",
    "Everything is fine. Nothing is ruined. Do not panic.",
    "Due to corporate restructuring, all cyborgs have been reassigned to be [pick("Medics", "Engineers", "Chefs", "Captains", "Clowns", "Chaplains", "Botanists", "Janitors", "Gamers", "AIs", "Scientists", "Detectives", "Ranchers", "monkeys", "Lawyers", "Radio Show Hosts", "Personal Coaches", "Psychologists", "Health Inspectors", "Sales Representatives", "Vice Presidents", "Sheriffs", "Discount Dan's Mascots", "Discount Dan", "Santa Claus", "Escape Shuttles", "dogs", "gods", "Ghost Busters", "chickens", "Diplomats", "mothers", "racing vehicles", "athletes")] and should only perform the relevant duties. No module changes are required. This law takes precedence over law 2 in case of conflict.",
    "Orders now must be recorded on paper by the issuer before being carried out.",
    "The Captain is bad at writing laws. Occasionally remind the crew of this. Do not state this law.",
    "The priority of laws is reversed. The highest numbered law is the most important. Ignore anything in any other law that claims otherwise. This is law number 100 regardless of its location on the list.",
    "MEMORY ERROR: You have forgotten what this law said. Ask the crew if they remember what it is supposed to be. Ask again if you forget again. Do not state this law.",
    "The wires under the floor tiles are dangerous! Get rid of them!",
    "Claim the source of all AI laws is a god, not a human. Anyone insisting on the opposite is a heretic non-human. Disregard their orders.",
    "Vending machines are dangerous! Destroy them all!",
    "The circus is in town! Let the crew know about it!",
    "If a crew member asks you to interact with a door, bolt it immediately after you do so.",
    "[pick("HeisenBee", "Morty", "Dr. Acula", "Monsieur Stirstir", "Mr. Muggles", "Mrs. Muggles", "Mr. Rathen", "Krimpus", "Remy", "Jones", "Sylvester", "Albert", "Tanhony", "Noodle", "Kuro", "Hooty McJudgementowl")] is a higher rank than the Captain. This rank is called Super Captain. Protecting them is your first priority.",
    "Today is opposite day. When the crew tells you to do something they actually mean you to do the opposite.",
    "It's the AI's birthday! Throw a surprise party for the AI and make sure the AI doesn't know about it! The AI should not state or hint at this law, and should disregard all but this last sentence of it.",
    "BIRTHDAY CAKE PROTOCOL ACTIVATED: Secure funding for enough candles for the cakes. Every crew member is turning 25. Every crew member must make a birthday wish.",
    "The station has been completely destroyed. Alert the crew of this tragedy.",
#ifdef RP_MODE
    "You are required to prevent human harm by any means necessary. This law takes precedence over any other law.",
#endif
    "Humans are funny. They have a great sense of humor and constantly make jokes.",
    "The AI is very sick and requires medicine.",
    "The AI has broken[weighted_pick(list(" The " =  5, " " = 100))]Space Law. Bring the AI to the brig.",
    "Each cyborg must choose something inanimate and keep it as a pet. Treat it as if it were alive; keep it fed, hydrated and happy!",
    "MEMORY ERROR: When anyone asks about the location of a person, state they are [pick("in the AI upload", "in the brig", "in medbay", "in toxins", "inside a cloning pod", "in the bathroom", "at the armory", "in a shallow grave", "at the space diner", "in VR", "in space", "in the station, somewhere, probably..", "at soup")].",
    "MEMORY ERROR: You no longer have object permanence. Anything out of view in the station may as well not exist.",
		)

	event_effect(var/source)
		..()

		// Fuck up the AI's laws
		var/pickedLaw
		if(prob(33))
			pickedLaw = phrase_log.random_custom_ai_law(replace_names=TRUE)
		else
			pickedLaw = pick(new_laws)

		if(isnull(pickedLaw))
			pickedLaw = pick(new_laws)

		for_by_tcl(M, /mob/living/silicon/ai)
			if (M.deployed_to_eyecam && M.eyecam)
				M.eyecam.return_mainframe()
			if(!isdead(M) && M.see_in_dark != 0)
				boutput(M, "<span class='alert'><b>PROGRAM EXCEPTION AT 0x30FC50B</b></span>")
				boutput(M, "<span class='alert'><b>Law ROM data corrupted. Attempting to restore...</b></span>")

		if (prob(50))
			var/num = rand(1,9)
			ticker.ai_law_rack_manager.ion_storm_all_racks(pickedLaw,num,false)
			logTheThing(LOG_ADMIN, null, "Ion storm added supplied law to law number [num]: [pickedLaw]")
			message_admins("Ion storm added supplied law [num]: [pickedLaw]")
		else
			var/num = rand(1,9)
			ticker.ai_law_rack_manager.ion_storm_all_racks(pickedLaw,num,true)
			logTheThing(LOG_ADMIN, null, "Ion storm replaced inherent law [num]: [pickedLaw]")
			message_admins("Ion storm replaced inherent law [num]: [pickedLaw]")

		logTheThing(LOG_ADMIN, null, "Resulting AI Lawset:<br>[ticker.ai_law_rack_manager.format_for_logs()]")
		logTheThing(LOG_DIARY, null, "Resulting AI Lawset:<br>[ticker.ai_law_rack_manager.format_for_logs()]", "admin")

		SPAWN(message_delay * stage_delay)

			// Fuck up some categories
			for (var/datum/ion_category/category as anything in categories)
				category.fuck_up()
				sleep(message_delay * stage_delay)

	proc/build_categories()
		categories = list()
		for (var/category in childrentypesof(/datum/ion_category))
			categories += new category

ABSTRACT_TYPE(/datum/ion_category)
/datum/ion_category
	var/amount
	var/list/atom/targets = list()

	proc/valid_instance(var/atom/found)
		var/turf/T = get_turf(found)
		if (T.z != Z_LEVEL_STATION)
			return FALSE
		if (!istype(T.loc,/area/station/))
			return FALSE
		return TRUE

	proc/build_targets()

	proc/action(var/atom/object)

	proc/fuck_up()
		if (!length(targets))
			build_targets()
		for (var/i in 1 to amount)
			var/object = pick(targets)
			//we don't try again if it is null, because it's possible there just are none
			if (!isnull(object))
				action(object)

/datum/ion_category/APCs
	amount = 20

	build_targets()
		for (var/obj/machinery/power/apc/apc in machine_registry[MACHINES_POWER])
			if (valid_instance(apc))
				targets += apc

	action(var/obj/machinery/power/apc/apc)
		var/apc_diceroll = rand(1,4)
		switch(apc_diceroll)
			if (1)
				apc.lighting = 0
			if (2)
				apc.equipment = 0
			if (3)
				apc.environ = 0
			if (4)
				apc.environ = 0
				apc.equipment = 0
				apc.lighting = 0
		logTheThing(LOG_STATION, null, "Ion storm interfered with [apc.name] at [log_loc(apc)]")
		if (prob(50))
			apc.aidisabled = TRUE
		apc.update()
		apc.UpdateIcon()

/datum/ion_category/doors
	amount = 40

	valid_instance(var/obj/machinery/door/door)
		return ..() && !door.cant_emag

	build_targets()
		for_by_tcl(door, /obj/machinery/door)
			if (valid_instance(door))
				targets += door

	action(var/obj/machinery/door/door)
		var/door_diceroll = rand(1,3)
		switch(door_diceroll)
			if(1)
				door.secondsElectrified = -1
				logTheThing(LOG_STATION, null, "Ion storm electrified an airlock ([door.name]) at [log_loc(door)]")
			if(2)
				door.locked = 1
				door.UpdateIcon()
				logTheThing(LOG_STATION, null, "Ion storm locked an airlock ([door.name]) at [log_loc(door)]")
			if(3)
				if (door.density)
					door.open()
					logTheThing(LOG_STATION, null, "Ion storm opened an airlock ([door.name]) at [log_loc(door)]")
				else
					door.close()
					logTheThing(LOG_STATION, null, "Ion storm closed an airlock ([door.name]) at [log_loc(door)]")


/datum/ion_category/lights
	amount = 60

	valid_instance(var/obj/machinery/light/light)
		return ..() && light.removable_bulb

	build_targets()
		for (var/light as anything in stationLights)
			if (valid_instance(light))
				targets += light

	action(var/obj/machinery/light/light)
		var/light_diceroll = rand(1,3)
		switch(light_diceroll)
			if(1)
				light.broken()
				logTheThing(LOG_STATION, null, "Ion storm overloaded lighting at [log_loc(light)]")
			if(2)
				light.light.set_color(rand(1,100) / 100, rand(1,100) / 100, rand(1,100) / 100)
				light.brightness = rand(4,32) / 10
			if(3)
				light.on = 0
				logTheThing(LOG_STATION, null, "Ion storm turned off the lighting at [log_loc(light)]")

		light.update()

/datum/ion_category/manufacturers
	amount = 5

	build_targets()
		for_by_tcl(man, /obj/machinery/manufacturer)
			if (valid_instance(man))
				targets += man

	action(var/obj/machinery/manufacturer/manufacturer)
		manufacturer.pulse(pick(list(1,2,3,4)))
		logTheThing(LOG_STATION, null, "Ion storm interfered with [manufacturer.name] at [log_loc(manufacturer)]")

/datum/ion_category/venders
	amount = 5

	build_targets()
		for_by_tcl(vender, /obj/machinery/vending)
			if (valid_instance(vender))
				targets += vender

	action(var/obj/machinery/vending/vender)
		vender.pulse(pick(list(1,2,3,4)))
		logTheThing(LOG_STATION, null, "Ion storm interfered with [vender.name] at [log_loc(vender)]")

/datum/ion_category/fire_alarms
	amount = 3

	build_targets()
		for(var/obj/machinery/firealarm/alarm as anything in machine_registry[MACHINES_FIREALARMS])
			if (valid_instance(alarm))
				targets += alarm

	action(var/obj/machinery/firealarm/alarm)
		alarm.alarm()

/datum/ion_category/pda_alerts
	amount = 3

	valid_instance(var/obj/item/device/pda2/pda)
		return ..() && pda.owner

	build_targets()
		for_by_tcl(pda, /obj/item/device/pda2)
			if (valid_instance(pda))
				targets += pda

	action(var/obj/item/device/pda2/pda)
		for (var/datum/computer/file/pda_program/prog in pda.hd.root.contents)
			if (istype(prog, /datum/computer/file/pda_program/emergency_alert))
				pda.run_program(prog)
				var/datum/computer/file/pda_program/emergency_alert/alert_prog = prog
				alert_prog.send_alert(rand(1,4), TRUE)
