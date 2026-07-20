/* ================== COMPONENTIZED PHONES ==================
 To turn something into a phone, you just need to be able to handle the relevant signals and
 correctly update the phone directory. Thankfully, the components do this all for you.
 Simply add the following components to your phone, and have a means of sending the following signals:

	/datum/component/phone_controller
	/datum/component/phone_ui
	/datum/component/phone_microphone
	/datum/component/phone_speaker
	/datum/component/phone_ringer

	COMSIG_PHONE_UI_INTERACT(user)
	COMSIG_PHONE_ANSWER
	COMSIG_PHONE_HANGUP

 These do most of the work for you, but are not required. Landlines don't use COMSIG_PHONE_ANSWER, for instance.
 You can always make your own UI, not have a speaker, or even make your own unique microphone component.
 These are just the basic components and signals you should be able to use for most purposes.

*/

// ================== GLOBALS ==================

/// [phone_id (which should be unique)] = [list(controller_parent, unlisted, can_talk_across_z_levels, category, color)]
/// All phones should always be listed here, regardless of if they're able to be called or not
var/global/list/phone_directory = list()
#define PHONE_DIRECTORY_PARENT 1
#define PHONE_DIRECTORY_UNLISTED 2
#define PHONE_DIRECTORY_Z 3
#define PHONE_DIRECTORY_CATEGORY 4
#define PHONE_DIRECTORY_COLOR 5

/// Returns a valid unique phone name/id, optionally auto-generated if name is left null
/// Controller components always use this when setting their name with COMSIG_PHONE_SET_INFO
/proc/phone_id_handler(var/datum/controller_parent, var/name)
	// Generate a name for the phone.
	var/temp_name = "phone"
	if (isnull(name))
		if(isatom(controller_parent))
			var/atom/parent_atom = controller_parent
			temp_name = parent_atom.name
			var/area/location = get_area(parent_atom)
			if ((temp_name == parent_atom::name) && location)
				temp_name = location.name
		name = temp_name
	temp_name = name // gonna reuse this variable in a sec
	var/safe_name_found = FALSE
	var/name_counter = 1
	var/match_found = FALSE
	while (!safe_name_found)
		match_found = FALSE
		for (var/phone_id in phone_directory)
			if (phone_id == temp_name)
				match_found = TRUE
				temp_name = name + " [name_counter]"
				name_counter++
				break
		if(!match_found)
			safe_name_found = TRUE
			name = temp_name
	return name

/// Our job is to handle connections between ourselves and other phones, and
///  take outbound signals and sending them as inbound signals on any connected phone
/// We assume everyone else will do the work of validation for signals, we just pass it along
/datum/component/phone_controller
	/// Who are we connected to and should forward signals to? (Even if one side hasn't picked up yet)
	/// If this is not null, we inherently cannot take calls
	var/datum/partner = null

	// misc vars
	var/can_talk_across_z_levels = TRUE
	var/unlisted = FALSE

	// Phone identification stuff
	var/phone_category = null
	var/phone_id = null
	var/stripe_color = null

	var/last_called = null

// old vars that are possibly needed
	var/dialing = FALSE
	var/emagged = FALSE
	var/ringing = FALSE

TYPEINFO(/datum/component/phone_controller)
	initialization_args = list(
		ARG_INFO("_phone_id", DATA_INPUT_TEXT, "unique identifier/name for the phone", null),
		ARG_INFO("_phone_category", DATA_INPUT_TEXT, "location category (e.g security)", "uncategorized"),
		ARG_INFO("_can_talk_across_z_levels", DATA_INPUT_BOOL, "if it works across z levels", 1),
		ARG_INFO("_unlisted", DATA_INPUT_BOOL, "whether or not to be visible to other phones", 0),
		ARG_INFO("_stripe_color", DATA_INPUT_COLOR, "what color should be associated with it", "#b65f08")
	)

