// Fake decal objects cause for some reason the writing defaults
/obj/fakeobject/pentagram
	name = "scrawled pentagram"
	icon = 'icons/obj/decals/writing.dmi'
	icon_state = "cPentacle"
	color = "#880808"

/obj/fakeobject/ritual_symbol
	name = "ritualistic engraving"
	icon = 'icons/obj/ritual_writing.dmi'
	icon_state = "" // should go to anchor
	color = "#880808"

/atom/movable/mysterious_beast
	name = "???"
	desc = "Whatever that is, its alive."
	icon = 'icons/misc/384x384.dmi'
	icon_state = "little_seamonster"
	plane = PLANE_ABOVE_FOREGROUND_PARALLAX
	anchored = TRUE
	mouse_opacity = FALSE

	New()
		..()
		src.alpha = 0
		animate(src, 10 SECONDS, alpha = 255)
		animate_wave(src)

	EnteredProximity()
		for(var/mob/living/M in oview(300))
			M.addOverlayComposition(/datum/overlayComposition/insanity)
			M.updateOverlaysClient(M.client)
			boutput(M, pick("<font color=purple><b>The reality around you fades out..</b></font>","<font color=purple><b>Suddenly your mind feels extremely frail and vulnerable..</b></font>","<font color=purple><b>Your sanity starts to fail you...</b></font>"))
			playsound(M, 'sound/ambience/spooky/Void_Song.ogg', 50, TRUE)
			SPAWN(62 SECONDS)
				M.removeOverlayComposition(/datum/overlayComposition/insanity)
				M.updateOverlaysClient(M.client)

// Cult base dialogue or items only used in dialogue
/obj/item/cult_sigil
	name = "green seal"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "sigil_pt2"
	w_class = W_CLASS_SMALL
	desc = "A green wax mold, it appears to already have a indent inside it."
	var/pt1 = FALSE

	complete // Nothingburger used for the dialogue box

	attackby(obj/item/W, mob/user, params)
		. = ..()
		if (istype(W, /obj/item/cult_sigil_pt1))
			var/obj/item/cult_sigil_pt1/C = W
			boutput(user, "The talisman settles onto the seal.")
			pt1 = TRUE
			src.UpdateOverlays(image('icons/obj/decoration.dmi', "sigil_pt2"), "sigil_pt1")
			if (C.pt3)
				boutput(user, "The eye fits in the slot on the talisman, completing the sigil!")
				qdel(C)
				var/obj/item/cult_sigil/complete/sigil = new /obj/item/cult_sigil/complete
				sigil.name = "improvised talisman"
				sigil.icon = 'icons/obj/decoration.dmi'
				sigil.icon_state = "sigil_key"
				sigil.desc = "A rag-tag sigil stitched together, it might fit in that seal now."
				user.put_in_hand_or_drop(sigil)
				qdel(src)
			qdel(C)

		if (istype(W, /obj/item/cult_sigil_pt3))
			var/obj/item/cult_sigil_pt3/C = W
			if (!pt1)
				boutput(user, "The eye seems drawn to the seal, but lacks a physical way to keep it on.")
			else
				boutput(user, "The eye fits in the slot on the talisman, completing the sigil!")
				qdel(C)
				var/obj/item/cult_sigil/complete/sigil = new /obj/item/cult_sigil/complete
				sigil.name = "improvised talisman"
				sigil.icon = 'icons/obj/decoration.dmi'
				sigil.icon_state = "sigil_key"
				sigil.desc = "A rag-tag sigil stitched together, it might fit in that seal now."
				user.put_in_hand_or_drop(sigil)
				qdel(src)

/obj/item/cult_sigil_pt1
	name = "golden pattern"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "sigil_pt1"
	w_class = W_CLASS_SMALL
	desc = "A golden handheld construct with the sigil of the deep, similar to a cross in conventional religions."
	var/pt3 = FALSE

	attackby(obj/item/W, mob/user, params)
		. = ..()
		if (istype(W, /obj/item/cult_sigil))
			var/obj/item/cult_sigil/C = W
			boutput(user, "The talisman settles onto the seal.")
			C.pt1 = TRUE
			C.UpdateOverlays(image('icons/obj/decoration.dmi', "sigil_pt1"), "sigil_pt2")
			qdel()

		if (istype(W, /obj/item/cult_sigil_pt3))
			boutput(user, "The eye fits in the slot on the talisman.")
			src.pt3 = TRUE
			src.UpdateOverlays(image('icons/obj/decoration.dmi', "sigil_pt3-o"), "sigil_pt1")
			qdel(W)

// /obj/item/cult_sigil_pt2
// 	name = "green seal"
// 	icon = 'icons/obj/decoration.dmi'
// 	icon_state = "sigil_pt2"
// 	w_class = W_CLASS_SMALL
// 	desc = "A green wax mold, it appears to already have a indent inside it."
// 	var/pt1 = FALSE
// 	var/pt3 = FALSE

