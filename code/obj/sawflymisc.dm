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
TYPEINFO(/obj/item/old_grenade/sawfly)
	mats = list("MET-2"=7, "CON-1"=7, "POW-1"=5)

/obj/item/old_grenade/sawfly

	name = "Compact sawfly"
	desc = "A self-deploying antipersonnel robot. It's folded up and offline..."
	det_time = 1.5 SECONDS
	throwforce = 7
	icon = 'icons/obj/items/sawfly.dmi'
	icon_state = "sawfly"
	icon_state_armed = "sawflyunfolding"
	sound_armed = 'sound/machines/sawflyrev.ogg'

	is_dangerous = TRUE
	is_syndicate = TRUE
	issawfly = TRUE //used to tell the sawfly remote if it can or can't prime() the grenade
	contraband = 2
	overlays = null
	state = 0

	//used in dictating behavior when deployed from grenade
	var/mob/living/critter/robotic/sawfly/heldfly = null

	attack_self(mob/user)
		var/area/A = get_area(src)
		if (A.sanctuary == TRUE && !istype(A, /area/syndicate_station/battlecruiser)) // salvager vessel, vr, THE SHAMECUBE, but not the battlecruiser
			boutput(user, "<span class='notice'>You can't prime it here!</span>")
			return
		..()

	prime()
		var/turf/T =  get_turf(src)
		if (T && heldfly)
			heldfly.set_loc(T)
			heldfly.is_npc = TRUE
			heldfly.ai = new /datum/aiHolder/sawfly(heldfly)

		qdel(src)
/obj/item/old_grenade/sawfly/firsttime//super important- traitor uplinks and sawfly pouches use this specific version
	New()

		heldfly = new /mob/living/critter/robotic/sawfly(src.loc)
		heldfly.ourgrenade = src
		heldfly.set_loc(src)
		..()

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
	icon = 'icons/obj/items/sawfly.dmi'
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
			var/area/A = get_area(S)
			if (A.sanctuary == TRUE && !istype(A, /area/syndicate_station/battlecruiser)) // salvager vessel, vr, THE SHAMECUBE, but not the battlecruiser
				continue
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
		if(!ON_COOLDOWN(user, "sawfly_attackCD", 1 SECONDS))
			if(issawflybuddy(target))
				return
			user.visible_message("<b class='alert'>[user] [pick(list("gouges", "carves", "cleaves", "lacerates", "shreds", "cuts", "tears", "saws", "mutilates", "hacks", "slashes",))] [target]!</b>")
			playsound(user, 'sound/machines/chainsaw_green.ogg', 50, 1)
			if(prob(3))
				user.communalbeep()
			take_bleeding_damage(target, null, 10, DAMAGE_STAB)
			random_brute_damage(target, 14, TRUE)
			target.was_harmed(user)

	attack_hand(atom/target, var/mob/user, var/reach)
		if (ismob(target))
			..()
		..()
