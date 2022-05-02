/* master file for all objects pertaining to sawfly that don't really go anywhere else
 includes grenades, both new reused, and cluster, controller, and finally, the critter

-->Things it DOES NOT include that are sawfly-related, and where they can be found:
-The pouch of sawflies for nukies at the bottom of ammo pouches.dm
-The projectile they use is midway through laser.dm, with the other melee drone projectiles. Try not to think too hard on that.
*/

// -------------------grenades-------------
/obj/item/old_grenade/spawner/sawfly
	name = "Compact sawfly"
	desc = "A self-deploying antipersonnel robot. It's folded up and offline..."
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
/obj/item/old_grenade/spawner/sawfly/withremote // for traitor menu

	New()
		new /obj/item/sawflyremote(src.loc)
		..()
/obj/item/old_grenade/spawner/sawfly/reused
	name = "Compact sawfly"
	var/tempname = "Someone meant to spawn /obj/item/old_grenade/spawner/sawfly but misclicked, didn't they?"
	desc = "A self-deploying antipersonnel robot. This one has seen some use."
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
	desc = "A whole lot of little angry robots at the end of the stick, ready to shred whoever stands in their way."
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
		src.setItemSpecial(/datum/item_special/swipe)
		new /obj/item/sawflyremote(src.loc)
		if (prob(50)) // give em some sprite variety
			icon_state = "clusterflyB"
			icon_state_armed = "clusterflyB1"


	prime() // I've de-spawnerized the spanwer grenade for sawflies and now I'm respawnerizing them. the irony.
		var/turf/T = ..()
		if (T)
			new /obj/critter/gunbot/drone/buzzdrone/sawfly(T)
		qdel(src)
		return

// -------------------controller---------------

/obj/item/sawflyremote
	name = "Sawfly deactivator"
	desc = "A small device that can be used to fold or deploy sawflies in range. It looks like you could hide it in your clothes. Or smash it into tiny bits, you guess."
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS
	icon = 'icons/obj/items/device.dmi'
	//inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi'// find good inhand sprites later
	icon_state = "sawflycontr"
	var/alreadyhit = FALSE
	var/emagged = FALSE

	attack_self(mob/user as mob)
		if(src.emagged || src.alreadyhit)// you broke it.
			if(prob(10))
				boutput(user,"<span class='alert'> The [src] suddenly falls apart!</span>")
				qdel(src)
				return
		for(var/obj/critter/gunbot/drone/buzzdrone/sawfly/S in range(get_turf(src), 3)) // folds active sawflies
			SPAWN(0.5 SECONDS)
				if(src.emagged)
					if(prob(50)) //sawfly breaks
						S.visible_message("<span class='combat'>[S] buzzes oddly and starts to sprial out of control!</span>")
						SPAWN(1 SECONDS)
							S.blowup()
					else
						S.foldself() //business as usual
				else  // non-emagged activity
					S.foldself()

		for(var/obj/item/old_grenade/spawner/sawfly/S in range(get_turf(src), 3)) // unfolds passive sawflies
			S.visible_message("<span class='combat'>[S] suddenly springs open as its engine purr to a start!</span>")
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
		boutput(user, "<span class='hint'> The controller buzzes... oddly. You're unsure exactly what that did, but it did do something</span>")
		icon_state = "sawflycontr1"
		alreadyhit = TRUE
		emagged = TRUE

	attackby(obj/item/S as obj, mob/user as mob)
		if(S.force < 3)
			boutput(user, "<span class='hint'>You feel like you'd need something heftier to break the [src].</span>")
		else
			if(alreadyhit)
				boutput(user,"<span class='alert'> You smash the [src] into tiny bits!</span>")
				qdel(src)
			else
				icon_state = "sawflycontr1"
				boutput(user,"<span class='alert'> You give the [src] a hefty whack.</span>")
				alreadyhit = TRUE
		..()



//------------- THE SAWFLY ITSELF----------

