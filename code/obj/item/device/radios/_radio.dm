#define WIRE_SIGNAL 1
#define WIRE_RECEIVE 2
#define WIRE_TRANSMIT 4
#define WINDOW_OPTIONS "window=radio;size=280x350"

TYPEINFO(/obj/item/device/radio)
	mats = 3
	start_listen_effects = list(LISTEN_EFFECT_RADIO)
	start_listen_modifiers = list(LISTEN_MODIFIER_RADIO)
	start_listen_inputs = list(LISTEN_INPUT_EQUIPPED)
	start_listen_languages = list(LANGUAGE_ALL)
	start_speech_modifiers = list(SPEECH_MODIFIER_RADIO)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_RADIO, SPEECH_OUTPUT_RADIO_GLOBAL, SPEECH_OUTPUT_RADIO_GLOBAL_DEFAULT_ONLY, SPEECH_OUTPUT_RADIO_GLOBAL_UNPROTECTED_ONLY)

/obj/item/device/radio
	name = "station bounced radio"
	desc = "A portable, non-wearable radio for communicating over a specified frequency. Has a microphone and a speaker which can be independently toggled."
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "radio"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	throw_speed = 2
	throw_range = 9
	w_class = W_CLASS_SMALL
	say_language = LANGUAGE_ENGLISH

	// Primary Channel Variables:
	/// Determines the colour of messages sent by the radio and certain aspects of this device's sprite.
	var/device_color = null
	/// The CSS class that should be used for messages sent over the primary channel of this radio. Overridden by `device_color`.
	var/chat_class = RADIOCL_STANDARD
	/// The frequency of the primary channel of this radio.
	var/frequency = R_FREQ_DEFAULT
	/// Whether the primary frequency may be changed from its default setting. If TRUE, permits the frequency to exist outside of the default range.
	var/locked_frequency = FALSE

	// Secure Channel Variables:
	/// A list of radio packet componenets that this radio has attached to it, indexed by channel prefix.
	var/list/datum/component/packet_connected/radio/secure_connections = null
	/// A list of available secure radio channel frequencies, indexed by channel prefix.
	var/list/secure_frequencies = null
	/// The colour that should be used for messages sent over each channel, indexed by channel prefix. Alternatively a single colour may be defined for all channels to use that colour. Overrides `secure_classes`.
	var/list/secure_colors = list()
	/// The overriding CSS classes that should be used for messages sent over each channel, indexed by channel prefix. Alternatively a class under the index "all" may be defined for all undefined channels to use that style (e.g. secure_classes = list("all" = RADIOCL_SYNDICATE)). Overridden by `secure_colors`.
	var/list/secure_classes = list()

	// Additional Message Styling Variables:
	/// If set, this is radio icon that this radio should display on sent messages. See the `browserassets/images/radio_icons` folder.
	var/icon_override = null
	/// If set, the tooltip that the radio icon of this radio should use. `null` will result in the radio name being used. "" will result in no tooltip.
	var/icon_tooltip = null
	/// Whether this radio will always display maptext.
	var/forced_maptext = FALSE

	// Microphone Variables:
	/// Whether this radio should display a microphone component in its UI.
	var/has_microphone = TRUE
	/// The listen input module that this radio's microphone should use.
	var/microphone_listen_input = LISTEN_INPUT_OUTLOUD
	/// Whether this radio's microphone is enabled. If so, it will be capable of hearing spoken messages within a range around it.
	var/microphone_enabled = FALSE
	/// Whether this radio's microphone starts enabled.
	var/initial_microphone_enabled = FALSE

	// Speaker Variables:
	/// Whether this radio should display a speaker component in its UI.
	var/has_speaker = TRUE
	/// The range in which radio messages received by this radio should be spoken to listeners.
	var/speaker_range = 2
	/// Whether this radio's speaker is enabled. If not, received radio messages will not be spoken.
	var/speaker_enabled = FALSE
	/// Whether this radio's speaker starts enabled.
	var/initial_speaker_enabled = FALSE

	// Radio Uplink Variables:
	/// If TRUE, messages sent over a protected channel cannot be picked up by the `radio_brain` bioeffect.
	var/protected_radio = FALSE
	/// The radio frequency that, when this radio is tuned to it, will unlock the traitor uplink.
	var/traitor_frequency = 0
	/// The integrated traitor radio uplink.
	var/obj/item/uplink/integrated/radio/traitorradio = null

	// Miscellaneous Variables:
	/// The world time of this radio's last transmission.
	var/last_transmission
	/// Whether this radio is capable of sending messages during solar flares.
	var/hardened = TRUE
	/// If TRUE, this radio will no longer be capable of sending nor receiving messages.
	var/bricked = FALSE
	/// The message that should be displayed when an attempt is made to use a bricked radio.
	var/bricked_msg = "The radio is utterly dead and silent."
	/// This radio's wires, determining whether it can receive and transmit.
	var/wires = WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT
	/// The build status of this radio, determining whether it can be attached to other objects, and other objects attached to it.
	var/b_stat = FALSE

