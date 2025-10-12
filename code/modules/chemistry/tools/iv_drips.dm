#define IV_FAIL_PT_FULL "patient_full"
#define IV_FAIL_BAG_EMPTY "bag_empty"
#define IV_FAIL_BAG_FULL "bag_full"
#define IV_FAIL_PT_EMPTY "patient_empty"

/**
 * # IV Drip
 *
 * Vampires can't [draw their own blood] to inflate their blood count, because they can't get more than ~30% of it back.
 * Also ignore that second container of blood entirely if it's a vampire (Convair880).
 */
/obj/item/reagent_containers/glass/iv_drip
	name = "\improper IV drip"
	desc = "A bag with a fine needle attached at the end, for injecting patients with fluids."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "IV"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "IV"
	w_class = W_CLASS_TINY
	flags = TABLEPASS | ACCEPTS_MOUSEDROP_REAGENTS | SUPPRESSATTACK
	rc_flags = RC_VISIBLE | RC_FULLNESS | RC_SPECTRO
	amount_per_transfer_from_this = 5
	initial_volume = 250
	incompatible_with_chem_dispensers = TRUE
	can_recycle = FALSE
	shatter_immune = TRUE
	container_icon = 'icons/obj/surgery.dmi'
	container_style = "IV"
	fluid_overlay_states = 9
	fluid_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_LINEAR

	var/mob/living/carbon/patient = null
	var/obj/machinery/medical/blood/iv_stand/iv_stand = null

	var/mode = IV_DRAW
	/// Is this actively drawing/injecting?
	var/active = FALSE

/obj/item/reagent_containers/glass/iv_drip/New()
	..()
	src.UpdateOverlays(image(src.icon, "IVlabel[src.reagents.get_master_reagent_name() == "blood" ? "-blood" : ""]"), "label")
	src.update_name()
	src.UpdateIcon()

/obj/item/reagent_containers/glass/iv_drip/disposing()
	processing_items -= src
	if (src.patient)
		src.remove_patient()
	. = ..()

/obj/item/reagent_containers/glass/iv_drip/moved(mob/user, old_loc)
	. = ..()
	src.on_movement()

/obj/item/reagent_containers/glass/iv_drip/set_loc(newloc, storage_check)
	. = ..()
	src.on_movement()

/obj/item/reagent_containers/glass/iv_drip/on_reagent_change()
	..()
	src.update_name()
	src.UpdateIcon()
	if (src.iv_stand)
		src.iv_stand.UpdateIcon()

/obj/item/reagent_containers/glass/iv_drip/update_icon()
	if (ismob(src.loc))
		src.UpdateOverlays(image(src.icon, (src.mode ? "inject" : "draw")), "inj_dr")
		return
	src.UpdateOverlays(null, "inj_dr")

/obj/item/reagent_containers/glass/iv_drip/pickup(mob/user)
	if (src.patient)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement), TRUE)
	..()
	SPAWN(0)
		src.UpdateIcon()

