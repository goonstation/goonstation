

/datum/lifeprocess/blindness
	process()
		if (!owner.client) return ..()

		owner.vision.animate_dither_alpha(owner.get_eye_blurry() / 10 * 255, 15) // animate it so that it doesnt "jump" as much

		if (human_owner)
			var/eyes_blinded = 0

			if (!isdead(human_owner))
				if (!human_owner.sight_check(1))
					eyes_blinded |= EYEBLIND_L
					eyes_blinded |= EYEBLIND_R
				else
					var/obj/item/organ/eye/left_eye = null
					var/obj/item/organ/eye/right_eye = null
					if (isskeleton(src.human_owner) && !src.human_owner.get_organ("head")) // get organs from the head, wherever it may be
						var/datum/mutantrace/skeleton/skele = src.human_owner.mutantrace
						left_eye = skele.head_tracker?.left_eye
						right_eye = skele.head_tracker?.right_eye
					else // get organs normally
						left_eye = human_owner.get_organ("left_eye")
						right_eye = human_owner.get_organ("right_eye")
					if (!left_eye)
						eyes_blinded |= EYEBLIND_L
					if (!right_eye)
						eyes_blinded |= EYEBLIND_R
					if (istype(human_owner.glasses))
						if (human_owner.glasses.block_eye)
							if (human_owner.glasses.block_eye == "L")
								eyes_blinded |= EYEBLIND_L
							else
								eyes_blinded |= EYEBLIND_R
						if (human_owner.glasses.allow_blind_sight)
							eyes_blinded = 0

			if (human_owner.last_eyes_blinded == eyes_blinded) // we don't need to update!
				return ..()


			if (!eyes_blinded) // neither eye is blind
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			else if ((eyes_blinded & EYEBLIND_L) && (eyes_blinded & EYEBLIND_R)) // both eyes are blind
				human_owner.addOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			else if (eyes_blinded & EYEBLIND_L) // left eye is blind, not right
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.addOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			else if (eyes_blinded & EYEBLIND_R) // right eye is blind, not left
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.addOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			else // edge case?  remove overlays just in case
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_l_eye)
				human_owner.removeOverlayComposition(/datum/overlayComposition/blinded_r_eye)

			human_owner.last_eyes_blinded = eyes_blinded
		else
			if (!owner.sight_check(1) && !isdead(owner))
				owner.addOverlayComposition(/datum/overlayComposition/blinded) //ov1
			else
				owner.removeOverlayComposition(/datum/overlayComposition/blinded) //ov1
		..()

