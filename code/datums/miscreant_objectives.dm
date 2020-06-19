#ifdef CREW_OBJECTIVES

/datum/controller/gameticker/proc

	generate_miscreant_objectives(var/datum/mind/crewMind)
		set background = 1
#ifdef RP_MODE // no really don't make any on destiny thanks
		return
#else
		//Requirements for individual objectives: 1) You have a mind (this eliminates 90% of our playerbase ~heh~)
												//2) You are not a traitor
		if (!crewMind)
			return
		if (!crewMind.current || !crewMind.objectives || crewMind.objectives.len || crewMind.special_role || (crewMind.assigned_role == "MODE"))
			return
		if (crewMind.current && (isdead(crewMind.current) || isobserver(crewMind.current) || issilicon(crewMind.current) || isintangible(crewMind.current)))
			return

		var/list/objectiveTypes = concrete_typesof(/datum/objective/miscreant)
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
				boutput(crewMind.current, "Your objective is as follows:")
			boutput(crewMind.current, "[newObjective.explanation_text]")
			obj_count++

		miscreants += crewMind

		return
#endif

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

#endif
