/* master file for all objects pertaining to sawfly that doesn't really go anywhere else
 includes grenades, both new reused, and cluster, controller that makes them easier to click, and loot

->Things it DOES NOT include that are sawfly-related, and where they can be found:
The critter itself is at the bottom of drone.dm
The pouch of sawflies for nukies at the bottom of ammo pouches.dm
The projectile they use is midway through laser.dm, with the other melee drone projectiles. Try not to think too hard on that.
*/

// -------------------grenades-------------
/obj/item/old_grenade/spawner/sawfly
	name = "Compact sawfly"
	desc = "A self-deploying area antipersonnel robot. It's folded up and offline..."
	det_time = 1 SECONDS
	throwforce = 7
	icon_state = "sawfly"
	icon_state_armed = "sawfly1"
	payload = /obj/critter/gunbot/drone/buzzdrone/sawfly
	is_dangerous = TRUE
	is_syndicate = 1
	contraband = 2

	prime() // we only want one drone, rewrite old proc
		var/turf/T =  get_turf(src)
		if (T)
			new /obj/critter/gunbot/drone/buzzdrone/sawfly(T)// this is probably a shitty way of doing it but it works
		qdel(src)
		return

/obj/item/old_grenade/spawner/sawfly/reused
	name = "Compact sawfly"
	var/tempname = "Someone meant to spawn /obj/item/old_grenade/spawner/sawfly but misclicked, didn't they?"
	desc = "A self-deploying area antipersonnel robot. This one has seen some use."
	var/temphp = 0


	prime()
		var/turf/T =  get_turf(src)
		if (T)
			var/obj/critter/gunbot/drone/buzzdrone/sawfly/D = new /obj/critter/gunbot/drone/buzzdrone/sawfly(T)
			D.isnew = FALSE // give it characteristics of old drone
			D.name = tempname
			D.health = temphp
			D.maxhealth = temphp
		qdel(src)
		return

/obj/item/old_grenade/spawner/sawflycluster
	name = "Cluster sawfly"
	desc = "A whole lot of little robots at the end of the stick, ready to shred whomever you decide to use them against."
	det_time = 2 SECONDS // give them slightly more time to realize their fate

	force = 7 //whacking people with metal on the end of a stick hurts -> this should be a decent weapon
	throwforce = 10
	stamina_damage = 35
	stamina_cost = 20
	stamina_crit_chance = 35


	icon_state = "clusterflyA"
	icon_state_armed = "clusterflyA1"
	payload = /obj/critter/gunbot/drone/buzzdrone/sawfly
	is_dangerous = TRUE
	is_syndicate = 1
	contraband = 5

	New()
		..()
		if (prob(50)) // give em some sprite variety
			icon_state = "clusterflyB"
			icon_state_armed = "clusterflyB1"


	prime() // I've de-spawnerized the spanwer grenade for sawflies and how I'm respawnerizing them. the irony.
		var/turf/T = ..()
		if (T)
			new /obj/critter/gunbot/drone/buzzdrone/sawfly(T)
		qdel(src)
		return

// controller

/obj/item/sawflysleeper
	name = "Sawfly deactivator"
	desc = "A small device that can be used to temporarily disable sawflies. It looks pretty fragile and it could easily be hidden in clothing."
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS
	icon = 'icons/obj/items/device.dmi'
	//inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi'
	icon_state = "sawflycontr"
	var/alreadyhit = FALSE

	attack_self(mob/user as mob)
		for(var/obj/critter/gunbot/drone/buzzdrone/sawfly/S in range(get_turf(src), 6))
			S.task = "sleeping"


	afterattack(obj/O as obj, mob/user as mob)
		if (O.loc == user && O != src && istype(O, /obj/item/clothing))
			boutput(user, "<span class='hint'>You hide the remote your [O]. (Use the snap emote while wearing the clothing item to retrieve it.)</span>")
			user.u_equip(src)
			src.set_loc(O)
			src.dropped(user)
			return

		..()
	attackby(obj/item/S as obj, mob/user as mob)
		if(S.force < 3)
			boutput(user, "<span class='hint'>You feel like you'd need something heftier to break the [src].")
		else
			if(alreadyhit)
				boutput(user,"<span class='alert'> You smash the [src] into tiny bits!")
				qdel(src)
			else
				icon_state = "sawflycontr1"
				alreadyhit = TRUE
		..()

