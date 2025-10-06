/* ================================================= */
/* -------------------- IV Drip -------------------- */
/* ================================================= */

/obj/item/reagent_containers/iv_drip
	name = "\improper IV drip"
	desc = "A bag with a fine needle attached at the end, for injecting patients with fluids."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "IV"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "IV"
	w_class = W_CLASS_TINY
	flags = TABLEPASS | SUPPRESSATTACK | OPENCONTAINER
	rc_flags = RC_VISIBLE | RC_FULLNESS | RC_SPECTRO
	amount_per_transfer_from_this = 5
	initial_volume = 250

	var/mob/living/carbon/human/patient = null
	var/obj/machinery/medical/iv_stand/iv_stand = null

	var/image/fluid_image = null
	var/image/label_image = null
	var/image/image_inj_dr = null

	var/mode = IV_DRAW
	/// Other reagent containers can pour reagents into this if slashed oppen.
	var/slashed = FALSE

/obj/item/reagent_containers/iv_drip/New()
	..()
	if (src.reagents.get_master_reagent_name() == "blood")
		src.label_image = image(src.icon, "IVlabel-blood")
	if (!src.label_image)
		src.label_image = image(src.icon, "IVlabel")
	src.UpdateOverlays(src.label_image, "label")
	src.AddComponent( \
		/datum/component/reagent_overlay, \
		reagent_overlay_icon = src.icon, \
		reagent_overlay_icon_state = "IV", \
		reagent_overlay_states = 9, \
		reagent_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_LINEAR, \
	)
	src.update_name()
	src.UpdateIcon()

/obj/item/reagent_containers/iv_drip/disposing()
	processing_items -= src
	if (src.patient)
		src.remove_patient()
	. = ..()

/obj/item/reagent_containers/iv_drip/moved(mob/user, old_loc)
	src.on_movement()
	. = ..()

/obj/item/reagent_containers/iv_drip/on_reagent_change()
	..()
	src.update_name()
	src.UpdateIcon()
	if (src.iv_stand)
		src.iv_stand.UpdateIcon()

/obj/item/reagent_containers/iv_drip/update_icon()
	if (ismob(src.loc))
		if (!src.image_inj_dr)
			src.image_inj_dr = image(src.icon)
		src.image_inj_dr.icon_state = src.mode ? "inject" : "draw"
		src.UpdateOverlays(src.image_inj_dr, "inj_dr")
	else
		src.UpdateOverlays(null, "inj_dr")

/obj/item/reagent_containers/iv_drip/is_open_container()
	. = TRUE

/obj/item/reagent_containers/iv_drip/pickup(mob/user)
	if (src.patient && (src.patient != user))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement), TRUE)
	..()
	SPAWN(0)
		src.UpdateIcon()

