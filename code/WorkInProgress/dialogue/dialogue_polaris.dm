//Oh boy this is gonna be messy as fuck..//


//SYNDIE DIALOGUE//
/obj/dialogueobj/syndiecorpse1
	name = "syndicate corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndcorpse2"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/syndicatecorpse1(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/syndicatecorpse1
	dialogueName = "Syndicate agent corpse"
	start = /datum/dialogueNode/syndicatecorpse1_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	syndicatecorpse1_start
		linkText = "..."
		links = list(/datum/dialogueNode/syndicatecorpse1_scan)

		getNodeText(var/client/C)
			return "Another member of the syndicate, it seems. He looks like he has burn marks from laser fire on him. Strange."

	syndicatecorpse1_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "Forensic analysis shows significant scarring and burned tissue aswell as minor blunt trauma. Several internal organs seem to have been surgically removed from the subject, ceasing vital functions."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

/obj/dialogueobj/syndiecorpse2
	name = "syndicate agent corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndcorpse3"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/syndicatecorpse2(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/syndicatecorpse2
	dialogueName = "Syndicate agent corpse"
	start = /datum/dialogueNode/syndicatecorpse2_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	syndicatecorpse2_start
		linkText = "..."
		links = list(/datum/dialogueNode/syndicatecorpse1_scan)

		getNodeText(var/client/C)
			return "This is an eviscerated body. Dressed in the classy turtleneck of the fearsome syndicate. Seems like he met his end fighting here, he looks pretty mangled. Strangely he doesnt seem to be wearing a diving suit?"

/obj/dialogueobj/syndiecorpse7
	name = "syndicate infiltrator corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndcorpse7"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/syndicatecorpse7(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/syndicatecorpse7
	dialogueName = "Syndicate infiltrator corpse"
	start = /datum/dialogueNode/syndicatecorpse7_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	syndicatecorpse7_start
		linkText = "..."
		links = list(/datum/dialogueNode/syndicatecorpse7_scan)

		getNodeText(var/client/C)
			return "This looks like a syndicate infiltrator. You figure out that something must have happened to his cloaker as these guys are rarely caught out in the open."

	syndicatecorpse7_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "Subject has severe burn damage, numerous eviscerations and has suffered significant blood and fluid loss, and seems to have a large open laceration on the sternum, the eviscerations seem to be partially cauterized by an intense heat. Subject's internals are severely damaged or are entirely missing."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

/obj/dialogueobj/syndiecorpse8
	name = "syndicate pyro-specialist corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndcorpse8"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/syndicatecorpse8(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/syndicatecorpse8
	dialogueName = "Syndicate pyro-specialist corpse"
	start = /datum/dialogueNode/syndicatecorpse8_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	syndicatecorpse8_start
		linkText = "..."
		links = list(/datum/dialogueNode/syndicatecorpse8_scan,/datum/dialogueNode/syndicatecorpse8_takeitem)

		getNodeText(var/client/C)
			return "Seems like a syndicate pyro-specialist. The fire axe has scorch marks on it, like something clawed has gripped it. Arent these things supposed to be nearly fireproof?"

	syndicatecorpse8_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "(The Forensic Scanner beeps grumpily. The corpse is too mangled to gather any meaningful data but judging from the corpse, it's safe to say that the syndicate pyro-specialist got taste of his own medicine."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/machines/airlock_deny_temp.ogg', 50, 1,1)
			return

	syndicatecorpse8_takeitem
		linkText = "(Dig through the mangled remains.)"
		nodeText = "(You dig through the mangled remains. The stench of rotting flesh is overpowering, but from the depths of the syndicate members suit, you manage to find a still functioning incendiary grenade."
		links = list()
		var/taken = 0

		canShow(var/client/C)
			if(taken == 0) return 1
			else return 0

		onActivate(var/client/C)
			taken = 1
			C.mob.put_in_hand_or_drop(new/obj/item/chem_grenade/incendiary, C.mob.hand)
			return

/obj/dialogueobj/syndiecorpse11
	name = "syndicate marksman corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndcorpse11"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/syndicatecorpse11(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/syndicatecorpse11
	dialogueName = "Syndicate marskman corpse"
	start = /datum/dialogueNode/syndicatecorpse11_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	syndicatecorpse11_start
		linkText = "..."
		links = list(/datum/dialogueNode/syndicatecorpse11_scan,)

		getNodeText(var/client/C)
			return "Judging from the optics on the helmet, looks like a syndicate marksman. looks like she died with her back against the wall. Her body is completely shredded by something."

	syndicatecorpse11_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "(Subject's body is severely damaged beyond repair. Several wounds on the remaining tissue seem to be cauterized by high-heat. The subject's internal organs are missing.)"
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0


/obj/dialogueobj/syndiecorpse5
	name = "syndicate engineer corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndcorpse5"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/syndicatecorpse5(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/syndicatecorpse5
	dialogueName = "Syndicate engineer corpse"
	start = /datum/dialogueNode/syndicatecorpse5_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	syndicatecorpse5_start
		linkText = "..."
		links = list(/datum/dialogueNode/syndicatecorpse5_scan,)

		getNodeText(var/client/C)
			return "Seems like a syndicate engineer with standard gear, or atleast, half of one. Seems like he was running away from something when the airlock closed on him suddenly. Huh."

	syndicatecorpse5_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "(Subject's torso is completely dislocated from legs. Severe internal damage and bleeding from crushing force, Subject has significant 3rd degree burns on his back.)"
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

/obj/dialogueobj/syndiecorpse10
	name = "syndicate engineer corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndcorpse10"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/syndicatecorpse10(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/syndicatecorpse10
	dialogueName = "Syndicate engineer corpse"
	start = /datum/dialogueNode/syndicatecorpse10_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	syndicatecorpse10_start
		linkText = "..."
		links = list(/datum/dialogueNode/syndicatecorpse5_scan,)

		getNodeText(var/client/C)
			return "The uh... other half of the engineer. Grisly."

	syndicatecorpse5_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "(The Forensic Scanner beeps grumpily. The corpse is too mangled to gather any meaningful data from the corpse."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/machines/airlock_deny_temp.ogg', 50, 1,1)
			return


//SECURITY DIALOGUE//

/obj/dialogueobj/securitycorpse1
	name = "security officer"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "seccorpse1"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/securitycorpse1(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/securitycorpse1
	dialogueName = "Security officer corpse"
	start = /datum/dialogueNode/securitycorpse1_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	securitycorpse1_start
		linkText = "..."
		links = list(/datum/dialogueNode/securitycorpse1_scan)

		getNodeText(var/client/C)
			return "A standard NT security officer with a patch on the side stating he's a crewmen of the polaris. Looks like he got sucked out when the polaris started to take on water. He has some glass and metal embedded in him."

	securitycorpse1_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "Forensic analysis indicates significant blunt trauma with the presence of several foreign objects, including ferrite metals. Subject has started to bloat and is entering stages of decomposition."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

/obj/dialogueobj/securitycorpse2
	name = "security officer"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "seccorpse2"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/securitycorpse2(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/securitycorpse2
	dialogueName = "Security officer corpse"
	start = /datum/dialogueNode/securitycorpse2_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	securitycorpse2_start
		linkText = "..."
		links = list(/datum/dialogueNode/securitycorpse2_scan)

		getNodeText(var/client/C)
			return "Looks like what once was a NT security officer. The cut seems to be clean, guess someone snuck up on him while he was looking at that console or something?"

	securitycorpse2_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "Subject has several of its internal organs removed. Subject's head has been removed and is missing, the neck wound has partial burn tissue, suggesting exposure to high heat. Musculature of the body suggests that the subject was not anticipating the decapitation. "
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

/obj/dialogueobj/securitycorpse6
	name = "security officer"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "seccorpse6"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/securitycorpse6(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/securitycorpse6
	dialogueName = "Security officer corpse"
	start = /datum/dialogueNode/securitycorpse6_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	securitycorpse6_start
		linkText = "..."
		links = list(/datum/dialogueNode/securitycorpse6_scan)

		getNodeText(var/client/C)
			return "Yet another NT security officer aboard the NSS Polaris, similar to the others. His body looks, utterly  crushed as if something heavy fell on him... what the fuck...."

	securitycorpse6_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "Subject has extreme blunt trauma, indicating an object atleast his size has fallen on the subject, rupturing his organs and shattering his bones completely."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0


/obj/dialogueobj/securitycorpse3
	name = "security officer"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "seccorpse3"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/securitycorpse3(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/securitycorpse3
	dialogueName = "Security officer corpse"
	start = /datum/dialogueNode/securitycorpse3_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	securitycorpse3_start
		linkText = "..."
		links = list(/datum/dialogueNode/securitycorpse3_scan)

		getNodeText(var/client/C)
			return "Oh gods, it looks like he was slammed straight through a wall and thrown out of the ship by the crash. His head is... in bad shape."

	securitycorpse3_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "Subject has severe blunt force trauma on the back, and neck. Minor burns around the neck are also present. Subject's internal organs have been removed."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0


/obj/dialogueobj/securitycorpse7
	name = "head of security corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "seccorpse7"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/securitycorpse7(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/securitycorpse7
	dialogueName = "Head of Security Corpse"
	start = /datum/dialogueNode/securitycorpse7_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	securitycorpse7_start
		linkText = "..."
		links = list(/datum/dialogueNode/securitycorpse7_scan)

		getNodeText(var/client/C)
			return "This... was the head of security you guess... if you can call this mangled mess a man. Looks like his arm is completely gone. Atleast he kept his hat, so, minor victory for him.."

	securitycorpse7_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "Subject has extreme lacerations and disfigurements across the body. Major burnt tissue is also present all over the body. Subject's arm, Brain, and internal organs are missing. Bruising along the knees indicate he was moved post mortem."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

//SERGEANTS COMPUTER

/obj/dialogueobj/captainscomputer
	name = "captain's private computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "old_alt"
	density = 1
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/sergeantscomputer(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/sergeantscomputer
	dialogueName = "Sgt. Wilkins Private Computer"
	start = /datum/dialogueNode/sergeantscomputer_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	sergeantscomputer_start
		nodeText = ""
		linkText = @"[Return.]"
		links = list(/datum/dialogueNode/sergeantscomputer_log1,/datum/dialogueNode/sergeantscomputer_log2,/datum/dialogueNode/sergeantscomputer_log3,/datum/dialogueNode/sergeantscomputer_log4,/datum/dialogueNode/sergeantscomputer_log5)
		var/list/inputs = list() //Required in case multiple people are using this at the same time.

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			if(master.getFlag(C, "access") != "granted")
				var/X = input(C,"Please enter the password.","Sgt. Wilkins Private Computer","Password") as text
				if (X == "Icarus")
					master.setFlag(C, "access", "granted")
				return

		getNodeText(var/client/C)
			if(master.getFlag(C, "access") == "granted")
				return "Welcome back Sgt. Wilkins. Which log would you like to access?"
			else
				return "Incorrect password."

	sergeantscomputer_log1
		linkText = "Daily log of the NSS Polaris, Sept 1st 2053, 9:00 PM."
		nodeText = "After a long uneventful trip through space, finally we are entering the atmopshere of Abzu, course plotted to Oshan Laboratories. Unfortunately in the last month or so, all of our intel on the movement of the syndicate has been nearly dead silent making this trip aggrivating. Whole crew is on edge due to the threat of an enemy attack on our vessel, especially if they know what we're carrying in the damned hold. <br><br> So far syndicate presence on Abzu has been 'minimal' according to the reports but, I feel like we should still be on the ready for anything.."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "access") == "granted")  return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	sergeantscomputer_log2
		linkText = "Daily log of the NSS Polaris, Sept 4th 2053, 2:34 AM."
		nodeText = "Despite a rather uneventful trip so far on the surface of the ocean, the crew is more on edge than ever. Reports of strange 'Green lights' have been seen out the windows, deep down in the sea. Some say from the deep trench recesses. I'll not tolerate such superstitions as ghosts on my ship, and the crew morale doesnt need those kinds of rumours spreading around. Disciplinary action has been threatened to the crew."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "access") == "granted")  return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	sergeantscomputer_log3
		linkText = "Daily log of the NSS Polaris, Sept 4th 2053, 2:34 AM."
		nodeText = "Those damned green lights. I can tell the crew is talking about them behind my back. I've already had to issue pay cuts and a temporary relief of duty of two of our security officers. Unfortunately, that's the best news I have. I have seen the lights myself deep down in the trenches. They cut through like a lighthouse in a fog bank. At best, it could be some form of indigenous fauna. At worst, some kind of new syndicate drone or ship, waiting for us to descend.  <br><br> Thankfully we're only 2 days away from the Oshan laboratories. Can't wait to get back and get on leave for all this shit.further prevent discussion of the green 'phantoms' I've decided to close the ships frontal shutters temporarily so the crew won't grow more nervous."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "access") == "granted")  return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	sergeantscomputer_log4
		linkText = "Daily log of the NSS Polaris, Sept 5th 2053, 11:38 AM."
		nodeText = "The power spikes are off the charts, radar is saying they're picking up movement all over the place but none of the sensor readings match any known vessels or autonomous drones we've seen before. We've gone to full burn to get to Oshan laboratories as quickly as possible, ETA 6 hours, 28 minutes. I don't like this, it's giving me a bad feeling, I've prepared the crew for battle."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "access") == "granted")  return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	sergeantscomputer_log5
		linkText = "Daily log of the NSS Polaris, Sept 6th 2053, 2:58 AM."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "access") == "granted")  return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

		getNodeText(var/client/C)
			return @"We're so close, just 3 more hours away. NT Command will want to see these sensor logs, I can't believe what we're seeing. We've got some kind of bogey on our tail, we've established an at distance visual on the vessel b- as$34r^&    *#$!#$   1|]};my go4 5%43 #$%21       5;.$311e <br><br> <h3>[WARNING, SEVERE DATA CORRUPTION DUE TO AN UNEXPECTED POWER FAULT]</h3>"

//PLANT OF LOST HOPE
/obj/dialogueobj/plantoflosthope
	name = "just a plant"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plant"
	density = 1
	anchored = 2
	pixel_y = 12
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/plantoflosthope(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/plantoflosthope
	dialogueName = "Just a plant."
	start = /datum/dialogueNode/plantoflosthope_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	plantoflosthope_start
		linkText = "..."
		links = list(/datum/dialogueNode/plantoflosthope_one)

		getNodeText(var/client/C)
			if(master.getFlag(C, "testflag"))
				return "Once a thriving plant, now dead like everything else here."
			else
				return "You take a closer look at the plant, it looks rather out of place. Everything else is broken or dead in this place but yet this plant is thriving."


	plantoflosthope_one
		linkText = "Take a closer look at the plant."
		nodeText = "You are very quickly reminded about the reality of the situation on Abzu. It's an ancient cradle of many civilizations and entities, all now colliding as they scramble for their own corner on Abzu. There is nothing beautiful there, only hostility and imminent conflicts. You ought to remember that."
		links = list()


		canShow(var/client/C)
			if(master.getFlag(C, "testflag") == "itssetyep") return 0
			else return 1

		onActivate(var/client/C)
			master.master.icon_state = "plant_dead"
			master.setFlag(C, "testflag", "itssetyep")
			return
//HELMS COMPUTER
/obj/dialogueobj/bustedmantapc
	name = "broken computer"
	desc = "Yeaaah, it has certainly seen some better days."
	anchored = 2
	density = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "bustedmantapc"
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/bustedmantapc(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/bustedmantapc
	dialogueName = "Broken NSS Polaris control Panel"
	start = /datum/dialogueNode/bustedmantapc_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	bustedmantapc_start
		linkText = "..."
		links = list(/datum/dialogueNode/syndicatecorpse8_scan,/datum/dialogueNode/bustedmantapc_takeitem)

		getNodeText(var/client/C)
			return "This was once the panel that controlled the whole NSS Polaris but after the crash it has been rendered absolutely useless. Maybe you should try some tools on it?"

	bustedmantapc_takeitem
		linkText = "(Pry open the console frame)"
		nodeText = "(After a moment of prying open the broken control panels frame open, you reveal the flight recorder that was hidden inside of it."
		links = list()
		var/taken = 0

		canShow(var/client/C)
			if(taken == 0 && ispryingtool(C.mob.equipped())) return 1
			else return 0

		onActivate(var/client/C)
			taken = 1
			playsound(C.mob.loc, 'sound/items/Crowbar.ogg', 50, 1,1)
			C.mob.put_in_hand_or_drop(new/obj/item/blackbox, C.mob.hand)
			return

//ENGINEERING COMPUTER
/obj/dialogueobj/engineeringcomputer
	name = "engineering computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	density = 1
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/engineeringcomputer(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/engineeringcomputer
	dialogueName = "Engineering Computer"
	start = /datum/dialogueNode/engineeringcomputer_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode

	engineeringcomputer_start
		nodeText = ""
		linkText = @"[Return]"
		links = list(/datum/dialogueNode/engineeringcomputer_log1,/datum/dialogueNode/engineeringcomputer_log2,/datum/dialogueNode/engineeringcomputer_log3,/datum/dialogueNode/engineeringcomputer_log4)
		var/list/inputs = list() //Required in case multiple people are using this at the same time.

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			if(master.getFlag(C, "access") != "granted")
				var/X = input(C,"Please enter the password.","Engineering Computer","Password") as text
				if (X == "Congaline")
					master.setFlag(C, "access", "granted")
				return

		getNodeText(var/client/C)
			if(master.getFlag(C, "access") == "granted")
				return "Engineering computer access granted. Which log would you like to access?"
			else
				return "Incorrect password."

	engineeringcomputer_log1
		linkText = "Engineering log. Sept 3rd 2053 10:04 AM."
		nodeText = "We're preparing for atmospheric entry now, energy dampeners look good, power output from the TEG is good, everything seems nominal right now. Crew's still a bit on edge but, I think im gonna go grab a drink with a few of the secoffs later and ease the nerves, some threat of a syndicate assault or some shit."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "access") == "granted")  return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	engineeringcomputer_log2
		linkText = "Engineering log. Sept 4th 2053, 7:39 PM"
		nodeText = "Coulda just been my eyes but, I swore that I saw these lights in the ocean out the rear windows. It's probably just the stress getting to me. TEG energy is still good, pipe integrity is good ever since we had a small breach in one of the hot loop pipes but that has since been repaired by *yours truly*. Hope the rest of this trip uneventful. I hear Oshan has some nice R&R facilities on it. Might stay there for a few months if its alright with the higher-ups."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "access") == "granted")  return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	engineeringcomputer_log3
		linkText = "Engineering log. Sept 5th 2053 9:47 PM"
		nodeText = "The crew is up in arms, and I can't say I can blame them. The green lights, they look like they're multiplying. I've... I've seen shadows moving in the ocean. Didn't NT clear this shit beforehand? Maybe it's just some, big animal or something. Anyways Wilkins would kill me if he found out I was putting this in the logs. Power's still good but we've had strange minor fluctuations in the power grid, aswell as some minor console problems but nothing too major. Everything returned to operation after a short bit, so. No skin off my back."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "access") == "granted")  return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	engineeringcomputer_log4
		linkText = "Engineering log. Sept 6th 2053 1:30 AM."
		nodeText = " Something fucky is going on, we're reading a massive power drain from the grid, currently the TEG can keep up to keep our systems up, but it looks like there's a massive power drain placed on it, I've had the security officers search for a power sink but to no avail. What's even more scary is that the drain seems like its ramping *up* like someone's siphoning gas from a car or some shit. <br> <br> I estimate total power failure probably... in an hour. I've rerouted a bit of power to the emergency units just in case we need to set down but I have no idea if what's hitting our main systems can hit our backups. I'm just heaing alot of shouting from the main deck about a vessel. I hope its not the fucking syndicate. Just incase, if a NT officer retrieves these logs. <br><br> Tell my family what happened here. <br><br> Please.I beg of you."
		links = list()

		canShow(var/client/C)
			if(master.getFlag(C, "access") == "granted")  return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

