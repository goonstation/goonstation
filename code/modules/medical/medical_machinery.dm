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
	/// Fire off single feedback message after losing power.
	var/low_power_alert_given = FALSE
	/// Is this device currently affecting a patient?
	var/active = FALSE
	/// For EMAG effects.
	var/hacked = FALSE

	/**
	 * Some machines don't connect directly to patients; they would then contain an item in its contents that handles the connection behaviour
	 * (e.g. IV stands).
	 *
	 * You may want to override the following procs: `attempt_add_patient()`, `add_patient()`, `attempt_remove_patient()`, `remove_patient()`
	*/
	var/connect_directly = TRUE
	var/connection_time = 3 SECONDS

	var/connect_offset_x = 0
	var/connect_offset_y = 10

	/* `tri_message` inputs for chat log feedback.
		Overrides:
			* $USR -> [user]
			* $SRC -> [src]
			* $TRG -> [new_patient] or [src.patient] dependent on target.
	*/
	/// Message to be displayed to all other viewers on attempted connection.
	var/attempt_msg_viewer = "<b>$USR</b> begins connecting $SRC to $TRG."
	/// Message to be displayed to user on attempted connection.
	var/attempt_msg_user = "You begin connecting $SRC to $TRG."
	/// Message to be displayed to patient on attempted connection.
	var/attempt_msg_patient = "<b>$USR</b> begins connecting $SRC to you."

	/// Message to be displayed to all other viewers on successful connection.
	var/add_msg_viewer = "<b>$USR</b> connects $SRC to $TRG."
	/// Message to be displayed to user on successful connection.
	var/add_msg_user = "You connect $SRC to $TRG."
	/// Message to be displayed to patient on successful connection.
	var/add_msg_patient = "<b>$USR</b> connects $SRC to you."

	/// Message to be displayed to all other viewers on disconnection.
	var/remove_msg_viewer = "<b>$USR</b> disconnects $SRC from $TRG."
	/// Message to be displayed to user on disconnection.
	var/remove_msg_user = "You disconnect $SRC from $TRG."
	/// Message to be displayed to patient on disconnection.
	var/remove_msg_patient = "<b>$USR</b> disconnects $SRC from you."

	/// Message to be displayed to all other viewers on forceful disconnection.
	var/remove_force_msg_viewer = "<b>$SRC is forcefully disconnected from $TRG!</b>"
	/// Message to be displayed to patient on forceful disconnection.
	var/remove_force_msg_patient = "<b>$SRC is forcefully disconnected from you!</b>"

/// Replaces tags in constant text variables with non-constants.
/obj/machinery/medical/proc/parse_message(text, mob/user, mob/living/carbon/target, self_referential = FALSE)
	if (!length(text))
		return ""
	if (ismob(user))
		text = replacetext(text, "$USR", "[user]")
	if (iscarbon(target))
		text = replacetext(text, "$TRG", "[user == target ? (self_referential ? "you" : himself_or_herself(user)) : target]")
	text = replacetext(text, "$SRC", "[src]")
	. = text

/obj/machinery/medical/disposing()
	src.remove_patient()
	src.detach_from_obj()
	. = ..()

/obj/machinery/medical/get_desc(dist, mob/user)
	..()
	if (src.hacked)
		. += " Something about it seems a little off."

/obj/machinery/medical/attack_hand(mob/user)
	if (src.paired_obj)
		boutput(user, SPAN_ALERT("Cannot adjust brakes while [src] is attached to [src.paired_obj]!"))
		return
	src.anchored = !src.anchored
	boutput(user, SPAN_NOTICE("You [src.anchored ? "apply" : "release"] \the [src.name]'s brake."))

/obj/machinery/medical/Move(atom/target)
	. = ..()
	if (src.patient)
		src.check_remove_conditions()
	if (!src.paired_obj)
		src.detach_from_obj()
		return
	if (!(src.paired_obj in src.loc))
		src.detach_from_obj()

