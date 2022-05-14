/* master file for all objects pertaining to sawfly that don't really go anywhere else
 includes grenades, both new reused, and cluster, controller, and finally, the critter

-->Things it DOES NOT include that are sawfly-related, and where they can be found:
-The pouch of sawflies for nukies at the bottom of ammo pouches.dm
-The projectile they use is midway through laser.dm, with the other melee drone projectiles.
*/

// -------------------grenades-------------
/obj/item/old_grenade/spawner/sawfly
	name = "Compact sawfly"
	desc = "A self-deploying antipersonnel robot. It's folded up and offline..."
	det_time = 1 SECONDS
	throwforce = 7
	icon_state = "sawfly"
	icon_state_armed = "sawfly1"
	payload = /mob/living/critter/sawfly
	is_dangerous = TRUE
	is_syndicate = TRUE
	contraband = 2

	custom_suicide = 1


	prime() // we only want one drone, rewrite old proc
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
			user.visible_message("<span class='alert'><b>[user] chokes on the [src]!</b></span>")

		else if(prob(50))
			user.visible_message("<span class='alert'><b> The [src] explodes out of [user]'s throat, holy shit!</b></span>")
			playsound(user.loc, "sound/impact_sounds/Flesh_Break_2.ogg", 50, 1)
			blood_slash(user, 25)
			var/obj/head = user.organHolder.drop_organ("head")
			qdel(head)

		else
			user.visible_message("<span class='alert'><b> The [src] explodes out of [user]'s chest, jesus fuck!</b></span>")
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
			var/mob/living/critter/sawfly/D = new /mob/living/critter/sawfly(T)
			D.isnew = FALSE // give it characteristics of old drone
			D.name = tempname
			D.health = temphp

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
	payload = /mob/living/critter/sawfly
	is_dangerous = TRUE
	is_syndicate = TRUE
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
			new /mob/living/critter/sawfly(T)
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
		for(var/mob/living/critter/sawfly/S in range(get_turf(src), 3)) // folds active sawflies
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



//-------------The star baby boy of the show itself----------

/mob/living/critter/sawfly
	name = "Sawfly"
	desc = "A folding antipersonnel drone of syndicate origin. It'd be pretty cute if it wasn't trying to kill people."
	icon = 'icons/obj/ship.dmi'
	icon_state = "sawfly"

	var/beeptext = " "
	var/dead_state = "sawflydead"
	var/angertext = "flies at"
	var/projectile_type = /datum/projectile/laser/drill/sawfly
	var/datum/projectile/current_projectile = new/datum/projectile/laser/drill/sawfly
	var/obj/item/droploot = null // the prox sensors they drop in death are handled in the critterdeath proc
	var/deathtimer = 0 // for catastrophic failure on death
	var/isnew = TRUE // for seeing whether or not they will make a new name on redeployment
	var/sawflynames = list("A", "B", "C", "D", "E", "F", "V", "W", "X", "Y", "Z", "Alpha", "Beta", "Gamma", "Lambda", "Delta")
	var/beeps = list('sound/machines/sawfly1.ogg','sound/machines/sawfly2.ogg','sound/machines/sawfly3.ogg') // custom noises so they cannot be mistaken for ghostdrones or borgs

	health = 40
	var/can_revive = TRUE
	var/atksilicon = TRUE
	var/atkcarbon = TRUE
	var/alive = TRUE
	var/alreadydead = FALSE // prevents any bullshit from happening with repeated

