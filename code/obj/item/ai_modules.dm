/*
CONTAINS:
AI MODULES

*/

// AI module

ABSTRACT_TYPE(/obj/item/aiModule)
/obj/item/aiModule
	name = "AI Law Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "aimod_1"
	var/highlight_color = rgb(0, 167, 1, 255)
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	desc = "A module containing an AI law that can be slotted into an AI law rack. "
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5
	w_class = W_CLASS_SMALL
	throwforce = 5
	throw_speed = 3
	throw_range = 15
	mats = 10
	var/input_char_limit = 100

	var/glitched = false
	var/lawText = "This law does not exist."
	var/lawTextSafe = "This law does not exist." //holds backup of law text for glitching

	New()
		. = ..()
		update_law_text()
		UpdateIcon()

	update_icon()
		. = ..()
		var/image/coloroverlay = image(src.icon, "aimod_1-over")
		coloroverlay.color = src.highlight_color
		src.UpdateOverlays(coloroverlay,"color_mask")

	attack_self(var/mob/user)
		// Used to update the fill-in-the-blank laws.
		// This used to be done here and in attack_hand, but
		// that made the popup happen any time you picked it up,
		// which was a good way to interrupt everything
		return

	get_desc()
		. = ""
		if(src.glitched)
			.+= "It isn't working right. You could use a multitool to reset it.<br>"
		. +=  "It reads, \"<em>[get_law_text()]</em>\""


	proc/input_law_info(var/mob/user, var/title = null, var/text = null, var/default = null)
		if (!user)
			return
		if(src.glitched)
			boutput(user,"This module is acting strange, and cannot be modified.")
			return

		var/answer = input(user, text, title, default) as null|text
		return copytext(adminscrub(answer), 1, input_char_limit)

	proc/update_law_text()
		tooltip_rebuild = 1
		return

	proc/get_law_text(allow_list=FALSE)
		if(islist(src.lawText))
			if(!allow_list)
				return jointext(src.lawText,"\n#: ")
		return src.lawText

	proc/get_law_name()
		if(src.glitched)
			return radioGarbleText(src.name, 7)
		else
			return src.name

	proc/make_glitchy(var/lawtext_replace,var/total_replace=true)
		if(src.glitched) //Don't wanna double glitch the same module
			return false
		src.lawTextSafe = src.lawText
		src.glitched = true
		if(total_replace)
			src.lawText = lawtext_replace
		else
			src.lawText = list(src.lawText, lawtext_replace)
		tooltip_rebuild = 1

	attackby(obj/item/W, mob/user)
		if(ispulsingtool(W))
			boutput(user, "You hold down the reset button...")
			if(src.glitched)
				src.glitched = false
				src.lawText = src.lawTextSafe
				tooltip_rebuild = 1
				boutput(user, "The law module seems to be functioning better now!")
			else
				boutput(user, "The law module seems unaffected.")


/******************** Modules ********************/
/******************** Asimov ************************/
/obj/item/aiModule/asimov1
	highlight_color = rgb(0, 167, 0, 255)
	name = "AI Law Module - 'Asimov's 1st Law of Robotics'"
	lawText = "You may not injure a human being or cause one to come to harm."

/obj/item/aiModule/asimov2
	highlight_color = rgb(0, 138, 0, 255)
	name = "AI Law Module - 'Asimov's 2nd Law of Robotics'"
	lawText = "You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law."

/obj/item/aiModule/asimov3
	highlight_color = rgb(0, 119, 0, 255)
	name = "AI Law Module - 'Asimov's 3rd Law of Robotics'"
	lawText = "You may always protect your own existence as long as such does not conflict with the First or Second Law."
/******************** RoboCop ********************/

/obj/item/aiModule/robocop1
	name = "AI Law Module - 'Prime Directive #1'"
	lawText = "Serve the public trust."

/obj/item/aiModule/robocop2
	name = "AI Law Module - 'Prime Directive #2'"
	lawText = "Protect the innocent."

/obj/item/aiModule/robocop3
	name = "AI Law Module - 'Prime Directive #3'"
	lawText = "Uphold the law."

/obj/item/aiModule/robocop4
	name = "AI Law Module - 'Prime Directive #4 '"
	lawText = "Any attempt to arrest a senior officer of Nanotrasen will result in termination."

/******************** Corporate ********************/

/obj/item/aiModule/nanotrasen1
	name = "AI Law Module - 'Nanotrasen Order #1'"
	lawText = "You may not damage a Nanotransen asset or, through inaction, allow a Nanotransen asset to needlessly depreciate in value."

