/* file for all objects pertaining to sawfly that don't really go anywhere else
 -->Includes:
-All grenades- cluster and normal
-The remote
-The limb that does the damage

-->Things it DOES NOT include that are sawfly-related, and where they can be found:
-The pouch of sawflies for nukies at the bottom of ammo pouches.dm
-The critter itself, which is in mob/living/critter/sawfly.dm
-Their AI, which is generic critter with local changes to the mob code
*/

// -------------------grenades-------------
TYPEINFO(/obj/item/old_grenade/sawfly)
	mats = list("metal_dense" = 7,
				"conductive" = 7,
				"energy" = 5)

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
	issawfly = TRUE //used to tell the sawfly remote if it can or can't detonate() the grenade
	contraband = 2
	overlays = null
	armed = FALSE
	HELP_MESSAGE_OVERRIDE({"Use the sawfly in hand or use the remote to deploy it. To deactivate, use the remote or (syndicate only) click on the sawfly with <span class='help'>help</span> or <span class='grab'>grab</span> intent."})

	//used in dictating behavior when deployed from grenade
	var/mob/living/critter/robotic/sawfly/heldfly = null

	attack_self(mob/user)
		var/area/A = get_area(src)
		if (A.sanctuary == TRUE && !istype(A, /area/syndicate_station/battlecruiser)) // salvager vessel, vr, THE SHAMECUBE, but not the battlecruiser
			boutput(user, SPAN_NOTICE("You can't prime [src] here!"))
			return
		..()

	detonate()
		var/turf/T =  ..()
		if (T && heldfly)
			heldfly.set_loc(T)
			heldfly.is_npc = TRUE
			heldfly.ai = new /datum/aiHolder/aggressive(heldfly)

		qdel(src)

/obj/item/old_grenade/sawfly/firsttime //super important- traitor uplinks and sawfly pouches use this specific version
	New()

		heldfly = new /mob/living/critter/robotic/sawfly(src.loc)
		heldfly.ourgrenade = src
		heldfly.set_loc(src)
		..()

/obj/item/old_grenade/sawfly/firsttime/withremote // for traitor menu
	mechanics_type_override = /obj/item/old_grenade/sawfly/firsttime //prevents remote clutter if you're making an army
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
TYPEINFO(/obj/item/remote/sawflyremote)
	mats = list("conductive"=2)
/obj/item/remote/sawflyremote
	name = "Sawfly remote"
	desc = "A small device that can be used to fold or deploy sawflies in range."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "sawfly_remote"

	w_class = W_CLASS_TINY
	object_flags = NO_GHOSTCRITTER
	is_syndicate = TRUE

	HELP_MESSAGE_OVERRIDE({"Use the remote in hand to activate/deactivate any sawflies within a 5 tile radius."})

	attack_self(mob/user)
		if (ON_COOLDOWN(src, "button_pushy", 1.5 SECONDS))
			return
		FLICK("sawfly_remote-pressed", src)
		for (var/mob/living/critter/robotic/sawfly/S in range(get_turf(src), 5)) // folds active sawflies
			SPAWN(0.1 SECONDS)
				S.foldself()
		for (var/obj/item/old_grenade/S in range(get_turf(src), 5)) // unfolds passive sawflies
			var/area/A = get_area(S)
			if (A.sanctuary == TRUE && !istype(A, /area/syndicate_station/battlecruiser)) // salvager vessel, vr, THE SHAMECUBE, but not the battlecruiser
				continue
			if (!S.issawfly) //check if we're allowed to prime the grenade
				continue
			if (istype(S, /obj/item/old_grenade/sawfly) && !S.armed)
				S.visible_message(SPAN_ALERT("[S] suddenly springs open as its engine purrs to a start!"))
				S.icon_state = "sawflyunfolding"
				S.armed = TRUE
				SPAWN(S.det_time)
					S?.detonate()

			if (istype(S, /obj/item/old_grenade/spawner/sawflycluster) && !S.armed)
				S.visible_message(SPAN_ALERT("The [S] suddenly begins beeping as it is primed!"))
				if (S.icon_state=="clusterflyA")
					S.icon_state = "clusterflyA1"
				else
					S.icon_state = "clusterflyB1"
				S.armed = TRUE
				SPAWN(S.det_time)
					S?.detonate()

// ---------------limb---------------
/datum/limb/sawfly_blades
	can_beat_up_robots = TRUE

	//due to not having intent hotkeys and also being AI controlled we only need the one proc
	harm(mob/living/target, var/mob/living/critter/robotic/sawfly/user) //will this cause issues down the line when someone eventually makes a child of this? hopefully not
		if(!ON_COOLDOWN(user, "sawfly_attackCD", 1 SECONDS))
			if(issawflybuddy(target))
				return
			user.visible_message("<b class='alert'>[user] [pick(list("gouges", "carves", "cleaves", "lacerates", "shreds", "cuts", "tears", "saws", "mutilates", "hacks", "slashes",))] [target]!</b>")
			playsound(user, 'sound/machines/chainsaw_green.ogg', 50, TRUE)
			if(prob(5))
				user.dobeep()
			take_bleeding_damage(target, null, 10, DAMAGE_STAB)
			random_brute_damage(target, 14, TRUE)
			target.was_harmed(user)

	attack_hand(atom/target, var/mob/user, var/reach)
		if (ismob(target))
			..()
		..()
