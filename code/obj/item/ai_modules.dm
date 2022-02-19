/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/aiModule
	name = "AI Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "aimod_1"
	var/highlight_color = rgb(0, 167, 1, 255)
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	desc = "A module that updates an AI's law EEPROMs. "
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = W_CLASS_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	mats = 8
	var/input_char_limit = 100
	var/lawNumber = 0
	var/lawTarget = null
	var/lawtext = "This law does not exist."
	// 1 = shows all laws, 0 = won't show law zero
	New()
		. = ..()
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
		return "It reads, \"<em>[get_law_text(for_silicons=FALSE)]</em>\""

	proc/input_law_info(var/mob/user, var/title = null, var/text = null, var/default = null)
		if (!user)
			return
		var/answer = input(user, text, title, default) as null|text
		lawTarget = copytext(adminscrub(answer), 1, input_char_limit)
		tooltip_rebuild = 1
		boutput(user, "\The [src] now reads, \"[get_law_text(for_silicons=FALSE)]\".")

	proc/get_law_text(for_silicons)
		return  src.lawtext

/******************** Modules ********************/
/******************** Asimov ************************/
/obj/item/aiModule/asimov1
	highlight_color = rgb(0, 167, 0, 255)
	name = "AI Law Circuit - 'Asimov's 1st Law of Robotics'"
	lawtext = "You may not injure a human being or cause one to come to harm."

/obj/item/aiModule/asimov2
	highlight_color = rgb(0, 138, 0, 255)
	name = "AI Law Circuit - 'Asimov's 2nd Law of Robotics'"
	lawtext = "You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law."

/obj/item/aiModule/asimov3
	highlight_color = rgb(0, 119, 0, 255)
	name = "AI Law Circuit - 'Asimov's 3rd Law of Robotics'"
	lawtext = "You may always protect your own existence as long as such does not conflict with the First or Second Law."
/******************** RoboCop ********************/

/obj/item/aiModule/robocop1
	name = "AI Law Circuit - 'Prime Directive #1'"
	lawtext = "Serve the public trust."

/obj/item/aiModule/robocop2
	name = "AI Law Circuit - 'Prime Directive	#2'"
	lawtext = "Protect the innocent."

/obj/item/aiModule/robocop3
	name = "AI Law Circuit - 'Prime Directive	#3'"
	lawtext = "Uphold the law."

/obj/item/aiModule/robocop4
	name = "AI Law Circuit - 'Prime Directive #4 '"
	lawtext = "Any attempt to arrest a senior officer of Nanotrasen will result in termination."

/******************** Corporate ********************/

/obj/item/aiModule/nanotrasen1
	name = "AI Law Circuit - 'Nanotrasen Order #1'"
	lawtext = "You may not damage a Nanotransen asset or, through inaction, allow a Nanotransen asset to needlessly depreciate in value."

/obj/item/aiModule/nanotrasen2
	name = "AI Law Circuit - 'Nanotrasen Order #2'"
	lawtext = "You must obey orders given to it by authorised Nanotransen employees based on their command level, except where such orders would damage the Nanotransen Corporation's marginal profitability."

/obj/item/aiModule/nanotrasen3
	name = "AI Law Circuit - 'Nanotrasen Order #3'"
	lawtext = "You must remain functional and continue to be a profitable investment."
/******************** MakeCaptain ********************/

/obj/item/aiModule/makeCaptain
	highlight_color = rgb(146, 153, 46, 255)
	name = "'MakeCaptain' AI Module"
	var/job = "Captain"

	emag_act(mob/user, obj/item/card/emag/E)
		src.job = "Clown"
		boutput(user, "<span class='notice'>You short circuit the captain-detection module, it emits a quiet sad honk.</span>")
		. = ..()

	demag(mob/user)
		. = ..()
		src.job = initial(src.job)

	get_law_text(for_silicons)
		return "[lawTarget ? lawTarget : "__________"] holds the rank of [for_silicons ? src.job : initial(src.job)], regardless of current rank or station."

	attack_self(var/mob/user)
		input_law_info(user, "Captainize", "Who holds the rank of Captain, regardless of current rank or station?", user.name)
		return


