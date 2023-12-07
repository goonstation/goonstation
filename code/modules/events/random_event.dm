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
		for(var/mob/living/player in mobs)
			if(is_crew_affected(player))
				. += player

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

#define ARG_INFO_NAME 1
#define ARG_INFO_TYPE 2
#define ARG_INFO_DESC 3
#define ARG_INFO_DEFAULT 4
/datum/random_event_editor/ui_static_data(mob/user)
	. = list()

	.["eventName"] = src.event.name
	.["eventDescription"] = "Uhhh testing 123"
	.["eventOptions"] = list()
	var/typeinfo/datum/random_event/RE = get_type_typeinfo(src.event.type)
	for(var/customization in RE.initialization_args)
		.["eventOptions"][customization[ARG_INFO_NAME]] += list(
			"type" = customization[ARG_INFO_TYPE],
			"description" = customization[ARG_INFO_DESC],
			"value" = src.event.vars[customization[ARG_INFO_NAME]]
		)
		if(customization[ARG_INFO_TYPE] == "LIST_CHILDREN")
			.["eventOptions"][customization[ARG_INFO_NAME]]["list"] = childrentypesof(customization[ARG_INFO_DEFAULT])


/datum/random_event_editor/ui_data()
	. = list()
	.["eventOptions"] = list()
	var/typeinfo/datum/random_event/RE = get_type_typeinfo(src.event.type)
	for(var/customization in RE.initialization_args)
		.["eventOptions"][customization[ARG_INFO_NAME]] += list(
			"type" = customization[ARG_INFO_TYPE],
			"description" = customization[ARG_INFO_DESC],
			"value" = src.event.vars[customization[ARG_INFO_NAME]]
		)
		if(length(customization) >= 5)
			.["eventOptions"][customization[ARG_INFO_NAME]]["a"] = customization[5]
		if(length(customization) >= 6)
			.["eventOptions"][customization[ARG_INFO_NAME]]["b"] = customization[6]
		if(customization[ARG_INFO_TYPE] == "LIST_CHILDREN")
			.["eventOptions"][customization[ARG_INFO_NAME]]["list"] = childrentypesof(customization[ARG_INFO_DEFAULT])


/datum/random_event_editor/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/typeinfo/datum/random_event/RE = get_type_typeinfo(src.event.type)
	switch(action)
		if("modify_event_value")
			for(var/customization in RE.initialization_args)
				if(params["name"]==customization[ARG_INFO_NAME] \
				&& params["type"]==customization[ARG_INFO_TYPE] \
				&& hasvar(src.event, params["name"]))
					src.event.vars[params["name"]] = params["value"]
					. = TRUE
					break

		if("modify_color_value")
			for(var/customization in RE.initialization_args)
				if(params["name"]==customization[ARG_INFO_NAME] \
				&& params["type"]==customization[ARG_INFO_TYPE] \
				&& hasvar(src.event, params["name"]))

					var/new_color = input(usr, "Pick new color", "Event Color") as color|null
					if(new_color)
						src.event.vars[params["name"]] = new_color
					. = TRUE
					break;
		if("activate")
			src.event.event_effect(key_name(usr, 1))
			ui.close()

#undef ARG_INFO_NAME
#undef ARG_INFO_TYPE
#undef ARG_INFO_DESC
#undef ARG_INFO_DEFAULT


ABSTRACT_TYPE(/datum/random_event/major)
ABSTRACT_TYPE(/datum/random_event/major/antag)
ABSTRACT_TYPE(/datum/random_event/major/player_spawn)
ABSTRACT_TYPE(/datum/random_event/major/player_spawn/antag)
ABSTRACT_TYPE(/datum/random_event/minor)
ABSTRACT_TYPE(/datum/random_event/special)
ABSTRACT_TYPE(/datum/random_event/start)
ABSTRACT_TYPE(/datum/random_event/start/until_playing)
