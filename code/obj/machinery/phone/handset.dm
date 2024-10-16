/obj/item/phone_handset
	name = "phone handset"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "I wonder if the last crewmember to use this washed their hands before touching it."
	w_class = W_CLASS_TINY

	start_listen_modifiers = list(LISTEN_MODIFIER_PHONE)
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD_RANGE_0, LISTEN_INPUT_EQUIPPED)
	start_listen_languages = list(LANGUAGE_ALL)
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_RADIO)
	say_language = LANGUAGE_ENGLISH

	var/obj/machinery/phone/parent = null
	var/icon/handset_icon = null

/obj/item/phone_handset/New(obj/machinery/phone/parent_phone, mob/living/picker_upper)
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
	processing_items.Add(src)

/obj/item/phone_handset/disposing()
	src.parent.handset = null
	src.parent = null
	processing_items.Remove(src)
	. = ..()

/obj/item/phone_handset/process()
	if (!src.parent)
		qdel(src)
		return

	if (!src.parent.answered || (BOUNDS_DIST(src, src.parent) == 0))
		return

	var/mob/holder = src.get_holder()
	if (holder)
		boutput(holder, SPAN_ALERT("The phone cord reaches it limit and the handset is yanked back to its base!"))

	src.parent.hang_up()
	processing_items.Remove(src)

/obj/item/phone_handset/update_icon()
	. = ..()
	src.UpdateOverlays(src.SafeGetOverlayImage("stripe", 'icons/obj/machines/phones.dmi',"[src.icon_state]-stripe"), "stripe")

/obj/item/phone_handset/hear(datum/say_message/message)
	if (!src.parent.linked || !src.parent.linked.handset)
		return

	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src.parent
	signal.encryption = "\ref[src.parent]"
	signal.data["message"] = message
	signal.data["address_1"] = src.parent.linked.net_id

	SEND_SIGNAL(src.parent, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, src.parent.frequency)

/obj/item/phone_handset/proc/get_holder()
	RETURN_TYPE(/mob)
	if (ismob(src.loc))
		return src.loc
