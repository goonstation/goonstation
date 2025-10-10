/**
 * IV stands
 *
 * N.B. The lights on the IV pump will flash red when these conditions are true:
 * 	- An IV bag is attached
 * 	- The area containing the IV stand is powered
 * 	- The IV bag is not connected to a patient
 * This is intended behaviour; aiming to emulate the error state on real-world IV pumps which would flash and beep if the line was occluded among
 * other error conditions - DisturbHerb
 */
/obj/machinery/medical/blood/iv_stand
	name = "\improper IV stand"
	desc = {"A metal pole that you can hang IV bags on, which is useful since we aren't animals that go leaving our sanitized medical equipment all
			over the ground or anything!"}
	icon = 'icons/obj/machines/medical/iv_stand.dmi'
	icon_state = "IV_stand"
	connect_directly = FALSE
	// This transfer rate may differ from the attached `iv_drip`.
	transfer_volume = 5

	low_power_msg = "IV pump unable to draw power. Check bag."
	start_msg = "$MODE patient at $VOLu per tick."
	stop_msg = "Stopped $MODE patient."

	/// IV stands cannot operate without an `iv_drip` attached. This machine does not directly connect to the patient.
	var/obj/item/reagent_containers/iv_drip/iv_drip = null

/**
 * Unique overrides:
 * 	$MODE -> [src.iv_drip.mode]
*/
/obj/machinery/medical/blood/iv_stand/parse_message(text, mob/user, mob/living/carbon/target, self_referential = FALSE)
	text = ..()
	if (src.iv_drip)
		text = replacetext(text, "$MODE", "[src.iv_drip?.mode ? "infusing" : "drawing from"]")
	. = text

/obj/machinery/medical/blood/iv_stand/New()
	..()
	src.UpdateIcon()
	src.update_name()

/obj/machinery/medical/blood/iv_stand/disposing()
	if (src.iv_drip)
		src.remove_iv_drip()
	..()

/obj/machinery/medical/blood/iv_stand/get_desc()
	. = ..()
	if (!src.iv_drip)
		return
	var/iv_drip_desc = src.iv_drip.desc
	iv_drip_desc = lowertext(copytext(iv_drip_desc, 1, 2)) + copytext(iv_drip_desc, 2)
	. += "[src.iv_drip] is attached to it; [iv_drip_desc]"

/obj/machinery/medical/blood/iv_stand/update_icon()
	if (!src.iv_drip)
		src.ClearSpecificOverlays("fluid", "bag", "lights")
		src.UpdateOverlays(image(src.icon, icon_state = "IV_pump-lid"), "lid")
		return
	src.handle_iv_bag_image()
	src.ClearSpecificOverlays("lid")
	if (src.iv_drip.patient || src.is_disabled())
		src.ClearSpecificOverlays("lights")
	if (!src.iv_drip.patient)
		src.UpdateOverlays(image(src.icon, icon_state = "IV_pump-lights"), "lights")

/obj/machinery/medical/blood/iv_stand/proc/handle_iv_bag_image()
	src.UpdateOverlays(image(src.icon, icon_state = "IV"), "bag")
	if (!src.iv_drip.reagents.total_volume)
		src.ClearSpecificOverlays("fluid")
		return
	var/image/fluid_image = image(src.icon, icon_state = "IV-fluid")
	fluid_image.icon_state = "IV-fluid"
	fluid_image.color = src.iv_drip.reagents.get_average_color().to_rgba()
	src.UpdateOverlays(fluid_image, "fluid")

/obj/machinery/medical/blood/iv_stand/proc/update_name()
	if (src.iv_drip)
		src.name = "[initial(src.name)] ([src.iv_drip])"
		return
	src.name = initial(src.name)

/obj/machinery/medical/blood/iv_stand/mouse_drop_behaviour(atom/over_object, mob/living/user)
	if (isturf(over_object) && src.iv_drip)
		var/turf/over_turf = over_object
		src.remove_iv_drip(user, over_turf)
		return TRUE
	. = ..()

/obj/machinery/medical/blood/iv_stand/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 2 SECONDS), user)
		return
	if (!istype(W, /obj/item/reagent_containers/iv_drip))
		return ..()
	if (isrobot(user)) // are they a borg? it's probably a mediborg's IV then, don't take that!
		return
	src.add_iv_drip(W, user)