/obj/item/device/radio/New()
	. = ..()

	if (((src.frequency < R_FREQ_MINIMUM) || (src.frequency > R_FREQ_MAXIMUM)) && !src.locked_frequency)
		// If the frequency is somehow set outside of the normal range, clamp it back within range.
		world.log << "[src] ([src.type]) has a frequency of [src.frequency], sanitizing."
		src.frequency = sanitize_frequency(src.frequency)

	MAKE_DEVICE_RADIO_PACKET_COMPONENT(null, "main", src.frequency)

	src.set_secure_frequencies()
	src.toggle_microphone(src.initial_microphone_enabled)
	src.toggle_speaker(src.initial_speaker_enabled)
	src.bricked = global.no_more_radios
	START_TRACKING

/obj/item/device/radio/disposing()
	for (var/prefix in src.secure_connections)
		qdel(src.secure_connections[prefix])

	src.secure_connections = null
	src.traitorradio = null
	STOP_TRACKING

	. = ..()

/obj/item/device/radio/examine(mob/user)
	. = ..()

	if (in_interact_range(src, user) || (src.loc == user))
		if (src.b_stat)
			. += "<br>[SPAN_NOTICE("[src] can be attached and modified!")]"
		else
			. += "<br>[SPAN_NOTICE("[src] can not be modified or attached!")]"

	if (length(src.secure_frequencies))
		. += "<br><b>Supplementary channels:</b>"
		for (var/sayToken in src.secure_frequencies)
			var/channel_name = global.headset_channel_lookup["[src.secure_frequencies["[sayToken]"]]"] || "???"
			var/frequency = format_frequency(src.secure_frequencies["[sayToken]"])
			. += "<br>[channel_name]: \[[frequency]\] (Activator: <b>[sayToken]</b>)"

/obj/item/device/radio/receive_signal(datum/signal/signal)
	if (!src.speaker_enabled || src.bricked || !(src.wires & WIRE_RECEIVE) || !signal.data || !istype(signal.data["message"], /datum/say_message))
		return TRUE

	var/datum/say_message/message = signal.data["message"]
	message = message.Copy()
	message.speaker = src
	message.message_origin = src
	message.heard_range = src.speaker_range

	src.ensure_speech_tree().process(message)

/obj/item/device/radio/attackby(obj/item/W, mob/user)
	src.add_dialog(user)
	if (!isscrewingtool(W))
		return
	src.b_stat = !src.b_stat
	if (src.b_stat)
		user.show_message(SPAN_NOTICE("The radio can now be attached and modified!"))
	else
		user.show_message(SPAN_NOTICE("The radio can no longer be modified or attached!"))
	if (isliving(src.loc))
		var/mob/living/M = src.loc
		src.AttackSelf(M)
	src.add_fingerprint(user)

/obj/item/device/radio/attack_self(mob/user)
	src.ui_interact(user)

/obj/item/device/radio/emp_act()
	src.toggle_microphone(FALSE)
	src.toggle_speaker(FALSE)

/obj/item/device/radio/ui_interact(mob/user, datum/tgui/ui)
	if (src.bricked)
		user.show_text(src.bricked_msg, "red")
		return

	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Radio")
		ui.open()

/obj/item/device/radio/ui_state(mob/user)
	return tgui_physical_state

/obj/item/device/radio/ui_status(mob/user, datum/ui_state/state)
	if (isAI(user))
		. = UI_INTERACTIVE
	else
		. = min(
			state.can_use_topic(src, user),
			tgui_not_incapacitated_state.can_use_topic(src, user)
		)