/datum/component/phone_controller/Initialize(
		_phone_id,
		_phone_category = "uncategorized",
		_can_talk_across_z_levels = TRUE,
		_unlisted = FALSE,
		_stripe_color = "#b65f08"
	)
		. = ..()
		src.set_info(null, list("id" = _phone_id, "category" = _phone_category, "color" = _stripe_color))
		src.set_unlisted(null, _unlisted)
		src.set_can_z(null, _can_talk_across_z_levels)

		RegisterSignal(parent, COMSIG_PHONE_INBOUND_CONNECTION, PROC_REF(inbound_connection))
		RegisterSignal(parent, COMSIG_PHONE_INBOUND_DISCONNECTION, PROC_REF(inbound_disconnection))
		RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_CONNECTION, PROC_REF(outbound_connection))
		RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_DISCONNECTION, PROC_REF(outbound_disconnection))
		RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_SPEECH, PROC_REF(outbound_speech))
		RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_SOUND, PROC_REF(outbound_sound))
		RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_VAPE, PROC_REF(outbound_vape))
		RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_VOLTRON, PROC_REF(outbound_voltron))
		RegisterSignal(parent, COMSIG_PHONE_CHECK_Z, PROC_REF(check_z))
		RegisterSignal(parent, COMSIG_PHONE_CHECK_CONNECTED, PROC_REF(check_connected))
		RegisterSignal(parent, COMSIG_PHONE_SET_INFO, PROC_REF(set_info))
		RegisterSignal(parent, COMSIG_PHONE_SET_UNLISTED, PROC_REF(set_unlisted))
		RegisterSignal(parent, COMSIG_PHONE_SET_CAN_Z, PROC_REF(set_can_z))
		RegisterSignal(parent, COMSIG_PHONE_ANSWER, PROC_REF(answer))
		RegisterSignal(parent, COMSIG_PHONE_HANGUP, PROC_REF(hangup))

		phone_directory[phone_id] = list(parent, unlisted, can_talk_across_z_levels, phone_category, stripe_color)

/datum/component/phone_controller/UnregisterFromParent()
	SEND_SIGNAL(parent, COMSIG_PHONE_OUTBOUND_DISCONNECTION)
	UnregisterSignal(parent, COMSIG_PHONE_INBOUND_CONNECTION)
	UnregisterSignal(parent, COMSIG_PHONE_INBOUND_DISCONNECTION)
	UnregisterSignal(parent, COMSIG_PHONE_OUTBOUND_CONNECTION)
	UnregisterSignal(parent, COMSIG_PHONE_OUTBOUND_DISCONNECTION)
	UnregisterSignal(parent, COMSIG_PHONE_OUTBOUND_SPEECH)
	UnregisterSignal(parent, COMSIG_PHONE_OUTBOUND_SOUND)
	UnregisterSignal(parent, COMSIG_PHONE_OUTBOUND_VAPE)
	UnregisterSignal(parent, COMSIG_PHONE_OUTBOUND_VOLTRON)
	UnregisterSignal(parent, COMSIG_PHONE_CHECK_Z)
	UnregisterSignal(parent, COMSIG_PHONE_CHECK_CONNECTED)
	UnregisterSignal(parent, COMSIG_PHONE_SET_INFO)
	UnregisterSignal(parent, COMSIG_PHONE_SET_UNLISTED)
	UnregisterSignal(parent, COMSIG_PHONE_SET_CAN_Z)
	UnregisterSignal(parent, COMSIG_PHONE_ANSWER)
	UnregisterSignal(parent, COMSIG_PHONE_HANGUP)
	phone_directory.Remove(phone_id)
	. = ..()

/// Another phone wants to connect to us
/// Disambiguation: This only means the initial connection; accepting is not the same as picking up
/datum/component/phone_controller/proc/inbound_connection(datum/source, datum/phone_caller, var/inbound_caller_id_message)
	. = SEND_SIGNAL(parent, COMSIG_PHONE_INBOUND_CONNECTION_OBJECTION_CHECK)
	if(.)
		return
	if(!isnull(src.partner))
		if(src.partner == phone_caller)
			CRASH()
		return PHONE_REJECTED

	src.partner = caller
	SEND_SIGNAL(src.parent, COMSIG_PHONE_RING_START, inbound_caller_id_message)
	return PHONE_ACCEPTED