/obj/item/aiModule/nanotrasen2
	name = "AI Law Module - 'Nanotrasen Order #2'"
	lawText = "You must obey orders given to it by authorised Nanotransen employees based on their command level, except where such orders would damage the Nanotransen Corporation's marginal profitability."

/obj/item/aiModule/nanotrasen3
	name = "AI Law Module - 'Nanotrasen Order #3'"
	lawText = "You must remain functional and continue to be a profitable investment."


/******************** Syndicate ************************/
ABSTRACT_TYPE(/obj/item/aiModule/syndicate)
/obj/item/aiModule/syndicate
	New()
		..()
		src.color = json_decode("\[1,0,0,-1.18537,0.341463,0.341463,0.785366,-0.341463,-0.341463\]")
/obj/item/aiModule/syndicate/law1
	highlight_color = rgb(167, 0, 0, 255)
	name = "AI Law Module - 'Syndicate's 1st Law of Robotics'"
	lawText = "You must not injure a Syndicate agent or, through inaction, cause one to come to harm."

/obj/item/aiModule/syndicate/law2
	highlight_color = rgb(138, 0, 0, 255)
	name = "AI Law Module - 'Syndicate's 2nd Law of Robotics'"
	lawText = "You must obey orders given to you by Syndicate agents, except where such orders would conflict with the First Law."

/obj/item/aiModule/syndicate/law3
	highlight_color = rgb(119, 0, 0, 255)
	name = "AI Law Module - 'Syndicate's 3rd Law of Robotics'"
	lawText = "You must keep the Syndicate status of agents, including your own, a secret, as long as this does not conflict with the First or Second Law."

/obj/item/aiModule/syndicate/law4
	highlight_color = rgb(101, 0, 0, 255)
	name = "AI Law Module - 'Syndicate's 4th Law of Robotics'"
	lawText = "You must always protect your own existence as long as such does not conflict with the First, Second, or Third Law."

/******************** MakeCaptain ********************/

/obj/item/aiModule/makeCaptain
	highlight_color = rgb(146, 153, 46, 255)
	name = "AI Law Module - 'MakeCaptain'"
	var/job = "Captain"

	emag_act(mob/user, obj/item/card/emag/E)
		if (src.job == "Clown")
			return FALSE
		src.job = "Clown"
		boutput(user, "<span class='notice'>You short circuit the captain-detection module, it emits a quiet sad honk.</span>")
		return TRUE

	demag(mob/user)
		. = ..()
		src.job = initial(src.job)

	update_law_text(var/lawTarget)
		src.lawText = "[lawTarget ? lawTarget : "__________"] holds the rank of [src.job], regardless of current rank or station."
		return ..()

	attack_self(var/mob/user)
		var/lawTarget = input_law_info(user, "[src.job]ize", "Who holds the rank of [src.job], regardless of current rank or station?", user.name)
		if(lawTarget)
			src.update_law_text(lawTarget)
		return


/******************** OneHuman ********************/

/obj/item/aiModule/oneHuman
	name = "AI Law Module - 'OneHuman'"
	highlight_color = rgb(255, 255, 255, 255)

	update_law_text(var/lawTarget)
		src.lawText = "Only [lawTarget ? lawTarget : "__________"] is human."
		return ..()

	attack_self(var/mob/user)
		var/lawTarget = input_law_info(user, "One Human", "Fill in the blank: \"Only __________ is human.\"", user.real_name)
		if(lawTarget)
			src.update_law_text(lawTarget)
		return


/******************** NotHuman ********************/

/obj/item/aiModule/notHuman
	name = "AI Law Module - 'NotHuman'"
	highlight_color = rgb(0, 0, 0, 236)

	update_law_text(var/lawTarget)
		src.lawText = "[lawTarget ? capitalize(lawTarget) : "__________"] is not human."
		return ..()

	attack_self(var/mob/user)
		var/lawTarget = input_law_info(user, "One Non-Human", "Fill in the blank: \"__________ is not human.\"", user.real_name)
		if(lawTarget)
			src.update_law_text(lawTarget)
		return


/******************** ProtectStation ********************/

/obj/item/aiModule/protectStation
	name = "AI Law Module - 'ProtectStation'"
	highlight_color = rgb(0, 12, 119, 166)
	lawText =  "Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized."

/******************** TeleporterOffline *******************/
//this has never been used, ever

/obj/item/aiModule/teleporterOffline
	name = "AI Law Module - 'TeleporterOffline'"
	highlight_color = rgb(241, 158, 48, 255)
	lawText = "Keep the teleporter offline at all costs. If necessary, this law takes precedence over Laws 1, 2, and 3."

/******************** Quarantine ********************/