/obj/machinery/medical/mouse_drop(atom/over_object)
	if (!isatom(over_object))
		. = ..()
		return
	var/mob/living/user = usr
	if (!isliving(user) || !can_act(user) || !in_interact_range(src, user) || !in_interact_range(over_object, user))
		. = ..()
		return
	if (iscarbon(over_object))
		if (src.patient == over_object)
			src.attempt_remove_patient(user)
		else
			src.attempt_add_patient(user, over_object)
		return
	if (!isobj(over_object))
		. = ..()
		return
	if (over_object == src.paired_obj)
		src.detach_from_obj(user)
		return
	if (src.paired_obj)
		boutput(user, SPAN_ALERT("[src] is already attached to [src.paired_obj]!"))
		return
	var/typeinfo/obj/machinery/medical/typinfo = src.get_typeinfo()
	var/obj/object_to_attach_to = null
	for (var/whitelist_type in typinfo.paired_obj_whitelist)
		if (!istype(over_object, whitelist_type))
			continue
		object_to_attach_to = over_object
		break
	if (!object_to_attach_to)
		. = ..()
		return
	src.attach_to_obj(object_to_attach_to, user)

/obj/machinery/medical/process(mult)
	..()
	if (!src.patient)
		return
	if (!src.connect_directly)
		src.affect_patient(mult)
		return
	src.check_remove_conditions()
	if (src.is_disabled())
		return
	if (!src.active)
		return
	src.affect_patient(mult)

/obj/machinery/medical/emag_act(mob/user, obj/item/card/emag/E)
	if (src.hacked)
		return FALSE
	src.hacked = TRUE
	logTheThing(LOG_ADMIN, user, "emagged [src] at [log_loc(user)].")
	logTheThing(LOG_DIARY, user, "emagged [src] at [log_loc(user)].", "admin")
	message_admins("[key_name(usr)] emagged [src] at [log_loc(user)].")

/obj/machinery/medical/power_change()
	. = ..()
	if (!src.powered())
		src.stop_affect(MED_MACHINE_NO_POWER)
		return
	if (!src.active && src.patient)
		src.affect_patient()

/obj/machinery/medical/set_broken()
	src.stop_affect()
	. = ..()

/// See `_std/defines/medical.dm`
/obj/machinery/medical/proc/check_remove_conditions()
	if (!src.connect_directly)
		return
	if (!src.patient)
		src.remove_patient()
		return
	// Yank the connection by force if patient exits interaction range.
	if (!in_interact_range(src, src.patient))
		src.remove_patient(force = TRUE)
		return

/obj/machinery/medical/proc/start_affect()
	if (src.is_disabled())
		return
	src.active = TRUE
	src.start_feedback()

/obj/machinery/medical/proc/affect_patient(mult)
	if (!src.patient)
		return
	if (!src.active)
		return

/obj/machinery/medical/proc/stop_affect(reason = MED_MACHINE_FAILURE)
	src.active = FALSE

/// Override on children. Usecase includes any feedback the machine should provide about the affect it currently has on the patient.
/obj/machinery/medical/proc/start_feedback()
	return

/obj/machinery/medical/proc/attempt_add_patient(mob/user, mob/living/carbon/new_patient)
	. = TRUE
	if (!ismob(user))
		return FALSE
	if (!iscarbon(new_patient))
		boutput(user, SPAN_ALERT("Unable to connect [new_patient] to [src]!"))
		return FALSE
	if (src.patient)
		boutput(user, SPAN_ALERT("Unable to connect [new_patient] as [src.patient] is already using [src]!"))
		return FALSE
	src.attempt_message(user, new_patient)
	logTheThing(LOG_COMBAT, user, "is trying to connect [src] to [constructTarget(new_patient, "combat")] at [log_loc(user)].")
	var/icon/actionbar_icon = getFlatIcon(src)
	SETUP_GENERIC_ACTIONBAR(user, src, src.connection_time, PROC_REF(add_patient), list(new_patient, user), actionbar_icon, null, null, null)

/obj/machinery/medical/proc/add_patient(mob/living/carbon/new_patient, mob/user)
	if (!iscarbon(new_patient))
		return
	src.patient = new_patient
	src.power_usage = src.power_consumption
	src.start_feedback()
	if (ismob(user))
		src.add_message(user, new_patient)
		logTheThing(LOG_COMBAT, user, "connected [src] to [constructTarget(new_patient, "combat")] at [log_loc(user)].")
	if (!src.connect_directly)
		RegisterSignal(src.patient, COMSIG_MOVABLE_MOVED, PROC_REF(on_patient_moved))

