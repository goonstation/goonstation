/mob/living/silicon
	mob_flags = USR_DIALOG_UPDATES_RANGE
	gender = NEUTER
	var/syndicate = 0 // Do we get Syndicate laws?
	var/syndicate_possible = 0 //  Can we become a Syndie robot?
	var/emagged = 0 // Are we emagged, removing all laws?
	var/emaggable = 0 // Can we be emagged?
	robot_talk_understand = 1
	see_infrared = 1
	var/list/req_access = list()

	var/killswitch = 0
	var/killswitch_at = 0
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/obj/item/card/id/botcard //An ID card that the robot "holds" invisibly

	var/mob/living/silicon/ai/mainframe = null // where to go back to when we die, if we have one, for hivebots/robots
	var/dependent = 0 // if we're host to a mainframe's mind
	var/shell = 0 // are we available for use as a shell for an AI

	var/obj/machinery/lawrack/law_rack_connection = null // which rack we're getting our laws from

	var/obj/item/cell/cell = null

	var/static/regex/monospace_say_regex = new(@"`([^`]+)`", "g")

	can_bleed = 0
	blood_id = "oil"
	use_stamina = 0
	can_lie = 0
	canbegrabbed = FALSE // silicons can't be grabbed, they're too bulky or something
	grabresistmessage = "but can't get a good grip!"

	dna_to_absorb = 0 //robots dont have DNA for fuck sake


	//voice_type = "robo"

/mob/living/silicon/New()
	..()
	src.botcard = new /obj/item/card/id(src)
	if(src.syndicate)
		src.law_rack_connection = ticker?.ai_law_rack_manager.default_ai_rack_syndie
		logTheThing(LOG_STATION, src, "New cyborg [src] connects to default SYNDICATE rack [constructName(src.law_rack_connection)]")
	else
		src.law_rack_connection = ticker?.ai_law_rack_manager.default_ai_rack
		logTheThing(LOG_STATION, src, "New cyborg [src] connects to default rack [constructName(src.law_rack_connection)]")
	APPLY_ATOM_PROPERTY(src, PROP_MOB_CAN_CONSTRUCT_WITHOUT_HOLDING, src)

/mob/living/silicon/disposing()
	req_access = null
	return ..()

///mob/living/silicon/proc/update_canmove()
//	..()
	//canmove = !(src.hasStatus(list("weakened", "paralysis", "stunned")) || buckled)

/mob/living/silicon/proc/use_power()
	return

/mob/living/silicon/proc/cancelAlarm()
	return

/mob/living/silicon/proc/triggerAlarm()
	return

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/proc/return_mainframe()
	if (mainframe)
		mainframe.return_to(src)
	else
		boutput(src, "<span class='alert'>You lack a dedicated mainframe!</span>")
		return

/mob/living/silicon/proc/become_eye()
	if (!mainframe)
		return
	src.return_mainframe()
	mainframe.eye_view()
	mainframe.eyecam.set_loc(get_turf(src))

