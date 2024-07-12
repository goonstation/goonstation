
ABSTRACT_TYPE(/obj/item/id_plating_kit)

/obj/item/id_plating_kit
	name = "ID Frame Plating Kit (YOU SHOULD NOT SEE THIS, FILE A BUG REPORT IF YOU ARE READING THIS)"
	desc = "A kit for putting the plating on an ID Card! WARNING: Choking hazard, not intended for children under 3 years."
	icon = 'icons/obj/items/card.dmi'
	icon_state = "fingerprint0" // placeholder icon
	/// The skin to apply to an ID card when we install this as plating. Needs to be a valid icon_state from icons/obj/item/card.dmi
	var/skin = "id"

/obj/item/id_plating_kit/syndicate
	name = "Syndicate ID Card Plating Kit"
	desc = "A kit for putting syndicate plating on an ID card! WARNING: Choking hazard, not intended for children under 3 years. <i>(Syndicate ID Access not included)</i>"
	icon_state = "kit_syndie"
	skin = "id_syndie"
	contraband = 1 // crime
