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
	if(!isnull(_parentRing) && !isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(_controller_parent)
		src.controller_parent = _controller_parent
	else
		src.controller_parent = parent
	src.outRing = _outRing
	src.parentRing = _parentRing
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_RING_START, PROC_REF(ring_start))
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_RING_STOP, PROC_REF(ring_stop))
	src.RegisterSignal(src.controller_parent, COMSIG_PHONE_EMAG, PROC_REF(do_emag))

/datum/component/phone_ringer/UnregisterFromParent()
	src.UnregisterSignals(src.controller_parent, list(
		COMSIG_PHONE_RING_START,
		COMSIG_PHONE_RING_STOP
	))
	src.UnregisterSignal(src.ring_process, COMSIG_PHONE_RING_TICK)
	. = ..()

/datum/component/phone_ringer/proc/ring_start(datum/source, _caller_id_message = null)
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
	src.RegisterSignal(ring_process, COMSIG_PHONE_RING_TICK, PROC_REF(ring_tick))
	// so we can immediately ring without risking rings overlapping
	SPAWN(4 SECONDS)
		wait2ring = FALSE

/datum/component/phone_ringer/proc/ring_stop()
	src.UnregisterSignal(src.ring_process, COMSIG_PHONE_RING_TICK)
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
	src.UnregisterSignal(src.controller_parent, COMSIG_PHONE_RING_STOP)
	// Pick a random phone.
	src.inbound_caller_id_message = "<span style=\"color: #cccccc;\">???</span>"
	var/list/phonebook = list()
	for(var/phone in PHONE.directory)
		if (PHONE.directory[phone][PHONE_UNLISTED])
			continue
		phonebook += phone
		phonebook[phone] = PHONE.directory[phone]

	if (length(phonebook))
		var/prank_id = pick(phonebook)
		src.inbound_caller_id_message = "<span style=\"color: [phonebook[prank_id][PHONE_COLOR]];\">[prank_id]</span>"
	SEND_SIGNAL(src.controller_parent, COMSIG_PHONE_RING_START, inbound_caller_id_message)
