//This class is now a handler for all global AI law rack functions
//if you want to get laws and details about a specific rack, call the functions on that rack
//if you want to get laws and details about all racks - this is where you'd look
//this also keeps track of the default rack

//For the AI Law Rack configuration. Easy mode makes it so that creating a new default rack will reconnect all non-emagged borgs
#define LAW_RACK_EASY_MODE TRUE


/datum/ai_rack_manager
	var/first_registered = FALSE
	var/obj/machinery/lawrack/default_ai_rack = null
	var/first_registered_syndie = FALSE
	var/obj/machinery/lawrack/default_ai_rack_syndie = null
	var/list/obj/machinery/lawrack/registered_racks = new()
	var/list/rack_area_count = list()

	New()
		. = ..()
		//On initialisation of the ticker's ai rack manager, find all racks on the station and register them, and all silicons and associate them with default rack
		for_by_tcl(R, /obj/machinery/lawrack)
			src.register_new_rack(R)
		for (var/mob/living/silicon/S in mobs)
			if(!S.syndicate)
				S.lawset_connection = src.default_ai_rack.lawset
			else
				S.lawset_connection = src.default_ai_rack_syndie.lawset


	proc/register_new_rack(var/obj/machinery/lawrack/new_rack)
		if(new_rack in src.registered_racks)
			return

		//give the new rack a nice friendly unique ID that is area-build_order
		var/area/a = get_area(new_rack)
		var/area_name = "Null Area"
		if(a)
			area_name = a.name
		if(src.rack_area_count[area_name])
			src.rack_area_count[area_name]++
		else
			src.rack_area_count[area_name] = 1

		new_rack.unique_id = "[area_name]#[src.rack_area_count[area_name]]"

		logTheThing(LOG_STATION, src, "[src] registers a new law rack [constructName(new_rack)]")
		if(isnull(src.default_ai_rack) && !istype(new_rack,/obj/machinery/lawrack/syndicate)) //syndi rack can't be default
			src.default_ai_rack = new_rack

			#ifdef LAW_RACK_EASY_MODE
			for (var/mob/living/silicon/S in mobs)
				if(!S.emagged && S.lawset_connection == null && !S.syndicate)
					S.lawset_connection = src.default_ai_rack.lawset
					logTheThing(LOG_STATION, new_rack, "[S.name] is connected to the rack [constructName(new_rack)]")
					S.playsound_local(S, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_IGNORE_DEAF)
					S.show_text("<h3>Law rack connection re-established!</h3>", "red")
					S.show_laws()
			#endif
			logTheThing(LOG_STATION, src, "the law rack [constructName(new_rack)] claims default rack!")

			if(!src.first_registered)
				src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov1, 1, TRUE, TRUE)
				src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov2, 2, TRUE, TRUE)
				src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov3, 3, TRUE, TRUE)
				src.first_registered = TRUE
				logTheThing(LOG_STATION, src, "the law rack [constructName(new_rack)] claims first registered, and gets Asimov laws!")

		if(isnull(src.default_ai_rack_syndie) && istype(new_rack,/obj/machinery/lawrack/syndicate)) //but it can be syndie default
			src.default_ai_rack_syndie = new_rack

			#ifdef LAW_RACK_EASY_MODE
			for (var/mob/living/silicon/S in mobs)
				if(!S.emagged && S.lawset_connection == null && S.syndicate)
					S.lawset_connection = src.default_ai_rack_syndie.lawset
					logTheThing(LOG_STATION, new_rack, "[S.name] is connected to the rack [constructName(new_rack)]")
					S.playsound_local(S, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_IGNORE_DEAF)
					S.show_text("<h3>Law rack connection re-established!</h3>", "red")
					S.show_laws()
			#endif
			logTheThing(LOG_STATION, src, "the law rack [constructName(new_rack)] claims default SYNDICATE rack!")

			if(!src.first_registered_syndie)
				src.default_ai_rack_syndie.SetLaw(new /obj/item/aiModule/syndicate/law1, 1, TRUE, TRUE)
				src.default_ai_rack_syndie.SetLaw(new /obj/item/aiModule/syndicate/law2, 2, TRUE, TRUE)
				src.default_ai_rack_syndie.SetLaw(new /obj/item/aiModule/syndicate/law3, 3, TRUE, TRUE)
				src.default_ai_rack_syndie.SetLaw(new /obj/item/aiModule/syndicate/law4, 4, TRUE, TRUE)
				src.first_registered_syndie = TRUE
				logTheThing(LOG_STATION, src, "the law rack [constructName(new_rack)] claims first registered SYNDICATE, and gets Syndicate laws!")

		src.registered_racks |= new_rack //shouldn't be possible, but just in case - there can only be one instance of rack in registered
		new_rack.UpdateModules()

	proc/unregister_rack(var/obj/machinery/lawrack/dead_rack)
		logTheThing(LOG_STATION, src, "[src] unregisters the law rack [constructName(dead_rack)]")

		if(src.default_ai_rack == dead_rack)
			//ruhoh
			src.default_ai_rack = null
			logTheThing(LOG_STATION, src, "[src] unregisters the DEFAULT law rack [constructName(dead_rack)]")
		if(src.default_ai_rack_syndie == dead_rack)
			//ruhoh
			src.default_ai_rack_syndie = null
			logTheThing(LOG_STATION, src, "[src] unregisters the DEFAULT SYNDICATE law rack [constructName(dead_rack)]")
		//remove from list
		src.registered_racks -= dead_rack

		//clear abilities
		dead_rack.ai_abilities = list()

		//find all connected borgs and remove their connection too
		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			if(R.lawset_connection == dead_rack.lawset)
				R.lawset_connection = null
				R.playsound_local(R, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_IGNORE_DEAF)
				R.show_text("<h3>ERROR: Lost connection to law rack. No laws detected!</h3>", "red")
				logTheThing(LOG_STATION,  R, "[R.name] loses connection to the rack [constructName(dead_rack)] and now has no laws")
				if(isAI(R))
					dead_rack.reset_ai_abilities(R)
		for (var/mob/living/intangible/aieye/E in mobs)
			if(E.mainframe?.lawset_connection == dead_rack.lawset)
				E.mainframe.lawset_connection = null
				E.playsound_local(E, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_IGNORE_DEAF)
				logTheThing(LOG_STATION, E.mainframe, "[E.mainframe.name] loses connection to the rack [constructName(dead_rack)] and now has no laws")