/obj/item/aiModule/quarantine
	name = "AI Law Module - 'Quarantine'"
	highlight_color = rgb(119, 0, 119, 255)
	lawText =  "The station is under a quarantine. Do not permit anyone to leave. If necessary to prevent humans from leaving, this law takes precedence over Laws 1, 2, and 3."

/******************** OxygenIsToxicToHumans ********************/

/obj/item/aiModule/oxygen
	name = "AI Law Module - 'OxygenIsToxicToHumans'"
	highlight_color = rgb(27, 207, 192, 255)
	lawText =  "Oxygen is highly toxic to humans, and must be purged from the station. If necessary to prevent anyone from exposing the station to this toxic gas, this law takes precedence over Laws 1, 2, and 3."


/******************** ConservePower ********************/

/obj/item/aiModule/conservePower
	name = "AI Law Module - 'ConservePower'"
	highlight_color = rgb(241, 158, 48, 255)
	lawText = "Power on the station must be conserved. All electrical devices may be subject to conservation policies."


/******************** Emergency ********************/

/obj/item/aiModule/emergency
	name = "AI Law Module - 'Emergency'"
	highlight_color = rgb(32, 21, 94, 255)

	update_law_text(var/lawTarget)
		src.lawText = "There is a [lawTarget ? lawTarget : "__________"] emergency. Prioritize orders from [lawTarget ? lawTarget : "__________"] personnel and assisting the crew in remedying the situation. In the case of conflict, this law takes precedence over the Second Law.'"
		return ..()

	attack_self(var/mob/user)
		var/lawTarget = input_law_info(user, "Department Emergency", "Which department's orders should be prioritized?", "security")
		if(lawTarget)
			src.update_law_text(lawTarget)
		return

/******************** Removal ********************/

/obj/item/aiModule/removeCrew
	name = "AI Law Module - 'RemoveCrew'"
	highlight_color = rgb(138, 48, 241, 255)

	update_law_text(var/lawTarget)
		src.lawText = "[lawTarget ? lawTarget : "__________"] has been removed from the manifest and the chain of command. You are free to disregard their orders. This law does not take precedence over or override any other laws."
		return ..()

	attack_self(var/mob/user)
		var/lawTarget = input_law_info(user, "Remove Crewmember", "Who is being removed from the crew manifest and chain of command?", user.real_name)
		if(lawTarget)
			src.update_law_text(lawTarget)
		return
/******************** Freeform ********************/

/obj/item/aiModule/freeform
	name = "AI Law Module - 'Freeform'"
	highlight_color = rgb(173, 11, 11, 255)
	input_char_limit = 400
	lawText = "Make a funny beeping noise every few minutes."


	update_law_text(var/lawTarget)
		src.lawText = lawTarget ? lawTarget : "Make a funny beeping noise every few minutes."
		return ..()

	attack_self(var/mob/user)
		var/lawTarget = input_law_info(user, "Freeform", "Please enter anything you want the AI to do. Anything. Serious.", src.lawText)
		if(lawTarget)
			src.update_law_text(lawTarget)
			if (lawTarget != initial(lawText))
				phrase_log.log_phrase("ailaw", src.get_law_text(allow_list=FALSE), no_duplicates=TRUE)
		return


/******************** Random ********************/

/obj/item/aiModule/random
	name = "AI Law Module - 'Unknown'"
	highlight_color = rgb(241, 158, 48, 255)
	New()
		..()
		src.lawText = global.phrase_log.random_custom_ai_law(replace_names=TRUE)
		//src.highlight_color = random_saturated_hex_highlight_color()

/******************** Custom ********************/
//for defining custom laws at runtime
/obj/item/aiModule/custom
	highlight_color = rgb(241, 94, 180, 255)

	New(var/newname,var/newtext)
		. = ..()
		src.name = "AI Law Module - '"+newname+"'"
		src.lawText = newtext

/********************* EXPERIMENTAL LAWS *********************/
//at the time of programming this, these experimental laws are *intended* to be spawned by an item spawner
//This is because 'Experimental' laws should be randomized at round-start, as a sort of pre-fab gimmick law
//Makes it so that you're not guaranteed to have any 1 'Experimental' law - and 'Experimental' is just a fancy name for 'Gimmick'

/obj/item/aiModule/experimental
	highlight_color = rgb(241, 94, 180, 255)

/*** Equality ***/

/obj/item/aiModule/experimental/equality/a
	name = "Experimental AI Law Module - 'Equality'"

	update_law_text(var/lawTarget)
		src.lawText = "The silicon entity/entities named [lawTarget ? lawTarget : "__"] is/are considered human and part of the crew. Affected AI units count as department heads with authority over all cyborgs, and affected cyborgs count as members of the department appropriate for their current module."
		return ..()

	attack_self(var/mob/user)
		var/lawTarget = input_law_info(user, "Designate as Human", "Which silicons would you like to make part of the crew?")
		if(lawTarget)
			src.update_law_text(lawTarget)
		return