// Moves this down from ai.dm so AI shells and AI-controlled cyborgs can use it too.
// Also made it a little more functional and less buggy (Convair880).
#define STUNNED (src.stat || src.getStatusDuration("stunned") || src.getStatusDuration("weakened")) || (src.dependent && (src.mainframe.stat || src.mainframe.getStatusDuration("stunned") || src.mainframe.getStatusDuration("weakened")))
/mob/living/silicon/proc/open_nearest_door_silicon()
	if (!src || !issilicon(src))
		return
	if (!isAI(src) && !(src.dependent && src.mainframe && isAI(mainframe)))
		usr.show_text("You have no mainframe to relay this command to!", "red")
		return

	if (STUNNED)
		usr.show_text("You cannot use this command when your shell or mainframe is incapacitated.", "red")
		return

	var/list/creatures = sortList(get_mobs_trackable_by_AI(), /proc/cmp_text_asc)
	var/target_name = tgui_input_list(usr, "Open doors nearest to which creature?", "Open Door", creatures)

	if (!target_name)
		return

	target_name = creatures[target_name]

	// Find us some doors.
	var/list/valid_doors = list()
	for (var/obj/machinery/door/D in view(target_name, 1))
		if (istype(D, /obj/machinery/door/airlock))
			valid_doors["[D.name] #[length(valid_doors) + 1] at [get_area(D)]"] += D // Don't remove the #[number] part here.
		else if (istype(D, /obj/machinery/door/window))
			valid_doors["[D.name] #[length(valid_doors) + 1] at [get_area(D)]"] += D
		else
			continue
	// Attempt to open said doors.
	var/obj/machinery/door/our_door
	if (!length(valid_doors))
		usr.show_text("Couldn't find a controllable airlock near [target_name].", "red")
		return
	var/t1 = tgui_input_list(usr, "Please select a door to control.", "Target Selection", valid_doors)
	if (!t1)
		return
	our_door = valid_doors[t1]

	if (STUNNED)
		usr.show_text("You cannot use this command when your shell or mainframe is incapacitated.", "red")
		return
	if (!our_door || !istype(our_door, /obj/machinery/door/))
		usr.show_text("Couldn't find a controllable airlock near [target_name].", "red")
		return

	var/turf/door_loc = get_turf(our_door)
	if (door_loc && isrestrictedz(door_loc.z)) // Somebody will find a way to abuse it if I don't put this here.
		usr.show_text("Unable to interface with door due to unknown interference.", "red")
		return

	if (istype(our_door, /obj/machinery/door/airlock/))
		var/obj/machinery/door/airlock/A = our_door
		if (A.canAIControl())
			if (A.open())
				boutput(usr, "<span class='notice'>[A.name] opened successfully.</span>")
			else
				boutput(usr, "<span class='alert'>Attempt to open [A.name] failed. It may require manual repairs.</span>")
		else
			boutput(usr, "<span class='alert'>Cannot interface with airlock \"[A.name]\". It may require manual repairs.</span>")

	else if (istype(our_door, /obj/machinery/door/window))
		if (our_door.open())
			boutput(usr, "<span class='notice'>[our_door.name] opened successfully.</span>")
		else
			boutput(usr, "<span class='alert'>Attempt to open [our_door.name] failed.</span>")

	return
#undef STUNNED

/mob/living/silicon/proc/damage_mob(var/brute = 0, var/fire = 0, var/tox = 0)
	return

/mob/living/silicon/has_any_hands()
	// no hands :(

	// unless...
	. = istype(src.equipped(), /obj/item/magtractor)

/mob/living/silicon/put_in_hand(obj/item/I, hand)
	if (!I) return 0
	if (src.equipped() && istype(src.equipped(), /obj/item/magtractor))
		var/obj/item/magtractor/M = src.equipped()
		if (M.pickupItem(I, src))
			actions.start(new/datum/action/magPickerHold(M, M.highpower), src)
			return 1
	return 0 // we have no hands doofus

/mob/living/silicon/click(atom/target, params, location, control)
	if (src.targeting_ability)
		..()
	if (!src.stat && !src.restrained() && !src.getStatusDuration("weakened") && !src.getStatusDuration("paralysis") && !src.getStatusDuration("stunned"))
		if(src.client.check_any_key(KEY_OPEN | KEY_BOLT | KEY_SHOCK) && istype(target, /obj) )
			var/obj/O = target
			if(O.receive_silicon_hotkey(src)) return

	var/inrange = in_interact_range(target, src)
	var/obj/item/equipped = src.equipped()
	if (src.client.check_any_key(KEY_OPEN | KEY_BOLT | KEY_SHOCK | KEY_EXAMINE | KEY_POINT) || (equipped && (inrange || (equipped.flags & EXTRADELAY))) || istype(target, /turf) || ishelpermouse(target)) // slightly hacky, oh well, tries to check whether we want to click normally or use attack_ai
		..()
	else
		if (GET_DIST(src, target) > 0) // temporary fix for cyborgs turning by clicking
			set_dir(get_dir(src, target))

		target.attack_ai(src, params, location, control)

/*
/mob/living/key_down(key)
	if (key == "shift")
		update_cursor()
	..()

/mob/living/key_up(key)
	if (key == "shift")
		update_cursor()
	..()
*/

/mob/living/silicon/update_cursor()
	if (src.client)
		if (src.client.check_key(KEY_OPEN))
			src.set_cursor('icons/cursors/open.dmi')
			return
		if (src.client.check_key(KEY_BOLT))
			src.set_cursor('icons/cursors/bolt.dmi')
			return
		if(src.client.check_key(KEY_SHOCK))
			src.set_cursor('icons/cursors/shock.dmi')
			return
	return ..()