/obj/item/reagent_containers/iv_drip/dropped(mob/user)
	if (src.patient != user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	..()
	SPAWN(0)
		src.UpdateIcon()

/obj/item/reagent_containers/iv_drip/attack_self(mob/user)
	src.mode = !src.mode
	user.show_text("You switch [src] to [src.mode ? "inject" : "draw"].")
	src.UpdateIcon()

/obj/item/reagent_containers/iv_drip/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (!ishuman(target))
		return ..()
	src.attempt_add_patient(target, user)

/obj/item/reagent_containers/iv_drip/attackby(obj/A, mob/user)
	if (!iscuttingtool(A))
		return ..()
	if (src.slashed)
		src.slashed = TRUE
		src.desc = "[src.desc] It has been sliced open with a scalpel."
		boutput(user, "You carefully slice [src] open.")
	else
		boutput(user, "[src] has already been sliced open.")

/obj/item/reagent_containers/iv_drip/mouse_drop(atom/over_object)
	if (!isatom(over_object))
		. = ..()
		return
	var/mob/living/user = usr
	if (!isliving(user) || !can_act(user) || !in_interact_range(src, user) || !in_interact_range(over_object, user))
		. = ..()
		return
	if (!istype(over_object, /obj/machinery/medical/iv_stand))
		. = ..()
		return
	var/obj/machinery/medical/iv_stand/iv_stand = over_object
	iv_stand.add_iv_drip(over_object, user)
	. = ..()

/// `mult` only matters if `src` is connected to an IV stand.
/obj/item/reagent_containers/iv_drip/process(mult = 1)
	if (!src.check_conditions())
		return
	switch (src.mode)
		if (IV_DRAW)
			src.handle_draw(mult)
		if (IV_INJECT)
			src.handle_inject(mult)

/obj/item/reagent_containers/iv_drip/proc/handle_draw(mult)
	if (src.reagents.is_full())
		src.visible_message("[src] is completely full!")
		src.stop_transfusion()
		return
	var/transfer_rate = src.iv_stand ? src.iv_stand.transfer_rate : src.amount_per_transfer_from_this
	transfer_blood(src.patient, src, (transfer_rate * mult))

/obj/item/reagent_containers/iv_drip/proc/handle_inject(mult)
	if (!src.reagents.total_volume)
		src.visible_message("[src] is completely empty!")
		src.stop_transfusion()
		return
	var/transfer_rate = src.iv_stand ? src.iv_stand.transfer_rate : src.amount_per_transfer_from_this
	src.reagents.trans_to(src.patient, (transfer_rate * mult))
	src.patient.reagents.reaction(src.patient, INGEST, (transfer_rate * mult))

/obj/item/reagent_containers/iv_drip/proc/update_name()
	if (src.reagents?.total_volume)
		src.name = src.reagents.get_master_reagent_name() == "blood" ? "blood pack" : "[src.reagents.get_master_reagent_name()] drip"
	else
		src.name = "\improper IV drip"

/obj/item/reagent_containers/iv_drip/proc/attempt_add_patient(mob/living/carbon/new_patient, mob/user)
	if (!iscarbon(new_patient))
		return
	if (src.patient)
		if (src.patient != new_patient)
			user.show_text("[src] is already being used by someone else!", "red")
		else
			src.remove_patient(user)
		return
	var/feedback = src.can_connect(new_patient)
	if (feedback)
		user.show_text(feedback, "red")
		return
	new_patient.tri_message(user,\
		SPAN_NOTICE("<b>[user]</b> begins inserting [src]'s needle into [new_patient == user ? "[his_or_her(new_patient)]" : "[new_patient]'s"] arm."),\
		SPAN_NOTICE("[new_patient == user ? "You begin" : "<b>[user]</b> begins"] inserting [src]'s needle into your arm."),\
		SPAN_NOTICE("You begin inserting [src]'s needle into [new_patient == user ? "your" : "[new_patient]'s"] arm."))
	logTheThing(LOG_COMBAT, user, "tries to hook up an IV drip [log_reagents(src)] to [constructTarget(new_patient,"combat")] at [log_loc(user)].")
	var/icon/actionbar_icon = src.iv_stand ? src.iv_stand.icon : src.icon
	var/actionbar_icon_state = src.iv_stand ? src.iv_stand.icon_state : "IV"
	SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(add_patient), list(new_patient, user), actionbar_icon, actionbar_icon_state, null, null)

/obj/item/reagent_containers/iv_drip/proc/can_connect(mob/living/carbon/new_patient)
	if (src.mode == IV_INJECT)
		if (!src.reagents.total_volume)
			. = "There's nothing left in [src]!"
			return
		if (new_patient.reagents && new_patient.reagents.is_full())
			. = "[new_patient]'s blood pressure seems dangerously high as it is, there's probably no room for anything else!"
			return
	if (src.mode == IV_DRAW)
		if (src.reagents.is_full())
			. = "[src] is full!"
			return
		// Vampires can't use this trick to inflate their blood count, because they can't get more than ~30% of it back.
		// Also ignore that second container of blood entirely if it's a vampire (Convair880).
		if ((isvampire(new_patient) && (new_patient.get_vampire_blood() <= 0)) || (!isvampire(new_patient) && !new_patient.blood_volume))
			. = "[new_patient] doesn't have anything left to give!"
			return

/obj/item/reagent_containers/iv_drip/proc/add_patient(mob/living/carbon/human/new_patient, mob/user)
	if (src.patient)
		return
	src.patient = new_patient
	RegisterSignal(src.patient, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement), TRUE)
	src.start_transfusion()
	if (!ismob(user))
		return
	if ((src.loc == user) && (src.patient != user))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement), TRUE)
	new_patient.tri_message(user,\
		SPAN_NOTICE("<b>[user]</b> inserts [src]'s needle into [new_patient == user ? "[his_or_her(new_patient)]" : "[new_patient]'s"] arm."),\
		SPAN_NOTICE("[new_patient == user ? "You insert" : "<b>[user]</b> inserts"] [src]'s needle into your arm."),\
		SPAN_NOTICE("You insert [src]'s needle into [new_patient == user ? "your" : "[new_patient]'s"] arm."))
	logTheThing(LOG_COMBAT, user, "connects an IV drip [log_reagents(src)] to [constructTarget(new_patient,"combat")] at [log_loc(user)].")

