/*
CONTAINS:
AI PLATING KITS

*/

ABSTRACT_TYPE(/obj/item/ai_plating_kit)

/obj/item/ai_plating_kit
	name = "AI Frame Plating Kit (YOU SHOULD NOT SEE THIS, FILE A BUG REPORT IF YOU ARE READING THIS)"
	desc = "A kit for putting the plating on an AI frame! WARNING: Choking hazard, not intended for children under 3 years."
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai-green" // placeholder icon
	/// The skin to apply to an AI core frame when we install this as plating. Needs to be a valid string from /ai/var/skinsList
	var/skin = "default"

/obj/item/ai_plating_kit/syndicate
	name = "Syndicate AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! WARNING: Choking hazard, not intended for children under 3 years. <i>(Syndicate AI system not included)</i>"
	icon_state = "syndie_kit" // get it???
	skin = "syndicate"
	contraband = 1 // crime

/obj/item/ai_plating_kit/clown
	name = "Clown AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! WARNING: Choking hazard, not intended for children under 3 years. It smells funny."
	icon_state = "clown_kit"
	skin = "clown"

/obj/item/ai_plating_kit/mime
	name = "Mime AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! WARNING: Choking hazard, not intended for children under 3 years."
	icon_state = "mime_kit"
	skin = "mime"

/obj/item/ai_plating_kit/flock
	name = "Flock AI Frame Plating Kit"
	desc = "A kit for putting the plating on an AI! It seems to be... pulsing."
	icon_state = "flock_kit"
	skin = "flock"