/obj/machinery/medical/proc/on_patient_moved()
	if (in_interact_range(src, src.patient))
		return
	// JAAAANK
	if (src.patient.pulling == src)
		return
	src.remove_patient(force = TRUE)

/obj/machinery/medical/proc/attempt_remove_patient(mob/user)
	src.remove_patient(user)

/obj/machinery/medical/proc/remove_patient(mob/user, force = FALSE)
	if (!src.patient || !iscarbon(src.patient))
		return
	UnregisterSignal(src.patient, COMSIG_MOVABLE_MOVED)
	if (ismob(user))
		src.remove_message(user)
		logTheThing(LOG_COMBAT, user, "disconnected [src] from [constructTarget(src.patient, "combat")] at [log_loc(user)].")
	if (force && !user)
		src.force_remove_feedback()
	src.stop_affect()
	src.patient = null
	src.power_usage = 0

/obj/machinery/medical/proc/attempt_message(mob/user, mob/living/carbon/new_patient)
	user.tri_message(new_patient,\
		SPAN_NOTICE(src.parse_message(src.attempt_msg_viewer, user, new_patient)),\
		SPAN_NOTICE(src.parse_message(src.attempt_msg_user, user, new_patient, self_referential = TRUE)),\
		SPAN_NOTICE(src.parse_message(src.attempt_msg_patient, user, new_patient)))

/obj/machinery/medical/proc/add_message(mob/user, mob/living/carbon/new_patient)
	user.tri_message(new_patient,\
		SPAN_NOTICE(src.parse_message(src.add_msg_viewer, user, new_patient)),\
		SPAN_NOTICE(src.parse_message(src.add_msg_user, user, new_patient, self_referential = TRUE)),\
		SPAN_NOTICE(src.parse_message(src.add_msg_patient, user, new_patient)))

/obj/machinery/medical/proc/remove_message(mob/user)
	user.tri_message(src.patient,\
		SPAN_NOTICE(src.parse_message(src.remove_msg_viewer, user, src.patient)),\
		SPAN_NOTICE(src.parse_message(src.remove_msg_user, user, src.patient, self_referential = TRUE)),\
		SPAN_NOTICE(src.parse_message(src.remove_msg_patient, user, src.patient)))

/obj/machinery/medical/proc/force_remove_feedback()
	src.patient.visible_message(\
		SPAN_ALERT(src.parse_message(src.remove_force_msg_viewer, target = src.patient)),\
		SPAN_ALERT(src.parse_message(src.remove_force_msg_patient, target = src.patient, self_referential = TRUE)))

/obj/machinery/medical/proc/attach_to_obj(obj/target_object, mob/user)
	. = TRUE
	if (!isobj(target_object) || src.paired_obj)
		return FALSE
	if (src.anchored)
		boutput(user, SPAN_ALERT("Disengage the brakes first to attach [src] to [target_object]!"))
		return FALSE
	if (ismob(user))
		src.visible_message(SPAN_NOTICE("[user] attaches [src] to [target_object]."))
	src.paired_obj = target_object
	mutual_attach(src, src.paired_obj)
	src.set_loc(src.paired_obj.loc)
	src.pixel_x = src.connect_offset_x
	src.pixel_y = src.connect_offset_y
	src.density = src.paired_obj.density
	src.set_layer()
	RegisterSignal(src.paired_obj, COMSIG_ATOM_DIR_CHANGED, PROC_REF(set_layer))

/obj/machinery/medical/proc/detach_from_obj(mob/user)
	. = TRUE
	src.layer = initial(src.layer)
	src.pixel_x = initial(src.pixel_x)
	src.pixel_y = initial(src.pixel_y)
	src.paired_obj = null
	src.density = initial(src.density)
	if (!src.paired_obj)
		return FALSE
	if (ismob(user))
		src.visible_message(SPAN_NOTICE("[user] detaches [src] from [src.paired_obj]."))
	mutual_detach(src, src.paired_obj)
	UnregisterSignal(src.paired_obj, COMSIG_ATOM_DIR_CHANGED)

/// Specifically because of chairs.
/obj/machinery/medical/proc/set_layer()
	if (!src.paired_obj)
		return
	src.layer = src.paired_obj.layer - 0.1

/// Override on children.
/obj/machinery/medical/proc/deconstruct()
	qdel(src)
