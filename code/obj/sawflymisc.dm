/* file for all objects pertaining to sawfly that don't really go anywhere else
 -->Includes:
-All grenades- cluster and normal
-The remote
-The limb that does the damage

-->Things it DOES NOT include that are sawfly-related, and where they can be found:
-The pouch of sawflies for nukies at the bottom of ammo pouches.dm
-Their AI, which can be found in mob/living/critter/ai/sawflyai.dm
-The critter itself, which is in mob/living/critter/sawfly.dm
*/

// -------------------grenades-------------
/obj/item/old_grenade/sawfly

	name = "Compact sawfly"
	desc = "A self-deploying antipersonnel robot. It's folded up and offline..."
	det_time = 1.5 SECONDS
	throwforce = 7
	icon = 'icons/obj/items/sawfly.dmi'
	icon_state = "sawfly"
	icon_state_armed = "sawflyunfolding"
	sound_armed = 'sound/machines/sawflyrev.ogg'
	//inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi' // could be better but it's distinct enough
	is_dangerous = TRUE
	is_syndicate = TRUE
	issawfly = TRUE //used to tell the sawfly remote if it can or can't prime() the grenade
	mats = list("MET-2"=7, "CON-1"=7, "POW-1"=5)
	contraband = 2
	overlays = null

	//used in dictating behavior when deployed from grenade
	//var/fresh = TRUE
	var/mob/living/critter/robotic/sawfly/heldfly = null
	var/obj/item/organ/brain/currentbrain = null
	var/mob/currentuser = null
	var/isopen = FALSE
	var/playercontrolled = FALSE

	attack_self(mob/user)
		user = currentuser
		if(isopen)
			if(playercontrolled)
				//if(tgui_alert(src, "Are you sure you want to eject the conciousness?", "Sawfly Brain", list("Yes", "No")) == "Yes")
				//ejectbrain(currentbrain)
			else
				//bungus gungus
		else
			..()

	prime()
		var/turf/T =  get_turf(src)
		if (T)
			heldfly.set_loc(T)
			heldfly.is_npc = TRUE
			heldfly.isgrenade = FALSE
		if(!playercontrolled)
			if(issawflybuddy(currentuser))
				heldfly.ai = new /datum/aiHolder/sawfly(heldfly)
			else
				heldfly.ai = new /datum/aiHolder/sawfly(heldfly) //todo: give them pet AI
		qdel(src)

	attackby(obj/item/W, mob/user)

		if (isscrewingtool(W)) //basic open/close actions
			if(isopen)
				isopen = FALSE
				overlays -= "open-overlay"
			else
				isopen = TRUE
				overlays += "open-overlay"
		if((istype(W, /obj/item/organ/brain/latejoin)) && isopen)
			insertbrain( W, src, heldfly)//user,

	proc/insertbrain( obj/item/brain, obj/item/sawflygrenade)//mob/user,
		//var/success = TRUE
		//	boutput(user, "You insert the [brain] into the [sawflygrenade]. Please wait a maximum of 20 seconds for the [heldfly]'s systems to initalize.")
		src.currentbrain = brain
		var/ghost_delay = 100
		var/list/text_messages = list()
		var/place = get_turf(src)
		var/mob/living/critter/robotic/sawfly/oursawfly = null

		text_messages.Add("Would you like to be resurrected as a traitor's Sawfly? You may be randomly selected from the list of candidates.")
		text_messages.Add("You are eligible to be resurrected as a traitor's Sawfly. You have [ghost_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. Please wait for the game to choose, good luck!")

		var/list/datum/mind/candidates = dead_player_list(1, ghost_delay, text_messages, allow_dead_antags = 1)
		if (!candidates)
			sawflygrenade.visible_message("The [src.heldfly] emits a grumpy beep and ejects the [currentbrain]")
			src.ejectbrain(currentbrain)
			return
		var/datum/mind/lucky_dude = pick(candidates)

		SPAWN(1) //IT'S TIME. FOR SOME FUCK SHIT!!!!!!
			if (lucky_dude)
				//new sawfly
				oursawfly = new /mob/living/critter/robotic/sawfly(place)
				lucky_dude.transfer_to(oursawfly)
				brain.set_loc(oursawfly)
				oursawfly.foldself()



				sawflygrenade.visible_message("The [oursawfly] emits a pleasant chime as glows with sapience!")
				qdel(src)

			else
				sawflygrenade.visible_message("The [oursawfly] makes an upset beep! Something went wrong!")

			//we're through with the necessary steps and we have our mind! Time to put things together


			/*if (lucky_dude)
				lucky_dude.transfer_to(heldfly)
				src.visible_message("The [src.heldfly] emits a pleasant chime as glows with sapience!")
				// ADD POPUP HERE
			else
				//boutput(user, "The [src.heldfly] emits a grumpy beep and ejects the [currentbrain]")
				src.ejectbrain(currentbrain)*/



	proc/ejectbrain(/obj/item/organ/brain/currentbrain)
		//bungus
		if(!isopen)
			isopen = TRUE
		if(currentbrain)
			if(currentbrain.owner)
				boutput(currentbrain.owner, "You have been booted from your sawfly and are now a disconnected ghost!")
				heldfly.ghostize()
				currentbrain.owner = null

			currentbrain.set_loc(get_turf(src))
			src.playercontrolled = FALSE

/obj/item/old_grenade/sawfly/firsttime //IMPORTANT- spawn this in or the sawfly grenade will NOT work
	New()

		heldfly = new /mob/living/critter/robotic/sawfly(src.loc)
		heldfly.ourgrenade = src
		heldfly.set_loc(src)
		..()