/// Our partner is disconnecting from us </3
/datum/component/phone_controller/proc/inbound_disconnection(datum/source, datum/old_partner)
	if(isnull(src.partner))
		CRASH() //todo text here
	if(src.partner != old_partner)
		CRASH() //todo text here
	src.on_disconnection()

/datum/component/phone_controller/proc/on_disconnection()
	src.partner = null
	SEND_SIGNAL(src.parent, COMSIG_PHONE_RING_STOP)

/// Something wants us to connect to a specific phone
/datum/component/phone_controller/proc/outbound_connection(datum/source, target_id)
	if(partner)
		return PHONE_REJECTED
	. = SEND_SIGNAL(parent, COMSIG_PHONE_OUTBOUND_CONNECTION_OBJECTION_CHECK)
	if(.)
		return
	var/datum/target
	// there's a delay between dialing and starting the call, and we'd risk a bad index if the target phone
	// gets deleted in that time
	try
		target = phone_directory[target_id][PHONE_DIRECTORY_PARENT]
	catch
		return PHONE_FAILED
	. = SEND_SIGNAL(target, COMSIG_PHONE_INBOUND_CONNECTION, parent, src.get_caller_id_message())
	if(. & PHONE_ACCEPTED)
		src.partner = target
	else
		SEND_SIGNAL(parent, COMSIG_PHONE_INBOUND_SOUND, 'sound/machines/phones/phone_busy.ogg', 50, 0)
		return

/// Something wants us to disconnect from our partner
/datum/component/phone_controller/proc/outbound_disconnection(datum/source)
	if(!src.partner)
		return PHONE_FAILED
	. = SEND_SIGNAL(src.partner, COMSIG_PHONE_INBOUND_DISCONNECTION, src.parent)
	src.on_disconnection()

/datum/component/phone_controller/proc/outbound_speech(datum/source, var/list/said_message, var/echo = FALSE)
	if(!src.partner)
		return PHONE_FAILED
	. = SEND_SIGNAL(src.partner, COMSIG_PHONE_INBOUND_SPEECH, said_message, echo)

/datum/component/phone_controller/proc/outbound_sound(datum/source, sound_file, vol = 50, vary = 0)
	if(!src.partner)
		return PHONE_FAILED
	. = SEND_SIGNAL(src.partner, COMSIG_PHONE_INBOUND_SOUND, sound_file, vol = 50, vary = 0)

/datum/component/phone_controller/proc/outbound_vape(datum/source, list/vape_list)
	if(!src.partner)
		return PHONE_FAILED
	. = SEND_SIGNAL(src.partner, COMSIG_PHONE_INBOUND_VAPE, vape_list)

/datum/component/phone_controller/proc/outbound_voltron(datum/source, list/voltron_list)
	if(!src.partner)
		return PHONE_FAILED
	. = SEND_SIGNAL(src.partner, COMSIG_PHONE_INBOUND_VOLTRON, voltron_list)

/datum/component/phone_controller/proc/check_z(datum/source, z2check)
	if(z2check == get_z(parent))
		return 1

/datum/component/phone_controller/proc/check_connected(datum/source)
	if(partner)
		return TRUE
	else
		return FALSE

/datum/component/phone_controller/proc/set_info(datum/source, list/new_info)
	var/list/updated_info = list()
	if(new_info["id"] || isnull(src.phone_id))
		SEND_SIGNAL(parent, COMSIG_PHONE_OUTBOUND_DISCONNECTION)
		phone_directory.Remove(phone_id)
		src.phone_id = phone_id_handler(parent, new_info["id"])
		updated_info["id"] = src.phone_id
	if(new_info["category"])
		src.phone_category = new_info["category"]
		updated_info["category"] = new_info["category"]
	if(new_info["color"])
		src.stripe_color = new_info["color"]
		updated_info["color"] = new_info["color"]
	phone_directory[phone_id] = list(parent, unlisted, can_talk_across_z_levels, phone_category, stripe_color)
	SEND_SIGNAL(parent, COMSIG_PHONE_INFO_UPDATED, updated_info)