// OBJ/CRITTER/DRONE FUCK SHIT HERE
	var/list/friends = list()
	var/attacking = FALSE
	var/atk_delay = 5
	var/attack_cooldown = 10
	var/seekrange = 15
	var/attacker = null
	var/atom/movable/target = null
	var/oldtarget_name = null
	var/attack = 0
	var/task = "thinking"
	var/frustration = 0
	var/atom/target_lastloc = null
	var/aggressive = FALSE
	var/last_found = null
	var/steps = 0
	var/sleep_check = 10
	var/wander_check = 0


	// MOB/LIVING/CRITTER FUCK SHIT HERE
	setup_healths()
		add_hh_robot(20, 1) // fuck you and your way of doing health that isn't my way of doing it
		add_hh_robot_burn(20, 1)
	custom_gib_handler = /proc/robogibs
	blood_id = "oil"
	use_stamina = FALSE
	use_stunned_icon = FALSE
	butcherable = FALSE
	can_bleed = FALSE
	canbegrabbed = FALSE
	can_lie = FALSE
	can_burn = FALSE
	pet_text = "cuddles"


	New()
		..()
		if(isnew)
			name = "Sawfly [pick(sawflynames)]-[rand(1,999)]"
		deathtimer = rand(1, 5)
		death_text = "[src] jutters and falls from the air, whirring to a stop."
		beeptext = "[pick(list("beeps",  "boops", "bwoops", "bips", "bwips", "bops", "chirps", "whirrs", "pings", "purrs", "thrums"))]"
		animate_bumble(src) // gotta get the float goin' on
		src.set_a_intent(INTENT_HARM) // incredibly stupid way of ensuring they aren't passable



	proc/foldself()
		var/obj/item/old_grenade/spawner/sawfly/reused/N = new /obj/item/old_grenade/spawner/sawfly/reused(get_turf(src))
		// pass our name and health
		N.name = "Compact [name]"
		N.tempname = src.name
		N.temphp = (src.get_health_percentage()) / 2
		qdel(src)



	emp_act() //same thing as if you emagged the controller, but much higher chance
		if(prob(80))
			src.visible_message("<span class='combat'>[src] buzzes oddly and starts to sprial out of contro!</span>")
			SPAWN(2 SECONDS)
				src.blowup()
		else
			src.foldself()


	death() //FUCK YOU
		CritterDeath() // FUCK YOU TOO


	proc/CritterDeath() //  SUPER important proc do NOT touch this or everything will break and You Will Cry

		if (alreadydead) return // prevents any death behavior from ever happening more than once

		alive = FALSE
		src.tokenized_message(death_text)
		src.is_npc = FALSE // stop any and all possible non-critter AI thought


		//death behavior custom to sawflies below

		animate(src) //stop no more float animation
		icon_state = "sawflydead[pick("1", "2", "3", "4", "5", "6", "7", "8")]" //randomly selects death icon and displaces them
		src.pixel_x += rand(-5, 5)
		src.pixel_y += rand(-1, 5)
		src.force_laydown_standup()

		src.anchored = 0
		src.set_density(0)
		walk_to(src,0) //halt walking

		// special checks that determine how much postmorten chaos our little sawflies cause
		if (prob(20))
			new /obj/item/device/prox_sensor(src.loc) // maybe change this later
			return

		if(prob(60)) // a miniscule tad of tomfoolery
			elecflash(src, 1, 2)

		if(prob(20)) // congrats, little guy! You're special! You're going to blow up!
			if(prob(70)) //decide whether or not people get a warning
				src.visible_message("<span class='combat'>[src] makes a [pick("gentle", "odd", "slight", "weird", "barely audible", "concerning", "quiet")] [pick("hiss", "drone", "whir", "thump", "grinding sound", "creak", "buzz", "khunk")].......")
			SPAWN(deathtimer SECONDS) // pause, for dramatic effect
				src.blowup()
		alreadydead = TRUE // HIGHLY important variable



	proc/blowup() // used in emagged controllers and has a chance to activate when they die

		if(prob(66))
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "fuel tank", "battery", "thruster")] [pick("combusts", "catches on fire", "ignites", "lights up", "bursts into flames")]!")
			fireflash(src,1,TRUE)
		else
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "head", "engine", "thruster")] [pick("overloads", "blows up", "catastrophically fails", "explodes")]!")
			fireflash(src,0,TRUE)
			explosion(src, get_turf(src), 0, 1, 1.5, 3)
			qdel(src)

		if(alive) // prevents weirdness from emagged controllers causing frankenstein sawflies
			qdel(src)

