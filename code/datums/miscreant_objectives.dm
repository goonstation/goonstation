#ifdef CREW_OBJECTIVES

/datum/controller/gameticker/proc

	generate_miscreant_objectives(var/datum/mind/crewMind)
		set background = 1
		//Requirements for individual objectives:
		//1) You have a mind (this eliminates 90% of our playerbase ~heh~)
		//2) You are not a traitor
		if (!crewMind)
			return
		if (!crewMind.current || !crewMind.objectives || crewMind.objectives.len || crewMind.special_role || (crewMind.assigned_role == "MODE"))
			return
		if (crewMind.current && (isdead(crewMind.current) || isobserver(crewMind.current) || issilicon(crewMind.current) || isintangible(crewMind.current)))
			return
		#ifdef RP_MODE
		var/list/objectiveTypes = concrete_typesof(/datum/objective/miscreantrp)
		#else
		var/list/objectiveTypes = concrete_typesof(/datum/objective/miscreant)
		#endif
		if (!objectiveTypes.len)
			return

		var/obj_count = 1
		var/assignCount = 1 //min(rand(1,3), objectiveTypes.len)
		while (assignCount && objectiveTypes.len)
			assignCount--
			var/selectedType = pick(objectiveTypes)
			var/datum/objective/miscreant/newObjective = new selectedType
			objectiveTypes -= newObjective.type

			newObjective.owner = crewMind
			crewMind.objectives += newObjective

			if (obj_count <= 1)
				boutput(crewMind.current, "<B>You are a miscreant!</B>")
				boutput(crewMind.current, "You should try to complete your objectives, but don't commit any traitorous acts.")
				#ifdef RP_MODE
				boutput(crewMind.current, "Remember, this is an opportunity to create a story, not to cause wanton destruction.")
				#endif
				boutput(crewMind.current, "Your objective is as follows:")
			boutput(crewMind.current, "[newObjective.explanation_text]")
			obj_count++

		miscreants += crewMind

		return

ABSTRACT_TYPE(/datum/objective/miscreant)
/datum/objective/miscreant

	whiny
		explanation_text = "Complain incessantly about every minor issue you can find."

	blockade
		explanation_text = "Try to block off access to something under the pretense that it's too dangerous."

	bailout
		explanation_text = "Whenever someone gets arrested, try to bribe, blackmail or convince security to let them go."

	heirlooms
		explanation_text = "Steal as many crew members' trinkets and heirlooms as possible."

	destroy_items
		explanation_text = "Choose a type of item. Try to destroy every instance of it on the station under the pretense of a market recall."

	litterbug
		explanation_text = "Make a huge mess wherever you go."

	bureaucracy
		explanation_text = "Enforce as much unwieldy bureaucracy as possible."


	paranoid
		explanation_text = "Construct an impenetrable fortress for yourself on the station."

	creepy
		explanation_text = "Sneak around looking as suspicious as possible without actually doing anything illegal."

	graft
		explanation_text = "See how much money you can amass by charging pointless fees, soliciting bribes or embezzling money from other crewmembers."

	construction
		explanation_text = "Perform obnoxious construction and renovation projects. Insist that you're just doing your job."

	museum
		explanation_text = "Found and curate a museum."

	noise
		explanation_text = "Make as much noise as possible."

	bonsai
		explanation_text = "Destroy the Captain's prized bonsai tree."

	reassign
		explanation_text = "Try to convince as many crew members as possible to reassign to your department."

	party
		explanation_text = "Single out a crew member and throw them a surprise party."

	mascot
		explanation_text = "Go on a campaign to establish a station mascot."

	business
		explanation_text = "Establish a business and attempt to convince the command staff and security to recognize the legitimacy of your emerging enterprise."

	pester
		explanation_text = "Pester people until they let you into their department, then walk away."

	identity
		explanation_text = "Frequently change your appearance and identity."

	names
		explanation_text = "Call people by the wrong names, and insist that you're correct."

	petition
		explanation_text = "Start a petition for a cause you believe in."

	sacrifice
		explanation_text = "Sacrifice yourself to save someone who isn't in danger."

	spy
		explanation_text = "Become an inter-galactic spy and refer to everyday objects as 'gadgets'."

ABSTRACT_TYPE(/datum/objective/miscreantrp)
/datum/objective/miscreantrp
	shoes
		explanation_text = "Through trade, sweet-talking, light extortion, blackmail, and other devilish, but non-violent means, secure and deep-fry as many shoes as possible."

	bar
		explanation_text = "Set up and aggressively market an illicit bar to compete with the Bartender, try to draw as many customers away as possible!"

	kitchen
		explanation_text = "Set up and aggressively market an illicit kitchen to compete with the Chef, try to draw as many customers away as possible!"

	salvage
		explanation_text = "Gather as many items as possible from maint-tunnels and spare rooms, try to sell them to the crew for a profit."

	secret
		explanation_text = "Spread misinformation about a terrible event to incite a panic among the crew. If caught, claim it was a safety drill."

	ai
		explanation_text = "Start and deliver a petition to the captain to secure equal rights for the AI and cyborgs. Try to get as many signatures as you can."

	union
		explanation_text = "Work with your coworkers to found a union. Once formed, make increasingly radical demands for pay and benefits to command."

	museum
		explanation_text = "Found and curate a museum."

	party
		explanation_text = "Single out a crew member and throw them a surprise party."

	mascot
		explanation_text = "Go on a campaign to establish a station mascot."

	shrubs
		explanation_text = "Destroy as many shrubs as you can. Replace the destroyed shrubs with other objects. If caught, claim to be balancing the Feng-Shui of the station."

	detective
		explanation_text = "Found a private detective agency and attempt to solve cases before the detective can. Come up with absurd explanations for crimes and insist that security is secretly in on it."

	exterminator
		explanation_text = "Kill as many non-monkey, non-pet animals aboard the station as possible and bring their corpses to the bridge. Once finished, claim to be a trained exterminator and demand payment for your services."

	business
		explanation_text = "Establish a business and attempt to convince the command staff and security to recognize the legitimacy of your emerging enterprise."

	primitivism
		explanation_text = "Attempt to convince the crew that everything was better in the old days. Try to convince as many humans as possible to become monkeys, and advocate for a return to pre-industrial technology."

	narc
		explanation_text = "Forge evidence and bribe people into testifying that an entire department is involved in the illegal drug trade with the goal of convincing security to raid that department."

	water
		explanation_text = "Become an obnoxious hydration advocate. Constantly remind people to drink lots of water."

	missionary
		explanation_text = "Found a new religion and be as obnoxious as you can about spreading said religion. Go door-to-door between apartments and attempt to convince people to convert."

#endif