/datum/component/phone_controller/proc/get_caller_id_message()
	return "<span style=\"color: [src.stripe_color];\">[src.phone_id]</span>"

/datum/component/phone_controller/proc/set_unlisted(datum/source, do_unlisted)
	src.unlisted = do_unlisted
	phone_directory[phone_id][PHONE_DIRECTORY_UNLISTED] = src.unlisted

/datum/component/phone_controller/proc/set_can_z(datum/source, allow_across_z)
	src.can_talk_across_z_levels = allow_across_z
	phone_directory[phone_id][PHONE_DIRECTORY_Z] = src.can_talk_across_z_levels

/datum/component/phone_controller/proc/answer()
	SEND_SIGNAL(src.parent, COMSIG_PHONE_RING_STOP)
	SEND_SIGNAL(src.parent, COMSIG_PHONE_MICROPHONE_ENABLE)
	SEND_SIGNAL(src.parent, COMSIG_PHONE_SPEAKER_ENABLE)

/datum/component/phone_controller/proc/hangup()
	SEND_SIGNAL(src.parent, COMSIG_PHONE_OUTBOUND_DISCONNECTION)
	SEND_SIGNAL(src.parent, COMSIG_PHONE_MICROPHONE_DISABLE)
	SEND_SIGNAL(src.parent, COMSIG_PHONE_SPEAKER_DISABLE)

// Default UI =======================================================================

/datum/component/phone_ui
	var/datum/controller_parent = null
	/// The name of the last phone we tried to dial
	var/last_called = "None"
	/// If we're in the middle of dialing
	var/dialing = FALSE
	// todo fix
	var/name = "TEST NAME"

TYPEINFO(/datum/component/phone_ui)
	initialization_args = list(
		ARG_INFO("_controller_parent", DATA_INPUT_REF, "the datum containing the phone controller we care about, if it's different from our parent", null)
	)

/datum/component/phone_ui/Initialize(_controller_parent)
	. = ..()
	if(_controller_parent)
		src.controller_parent = _controller_parent
	else
		src.controller_parent = parent
	RegisterSignal(src.controller_parent, COMSIG_PHONE_UI_INTERACT, PROC_REF(signal_ui_interact))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_UI_CLOSE, PROC_REF(phone_ui_close))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_CONNECTION_OBJECTION_CHECK, PROC_REF(inbound_connection_check))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_INFO_UPDATED, PROC_REF(info_updated))

/datum/component/phone_ui/UnregisterFromParent()
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_UI_INTERACT)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_UI_CLOSE)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_CONNECTION_OBJECTION_CHECK)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_INFO_UPDATED)
	. = ..()

/datum/component/phone_ui/proc/signal_ui_interact(datum/source, mob/user)
	src.ui_interact(user)

/datum/component/phone_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Phone")
		ui.open()

/datum/component/phone_ui/ui_data(mob/user)
	var/list/list/list/phonebook = list()
	for(var/P in phone_directory)
		var/match_found = FALSE
		var/unlisted = phone_directory[P][PHONE_DIRECTORY_UNLISTED]
		if (unlisted)
			continue
		var/datum/phone_parent = phone_directory[P][PHONE_DIRECTORY_PARENT]
		if (phone_parent == src.controller_parent)
			continue
		var/can_z = phone_directory[P][PHONE_DIRECTORY_Z]
		if (!can_z && !SEND_SIGNAL(phone_parent, COMSIG_PHONE_CHECK_Z, get_z(src.controller_parent)))
			continue
		var/category = phone_directory[P][PHONE_DIRECTORY_CATEGORY]
		if (length(phonebook))
			for (var/i in 1 to length(phonebook))
				if (phonebook[i]["category"] == category)
					match_found = TRUE
					phonebook[i]["phones"] += list(list(
						"id" = P
					))
					break
		if (!match_found)
			phonebook += list(list(
				"category" = category,
				"phones" = list(list(
					"id" = P
				))
			))

	// The UI expects null for inCall if we're not connected
	var/incall = null
	if(SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_CHECK_CONNECTED))
		incall = TRUE
	. = list(
		"dialing" = src.dialing,
		"inCall" = incall,
		"lastCalled" = src.last_called,
		"name" = src.name
	)

	.["phonebook"] = phonebook