/obj/machinery/medical/blood/iv_stand/attack_hand(mob/user)
	if (!src.iv_drip)
		return ..()
	if (isrobot(user))
		return ..()
	src.remove_iv_drip(user)

/obj/machinery/medical/blood/iv_stand/attempt_add_patient(mob/user, mob/living/carbon/new_patient)
	. = TRUE
	if (!ismob(user))
		return FALSE
	if (!src.iv_drip)
		boutput(user, SPAN_ALERT("[src] does not have an IV drip attached!"))
		return FALSE
	if (!src.iv_drip.attempt_add_patient(user, new_patient))
		return FALSE
	src.add_patient(new_patient)

/obj/machinery/medical/blood/iv_stand/add_patient(mob/living/carbon/new_patient, mob/user)
	if (!src.iv_drip)
		return
	src.patient = new_patient
	src.start_affect()
	src.UpdateIcon()

/obj/machinery/medical/blood/iv_stand/remove_patient(mob/user, force = FALSE)
	src.stop_affect()
	src.patient = null
	src.UpdateIcon()
	src.iv_drip?.remove_patient(user, force)

/obj/machinery/medical/blood/iv_stand/can_affect()
	. = ..()
	if (!src.iv_drip)
		return FALSE

/obj/machinery/medical/blood/iv_stand/affect_patient(mult)
	..()
	src.iv_drip.process(mult)

/obj/machinery/medical/blood/iv_stand/deconstruct()
	if (src.iv_drip)
		src.remove_iv_drip()
	var/obj/item/furniture_parts/IVstand/P = new /obj/item/furniture_parts/IVstand(src.loc)
	if (P && src.material)
		P.setMaterial(src.material)
	qdel(src)

/obj/machinery/medical/blood/iv_stand/proc/add_iv_drip(obj/item/reagent_containers/iv_drip/new_iv, mob/user)
	if (src.iv_drip)
		return
	if (!istype(new_iv, /obj/item/reagent_containers/iv_drip))
		return
	user.visible_message(SPAN_NOTICE("[user] hangs [new_iv] on [src]."), SPAN_NOTICE("You hang [new_iv] on [src]."))
	if (new_iv.loc == user)
		user.u_equip(new_iv)
	new_iv.set_loc(src)
	src.iv_drip = new_iv
	src.iv_drip.iv_stand = src
	src.iv_drip.handle_processing()
	src.add_patient(src.iv_drip.patient)
	src.UpdateIcon()
	src.update_name()

/obj/machinery/medical/blood/iv_stand/proc/remove_iv_drip(mob/user, turf/new_loc)
	src.stop_affect()
	var/obj/item/reagent_containers/iv_drip/old_iv = src.iv_drip
	src.iv_drip.iv_stand = null
	src.iv_drip = null
	src.remove_patient()
	src.UpdateIcon()
	src.update_name()
	old_iv.handle_processing()
	if (ismob(user))
		user.visible_message(SPAN_NOTICE("[user] takes [old_iv] down from [src]."), SPAN_NOTICE("You take [old_iv] down from [src]."))
		user.put_in_hand_or_drop(old_iv)
		return
	if (!isturf(new_loc))
		new_loc = get_turf(src)
	src.iv_drip.set_loc(new_loc)

/obj/item/furniture_parts/IVstand
	name = "\improper IV stand parts"
	desc = "A collection of parts that can be used to make an IV stand."
	icon = 'icons/obj/machines/medical/iv_stand.dmi'
	icon_state = "IV_stand_parts"
	force = 2
	stamina_damage = 10
	stamina_cost = 8
	furniture_type = /obj/machinery/medical/blood/iv_stand
	furniture_name = "\improper IV stand"
	build_duration = 25
