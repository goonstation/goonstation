/*
CONTAINS:
AI PLATING KITS

*/

ABSTRACT_TYPE(/obj/item/ai_plating_kit)

/obj/item/ai_plating_kit
	name = "AI Frame Plating Kit (YOU SHOULD NOT SEE THIS, FILE A BUG REPORT IF YOU ARE READING THIS)"
	desc = "A kit for putting the plating on an AI frame! WARNING: Choking hazard, not intended for children under 3 years."
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai_green" // placeholder icon
	/// The skin to apply to an AI core frame when we install this as plating. Needs to be a valid string from /ai/var/skinsList
	var/skin = "default"

/obj/item/ai_plating_kit/syndicate
	name = "Syndicate AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! WARNING: Choking hazard, not intended for children under 3 years. <i>(Syndicate AI system not included)</i>"
	icon_state = "kit_syndie" // sorry I ruined the syndie_kit pun by making everything in ai.dmi consistant -444
	skin = "syndicate"
	contraband = 1 // crime

/obj/item/ai_plating_kit/clown
	name = "Clown AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! WARNING: Choking hazard, not intended for children under 3 years. It smells funny."
	icon_state = "kit_clown"
	skin = "clown"

/obj/item/ai_plating_kit/mime
	name = "Mime AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! WARNING: Choking hazard, not intended for children under 3 years."
	icon_state = "kit_mime"
	skin = "mime"

/obj/item/ai_plating_kit/flock
	name = "Flock AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! It seems to be... pulsing."
	icon_state = "kit_flock"
	skin = "flock"

/obj/item/ai_plating_kit/pumpkin
	name = "Pumpkin AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! It feels squishy."
	icon_state = "kit_pumpkin"
	skin = "pumpkin"

/obj/item/ai_plating_kit/regal
	name = "Regal AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! Fit for a monarch."
	icon_state = "kit_regal"
	skin = "regal"