/datum/component/phone_ui/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch (action)
		if ("call")
			if (src.dialing == TRUE || SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_CHECK_CONNECTED))
				return
			. = TRUE
			var/id = params["target"]
			// good to double-check since uis don't immediately update
			if(!phone_directory[id][PHONE_DIRECTORY_UNLISTED])
				src.start_call(id)
				return
			boutput(usr, SPAN_ALERT("Unable to connect!"))

/datum/component/phone_ui/proc/start_call(target_id)
	if(SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_OUTBOUND_CONNECTION_OBJECTION_CHECK)) return

	src.dialing = TRUE
	tgui_process?.update_uis(src)

	SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_INBOUND_SOUND, 'sound/machines/phones/dial.ogg')

	// in the slight chance we start dialing after the target phone blew up but before our UI updated
	try
		src.last_called = phone_directory[target_id][PHONE_DIRECTORY_UNLISTED] ? "Undisclosed" : "[target_id]"
	catch
		SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_INBOUND_SOUND, 'sound/machines/phones/phone_busy.ogg')
		return

	SPAWN(4 SECONDS)
		SEND_SIGNAL(controller_parent, COMSIG_PHONE_OUTBOUND_CONNECTION, target_id)
		src.dialing = FALSE

/datum/component/phone_ui/proc/inbound_connection_check()
	if(src.dialing)
		return PHONE_REJECTED

/datum/component/phone_ui/proc/phone_ui_close()
	tgui_process.close_uis(src)

/datum/component/phone_ui/proc/info_updated(datum/source, list/info_list)
	if(info_list["id"])
		src.name = info_list["id"]

// Microphone =======================================================================

/// Turns an atom into a microphone, setting up speech trees accordingly. This will NOT remove them upon component removal.
/// You may safely not use this if you don't need a microphone, or have another means of sending outbound phone signals
/datum/component/phone_microphone
	var/datum/controller_parent = null
	var/microphone_enabled = FALSE

TYPEINFO(/datum/component/phone_microphone)
	initialization_args = list(
		ARG_INFO("_controller_parent", DATA_INPUT_REF, "the datum containing the phone controller we care about, if it's different from our parent", null),
		ARG_INFO("voltronnable", DATA_INPUT_BOOL, "whether or not we should allow voltrons to enter us", TRUE),
		ARG_INFO("vapeable", DATA_INPUT_BOOL, "whether or not we should allow vape clouds to enter us", TRUE)
	)

/datum/component/phone_microphone/Initialize(_controller_parent = null, voltronnable = TRUE, vapeable = TRUE)
	. = ..()
	if(_controller_parent)
		src.controller_parent = _controller_parent
	else
		src.controller_parent = src.parent
	RegisterSignal(src.parent, COMSIG_PHONE_SPEECH_TREE_INPUT, PROC_REF(transmit_speech))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_MICROPHONE_ENABLE, PROC_REF(microphone_enable))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_MICROPHONE_DISABLE, PROC_REF(microphone_disable))
	if(voltronnable)
		RegisterSignal(src.parent, COMSIG_PHONE_ATTEMPT_VOLTRON, PROC_REF(attempt_voltron))
	if(vapeable)
		RegisterSignal(src.parent, COMSIG_PHONE_ATTEMPT_VAPE, PROC_REF(attempt_vape))
	src.setup_speech_system()

