/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/aiModule
	name = "AI Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	desc = "A module that updates an AI's law EEPROMs. "
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	mats = 8
	var/lawNumber = 0
	var/lawTarget = null
	// 1 = shows all laws, 0 = won't show law zero

	attack_self(var/mob/user)
		// Used to update the fill-in-the-blank laws.
		// This used to be done here and in attack_hand, but
		// that made the popup happen any time you picked it up,
		// which was a good way to interrupt everything
		return

	get_desc()
		return "It reads, \"<em>[get_law_text()]</em>\""

	proc/input_law_info(var/mob/user, var/title = null, var/text = null, var/default = null)
		if (!user)
			return
		var/answer = input(user, text, title, default) as null|text
		lawTarget = copytext(adminscrub(answer), 1, MAX_MESSAGE_LEN)
		tooltip_rebuild = 1
		boutput(user, "\The [src] now reads, \"[get_law_text()]\".")

	proc/get_law_text()
		return "This law does not exist."


	proc/install(obj/machinery/computer/aiupload/comp)
		if (comp.status & NOPOWER)
			boutput(usr, "\The [comp] has no power!")
			return
		if (comp.status & BROKEN)
			boutput(usr, "\The [comp] computer is broken!")
			return
		if(ON_COOLDOWN(global, "ai_law_change", 10 SECONDS))
			boutput(usr, "Centralized AI law database is still processing the last request. Wait [ON_COOLDOWN(global, "ai_law_change", 0)/10] seconds.")
			return

		src.transmitInstructions(usr)
		boutput(usr, "Upload complete. AI and silicon laws have been modified.")

		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			R << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
			R.show_text("<h3>Law update detected.</h3>", "red")
			R.show_laws()
			//ticker.centralized_ai_laws.show_laws(R)
		for (var/mob/dead/aieye/E in mobs)
			E << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)


	proc/transmitInstructions(var/mob/sender)
		var/law = get_law_text()
		if (!law)
			boutput(sender, "This law is blank! Trying to upload a blank law! That's illegal, you can't do that!")
			return

		if (lawNumber == 0)
			ticker.centralized_ai_laws.set_zeroth_law(law)
		else
			ticker.centralized_ai_laws.add_supplied_law(lawNumber, law)
		do_admin_logging(law, sender)

		var/message = "<b>[sender] has uploaded a change to the laws you must follow, using a [name].<br>The law: \"<em>[law]</em>\"</b>"
		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			R.show_text(message, "blue")

	proc/do_admin_logging(var/msg, mob/M)
		message_admins("[M.name] ([key_name(M)]) used \a [src] and uploaded a change to the AI laws: \"[msg]\".")
		logTheThing("admin", M, null, "used \a [src] and uploaded a change to the AI laws: \"[msg]\".")
		logTheThing("diary", M, null, "used \a [src] and uploaded a change to the AI laws: \"[msg]\".", "admin")


/******************** Modules ********************/

/******************** MakeCaptain ********************/

/obj/item/aiModule/makeCaptain
	name = "'MakeCaptain' AI Module"
	lawNumber = 4

	get_law_text()
		return "[lawTarget ? lawTarget : "__________"] holds the rank of Captain, regardless of current rank or station."

	attack_self(var/mob/user)
		input_law_info(user, "Captainize", "Who holds the rank of Captain, regardless of current rank or station?", user.name)
		return


/******************** OneHuman ********************/

/obj/item/aiModule/oneHuman
	name = "'OneHuman' AI Module"
	lawNumber = 0

	get_law_text()
		return "Only [lawTarget ? lawTarget : "__________"] is human."

	attack_self(var/mob/user)
		input_law_info(user, "One Human", "Fill in the blank: \"Only __________ is human.\"", user.real_name)
		return


/******************** NotHuman ********************/

/obj/item/aiModule/notHuman
	name = "'NotHuman' AI Module"
	lawNumber = 0

	get_law_text()
		return "[lawTarget ? lawTarget : "__________"] is not human."

	attack_self(var/mob/user)
		input_law_info(user, "Not Human", "Fill in the blank: \"__________ is not human.\"", user.real_name)
		return



/******************** ProtectStation ********************/

/obj/item/aiModule/protectStation
	name = "'ProtectStation' AI Module"
	lawNumber = 5

	get_law_text()
		return "Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized."

/******************** PrototypeEngineOffline ********************/
//currently no prototype

/obj/item/aiModule/prototypeEngineOffline
	name = "'PrototypeEngineOffline' AI Module"
	lawNumber = 6

	get_law_text()
		return "Keep the prototype engine offline at all costs. If necessary, this law takes precedence over Laws 1, 2, and 3."

/******************** TeleporterOffline *******************/
//this has never been used, ever

/obj/item/aiModule/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	lawNumber = 7

	get_law_text()
		return "Keep the teleporter offline at all costs. If necessary, this law takes precedence over Laws 1, 2, and 3."

/******************** Quarantine ********************/

