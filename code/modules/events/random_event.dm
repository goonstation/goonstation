/datum/random_event
	var/name = null                      // What is this event called?
	var/centcom_headline = null          // The title of the displayed message.
	var/centcom_message = null           // A message displayed to the crew.
	var/centcom_origin = null			 // The origin of the message
	var/message_delay = 0 SECONDS        // How long it takes after the event's effect for the message to arrive.
	var/required_elapsed_round_time = 0  // Round elapsed ticks must be this or higher for the event to trigger naturally.
	var/wont_occur_past_this_time = -1   // Event will no longer occur naturally after this many ticks have elapsed.
	var/disabled = 0                     // Event won't occur if this is true.
	var/announce_to_admins = 1
	var/customization_available = 0
	var/always_custom = FALSE
	var/weight = 100					//for weighted probability picker. 100 is base

	proc/event_effect(var/source)
		if (!source)
			source = "random"
		if (announce_to_admins)
			message_admins(SPAN_INTERNAL("Beginning [src.name] event (Source: [source])."))
			logTheThing(LOG_ADMIN, null, "Random event [src.name] was triggered. Source: [source]")

		if (centcom_headline && centcom_message && random_events.announce_events)
			SPAWN(message_delay)
				command_alert("[centcom_message]", "[centcom_headline]", alert_origin = "[centcom_origin]")

	proc/admin_call(var/source)
		if (!istext(source))
			return 1
		return 0

	proc/is_event_available(var/ignore_time_lock = 0)
		var/timer = ticker.round_elapsed_ticks

		if (!ignore_time_lock && timer < src.required_elapsed_round_time && random_events.time_lock)
			return 0

		if (src.wont_occur_past_this_time > -1)
			if (timer > src.wont_occur_past_this_time && random_events.time_lock)
				return 0

		if (src.disabled)
			return 0

		return 1

	proc/cleanup()
		return

/datum/random_event/minor
	announce_to_admins = 0

/datum/random_event/start
	proc/is_crew_affected(var/mob/living/player)
		. = TRUE

	proc/apply_to_player(var/mob/living/player)
		return

	proc/get_affected_crew()
		. = list()
		for(var/mob/living/M in mobs)
			if (isnpc(M))
				continue
			if(is_crew_affected(M))
				. += M

/datum/random_event/start/until_playing
	var/include_latejoin = FALSE


TYPEINFO(/datum/random_event)
	var/initialization_args = null // let the user select any initialization arguments

/datum/random_event_editor
	var/atom/movable/target
	var/datum/random_event/event

/datum/random_event_editor/New(atom/target, datum/random_event/event)
	..()
	src.target = target
	src.event = event

/datum/random_event_editor/disposing()
	src.target = null
	src.event = null
	..()

/datum/random_event_editor/ui_state(mob/user)
	return tgui_admin_state

/datum/random_event_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RandomEvent")
		ui.open()


/datum/random_event_editor/ui_static_data(mob/user)
	. = ui_data()
	.["eventName"] = src.event.name

/datum/random_event_editor/ui_data()
	. = list()
	.["eventOptions"] = list()
	var/typeinfo/datum/random_event/RE = get_type_typeinfo(src.event.type)
	for(var/customization in RE.initialization_args)
		.["eventOptions"][customization[EVENT_INFO_NAME]] += list(
			"type" = customization[EVENT_INFO_TYPE],
			"description" = customization[EVENT_INFO_DESC],
			"value" = src.event.vars[customization[EVENT_INFO_NAME]]
		)
		if(length(customization) >= EVENT_INFO_VAL_A)
			.["eventOptions"][customization[EVENT_INFO_NAME]]["a"] = customization[EVENT_INFO_VAL_A]
		if(length(customization) >= EVENT_INFO_VAL_B)
			.["eventOptions"][customization[EVENT_INFO_NAME]]["b"] = customization[EVENT_INFO_VAL_B]

		if(customization[EVENT_INFO_TYPE] == DATA_INPUT_LIST_CHILDREN_OF)
			.["eventOptions"][customization[EVENT_INFO_NAME]]["list"] = childrentypesof(customization[EVENT_INFO_VAL_A])
		else if(customization[EVENT_INFO_TYPE] == DATA_INPUT_LIST_PROVIDED)
			.["eventOptions"][customization[EVENT_INFO_NAME]]["list"] = customization[EVENT_INFO_VAL_A]
		else if(customization[EVENT_INFO_TYPE] == DATA_INPUT_LIST_VAR)
			var/list/items = list()
			for(var/key in src.event.vars[customization[EVENT_INFO_VAL_A]])
				items += key
			.["eventOptions"][customization[EVENT_INFO_NAME]]["list"] = items
		else if(customization[EVENT_INFO_TYPE] == DATA_INPUT_REFPICKER)
			var/atom/target = src.event.vars[customization[EVENT_INFO_NAME]]
			if(isatom(target))
				.["eventOptions"][customization[EVENT_INFO_NAME]]["value"] = "([target.x],[target.y],[target.z]) [target]"
			else
				.["eventOptions"][customization[EVENT_INFO_NAME]]["value"] = "null"


/datum/random_event_editor/ui_act(action, list/params, datum/tgui/ui)
	USR_ADMIN_ONLY
	. = ..()
	if(.)
		return

	var/typeinfo/datum/random_event/RE = get_type_typeinfo(src.event.type)
	switch(action)
		if("modify_value", "modify_list_value")
			for(var/customization in RE.initialization_args)
				if(params["name"]==customization[EVENT_INFO_NAME] \
				&& params["type"]==customization[EVENT_INFO_TYPE] \
				&& hasvar(src.event, params["name"]))
					src.event.vars[params["name"]] = params["value"]
					. = TRUE
					break

		if("modify_color_value")
			for(var/customization in RE.initialization_args)
				if(params["name"]==customization[EVENT_INFO_NAME] \
				&& params["type"]==customization[EVENT_INFO_TYPE] \
				&& hasvar(src.event, params["name"]))

					var/new_color = input(usr, "Pick new color", "Event Color") as color|null
					if(new_color)
						src.event.vars[params["name"]] = new_color
					. = TRUE
					break;

		if("modify_ref_value")
			for(var/customization in RE.initialization_args)
				if(params["name"]==customization[EVENT_INFO_NAME] \
				&& params["type"]==customization[EVENT_INFO_TYPE] \
				&& hasvar(src.event, params["name"]))
					var/atom/target = pick_ref(usr)
					src.event.vars[params["name"]] = target
					. = TRUE
					break;

		if("activate")
			src.event.event_effect(key_name(usr, 1))
			ui.close()

ABSTRACT_TYPE(/datum/random_event/major)
ABSTRACT_TYPE(/datum/random_event/major/antag)
ABSTRACT_TYPE(/datum/random_event/major/player_spawn)
ABSTRACT_TYPE(/datum/random_event/major/player_spawn/antag)
ABSTRACT_TYPE(/datum/random_event/minor)
ABSTRACT_TYPE(/datum/random_event/special)
ABSTRACT_TYPE(/datum/random_event/start)
ABSTRACT_TYPE(/datum/random_event/start/until_playing)