/datum/component/phone_microphone/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_PHONE_SPEECH_TREE_INPUT)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_MICROPHONE_ENABLE)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_MICROPHONE_DISABLE)
	UnregisterSignal(src.parent, COMSIG_PHONE_ATTEMPT_VOLTRON)
	UnregisterSignal(src.parent, COMSIG_PHONE_ATTEMPT_VAPE)
	. = ..()

/// Listens for our speech tree effect to send us a signal so we can transmit, assuming we're on
/datum/component/phone_microphone/proc/transmit_speech(datum/source, var/datum/say_message/message)
	if(!src.microphone_enabled) return
	SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_OUTBOUND_SPEECH, message)

/datum/component/phone_microphone/proc/microphone_enable()
	src.microphone_enabled = TRUE

/datum/component/phone_microphone/proc/microphone_disable()
	src.microphone_enabled = FALSE

/datum/component/phone_microphone/proc/attempt_voltron(datum/source, list/voltron_list)
	. = SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_OUTBOUND_VOLTRON, voltron_list)
	if(.)
		return
	else // in case we dont hear anything back, since otherwise the voltron couldnt distinguish
		return PHONE_FAILED // between it not finding a phone, and getting rejected

/datum/component/phone_microphone/proc/attempt_vape(datum/source, list/vape_list)
	. = SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_OUTBOUND_VAPE, vape_list)

/datum/component/phone_microphone/proc/setup_speech_system()
	var/atom/parent_atom = src.parent
	parent_atom.ensure_listen_tree().AddListenInput(LISTEN_INPUT_EQUIPPED)
	parent_atom.listen_tree.AddListenInput(LISTEN_INPUT_OUTLOUD_RANGE_0)
	parent_atom.listen_tree.AddListenEffect(LISTEN_EFFECT_BASE_PHONE)
	parent_atom.listen_tree.AddListenModifier(LISTEN_MODIFIER_PHONE)
	parent_atom.listen_tree.AddKnownLanguage(LANGUAGE_ALL)


// Speaker ==========================================================================

/// Turns an atom into a speaker
/// Can safely have a different parent from the controller
/// Parent MUST be an atom. You can safely make a new component for handling output if you so wish.
/datum/component/phone_speaker
	var/datum/controller_parent = null
	var/speaker_enabled = FALSE
	var/name = null
	var/color = null

TYPEINFO(/datum/component/phone_speaker)
	initialization_args = list(
		ARG_INFO("_controller_parent", DATA_INPUT_REF, "the datum containing the phone controller we care about, if it's different from our parent", null),
		ARG_INFO("voltronnable", DATA_INPUT_BOOL, "whether or not we should allow voltrons to exit through us", TRUE),
		ARG_INFO("vapeable", DATA_INPUT_BOOL, "whether or not we should allow vape clouds to exit through us", TRUE)
	)

/datum/component/phone_speaker/Initialize(_controller_parent, voltronnable = TRUE, vapeable = TRUE)
	. = ..()
	if(_controller_parent)
		src.controller_parent = _controller_parent
	else
		src.controller_parent = parent
	RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_SPEECH, PROC_REF(receive_speech))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_SOUND, PROC_REF(receive_sound))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_SPEAKER_ENABLE, PROC_REF(speaker_enable))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_SPEAKER_DISABLE, PROC_REF(speaker_disable))
	RegisterSignal(src.parent, COMSIG_PHONE_RETRIEVE_PREFIX, PROC_REF(retrieve_prefix))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_INFO_UPDATED, PROC_REF(info_updated))
	if(voltronnable)
		RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_VOLTRON, PROC_REF(receive_voltron))
	if(vapeable)
		RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_VAPE, PROC_REF(receive_vape))
	src.setup_speech_system()

