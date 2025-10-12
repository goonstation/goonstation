TYPEINFO(/obj/machinery/medical)
	mats = 10
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_SUBTLE)

	/// `obj` types this machine can connect to.
	var/list/paired_obj_whitelist = list(
		/obj/machinery/optable,
		/obj/stool/bed,
		/obj/stool/chair,
	)

ABSTRACT_TYPE(/obj/machinery/medical)
/**
 * # Medical Machines
 *
 * Any medical object that can be (in)directly connected to a patient to impart an effect onto them. Can be attached to any object within
 * `TYPEINFO(/obj/machinery/medical).paired_obj_whitelist`.
 */
/obj/machinery/medical
	name = "medical machine"
	desc = "A medical doohickey. Call 1800-CODER if you see this."
	icon = 'icons/obj/machines/medical/iv_stand.dmi'
	icon_state = "IVstand"
	anchored = UNANCHORED
	density = 0
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	speech_verb_say = "beeps"

	/// The `/mob/living/carbon` that this machine is affecting. Must stay within interact range.
	var/mob/living/carbon/patient = null
	/// Medical machines can be connected to objects such as beds or surgical tables.
	var/obj/paired_obj = null

	/// Power consumption is constant if a patient is connected to the machine. In Watts.
	var/power_consumption = 250 MILLI WATTS
	/// Is this device currently affecting a patient?
	var/active = FALSE
	/// For EMAG effects.
	var/hacked = FALSE
	var/hackable = FALSE
	/// Appended on examine.
	var/hacked_desc = "Something about it seems a little off."

	/// Fire off single feedback message after losing power. Resets on successful start.
	var/low_power_alert_given = FALSE
	/// Fire off single feedback message if failing to start. Resets on successful start.
	var/start_fail_alert_given = FALSE
	/// Fire off single feedback message on startup. Resets on stop.
	var/start_alert_given = FALSE
	/// Fire off single feedback message if stopping. Resets on successful start.
	var/stop_alert_given = FALSE

	/**
	 * Some machines don't connect directly to patients; they would then contain an item in its contents that handles the connection behaviour
	 * (e.g. IV stands).
	 *
	 * Override the following procs: `attempt_add_patient()`, `add_patient()`, `remove_patient()`
	*/
	var/connect_directly = TRUE
	var/connection_time = 3 SECONDS
	var/connection_status_effect = "medical_machine"

	// Pixel offsets for this machine when paired with an object.
	var/connect_offset_x = 0
	var/connect_offset_y = 10

/obj/machinery/medical/disposing()
	src.remove_patient()
	src.detach_from_obj()
	. = ..()

/obj/machinery/medical/get_desc(dist, mob/user)
	..()
	if (src.hacked)
		. += " [src.hacked_desc]"
	if (src.patient)
		. += " [src.patient] is currently attached to it."

/obj/machinery/medical/attack_hand(mob/user)
	if (src.paired_obj)
		boutput(user, SPAN_ALERT("Cannot adjust brakes while [src] is attached to [src.paired_obj]!"))
		return
	src.anchored = !src.anchored
	boutput(user, SPAN_NOTICE("You [src.anchored ? "apply" : "release"] \the [src.name]'s brake."))

/obj/machinery/medical/process(mult)
	..()
	if (!src.check_connection() && src.patient)
		src.remove_patient(force = TRUE)
	if (!src.powered())
		src.stop_affect(MED_MACHINE_NO_POWER)
	if (!src.can_affect())
		src.stop_affect()
	if (src.active)
		src.affect_patient(mult)
		return
	if (src.powered() && src.can_affect())
		src.start_affect()

/obj/machinery/medical/Move(atom/target)
	. = ..()
	if (!src.patient)
		return
	if (src.check_connection())
		return
	src.remove_patient(force = TRUE)

/**
 * Only checks to see if the user using the `mouse_drop` interaction is tangible, living, able to act, and is within interaction range. Specific
 * behaviours should be implemented in `/obj/machinery/medical/proc/mouse_drop_behaviour()`.
 */
/obj/machinery/medical/mouse_drop(atom/over_object)
	if (!isatom(over_object))
		return ..()
	var/mob/user = usr
	if (!isliving(user))
		return ..()
	if (isintangible(user))
		return ..()
	if (!can_act(user))
		return ..()
	if (!in_interact_range(src, user))
		return ..()
	if (!in_interact_range(over_object, user))
		return ..()
	if (!src.mouse_drop_behaviour(over_object, user))
		return ..()