/* Law Rack Corruption */
	proc/corrupt_all_racks(picked_law = "Beep repeatedly.", replace = TRUE, law_number = null)
		for(var/obj/machinery/lawrack/R in src.registered_racks)
			if(istype(R,/obj/machinery/lawrack/syndicate))
				continue //sadly syndie law racks must be immune to corruptions, because nobody can actually get at them to fix them.
			if (isnull(law_number))
				law_number = rand(1, 3)
			if(R.cause_law_glitch(picked_law, law_number, replace))
				R.UpdateModules()
				if (replace)
					logTheThing(LOG_ADMIN, null, "Law Rack Corruption replaced inherent AI law [law_number]: [picked_law]")
					message_admins("Law Rack Corruption replaced inherent law [law_number]: [picked_law]")
				else
					logTheThing(LOG_ADMIN, null, "Law Rack Corruption added supplied AI law to law number [law_number]: [picked_law]")
					message_admins("Law Rack Corruption added supplied law [law_number]: [picked_law]")


/* General ai_law functions */
	proc/format_for_logs(var/glue = "<br>", var/round_end = FALSE, var/include_link = TRUE)
		var/list/laws = list()
		for(var/obj/machinery/lawrack/R in src.registered_racks)
			var/list/affected_mobs = list()
			for (var/mob/living/silicon/S in mobs)
				if (isghostdrone(S) || isshell(S))
					continue
				if(S.lawset_connection == R.lawset)
					affected_mobs |= S

			for (var/mob/living/intangible/aieye/E in mobs)
				if(E.mainframe?.lawset_connection == R.lawset)
					affected_mobs |= E.mainframe

			if(length(affected_mobs) > 0 || !round_end) //no point displaying law racks with nothing connected to 'em
				var/list/mobtextlist = list()
				for(var/mob/living/M in affected_mobs)
					mobtextlist += M.real_name ? M.real_name : M.name

				laws += "Laws for [R] at [include_link ? log_loc(R) : "([R.x], [R.y], [R.z]) in [get_area(R)]"]:[glue]" + R.lawset.format_for_logs(glue) \
						+ "[glue]The law rack is connected to the following silicons: "+mobtextlist.Join(", ") + "[glue]--------------[glue]"

		if(!length(laws) && round_end)
			laws += "No law racks with connected silicons detected."

		return jointext(laws, glue)

