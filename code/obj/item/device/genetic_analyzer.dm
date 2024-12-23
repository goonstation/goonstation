/obj/item/device/analyzer/genetic
	name = "genetic analyzer"
	desc = "A hand-held genetic scanner able to compare a person's DNA with a database of known genes."
	icon_state = "genetic_analyzer"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	hide_attack = ATTACK_PARTIALLY_HIDDEN

/obj/item/device/analyzer/genetic/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	var/datum/computer/file/genetics_scan/GS = create_new_dna_sample_file(target)
	if (!GS)
		return
	user.visible_message(
		SPAN_ALERT("<b>[user]</b> has analyzed [target]'s genetic makeup."),
		SPAN_ALERT("You have analyzed [target]'s genetic makeup.")
	)
	// build prescan as we have the parts we need from the genetics scan file above, avoids re-looping, and we know these will be read-only
	var/datum/genetic_prescan/GP = new
	GP.activeDna = GS.dna_active
	GP.poolDna = GS.dna_pool
	GP.generate_known_unknown()
	boutput(user, scan_genetic(target, prescan = GP, visible = 1))

	record_cloner_defects(target)