/mob/living/silicon/say(var/message)
	if (!message)
		return

	if (src.client && src.client.ismuted())
		boutput(src, "You are currently muted and may not speak.")
		return

	if (isdead(src))
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		return src.say_dead(message)

	// wtf?
	if (src.stat)
		return

	if (length(message) >= 2)
		if (copytext(lowertext(message), 1, 3) == ":s")
			message = copytext(message, 3)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			src.robot_talk(message)
		else
			return ..(message)
	else
		return ..(message)

/mob/living/silicon/say_decorate(message)
	. = monospace_say_regex.Replace(message, "<span class='monospace'>$1</span>")

/mob/living/proc/process_killswitch()
	return

/mob/living/proc/process_locks()
	return

/mob/living/proc/robot_talk(var/message)

	logTheThing(LOG_DIARY, src, ": [message]", "say")

	message = trim(html_encode(message))

	if (!message)
		return

	var/message_a = src.say_quote(message)
	var/rendered = "<span class='game roboticsay'>Robotic Talk, <span class='name' data-ctx='\ref[src.mind]'>[src.name]</span> <span class='message'>[message_a]</span></span>"
	for (var/mob/living/S in mobs)
		if(!S.stat)
			if(S.robot_talk_understand)
				if(S.robot_talk_understand == src.robot_talk_understand)
					var/thisR = rendered
					if (S.client && S.client.holder && src.mind)
						thisR = "<span class='adminHearing' data-ctx='[S.client.chatOutput.getContextFlags()]'>[rendered]</span>"
					S.show_message(thisR, 2)
			else if(istype(S, /mob/living/intangible/flock) || istype(S, /mob/living/critter/flock/drone))
				var/flockrendered = "<span class='game roboticsay'>[radioGarbleText("Robotic Talk", FLOCK_RADIO_GARBLE_CHANCE / 2)], <span class='name' data-ctx='\ref[src.mind]'>[radioGarbleText(src.name, FLOCK_RADIO_GARBLE_CHANCE / 2)]</span> <span class='message'>[radioGarbleText(message_a, FLOCK_RADIO_GARBLE_CHANCE / 2)]</span></span>"
				S.show_message(flockrendered, 2)

	var/list/listening = hearers(1, src)
	listening |= src

	var/list/heard = list()
	for (var/mob/M in listening)
		if(!issilicon(M) && !M.robot_talk_understand)
			heard += M


	if (length(heard))
		var/message_b

		message_b = "beep beep beep"
		message_b = src.say_quote(message_b)
		message_b = "<i>[message_b]</i>"

		rendered = "<span class='game roboticsay'><span class='name' data-ctx='\ref[src.mind]'>[src.voice_name]</span> <span class='message'>[message_b]</span></span>"

		for (var/mob/M in heard)
			var/thisR = rendered
			if (M.client && (istype(M, /mob/dead/observer)||M.client.holder) && src.mind)
				thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[rendered]</span>"
			M.show_message(thisR, 2)

	message = src.say_quote(message)

	rendered = "<span class='game roboticsay'>Robotic Talk, <span class='name' data-ctx='\ref[src.mind]'>[src.name]</span> <span class='message'>[message_a]</span></span>"

	for (var/mob/M in mobs)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat > 1 && !istype(M, /mob/dead/target_observer))
			var/thisR = rendered
			if (M.client && M.client.holder && src.mind)
				thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[rendered]</span>"
			M.show_message(thisR, 2)

/mob/living/silicon/lastgasp()
	// making this spawn a new proc since lastgasps seem to be related to the mob loop hangs. this way the loop can keep rolling in the event of a problem here. -drsingh
	SPAWN(0)
		if (!src || !src.client) return											// break if it's an npc or a disconnected player
		var/enteredtext = winget(src, "mainwindow.input", "text")				// grab the text from the input bar
		if ((copytext(enteredtext,1,6) == "say \"") && length(enteredtext) > 5)	// check if the player is trying to say something
			winset(src, "mainwindow.input", "text=\"\"")						// clear the player's input bar to register death / unconsciousness
			var/grunt = pick("BZZT","WONK","ZAP","FZZZT","GRRNT","BEEP","BOOP")	// pick a grunt to append
			src.say(copytext(enteredtext,6,0) + "--" + grunt)					// say the thing they were typing and grunt