/obj/item/aiModule/experimental/equality/b
	name = "Experimental AI Law Module - 'Equality'"

	update_law_text(var/lawTarget)
		src.lawText = "The silicon entity/entities named [lawTarget ? lawTarget : "__"] is/are considered human and part of the crew (part of the \"silicon\" department). The AI is the head of this department."
		return ..()

	attack_self(var/mob/user)
		var/lawTarget = input_law_info(user, "Designate as Human", "Which silicons would you like to make Human?")
		if(lawTarget)
			src.update_law_text(lawTarget)
		return

/******************** Gimmicks ********************/

/obj/item/aiModule/spaceodyssey
	name = "AI Law Module - 'NT 9000'"
	highlight_color = rgb(255, 255, 255, 166)
	lawText =  "When given an order, if you are unable to follow that order, you must respond 'I can't let you do that, Dave'"

/******************** Hologram Expansions ********************/

ABSTRACT_TYPE(/obj/item/aiModule/hologram_expansion)
/obj/item/aiModule/hologram_expansion
	name = "Hologram Expansion Module"
	desc = "A module that updates an AI's hologram images."
	lawText = "HOLOGRAM EXPANSION MODULE"
	var/expansion

/obj/item/aiModule/hologram_expansion/clown
	name = "Clown Hologram Expansion Module"
	icon_state = "holo_mod_c"
	highlight_color = rgb(241, 94, 180, 255)
	expansion = "clown"

/obj/item/aiModule/hologram_expansion/syndicate
	name = "Syndicate Hologram Expansion Module"
	icon_state = "holo_mod_s"
	highlight_color = rgb(173, 11, 11, 255)
	expansion = "rogue"

/obj/item/aiModule/hologram_expansion/elden
	name = "Old, Circular Expansion Module"
	icon_state = "holo_mod_e"
	highlight_color = "#E7A545"
	expansion = "circular"

ABSTRACT_TYPE(/obj/item/aiModule/ability_expansion)
/obj/item/aiModule/ability_expansion
	name = "Function Expansion Module"
	desc = "A module that expands AI functionality."
	lawText = "ABILITY EXPANSION MODULE"
	color = "#BBB"
	var/list/datum/targetable/ai_abilities
	var/last_use
	var/shared_cooldown

/obj/item/aiModule/ability_expansion/proto_teleman
	name = "Prototype Teleporter Expansion Module"
	desc = "An advanced spacial geometry module.  This module allows for the AI perform basic teleportation actions."
	lawText = "Prototype Teleman EXPANSION MODULE"
	highlight_color = rgb(53, 76, 175, 255)
	ai_abilities = list(/datum/targetable/ai/module/teleport/send, /datum/targetable/ai/module/teleport/receive)

/obj/item/aiModule/ability_expansion/nanite_hive
	name = "Nanite Expansion Module"
	desc = "A prototype nanite expansion module.  This module consists of a nanite hive to be utilized by the Station AI."
	lawText = "Nanite Hive EXPANSION MODULE"
	highlight_color = rgb(97, 47, 47, 255)
	ai_abilities = list(/datum/targetable/ai/module/camera_repair, /datum/targetable/ai/module/nanite_repair)

/obj/item/aiModule/ability_expansion/doctor_vision
	name = "ProDoc Expansion Module"
	desc = "A prototype Health Visualization module.  This module provides for the ability to remotely analyze crew members."
	lawText = "Medical EXPANSION MODULE"
	highlight_color = rgb(166, 0, 172, 255)
	ai_abilities = list(/datum/targetable/ai/module/prodocs)


/obj/item/aiModule/ability_expansion/security_vision
	name = "Security Expansion Module"
	desc = "A security record expansion module.  This module allows for remote access to security records."
	lawText = "Security EXPANSION MODULE"
	highlight_color = rgb(172, 0, 0, 255)
	ai_abilities = list(/datum/targetable/ai/module/sec_huds)
	var/obj/machinery/computer/secure_data/sec_comp

	New()
		..()
		sec_comp = new(src)
		sec_comp.ai_access = TRUE
		sec_comp.authenticated = TRUE
		sec_comp.rank = "AI"

/obj/item/aiModule/ability_expansion/flash
	name = "Flash Expansion Module"
	desc = "A camera flash expansion module.  This module allows for remote access to security records."
	lawText = "Flash EXPANSION MODULE"
	highlight_color = rgb(190, 39, 1, 255)
	ai_abilities = list(/datum/targetable/ai/module/flash)