//ENGINEER
/obj/dialogueobj/engineerscorpse
	name = "engineer's corpse"
	icon = 'icons/misc/hstation.dmi'
	icon_state = "body3"
	density = 0
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/engineerscorpse(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/engineerscorpse
	dialogueName = "Engineer's corpse"
	start = /datum/dialogueNode/engineerscorpse_start
	visibleDialogue = 0
	maxDistance = 1
	var/taken = 0


/datum/dialogueNode

	engineerscorpse_start
		linkText = "..."
		links = list(/datum/dialogueNode/engineerscorpse_scan,/datum/dialogueNode/engineerscorpse_takeitem)

		getNodeText(var/client/C)
			if(master.getFlag(C, "testflag") == "itssetyep")  return "Seems like he was a NT engineer. A patch on the shoulder signifies him being a crewman of the polaris. Looks like he's been dead for some time now."
			else return "Seems like he was a NT engineer. A patch on the shoulder signifies him being a crewman of the polaris. Looks like he's been dead for some time now. Seems like he has something stuffed in his pocket..."

	engineerscorpse_scan
		linkText = "(Use your Forensic Scanner to scan the body)"
		nodeText = "(The Forensic Scanner beeps grumpily. The corpse is too mangled to gather any meaningful data but judging from the corpse, it's safe to say that the syndicate pyro-specialist got taste of his own medicine."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/device/detective_scanner)) return 1
			else return 0

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/machines/airlock_deny_temp.ogg', 50, 1,1)
			return

	engineerscorpse_takeitem
		linkText = "(Search through the dead engineers pockets.)"
		nodeText = "(You dig through the engineers pockets and find a single note."
		links = list()
		var/taken = 0

		canShow(var/client/C)
			if(master.getFlag(C, "testflag") == "itssetyep")  return 0
			else return 1

		onActivate(var/client/C)
			master.setFlag(C, "testflag", "itssetyep")
			C.mob.put_in_hand_or_drop(new/obj/item/paper/manta_polarisengineernote, C.mob.hand)
			return