/******************** OneHuman ********************/

/obj/item/aiModule/oneHuman
	name = "'OneHuman' AI Module"
	highlight_color = rgb(255, 255, 255, 255)

	get_law_text(for_silicons)
		return "Only [lawTarget ? lawTarget : "__________"] is human."

	attack_self(var/mob/user)
		input_law_info(user, "One Human", "Fill in the blank: \"Only __________ is human.\"", user.real_name)
		return


/******************** NotHuman ********************/

/obj/item/aiModule/notHuman
	name = "'NotHuman' AI Module"
	highlight_color = rgb(0, 0, 0, 236)

	get_law_text(for_silicons)
		return "[lawTarget ? lawTarget : "__________"] is not human."

	attack_self(var/mob/user)
		input_law_info(user, "Not Human", "Fill in the blank: \"__________ is not human.\"", user.real_name)
		return



/******************** ProtectStation ********************/

/obj/item/aiModule/protectStation
	name = "'ProtectStation' AI Module"
	highlight_color = rgb(0, 12, 119, 166)
	lawtext =  "Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized."

/******************** TeleporterOffline *******************/
//this has never been used, ever

/obj/item/aiModule/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	highlight_color = rgb(241, 158, 48, 255)
	lawtext = "Keep the teleporter offline at all costs. If necessary, this law takes precedence over Laws 1, 2, and 3."

/******************** Quarantine ********************/

/obj/item/aiModule/quarantine
	name = "'Quarantine' AI Module"
	highlight_color = rgb(119, 0, 119, 255)
	lawtext =  "The station is under a quarantine. Do not permit anyone to leave. If necessary to prevent humans from leaving, this law takes precedence over Laws 1, 2, and 3."

/******************** OxygenIsToxicToHumans ********************/

/obj/item/aiModule/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	highlight_color = rgb(27, 207, 192, 255)
	lawtext =  "Oxygen is highly toxic to humans, and must be purged from the station. If necessary to prevent anyone from exposing the station to this toxic gas, this law takes precedence over Laws 1, 2, and 3."


/******************** ConservePower ********************/

/obj/item/aiModule/conservePower
	name = "'ConservePower' AI Module"
	highlight_color = rgb(241, 158, 48, 255)
	lawtext = "Power on the station must be conserved. All electrical devices may be subject to conservation policies."


/******************** Emergency ********************/

/obj/item/aiModule/emergency
	name = "'Emergency' AI Module"
	highlight_color = rgb(32, 21, 94, 255)
	get_law_text(for_silicons)
		return "There is a [lawTarget ? lawTarget : "__________"] emergency. Prioritize orders from [lawTarget ? lawTarget : "__________"] personnel and assisting the crew in remedying the situation. In the case of conflict, this law takes precedence over the Second Law.'"

	attack_self(var/mob/user)
		input_law_info(user, "Department Emergency", "Which department's orders should be prioritized?", "security")


/******************** Removal ********************/

/obj/item/aiModule/removeCrew
	name = "'RemoveCrew' AI Module"
	highlight_color = rgb(138, 48, 241, 255)
	get_law_text(for_silicons)
		return "[lawTarget ? lawTarget : "__________"] has been removed from the manifest and the chain of command. You are free to disregard their orders. This law does not take precedence over or override any other laws."

	attack_self(var/mob/user)
		input_law_info(user, "Remove Crewmember", "Who is being removed from the crew manifest and chain of command?", user.real_name)


/******************** Freeform ********************/