/obj/item/device/radio/ui_data(mob/user)
	var/list/frequencies = list()
	for (var/sayToken in src.secure_frequencies)
		frequencies += list(list(
			"channel" = global.headset_channel_lookup["[src.secure_frequencies[sayToken]]"] || "???",
			"frequency" = format_frequency(src.secure_frequencies[sayToken]),
			"sayToken" = sayToken,
		))

	. = list(
		"name" = src.name,
		"hasMicrophone" = src.has_microphone,
		"microphoneEnabled" = src.microphone_enabled,
		"hasSpeaker" = src.has_speaker,
		"speakerEnabled" = src.speaker_enabled,
		"frequency" = src.frequency,
		"lockedFrequency" = src.locked_frequency,
		"secureFrequencies" = frequencies,
		"wires" = src.wires,
		"modifiable" = src.b_stat,
	)

/obj/item/device/radio/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if (. || src.bricked)
		return

	switch(action)
		if ("set-frequency")
			if (src.locked_frequency)
				return FALSE
			src.set_frequency(sanitize_frequency(params["value"]))

			// The "finish" param indicates that a user has inputted a number or finished dragging the frequency dial.
			// This makes it more difficult to bruteforce the uplink.
			if (params["finish"] && !isnull(src.traitorradio) && src.traitor_frequency && src.frequency == src.traitor_frequency)
				ui.close()
				src.remove_dialog(usr)
				usr.Browse(null, WINDOW_OPTIONS)
				global.onclose(usr, "radio")

				// Transform the regular radio into a disguised Syndicate uplink.
				var/obj/item/uplink/integrated/radio/T = src.traitorradio
				var/obj/item/device/radio/R = src
				R.set_loc(T)
				usr.u_equip(R)
				usr.put_in_hand_or_drop(T)
				R.set_loc(T)
				T.AttackSelf(usr)
				return

			return TRUE

		if ("toggle-microphone")
			src.toggle_microphone(!src.microphone_enabled)
			return TRUE

		if ("toggle-speaker")
			src.toggle_speaker(!src.speaker_enabled)
			return TRUE

		if ("toggle-wire")
			if (!(usr.find_tool_in_hand(TOOL_SNIPPING)))
				return FALSE

			var/wireflip = params["wire"] & (WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT)
			if (wireflip)
				src.wires ^= wireflip
				return TRUE

/// Sets the primary frequency of the radio to a specified frequency.
/obj/item/device/radio/proc/set_frequency(new_frequency)
	src.frequency = new_frequency
	global.get_radio_connection_by_id(src, "main").update_frequency(src.frequency)

/// Initialises the `secure_connections` list from the frequencies listed in `secure_frequencies`.
/obj/item/device/radio/proc/set_secure_frequencies()
	if (!length(src.secure_frequencies))
		return

	src.secure_connections ||= list()

	for (var/sayToken in src.secure_frequencies)
		var/frequency_id = src.secure_frequencies["[sayToken]"]
		if (frequency_id)
			if (!src.secure_connections["[sayToken]"])
				src.secure_connections["[sayToken]"] = MAKE_DEVICE_RADIO_PACKET_COMPONENT(null, "f[frequency_id]", frequency_id)
		else
			src.secure_frequencies -= "[sayToken]"

/// Sets a secure frequency, specified using its channel prefix, to a new frequency.
/obj/item/device/radio/proc/set_secure_frequency(frequencyToken, newFrequency)
	if (!frequencyToken || !newFrequency)
		return

	src.secure_frequencies ||= list()
	src.secure_connections ||= list()

	qdel(src.secure_connections["[frequencyToken]"])
	src.secure_connections["[frequencyToken]"] = MAKE_DEVICE_RADIO_PACKET_COMPONENT(null, "f[newFrequency]", newFrequency)
	src.secure_frequencies["[frequencyToken]"] = newFrequency

/// Toggles the radio microphone, determining whether it is capable of hearing spoken messages within a range around it.
/obj/item/device/radio/proc/toggle_microphone(microphone_enabled)
	if (src.microphone_enabled == microphone_enabled)
		return

	src.microphone_enabled = microphone_enabled

	src.ensure_listen_tree()
	if (src.microphone_enabled)
		src.listen_tree.AddListenInput(src.microphone_listen_input)
	else
		src.listen_tree.RemoveListenInput(src.microphone_listen_input)