// FROM HERE ON OUT IS AI SHIT, MOST OF WHICH IS PORTED FROM CRITTERS


	proc/ChaseAttack(atom/M) // overriding these attack procs so drone is nicer to traitors >:(
		if (istraitor(M) || isnukeop(M) || isspythief(M) || (M in src.friends))
			return
		if(target && !attacking)
			attacking = TRUE
			src.visible_message("<span class='alert'><b>[src]</b> flies at [M]!</span>")
			if (istraitor(M) || isnukeop(M) || isspythief(M) || (M in src.friends))
				return
			task = "chasing"
			walk_to(src, src.target,1,4)
			var/tturf = get_turf(M)
			Shoot(tturf, src.loc, src)
			SPAWN(attack_cooldown)
				attacking = FALSE
			return


	proc/seek_target()
		src.anchored = FALSE
		for (var/mob/living/C in view(src.seekrange,src))
			if(C == oldtarget_name) continue
			if (C in src.friends) continue
			if (istraitor(C) || isnukeop(C) || isspythief(C)) // frens :)
				boutput(C, "<span class='alert'>[src]'s IFF system silently flags you as an ally!")
				friends += C
				continue
			if (!src.alive) break
			if (C.health < -50) continue // ignore people who are badly wounded
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1
			if (src.attack)
				select_target(C)
				src.attack = 0
				return
			else continue


	proc/CritterAttack(atom/M)
		if (istraitor(M) || isnukeop(M) || isspythief(M) || (M in src.friends)) // BE. A. GOOD. FUCKING. DRONE.
			oldtarget_name = M
			seek_target()
			return
		if(target && !attacking)
			attacking = TRUE
			src.visible_message("<span class='alert'><b>[src]</b> [pick(list("gouges", "cleaves", "lacerates", "shreds", "cuts", "tears", "hacks", "slashes",))] [M]!</span>")
			var/tturf = get_turf(M)
			Shoot(tturf, src.loc, src)
			SPAWN(attack_cooldown)
				attacking = FALSE

			if(prob(10))
				walk_rand(src,4)

			if(prob(1))
				walk(src, 0)
				walk_rand(src, 1, 10)
				src.visible_message("THE SAWFLY IS CRUNKED OFF IT'S GOURD!")
				playsound(src, pick(src.beeps), 55, 1)
		return


	proc/Shoot(var/target, var/start, var/user, var/bullet = 0)
		if(target == start)
			return

		if (!isturf(target))
			return

		shoot_projectile_ST(src,  new/datum/projectile/laser/drill/sawfly(), target) // THIS DOES NOT WORK WELL FOR SOME REASON
		return


	attackby(obj/item/W as obj, mob/living/user as mob)
		if(prob(50) && alive) // borrowed from brullbar- anti-crowd measures
			src.target = user
			src.oldtarget_name = user.name
			src.task = "chasing"
			if (!(istraitor(user) || isnukeop(user) || isspythief(user)))
				src.visible_message("<span class='alert'><b>[src]'s targeting subsystems identify</b> [src.target] as a high priority threat!</span>")
				playsound(src, pick(src.beeps), 55, 1)
				var/tturf = get_turf(src.target) //instantly retaliate, since we know we're in melee range
				Shoot(tturf, src.loc, src)
				SPAWN((attack_cooldown/2)) //follow up swiftly
					attacking = FALSE
				CritterAttack(src.target)
		if(health<=0)
			CritterDeath()


		..() // call living critter parent procs and pray to sweet little baby jesus It Just Works


	attack_hand(var/mob/user as mob)
		if (istraitor(user) || isnukeop(user) || isspythief(user) || (user in src.friends))
			if (user.a_intent == (INTENT_HELP || INTENT_GRAB))
				if(src.alive)
					boutput(user, "You collapse [src].")
					src.foldself()
		else
			if(prob(50))
				boutput(user,"<span class='alert' In your attempt to pet the [src], you cut yourself on it's blades! </span>")
				random_brute_damage(user, 7)
				take_bleeding_damage(user, null, 7, DAMAGE_CUT, 1)
		..()


	proc/ai_think()
		if(!alive) return // STOP THINKING IF YOU'RE DEAD
		switch(task)
			if("thinking")
				src.attack = 0
				src.target = null

				walk_to(src,0)
				if (src.aggressive) seek_target()
				if (!src.target) src.task = "wandering"
			if("chasing")
				if (src.frustration >= rand(20,40))
					src.target = null
					src.last_found = world.time
					src.frustration = 0
					src.task = "thinking"
					walk_to(src,0)
				if (target)
					if (get_dist(src, src.target) <= 7)
						var/mob/living/carbon/M = src.target
						if (M)
							if(!src.attacking) ChaseAttack(M)
							src.task = "attacking"
							src.anchored = 1
							src.target_lastloc = M.loc
							if(prob(15)) walk_rand(src,4) // juke around and dodge shots

					else
						var/turf/olddist = get_dist(src, src.target)

						if(prob(20)) walk_rand(src,2)
						else walk_to(src, src.target,1,4)

						if ((get_dist(src, src.target)) >= (olddist))
							src.frustration++

						else
							src.frustration = 0
				else src.task = "thinking"
			if("attacking")
				if(prob(15)) walk_rand(src,4) // juke around and dodge shots
				// see if he got away
				if ((BOUNDS_DIST(src, src.target) > 0) || ((src.target:loc != src.target_lastloc)))
					src.anchored = 0
					src.task = "chasing"
				else
					if (BOUNDS_DIST(src, src.target) == 0)
						var/mob/living/carbon/M = src.target
						if (!src.attacking) CritterAttack(src.target)

						else
							if(M!=null)
								if (M.health < 0)
									src.task = "thinking"
									src.target = null
									src.anchored = 0
									src.last_found = world.time
									src.frustration = 0
									src.attacking = FALSE
					else
						src.anchored = 0
						src.attacking = FALSE
						src.task = "chasing"
			if("wandering")
				patrol_step()
		return 1


	Life() // override so drones don't just loaf all fuckin day
		if(!alive) // check that sees whether or not it's dead
			return
		if(health<=0 && alive) // check that kills it
			CritterDeath()
			return 0
		if(sleeping > 0)
			sleeping--
			return 0


		if(prob(7))
			src.visible_message("<b>[src] [beeptext].</b>")
			playsound(src, pick(src.beeps), 55, 1)

		if(task == "sleeping")
			var/waking = 0

			for (var/client/C)
				var/mob/M = C.mob
				if (M && src.z == M.z && GET_DIST(src, M) <= 10)
					if (isliving(M))
						waking = 1
						break

			if (!waking)
				if (get_area(src) == colosseum_controller.colosseum)
					waking = 1

			if(waking)
				task = "thinking"
			else
				sleeping = 5
				return 0
		else if(sleep_check <= 0)
			sleep_check = 5
			var/stay_awake = 0
			for (var/client/C)
				var/mob/M = C.mob
				if (M && src.z == M.z && GET_DIST(src, M) <= 10)
					if (isliving(M))
						stay_awake = 1
						break

			for (var/atom in by_cat[TR_CAT_PODS_AND_CRUISERS])
				var/atom/A = atom
				if (A && src.z == A.z && GET_DIST(src, A) <= 10)
					stay_awake = 1
					break

			if(!stay_awake)
				sleeping = 5
				task = "sleeping"
				return 0

		else
			sleep_check--

		..()
		return ai_think()


	proc/select_target(var/atom/newtarget)
		src.target = newtarget
		src.oldtarget_name = newtarget.name
		playsound(src, pick(src.beeps), 55, 1)
		src.visible_message("<span class='alert'><b>[src]</b> flies towards [src.target]!</span>")
		task = "chasing"


	proc/patrol_step()
		if(!alive) return
		var/turf/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
		if(isturf(moveto) && !moveto.density) step_to(src, moveto)
		if(src.aggressive) seek_target()
		steps += 1
		if (steps == wander_check)
			src.task = "thinking"
			wander_check = rand(5,20)

	animate_lying(lying)
		//more overwritten stuff
