/datum/listen_module/effect/detgadget
	id = LISTEN_EFFECT_DETGADGET

/datum/listen_module/effect/detgadget/process(datum/say_message/message)
	var/obj/item/clothing/head/det_hat/gadget/hat = src.parent_tree.listener_parent
	if (!istype(hat) || !ismob(message.speaker))
		return

	var/phrase_location = findtext(message.original_content, hat.phrase)
	if (!phrase_location)
		return

	var/mob/M = message.speaker
	var/gadget = copytext(message.original_content, phrase_location + length(hat.phrase))
	gadget = replacetext(gadget, " ", "")

	for (var/name in hat.items)
		if (!findtext(gadget, name))
			continue

		var/obj/item/I = locate(hat.items[name]) in hat.contents
		if (!istype(I))
			continue

		M.put_in_hand_or_drop(I)
		M.visible_message(SPAN_ALERT("<b>[M]</b>'s hat snaps open and pulls out \the [I]!"))
		return

	if (findtext(gadget, "cigarette"))
		var/num_of_cigarettes = length(hat.cigs)
		if (!num_of_cigarettes)
			M.show_text("You're out of cigs, shit! How you gonna get through the rest of the day?", "red")
			return

		var/obj/item/clothing/mask/cigarette/cigarette = hat.cigs[num_of_cigarettes]
		hat.cigs -= cigarette

		var/location = "hand"
		var/mob/living/carbon/human/H = M
		if (istype(H) && H.equip_if_possible(cigarette, SLOT_WEAR_MASK))
			location = "mouth"
		else
			M.put_in_hand_or_drop(cigarette)

		M.visible_message(SPAN_ALERT("<b>[M]</b>'s hat snaps open and puts \the [cigarette] in [his_or_her(M)] [location]!"))
		var/obj/item/device/light/zippo/lighter = (locate(/obj/item/device/light/zippo) in hat.contents)
		if (lighter)
			cigarette.light(M, SPAN_ALERT("<b>[M]</b>'s hat proceeds to light \the [cigarette] with \the [lighter], whoa."))
			lighter.firesource_interact()

	else
		M.show_text("Requested object missing or nonexistant!", "red")
