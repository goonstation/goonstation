/obj/dialogueobj/keyhole
	name = "key panel"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "keypad"
	density = 0
	desc = "A device built straight into the wall. It looks like there is six slots for somekind of keys?"
	anchored = ANCHORED_ALWAYS
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/keypanel(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/keypanel
	dialogueName = "Key panel"
	start = /datum/dialogueNode/keypanel_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	keypanel_start
		linkText = "..."
		links = list()

		getNodeText(var/client/C)
			return "You take a closer look at the key panel, it looks like there is six seperate slots for what you presume is keys. <br> The vault itself is an ominous, dimly lit superstructure hidden somewhere in NSS Manta's hull. Why would the ship need a secret vault like this? <br>You can't help but wonder what it might have inside it."
