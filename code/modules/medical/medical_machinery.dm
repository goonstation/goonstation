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

	var/actionbar_icon = 'icons/obj/surgery.dmi'
	/// Icon state that represents every actionbar interaction for this machine. See `src.actionbar_icon`.
	var/actionbar_icon_state = "IV"

	/// Power consumption is constant if a patient is connected to the machine. In Watts.
	var/power_consumption = 250 MILLI WATTS
	/// For EMAG effects.
	var/hacked = FALSE

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
	var/attempt_msg_first = "You begin connecting $SRC to $TRG."
	/// Message to be displayed to patient on attempted connection.
	var/attempt_msg_second = "<b>$USR</b> begins connecting $SRC to you."

	/// Message to be displayed to all other viewers on successful connection.
	var/add_msg_viewer = "<b>$USR</b> connects $SRC to $TRG."
	/// Message to be displayed to user on successful connection.
	var/add_msg_first = "You connect $SRC to $TRG."
	/// Message to be displayed to patient on successful connection.
	var/add_msg_second = "<b>$USR</b> connects $SRC to you."

	/// Message to be displayed to all other viewers on disconnection.
	var/remove_msg_viewer = "<b>$USR</b> disconnects $SRC from $TRG."
	/// Message to be displayed to user on disconnection.
	var/remove_msg_first = "You disconnect $SRC from $TRG."
	/// Message to be displayed to patient on disconnection.
	var/remove_msg_second = "<b>$USR</b> disconnects $SRC from you."

	/// Message to be displayed to all other viewers on forceful disconnection.
	var/remove_forceful_msg_viewer = "<b>$USR</b> disconnects $SRC from $TRG."
	/// Message to be displayed to patient on forceful disconnection.
	var/remove_forceful_msg_patient = "<b>$USR</b> disconnects $SRC from you."

/obj/machinery/medical/New()
	. = ..()
	src.UnsubscribeProcess()

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
	if (!src.paired_obj)
		return
	if (!(src.paired_obj in src.loc))
		src.detach_from_obj()

/obj/machinery/medical/mouse_drop(atom/over_object)
	if (!isatom(over_object))
		..()
		return
	var/mob/living/user = usr
	if (!isliving(user) || !can_act(user) || !in_interact_range(src, user) || !in_interact_range(over_object, user))
		..()
		return
	if (iscarbon(over_object))
		if (src.patient == over_object)
			src.attempt_remove_patient(user)
		else
			src.attempt_add_patient(over_object, user)
		return
	if (!isobj(over_object))
		..()
		return
	var/typeinfo/obj/machinery/medical/typinfo = src.get_typeinfo()
	if (!(over_object.type in typinfo.paired_obj_whitelist))
		..()
		return
	if (over_object == src.paired_obj)
		src.detach_from_obj(user)
		return
	if (src.paired_obj)
		boutput(user, SPAN_ALERT("[src] is already attached to [src.paired_obj]!"))
		return
	src.attach_to_obj(over_object, user)

/obj/machinery/medical/process(mult)
	..()
	if (!src.patient)
		return
	if (!in_interact_range(src, src.patient))
		src.remove_patient(forceful = TRUE)
		return
	if (!src.check_remove_conditions())
		src.remove_patient()
		return
	if (src.is_broken() || src.has_no_power())
		return
	src.affect_patient(mult)

/obj/machinery/medical/emag_act(mob/user, obj/item/card/emag/E)
	if (src.hacked)
		return FALSE
	src.hacked = TRUE
	logTheThing(LOG_ADMIN, user, "emagged [src] at [log_loc(user)].")
	logTheThing(LOG_DIARY, user, "emagged [src] at [log_loc(user)].", "admin")
	message_admins("[key_name(usr)] emagged [src] at [log_loc(user)].")

/// Override this proc on child types. Return boolean.
/obj/machinery/medical/proc/check_remove_conditions()
	. = TRUE

