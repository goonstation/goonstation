/// Turns an atom into a speaker
/// Can safely have a different parent from the controller
/// Parent MUST be an atom. You can safely make a new component for handling output if you so wish.
/datum/component/phone_speaker
	var/datum/controller_parent = null
	var/speaker_enabled = FALSE

TYPEINFO(/datum/component/phone_speaker)
	initialization_args = list(
		ARG_INFO("_controller_parent", DATA_INPUT_REF, "the datum containing the phone controller we care about, if it's different from our parent", null),
		ARG_INFO("voltronnable", DATA_INPUT_BOOL, "whether or not we should allow voltrons to exit through us", TRUE),
		ARG_INFO("vapeable", DATA_INPUT_BOOL, "whether or not we should allow vape clouds to exit through us", TRUE)
	)

/datum/component/phone_speaker/Initialize(_controller_parent, voltronnable = TRUE, vapeable = TRUE)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(_controller_parent)
		src.controller_parent = _controller_parent
	else
		src.controller_parent = parent
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_SPEECH, PROC_REF(receive_speech))
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_SOUND, PROC_REF(receive_sound))
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_SPEAKER_ENABLE, PROC_REF(speaker_enable))
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_SPEAKER_DISABLE, PROC_REF(speaker_disable))
	src.RegisterSignal(src.parent, COMSIG_PHONE_RETRIEVE_PREFIX, PROC_REF(retrieve_prefix))
	if(voltronnable)
		src.RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_VOLTRON, PROC_REF(receive_voltron))
	if(vapeable)
		src.RegisterSignal(src.controller_parent, COMSIG_PHONE_INBOUND_VAPE, PROC_REF(receive_vape))
	src.setup_speech_system()

/datum/component/phone_speaker/UnregisterFromParent()
	src.UnregisterSignals(src.controller_parent, list(
		COMSIG_PHONE_INBOUND_SPEECH,
		COMSIG_PHONE_INBOUND_SOUND,
		COMSIG_PHONE_SPEAKER_ENABLE,
		COMSIG_PHONE_SPEAKER_DISABLE,
		COMSIG_PHONE_RETRIEVE_PREFIX,
		COMSIG_PHONE_INBOUND_VOLTRON,
		COMSIG_PHONE_INBOUND_VAPE
	))
	. = ..()

/datum/component/phone_speaker/proc/setup_speech_system()
	var/atom/parent_atom = src.parent
	parent_atom.ensure_speech_tree().AddSpeechOutput(SPEECH_OUTPUT_SPOKEN_RADIO)

/datum/component/phone_speaker/proc/receive_speech(datum/source, datum/say_message/message, do_echo = FALSE)
	if(!istype(message, /datum/say_message))
		CRASH("[src].receive_speech() (Parent: [parent]) received [message], expected type /datum/say_message!")
	if(!src.speaker_enabled) return
	if(do_echo)
		SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_OUTBOUND_SPEECH, message, FALSE)
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

/// Effectively returns a string which we should display in output speech, by putting it into an existing list
/datum/component/phone_speaker/proc/retrieve_prefix(datum/source, list/return_list)
	var/color = PHONE.get_var(src.controller_parent, PHONE_COLOR)
	var/name = PHONE.get_var(src.controller_parent, PHONE_NAME)
	return_list["prefix"] = "\[ <span style=\"color:[color]\">[bicon(src.parent)] [name]</span> \]"
