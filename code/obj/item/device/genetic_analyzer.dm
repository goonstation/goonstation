/obj/item/device/analyzer/genetic
	name = "genetic analyzer"
	desc = "A hand-held genetic scanner able to compare a person's DNA with a database of known genes."
	icon_state = "genetic_analyzer"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	hide_attack = ATTACK_PARTIALLY_HIDDEN

/obj/item/device/analyzer/genetic/attack(mob/M, mob/user)
	var/datum/computer/file/genetics_scan/GS = create_new_dna_sample_file(M)
	if (!GS)
		return
	user.visible_message(
		"<span class='alert'><b>[user]</b> has analyzed [M]'s genetic makeup.</span>",
		"<span class='alert'>You have analyzed [M]'s genetic makeup.</span>"
	)
	// build prescan as we have the parts we need from the genetics scan file above, avoids re-looping, and we know these will be read-only
	var/datum/genetic_prescan/GP = new
	GP.activeDna = GS.dna_active
	GP.poolDna = GS.dna_pool
	GP.generate_known_unknown()
	boutput(user, scan_genetic(M, prescan = GP, visible = 1))