/// For children of `/obj/machinery/medical`, please call `handle_emag` instead with the same params so that all EMAGs are logged and handled correctly.
/obj/machinery/medical/emag_act(mob/user, obj/item/card/emag/E)
	SHOULD_NOT_OVERRIDE(TRUE)
	src.handle_emag(user, E)

/// SpacemanDMM kept yellying at me for putting the `SHOULD_CALL_PARENT` macro on `emag_act()` so you get this instead.
/obj/machinery/medical/proc/handle_emag(mob/user, obj/item/card/emag/emag)
	SHOULD_CALL_PARENT(TRUE)
	if (src.hacked)
		return FALSE
	if (!src.hackable)
		return FALSE
	src.hacked = TRUE
	logTheThing(LOG_ADMIN, user, "emagged [src] at [log_loc(user)].")
	logTheThing(LOG_DIARY, user, "emagged [src] at [log_loc(user)].", "admin")
	message_admins("[key_name(usr)] emagged [src] at [log_loc(user)].")

/obj/machinery/medical/power_change()
	. = ..()
	if (src.active)
		return
	if (!src.powered())
		src.stop_affect(MED_MACHINE_NO_POWER)
		return
	if (!src.can_affect())
		return
	src.start_affect()

/obj/machinery/medical/set_broken()
	. = ..()
	if (src.active)
		src.stop_affect()
	src.UnsubscribeProcess()

/// Return `TRUE` if our mouse drop actually does something.
/obj/machinery/medical/proc/mouse_drop_behaviour(atom/over_object, mob/living/user)
	. = FALSE
	if (iscarbon(over_object))
		if (src.patient == over_object)
			src.remove_patient(user)
		else
			src.attempt_add_patient(user, over_object)
		return TRUE
	if (over_object == src.paired_obj)
		src.detach_from_obj(user)
		return TRUE
	if (src.attempt_attach_to_obj(over_object, user))
		return TRUE

/// Can we actually impart an effect onto a patient?
/obj/machinery/medical/proc/can_affect()
	. = TRUE
	if (!src.patient)
		return FALSE
	if (src.is_broken())
		return FALSE

/// Is a connection (to an object or patient) possible?
/obj/machinery/medical/proc/can_connect(atom/atom_to_test, mob/connector)
	. = FALSE
	if (isatom(atom_to_test))
		return
	if (ismob(connector) && !in_interact_range(src, connector))
		return
	if (in_interact_range(src, atom_to_test))
		return TRUE
	// JAAAANK
	if (!iscarbon(atom_to_test))
		return
	var/mob/living/carbon/patient_to_test = atom_to_test
	if (patient_to_test.pulling == src)
		return TRUE

/obj/machinery/medical/proc/attempt_add_patient(mob/user, mob/living/carbon/new_patient)
	if (!src.connect_directly)
		CRASH("[src] has not overridden patient connectivity behaviour on `/proc/attempt_add_patient()`!")
	if (!ismob(user))
		return
	if (!iscarbon(new_patient))
		boutput(user, SPAN_ALERT("Unable to connect [new_patient] to [src]!"))
		return
	if (src.patient)
		boutput(user, SPAN_ALERT("Unable to connect [new_patient] as [src.patient] is already using [src]!"))
		return
	if (!src.can_connect(new_patient, user))
		boutput(user, SPAN_ALERT("[src] is too far away to connect anybody!"))
		return
	src.attempt_message(user, new_patient)
	logTheThing(LOG_COMBAT, user, "is trying to connect [src] to [constructTarget(new_patient, "combat")] at [log_loc(user)].")
	var/icon/actionbar_icon = getFlatIcon(src)
	SETUP_GENERIC_ACTIONBAR(user, src, src.connection_time, PROC_REF(add_patient), list(new_patient, user), actionbar_icon, null, null, null)

/obj/machinery/medical/proc/add_patient(mob/living/carbon/new_patient, mob/user)
	if (!iscarbon(new_patient))
		return
	if (!src.connect_directly)
		CRASH("[src] has not overridden patient connectivity behaviour on `/proc/add()`!")
	src.patient = new_patient
	src.start_affect()
	if (ismob(user))
		src.add_message(user, new_patient)
		logTheThing(LOG_COMBAT, user, "connected [src] to [constructTarget(new_patient, "combat")] at [log_loc(user)].")
	if (!length(src.patient.getStatusList(src.connection_status_effect, src)))
		src.patient.setStatus(src.connection_status_effect, INFINITE_STATUS, src)
	RegisterSignal(src.patient, COMSIG_MOVABLE_MOVED, PROC_REF(on_patient_move))