//THE CRATE
/obj/dialogueobj/polariscrate
	name = "important looking crate"
	desc = "So that's what NSS Polaris was delivering to Oshan Laboratory.. It looks important."
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "futurecrate"
	density = 1
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/polariscrate(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/polariscrate
	dialogueName = "Important looking crate"
	start = /datum/dialogueNode/polariscrate_start
	visibleDialogue = 0
	maxDistance = 1
	var/taken = 0


/datum/dialogueNode

	polariscrate_start
		linkText = "..."
		links = list(/datum/dialogueNode/polariscrate_open1)

		getNodeText(var/client/C)
			if(master.getFlag(C, "polariscrate") == "open")  return "The mysterious important looking crate that NSS Polaris was guarding has been opened and it contents have been ransacked. <br> <br> While the contents of the crate remain unknown to everyone but the highest of Nanotrasen officials, it is clear that they won't sit idly as Syndicate attempts to steal something so important to them. <br> <br> <b>Nanotrasen is ready to wage full war against the Syndicate, ready to eradicate the mysterious organization once and for all.</b>"
			else return "The mysterious crate in middle of the highly secure vault stands before you, the corpse of one-armed Head of Security close to it. Are you ready to see what is inside of it?"

	polariscrate_open1
		linkText = "(It is time to find out whats inside)"
		nodeText = "As you press the buttons on the crate, activating it's opening sequence, you can't help but wonder how many lives have been wasted in the pursuit of a singular crate. Many good men had given their lives to protect the contents of this very crate. Does it hold the key to immortality? To true machine sentience? A map of all existance? DNA of the first changeling?"
		links = list(/datum/dialogueNode/polariscrate_open2)

		canShow(var/client/C)
			if(master.getFlag(C, "polariscrate") == "open")  return 0
			else return 1

		onActivate(var/client/C)
			flick("futurecrateopen",master.master)
			playsound(C.mob.loc, 'sound/effects/polaris_crateopening.ogg', 50, 1,1)
			master.master.icon_state = "futurecrateopened"
			return

	polariscrate_open2
		linkText = "(Enough is enough. It's time.)"
		nodeText = "After a long moment of anticipation, it turns out that the crate is completely empty. Whoever who had entered the vault before you has managed to get away with whatever was inside this crate. Whatever it was, you can't help but feel that it was something very, very important. You're not quite sure why, but you feel like things won't ever be the same."
		links = list()

		onActivate(var/client/C)
			master.setFlag(C, "polariscrate", "open")
			C.mob.unlock_medal("Old Enemy", 1)
			return