/datum/random_event/major/antag/sawflytest
	name = "SAWFLY TEST"
	required_elapsed_round_time = 26.6 MINUTES
	customization_available = 1
	announce_to_admins = 0 // Doing it manually.
	centcom_headline = "Biogenic Outbreak"
	centcom_message = "Aggressive macrocellular organism detected aboard the station. All personnel must contain the outbreak."
	message_delay = 5 MINUTES // (+ ghost_confirmation_delay). Don't out them too early, blobs in particular need time to establish themselves.
	var/place = null
	var/obj/item/old_grenade/sawfly/firsttime/baby = null
	var/obj/item/organ/brain/latejoin/brain = null

	event_effect()
		place = pick_landmark(LANDMARK_LATEJOIN)
		baby = new /obj/item/old_grenade/sawfly(place)
		brain = new /obj/item/organ/brain/latejoin(place)
		SPAWN(1)
			baby.insertbrain(brain, baby, baby.heldfly)
/obj/item/old_grenade/sawfly/firsttime/withremote // for traitor menu
	New()
		new /obj/item/remote/sawflyremote(src.loc)
		..()


/obj/item/old_grenade/spawner/sawflycluster
	name = "Cluster sawfly"
	desc = "A whole lot of little angry robots at the end of the stick, ready to shred whoever stands in their way."
	det_time = 2 SECONDS // more reasonable reaction time

	force = 7
	throwforce = 10
	stamina_damage = 35
	stamina_cost = 20
	stamina_crit_chance = 35
	sound_armed = 'sound/machines/sawflyrev.ogg'
	icon_state = "clusterflyA"
	icon_state_armed = "clusterflyA1"
	payload = /mob/living/critter/robotic/sawfly/ai_controlled
	is_dangerous = TRUE
	is_syndicate = TRUE
	issawfly = TRUE
	contraband = 5

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		new /obj/item/remote/sawflyremote(src.loc)
		if (prob(50)) // give em some sprite variety
			icon_state = "clusterflyB"
			icon_state_armed = "clusterflyB1"

// -------------------controller---------------

/obj/item/remote/sawflyremote
	name = "Sawfly remote"
	desc = "A small device that can be used to fold or deploy sawflies in range."
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS
	object_flags = NO_GHOSTCRITTER
	icon = 'icons/obj/items/device.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi'
	icon_state = "sawflycontr"

	attack_self(mob/user as mob)
		for (var/mob/living/critter/robotic/sawfly/S in range(get_turf(src), 5)) // folds active sawflies
			SPAWN(0.1 SECONDS)
				S.foldself()

		for(var/obj/item/old_grenade/S in range(get_turf(src), 4)) // unfolds passive sawflies
			if (S.issawfly == TRUE) //check if we're allowed to prime the grenade
				if (istype(S, /obj/item/old_grenade/sawfly))
					S.visible_message("<span class='alert'>[S] suddenly springs open as its engine purrs to a start!</span>")
					S.icon_state = "sawflyunfolding"
					SPAWN(S.det_time)
						if(S)
							S.prime()

				if (istype(S, /obj/item/old_grenade/spawner/sawflycluster))
					S.visible_message("<span class='alert'>The [S] suddenly begins beeping as it is primed!</span>")
					if (S.icon_state=="clusterflyA")
						S.icon_state = "clusterflyA1"
					else
						S.icon_state = "clusterflyB1"
					SPAWN(S.det_time)
						if(S)
							S.prime()
			else
				continue


// ---------------limb---------------
/datum/limb/sawfly_blades


	//due to not having intent hotkeys and also being AI controlled we only need the one proc
	harm(mob/living/target, var/mob/living/critter/robotic/sawfly/user) //will this cause issues down the line when someone eventually makes a child of this? hopefully not
		if(!ON_COOLDOWN(user, "sawfly_attackCD", 0.8 SECONDS))
			user.visible_message("<b class='alert'>[user] [pick(list("gouges", "cleaves", "lacerates", "shreds", "cuts", "tears", "saws", "mutilates", "hacks", "slashes",))] [target]!</b>")
			playsound(user, "sound/machines/chainsaw_green.ogg", 50, 1)
			if(prob(3))
				user.communalbeep()
			take_bleeding_damage(target, null, 17, DAMAGE_STAB)
			random_brute_damage(target, 14, FALSE)
			target.was_harmed(user)

	attack_hand(atom/target, var/mob/user, var/reach)
		if (ismob(target))
			..()
		..()
//sawfly abilities
/datum/targetable/critter/sawflydeploy
	name = "(Un)deploy"
	desc = "Toggle your flying/item state! Cannot be used in containers"
	icon_state = "sawfly-deploy"
	cooldown = 0
	cast_in_storage = TRUE

	cast(mob/target)

		var/mob/living/critter/robotic/sawfly/M = holder.owner
		//boutput(M, "Casting!")
		if(istype(M.loc, /obj/item/storage))
			return //bad!
			// to work on: make it take a looong ass time if it's in a storage container so they can escape if their master dies
		//boutput(M, "Starting grenade logic!!")
		if(M.isgrenade == TRUE) //we're in a grenade, time to un-grenade ourselfes!
		//	boutput(M, "Attempting to unfold self!")
			M.visible_message("<span class='alert'>[M] suddenly springs open as its engine purrs to a start!</span>")
			playsound(M, pick(M.beeps), 40, 1)
			if(get_turf(M))
				M.ourgrenade.prime()
				M.isgrenade = FALSE //for some reason priming it doesn't work, so we'll have to do things the manual way
				M.set_loc(get_turf(M))
				//qdel(M.ourgrenade)



		else
		//	boutput(M, "Attempting to fold self!")
			M.foldself()
	//	boutput(M, "Finished grenade if else!")




