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
	var/weight = 100					//for weighted probability picker. 100 is base

	proc/event_effect(var/source)
		if (!source)
			source = "random"
		if (announce_to_admins)
			message_admins("<span class='internal'>Beginning [src.name] event (Source: [source]).</span>")
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

/datum/random_event/minor
	announce_to_admins = 0

ABSTRACT_TYPE(/datum/random_event/major)
ABSTRACT_TYPE(/datum/random_event/major/antag)
ABSTRACT_TYPE(/datum/random_event/major/player_spawn)
ABSTRACT_TYPE(/datum/random_event/minor)
ABSTRACT_TYPE(/datum/random_event/special)
ABSTRACT_TYPE(/datum/random_event/start)