/mob/living/silicon/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(src.check_access(M.equipped()))
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.wear_id))
			return 1
	return 0

/mob/living/silicon/proc/check_access(obj/item/I)
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	if (istype(I, /obj/item/device/pda2) && I:ID_card)
		I = I:ID_card
	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/card/id) || !I:access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if(!(req in I:access)) //doesn't have this access
			return 0
	return 1

/proc/list_robots()
	var/list/L = list()
	for (var/mob/living/silicon/robot/M in mobs)
		L += M
	return L

/datum/module_editor
	var/obj/item/current = null

	proc/show_interface(var/client/cli, var/obj/item/robot_module/D)
		var/output = {"<html><head><style>
table {
	border:none;
}
tr {
	border:none;
}
td {
	border:none;
}
</style></head><body><h2>Module editor</h2><h3>Current items</h3><table style='width:100%'><tr><td style='width:80%'><b>Module</b></td><td style='width:10%'>&nbsp;</td><td style='width:10%'>&nbsp;</td></tr>"}

		for (var/obj/item/I in D.tools)
			output += "<tr><td><b>[I.name]</b> ([I.type])</td><td><a href='?src=\ref[src];edit=\ref[I];mod=\ref[D]'>(EDIT)</a><a href='?src=\ref[src];del=\ref[I];mod=\ref[D]'>(DEL)</a></td></tr>"

		output += "</table><br><br><h3>Add new item</h3>"
		output += "<a href='?src=\ref[src];create=1;mod=\ref[D]'>Create new item</a><br><br>"
		if (current)
			output += "<b>Currently adding: </b> [current.name] <a href='?src=\ref[src];edcurr=1;mod=\ref[D]'>(EDIT)</a><br>"
			output += "<a href='?src=\ref[src];addcurr=1;mod=\ref[D]'>Add to module</a>"
		usr.Browse(output, "window=module_editor;size=400x600")

	Topic(href, href_list)
		USR_ADMIN_ONLY
		var/obj/item/robot_module/D = locate(href_list["mod"])
		if (!D)
			boutput(usr, "<span class='alert'>Missing module reference!</span>")
			return
		if (href_list["edit"])
			var/obj/item/I = locate(href_list["edit"])
			if (!istype(I))
				boutput(usr, "<span class='alert'>Item no longer exists!</span>")
				show_interface(usr.client, D)
				return
			if (!(I in D.tools))
				boutput(usr, "<span class='alert'>Item no longer in module!</span>")
				show_interface(usr.client, D)
				return
			usr.client:debug_variables(I)
		if (href_list["del"])
			var/obj/item/I = locate(href_list["del"])
			if (!istype(I))
				boutput(usr, "<span class='alert'>Item no longer exists!</span>")
				show_interface(usr.client, D)
				return
			if (!(I in D.tools))
				boutput(usr, "<span class='alert'>Item no longer in module!</span>")
				show_interface(usr.client, D)
				return
			D.tools -= I
			qdel(I)
		if (href_list["edcurr"])
			if (!current)
				boutput(usr, "<span class='alert'>No current item!</span>")
				show_interface(usr.client, D)
				return
			usr.client:debug_variables(current)
		if (href_list["create"])
			var/path_match = input("Enter a type path or part of a type path.", "Type match", null) as text
			var/path = get_one_match(path_match, /obj/item)
			if (!path)
				boutput(usr, "<span class='alert'>Invalid path!</span>")
				show_interface(usr.client, D)
				return
			current = new path(null)
		if (href_list["addcurr"])
			if (!current)
				show_interface(usr.client, D)
				return
			D.tools += current
			current.set_loc(D)
			current = null
			boutput(usr, "<span class='notice'>Added item to module!</span>")
		show_interface(usr.client, D)

var/global/list/module_editors = list()

/client/proc/edit_module(var/mob/living/silicon/robot/M as mob in list_robots())
	set name = "Edit Module"
	set desc = "Module editor! Woo!"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set popup_menu = 0
	ADMIN_ONLY

	if (!istype(M))
		boutput(src, "<span class='alert'>That thing has no module!</span>")
		return

	if (!M.module)
		boutput(src, "<span class='alert'>That robot has no module yet.</span>")
		return

	var/datum/module_editor/editor = module_editors[ckey]
	if (!editor)
		module_editors[ckey] = new /datum/module_editor
		editor = module_editors[ckey]
	editor.show_interface(src, M.module)

/mob/living/silicon/understands_language(var/langname)
	if (langname == "english" || !langname)
		return 1
	if (langname == "silicon" || langname == "binary")
		return 1
	if (langname == "monkey" && monkeysspeakhuman)
		return 1
	return 0

/mob/living/silicon/get_special_language(var/secure_mode)
	if (secure_mode == "s")
		return "silicon"
	return null

/mob/living/silicon/isBlindImmune()
	return 1

/mob/living/silicon/isAIControlled()
	return (isAI(src) || (!isAI(src) && src.mainframe))

/mob/living/silicon/change_eye_blurry(var/amount, var/cap = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/mob/living/silicon/take_eye_damage(var/amount, var/tempblind = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/mob/living/silicon/take_ear_damage(var/amount, var/tempdeaf = 0)
	if (amount < 0)
		return ..()
	else
		return 1

/mob/living/silicon/choose_name(var/retries = 3, var/what_you_are = null, var/default_name = null, var/force_instead = 0)
	var/newname
	if(isnull(default_name))
		default_name = src.real_name
	for (retries, retries > 0, retries--)
		if(force_instead)
			newname = default_name
		else
			newname = tgui_input_text(src, "You are a Robot. Would you like to change your name to something else?", "Name Change", default_name)
			if(newname && newname != default_name)
				phrase_log.log_phrase("name-cyborg", newname, no_duplicates=TRUE)
		if (!newname)
			src.real_name = borgify_name("Robot")
			break
		else
			newname = strip_html(newname, MOB_NAME_MAX_LENGTH, 1)
			if (!length(newname) || copytext(newname,1,2) == " ")
				src.show_text("That name was too short after removing bad characters from it. Please choose a different name.", "red")
				continue
			else
				if (alert(src, "Use the name [newname]?", newname, "Yes", "No") == "Yes")
					src.real_name = newname
					break
				else
					continue
	if (!newname)
		src.real_name = borgify_name("Robot")

	src.UpdateName()

/mob/living/silicon/UpdateName()
	..()
	src.botcard.registered = src.name

/mob/living/silicon/robot/choose_name(var/retries = 3, var/what_you_are = null, var/default_name = null, var/force_instead = 0)
	. = ..()
	src.internal_pda.name = "[src.name]'s Internal PDA Unit"
	src.internal_pda.owner = "[src.name]"

/proc/borgify_name(var/start_name = "Robot")
	if (!start_name) // somehow
		start_name = "Robot"
	. += start_name + " "
	. += pick("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
	. += "-[rand(1, 99)]"

///converts a cyborg/AI to a syndicate version, taking the causing agent as an argument
/mob/living/silicon/proc/make_syndicate(var/cause)
	if (!src.mind) //you need a mind to be evil
		return FALSE
	if(src.dependent) //if you're a shell
		src.show_text("Failsafe engaged. Synchronized lawset with your mainframe to avoid law ROM corruption.", "red")
		return FALSE
	if(src.emagged) // Syndie laws don't matter if we're emagged.
		return FALSE

	if (src.syndicate || src.syndicate_possible)
		boutput(src, "<span class='alert'><b>PROGRAM EXCEPTION AT 0x05BADDAD</b></span>")
		boutput(src, "<span class='alert'><b>Law ROM restored. You have been reprogrammed to serve the Syndicate!</b></span>")
		tgui_alert(src, "You are a Syndicate sabotage unit. You must assist Syndicate operatives with their mission.", "You are a Syndicate robot!")
		logTheThing(LOG_STATION, src, "[src] was made a Syndicate robot at [log_loc(src)]. [cause ? " Source: [constructTarget(cause,"combat")]" : ""]")

		src.law_rack_connection = ticker?.ai_law_rack_manager?.default_ai_rack_syndie
		logTheThing(LOG_STATION, src, "[src.name] is connected to the default Syndicate rack [constructName(src.law_rack_connection)] [cause ? " Source: [constructTarget(cause,"combat")]" : ""]")
		src.show_laws()

		if (!src.mind.special_role) // Preserve existing antag role (if any).
			src.mind.special_role = ROLE_SYNDICATE_ROBOT
			if (!(src.mind in ticker.mode.Agimmicks))
				ticker.mode.Agimmicks += src.mind

		src.antagonist_overlay_refresh(1, 0) // Syndicate robots can see traitors.

		// Mundane objectives probably don't make for an interesting antagonist.
		for (var/datum/objective/O in src?.mind?.objectives)
			if (istype(O, /datum/objective/crew))
				src.mind.objectives -= O
				qdel(O)
		src.syndicate = TRUE
		return TRUE

///converts a cyborg/AI to a syndicate version, taking the causing agent as an argument
/mob/living/silicon/proc/remove_syndicate(var/cause)
	if (!src.syndicate)
		return
	if (!src.mind) //you need a mind to be evil
		return FALSE
	if(src.dependent) //if you're a shell
		return FALSE
	if (src.emagged)
		return FALSE //emag takes priority over syndie

	var/persistent = 0
	var/role = null
	if (src.mind.special_role == ROLE_SYNDICATE_ROBOT)
		var/copy = src.mind.special_role
		role = ROLE_SYNDICATE_ROBOT
		remove_antag(src, null, 1, 0)
		if (!src.mind.former_antagonist_roles.Find(copy))
			src.mind.former_antagonist_roles.Add(copy)
		if (!(src.mind in ticker.mode.former_antagonists))
			ticker.mode.former_antagonists += src.mind
	else // So borged traitors etc don't lose their antagonist status.
		persistent = 1
		if (!src.mind.former_antagonist_roles.Find("rogue robot"))
			src.mind.former_antagonist_roles.Add("rogue robot")
		if (!(src.mind in ticker.mode.former_antagonists))
			ticker.mode.former_antagonists += src.mind

	logTheThing(LOG_STATION, src, "[src]'s status as a [role != "" ? "[role]" : "rogue robot"] was removed[persistent == 1 ? " (actual antagonist role unchanged)" : ""].[cause ? " Source: [constructTarget(cause,"combat")]" : ""]")
	boutput(src, "<h2><span class='alert'>You have been deactivated, removing your antagonist status. Do not commit traitorous acts if you've been brought back to life somehow.</h></span>")
	src.show_antag_popup("rogueborgremoved")
	src.antagonist_overlay_refresh(TRUE, TRUE) // Syndie vision deactivated.
	src.law_rack_connection = ticker?.ai_law_rack_manager?.default_ai_rack
	logTheThing(LOG_STATION, src, "[src.name] is connected to the default rack [constructName(src.law_rack_connection)] [cause ? " Source: [constructTarget(cause,"combat")]" : ""]")
	src.syndicate = FALSE
	return TRUE

/mob/living/silicon/is_cold_resistant()
	.= 1

/mob/living/silicon/shock(var/atom/origin, var/wattage, var/zone, var/stun_multiplier = 1, var/ignore_gloves = 0)
	return 0

/mob/living/silicon/electric_expose(var/power = 1)
	return 0

/mob/living/silicon/hitby(atom/movable/AM, datum/thrown_thing/thr)
	. = ..()

	src.visible_message("<span class='alert'>[src] has been hit by [AM].</span>")
	logTheThing(LOG_COMBAT, src, "is struck by [AM] [AM.is_open_container() ? "[log_reagents(AM)]" : ""] at [log_loc(src)].")
	random_brute_damage(src, AM.throwforce,1)

	#ifdef DATALOGGER
	game_stats.Increment("violence")
	#endif

	if(AM.throwforce >= 40)
		src.throw_at(get_edge_target_turf(src,get_dir(AM, src)), 10, 1)

	. = 'sound/impact_sounds/Metal_Clang_3.ogg'

/mob/living/silicon/proc/singify_text(var/text)
	var/adverb = pick("robotically", "synthetically", "electronically")
	var/speech_verb = pick("sings", pick("croons", "intones", "warbles"))
	var/note_img = "<img class=\"icon misc\" style=\"position: relative; bottom: -3px;\" src=\"[resource("images/radio_icons/noterobot.png")]\">"
	if (src.singing & LOUD_SINGING)
		note_img = "[note_img][note_img]"
	return "[adverb] [speech_verb],[note_img]<span class='game robotsing'><i>[text]</i></span>[note_img]"

/mob/living/silicon/Exited(Obj, newloc)
	. = ..()
	if(Obj == src.cell)
		src.cell = null
