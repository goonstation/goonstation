var/global/mob/living/carbon/human/character_preview_icon_mob = null

/proc/character_preview_icon(datum/appearanceHolder/AH, datum/mutantrace/MR = null, direction = SOUTH)
	if (isnull(character_preview_icon_mob))
		character_preview_icon_mob = new()

	var/mob/living/carbon/human/H = character_preview_icon_mob

	H.dir = direction
	H.bioHolder.mobAppearance.CopyOther(AH)
	H.set_mutantrace(MR)
	H.organHolder.head.donor = H
	H.organHolder.head.donor_appearance.CopyOther(H.bioHolder.mobAppearance)

	H.update_colorful_parts()
	H.update_body()
	H.update_face()

	. = getFlatIcon(H)
