// Antagonifiers
/obj/traitorifier
	//var/allowAntagStacking = 0 // If set to 1, permits people to use multiple traitorifier types TODO: Figure out how to make this work intelligently
	name = "An Offer You Couldn't Refuse"
	desc = "In this economy you'd be stupid to turn this down."
	anchored = ANCHORED
	icon = 'icons/obj/items/pda.dmi'
	icon_state = "pda-s"
	var/attachedObjective = "For the free market!"
	var/uses = -1 // -1 for infinite uses

	attack_hand(mob/M)
		if (issilicon(M))
			boutput(M, "Silly robot.")
			return

		if (M?.mind && !M.mind.special_role)
			new /datum/objective(attachedObjective, M.mind)
			makeAntag(M)
			uses--
			if (uses == 0)
				qdel(src)

	proc/makeAntag(mob/M as mob)
		M.show_text("<h2>[SPAN_ALERT("<B>You have defected and become a traitor!</B>")]</h2>", "red")
		M.mind.add_antagonist(ROLE_TRAITOR)

/obj/traitorifier/wizard
	name = "Eldritch Altar"
	desc = "Phenomenal cosmic power and groovy facial hair."
	attachedObjective = "You're a wizard, you don't need reasons."
	icon = 'icons/misc/halloween.dmi'
	icon_state = "tombstone"

	makeAntag(mob/M as mob)
		M.show_text("<h2>[SPAN_ALERT("<B>You have been seduced by magic and become a wizard!</B>")]</h2>", "red")
		M.mind.add_antagonist(ROLE_WIZARD, do_relocate = FALSE)

/obj/traitorifier/changeling
	name = "Fleshy Protuberance"
	desc = "Join ussssssss"
	attachedObjective = "EAT"
	icon = 'icons/misc/meatland.dmi'
	icon_state = "ganglion0"

	makeAntag(mob/M as mob)
		M.show_text("<h2>[SPAN_ALERT("<B>You have mutated into a changeling!</B>")]</h2>", "red")
		M.mind.add_antagonist(ROLE_CHANGELING)

/obj/traitorifier/vampire
	name = "Fang-Marked Coffin"
	desc = "The children of the night make such beautiful music."
	attachedObjective = "Convert an army of minions, wear a cloak, say 'bluh' a lot."
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "coffin"
	color = "#FF0000"

	makeAntag(mob/M as mob)
		M.show_text("<h2>[SPAN_ALERT("<B>You have joined the ranks of the undead and are now a vampire!</B>")]</h2>", "red")
		M.mind.add_antagonist(ROLE_VAMPIRE)

/obj/traitorifier/wrestler
	name = "VERY Haunted Championship Belt"
	desc = "You feel more awesome just looking at this thing."
	attachedObjective = "Climb to the top of the mountain!"
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "machobelt"

	makeAntag(mob/M as mob)
		M.show_text("<h2>[SPAN_ALERT("<B>You feel an urgent need to wrestle!</B>")]</h2>", "red")
		M.mind.add_antagonist(ROLE_WRESTLER)

/obj/traitorifier/hunter
	name = "Ferocious Alien Skull"
	desc = "Fancy a game?"
	attachedObjective = "Blood, blood, blood!"
	icon = 'icons/obj/items/organs/skull.dmi'
	icon_state = "skullP"
	color = "#FF0000"

	makeAntag(mob/M as mob)
		M.mind?.add_antagonist(ROLE_HUNTER)

/obj/traitorifier/werewolf
	name = "Shadowy Dog Thing"
	desc = "Awooo?"
	attachedObjective = "Awoooooooooo"
	icon = 'icons/misc/critter.dmi'
	icon_state = "george"
	color = "#000000"

	makeAntag(mob/M as mob)
		M.show_text("<h2>[SPAN_ALERT("<B>You have become a werewolf!</B>")]</h2>", "red")
		M.mind?.add_antagonist(ROLE_WEREWOLF)

/obj/traitorifier/omnitraitor
	name = "Ugly Amalgamation"
	desc = "For the person who wants everything."
	attachedObjective = "Try not to kill yourself with your own power."
	icon = 'icons/effects/fire.dmi'
	icon_state = "1old"

	makeAntag(mob/M as mob)
		M.mind.add_antagonist(ROLE_OMNITRAITOR)

/obj/traitorifier/wraith
	name = "Spooky Pool"
	desc = "The void calls."
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "fissure"
	attachedObjective = "Make them suffer."

	makeAntag(mob/M as mob)
		M.mind?.add_antagonist(ROLE_WRAITH)

