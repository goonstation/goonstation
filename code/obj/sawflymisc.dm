/* file for all objects pertaining to sawfly that don't really go anywhere else
 -->Includes:
-All grenades- reused, cluster and normal
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
	icon_state = "sawfly"
	icon_state_armed = "sawfly1"
	sound_armed = 'sound/machines/sawflyrev.ogg'
	inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi' // could be better but it's distinct enough
	is_dangerous = TRUE
	is_syndicate = TRUE
	contraband = 2
	custom_suicide = 1

	prime()
		var/turf/T =  get_turf(src)
		if (T)
			new /mob/living/critter/robotic/sawfly(T)// this is probably a shitty way of doing it but it works
		qdel(src)
		return

/obj/item/old_grenade/sawfly/withremote // for traitor menu

	New()
		new /obj/item/remote/sawflyremote(src.loc)
		..()

/obj/item/old_grenade/sawfly/reused
	name = "Compact sawfly"
	var/tempname = "Uh oh! Call 1-800-imcoder!"
	desc = "A self-deploying antipersonnel robot. This one has seen some use."
	var/tempdam = 0


	prime()
		var/turf/T =  get_turf(src)
		if (T)
			var/mob/living/critter/robotic/sawfly/D = new /mob/living/critter/robotic/sawfly(T)
			D.isnew = FALSE // give it characteristics of old drone
			D.name = tempname
			D.TakeDamage("All", (tempdam))

		qdel(src)
		return

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
	payload = /mob/living/critter/robotic/sawfly
	is_dangerous = TRUE
	is_syndicate = TRUE
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
	icon = 'icons/obj/items/device.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi'
	icon_state = "sawflycontr"


	attack_self(mob/user as mob)
		for(var/mob/living/critter/robotic/sawfly/S in range(get_turf(src), 5)) // folds active sawflies
			SPAWN(0.1 SECONDS)
				S.foldself()

		for(var/obj/item/old_grenade/sawfly/S in range(get_turf(src), 4)) // unfolds passive sawflies
			S.visible_message("<span class='combat'>[S] suddenly springs open as its engine purrs to a start!</span>")
			S.icon_state = "sawfly1"
			SPAWN(S.det_time)
				S.prime()
		for(var/obj/item/old_grenade/spawner/sawflycluster/S in range(get_turf(src), 4))
			S.visible_message("<span class='combat'>The [S] suddenly begins beeping as it is primed!</span>")
			if(S.icon_state=="clusterflyA")
				S.icon_state = "clusterflyA1"
			else
				S.icon_state = "clusterflyB1"
			SPAWN(S.det_time)
				S.prime()

// ---------------limb---------------
/datum/limb/sawfly_blades

	//due to not having intent hotkeys and also being AI controlled we only need the one proc
	harm(mob/target, var/mob/user)
		if(!ON_COOLDOWN(user, "sawfly_attackCD", 1 SECONDS))
			user.visible_message("<b class='alert'>[user] [pick(list("gouges", "cleaves", "lacerates", "shreds", "cuts", "tears", "saws", "mutilates", "hacks", "slashes",))] [target]!</b>")
			playsound(user, "sound/machines/chainsaw_green.ogg", 50, 1)
			take_bleeding_damage(target, null, 17, DAMAGE_STAB)
			random_brute_damage(target, 14, FALSE)

	attack_hand(atom/target, var/mob/user, var/reach)
		if (ismob(target))
			..()


