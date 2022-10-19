var/list/datum/chem_request/chem_requests = list()

/datum/chem_request
	var/requester_name = ""
	var/reagent_name = ""
	var/reagent_color = null
	var/note = ""
	var/volume = 5
	var/area_name = "Somewhere"
	var/state = "pending"
	var/id
	var/static/last_id = 0
	// the tick count this request was placed on
	var/time = 0
	New()
		..()
		src.id = ++last_id

/obj/machinery/computer/chem_requester
	name = "Chemical request console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "chemreq"
	var/datum/chem_request/request = new
	var/obj/item/card/id/card = null
	var/max_volume = 400
	var/area_name = null

	ui_data(mob/user)
		. = list()
		if (src.card)
			.["card"] = list("name" = src.card.registered, "role" = src.card.assignment)
		else
			.["card"] = null
		.["selected_reagent"] = src.request.reagent_name
		.["notes"] = src.request.note
		.["volume"] = src.request.volume
		.["silicon_user"] = issilicon(user) || isAI(user)

	ui_static_data(mob/user)
		. = list()
		var/list/chems = list()
		for (var/id in chem_reactions_by_id)
			var/datum/chemical_reaction/reaction = chem_reactions_by_id[id]
			if (reaction.result && !reaction.hidden)
				var/datum/reagent/reagent = reagents_cache[reaction.result]
				if (reagent && !istype(reagent, /datum/reagent/fooddrink)) //all the cocktails clog the UI
					chems[lowertext(reagent.name)] = reagent.id
		for (var/id in basic_elements)
			var/datum/reagent/reagent = reagents_cache[id]
			chems[lowertext(reagent.name)] = id
		.["chemicals"] = sortList(chems, /proc/cmp_text_asc)
		.["max_volume"] = src.max_volume

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "ChemRequester")
			ui.open()

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		switch (action)
			if ("reset_id")
				src.card = null
				qdel(src.request)
				src.request = new
				. = TRUE
			if ("silicon_login")
				var/mob/living/silicon/silicon = ui.user
				//handle AIeyes
				if (isAIeye(ui.user))
					var/mob/living/intangible/aieye/eye = ui.user
					silicon = eye.mainframe
				if (istype(silicon))
					//handle shells
					if (silicon.mainframe)
						silicon = silicon.mainframe
					src.card = silicon.botcard
				. = TRUE
			if ("set_reagent")
				src.request.reagent_name = params["reagent_name"]
				var/datum/reagent/reagent = reagents_cache[params["reagent_id"]]
				if (reagent)
					src.request.reagent_color = list(reagent.fluid_r, reagent.fluid_g, reagent.fluid_b)
				. = TRUE
			if ("set_notes")
				src.request.note = strip_html(copytext(params["notes"], 1, 66))
			if ("set_volume")
				src.request.volume = clamp(params["volume"], 1, src.max_volume)
				. = TRUE
			if ("submit")
				src.request.area_name = src.area_name || (get_area(src))?.name || src.request.area_name
				src.request.requester_name = src.card.registered + " ([src.card.assignment])"
				src.request.time = ticker.round_elapsed_ticks
				//byond jank, lists are only associative if they aren't int indexed
				chem_requests["[src.request.id]"] = src.request
				logTheThing(LOG_STATION, src, "[constructTarget(ui.user)] placed a chemical request for [src.request.volume] units of [src.request.reagent_name] using [src.request.requester_name]'s ID at [log_loc(src)], notes: \"[src.request.note]\"")
				var/datum/signal/pdaSignal = get_free_signal()
				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="RESEARCH-MAILBOT",  "group"=list(MGD_SCIENCE), "sender"="00000000", "message"="Notification: new chemical request received.")
				radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)
				src.request = new
				. = TRUE

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/card/id) || (istype(I, /obj/item/device/pda2) && I:ID_card))
			if (istype(I, /obj/item/device/pda2) && I:ID_card)
				I = I:ID_card
			boutput(user, "<span class='notice'>You swipe the ID card.</span>")
			src.card = I
			tgui_process.try_update_ui(user, src)
		else src.Attackhand(user)

	science
		area_name = "Science"

	medical
		area_name = "Medbay"

/obj/machinery/computer/chem_request_receiver
	name = "Chemical request display"
	icon = 'icons/obj/computer.dmi'
	icon_state = "chemreq"
	req_access = list(access_chemistry)
	object_flags = CAN_REPROGRAM_ACCESS

	proc/get_age(var/datum/chem_request/request)
		var/delta = ticker.round_elapsed_ticks - request.time
		if (delta < 1 MINUTE)
			return "[round(delta / (1 SECOND))]s"
		else
			return "[round(delta / (1 MINUTE))]m"

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "ChemRequestReceiver")
			ui.open()

	ui_data(mob/user)
		var/list/requests = list()
		for (var/request_id in chem_requests)
			var/datum/chem_request/request = chem_requests[request_id]
			requests += list(list(
				"id" = request_id,
				"name" = request.requester_name,
				"reagent_name" = request.reagent_name,
				"volume" = request.volume,
				"reagent_color" = request.reagent_color,
				"notes" = copytext(request.note, 1, 80),
				"area" = request.area_name,
				"state" = request.state,
				"age" = src.get_age(request),
			))
		return list(
			"requests" = requests,
			"allowed" = src.allowed(user)
			)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		switch (action)
			if ("deny")
				var/datum/chem_request/request = chem_requests["[params["id"]]"]
				if (request)
					request.state = "denied"
					logTheThing(LOG_STATION, src, "[constructTarget(ui.user)] denied [request.requester_name]'s chemical request for [request.volume] units of [request.reagent_name] at [log_loc(src)]")
				. = TRUE
			if ("fulfil")
				var/datum/chem_request/request = chem_requests["[params["id"]]"]
				if (request)
					logTheThing(LOG_STATION, src, "[constructTarget(ui.user)] fulfilled [request.requester_name]'s chemical request for [request.volume] units of [request.reagent_name] at [log_loc(src)]")
					request.state = "fulfilled"
				. = TRUE
