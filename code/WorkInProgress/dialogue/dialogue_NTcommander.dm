//MOB HIMSELF

/obj/dialogueobj/ntrepresentative
	name = "NT Representative"
	icon = 'icons/misc/factionreps.dmi'
	icon_state = "ntcommander"
	density = 1
	anchored = ANCHORED_ALWAYS
	layer = OBJ_LAYER + 0.1
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/nt_faction(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/nt_faction
	dialogueName = "NT Representative"
	start = /datum/dialogueNode/nt_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode
	nt_start
		nodeImage = "ntportrait.png"
		linkText = "..." //Because we use the first node as a "go back" link as well.
		links = list(/datum/dialogueNode/nt_who,/datum/dialogueNode/nt_reputation,/datum/dialogueNode/nt_rewards,/datum/dialogueNode/nt_standing,/datum/dialogueNode/nt_item,/datum/dialogueNode/nt_itemdebug )
		var/lastComplaint = 0

		getNodeText(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			var/rank = C.reputations.get_Nanotrasen_rank_string("nt")
			switch(rep)
				if(0)
					return "Hello [C.mob.name]. What business do you have with me?"
				if(-3 to -1)
					return "And what do you want?"
				if(-6 to -4)
					return "What do you want, you darn traitor?"
				if(1 to 3)
					return "Good to see you [rank] [C.mob.name]!"
				if(4 to 6)
					return "Hope you're having an excellent day [rank] [C.mob.name]!"
			return ""

	nt_who
		nodeImage = "ntportrait.png"
		linkText = "Who are you?"
		nodeText = "I am Commander Wardson. I've been sent here to investigate the NSS Polaris incident. Do you by any chance have information regarding that?"
		links = list()

	nt_reputation
		nodeImage = "ntportrait.png"
		linkText = "How can I improve my standing with you?"
		nodeText = "I would encourage you to dispose of any threats to the station you might find. Especially those darn syndicate members and their blasted drones. Bring me back proof and I will reward you accordingly."
		links = list()

	nt_standing
		nodeImage = "ntportrait.png"
		linkText = "What is my current standing with you?"
		links = list()

		getNodeText(var/client/C)
			var/rep = C.reputations.get_reputation_string("nt")
			return "Your current standing with Nanotrasen is [rep]."

	nt_rewards
		nodeImage = "ntportrait.png"
		linkText = "Let me see the available rewards, please."
		nodeText = "Alright, here's what I have to offer for your current standing with Nanotrasen.."
		links = list(/datum/dialogueNode/nt_reward_a,/datum/dialogueNode/nt_reward_b,/datum/dialogueNode/nt_reward_c,/datum/dialogueNode/nt_reward_d,/datum/dialogueNode/nt_reward_e,/datum/dialogueNode/nt_reward_f,/datum/dialogueNode/nt_reward_g,/datum/dialogueNode/nt_reward_h,/datum/dialogueNode/nt_reward_i)

	nt_reward_a
		nodeImage = "ntportrait.png"
		linkText = "Blank Nanotrasen ID"
		nodeText = "Sure thing, here you go."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "card_reward") == "taken" || rep < 1 ) return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "card_reward", "taken")
			C.mob.put_in_hand_or_drop(new/obj/item/card/id/blank_polaris, C.mob.hand)
			return

	nt_reward_b
		nodeImage = "ntportrait.png"
		linkText = "Seaman's uniform"
		nodeText = "Sure thing, here you go."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "seaman_reward") == "taken" || rep < 1 ) return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "seaman_reward", "taken")
			C.mob.put_in_hand_or_drop(new/obj/item/clothing/under/gimmick/seaman, C.mob.hand)
			return

	nt_reward_c
		nodeImage = "ntportrait.png"
		linkText = "Seaman's cap"
		nodeText = "Sure thing, here you go."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "seamancap_reward") == "taken" || rep < 1 ) return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "seamancap_reward", "taken")
			C.mob.put_in_hand_or_drop(new/obj/item/clothing/head/seaman, C.mob.hand)
			return

	nt_reward_d
		nodeImage = "ntportrait.png"
		linkText = "Cadet's uniform"
		nodeText = "Sure thing, here you go."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "cadet_reward") == "taken" || rep < 2 ) return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "cadet_reward", "taken")
			C.mob.put_in_hand_or_drop(new/obj/item/clothing/under/gimmick/cadet, C.mob.hand)
			return

	nt_reward_e
		nodeImage = "ntportrait.png"
		linkText = "Lieutenant's uniform"
		nodeText = "Sure thing, here you go."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "lieutenant_reward") == "taken" || rep < 3 ) return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "lieutenant_reward", "taken")
			C.mob.put_in_hand_or_drop(new/obj/item/clothing/under/gimmick/lieutenant, C.mob.hand)
			return

	nt_reward_f
		nodeImage = "ntportrait.png"
		linkText = "Officer's uniform"
		nodeText = "Sure thing, here you go."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "officer_reward") == "taken" || rep < 4 ) return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "officer_reward", "taken")
			C.mob.put_in_hand_or_drop(new/obj/item/clothing/under/gimmick/officer, C.mob.hand)
			return

	nt_reward_g
		nodeImage = "ntportrait.png"
		linkText = "Officer's cap"
		nodeText = "Sure thing, here you go."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "officercap_reward") == "taken" || rep < 4 ) return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "officercap_reward", "taken")
			C.mob.put_in_hand_or_drop(new/obj/item/clothing/head/officer, C.mob.hand)
			return

	nt_reward_h
		nodeImage = "ntportrait.png"
		linkText = "Nanotrasen Bodyguard Armor"
		nodeText = "Sure thing, here you go."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "bodyguard_reward") == "taken" || rep < 5 ) return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "bodyguard_reward", "taken")
			C.mob.put_in_hand_or_drop(new/obj/item/clothing/suit/armor/nanotrasen, C.mob.hand)
			return

	nt_reward_i
		nodeImage = "ntportrait.png"
		linkText = "Chief Officer's uniform"
		nodeText = "Sure thing, here you go."
		links = list()

		canShow(var/client/C)
			var/rep = C.reputations.get_reputation_level("nt")
			if(master.getFlag(C, "chiefofficer_reward") == "taken" || rep < 6 ) return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "chiefofficer_reward", "taken")
			C.mob.put_in_hand_or_drop(new/obj/item/clothing/under/gimmick/chiefofficer, C.mob.hand)
			return

	nt_item
		nodeImage = "ntportrait.png"
		linkText = "I actually have something interesting.."
		links = list(/datum/dialogueNode/nt_itemtake)

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/factionrep/ntboard)) return 1
			if(istype(C.mob.equipped(), /obj/item/blackbox)) return 1
			else return 0

		getNodeText(var/client/C)
			var/rank = C.reputations.get_Nanotrasen_rank_string("nt")
			return "Excellent work, [rank] [C.mob.name]! You'll do Nanotrasen proud. Now hand it over and I will make sure you will be rewarded accordingly."


	nt_itemdebug
		nodeImage = "ntportrait.png"
		linkText = "I actually have something interesting.."
		links = list(/datum/dialogueNode/nt_itemtakedebug)

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/factionrep/ntboarddebug)) return 1
			else return 0

		getNodeText(var/client/C)
			var/rank = C.reputations.get_Nanotrasen_rank_string("nt")
			return "Excellent work, [rank] [C.mob.name]! You'll do Nanotrasen proud. Now hand it over and I will make sure you will be rewarded accordingly."

	nt_itemtake
		nodeImage = "ntportrait.png"
		linkText = "Alright, here you go."
		nodeText = ""
		links = list()

		getNodeText(var/client/C)
			var/rank = C.reputations.get_Nanotrasen_rank_string("nt")
			return "� will make sure that Nanotrasen will remember your name, [rank] [C.mob.name]."

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/factionrep/ntboard)) return 1
			if(istype(C.mob.equipped(), /obj/item/blackbox)) return 1
			else return 0

		onActivate(var/client/C)
			qdel(C.mob.equipped())
			C.reputations.set_reputation(id = "nt",amt = 50,absolute = 0)
			boutput(C.mob, SPAN_SUCCESS("Your standing with Nanotrasen has increased by 50!"))
			return

	nt_itemtakedebug
		nodeImage = "ntportrait.png"
		linkText = "Alright, here you go."
		nodeText = ""
		links = list()

		getNodeText(var/client/C)
			var/rank = C.reputations.get_Nanotrasen_rank_string("nt")
			return "� will make sure that Nanotrasen will remember your name, [rank] [C.mob.name]."

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/factionrep/ntboarddebug)) return 1
			else return 0

		onActivate(var/client/C)
			qdel(C.mob.equipped())
			C.reputations.set_reputation(id = "nt",amt = 10000,absolute = 0)
			boutput(C.mob, SPAN_SUCCESS("Your standing with Nanotrasen has increased by 10000!"))
			return



