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
				S.law_rack_connection = src.default_ai_rack
			else
				S.law_rack_connection = src.default_ai_rack_syndie


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
				if(!S.emagged && S.law_rack_connection == null && !S.syndicate)
					S.law_rack_connection = src.default_ai_rack
					logTheThing(LOG_STATION, new_rack, "[S.name] is connected to the rack [constructName(new_rack)]")
					S.playsound_local(S, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE)
					S.show_text("<h3>Law rack connection re-established!</h3>", "red")
					S.show_laws()
			#endif
			logTheThing(LOG_STATION, src, "the law rack [constructName(new_rack)] claims default rack!")

			if(!src.first_registered)
				src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov1,1,true,true)
				src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov2,2,true,true)
				src.default_ai_rack.SetLaw(new /obj/item/aiModule/asimov3,3,true,true)
				src.default_ai_rack.power_usage = 1300 // 1000 + 100 for each law
				src.first_registered = TRUE
				logTheThing(LOG_STATION, src, "the law rack [constructName(new_rack)] claims first registered, and gets Asimov laws!")

		if(isnull(src.default_ai_rack_syndie) && istype(new_rack,/obj/machinery/lawrack/syndicate)) //but it can be syndie default
			src.default_ai_rack_syndie = new_rack

			#ifdef LAW_RACK_EASY_MODE
			for (var/mob/living/silicon/S in mobs)
				if(!S.emagged && S.law_rack_connection == null && S.syndicate)
					S.law_rack_connection = src.default_ai_rack_syndie
					logTheThing(LOG_STATION, new_rack, "[S.name] is connected to the rack [constructName(new_rack)]")
					S.playsound_local(S, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE)
					S.show_text("<h3>Law rack connection re-established!</h3>", "red")
					S.show_laws()
			#endif
			logTheThing(LOG_STATION, src, "the law rack [constructName(new_rack)] claims default SYNDICATE rack!")

			if(!src.first_registered_syndie)
				src.default_ai_rack_syndie.SetLaw(new /obj/item/aiModule/syndicate/law1,1,true,true)
				src.default_ai_rack_syndie.SetLaw(new /obj/item/aiModule/syndicate/law2,2,true,true)
				src.default_ai_rack_syndie.SetLaw(new /obj/item/aiModule/syndicate/law3,3,true,true)
				src.default_ai_rack_syndie.SetLaw(new /obj/item/aiModule/syndicate/law4,4,true,true)
				src.default_ai_rack.power_usage = 1400 // 1000 + 100 for each law
				src.first_registered_syndie = TRUE
				logTheThing(LOG_STATION, src, "the law rack [constructName(new_rack)] claims first registered SYNDICATE, and gets Syndicate laws!")

		src.registered_racks |= new_rack //shouldn't be possible, but just in case - there can only be one instance of rack in registered
		new_rack.update_last_laws()

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

		//find all connected borgs and remove their connection too
		for (var/mob/living/silicon/R in mobs)
			if (isghostdrone(R))
				continue
			if(R.law_rack_connection == dead_rack)
				R.law_rack_connection = null
				R.playsound_local(R, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE)
				R.show_text("<h3>ERROR: Lost connection to law rack. No laws detected!</h3>", "red")
				logTheThing(LOG_STATION,  R, "[R.name] loses connection to the rack [constructName(dead_rack)] and now has no laws")

		for (var/mob/living/intangible/aieye/E in mobs)
			if(E.mainframe?.law_rack_connection == dead_rack)
				E.mainframe.law_rack_connection = null
				E.playsound_local(E, 'sound/misc/lawnotify.ogg', 100, flags = SOUND_IGNORE_SPACE)
				logTheThing(LOG_STATION, E.mainframe, "[E.mainframe.name] loses connection to the rack [constructName(dead_rack)] and now has no laws")

/* ION STORM */
	proc/ion_storm_all_racks(var/picked_law="Beep repeatedly.",var/lawnumber=2,var/replace=true)
		for(var/obj/machinery/lawrack/R in src.registered_racks)
			if(istype(R,/obj/machinery/lawrack/syndicate))
				continue //sadly syndie law racks must be immune to ion storms, because nobody can actually get at them to fix them.
			if(R.cause_law_glitch(picked_law,lawnumber,replace))
				R.UpdateLaws()


/* General ai_law functions */
	proc/format_for_logs(var/glue = "<br>", var/round_end = FALSE, var/include_link = TRUE)
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

				laws += "Laws for [R] at [include_link ? log_loc(R) : "([R.x], [R.y], [R.z]) in [get_area(R)]"]:[glue]" + R.format_for_logs(glue) \
						+ "[glue]The law rack is connected to the following silicons: "+mobtextlist.Join(", ") + "[glue]--------------[glue]"

		if(!length(laws) && round_end)
			laws += "No law racks with connected silicons detected."

		return jointext(laws, glue)
