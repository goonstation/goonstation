/datum/element/lifeprocess/blindness/process(mob/living/target, mult, datum/gas_mixture/environment)
	if (!target.client)
		return

	// Animate it so that it doesnt "jump" as much.
	target.vision.animate_dither_alpha(target.get_eye_blurry() / 10 * 255, 15)

	var/mob/living/carbon/human/H = astype(target)
	if (!H)
		if (isdead(target) || target.sight_check(TRUE))
			target.removeOverlayComposition(/datum/overlayComposition/blinded)
		else
			target.addOverlayComposition(/datum/overlayComposition/blinded)

		return

	var/eyes_blinded = src.get_blindness_bitflag(H)

	// Check if an update is needed.
	if (H.last_eyes_blinded == eyes_blinded)
		return

	switch (eyes_blinded)
		if (EYEBLIND_L | EYEBLIND_R)
			H.addOverlayComposition(/datum/overlayComposition/blinded)
			H.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
			H.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

		if (EYEBLIND_L)
			H.removeOverlayComposition(/datum/overlayComposition/blinded)
			H.addOverlayComposition(/datum/overlayComposition/blinded_l_eye)
			H.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

		if (EYEBLIND_R)
			H.removeOverlayComposition(/datum/overlayComposition/blinded)
			H.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
			H.addOverlayComposition(/datum/overlayComposition/blinded_r_eye)

		else
			H.removeOverlayComposition(/datum/overlayComposition/blinded)
			H.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
			H.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

	H.last_eyes_blinded = eyes_blinded

/// Returns a 2-bit bitflag corresponding to the blind eyes of a human mob.
/datum/element/lifeprocess/blindness/proc/get_blindness_bitflag(mob/living/carbon/human/H)
	if (isdead(H))
		return 0

	if (!H.sight_check(TRUE))
		return EYEBLIND_L | EYEBLIND_R

	. = 0
	var/obj/item/clothing/glasses/glasses = astype(H.glasses)
	if (glasses)
		if (glasses.allow_blind_sight)
			return 0

		switch (glasses.block_eye)
			if ("L")
				. |= EYEBLIND_L
			if ("R")
				. |= EYEBLIND_R

	var/gforce = 0
	var/obj/item/organ/eye/left_eye = null
	var/obj/item/organ/eye/right_eye = null

	var/obj/item/organ/head/head = astype(H.mutantrace, /datum/mutantrace/skeleton)?.head_tracker
	if (head)
		gforce = head.gforce
		left_eye = head.left_eye
		right_eye = head.right_eye
	else
		gforce = H.gforce
		left_eye = H.get_organ("left_eye")
		right_eye = H.get_organ("right_eye")

	if (gforce >= GFORCE_MOB_BLINDNESS_THRESHOLD)
		return EYEBLIND_L | EYEBLIND_R

	if (!left_eye?.provides_sight)
		. |= EYEBLIND_L
	if (!right_eye?.provides_sight)
		. |= EYEBLIND_R
