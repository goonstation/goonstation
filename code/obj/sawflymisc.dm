/* file for all objects pertaining to sawfly that don't really go anywhere else
 -->Includes:
-All grenades- reused, cluster and normal
-The remote
-The limb that shoots the blade

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
			var/mob/living/critter/sawfly/D = new /mob/living/critter/sawfly(T)
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
	name = "Sawfly remote"
	desc = "A small device that can be used to fold or deploy sawflies in range."
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS
	icon = 'icons/obj/items/device.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi'
	icon_state = "sawflycontr"


	attack_self(mob/user as mob)
		for(var/mob/living/critter/sawfly/S in range(get_turf(src), 5)) // folds active sawflies
			SPAWN(0.5 SECONDS)
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
// -------------------limbs---------------

/datum/limb/gun/sawfly_blades //OP as shit for the sake of the AI- if a player ever uses this, make a weaker version
	proj = new/datum/projectile/laser/drill/sawfly
	shots = 1
	current_shots = 1
	cooldown = 1
	reload_time = 1
	reloading_str = "cooling"

	attack_range(atom/target, var/mob/user, params) //overriding attack_range to change default fire message into something more melee-themed
		if (reloaded_at > ticker.round_elapsed_ticks && !current_shots)
			boutput(user, "<span class='alert'>The [holder.name] is [reloading_str]!</span>")
			return
		else if (current_shots <= 0)
			current_shots = shots
		if (next_shot_at > ticker.round_elapsed_ticks)
			return
		if (current_shots > 0)
			current_shots--

			var/pox = text2num(params["icon-x"]) - 16
			var/poy = text2num(params["icon-y"]) - 16
			shoot_projectile_ST_pixel(user, proj, target, pox, poy)
			//since sawflies literally cannot miss their shots unless someone frame perfect dodges, I'm fine with their attack flavor text being the fire message
			user.visible_message("<b class='alert'>[user] [pick(list("gouges", "cleaves", "lacerates", "shreds", "cuts", "tears", "hacks", "slashes",))] [target]!</b>")
			next_shot_at = ticker.round_elapsed_ticks + cooldown
			if (!current_shots)
				reloaded_at = ticker.round_elapsed_ticks + reload_time
		else
			reloaded_at = ticker.round_elapsed_ticks + reload_time

/datum/limb/gun/flock_stunner/attack_range(atom/target, var/mob/living/critter/flock/drone/user, params)
	if(!target || !user)
		return
	return ..()