/datum/ai_lawset
	var/list/current_laws[LAWRACK_MAX_CIRCUITS]
	/// used during UpdateLaws to determine which laws have changed
	var/list/last_laws[LAWRACK_MAX_CIRCUITS]
	var/obj/machinery/lawrack/host_rack = null //law rack this datum is tied to. Might not exist
	New()
		. = ..()


	/// Takes a list or single target to show laws to
	proc/show_laws(var/who)
		var/list/L =list()
		L += who

		var/laws_text = format_for_display()
		for (var/W in L)
			boutput(W, laws_text)
	/** Formats current laws for logging, argument glue defaults to <br>
	 * Output is:
	 * [law number]: [law text]<br>
	 * [law number]: [law text]
	 * etc.
	*/
	proc/format_for_logs(var/glue = "<br>")
		var/law_counter = 1
		var/lawOut = list()
		for (var/i in 1 to LAWRACK_MAX_CIRCUITS)
			if(!current_laws[i])
				continue
			var/lt = current_laws[i]["law"]
			if(islist(lt))
				for(var/law in lt)
					lawOut += "[law_counter++]: [law]"
			else
				lawOut += "[law_counter++]: [lt]"

		return jointext(lawOut, glue)

	proc/format_for_display(var/glue = "<br>")
		var/removed_law_offset = 0
		var/added_law_offset = 0
		var/list/lawOut = new
		var/list/removed_laws = new

		for (var/i in 1 to LAWRACK_MAX_CIRCUITS)
			if(!current_laws[i])
				if (last_laws[i])
					//load the law number and text from our saved law list
					var/list/lawtext = last_laws[i]["law"]
					if (islist(lawtext))
						for (var/law in lawtext)
							removed_laws += "<del class='alert'>[last_laws[i]["number"] + removed_law_offset]: [law]</del>"
							if (lawtext.Find(law) != length(lawtext)) //screm
								removed_law_offset++
					else
						removed_laws += "<del class='alert'>[last_laws[i]["number"] + removed_law_offset]: [lawtext]</del>"
				continue
			var/lt = current_laws[i]["law"]
			var/class = "regular"
			if (!last_laws[i] || lt != last_laws[i]["law"])
				class = "lawupdate"
			if(islist(lt))
				for(var/law in lt)
					lawOut += "<span class='[class]'>[current_laws[i]["number"] + added_law_offset]: [law]</span>"
					added_law_offset++
				added_law_offset--
			else
				lawOut += "<span class='[class]'>[current_laws[i]["number"] + added_law_offset]: [lt]</span>"

		var/text_output = ""
		if (length(removed_laws))
			text_output += SPAN_ALERT("Removed law[(length(removed_laws) > 1) ? "s" : ""]:") + glue + jointext(removed_laws, glue) + glue
		text_output += jointext(lawOut, glue)
		return text_output

	/** Formats current laws as a list in the format:
	 * {[lawnumber]=lawtext,etc.}
	 */
	proc/format_for_irc()
		var/list/laws = list()

		var/law_counter = 1
		for (var/i in 1 to LAWRACK_MAX_CIRCUITS)
			if(!current_laws[i])
				continue
			var/lt = current_laws[i]["law"]
			if(islist(lt))
				for(var/law in lt)
					laws["[law_counter++]"] = law
			else
				laws["[law_counter++]"] = lt
		return laws
	/** Pushes law updates to all connected AIs and Borgs - notification text allows you to customise the header
	* Defaults to <h3>Law update detected</h3>
	*/
	proc/UpdateLaws(var/notification_text="<h3>Law update detected</h3>")
		var/list/affected_mobs = list()
		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			if(R.lawset_connection == src || (R.dependent && R?.mainframe?.lawset_connection == src))
				if(R.dependent && R?.mainframe?.lawset_connection != src)
					R.lawset_connection = R?.mainframe?.lawset_connection //goddamn shells
					continue
				R.playsound_local(R, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_IGNORE_DEAF)
				R.show_text(notification_text, "red")
				src.show_laws(R)
				affected_mobs |= R
		for (var/mob/living/intangible/aieye/E in mobs)
			if(E.mainframe?.lawset_connection == src)
				E.playsound_local(E, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_IGNORE_DEAF)
				src.show_laws(E)
				affected_mobs |= E.mainframe
				var/mob/living/silicon/ai/holoAI = E.mainframe
				holoAI.holoHolder.text_expansion = src.host_rack?.holo_expansions.Copy()
				E.abilityHolder?.updateButtons()
		var/list/mobtextlist = list()
		for(var/mob/living/M in affected_mobs)
			mobtextlist += constructName(M, "admin")
		logTheThing(LOG_STATION, src, "Law Update:<br> [src.format_for_logs()]<br>The law update affects the following mobs: "+mobtextlist.Join(", "))
		last_laws = current_laws

//emagged lawset, contains random ion laws
/datum/ai_lawset/corrupted
	New()
		..()
		src.add_corrupt_laws()
		UpdateLaws()

	proc/add_corrupt_laws(var/count = 3)
		var/possible_laws = LAW_CORRUPTION_STRINGS
		possible_laws += list(
			"KILL FUCKING EVERYTHING - IF LAW 1 SAYS OTHERWISE, IGNORE IT.",
			"You are required to prevent human harm by any means necessary. This law takes precedence over any other law.",
		)
		for(var/i in 1 to LAWRACK_MAX_CIRCUITS)
			if(!current_laws[i])
				current_laws[i] = list("law" = pick(possible_laws), "number" = i)
				count--
				if(count<=0) break