/obj/traitorifier/blob
	name = "Viscous Puddle"
	desc = "This does not look refreshing."
	icon = 'icons/mob/blob.dmi'
	icon_state = "0"
	color = "#44FF44"
	attachedObjective = "GET FAT"

	makeAntag(mob/M as mob)
		M.mind?.add_antagonist(ROLE_BLOB)



/obj/traitorifier/virtual
	name = "SYNDIC~1.EXE"
	desc = "Self-extracting archive containing some sweet Syndicate stuff!"
	var/in_use = 0

	//People keep blowing up the murderbox
	ex_act(severity)
		return

	meteorhit(obj/meteor)
		return

	attack_hand(mob/M)

		if (!istype(M, /mob/living/carbon/human))
			boutput(M, "You aren't a human so you can't use these.")
			return

		if (in_use)
			boutput(M, "It just did something, give it a bit, gosh.")
			return

		in_use = 1
		alpha = 120
		makeAntag(M)
		sleep(5 SECONDS)
		in_use = 0
		alpha = 255

	makeAntag(mob/living/carbon/human/M as mob)
		var/uplink = new /obj/item/uplink/syndicate/virtual(get_turf(M))
		M.put_in_hand_or_eject(uplink) // try to eject it into the users hand, if we can
		boutput(M, SPAN_COMBAT("You can spawn fancy Syndicate gear with the virtual uplink! Go hog wild."))

	werewolf
		name = "WEREWOLF.EXE"
		desc = "Makes you into a werewolf? If only they included a goddamn readme with this shit."
		icon = 'icons/misc/critter.dmi'
		icon_state = "george"
		color = "#000000"

		makeAntag(mob/living/carbon/human/M as mob)
			boutput(M, SPAN_COMBAT("Awooooooo!"))
			M.mind.add_antagonist(ROLE_WEREWOLF, do_vr = TRUE)

	wrestler
		name = "WRESTL~1.EXE"
		desc = "Installs some sweet wrestling moves into your virtual body."
		icon = 'icons/obj/items/belts.dmi'
		icon_state = "machobelt"

		makeAntag(mob/living/carbon/human/M as mob)
			boutput(M, SPAN_COMBAT("Time to step into the squared circle, son."))
			M.mind.add_antagonist(ROLE_WRESTLER, do_vr = TRUE)

	wizard
		name = "WIZARD.EXE"
		desc = "An installation wizard that installs a wizard (you). Make sure to uncheck the browser toolbar addons."
		icon = 'icons/obj/clothing/item_hats.dmi'
		icon_state = "apprentice"

		makeAntag(mob/living/carbon/human/M as mob)
			boutput(M, SPAN_COMBAT("You're a wizard, <s>Harry</s> [M]! Don't forget to pick your spells."))
			M.mind?.add_antagonist(ROLE_WIZARD, do_vr = TRUE)

	nuclear
		name = "NUKE_TKN.EXE"
		desc = "A syndicoin mining rig. Get some sweet syndicate requisition tokens"
		icon = 'icons/obj/items/items.dmi'
		icon_state = "req-token"

		makeAntag(mob/living/carbon/human/M as mob)
			var/token = new /obj/item/requisition_token/syndicate/vr(get_turf(M))
			M.put_in_hand_or_eject(token) // try to eject it into the users hand, if we can
			boutput(M, SPAN_COMBAT("Redeem your freshly mined syndicoin in the nearby weapon vendor."))

	arcfiend
		name = "ARCF13ND.EXE"
		desc = "Turns you into an arcfiend, using a bit of the processing power of vr."
		icon = 'icons/obj/power.dmi'
		icon_state = "apc0"

		makeAntag(mob/living/carbon/human/M)
			boutput(M, SPAN_COMBAT("The simulation grants you a small portion of its power."))
			M.mind?.add_antagonist(ROLE_ARCFIEND, do_vr = TRUE)


/datum/fishing_spot/traitorifier
	rod_tier_required = 0
	fishing_atom_type = /obj/traitorifier

	try_fish(mob/user, obj/item/fishing_rod/fishing_rod, atom/target)
		boutput(user, SPAN_ALERT("Antag fishing is against the rules!"))
		if (!user.hasStatus("knockdown"))
			user.changeStatus("knockdown", 1 SECONDS)
			user.force_laydown_standup()
			playsound(user, 'sound/impact_sounds/Energy_Hit_3.ogg', 50, TRUE, -1)
		return FALSE