// 	attackby(obj/item/W, mob/user, params)
// 		. = ..()
// 		if (istype(W, /obj/item/cult_sigil_pt1))
// 			var/obj/item/cult_sigil_pt1/C = W
// 			boutput(user, "The talisman settles onto the seal.")
// 			pt1 = TRUE
// 			icon_state = "sigil_pt1-2"
// 			if (C.pt3)
// 				boutput(user, "With the eye in the talisman, the sigil is complete!")
// 				/var/obj/item/cult_sigil/sigil = new /obj/item/cult_sigil
// 				user.put_in_hand_or_drop(sigil)
// 				qdel()
// 			qdel(W)

// 		if (istype(W, /obj/item/cult_sigil_pt3))
// 			var/obj/item/cult_sigil_pt3/C = W
// 			if (!pt1)
// 				boutput(user, "The eye seems drawn to the seal, but lacks a physical way to keep it on.")
// 			else
// 				boutput(user, "The eye fits in the slot on the talisman, completing the sigil!")
// 				src.pt3 = TRUE
// 				qdel(C)
// 				/var/obj/item/cult_sigil/L = new /obj/item/cult_sigil
// 				user.put_in_hand_or_drop(sigil)
// 				qdel()

/obj/item/cult_sigil_pt3
	name = "odd crystal"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "sigil_pt3"
	w_class = W_CLASS_SMALL
	desc = "A purple crystal, it appears to gaze at you like a eye."

	attackby(obj/item/W, mob/user, params)
		. = ..()
		if (istype(W, /obj/item/cult_sigil_pt1))
			var/obj/item/cult_sigil_pt1/C = W
			boutput(user, "The eye fits in the slot on the talisman.")
			C.pt3 = TRUE
			C.UpdateOverlays(image('icons/obj/decoration.dmi', "sigil_pt3-o"), "sigil_pt1")
			qdel(W)
			qdel(src)
		if (istype(W, /obj/item/cult_sigil))
			var/obj/item/cult_sigil/C = W
			if (!C.pt1)
				boutput(user, "The eye seems drawn to the seal, but lacks a physical way to keep it on.")
			else
				boutput(user, "The eye fits in the slot on the talisman, completing the sigil!")
				qdel(C)
				var/obj/item/cult_sigil/complete/sigil = new /obj/item/cult_sigil/complete
				sigil.name = "improvised talisman"
				sigil.icon = 'icons/obj/decoration.dmi'
				sigil.icon_state = "sigil_key"
				sigil.desc = "A rag-tag sigil stitched together, it might fit in that seal now."
				user.put_in_hand_or_drop(sigil)
				qdel(src)

/obj/item/control_key
	name = "voltage control safety key"
	icon = 'icons/obj/artifacts/keys.dmi'
	icon_state = "key_round"
	w_class = W_CLASS_SMALL
	desc = "It has Voltage Control written on the handle."

/obj/item/totally_just_a_backscratcher
	name = "overqualified backscratcher"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "backscratcher"
	desc = "A something... It could sure scratch a itch on someone's back though."
	force = 10

	attackby(obj/item/W, mob/user, params)
		. = ..()
		if (istype(W, /obj/item/siren_orb))
			var/obj/item/siren_orb/C = W
			var/obj/item/gun/energy/resonator/G = new /obj/item/gun/energy/resonator
			boutput(user, "The orb begins to hover in place in the prongs of the device, before the whole item crackles to life with energy.")
			user.put_in_hand_or_drop(G)
			qdel(C)
			qdel(src)

/obj/item/siren_orb
	name = "soothing orb"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "siren_orb"
	desc = "An orb which is the byproduct of released pain, it could probably power the right technology."

/obj/dialogueobj/cultistcorpse_1
	name = "fanatical corpse"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "cultistcorpse"
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
	maxDistance = -1 // Cause they have to delete themselves, doubt it'll be a problem... right?


/datum/dialogueNode

	cultistbarricade_start
		linkText = "..."
		links = list(/datum/dialogueNode/cultistbarricade_break, /datum/dialogueNode/cultistbarricade_revelation)

		getNodeText(var/client/C)
			return "This appears to be a rapidly hacked together barricade with some sort of religious sigil attached to it, it feels easily breakable but doesn't budge."

	cultistbarricade_break
		linkText = "(Use the talisman on the empty slot.)"
		nodeText = "A slight glow fills the barricade before it entirely crumbles into dust."
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/cult_sigil/complete)) return 1
			else return 0

		onActivate(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/cult_sigil/complete))
				qdel(C.mob.equipped())
			qdel(src) // pretty sure all of these are needed for cleanup
			qdel(src.master)
			qdel(src.master.master)

	cultistbarricade_revelation
		linkText = "(Use your faith to examine the seal.)"
		nodeText = "This jury rigged seal appears to have been made of three seperate pieces. Estimating their significance, you'd assume these would be held on someone's person."
		links = list()

		canShow(var/client/C)
			if(C.mob.traitHolder.hasTrait("training_chaplain")) return 1
			else return 0