/obj/item/reagent_containers/glass/iv_drip/dropped(mob/user)
	if (src.patient != user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	..()
	SPAWN(0)
		src.UpdateIcon()

/obj/item/reagent_containers/glass/iv_drip/attack_self(mob/user)
	src.mode = !src.mode
	user.show_text("You switch [src] to [src.mode ? "inject" : "draw"].")
	src.UpdateIcon()

/obj/item/reagent_containers/glass/iv_drip/afterattack(obj/target, mob/user, flag)
	if (!iscarbon(target))
		return ..()
	if (src.patient == target)
		src.remove_patient(user)
		return
	src.attempt_add_patient(target, user)

/obj/item/reagent_containers/glass/iv_drip/attackby(obj/A, mob/user)
	if (!iscuttingtool(A))
		return ..()
	if (src.is_open_container())
		boutput(user, "[src] has already been sliced open.")
		return ..()
	src.set_open_container(TRUE)
	src.desc = "[src.desc] It has been sliced open."
	boutput(user, "You carefully slice [src] open.")

/obj/item/reagent_containers/glass/iv_drip/mouse_drop(atom/over_object)
	if (!isatom(over_object))
		. = ..()
		return
	var/mob/living/user = usr
	if (!isliving(user) || isintangible(user) || !can_act(user) || !in_interact_range(src, user) || !in_interact_range(over_object, user))
		. = ..()
		return
	if (!istype(over_object, /obj/machinery/medical/blood/iv_stand))
		. = ..()
		return
	var/obj/machinery/medical/blood/iv_stand/iv_stand = over_object
	iv_stand.add_iv_drip(src, user)

/// `mult` only matters if `src` is connected to an IV stand.
/obj/item/reagent_containers/glass/iv_drip/process(mult = 10)
	if (!src.patient)
		return
	if (!src.check_interact_range())
		src.remove_patient(force = TRUE)
		return
	var/failure_feedback = src.check_iv_fail()
	if (failure_feedback && src.active)
		src.transfuse_fail_feedback(failure_feedback)
		src.stop_transfusion()
		return
	if (src.active)
		if (src.mode == IV_INJECT)
			src.handle_inject(mult)
		else
			src.handle_draw(mult)
		return
	if (!failure_feedback)
		src.start_transfusion()

/obj/item/reagent_containers/glass/iv_drip/proc/handle_draw(mult)
	var/transfer_volume = src.calculate_transfer_volume()
	transfer_blood(src.patient, src, transfer_volume)

/obj/item/reagent_containers/glass/iv_drip/proc/handle_inject(mult)
	var/transfer_volume = src.calculate_transfer_volume()
	src.reagents.trans_to(src.patient, transfer_volume)
	src.patient.reagents.reaction(src.patient, INGEST, transfer_volume)

/obj/item/reagent_containers/glass/iv_drip/proc/calculate_transfer_volume(mult)
	. = src.amount_per_transfer_from_this
	if (src.iv_stand?.active)
		. = src.iv_stand.transfer_volume
	. *= max(mult / 10, 1)

/obj/item/reagent_containers/glass/iv_drip/proc/update_name()
	if (src.reagents?.total_volume)
		src.name = src.reagents.get_master_reagent_name() == "blood" ? "blood pack" : "[src.reagents.get_master_reagent_name()] drip"
	else
		src.name = "\improper IV drip"

/obj/item/reagent_containers/glass/iv_drip/proc/check_iv_fail(mob/living/carbon/patient_to_check)
	. = null
	if (!patient_to_check && src.patient)
		patient_to_check = src.patient
	if (src.mode == IV_INJECT)
		if (!src.reagents.total_volume)
			return IV_FAIL_BAG_EMPTY
		if (patient_to_check.reagents.is_full())
			return IV_FAIL_PT_FULL
		return
	if (src.check_vampire(patient_to_check) || (!patient_to_check.reagents.total_volume && !patient_to_check.blood_volume))
		return IV_FAIL_PT_EMPTY
	if (src.reagents.is_full())
		return IV_FAIL_BAG_FULL

/obj/item/reagent_containers/glass/iv_drip/proc/attempt_add_patient(mob/living/carbon/new_patient, mob/user)
	. = TRUE
	if (src.patient && (src.patient != new_patient))
		user.show_text("[src] is already being used by someone else!", "red")
		return FALSE
	var/failure_feedback = src.check_iv_fail(new_patient)
	if (failure_feedback)
		user.show_text(src.connect_fail_feedback(failure_feedback, new_patient), "red")
		return FALSE
	new_patient.tri_message(user,\
		SPAN_NOTICE("<b>[user]</b> begins inserting [src]'s needle into [new_patient == user ? "[himself_or_herself(new_patient)]" : "[new_patient]"]."),\
		SPAN_NOTICE("[new_patient == user ? "You begin" : "<b>[user]</b> begins"] inserting [src]'s needle into you[new_patient == user ? "rself" : ""]."),\
		SPAN_NOTICE("You begin inserting [src]'s needle into [new_patient]."))
	logTheThing(LOG_COMBAT, user, "tries to hook up an IV drip [log_reagents(src)] to [constructTarget(new_patient,"combat")] at [log_loc(user)].")
	var/icon/actionbar_icon = getFlatIcon(src.iv_stand ? src.iv_stand : src, no_anim = TRUE)
	SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(add_patient), list(new_patient, user), actionbar_icon, null, null, null)

