/obj/machinery/medical/iv_stand
	name = "\improper IV stand"
	desc = {"A metal pole that you can hang IV bags on, which is useful since we aren't animals that go leaving our sanitized medical equipment all
			over the ground or anything!"}
	icon = 'icons/obj/machines/medical/iv_stand.dmi'
	icon_state = "IVstand"
	connect_directly = FALSE

	var/obj/item/reagent_containers/iv_drip/iv_drip = null
	var/transfer_rate = 5

	// Overlay images
	var/image/fluid_image = null
	var/image/bag_image = null

/obj/machinery/medical/iv_stand/parse_message(text, mob/user, mob/living/carbon/target, self_referential = FALSE)
	return

/obj/machinery/medical/iv_stand/New()
	. = ..()
	src.UpdateIcon()

/obj/machinery/medical/iv_stand/disposing()
	if (src.iv_drip)
		MOVE_OUT_TO_TURF_SAFE(src.iv_drip, src)
		src.iv_drip.iv_stand = null
		src.iv_drip = null
	..()

/obj/machinery/medical/iv_stand/get_desc()
	. = ..()
	if (src.iv_drip)
		var/iv_drip_examine = src.iv_drip.examine()
		iv_drip_examine = lowertext(copytext(iv_drip_examine, 1, 2)) + copytext(iv_drip_examine, 2)
		. += "[src.iv_drip] is attached to it; [iv_drip_examine]"

/obj/machinery/medical/iv_stand/update_icon()
	if (!src.iv_drip)
		src.icon_state = "IVstand"
		src.name = "\improper IV stand"
		src.UpdateOverlays(null, "fluid")
		src.UpdateOverlays(null, "bag")
		return
	src.name = "\improper IV stand ([src.iv_drip])"
	if (src.iv_drip.reagents.total_volume)
		src.bag_image = image(src.icon, icon_state = "IVstand1-full")
		if (!src.fluid_image)
			src.fluid_image = image(src.icon, icon_state = "IVstand1-fluid")
		src.fluid_image.icon_state = "IVstand1-fluid"
		var/datum/color/average = src.iv_drip.reagents.get_average_color()
		src.fluid_image.color = average.to_rgba()
		src.UpdateOverlays(src.fluid_image, "fluid")
	else
		src.bag_image = image(src.icon, icon_state = "IVstand1")
		src.UpdateOverlays(null, "fluid")
	if (!src.bag_image)
		src.bag_image = image(src.icon, icon_state = "IVstand1")
	src.UpdateOverlays(src.bag_image, "bag")
	if (src.iv_drip.patient)
		src.icon_state = "IVstand-active"
	else
		src.icon_state = "IVstand-finished"

/obj/machinery/medical/iv_stand/mouse_drop(atom/over_object)
	if (!isatom(over_object))
		. = ..()
		return
	var/mob/living/user = usr
	if (!isliving(user) || !can_act(user) || !in_interact_range(src, user) || !in_interact_range(over_object, user))
		. = ..()
		return
	if (!src.iv_drip)
		. = ..()
		return
	if (iscarbon(over_object))
		var/mob/living/carbon/new_patient = over_object
		src.iv_drip.attempt_add_patient(new_patient, user)
		return
	if (!isturf(over_object))
		. = ..()
		return
	var/turf/over_turf = over_object
	src.remove_iv_drip(user, over_turf)
	. = ..()

/obj/machinery/medical/iv_stand/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 2 SECONDS), user)
		return
	if (!istype(W, /obj/item/reagent_containers/iv_drip))
		. = ..()
		return
	if (isrobot(user)) // are they a borg? it's probably a mediborg's IV then, don't take that!
		return
	src.add_iv_drip(W, user)

/obj/machinery/medical/iv_stand/attack_hand(mob/user)
	if (!src.iv_drip)
		. = ..()
		return
	if (isrobot(user))
		return
	src.remove_iv_drip(user)

/obj/machinery/medical/iv_stand/attempt_add_patient(mob/user, mob/living/carbon/new_patient)
	. = TRUE
	if (!ismob(user))
		return FALSE
	if (!src.iv_drip)
		boutput(user, SPAN_ALERT("[src] does not have an IV drip attached!"))
		return FALSE
	src.iv_drip.attempt_add_patient(user, new_patient)

/obj/machinery/medical/iv_stand/add_patient(mob/living/carbon/new_patient, mob/user)
	if (src.patient)
		return
	if (!src.iv_drip.patient)
		return
	src.patient = src.iv_drip.patient
	src.SubscribeToProcess()

/obj/machinery/medical/iv_stand/remove_patient(mob/user, forceful)
	src.patient = null
	src.UnsubscribeProcess()

/obj/machinery/medical/iv_stand/affect_patient(mult)
	src.iv_drip.process(mult)

/obj/machinery/medical/iv_stand/deconstruct()
	if (src.iv_drip)
		src.iv_drip.set_loc(get_turf(src))
		src.iv_drip.iv_stand = null
		src.iv_drip = null
	var/obj/item/furniture_parts/IVstand/P = new /obj/item/furniture_parts/IVstand(src.loc)
	if (P && src.material)
		P.setMaterial(src.material)
	qdel(src)

/obj/machinery/medical/iv_stand/proc/add_iv_drip(obj/item/reagent_containers/iv_drip/new_IV, mob/user)
	if (src.iv_drip)
		return
	if (!istype(new_IV, /obj/item/reagent_containers/iv_drip))
		return
	user.visible_message(SPAN_NOTICE("[user] hangs [new_IV] on [src]."), SPAN_NOTICE("You hang [new_IV] on [src]."))
	user.u_equip(new_IV)
	new_IV.set_loc(src)
	src.iv_drip = new_IV
	src.iv_drip.iv_stand = src
	src.iv_drip.handle_processing()
	src.add_patient(src.iv_drip.patient)
	src.UpdateIcon()

/obj/machinery/medical/iv_stand/proc/remove_iv_drip(mob/user, turf/new_loc)
	var/obj/item/reagent_containers/iv_drip/old_IV = src.iv_drip
	src.iv_drip = null
	src.remove_patient()
	src.UpdateIcon()
	user.visible_message(SPAN_NOTICE("[user] takes [old_IV] down from [src]."),\
	SPAN_NOTICE("You take [old_IV] down from [src]."))
	if (ismob(user) && !isturf(new_loc))
		user.put_in_hand_or_drop(old_IV)
	else
		old_IV.set_loc(new_loc)
	old_IV.iv_stand = null
	old_IV.handle_processing()

/obj/machinery/medical/iv_stand/proc/feedback(feedback)
	var/output = ""
	switch (feedback)
		if (IV_STAND_STOP)
			output = "Stopped [src.iv_drip.mode == IV_INJECT ? "infusion" : "drawing"]."
		if (IV_STAND_START)
			output = "Started [src.iv_drip.mode == IV_INJECT ? "infusion" : "drawing"] at [src.transfer_rate]u per tick."
	src.say(output)

/obj/item/furniture_parts/IVstand
	name = "\improper IV stand parts"
	desc = "A collection of parts that can be used to make an IV stand."
	icon = 'icons/obj/machines/medical/iv_stand.dmi'
	icon_state = "IVstand_parts"
	force = 2
	stamina_damage = 10
	stamina_cost = 8
	furniture_type = /obj/machinery/medical/iv_stand
	furniture_name = "\improper IV stand"
	build_duration = 25
