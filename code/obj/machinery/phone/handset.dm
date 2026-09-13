/obj/item/phone_handset
	name = "phone handset"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "I wonder if the last crewmember to use this washed their hands before touching it."
	w_class = W_CLASS_TINY
	say_language = LANGUAGE_ENGLISH
	HELP_MESSAGE_OVERRIDE("Only picks up sound in your <b>active hand</b>.")

	var/obj/machinery/phone/parent = null
	var/icon/handset_icon = null

/obj/item/phone_handset/New(obj/machinery/phone/parent_phone)
	if (!parent_phone)
		return

	. = ..()

	icon_state = "handset"
	src.parent = parent_phone
	var/image/stripe_image = image('icons/obj/machines/phones.dmi',"[src.icon_state]-stripe")
	stripe_image.color = parent_phone.stripe_color
	stripe_image.appearance_flags = RESET_COLOR | PIXEL_SCALE
	src.color = parent_phone.color
	src.UpdateOverlays(stripe_image, "stripe")
	src.handset_icon = getFlatIcon(src)

	src.AddComponent(/datum/component/phone_microphone, parent_phone)
	src.AddComponent(/datum/component/phone_speaker, parent_phone)

/obj/item/phone_handset/disposing()
	src.parent.hang_up()
	src.RemoveComponentsOfType(/datum/component/phone_microphone)
	src.RemoveComponentsOfType(/datum/component/phone_speaker)
	src.handset_icon = null
	src.parent.handset = null
	src.parent = null
	processing_items.Remove(src)
	. = ..()

/obj/item/phone_handset/update_icon()
	. = ..()
	src.UpdateOverlays(src.SafeGetOverlayImage("stripe", 'icons/obj/machines/phones.dmi',"[src.icon_state]-stripe"), "stripe")

/obj/item/phone_handset/proc/get_holder()
	RETURN_TYPE(/mob)
	if (ismob(src.loc))
		return src.loc