/// Toggles the radio speaker, determining whether received radio messages should be spoken.
/obj/item/device/radio/proc/toggle_speaker(speaker_enabled)
	src.speaker_enabled = speaker_enabled

/// Returns the HTML radio icon and tooltip.
/obj/item/device/radio/proc/radio_icon(mob/user)
	if (isAI(user))
		. = "ai"
	else if (isrobot(user))
		. = "robo"
	else if (icon_override)
		. = icon_override

	if (.)
		. = "<img style='position: relative; left: -1px; bottom: -3px;' class='icon misc' src='[resource("images/radio_icons/[.].png")]'>"
	else
		. = bicon(src)

	var/tooltip = src.icon_tooltip
	if (isnull(tooltip))
		tooltip = src.name
	if (tooltip)
		. = "<div class='tooltip'>[.]<span class='tooltiptext'>[tooltip]</span></div>"


TYPEINFO(/obj/item/radiojammer)
	mats = 10

/obj/item/radiojammer
	name = "signal jammer"
	desc = "An illegal device used to jam radio signals, preventing broadcast or transmission."
	icon = 'icons/obj/shield_gen.dmi'
	icon_state = "shieldoff"
	w_class = W_CLASS_TINY
	is_syndicate = TRUE
	var/active = FALSE
	var/range = DEFAULT_RADIO_JAMMER_RANGE

/obj/item/radiojammer/New()
	. = ..()
	src.RegisterSignal(src, COMSIG_SIGNAL_JAMMED, PROC_REF(signal_jammed))

/obj/item/radiojammer/disposing()
	STOP_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)
	. = ..()

/obj/item/radiojammer/get_desc(dist, mob/user)
	. = ..()
	. += " The range is currently set to [src.range]."
	if(!src.active)
		.+= " It is off."

/obj/item/radiojammer/proc/signal_jammed(_source, datum/signal/signal)
	//hoping this isn't too performance heavy if a lot of signals get blocked at once
	if (!src.GetOverlayImage("jammed_light"))
		//automatic heartbeat signals: we still want to know when we're jamming them but we probably don't care most of the time
		var/icon_state = signal.data["command"] == "heartbeat" ? "signal_jammed_heartbeat" : "signal_jammed"
		src.UpdateOverlays(image(src.icon, icon_state), "jammed_light")
	SPAWN(2 DECI SECONDS)
		src.ClearSpecificOverlays("jammed_light")

/obj/item/radiojammer/attack_self(mob/user)
	if (!istype(global.radio_controller))
		return

	src.active = !src.active

	if (src.active)
		boutput(user, "You activate [src].")
		src.icon_state = "shieldon"
		START_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)
	else
		boutput(user, "You shut off [src].")
		icon_state = "shieldoff"
		STOP_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)

/obj/item/radiojammer/attackby(obj/item/W, mob/user, params)
	if(isscrewingtool(W) || ispulsingtool(W))
		src.edit_range(user)
		return
	. = ..()

/obj/item/radiojammer/proc/edit_range(mob/user)
	var/inputted_number = tgui_input_number(user, "Input radio jammer range", "Radio Jammer", DEFAULT_RADIO_JAMMER_RANGE, DEFAULT_RADIO_JAMMER_RANGE, 1)
	if(!inputted_number)
		return
	if(!can_act(user))
		boutput(user, SPAN_ALERT("Not while incapacitated!"))
		return
	if(BOUNDS_DIST(src,user) > 1)
		boutput(user, SPAN_ALERT("You are too far away from [src]!"))
		return
	inputted_number = trunc(inputted_number)
	if(!isnum_safe(inputted_number) || inputted_number > DEFAULT_RADIO_JAMMER_RANGE || inputted_number < 1)
		boutput(user, SPAN_ALERT("That number is out of [src]'s range!"))
		return
	src.range = inputted_number
	boutput(user, SPAN_NOTICE("You set [src]'s range to [inputted_number]."))

#undef WIRE_SIGNAL
#undef WIRE_RECEIVE
#undef WIRE_TRANSMIT
#undef WINDOW_OPTIONS