/obj/machinery/medical/proc/on_patient_move()
	if (src.check_connection())
		return
	src.remove_patient(force = TRUE)

/obj/machinery/medical/proc/remove_patient(mob/user, force = FALSE)
	if (!src.connect_directly)
		CRASH("[src] has not overridden patient connectivity behaviour on `/proc/remove_patient()`!")
	if (ismob(user))
		src.remove_message(user)
		logTheThing(LOG_COMBAT, user, "disconnected [src] from [constructTarget(src.patient, "combat")] at [log_loc(user)].")
	if (force)
		src.force_remove_feedback()
	src.stop_affect()
	for (var/datum/statusEffect/machine_status_effect as anything in src.patient.getStatusList(src.connection_status_effect, src))
		src.patient.delStatus(machine_status_effect)
	UnregisterSignal(src.patient, COMSIG_MOVABLE_MOVED)
	src.patient = null

/// Feedback on (a user) attempting to connect a patient.
/obj/machinery/medical/proc/attempt_message(mob/user, mob/living/carbon/new_patient)
	user.tri_message(new_patient,\
		SPAN_NOTICE("<b>[user]</b> begins connecting [src] to [new_patient]."),\
		SPAN_NOTICE("You begin connecting [src] to [new_patient]."),\
		SPAN_NOTICE("<b>[user]</b> begins connecting [src] to you."))

/// Feedback on (a user) successfully connecting a patient.
/obj/machinery/medical/proc/add_message(mob/user, mob/living/carbon/new_patient)
	user.tri_message(new_patient,\
		SPAN_NOTICE("<b>[user]</b> connects [src] to [new_patient]."),\
		SPAN_NOTICE("You connect [src] to [new_patient]."),\
		SPAN_NOTICE("<b>[user]</b> connects [src] to you."))

/// Feedback on (a user) disconencting a patient.
/obj/machinery/medical/proc/remove_message(mob/user)
	user.tri_message(src.patient,\
		SPAN_NOTICE("<b>[user]</b> disconnects [src] from [src.patient]."),\
		SPAN_NOTICE("You disconnect [src] from [src.patient]."),\
		SPAN_NOTICE("<b>[user]</b> disconnects [src] from you."))

/// Feedback on the forceful disconnection of a patient.
/obj/machinery/medical/proc/force_remove_feedback()
	src.patient.visible_message(\
		SPAN_ALERT("<b>[src] is forcefully disconnected from [src.patient]!</b>"),\
		SPAN_ALERT("<b>[src] is forcefully disconnected from you!</b>"))

/// If failure to start, fire off once.
/obj/machinery/medical/proc/start_failure_feedback()
	SHOULD_CALL_PARENT(TRUE)
	if (src.start_fail_alert_given)
		return
	src.start_fail_alert_given = TRUE

/// Feedback on successful startup.
/obj/machinery/medical/proc/start_feedback()
	SHOULD_CALL_PARENT(TRUE)
	if (src.start_alert_given)
		return
	if (!src.active)
		return
	src.start_alert_given = TRUE

/// Feedback on stopping for any reason.
/obj/machinery/medical/proc/stop_feedback(reason = MED_MACHINE_FAILURE)
	SHOULD_CALL_PARENT(TRUE)
	if (src.low_power_alert_given || src.stop_alert_given)
		return
	if (!length(reason))
		reason = MED_MACHINE_FAILURE
	if (!src.active)
		return
	if ((reason == MED_MACHINE_NO_POWER) && !src.low_power_alert_given)
		src.low_power_alert()
		return
	if (src.is_disabled())
		return
	src.stop_alert_given = TRUE

/// If stopping due to power loss, fire off once.
/obj/machinery/medical/proc/low_power_alert()
	SHOULD_CALL_PARENT(TRUE)
	if (src.low_power_alert_given || src.stop_alert_given)
		return
	if (!src.active)
		return
	if (src.is_broken())
		return
	src.low_power_alert_given = TRUE
	src.stop_alert_given = TRUE

/// For machines that connect directly to patients: is our connection still good?
/obj/machinery/medical/proc/check_connection()
	. = TRUE
	if (!src.patient)
		return FALSE
	if (!src.can_connect(src.patient))
		return FALSE

/obj/machinery/medical/proc/set_active()
	SHOULD_CALL_PARENT(TRUE)
	// Don't need to do these again if it's the same value.
	if (src.active)
		return
	src.active = TRUE
	src.power_usage = src.power_consumption
	src.low_power_alert_given = FALSE
	src.start_fail_alert_given = FALSE
	src.stop_alert_given = FALSE

