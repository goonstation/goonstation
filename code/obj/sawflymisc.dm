/* file for all objects pertaining to sawfly that don't really go anywhere else
 -->Includes:
-All grenades- reused, cluster and normal
-The remote
-The limb that shoots the blade
-

-->Things it DOES NOT include that are sawfly-related, and where they can be found:
-The pouch of sawflies for nukies at the bottom of ammo pouches.dm
-The projectile they use is midway through laser.dm, with the other melee drone projectiles.
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
		SPAWN(2) // super short delay to prevent fuckiness with suicide code
			var/turf/T =  get_turf(src)
			if (T)
				new /mob/living/critter/sawfly(T)// this is probably a shitty way of doing it but it works
			qdel(src)
		return


	suicide(var/mob/living/carbon/human/user)
		if (!src.user_can_suicide(user))
			return FALSE
		user.visible_message("<span class='alert'><b>[user] primes the [src] and swallows it!</b></span>")

		if(prob(30)) //you fumble the grenade
			user.take_oxygen_deprivation(200)
			user.visible_message("<span class='alert'><b>[user] chokes on [src]!</b></span>")

		else if(prob(50))
			user.visible_message("<span class='alert'><b>[src] explodes out of [user]'s throat, holy shit!</b></span>")
			playsound(user.loc, "sound/impact_sounds/Flesh_Break_2.ogg", 50, 1)
			blood_slash(user, 25)
			var/obj/head = user.organHolder.drop_organ("head")
			qdel(head)

		else
			user.visible_message("<span class='alert'><b>The [src] explodes out of [user]'s chest, jesus fuck!</b></span>")
			playsound(user.loc, "sound/impact_sounds/Flesh_Break_2.ogg", 50, 1)
			user.organHolder.drop_organ("head") //bye bye extremities
			if(user.limbs.l_arm)
				user.limbs.l_arm.sever()
			if(user.limbs.r_arm)
				user.limbs.r_arm.sever()
			if(user.limbs.l_leg)
				user.limbs.l_leg.sever()
			if(user.limbs.r_leg)
				user.limbs.r_leg.sever()
			SPAWN(2)
				user.gib()

		src.prime()
		return TRUE





/obj/item/old_grenade/sawfly/withremote // for traitor menu

	New()
		new /obj/item/remote/sawflyremote(src.loc)
		..()

/obj/item/old_grenade/sawfly/reused
	name = "Compact sawfly"
	var/tempname = "Uh oh! Call 1-800-imcoder!"
	desc = "A self-deploying antipersonnel robot. This one has seen some use."
	var/temphp = 0


	prime()
		var/turf/T =  get_turf(src)
		if (T)
			var/mob/living/critter/sawfly/D = new /mob/living/critter/sawfly(T)
			D.isnew = FALSE // give it characteristics of old drone
			D.name = tempname
			D.TakeDamage("All", (50 - temphp))

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
	payload = /mob/living/critter/sawfly
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
	name = "Sawfly deactivator"
	desc = "A small device that can be used to fold or deploy sawflies in range. It looks like you could hide it in your clothes. Or smash it into tiny bits, you guess."
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS
	icon = 'icons/obj/items/device.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi'
	icon_state = "sawflycontr"
	var/alreadyhit = FALSE
	var/emagged = FALSE

	attack_self(mob/user as mob)
		if(src.emagged || src.alreadyhit)// you broke it.
			if(prob(10))
				boutput(user,"<span class='alert'>The [src] suddenly falls apart!</span>")
				qdel(src)
				return
		for(var/mob/living/critter/sawfly/S in range(get_turf(src), 3)) // folds active sawflies
			SPAWN(0.5 SECONDS)
				if(src.emagged)
					if(prob(50)) //sawfly breaks
						S.visible_message("<span class='combat'>[S] buzzes oddly and starts to sprial out of control!</span>")
						walk(src, 0)
						walk_rand(src, 1, 10)
						SPAWN(2 SECONDS)
							S.blowup()
					else
						S.foldself() //business as usual
				else  // non-emagged activity
					S.foldself()

		for(var/obj/item/old_grenade/sawfly/S in range(get_turf(src), 3)) // unfolds passive sawflies
			S.visible_message("<span class='combat'>[S] suddenly springs open as its engine purrs to a start!</span>")
			S.icon_state = "sawfly1"
			SPAWN(S.det_time)
				S.prime()

	afterattack(obj/O as obj, mob/user as mob)
		if (O.loc == user && O != src && istype(O, /obj/item/clothing))
			boutput(user, "<span class='hint'>You hide the remote in your [O]. (Use the snap emote (ctrl+z) while wearing the clothing to retrieve it.)</span>")
			user.u_equip(src)
			src.set_loc(O)
			src.dropped(user)
			return
		..()

	emag_act(var/mob/user)
		boutput(user, "<span class='hint'>The controller buzzes... oddly. You're unsure exactly what that did, but it did do something</span>")
		icon_state = "sawflycontr1"
		alreadyhit = TRUE
		emagged = TRUE

	attackby(obj/item/S as obj, mob/user as mob)
		if(S.force < 3)
			boutput(user, "<span class='hint'>You feel like you'd need something heftier to break the [src].</span>")
		else
			if(alreadyhit)
				boutput(user,"<span class='alert'>You smash the [src] into tiny bits!</span>")
				qdel(src)
			else
				icon_state = "sawflycontr1"
				boutput(user,"<span class='alert'>You give the [src] a hefty whack.</span>")
				alreadyhit = TRUE
		..()


// -------------------limbs---------------

/datum/limb/gun/sawfly_blades //OP as shit for the sake of the AI- if a player ever uses this, make a weaker version
	proj = new/datum/projectile/laser/drill/sawfly
	shots = 1
	current_shots = 1
	cooldown = 1
	reload_time = 1
	reloading_str = "cooling"

/datum/limb/gun/flock_stunner/attack_range(atom/target, var/mob/living/critter/flock/drone/user, params)
	if(!target || !user)
		return
	return ..()