/obj/item/factionrep/ntboard
	name = "syndicate circuit board"
	desc = "Rather complex circuit board, ripped straight from a syndicate drone's internal mechanism. Maybe someone would be interested in this?"
	icon = 'icons/misc/factionrewards.dmi'
	icon_state = "droneboard2"
	event_handler_flags = IMMUNE_OCEAN_PUSH | USE_FLUID_ENTER

/obj/item/factionrep/ntboarddebug
	name = "syndicate circuit board"
	desc = "Rather complex circuit board, ripped straight from a syndicate drone's internal mechanism. Maybe someone would be interested in this?"
	icon = 'icons/misc/factionrewards.dmi'
	icon_state = "droneboard2"
	event_handler_flags = IMMUNE_OCEAN_PUSH | USE_FLUID_ENTER

/obj/item/factionrep/ntboardfried
	name = "fried syndicate circuit board"
	desc = "This illegal-looking circuit board is fried. Looks like it was overloaded somehow, rendering it useless."
	icon = 'icons/misc/factionrewards.dmi'
	icon_state = "droneboard2fried"
	event_handler_flags = IMMUNE_OCEAN_PUSH

/obj/item/clothing/under/gimmick/seaman
	name = "seaman's uniform"
	desc = "Official seaman's uniform of Nanotrasen's naval branch."
	icon = 'icons/obj/clothing/uniforms/item_js_reward.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_reward.dmi'
	icon_state = "seaman"
	item_state = "seaman"