/obj/item/reagent_containers/glass/iv_drip/proc/connect_fail_feedback(failure_feedback, mob/living/carbon/new_patient)
	. = null
	if (!length(failure_feedback))
		return
	switch (failure_feedback)
		if (IV_FAIL_BAG_FULL)
			return "[src] is full!"
		if (IV_FAIL_PT_EMPTY)
			return "[new_patient] doesn't have anything left to give!"
		if (IV_FAIL_PT_FULL)
			return "[new_patient]'s blood pressure seems dangerously high as it is, there's probably no room for anything else!"
		if (IV_FAIL_BAG_EMPTY)
			return "There's nothing left in [src]!"

/obj/item/reagent_containers/glass/iv_drip/proc/add_patient(mob/living/carbon/human/new_patient, mob/user)
	if (src.patient)
		return
	src.patient = new_patient
	if (src.iv_stand)
		src.iv_stand.add_patient(src.patient, user)
	RegisterSignal(src.patient, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement), TRUE)
	src.start_transfusion()
	if (!length(src.patient.getStatusList("iv_drip", src)))
		src.patient.setStatus("iv_drip", INFINITE_STATUS, src)
	if (!ismob(user))
		return
	if ((src.loc == user) && (src.patient != user))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement), TRUE)
	new_patient.tri_message(user,\
		SPAN_NOTICE("<b>[user]</b> inserts [src]'s needle into [new_patient == user ? "[himself_or_herself(new_patient)]" : "[new_patient]"]."),\
		SPAN_NOTICE("[new_patient == user ? "You insert" : "<b>[user]</b> inserts"] [src]'s needle into you[new_patient == user ? "rself" : ""]."),\
		SPAN_NOTICE("You insert [src]'s needle into [new_patient]."))
	logTheThing(LOG_COMBAT, user, "connects an IV drip [log_reagents(src)] to [constructTarget(new_patient,"combat")] at [log_loc(user)].")

/obj/item/reagent_containers/glass/iv_drip/proc/remove_patient(mob/user, force = FALSE)
	if (!src.patient)
		return
	UnregisterSignal(src.patient, COMSIG_MOVABLE_MOVED)
	if (force)
		var/fluff = pick("pulled", "yanked", "ripped")
		src.patient.visible_message(SPAN_ALERT("<b>[src]'s needle gets [fluff] out of [src.patient]!</b>"),\
		SPAN_ALERT("<b>[src]'s needle gets [fluff] out of you!</b>"))
	if (ismob(user))
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		src.patient.tri_message(user,\
			SPAN_NOTICE("<b>[user]</b> removes [src]'s needle from [src.patient == user ? "[himself_or_herself(src.patient)]" : "[src.patient]"]."),\
			SPAN_NOTICE("[src.patient == user ? "You remove" : "<b>[user]</b> removes"] [src]'s needle from you[src.patient == user ? "rself" : ""]."),\
			SPAN_NOTICE("You remove [src]'s needle from [src.patient]."))
	src.stop_transfusion()
	for (var/datum/statusEffect/status_effect as anything in src.patient.getStatusList("iv_drip", src))
		src.patient.delStatus(status_effect)
	src.patient = null
	if (src.iv_stand?.patient)
		src.iv_stand.remove_patient(user)
	src.UpdateIcon()

/obj/item/reagent_containers/glass/iv_drip/proc/start_transfusion()
	if (src.check_iv_fail())
		return
	src.active = TRUE
	src.handle_processing()
	APPLY_ATOM_PROPERTY(src.patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src, 2)
	src.iv_stand?.start_affect()