/obj/item/reagent_containers/iv_drip/proc/remove_patient(mob/user, force = FALSE)
	if (!src.patient)
		return
	UnregisterSignal(src.patient, COMSIG_MOVABLE_MOVED)
	if (force)
		var/fluff = pick("pulled", "yanked", "ripped")
		src.patient.visible_message(SPAN_ALERT("<b>[src]'s needle gets [fluff] out of [src.patient]'s arm!</b>"),\
		SPAN_ALERT("<b>[src]'s needle gets [fluff] out of your arm!</b>"))
		blood_slash(src.patient, 5)
		src.patient.emote("scream")
	var/mob/living/carbon/human/old_patient = src.patient
	src.stop_transfusion()
	src.patient = null
	if (!ismob(user))
		return
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	old_patient.tri_message(user,\
		SPAN_NOTICE("<b>[user]</b> removes [src]'s needle from [old_patient == user ? "[his_or_her(old_patient)]" : "[old_patient]'s"] arm."),\
		SPAN_NOTICE("You remove [src]'s needle from [old_patient == user ? "your" : "[old_patient]'s"] arm."),\
		SPAN_NOTICE("[old_patient == user ? "You remove" : "<b>[user]</b> removes"] [src]'s needle from your arm."))

/obj/item/reagent_containers/iv_drip/proc/start_transfusion()
	src.handle_processing()
	APPLY_ATOM_PROPERTY(src.patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src, 2)
	if (!src.iv_stand)
		return
	src.iv_stand.feedback(IV_STAND_START)

/obj/item/reagent_containers/iv_drip/proc/stop_transfusion()
	REMOVE_ATOM_PROPERTY(src.patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src)
	processing_items -= src
	if (!src.iv_stand)
		return
	src.iv_stand.feedback(IV_STAND_STOP)

/// When attached to an IV stand, we'll leech off of the machine process loop instead of `processing_items`.
/obj/item/reagent_containers/iv_drip/proc/handle_processing()
	if (src.iv_stand || !src.patient)
		processing_items -= src
		return
	processing_items |= src

/obj/item/reagent_containers/iv_drip/proc/on_movement()
	. = TRUE
	if (!src.patient)
		return
	if (!src.check_interact_range())
		return FALSE

/obj/item/reagent_containers/iv_drip/proc/check_interact_range()
	. = TRUE
	if (!src.patient)
		return
	if (in_interact_range(src, src.patient))
		return
	// JAAAANK
	if (src.patient.pulling == (src || src.iv_stand))
		return
	src.remove_patient(force = TRUE)
	. = FALSE

/obj/item/reagent_containers/iv_drip/proc/check_conditions()
	. = TRUE
	if (!src.patient || !ishuman(src.patient) || !src.patient.reagents)
		return FALSE

	if (!src.check_interact_range())
		return FALSE

	if (src.mode == IV_INJECT)
		if (src.patient.reagents.is_full())
			src.patient.visible_message(SPAN_NOTICE("<b>[src.patient]</b>'s transfusion finishes."),\
			SPAN_NOTICE("Your transfusion finishes."))
			src.stop_transfusion()
			return FALSE
		if (!src.reagents.total_volume)
			src.patient.visible_message(SPAN_ALERT("[src] runs out of fluid!"))
			src.stop_transfusion()
			return FALSE
		return

	if (src.mode == IV_DRAW)
		if (src.reagents.is_full())
			src.patient.visible_message(SPAN_NOTICE("[src] fills up and stops drawing blood from [src.patient]."),\
			SPAN_NOTICE("[src] fills up and stops drawing blood from you."))
			src.stop_transfusion()
			return FALSE
		// Vampires can't use this trick to inflate their blood count, because they can't get more than ~30% of it back.
		// Also ignore that second container of blood entirely if it's a vampire (Convair880).
		if ((isvampire(src.patient) && (src.patient.get_vampire_blood() <= 0)) || (!isvampire(src.patient) && !src.patient.reagents.total_volume && !src.patient.blood_volume))
			src.patient.visible_message(SPAN_ALERT("[src] can't seem to draw anything more out of [src.patient]!"),\
			SPAN_ALERT("Your veins feel utterly empty!"))
			src.stop_transfusion()
			return FALSE

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/iv_drip/blood
	desc = "A bag filled with some odd, synthetic blood. There's a fine needle at the end that can be used to transfer it to someone."
	mode = IV_INJECT
	initial_reagents = "blood"

/obj/item/reagent_containers/iv_drip/blood/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/reagent_containers/iv_drip/saline
	desc = "A bag filled with saline. There's a fine needle at the end that can be used to transfer it to someone."
	mode = IV_INJECT
	initial_reagents = "saline"