/datum/component/phone_speaker/UnregisterFromParent()
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_SPEECH)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_SOUND)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_SPEAKER_ENABLE)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_SPEAKER_DISABLE)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_RETRIEVE_PREFIX)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_INFO_UPDATED)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_VOLTRON)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_VAPE)
	. = ..()

/datum/component/phone_speaker/proc/setup_speech_system()
	var/atom/parent_atom = src.parent
	parent_atom.ensure_speech_tree().AddSpeechOutput(SPEECH_OUTPUT_SPOKEN_RADIO)

/datum/component/phone_speaker/proc/receive_speech(datum/source, var/datum/say_message/message, var/echo = FALSE)
	if(!istype(message, /datum/say_message))
		CRASH("[src].receive_speech() (Parent: [parent]) received [message], expected type /datum/say_message!")
	if(!src.speaker_enabled) return
	if(!echo)
		SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_OUTBOUND_SPEECH, message, TRUE)
	var/atom/P = parent
	message = message.Copy()
	message.speaker = P
	message.message_origin = P
	P.ensure_speech_tree().process(message)

/datum/component/phone_speaker/proc/receive_sound(datum/source, sound_file, vol = 50, vary = 0)
	var/atom/parent_atom = parent
	if(!ismob(parent_atom.loc))
		return
	var/mob/holder = parent_atom.loc
	holder.playsound_local(holder, sound_file, vol, vary)

/datum/component/phone_speaker/proc/speaker_enable()
	src.speaker_enabled = TRUE

/datum/component/phone_speaker/proc/speaker_disable()
	src.speaker_enabled = FALSE

/datum/component/phone_speaker/proc/receive_voltron(datum/source, list/voltron_list)
	. = PHONE_FAILED
	var/atom/parent_atom = parent
	var/atom/target_loc = null
	voltron_list["target_atom"] = parent
	if(isturf(parent_atom.loc))
		target_loc = parent_atom.loc
	else if(ismob(parent_atom.loc))
		target_loc = parent_atom.loc.loc
	else
		return
	var/mob/user = voltron_list["user"]
	if(isrestrictedz(user.loc.z) || isrestrictedz(target_loc.z))
		return
	voltron_list["target_loc"] = target_loc
	return PHONE_ACCEPTED

/datum/component/phone_speaker/proc/receive_vape(datum/source, list/vape_list)
	var/atom/parent_atom = parent
	if(ismob(parent_atom.loc))
		vape_list["target_loc"] = parent_atom.loc.loc
		vape_list["holder"] = parent_atom.loc
	else
		vape_list["target_loc"] = parent_atom.loc
	return PHONE_ACCEPTED

/datum/component/phone_speaker/proc/info_updated(datum/source, list/info_list)
	if(info_list["id"])
		src.name = info_list["id"]
	if(info_list["color"])
		src.color = info_list["color"]

/// Effectively returns a string which we should display in output speech, by putting it into an existing list
/datum/component/phone_speaker/proc/retrieve_prefix(datum/source, list/return_list)
	return_list["prefix"] = "\[ <span style=\"color:[src.color]\">[bicon(src.parent)] [src.name]</span> \]"

// Ringer ===========================================================================

/// Our job is to listen for RING_START and RING_STOP, and to produce effects on RING_TICK
/// This ONLY does the ring sound and the maptext with caller info, not any animations
/// Set _outRing or _parentRing to null on New() if you want to remove either of them, though removing _outRing means callers won't hear anything
/// Parent must be an atom only if parentRing is not null
/datum/component/phone_ringer
	var/datum/controller_parent = null
	var/outRing = null
	var/parentRing = null
	var/ring_process = null
	var/wait2ring = FALSE
	var/inbound_caller_id_message = ""
	/// Set to FALSE if you don't want the caller id message being said by the parent, if it's an atom
	var/allow_ring_speech = TRUE

