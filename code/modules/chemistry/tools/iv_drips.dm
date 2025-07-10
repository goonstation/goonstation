#define IV_INJECT 1
#define IV_DRAW 0

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
	var/image/fluid_image = null
	var/image/label_image = null
	var/image/image_inj_dr = null
	var/mob/living/carbon/human/patient = null
	var/obj/machinery/medical/iv_stand/stand = null
	var/mode = IV_DRAW
	var/in_use = FALSE
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

/obj/item/reagent_containers/iv_drip/on_reagent_change()
	..()
	src.update_name()
	src.UpdateIcon()
	if (src.stand)
		src.stand.UpdateIcon()

/obj/item/reagent_containers/iv_drip/update_icon()
	if (ismob(src.loc))
		if (!src.image_inj_dr)
			src.image_inj_dr = image(src.icon)
		src.image_inj_dr.icon_state = src.mode ? "inject" : "draw"
		src.UpdateOverlays(src.image_inj_dr, "inj_dr")
	else
		src.UpdateOverlays(null, "inj_dr")
	signal_event("icon_updated")

/obj/item/reagent_containers/iv_drip/is_open_container()
	. = TRUE

/obj/item/reagent_containers/iv_drip/pickup(mob/user)
	..()
	src.UpdateIcon()

/obj/item/reagent_containers/iv_drip/dropped(mob/user)
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
	src.attempt_transfusion(target, user)

/obj/item/reagent_containers/iv_drip/attackby(obj/A, mob/user)
	if (!iscuttingtool(A))
		return ..()
	if (src.slashed)
		src.slashed = TRUE
		src.desc = "[src.desc] It has been sliced open with a scalpel."
		boutput(user, "You carefully slice [src] open.")
	else
		boutput(user, "[src] has already been sliced open.")

/obj/item/reagent_containers/iv_drip/process(mult)
	if (!src.check_conditions())
		return
	switch (src.mode)
		if (IV_INJECT)
			src.draw_from_patient()
		if (IV_DRAW)
			src.inject_into_patient()

/obj/item/reagent_containers/iv_drip/proc/update_name()
	if (src.reagents?.total_volume)
		src.name = src.reagents.get_master_reagent_name() == "blood" ? "blood pack" : "[src.reagents.get_master_reagent_name()] drip"
	else
		src.name = "\improper IV drip"

/obj/item/reagent_containers/iv_drip/proc/attempt_transfusion(mob/living/carbon/H, mob/user)
	if (!iscarbon(H))
		return
	if (in_use)
		if (src.patient != H)
			user.show_text("[src] is already being used by someone else!", "red")
		else
			H.tri_message(user, SPAN_NOTICE("<b>[user]</b> removes [src]'s needle from [H == user ? "[his_or_her(H)]" : "[H]'s"] arm."),\
				SPAN_NOTICE("You remove [src]'s needle from [H == user ? "your" : "[H]'s"] arm."),\
				SPAN_NOTICE("[H == user ? "You remove" : "<b>[user]</b> removes"] [src]'s needle from your arm."))
			src.stop_transfusion()
		return
	if (src.mode == IV_INJECT)
		if (!src.reagents.total_volume)
			user.show_text("There's nothing left in [src]!", "red")
			return
		if (H.reagents && H.reagents.is_full())
			user.show_text("[H]'s blood pressure seems dangerously high as it is, there's probably no room for anything else!", "red")
			return
	if (src.mode == IV_DRAW)
		if (src.reagents.is_full())
			user.show_text("[src] is full!", "red")
			return
		// Vampires can't use this trick to inflate their blood count, because they can't get more than ~30% of it back.
		// Also ignore that second container of blood entirely if it's a vampire (Convair880).
		if ((isvampire(H) && (H.get_vampire_blood() <= 0)) || (!isvampire(H) && !H.blood_volume))
			user.show_text("[H] doesn't have anything left to give!", "red")
			return
	H.tri_message(user, SPAN_NOTICE("<b>[user]</b> begins inserting [src]'s needle into [H == user ? "[his_or_her(H)]" : "[H]'s"] arm."),\
		SPAN_NOTICE("[H == user ? "You begin" : "<b>[user]</b> begins"] inserting [src]'s needle into your arm."),\
		SPAN_NOTICE("You begin inserting [src]'s needle into [H == user ? "your" : "[H]'s"] arm."))
	logTheThing(LOG_COMBAT, user, "tries to hook up an IV drip [log_reagents(src)] to [constructTarget(H,"combat")] at [log_loc(user)].")
	SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(start_transfusion), list(H, user), src.icon, "IV", null, null)

/obj/item/reagent_containers/iv_drip/proc/start_transfusion(mob/living/carbon/human/H, mob/living/carbon/user)
	src.patient = H
	H.tri_message(user, SPAN_NOTICE("<b>[user]</b> inserts [src]'s needle into [H == user ? "[his_or_her(H)]" : "[H]'s"] arm."),\
		SPAN_NOTICE("[H == user ? "You insert" : "<b>[user]</b> inserts"] [src]'s needle into your arm."),\
		SPAN_NOTICE("You insert [src]'s needle into [H == user ? "your" : "[H]'s"] arm."))
	logTheThing(LOG_COMBAT, user, "connects an IV drip [log_reagents(src)] to [constructTarget(H,"combat")] at [log_loc(user)].")
	src.in_use = 1
	processing_items |= src
	APPLY_ATOM_PROPERTY(patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src, 2)
	if (src.stand)
		src.stand.UpdateIcon()

/obj/item/reagent_containers/iv_drip/proc/stop_transfusion()
	processing_items -= src
	src.in_use = 0
	REMOVE_ATOM_PROPERTY(patient, PROP_MOB_BLOOD_ABSORPTION_RATE, src)
	src.patient = null
	if (src.stand)
		src.stand.UpdateIcon()

/obj/item/reagent_containers/iv_drip/proc/draw_from_patient(mult)
	transfer_blood(src.patient, src, (src.amount_per_transfer_from_this * mult))

/obj/item/reagent_containers/iv_drip/proc/inject_into_patient(mult)
	src.reagents.trans_to(src.patient, (src.amount_per_transfer_from_this * mult))
	src.patient.reagents.reaction(src.patient, INGEST, (src.amount_per_transfer_from_this * mult))

/obj/item/reagent_containers/iv_drip/proc/check_conditions()
	. = TRUE
	if (!src.patient || !ishuman(src.patient) || !src.patient.reagents)
		return FALSE

	if ((!src.stand && !in_interact_range(src, src.patient)) || (src.stand && !in_interact_range(src.stand, src.patient)))
		var/fluff = pick("pulled", "yanked", "ripped")
		src.patient.visible_message(SPAN_ALERT("<b>[src]'s needle gets [fluff] out of [src.patient]'s arm!</b>"),\
		SPAN_ALERT("<b>[src]'s needle gets [fluff] out of your arm!</b>"))
		src.stop_transfusion()
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

#undef IV_INJECT
#undef IV_DRAW