/// Override this proc on child types.
/obj/machinery/medical/proc/affect_patient(mult)
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
	SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(add_patient), list(new_patient, user), src.actionbar_icon, src.actionbar_icon_state, null, null)

/obj/machinery/medical/proc/add_patient(mob/living/carbon/new_patient, mob/user)
	if (!iscarbon(new_patient))
		return
	if (ismob(user))
		src.add_message(user, new_patient)
		logTheThing(LOG_COMBAT, user, "connected [src] to [constructTarget(new_patient, "combat")] at [log_loc(user)].")
	src.patient = new_patient
	src.power_usage = src.power_consumption
	src.SubscribeToProcess()

/obj/machinery/medical/proc/attempt_remove_patient(mob/user)
	src.remove_patient(user)

/obj/machinery/medical/proc/remove_patient(mob/user, forceful = FALSE)
	if (ismob(user))
		src.remove_message(user)
		logTheThing(LOG_COMBAT, user, "disconnected [src] from [constructTarget(src.patient, "combat")] at [log_loc(user)].")
	if (forceful && !user)
		src.force_remove_message()
	src.patient = null
	src.power_usage = 0
	src.UnsubscribeProcess()

/// Replaces tags in constant text variables with non-constants.
/obj/machinery/medical/proc/parse_message(text, mob/user, mob/living/carbon/target)
	if (!length(text))
		return ""
	if (ismob(user))
		text = replacetext(text, "$USR", "[user]")
	if (iscarbon(target))
		text = replacetext(text, "$TRG", "[target]")
	text = replacetext(text, "$SRC", "[src]")
	. = text

/obj/machinery/medical/proc/attempt_message(mob/user, mob/living/carbon/new_patient)
	user.tri_message(new_patient,\
		SPAN_NOTICE(src.parse_message(src.attempt_msg_viewer, user, new_patient)),\
		SPAN_NOTICE(src.parse_message(src.attempt_msg_first, user, new_patient)),\
		SPAN_NOTICE(src.parse_message(src.attempt_msg_second, user, new_patient)))

/obj/machinery/medical/proc/add_message(mob/user, mob/living/carbon/new_patient)
	user.tri_message(new_patient,\
		SPAN_NOTICE(src.parse_message(src.add_msg_viewer, user, new_patient)),\
		SPAN_NOTICE(src.parse_message(src.add_msg_first, user, new_patient)),\
		SPAN_NOTICE(src.parse_message(src.add_msg_second, user, new_patient)))

/obj/machinery/medical/proc/remove_message(mob/user)
	user.tri_message(src.patient,\
		SPAN_NOTICE(src.parse_message(src.remove_msg_viewer, user, src.patient)),\
		SPAN_NOTICE(src.parse_message(src.remove_msg_first, user, src.patient)),\
		SPAN_NOTICE(src.parse_message(src.remove_msg_second, user, src.patient)))

/obj/machinery/medical/proc/force_remove_message()
	src.patient.visible_message(\
		SPAN_ALERT(src.parse_message(src.remove_forceful_msg_viewer, target = src.patient)),\
		SPAN_ALERT(src.parse_message(src.remove_forceful_msg_patient, target = src.patient)))

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
	src.layer = (src.paired_obj.layer - 0.1)
	src.pixel_x = src.connect_offset_x
	src.pixel_y = src.connect_offset_y
	src.density = FALSE

/obj/machinery/medical/proc/detach_from_obj(mob/user)
	. = TRUE
	if (!src.paired_obj)
		return FALSE
	if (ismob(user))
		src.visible_message(SPAN_NOTICE("[user] detaches [src] from [src.paired_obj]."))
	mutual_detach(src, src.paired_obj)
	src.layer = initial(src.layer)
	src.pixel_x = initial(src.pixel_x)
	src.pixel_y = initial(src.pixel_y)
	src.paired_obj = null
	src.density = initial(src.density)