/obj/dialogueobj/controlpc
	name = "barely intact lever"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "bustedmantapc"
	density = 1
	anchored = ANCHORED_ALWAYS
	var/datum/dialogueMaster/dialogue = null
	var/cutoff = FALSE

	New()
		dialogue = new/datum/dialogueMaster/controlpc(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

	proc/lever_hv(mob/user)
		cutoff = TRUE
		for(var/obj/decoration/ritual/R in(range(7))) // any better ideas I'm all ears
			for(var/obj/fakeobject/catalytic_doodad/C in (range(11)))
				arcFlashTurf(C, R.loc, 50, 50)
			new /mob/living/critter/void_scale(R.loc)
		for(var/atom/movable/mysterious_beast/B in (range(7)))
			qdel(B)
		shake_camera(user, 5, 16)
		random_brute_damage(user, 3)
		user.changeStatus("knockdown", 1 SECOND)
		var/obj/decoration/bustedmantapc/D = new /obj/decoration/bustedmantapc(src.loc) // Swapping it out so people can't double dip
		D.dir = 4
		playsound(user, 'sound/effects/seamonster/beats/boom1.ogg', 50, TRUE)
		playsound(user, 'sound/effects/seamonster/whale1.ogg', 50, TRUE)
		for(var/mob/living/carbon/human/H in (range(5)))
			if(H.mind)
				user.unlock_medal("Waking Nightmare", TRUE)
		qdel(src)

	proc/lever_lv(mob/user)
		cutoff = TRUE
		for(var/obj/decoration/ritual/R in(range(7)))
			new /obj/item/siren_orb(R.loc)
		for(var/atom/movable/mysterious_beast/B in (range(7)))
			qdel(B)
		for(var/obj/fakeobject/catalytic_doodad/C in (range(11)))
			animate_little_spark(C)
		shake_camera(user, 4, 4)
		var/obj/decoration/bustedmantapc/D = new /obj/decoration/bustedmantapc(src.loc) // Swapping it out so people can't double dip
		D.dir = 4
		playsound(user, 'sound/effects/seamonster/beats/boom1.ogg', 50, TRUE)
		playsound(user, 'sound/effects/seamonster/whale1.ogg', 50, TRUE)
		for(var/mob/living/carbon/human/H in (range(5)))
			if(H.mind)
				user.unlock_medal("Waking Dream", TRUE)
		qdel(src)

/datum/dialogueMaster/controlpc
	dialogueName = "Voltage Control Terminal"
	start = /datum/dialogueNode/controlpc_start
	visibleDialogue = 0
	maxDistance = -1 // Cause they have to delete themselves, doubt it'll be a problem... right?

	showDialogue()
		var/obj/dialogueobj/controlpc/PC = src.master
		if(PC.cutoff)
			return
		else
			..()

/datum/dialogueNode

	controlpc_start
		linkText = "..."
		links = list(/datum/dialogueNode/controlpc_lv, /datum/dialogueNode/controlpc_hv, /datum/dialogueNode/controlpc_diagnose)

		getNodeText(var/client/C)
			return {"A barely visible creature, swimming mist and void looms above, your mind aches even attempting to gaze at it. The emitters within the sand appear to suspend it in place with soundwaves almost piercing the glass. <br>
			This one piece of the control terminal barely survived the conflict around it, it looks like the amount of power going into the containment systems can be adjusted here, with the right key."}

	controlpc_lv
		linkText = "(Move the lever down to lower the voltage.)"
		nodeText = {"The creature, while not even directly visible clearly loosens its composure. A echo... a sound which could be graditude or unleashed wrath. Its simply too alien to determine. <br>
		A bead of some kind is knocked off it during its departure."}
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/control_key)) return 1
			else return 0

		onActivate(var/client/C)
			var/obj/dialogueobj/controlpc/M = new /obj/dialogueobj/controlpc
			M.lever_lv(C.mob)
			qdel(src) // pretty sure all of these are needed for cleanup
			qdel(src.master)
			qdel(src.master.master)

	controlpc_hv
		linkText = "(Move the lever up to increase the voltage.)"
		nodeText = {"The water outside stirs with rage, like watching the world's largest kettle. With a pained wave of energy from the creature the emitters go dark, and the creature rapidly ascends. <br>
		A black scale falling from the process itches with vengeful life."}
		links = list()

		canShow(var/client/C)
			if(istype(C.mob.equipped(), /obj/item/control_key)) return 1
			else return 0

		onActivate(var/client/C)
			var/obj/dialogueobj/controlpc/M = new /obj/dialogueobj/controlpc
			M.lever_hv(C.mob)
			qdel(src) // pretty sure all of these are needed for cleanup
			qdel(src.master)
			qdel(src.master.master)

	controlpc_diagnose
		linkText = "(Expertly examine the damage.)"
		nodeText = {"This lever system appears to have been hit with gunfire, and while the wiring is heavily damaged to the lever, the overall containment system its connected to is fine. <br>
		You'd guess you'd have only one shot with the lever if you get the key for it."}
		links = list()

		canShow(var/client/C)
			if(C.mob.traitHolder.hasTrait("training_engineer")) return 1
			else return 0
