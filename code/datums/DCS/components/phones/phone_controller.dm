/* ================== COMPONENT PHONES ==================
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

 Phones operate through a mix of signals and the PHONE namespace. All communications and controls
 to and from phones is done through signals, with important procs available in PHONE, such as
 get_var and set_var. Certain logic is made available to all parts of the codebase, primarily
 defined in defines\phone.dm. There are also mapping helpers available.

*/

/// Our job is to handle connections between ourselves and other phones, and
///  take outbound signals and sending them as inbound signals on any connected phone
/// We assume everyone else will do the work of validation for signals, we just pass it along
/datum/component/phone_controller
	/// Who are we connected to and should forward signals to? (Even if one side hasn't picked up yet)
	var/datum/partner = null
	var/phone_id = null

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
		_stripe_color = "#b65f08",
		_networks = PHONE_NET_STATION
	)
		. = ..()

		src.RegisterSignal(parent, COMSIG_PHONE_INBOUND_CONNECTION, PROC_REF(inbound_connection))
		src.RegisterSignal(parent, COMSIG_PHONE_INBOUND_DISCONNECTION, PROC_REF(inbound_disconnection))
		src.RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_CONNECTION, PROC_REF(outbound_connection))
		src.RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_DISCONNECTION, PROC_REF(outbound_disconnection))
		src.RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_SPEECH, PROC_REF(outbound_speech))
		src.RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_SOUND, PROC_REF(outbound_sound))
		src.RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_VAPE, PROC_REF(outbound_vape))
		src.RegisterSignal(parent, COMSIG_PHONE_OUTBOUND_VOLTRON, PROC_REF(outbound_voltron))
		src.RegisterSignal(parent, COMSIG_PHONE_GET_Z, PROC_REF(get_phone_z))
		src.RegisterSignal(parent, COMSIG_PHONE_CHECK_CONNECTED, PROC_REF(check_connected))
		src.RegisterSignal(parent, COMSIG_PHONE_ANSWER, PROC_REF(answer))
		src.RegisterSignal(parent, COMSIG_PHONE_HANGUP, PROC_REF(hangup))
		src.RegisterSignal(parent, COMSIG_PHONE_GET_PHONEBOOK, PROC_REF(get_phonebook))
		src.RegisterSignal(parent, COMSIG_PHONE_GET_NAME, PROC_REF(get_name))

		src.phone_id = PHONE.name_handler(src.parent, _phone_id)
		PHONE.set_var(src.phone_id, PHONE_PARENT, src.parent, suppress_updates = TRUE)
		PHONE.set_var(src.phone_id, PHONE_CATEGORY, _phone_category, suppress_updates = TRUE)
		PHONE.set_var(src.phone_id, PHONE_COLOR, _stripe_color, suppress_updates = TRUE)
		PHONE.set_var(src.phone_id, PHONE_CAN_Z, _can_talk_across_z_levels, suppress_updates = TRUE)
		PHONE.set_var(src.phone_id, PHONE_UNLISTED, _unlisted, suppress_updates = TRUE)
		PHONE.set_var(src.phone_id, PHONE_NETWORKS, _networks, suppress_updates = FALSE)

/datum/component/phone_controller/UnregisterFromParent()
	SEND_SIGNAL(parent, COMSIG_PHONE_OUTBOUND_DISCONNECTION)
	src.UnregisterSignals(parent, list(
		COMSIG_PHONE_INBOUND_CONNECTION,
		COMSIG_PHONE_INBOUND_DISCONNECTION,
		COMSIG_PHONE_OUTBOUND_CONNECTION,
		COMSIG_PHONE_OUTBOUND_DISCONNECTION,
		COMSIG_PHONE_OUTBOUND_SPEECH,
		COMSIG_PHONE_OUTBOUND_SOUND,
		COMSIG_PHONE_OUTBOUND_VAPE,
		COMSIG_PHONE_OUTBOUND_VOLTRON,
		COMSIG_PHONE_GET_Z,
		COMSIG_PHONE_CHECK_CONNECTED,
		COMSIG_PHONE_ANSWER,
		COMSIG_PHONE_HANGUP,
		COMSIG_PHONE_GET_PHONEBOOK,
		COMSIG_PHONE_GET_NAME
	))
	PHONE.directory.Remove(phone_id)
	. = ..()

/// Another phone wants to connect to us
/// Disambiguation: This only means the initial connection; accepting is not the same as picking up
/datum/component/phone_controller/proc/inbound_connection(datum/source, datum/phone_caller, inbound_caller_id_message)
	. = SEND_SIGNAL(parent, COMSIG_PHONE_INBOUND_CONNECTION_CHECK)
	if(.)
		return
	if(!isnull(src.partner))
		if(src.partner == phone_caller)
			CRASH()
		return PHONE_FAILED

	src.partner = phone_caller
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
		return PHONE_FAILED
	. = SEND_SIGNAL(parent, COMSIG_PHONE_OUTBOUND_CONNECTION_CHECK)
	if(.)
		return
	var/datum/target
	// there's a delay between dialing and starting the call, and we'd risk a bad index if the target phone
	// gets deleted in that time
	try
		target = PHONE.directory[target_id][PHONE_PARENT]
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

/datum/component/phone_controller/proc/outbound_speech(datum/source, list/said_message, do_echo = FALSE)
	if(!src.partner)
		return PHONE_FAILED
	. = SEND_SIGNAL(src.partner, COMSIG_PHONE_INBOUND_SPEECH, said_message, do_echo)

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

/// Returns the parent's z-level, or 0 if it's a datum
/datum/component/phone_controller/proc/get_phone_z()
	if(!isatom(src.parent))
		return 0
	return get_z(src.parent)

/datum/component/phone_controller/proc/check_connected(datum/source)
	if(partner)
		return TRUE
	else
		return FALSE

/datum/component/phone_controller/proc/get_caller_id_message()
	var/color = PHONE.get_var(src.phone_id, PHONE_COLOR)
	return "<span style=\"color: [color];\">[src.phone_id]</span>"

/datum/component/phone_controller/proc/answer()
	SEND_SIGNAL(src.parent, COMSIG_PHONE_RING_STOP)
	SEND_SIGNAL(src.parent, COMSIG_PHONE_MICROPHONE_ENABLE)
	SEND_SIGNAL(src.parent, COMSIG_PHONE_SPEAKER_ENABLE)

/datum/component/phone_controller/proc/hangup()
	SEND_SIGNAL(src.parent, COMSIG_PHONE_OUTBOUND_DISCONNECTION)
	SEND_SIGNAL(src.parent, COMSIG_PHONE_MICROPHONE_DISABLE)
	SEND_SIGNAL(src.parent, COMSIG_PHONE_SPEAKER_DISABLE)

/// Returns all entries in PHONE.directory which we can see
/datum/component/phone_controller/proc/get_phonebook(datum/source, list/return_list)
	for(var/phone in PHONE.directory)
		var/datum/phone_parent = PHONE.directory[phone][PHONE_PARENT]
		if(PHONE.get_var(phone, PHONE_UNLISTED))
			continue
		if(!(PHONE.get_var(src.phone_id, PHONE_NETWORKS) & PHONE.get_var(phone, PHONE_NETWORKS)))
			continue
		if(phone_parent == src.parent)
			continue
		if(!PHONE.z_check(src.parent, phone_parent))
			continue
		return_list[phone] = PHONE.directory[phone]

/datum/component/phone_controller/proc/get_name(datum/source, list/return_list)
	return_list[PHONE_NAME] = src.phone_id
