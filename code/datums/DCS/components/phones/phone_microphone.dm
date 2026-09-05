/// Turns an atom into a microphone, setting up speech trees accordingly. This will NOT remove them upon component removal.
/// You may safely not use this if you don't need a microphone, or have another means of sending outbound phone signals
/// This component currently assumes your microphone is intended to have someone holding it in their active hand when speaking
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
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(_controller_parent)
		src.controller_parent = _controller_parent
	else
		src.controller_parent = src.parent
	src.RegisterSignal(src.parent, COMSIG_PHONE_SPEECH_TREE_INPUT, PROC_REF(transmit_speech))
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_MICROPHONE_ENABLE, PROC_REF(microphone_enable))
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_MICROPHONE_DISABLE, PROC_REF(microphone_disable))
	if(voltronnable)
		src.RegisterSignal(src.parent, COMSIG_PHONE_ATTEMPT_VOLTRON, PROC_REF(attempt_voltron))
	if(vapeable)
		src.RegisterSignal(src.parent, COMSIG_PHONE_ATTEMPT_VAPE, PROC_REF(attempt_vape))
	src.setup_speech_system()

/datum/component/phone_microphone/UnregisterFromParent()
	src.UnregisterSignals(src.parent, list(
		COMSIG_PHONE_SPEECH_TREE_INPUT,
		COMSIG_PHONE_ATTEMPT_VOLTRON,
		COMSIG_PHONE_ATTEMPT_VAPE,
	))
	src.UnregisterSignals(src.controller_parent, list(
		COMSIG_PHONE_MICROPHONE_ENABLE,
		COMSIG_PHONE_MICROPHONE_DISABLE
	))
	. = ..()

/// Listens for our speech tree effect to send us a signal so we can transmit, assuming we're on
/datum/component/phone_microphone/proc/transmit_speech(datum/source, datum/say_message/message)
	if(!src.microphone_enabled) return
	SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_OUTBOUND_SPEECH, message, TRUE)

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

// This works for reasons beyond my comprehension. Someone more well-versed in speech code than I is
// more than welcome to make changes to this.
/datum/component/phone_microphone/proc/setup_speech_system()
	var/atom/parent_atom = src.parent
	parent_atom.ensure_listen_tree().AddListenInput(LISTEN_INPUT_EQUIPPED)
	parent_atom.listen_tree.AddListenInput(LISTEN_INPUT_OUTLOUD_RANGE_0)
	parent_atom.listen_tree.AddListenEffect(LISTEN_EFFECT_PHONE)
	parent_atom.listen_tree.AddListenModifier(LISTEN_MODIFIER_PHONE_INHAND)
	parent_atom.listen_tree.AddKnownLanguage(LANGUAGE_ALL)
