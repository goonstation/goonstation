// Cult base dialogue or items only used in dialogue
/obj/item/cult_sigil
	name = "improvised talisman"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "sigil_key"
	w_class = W_CLASS_SMALL
	desc = "A rag-tag sigil stitched together, it might fit in that seal now."

/obj/item/cult_sigil_pt1
	name = "golden pattern"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "sigil_pt1"
	w_class = W_CLASS_SMALL
	desc = "A golden handheld construct with the sigil of the deep, similar to a cross in conventional religions."

/obj/item/cult_sigil_pt2
	name = "green seal"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "sigil_pt2"
	w_class = W_CLASS_SMALL
	desc = "A green wax mold, it appears to already have a indent inside it."

/obj/item/cult_sigil_pt3
	name = "odd crystal"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "sigil_pt3"
	w_class = W_CLASS_SMALL
	desc = "A purple crystal, it appears to gaze at you like a eye."

/obj/item/control_key
	name = "voltage control safety key"
	icon = 'icons/obj/artifacts/keys.dmi'
	icon_state = "key_round"
	w_class = W_CLASS_SMALL
	desc = "It has Voltage Control written on the handle."

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

	cultist_corpse1_start
		linkText = "..."
		links = list(/datum/dialogueNode/cultist_corpse1_scan, /datum/dialogueNode/cultist_corpse1_revelation)

		getNodeText(var/client/C)
			return "This man in fanatical clothes appears to have crawled up this ladder on the last of their air with a leg injury, a distress signal, and a dream. Dream on in the next life buddy."

	cultist_corpse1_scan
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
			if(C.mob.traitHolder.hasTrait("training_chaplain")) return 1
			else return 0

/obj/dialogueobj/cultistbarricade
	name = "ominious barricade"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "sigil_barricade"
	density = 1
	opacity = 1
	anchored = ANCHORED_ALWAYS
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/cultistbarricade(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/cultistbarricade
	dialogueName = "Ominious Barricade"
	start = /datum/dialogueNode/cultistbarricade_start
	visibleDialogue = 0
	maxDistance = 1


/datum/dialogueNode

	cultistbarricade_start
		linkText = "..."
		links = list(/datum/dialogueNode/cultistbarricade_break)

		getNodeText(var/client/C)
			return "This appears to be a rapidly hacked together barricade with some sort of religious sigil attached to it, it feels easily breakable but doesn't budge."

	cultistbarricade_break
		linkText = "(Use the talisman on the empty slot.)"
		nodeText = "A slight glow fills the barricade before it entirely crumbles into dust."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/cult_sigil)) return 1
			else return 0

		onActivate(var/client/C)
			C.mob.drop_item()
			qdel()

/obj/dialogueobj/controlpc
	name = "barely intact lever"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "bustedmantapc"
	density = 1
	anchored = ANCHORED_ALWAYS
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/controlpc(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/controlpc
	dialogueName = "Voltage Control Terminal"
	start = /datum/dialogueNode/controlpc_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	controlpc_start
		linkText = "..."
		links = list(/datum/dialogueNode/controlpc_lv, /datum/dialogueNode/controlpc_hv)

		getNodeText(var/client/C)
			return {"A barely visible creature, swimming mist and void looms above, your mind aches even attempting to gaze at it. The emitters within the sand appear to suspend it in place with soundwaves almost piercing the glass. <br>
			This one piece of the control terminal barely survived the conflict around it, it looks like the amount of power going into the containment systems can be adjusted here, with the right key."}

	controlpc_lv
		linkText = "(Move the lever down to lower the voltage.)"
		nodeText = {"The creature, while not even directly visible clearly loosens its composure. A echo... a sound which could be graditude or unleashed wrath. Its simply too alien to determine. <br>
		a bead of some kind is knocked off it during its departure."}
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/control_key)) return 1
			else return 0

		onActivate(var/client/C)

	controlpc_hv
		linkText = "(Move the lever up to increase the voltage.)"
		nodeText = {"The water outside stirs with rage, like watching the world's largest kettle. With a pained wave of energy from the creature the emitters go dark, and the creature rapidly ascends. <br>
		The black scales from the process itch with vengeful life."}
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/control_key)) return 1
			else return 0

		onActivate(var/client/C)
