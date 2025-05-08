/obj/dialogueobj/cultistcorpse_1
	name = "fanatical corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "seccorpse7"
	density = 0
	anchored = ANCHORED_ALWAYS
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/cultist_corpse_1(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/cultist_corpse_1
	dialogueName = "Cultist Initiate Corpse"
	start = /datum/dialogueNode/cultist_corpse1_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	cultistcorpse1_start
		linkText = "..."
		links = list(/datum/dialogueNode/cultist_corpse1_scan, /datum/dialogueNode/cultist_corpse1_revelation)

		getNodeText(var/client/C)
			return "This man in fanatical clothes appears to have crawled up this ladder on the last of their air with a leg injury, a distress signal, and a dream. Dream on in the next life buddy."

	cultistcorpse1_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "Stabbing wound prominient source of blood loss in subject. Final death was caused by oxygen deprivation."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

	cultist_corpse1_revelation
		linkText = "(Examine the clothes using your religious knowledge)"
		nodeText = "This attire is worn by those who worship the deep, no doubt drawn to the area by the various megafauna in these depths."
		links = list()

		canShow(var/client/C)
			if(C.traitHolder.hasTrait("training_chaplain")) return 1
			else return 0