/obj/item/clothing/under/gimmick/cadet
	name = "cadet's uniform"
	desc = "Official cadet's uniform of Nanotrasen's naval branch."
	icon = 'icons/obj/clothing/uniforms/item_js_reward.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_reward.dmi'
	icon_state = "cadet"
	item_state = "cadet"

/obj/item/clothing/under/gimmick/lieutenant
	name = "lieutenant's uniform"
	desc = "Official lieutenant's uniform of Nanotrasen's naval branch."
	icon = 'icons/obj/clothing/uniforms/item_js_reward.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_reward.dmi'
	icon_state = "lieutenant"
	item_state = "lieutenant"

/obj/item/clothing/under/gimmick/officer
	name = "officer's uniform"
	desc = "Officers uniform of Nanotrasen's naval branch."
	icon = 'icons/obj/clothing/uniforms/item_js_reward.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_reward.dmi'
	icon_state = "officer"
	item_state = "officer"

/obj/item/clothing/under/gimmick/chiefofficer
	name = "chief officer's uniform"
	desc = "Uniform awarded to the highest ranking Nanotrasen naval officers."
	icon = 'icons/obj/clothing/uniforms/item_js_reward.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_reward.dmi'
	icon_state = "chiefofficer"
	item_state = "chiefofficer"

/obj/item/clothing/head/seaman
	name = "seaman's peaked cap"
	desc = "A service cap, to go with the seaman's uniform of Nanotrasen's naval branch. Snazzy!"
	icon_state = "nt1"
	item_state = "nt1"

/obj/item/clothing/head/officer
	name = "officer's peaked cap"
	desc = "A service cap, to go with the officer's uniform of Nanotrasen's naval branch. Looking sharp, chief!"
	icon_state = "nt2"
	item_state = "nt2"

/obj/item/clothing/suit/armor/nanotrasen
	name = "Nanotrasen Bodyguard Armor"
	icon_state = "nt2armor"
	item_state = "nt2armor"
	desc = "Heavy armor used by certain Nanotrasen bodyguards."


	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)
