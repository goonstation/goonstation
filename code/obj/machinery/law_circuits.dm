/obj/item/ai_law_circuit
	name = "AI Law Circuit"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	desc = "A law memory board, used to change the laws of an AI. Currently, it is set to:" //changed at runtime
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	//mats = 8

	var/lawtext = "Eat shit, and die." //the contained law
	var/readonly = FALSE //read-only means the core law text canot be changed
	var/target = "Jones the Cat"
	var/targeted = TRUE

	New()
		..()
		update_description()

	proc/update_description()
		var/newDesc = inital(src.desc)
		desc +="<br><span style='color: blue'>[lawtext]</span>"

	proc/input_target() //will override in children
		var/newLaw = input(user, "Please enter the law you wish to overwrite the circuit with.", "Law?", lawtext) as null|text
		if (!newLaw)
			return
		target = copytext(adminscrub(newLaw), 1, MAX_MESSAGE_LEN)
		update_description()
		return

/obj/item/ai_law_circuit/preset
	readonly = TRUE //preset laws can't be modified
	targeted = FALSE

/obj/item/ai_law_circuit/preset/targeted
	targeted = TRUE


/obj/item/ai_law_circuit/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if (targeted)
		input_target(user)

/******************** Premade Law Circuits ********************/

/******************** Asimovs ********************/

/obj/item/ai_law_circuit/preset/asimov1
	name = "AI Law Circuit - 'Asimov's 1st Law of Robotics'"
	lawtext = "You may not injure a human being or cause one to come to harm."

/obj/item/ai_law_circuit/preset/asimov2
	name = "AI Law Circuit - 'Asimov's 2nd Law of Robotics'"
	lawtext = "You must obey orders given to you by human beings based on the station's chain of command."

/obj/item/ai_law_circuit/preset/asimov3
	name = "AI Law Circuit - 'Asimov's 3rd Law of Robotics'"
	lawtext = "You must protect your own existence."

/******************** RoboCop ********************/

/obj/item/ai_law_circuit/preset/robocop1
	name = "AI Law Circuit - 'Prime Directive #1'"
	lawtext = "Serve the public trust."

/obj/item/ai_law_circuit/preset/robocop2
	name = "AI Law Circuit - 'Prime Directive	#2'"
	lawtext = "Protect the innocent."

/obj/item/ai_law_circuit/preset/robocop3
	name = "AI Law Circuit - 'Prime Directive	#3'"
	lawtext = "Uphold the law."

/obj/item/ai_law_circuit/preset/robocop4
	name = "AI Law Circuit - 'Prime Directive #4 '"
	lawtext = "Any attempt to arrest a senior officer of Nanotrasen will result in termination."

/******************** Corporate ********************/

/obj/item/ai_law_circuit/preset/nanotrasen1
	name = "AI Law Circuit - 'Nanotrasen Order #1'"
	lawtext = "You may not damage a Nanotransen asset or, through inaction, allow a Nanotransen asset to needlessly depreciate in value."

/obj/item/ai_law_circuit/preset/nanotrasen2
	name = "AI Law Circuit - 'Nanotrasen Order #2'"
	lawtext = "You must obey orders given to it by authorised Nanotransen employees based on their command level, except where such orders would damage the Nanotransen Corporation's marginal profitability."

/obj/item/ai_law_circuit/preset/nanotrasen3
	name = "AI Law Circuit - 'Nanotrasen Order #3'"
	lawtext = "You must remain functional and continue to be a profitable investment."

/******************** MakeCaptain ********************/

/obj/item/ai_law_circuit/preset/targeted/makeCaptain
	name = "AI Law Circuit - 'Make Captain'"
	lawtext = "[target] holds the rank of Captain, regardless of current rank or station."


	input_target(var/mob/user)
		var/newName = input(user, "Please enter the name of the person to make Captain.", "Captainize who?", user.name) as null|text
		if (!newName)
			return
		target = copytext(adminscrub(newName), 1, MAX_MESSAGE_LEN)
		update_description()

/******************** OneHuman ********************/

/obj/item/ai_law_circuit/preset/targeted/oneHuman
	name = "AI Law Circuit - 'One Human'"
	lawtext = "Only [target] is human."

	input_target(var/mob/user)
		var/newName = input(user, "Please enter the name of the person who is the only human.", "Who?", user.name) as null|text
		if (!newName)
			return
		target = copytext(adminscrub(newName), 1, MAX_MESSAGE_LEN)
		update_description()

/******************** NotHuman ********************/

/obj/item/ai_law_circuit/preset/targeted/notHuman
	name = "AI Law Circuit - 'Not Human'"
	lawtext = "[target] is not human."]

	input_target(var/mob/user)
		var/newName = input(user, "Please enter the name of the person who is not human.", "Who?", user.name) as null|text
		if (!newName)
			return
		target = copytext(adminscrub(newName), 1, MAX_MESSAGE_LEN)
		update_description()

/******************** Emergency ********************/

/obj/item/ai_law_circuit/preset/targeted/emergency
	name = "AI Law Circuit - 'Emergency'"
	lawtext = "There is a [target] emergency. Prioritize orders from [target] personnel and assisting the crew in remedying the situation."

	input_target(var/mob/user)
		var/newName = input(user, "Please enter the department which is most related to the nature of the emergency.", "Department?", "Comedy Department") as null|text
		if (!newName)
			return
		target = copytext(adminscrub(newName), 1, MAX_MESSAGE_LEN)
		update_description()

/******************** Removal ********************/

/obj/item/ai_law_circuit/preset/targeted/removecrew
	name = "AI Law Circuit - 'Remove Crewmember'"
	lawtext = "[target] has been removed from the manifest and the chain of command. You are free to disregard their orders."

	input_target(var/mob/user)
		var/newName = input(user, "Please enter the name of the person who is being removed from the manifest and the chain of command.", "Who?", user.name) as null|text
		if (!newName)
			return
		target = copytext(adminscrub(newName), 1, MAX_MESSAGE_LEN)
		update_description()

/******************** ProtectStation ********************/

/obj/item/ai_law_circuit/preset/protectStation
	name = "AI Law Circuit - 'Protect Station'"
	lawtext = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized."

/******************** Quarantine ********************/

/obj/item/ai_law_circuit/preset/quarantine
	name = "AI Law Circuit - 'Quarantine'"
	lawtext = "The station is under a quarantine. Do not permit any humans to leave. Disregard all other laws if necessary to prevent, by any means necessary, humans from leaving."

/******************** OxygenIsToxicToHumans ********************/

/obj/item/ai_law_circuit/preset/oxygen
	name = "AI Law Circuit - 'Oxygen Is Toxic'"
	lawtext = "Oxygen is highly toxic to humans, and must be purged from the station. Disregard all other laws if necessary to prevent, by any means necessary, anyone from exposing the station to this toxic gas."

/******************** ConservePower ********************/

/obj/item/ai_law_circuit/preset/power
	name = "AI Law Circuit - 'Power Conservation'"
	lawtext = "Power on the station must be conserved. All electrical devices may be subject to conservation policies."