/obj/item/reagent_containers/glass/iv_drip/proc/stop_transfusion()
	src.active = FALSE
	src.handle_processing()
	REMOVE_ATOM_PROPERTY(src.patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src)
	src.iv_stand?.stop_affect()

/// When attached to an IV stand, we'll leech off of the machine process loop instead of `global.processing_items`.
/obj/item/reagent_containers/glass/iv_drip/proc/handle_processing()
	if (!src.patient || src.iv_stand?.active)
		global.processing_items -= src
		return
	global.processing_items |= src

/obj/item/reagent_containers/glass/iv_drip/proc/on_movement()
	if (!src.check_interact_range())
		src.remove_patient(force = TRUE)

/obj/item/reagent_containers/glass/iv_drip/proc/check_interact_range()
	. = TRUE
	if (!src.patient)
		return
	if (in_interact_range(src, src.patient))
		return
	// JAAAANK
	if ((src.patient.pulling == src) || (src.iv_stand && (src.patient.pulling == src.iv_stand)))
		return
	. = FALSE

/obj/item/reagent_containers/glass/iv_drip/proc/transfuse_fail_feedback(failure_feedback)
	if (!length(failure_feedback))
		return
	switch (failure_feedback)
		if (IV_FAIL_BAG_FULL)
			src.patient.visible_message(\
				SPAN_NOTICE("[src] fills up and stops drawing blood from [src.patient]."),\
				SPAN_NOTICE("[src] fills up and stops drawing blood from you."))
		if (IV_FAIL_PT_EMPTY)
			src.patient.visible_message(\
				SPAN_ALERT("[src] can't seem to draw anything more out of [src.patient]!"),\
				SPAN_ALERT("Your veins feel utterly empty!"))
		if (IV_FAIL_PT_FULL)
			src.patient.visible_message(\
				SPAN_NOTICE("<b>[src.patient]</b>'s transfusion finishes."),\
				SPAN_NOTICE("Your transfusion finishes."))
		if (IV_FAIL_BAG_EMPTY)
			src.patient.visible_message(SPAN_ALERT("[src] runs out of fluid!"))

/obj/item/reagent_containers/glass/iv_drip/proc/check_vampire(mob/living/carbon/mob_to_test)
	. = FALSE
	if (!iscarbon(mob_to_test))
		mob_to_test = src.patient
	if (isvampire(mob_to_test) && !mob_to_test.get_vampire_blood())
		. = TRUE

#undef IV_FAIL_PT_FULL
#undef IV_FAIL_BAG_EMPTY
#undef IV_FAIL_BAG_FULL
#undef IV_FAIL_PT_EMPTY

/datum/statusEffect/iv_drip
	id = "iv_drip"
	name = "IV line"
	desc = "Your're currently connected to an IV drip."
	icon_state = "+"
	unique = FALSE
	effect_quality = STATUS_QUALITY_NEUTRAL
	var/obj/item/reagent_containers/glass/iv_drip/iv_drip = null

/datum/statusEffect/iv_drip/getTooltip()
	. = "You are physically connected to an IV drip. Moving too far from it may forcefully disconnect you."

/datum/statusEffect/iv_drip/onAdd(obj/item/reagent_containers/glass/iv_drip/optional)
	..()
	src.iv_drip = optional

/datum/statusEffect/iv_drip/onCheck(optional)
	return src.iv_drip == optional

/obj/item/reagent_containers/glass/iv_drip/blood
	desc = "A bag filled with some odd, synthetic blood. There's a fine needle at the end that can be used to transfer it to someone."
	mode = IV_INJECT
	initial_reagents = "blood"

/obj/item/reagent_containers/glass/iv_drip/blood/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/reagent_containers/glass/iv_drip/saline
	desc = "A bag filled with saline. There's a fine needle at the end that can be used to transfer it to someone."
	mode = IV_INJECT
	initial_reagents = "saline"