/obj/critter/gunbot/drone/buzzdrone/sawfly
	name = "Sawfly"
	desc = "A folding antipersonnel drone of syndicate origin. It'd be pretty cute if it wasn't trying to kill people."
	icon_state = "sawfly"
	beeptext = "UH OOH"
	dead_state = "sawflydead"
	projectile_type = /datum/projectile/laser/drill/sawfly
	current_projectile = new/datum/projectile/laser/drill/sawfly
	smashes_shit = 0
	droploot = null //change this later
	health = 40
	maxhealth = 40
	firevuln = 0.5
	brutevuln = 1.2
	can_revive = 1
	atksilicon = 0
	firevuln = 0
	atk_delay = 5
	attack_cooldown = 8
	seekrange = 15
	var/deathtimer = 0 // for catastrophic failure on death
	var/isnew = TRUE // for reuse
	var/sawflynames = list("A", "B", "C", "D", "E", "F", "V", "W", "X", "Y", "Z", "Alpha", "Beta", "Gamma", "Lambda", "Delta")


	New()
		..()
		deathtimer = rand(1, 5)
		death_text = "[src] jutters and falls from the air, whirring to a stop"
		if(isnew)
			name = "Sawfly [pick(sawflynames)]-[rand(1,999)]"
		beeptext = "[pick(list("beeps", "boops", "bwoops", "bips", "bwips", "bops", "chirps", "whirrs", "pings", "purrs"))]"
		animate_bumble(src) // gotta get the float goin' on


	proc/foldself()
		var/obj/item/old_grenade/spawner/sawfly/reused/N = new /obj/item/old_grenade/spawner/sawfly/reused(get_turf(src))
		// pass our name and health
		N.name = "Compact [name]"
		N.tempname = src.name
		N.temphp = src.health
		qdel(src)


	proc/blowup() // used in emagged controllers and has a chance to activate when they die

		if(prob(66))
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "fuel tank", "battery", "thruster")] [pick("combusts", "catches on fire", "ignites", "lights up", "bursts into flames")]!")
			fireflash(src,1,TRUE)

		else
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "head", "engine", "thruster")] [pick("overloads", "blows up", "catastrophically fails", "explodes")]!")
			fireflash(src,0,TRUE)
			explosion(src, get_turf(src), 0, 1, 2, 3)
			qdel(src)

		if(alive) // prevents weirdness from emagged controllers
			qdel(src)


	emp_act() //same thing as if you emagged the controller, but much higher chance
		if(prob(80))
			src.visible_message("<span class='combat'>[src] buzzes oddly and starts to sprial out of contro!</span>")
			SPAWN(2 SECONDS)
				src.blowup()
		else
			src.foldself()


	ChaseAttack(atom/M) // overriding these procs so the drone is nicer >:(
		if (istraitor(M) || isnukeop(M) || isspythief(M) || (M in src.friends))

			return
		if(target && !attacking)
			attacking = 1
			src.visible_message("<span class='alert'><b>[src]</b> flies at [M]!</span>")
			if (istraitor(M) || isnukeop(M) || isspythief(M) || (M in src.friends))
				return

			walk_to(src, src.target,1,4)
			var/tturf = get_turf(M)
			Shoot(tturf, src.loc, src)
			SPAWN(attack_cooldown)
				attacking = 0
			return


	seek_target()
		src.anchored = 0
		for (var/mob/living/C in view(src.seekrange,src))
			if (C in src.friends) continue
			if (istraitor(C) || isnukeop(C) || isspythief(C)) // frens :)
				boutput(C, "<span class='alert'>[src]'s IFF system silently flags you as an ally!")
				friends += C
				continue
		..()


	CritterAttack(atom/M)
		if (istraitor(M) || isnukeop(M) || isspythief(M) || (M in src.friends)) // BE. A. GOOD. DRONE.
			return
		if(target && !attacking)
			attacking = 1
			src.visible_message("<span class='alert'><b>[src]</b> [pick(list("gouges", "cleaves", "lacerates", "shreds", "cuts", "tears", "hacks", "slashes",))] [M]!</span>")
			var/tturf = get_turf(M)
			Shoot(tturf, src.loc, src)
			SPAWN(attack_cooldown)
				attacking = 0
		return


	attackby(obj/item/W as obj, mob/living/user as mob)
		if(prob(50) && alive) // borrowed from brullbar- anti-crowd measures
			src.target = user
			src.oldtarget_name = user.name
			src.task = "chasing"
			//playsound(src.loc, "sound/impact_sounds/Generic_Hit_1.ogg", 60, 1)
			if (!(istraitor(user) || isnukeop(user) || isspythief(user)) )
				src.visible_message("<span class='alert'><b>[src]'s targeting subsystems identify</b> [src.target] as a high priority threat!</span>")
				var/tturf = get_turf(src.target) //instantly retaliate, since we know we're in melee range
				Shoot(tturf, src.loc, src)
				SPAWN((attack_cooldown/2)) //follow up swiftly
					attacking = 0
				CritterAttack(src.target)
		..()


	attack_hand(var/mob/user as mob)
		if (istraitor(user) || isnukeop(user) || isspythief(user) || (user in src.friends))
			if (user.a_intent == INTENT_HELP || INTENT_GRAB)
				boutput(user, "You collapse [src].")
				src.foldself()
		else
			if(prob(50))
				boutput(user,"<span class='alert' In your attempt to pet the [src], you cut yourself on it's blades! </span>")
				random_brute_damage(user, 7)
				take_bleeding_damage(user, null, 7, DAMAGE_CUT, 1)
		..()


	CritterDeath() // rip lil guy
		if (!src.alive) return
		..()
		// since they're a child of a child of a child of a child
		// and shit gets WHACKY fast with their behaviors
		// I'm just gonna say fuck all that and copy the critter death code
		SHOULD_CALL_PARENT(TRUE)
		if (!src.alive) return

		#ifdef COMSIG_OBJ_CRITTER_DEATH
		SEND_SIGNAL(src, COMSIG_OBJ_CRITTER_DEATH)
		#endif


		//special dead sprites
		animate(src) //stop no more float animation
		icon_state = "sawflydead[pick("1", "2", "3", "4", "5", "6", "7", "8")]"
		src.pixel_x += rand(-5, 5)
		src.pixel_y += rand(-1, 5)



		src.alive = 0
		src.anchored = 0
		src.set_density(0)
		walk_to(src,0) //halt walking
		report_death()
		src.tokenized_message(death_text)

		// IT'S TIME TO ROOOOOOLLLL THE DIIIICEEEEEE!!!!
		// special checks that determine how much postmorten chaos our little sawflies cause

		if(prob(60)) // 60 percent chance to zap the area
			elecflash(src, 1, 2)

		if(prob(20)) // congrats, little guy! You're special! You're going to blow up!
			if(prob(70)) //decide whether or not people get a warning
				src.visible_message("<span class='combat'>[src] makes a [pick("gentle", "odd", "slight", "weird", "barely audible", "concerning", "quiet")] [pick("hiss", "drone", "whir", "thump", "grinding sound", "creak", "buzz", "khunk")].......")

			SPAWN(deathtimer SECONDS) // pause, for dramatic effect
				src.blowup()