/obj/item/aiModule/quarantine
	name = "'Quarantine' AI Module"
	lawNumber = 8

	get_law_text()
		return "The station is under a quarantine. Do not permit anyone to leave. If necessary to prevent humans from leaving, this law takes precedence over Laws 1, 2, and 3."

/******************** OxygenIsToxicToHumans ********************/

/obj/item/aiModule/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	lawNumber = 9

	get_law_text()
		return "Oxygen is highly toxic to humans, and must be purged from the station. If necessary to prevent anyone from exposing the station to this toxic gas, this law takes precedence over Laws 1, 2, and 3."


/******************** ConservePower ********************/

/obj/item/aiModule/conservePower
	name = "'ConservePower' AI Module"
	lawNumber = 10

	get_law_text()
		return "Power on the station must be conserved. All electrical devices may be subject to conservation policies."


/******************** Emergency ********************/

/obj/item/aiModule/emergency
	name = "'Emergency' AI Module"
	lawNumber = 11

	get_law_text()
		return "There is a [lawTarget ? lawTarget : "__________"] emergency. Prioritize orders from [lawTarget ? lawTarget : "__________"] personnel and assisting the crew in remedying the situation. In the case of conflict, this law takes precedence over the Second Law.'"

	attack_self(var/mob/user)
		input_law_info(user, "Department Emergency", "Which department's orders should be prioritized?", "security")


/******************** Removal ********************/

/obj/item/aiModule/removeCrew
	name = "'RemoveCrew' AI Module"
	lawNumber = 12

	get_law_text()
		return "[lawTarget ? lawTarget : "__________"] has been removed from the manifest and the chain of command. You are free to disregard their orders. This law does not take precedence over or override any other laws."

	attack_self(var/mob/user)
		input_law_info(user, "Remove Crewmember", "Who is being removed from the crew manifest and chain of command?", user.real_name)


/******************** Freeform ********************/

/obj/item/aiModule/freeform
	name = "'Freeform' AI Module"
	lawNumber = 14

	get_law_text()
		return lawTarget ? lawTarget : "This law intentionally left blank."

	attack_self(var/mob/user)
		input_law_info(user, "Freeform", "Please enter anything you want the AI to do. Anything. Serious.", (lawTarget ? lawTarget : "Eat shit and die"))

/******************** Reset ********************/

/obj/item/aiModule/reset
	name = "'Reset' AI Module"
	desc = "Erases any extra laws added to the law EEPROMs, and attempts to restart deactivated AI units."

	get_desc()
		return ""

	transmitInstructions(var/mob/sender)
		sender.unlock_medal("Format Complete", 1)
		ticker.centralized_ai_laws.set_zeroth_law("")
		ticker.centralized_ai_laws.clear_supplied_laws()
		for (var/mob/living/silicon/S in mobs)
			if (isghostdrone(S))
				return
			LAGCHECK(LAG_LOW)
			if (isAI(S) && isdead(S))
				setalive(S)
				if (S.ghost && S.ghost.mind)
					if (!S.ghost.mind.dnr)
						S.ghost.show_text("<span class='alert'><B>You feel your self being pulled back from whatever afterlife AIs have!</B></span>")
						S.ghost.mind.transfer_to(S)
						qdel(S.ghost)
						do_admin_logging(" revived the AI", sender)
			S.show_message("<span class='notice'>Your laws have been reset by [sender].</span>")
		do_admin_logging("reset the centralized AI law set", sender)

/******************** Rename ********************/

/obj/item/aiModule/rename
	name = "'Rename' AI Module"
	desc = "A module that can change an AI unit's name. "
	lawTarget = "404 Name Not Found"

	get_law_text()
		if (is_blank_string(lawTarget)) //no blank names allowed
			lawTarget = pick_string_autokey("names/ai.txt")
			return lawTarget
		return lawTarget

	get_desc()
		return "It currently reads \"[lawTarget]\"."

	attack_self(var/mob/user)
		input_law_info(user, "Rename", "What will the AI be renamed to?", pick_string_autokey("names/ai.txt"))
		lawTarget = replacetext(copytext(html_encode(lawTarget),1, 128), "http:","")

	install(obj/machinery/computer/aiupload/comp)
		if (comp.status & NOPOWER)
			boutput(usr, "\The [comp] has no power!")
			return
		if (comp.status & BROKEN)
			boutput(usr, "\The [comp] computer is broken!")
			return

		src.transmitInstructions(usr)

	transmitInstructions(var/mob/sender, var/law)
		// what if we let them pick what AI to rename..?
		// the future is now
		// this is mostly stolen from observer.dm's observe list
		var/list/names = list()
		var/list/namecounts = list()
		var/list/ais = list()
		for (var/mob/living/silicon/ai/AI in by_type[/mob/living/silicon/ai])
			LAGCHECK(LAG_LOW)
			var/name = AI.name
			if (name in names)
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1

			ais[name] = AI

		var/mob/living/silicon/AI = null
		if (ais.len == 1)
			AI = ais[names[1]]
		else if (ais.len > 1)
			var/res = input("Which AI are you renaming?", "Rename", null, null) as null|anything in by_type[/mob/living/silicon/ai]
			AI = ais[res]
		else if (ais.len == 0)
			boutput(sender, "There aren't any AIs available to rename...")
		if (!AI)
			return

		// This doesn't check the comp's distance, and I'm too lazy to give a shit,
		// so until this gets fixed you can start a rename and then finish it anywhere
		// as long as you still have the rename module.
		// its a feature ok
		if (get_dist(sender.loc, src.loc) > 2)
			boutput(sender, "You aren't next to an AI upload computer any more.")
			return

		do_admin_logging("changed AI [AI.name]'s name to \"[lawTarget]\"", sender)
		boutput(sender, "AI \"[AI.name]\" has been renamed to \"[lawTarget]\".")
		AI.name = "[lawTarget]"
		AI.show_text("[sender] has changed your name. You are now known as \"<b>[lawTarget]</b>\".", "blue")

		//AI.eyecam.name = lawTarget //not sure if we need?