/obj/machinery/medical/proc/set_inactive()
	SHOULD_CALL_PARENT(TRUE)
	// Don't need to do these again if it's the same value.
	if (!src.active)
		return
	src.active = FALSE
	src.power_usage = 0
	src.start_alert_given = FALSE

/obj/machinery/medical/proc/start_affect()
	if (src.active)
		return
	if (!src.can_affect())
		src.start_failure_feedback()
		return
	src.set_active()
	src.start_feedback()

/obj/machinery/medical/proc/affect_patient(mult)
	if (!src.active)
		return

/obj/machinery/medical/proc/stop_affect(reason = MED_MACHINE_FAILURE)
	if (!src.active)
		return
	if (src.patient)
		src.stop_feedback(reason)
	src.set_inactive()

/obj/machinery/medical/proc/attempt_attach_to_obj(obj/target_object, mob/user)
	. = TRUE
	if (target_object == src.paired_obj)
		boutput(user, SPAN_ALERT("[src] is already attached to [src.paired_obj]!"))
		return FALSE
	if (src.anchored)
		boutput(user, SPAN_ALERT("Disengage the brakes first to attach [src] to [target_object]!"))
		return FALSE
	if (!src.can_connect(target_object, user))
		boutput(user, SPAN_ALERT("[src] is too far away to be attached to anything!"))
		return
	var/typeinfo/obj/machinery/medical/typinfo = src.get_typeinfo()
	var/obj/object_to_attach_to = null
	for (var/whitelist_type in typinfo.paired_obj_whitelist)
		if (!istype(target_object, whitelist_type))
			continue
		object_to_attach_to = target_object
		break
	if (!object_to_attach_to)
		return FALSE
	src.attach_to_obj(object_to_attach_to, user)

/obj/machinery/medical/proc/attach_to_obj(obj/target_object, mob/user)
	. = TRUE
	if (!isobj(target_object))
		return FALSE
	if (src.paired_obj)
		src.detach_from_obj(user)
	if (ismob(user))
		src.visible_message(SPAN_NOTICE("[user] attaches [src] to [target_object]."))
	src.paired_obj = target_object
	src.set_loc(src.paired_obj.loc)
	src.pixel_x = src.connect_offset_x
	src.pixel_y = src.connect_offset_y
	src.density = src.paired_obj.density
	src.set_layer()
	mutual_attach(src, src.paired_obj)
	RegisterSignal(src.paired_obj, COMSIG_ATOM_DIR_CHANGED, PROC_REF(set_layer))
	RegisterSignal(src.paired_obj, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(paired_obj_disposed))

/obj/machinery/medical/proc/paired_obj_disposed()
	src.detach_from_obj()

/obj/machinery/medical/proc/detach_from_obj(mob/user)
	mutual_detach(src, src.paired_obj)
	UnregisterSignal(src.paired_obj, COMSIG_ATOM_DIR_CHANGED)
	UnregisterSignal(src.paired_obj, COMSIG_PARENT_PRE_DISPOSING)
	if (ismob(user))
		src.visible_message(SPAN_NOTICE("[user] detaches [src] from [src.paired_obj]."))
	src.layer = initial(src.layer)
	src.pixel_x = initial(src.pixel_x)
	src.pixel_y = initial(src.pixel_y)
	src.paired_obj = null
	src.density = initial(src.density)

/// Specifically because of chairs, they change layers on dir change.
/obj/machinery/medical/proc/set_layer()
	if (!src.paired_obj)
		return
	src.layer = src.paired_obj.layer - 0.1

/// Override on children.
/obj/machinery/medical/proc/deconstruct()
	qdel(src)

/**
 * # /datum/statusEffect/medical_machine
 *
 * Added to patient on connection to a medical machine. Mostly serves as a visual indicator that you're connected.
 */
/datum/statusEffect/medical_machine
	id = "medical_machine"
	name = "Medical Machine"
	desc = "You are connected to a medical machine."
	icon_state = "+"
	unique = FALSE
	effect_quality = STATUS_QUALITY_NEUTRAL
	var/obj/machinery/medical/medical_machine = null

/datum/statusEffect/medical_machine/getTooltip()
	. = "You are physically connected to \a [src.medical_machine.name]. Moving too far from it may forcefully disconnect you."

/datum/statusEffect/medical_machine/onAdd(obj/machinery/medical/optional)
	..()
	src.medical_machine = optional

/datum/statusEffect/medical_machine/onCheck(optional)
	return src.medical_machine == optional
