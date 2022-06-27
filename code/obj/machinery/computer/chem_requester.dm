var/list/datum/chem_request/chem_requests = list()

/datum/chem_request
	var/requester_name = ""
	var/reagent_name = ""
	var/reagent_color = null
	var/note = ""
	var/volume = 5
	var/area/area = null
	var/state = "pending"
	var/id
	var/static/last_id = 0
	var/time
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

	ui_data(mob/user)
		. = list()
		if (src.card)
			.["card"] = list("name" = src.card.registered, "role" = src.card.assignment)
		else
			.["card"] = null
		.["selected_reagent"] = src.request.reagent_name
		.["notes"] = src.request.note
		.["volume"] = src.request.volume

	ui_static_data(mob/user)
		. = list()
		var/list/chems = list()
		for (var/id in chem_reactions_by_id)
			var/datum/chemical_reaction/reaction = chem_reactions_by_id[id]
			if (reaction.result)
				var/datum/reagent/reagent = reagents_cache[reaction.result]
				if (reagent && !istype(reagent, /datum/reagent/fooddrink)) //all the cocktails clog the UI
					chems[reagent.name] = reagent.id
		.["chemicals"] = sortList(chems)
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
			if ("set_reagent")
				src.request.reagent_name = params["reagent_name"]
				var/datum/reagent/reagent = reagents_cache[params["reagent_id"]]
				if (reagent)
					src.request.reagent_color = list(reagent.fluid_r, reagent.fluid_g, reagent.fluid_b)
				. = TRUE
			if ("set_notes")
				src.request.note = strip_html(params["notes"], 80)
			if ("set_volume")
				src.request.volume = clamp(params["volume"], 1, src.max_volume)
				. = TRUE
			if ("submit")
				src.request.area = get_area(src)
				src.request.requester_name = src.card.registered + " ([src.card.assignment])"
				//byond jank, lists are only associative if they aren't int indexed
				chem_requests["[src.request.id]"] = src.request
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

/obj/machinery/computer/chem_request_receiver
	name = "Chemical request display"
	icon = 'icons/obj/computer.dmi'
	icon_state = "chemreq"
	req_access = list(access_chemistry)
	object_flags = CAN_REPROGRAM_ACCESS

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
				"area" = request.area.name,
				"state" = request.state
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
				. = TRUE
			if ("fulfil")
				var/datum/chem_request/request = chem_requests["[params["id"]]"]
				if (request)
					request.state = "fulfilled"
				. = TRUE