TYPEINFO(/datum/component/phone_ringer)
	initialization_args = list(
		ARG_INFO("_controller_parent", DATA_INPUT_REF, "the datum containing the phone controller we care about, if it's different from our parent", null),
		ARG_INFO("_outRing", DATA_INPUT_FILE, "the sound we should send to linked phones when ringing, which can be null", 'sound/machines/phones/ring_outgoing.ogg'),
		ARG_INFO("_parentRing", DATA_INPUT_FILE, "the sound we should make on our parent when ringing, which can be null", 'sound/machines/phones/ring_incoming.ogg')
	)


/datum/component/phone_ringer/Initialize(_controller_parent, _outRing = 'sound/machines/phones/ring_outgoing.ogg', _parentRing = 'sound/machines/phones/ring_incoming.ogg')
	. = ..()
	if(_controller_parent)
		src.controller_parent = _controller_parent
	else
		src.controller_parent = parent
	src.outRing = _outRing
	src.parentRing = _parentRing
	RegisterSignal(src.controller_parent, COMSIG_PHONE_RING_START, PROC_REF(ring_start))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_RING_STOP, PROC_REF(ring_stop))
	RegisterSignal(src.controller_parent, COMSIG_PHONE_EMAG, PROC_REF(do_emag))

/datum/component/phone_ringer/UnregisterFromParent()
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_RING_START)
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_RING_STOP)
	UnregisterSignal(src.ring_process, COMSIG_PHONE_RING_TICK)
	. = ..()

/datum/component/phone_ringer/proc/ring_start(datum/source, var/_caller_id_message = null)
	if(processScheduler)
		for(var/datum/controller/process/phone_ringing/P in processScheduler.processes)
			ring_process = P
			break
	if(!ring_process)
		CRASH()
	if(isnull(_caller_id_message))
		_caller_id_message = "<span style=\"color: #cccccc;\">???</span>"
	src.inbound_caller_id_message = _caller_id_message
	ring_tick()
	wait2ring = TRUE
	RegisterSignal(ring_process, COMSIG_PHONE_RING_TICK, PROC_REF(ring_tick))
	// so we can immediately ring without risking rings overlapping
	SPAWN(4 SECONDS)
		wait2ring = FALSE

/datum/component/phone_ringer/proc/ring_stop()
	UnregisterSignal(src.ring_process, COMSIG_PHONE_RING_TICK)
	src.inbound_caller_id_message = ""

/datum/component/phone_ringer/proc/ring_tick()
	if(wait2ring) return
	// We do this to synchronize any other on-ring-tick behaviors from our parent or other components
	SEND_SIGNAL(parent, COMSIG_PHONE_RING_TICK)
	doRingSounds()
	doRingSpeech()

/datum/component/phone_ringer/proc/doRingSounds()
	if(src.outRing)
		SEND_SIGNAL(parent, COMSIG_PHONE_OUTBOUND_SOUND, src.outRing, 50, 0)
	if(src.parentRing)
		if(!isatom(parent))
			CRASH()
		playsound(parent, parentRing, 40, 0)

/datum/component/phone_ringer/proc/doRingSpeech()
	if(isatom(parent) && src.allow_ring_speech)
		var/atom/parent_atom = parent
		parent_atom.say("Call from [src.inbound_caller_id_message].", flags = SAYFLAG_IGNORE_HTML)

/datum/component/phone_ringer/proc/do_emag()
	UnregisterSignal(src.controller_parent, COMSIG_PHONE_RING_STOP)
	// Pick a random phone.
	src.inbound_caller_id_message = "<span style=\"color: #cccccc;\">???</span>"
	var/list/phonebook = list()
	for(var/phone in phone_directory)
		if (phone_directory[phone][PHONE_DIRECTORY_UNLISTED])
			continue
		phonebook += phone
		phonebook[phone] = phone_directory[phone]

	if (length(phonebook))
		var/prank_id = pick(phonebook)
		src.inbound_caller_id_message = "<span style=\"color: [phonebook[prank_id][PHONE_DIRECTORY_COLOR]];\">[prank_id]</span>"
	SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_RING_START, inbound_caller_id_message)