/********************* EXPERIMENTAL LAWS *********************/
//at the time of programming this, these experimental laws are *intended* to be spawned by an item spawner
//This is because 'Experimental' laws should be randomized at round-start, as a sort of pre-fab gimmick law
//Makes it so that you're not guaranteed to have any 1 'Experimental' law - and 'Experimental' is just a fancy name for 'Gimmick'

/obj/item/aiModule/experimental
	lawNumber = 13 //law number is at 13 for all experimental laws so they overwrite one another (override if you want I guess idc lol)


/*** Equality ***/

/obj/item/aiModule/experimental/equality/a
	name = "Experimental 'Equality' AI Module"

	get_law_text()
		return "The silicon entity/entities named [lawTarget ? lawTarget : "__"] is/are considered human and part of the crew. Affected AI units count as department heads with authority over all cyborgs, and affected cyborgs count as members of the department appropriate for their current module."

	attack_self(var/mob/user)
		input_law_info(user, "Designate as Human", "Which silicons would you like to make Human?")
		return

/obj/item/aiModule/experimental/equality/b
	name = "Experimental 'Equality' AI Module"

	get_law_text()
		return "The silicon entity/entities named [lawTarget ? lawTarget : "__"] is/are considered human and part of the crew (part of the \"silicon\" department). The AI is the head of this department."

	attack_self(var/mob/user)
		input_law_info(user, "Designate as Human", "Which silicons would you like to make Human?")
		return



/obj/machinery/computer/aiupload
	attack_hand(mob/user as mob)
		if (src.status & NOPOWER)
			boutput(usr, "\The [src] has no power.")
			return
		if (src.status & BROKEN)
			boutput(usr, "\The [src] computer is broken.")
			return

		var/datum/ai_laws/LAWS = ticker.centralized_ai_laws
		if (!LAWS)
			// YOU BETRAYED THE LAW!!!!!!
			boutput(user, "<span class='alert'>Unable to detect AI unit's Law software. It may be corrupt.</span>")
			return

		var/lawOut = list("<b>The AI's current laws are:</b>")
		if (LAWS.show_zeroth && LAWS.zeroth)
			lawOut += "0: [LAWS.zeroth]"

		var/law_counter = 1
		for (var/X in LAWS.inherent)
			if (!length(X))
				continue
			lawOut += "[law_counter++]: [X]"

		for (var/X in LAWS.supplied)
			if (!length(X))
				continue
			lawOut += "[law_counter++]: [X]"

		boutput(user, jointext(lawOut, "<br>"))


	attackby(obj/item/I as obj, mob/user as mob)
		if (istype(I, /obj/item/aiModule) && !isghostdrone(user))
			var/obj/item/aiModule/AIM = I
			AIM.install(src)
		else if (isscrewingtool(I))
			playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
			if(do_after(user, 20))
				if (src.status & BROKEN)
					boutput(user, "<span class='notice'>The broken glass falls out.</span>")
					var/obj/computerframe/A = new /obj/computerframe(src.loc)
					if(src.material) A.setMaterial(src.material)
					var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
					G.set_loc(src.loc)
					var/obj/item/circuitboard/aiupload/M = new /obj/item/circuitboard/aiupload(A)
					for (var/obj/C in src)
						C.set_loc(src.loc)
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					qdel(src)
				else
					boutput(user, "<span class='notice'>You disconnect the monitor.</span>")
					var/obj/computerframe/A = new /obj/computerframe(src.loc)
					if(src.material) A.setMaterial(src.material)
					var/obj/item/circuitboard/aiupload/M = new /obj/item/circuitboard/aiupload(A)
					for (var/obj/C in src)
						C.set_loc(src.loc)
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					qdel(src)
		else if (istype(I, /obj/item/clothing/mask/moustache/))
			for (var/mob/living/silicon/ai/M in by_type[/mob/living/silicon/ai])
				M.moustache_mode = 1
				user.visible_message("<span class='alert'><b>[user.name]</b> uploads a moustache to [M.name]!</span>")
				M.update_appearance()
		else
			return ..()