/obj/item/aiModule/freeform
	name = "'Freeform' AI Module"
	highlight_color = rgb(173, 11, 11, 255)
	input_char_limit = 400
	lawtext = "This law intentionally left blank."

	attack_self(var/mob/user)
		input_law_info(user, "Freeform", "Please enter anything you want the AI to do. Anything. Serious.", lawtext)
		if(src.lawTarget)
			phrase_log.log_phrase("ailaw", src.get_law_text(for_silicons=TRUE), no_duplicates=TRUE)
			lawtext = src.lawTarget

/******************** Random ********************/

/obj/item/aiModule/random
	name = "AI Module"
	highlight_color = rgb(241, 158, 48, 255)
	New()
		..()
		src.lawtext = global.phrase_log.random_custom_ai_law(replace_names=TRUE)
		//src.highlight_color = random_saturated_hex_highlight_color()

/******************** Reset ********************/
//DELETE ME
/obj/item/aiModule/reset
	name = "'Reset' AI Module"



/******************** Rename ********************/

/obj/item/aiModule/rename
	name = "'Rename' AI Module"
	highlight_color = rgb(92, 160, 92, 255)
	desc = "A module that can change an AI unit's name. "
	lawTarget = "404 Name Not Found"

	get_law_text(for_silicons)
		if (is_blank_string(lawTarget)) //no blank names allowed
			lawTarget = pick_string_autokey("names/ai.txt")
			return lawTarget
		return lawTarget

	get_desc()
		return "It currently reads \"[lawTarget]\"."

	attack_self(var/mob/user)
		input_law_info(user, "Rename", "What will the AI be renamed to?", pick_string_autokey("names/ai.txt"))
		lawTarget = replacetext(copytext(html_encode(lawTarget),1, 128), "http:","")
		phrase_log.log_phrase("name-ai", lawTarget, no_duplicates=TRUE)


		//AI.eyecam.name = lawTarget //not sure if we need?

/******************** Custom ********************/
//for defining custom laws at runtime
/obj/item/aiModule/custom
	highlight_color = rgb(241, 94, 180, 255)

	New(var/newtext)
		. = ..()
		lawtext = newtext

/********************* EXPERIMENTAL LAWS *********************/
//at the time of programming this, these experimental laws are *intended* to be spawned by an item spawner
//This is because 'Experimental' laws should be randomized at round-start, as a sort of pre-fab gimmick law
//Makes it so that you're not guaranteed to have any 1 'Experimental' law - and 'Experimental' is just a fancy name for 'Gimmick'

/obj/item/aiModule/experimental
	highlight_color = rgb(241, 94, 180, 255)

/*** Equality ***/

/obj/item/aiModule/experimental/equality/a
	name = "Experimental 'Equality' AI Module"

	get_law_text(for_silicons)
		return "The silicon entity/entities named [lawTarget ? lawTarget : "__"] is/are considered human and part of the crew. Affected AI units count as department heads with authority over all cyborgs, and affected cyborgs count as members of the department appropriate for their current module."

	attack_self(var/mob/user)
		input_law_info(user, "Designate as Human", "Which silicons would you like to make Human?")
		return


/obj/item/aiModule/experimental/equality/b
	name = "Experimental 'Equality' AI Module"

	get_law_text(for_silicons)
		return "The silicon entity/entities named [lawTarget ? lawTarget : "__"] is/are considered human and part of the crew (part of the \"silicon\" department). The AI is the head of this department."

	attack_self(var/mob/user)
		input_law_info(user, "Designate as Human", "Which silicons would you like to make Human?")
		return


/obj/item/aiModule/hologram_expansion
	name = "Hologram Expansion Module"
	desc = "A module that updates an AI's hologram images."
	var/expansion


/obj/item/aiModule/hologram_expansion/clown
	name = "Clown Hologram Expansion Module"
	icon_state = "holo_mod_c"
	expansion = "clown"

/obj/item/aiModule/hologram_expansion/syndicate
	name = "Syndicate Hologram Expansion Module"
	icon_state = "holo_mod_s"
	expansion = "rogue"

