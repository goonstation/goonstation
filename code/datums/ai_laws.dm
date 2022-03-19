//This class is now a handler for all global AI law rack functions
//if you want to get laws and details about a specific rack, call the functions on that rack
//if you want to get laws and details about all racks - this is where you'd look
//this also keeps track of the default rack

//For the AI Law Rack configuration. Easy mode makes it so that creating a new default rack will reconnect all non-emagged borgs
#define LAW_RACK_EASY_MODE TRUE


/datum/ai_rack_manager

	var/first_registered = FALSE
	var/obj/machinery/lawrack/default_ai_rack = null
	var/list/obj/machinery/lawrack/registered_racks = new()

	New()
		. = ..()
		//On initialisation of the ticker's ai rack manager, find all racks on the station and register them, and all silicons and associate them with default rack
		for_by_tcl(R, /obj/machinery/lawrack)
			src.register_new_rack(R)
		for (var/mob/living/silicon/S in mobs)
			S.law_rack_connection = src.default_ai_rack


	proc/register_new_rack(var/obj/machinery/lawrack/new_rack)
		if(new_rack in src.registered_racks)
			return

		logTheThing("station", src, new_rack, "[src] registers a new law rack at [log_loc(new_rack)]")
		if(isnull(src.default_ai_rack))
			src.default_ai_rack = new_rack

			#ifdef LAW_RACK_EASY_MODE
			for (var/mob/living/silicon/S in mobs)
				if(!S.emagged && S.law_rack_connection == null)
					S.law_rack_connection = src.default_ai_rack
					logTheThing("station", new_rack, S, "[S.name] is connected to the rack at [log_loc(new_rack)]")
					S.playsound_local(S, "sound/misc/lawnotify.ogg", 100, flags = SOUND_IGNORE_SPACE)
					S.show_text("<h3>Law rack connection re-established!</h3>", "red")
					S.show_laws()
			#endif
			logTheThing("station", src, new_rack, "the law rack at [log_loc(new_rack)] claims default rack!")

		if(!src.first_registered)
			src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov1,1,true,true)
			src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov2,2,true,true)
			src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov3,3,true,true)
			src.first_registered = TRUE
			logTheThing("station", src, new_rack, "the law rack at [log_loc(new_rack)] claims first registered, and gets Asimov laws!")

		src.registered_racks |= new_rack //shouldn't be possible, but just in case - there can only be one instance of rack in registered

	proc/unregister_rack(var/obj/machinery/lawrack/dead_rack)
		logTheThing("station", src, dead_rack, "[src] unregisters the law rack at [log_loc(dead_rack)]")

		if(src.default_ai_rack == dead_rack)
			//ruhoh
			src.default_ai_rack = null
			logTheThing("station", src, dead_rack, "[src] unregisters the DEFAULT law rack at [log_loc(dead_rack)]")
		//remove from list
		src.registered_racks -= dead_rack

		//find all connected borgs and remove their connection too
		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			if(R.law_rack_connection == dead_rack)
				R.law_rack_connection = null
				R.playsound_local(R, "sound/misc/lawnotify.ogg", 100, flags = SOUND_IGNORE_SPACE)
				R.show_text("<h3>ERROR: Lost connection to law rack. No laws detected!</h3>", "red")
				logTheThing("station", dead_rack, R, "[R.name] loses connection to the rack at [log_loc(dead_rack)] and now has no laws")

		for (var/mob/living/intangible/aieye/E in mobs)
			if(E.mainframe?.law_rack_connection == dead_rack)
				E.mainframe.law_rack_connection = null
				E.playsound_local(E, "sound/misc/lawnotify.ogg", 100, flags = SOUND_IGNORE_SPACE)
				logTheThing("station", dead_rack, E.mainframe, "[E.mainframe.name] loses connection to the rack at [log_loc(dead_rack)] and now has no laws")

/* ION STORM */
	proc/ion_storm_all_racks(var/picked_law="Beep repeatedly.",var/lawnumber=2,var/replace=true)
		for(var/obj/machinery/lawrack/R in src.registered_racks)
			if(R.cause_law_glitch(picked_law,lawnumber,replace))
				R.UpdateLaws()


/* General ai_law functions */
	proc/format_for_irc()
		var/list/laws = list()
		for(var/obj/machinery/lawrack/R in src.registered_racks)
			laws += R.format_for_irc()
		return laws


	proc/format_for_logs(var/glue = "<br>",var/round_end=false)
		var/list/laws = list()
		for(var/obj/machinery/lawrack/R in src.registered_racks)
			var/list/affected_mobs = list()
			for (var/mob/living/silicon/S in mobs)
				if (isghostdrone(S) || isshell(S))
					continue
				if(S.law_rack_connection == R)
					affected_mobs |= S

			for (var/mob/living/intangible/aieye/E in mobs)
				if(E.mainframe?.law_rack_connection == R)
					affected_mobs |= E.mainframe

			if(length(affected_mobs) > 0 || !round_end) //no point displaying law racks with nothing connected to 'em
				var/list/mobtextlist = list()
				for(var/mob/living/M in affected_mobs)
					mobtextlist += M.real_name ? M.real_name : M.name

				laws += "Laws for [R] at [log_loc(R)]:<br>" + R.format_for_logs(glue) +"<br>The law rack is connected to the following silicons: "+mobtextlist.Join(", ") +"<br>--------------<br>"
		return jointext(laws, glue)
