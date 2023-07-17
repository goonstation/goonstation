// most of this is taken from chem_requester.dm, so there's a heads up for you.

var/list/datum/botany_request/botany_requests = list()

/datum/botany_request
	var/requester_name = ""
	var/produce_id = ""
	var/produce_name = ""
	var/produce_color = null
	var/note = ""
	var/amount = 1
	var/area_name = "Somewhere"
	var/state = "pending"
	var/id
	var/static/last_id = 0
	/// the tick count this request was placed on
	var/time = 0
	New()
		..()
		src.id = ++last_id

/obj/machinery/computer/botany_requester
	name = "Hydroponics request console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "botanyreq"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/datum/botany_request/request = new
	var/obj/item/card/id/card = null
	var/max_amount = 50
	var/area_name = null

	get_help_message(dist, mob/user)
		return null

	ui_data(mob/user)
		. = list()
		if (src.card)
			.["card"] = list("name" = src.card.registered, "role" = src.card.assignment)
		else
			.["card"] = null
		.["selected_produce"] = src.request.produce_name
		.["notes"] = src.request.note
		.["amount"] = src.request.amount
		.["silicon_user"] = issilicon(user) || isAI(user)

	ui_static_data(mob/user)
		. = list()
		var/list/produce = list()
		for (var/plant in concrete_typesof(/datum/plant))
			produce[lowertext(plant.produce_name)] = plant
		.["produce"] = sortList(produce, /proc/cmp_text_asc)
		.["max_amount"] = src.max_amount

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "BotanyRequester")
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
			if ("set_produce")
				src.request.produce_name = params["produce_name"]
				src.request.produce_id = params["produce_id"]
				. = TRUE
			if ("set_notes")
				src.request.note = strip_html(copytext(params["notes"], 1, 66))
			if ("set_amount")
				src.request.amount = clamp(params["amount"], 1, src.max_amount)
				. = TRUE
			if ("submit")
				src.request.area_name = src.area_name || (get_area(src))?.name || src.request.area_name
				src.request.requester_name = src.card.registered + " ([src.card.assignment])"
				src.request.time = ticker.round_elapsed_ticks
				//byond jank, lists are only associative if they aren't int indexed
				botany_requests["[src.request.id]"] = src.request
				logTheThing(LOG_STATION, src, "[constructTarget(ui.user)] placed a botanical request for [src.request.amount] [src.request.produce_id][src.request.amount > 1 ? "s" : ""] using [src.request.requester_name]'s ID at [log_loc(src)], notes: \"[src.request.note]\"")
				var/datum/signal/pdaSignal = get_free_signal()
				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="HYDROPONICS-MAILBOT",  "group"=list(MGD_BOTANY), "sender"="00000000", "message"="Notification: new botanical request received.")
				radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)
				src.request = new
				. = TRUE

	attackby(var/obj/item/I, mob/user)
		var/obj/item/card/id/id_card = get_id_card(I)
		if (istype(id_card))
			boutput(user, "<span class='notice'>You swipe the ID card.</span>")
			src.card = id_card
			tgui_process.try_update_ui(user, src)
		else src.Attackhand(user)

	science
		area_name = "Science"

	medical
		area_name = "Medbay"

/obj/machinery/computer/botany_request_receiver
	name = "Hydroponic request display"
	icon = 'icons/obj/computer.dmi'
	icon_state = "botanyreq"
	req_access = list(access_hydro)
	object_flags = CAN_REPROGRAM_ACCESS
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL

	get_help_message(dist, mob/user)
		return null

	proc/get_age(var/datum/botany_request/request)
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
		for (var/request_id in botany_requests)
			var/datum/botany_request/request = botany_requests[request_id]
			requests += list(list(
				"id" = request_id,
				"name" = request.requester_name,
				"produce_name" = request.produce_name,
				"amount" = request.amount,
				"produce_color" = request.produce_color,
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
				var/datum/botany_request/request = botany_requests["[params["id"]]"]
				if (request)
					request.state = "denied"
					logTheThing(LOG_STATION, src, "[constructTarget(ui.user)] denied [request.requester_name]'s chemical request for [request.amount] units of [request.produce_id] at [log_loc(src)]")
				. = TRUE
			if ("fulfil")
				var/datum/botany_request/request = botany_requests["[params["id"]]"]
				if (request)
					logTheThing(LOG_STATION, src, "[constructTarget(ui.user)] fulfilled [request.requester_name]'s chemical request for [request.amount] units of [request.produce_id] at [log_loc(src)]")
					request.state = "fulfilled"
				. = TRUE
