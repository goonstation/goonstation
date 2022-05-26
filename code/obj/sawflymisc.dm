/* master file for all objects pertaining to sawfly that don't really go anywhere else
 -->Includes:
-All grenades- reused, cluster and normal
-The remote
-The limb that shoots the blade
-The critter itself

-->Things it DOES NOT include that are sawfly-related, and where they can be found:
-The pouch of sawflies for nukies at the bottom of ammo pouches.dm
-The projectile they use is midway through laser.dm, with the other melee drone projectiles.
-Their AI, which can be found in mob/living/critter/ai/sawfly.dm
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


/datum/limb/gun/sawfly_blades //OP as shit for the sake of the AI if a player ever uses this, make a weaker version
	proj = new/datum/projectile/laser/drill/sawfly
	shots = 1
	current_shots = 1
	cooldown = 1
	reload_time = 1
	reloading_str = "cooling"

//the star of the show!!!
/mob/living/critter/sawfly

	name = "Sawfly flock code"
	desc = "A folding antipersonnel drone of syndicate origin. It'd be pretty cute if it wasn't trying to kill people."
	icon = 'icons/obj/ship.dmi'
	icon_state = "sawfly"
	flags = TABLEPASS

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
	var/fliesnearby = 0 //for rolling chance to beep
	var/friends = list()
	misstep_chance = 30 //makes them behave more like drones

	hand_count = 1 //stabby hands
	setup_healths()
		add_hh_robot(20, 1)
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
		// ai setup
		src.mob_flags |= HEAVYWEIGHT_AI_MOB
		src.ai = new /datum/aiHolder/sawfly(src)
		src.is_npc = TRUE
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING


	proc/foldself()
		var/obj/item/old_grenade/sawfly/reused/N = new /obj/item/old_grenade/sawfly/reused(get_turf(src))
		// pass our name and health
		N.name = "Compact [name]"
		N.tempname = src.name
		N.temphp = (src.health)
		qdel(src)

	proc/communalbeep() // distributes the beepchance among the number of sawflies nearby
		fliesnearby = 1 //that's you, little man! :)
		for(var/mob/living/critter/sawfly/E in range(get_turf(src), 18))
			if(isalive(src))
				src.fliesnearby += 1 //that's your buddies!
		var/beepchance = (1 / fliesnearby) * 100 //if two sawflies, give 50% chance that any one will beep
		if(fliesnearby<3) beepchance -=20 //heavily reduce chance of beep in swarm
		if(prob(beepchance))
			if(isalive(src))
				playsound(src, pick(src.beeps), 40, 1)
				src.visible_message("<b>[src] [beeptext].</b>")



	emp_act() //same thing as if you emagged the controller, but much higher chance
		if(prob(80))
			src.visible_message("<span class='combat'>[src] buzzes oddly and starts to spiral out of control!</span>")
			SPAWN(2 SECONDS)
				src.blowup()
		else
			src.foldself()


	Cross(atom/movable/mover) //code that ensure projectiles hit them when they're alive, but won't when they're dead
		if(istype(mover, /obj/projectile))
			if(!isalive(src))
				return 1
		return ..()

//note: due to the AIholder's way of being timed, they can still attack priority attack you if you're already getting hit, but you have to time it just right
	attackby(obj/item/W as obj, mob/living/user as mob)
		if(!(istraitor(user) || isnukeop(user) || isspythief(user) || (user in src.friends)))//are you an eligible target?
			if(prob(50) && isalive(src))//can we attack?
				if((ai.target != user)) //are we already attacking?
					ai.interrupt()//stop what you're doing
					src.visible_message("<span class='alert'><b>[src]'s targeting subsystems identify [user] as a high priority threat!</b></span>")
					Shoot(get_turf(user), src.loc, src) //getting this to work in the AIholder was a pain in the butt
					SPAWN(5)
						Shoot(get_turf(user), src.loc, src)

		..()

	death()
		if(!isalive(src)) return//we already dead, somehow

		src.set_density(0)
		src.set_a_intent(INTENT_HELP)
		src.force_laydown_standup()
		src.tokenized_message(death_text)
		src.is_npc = FALSE // //shut down the AI
		src.throws_can_hit_me = FALSE  //prevent getting hit by thrown stuff- super important in avoiding jank


		animate(src) //stop no more float animation
		icon_state = "sawflydead[pick("1", "2", "3", "4", "5", "6", "7", "8")]" //randomly selects death icon and displaces them
		src.pixel_x += rand(-5, 5)
		src.pixel_y += rand(-1, 5)
		src.anchored = 0
		//walk_to(src,0) //halt walking



		// special checks that determine how much damage they do after death
		if (prob(20))
			new /obj/item/device/prox_sensor(src.loc)
			return
		if(prob(60))
			elecflash(src, 1, 3)

		if(prob(20)) // congrats, little guy! You're special! You're going to blow up!
			if(prob(70)) //decide whether or not people get a warning
				src.visible_message("<span class='combat'>[src] makes /a [pick("gentle", "odd", "slight", "weird", "barely audible", "concerning", "quiet")] [pick("hiss", "drone", "whir", "thump", "grinding sound", "creak", "buzz", "khunk")]...")
			SPAWN(deathtimer SECONDS)
				src.blowup()


		remove_lifeprocess(/datum/lifeprocess/blood) //so apparently the reduce_lifeprocess_on_death() proc is limited to only the small animals
		remove_lifeprocess(/datum/lifeprocess/canmove)
		remove_lifeprocess(/datum/lifeprocess/disability)
		remove_lifeprocess(/datum/lifeprocess/fire)
		remove_lifeprocess(/datum/lifeprocess/hud)
		remove_lifeprocess(/datum/lifeprocess/mutations)
		remove_lifeprocess(/datum/lifeprocess/organs)
		remove_lifeprocess(/datum/lifeprocess/sight)
		remove_lifeprocess(/datum/lifeprocess/skin)
		remove_lifeprocess(/datum/lifeprocess/statusupdate)

		..()
		// it is VITAL this goes after the parent so they don't show up as a whacky chunk of metal
		icon_state = "sawflydead[pick("1", "2", "3", "4", "5", "6", "7", "8")]" //randomly selects death icon and displaces them
		src.pixel_x += rand(-5, 5)
		src.pixel_y += rand(-1, 5)
	proc/blowup() // used in emagged controllers and has a chance to activate when they die

		if(prob(66))
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "fuel tank", "battery", "thruster")] [pick("combusts", "catches on fire", "ignites", "lights up", "bursts into flames")]!")
			fireflash(src,1,TRUE)
		else
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "head", "engine", "thruster")] [pick("overloads", "blows up", "catastrophically fails", "explodes")]!")
			fireflash(src,0,TRUE)
			explosion(src, get_turf(src), 0, 1, 1.5, 3)
			qdel(src)

		if(isalive(src)) // prevents weirdness from emagged controllers causing frankenstein sawflies
			qdel(src)



	attack_hand(var/mob/user as mob)
		if (istraitor(user) || isnukeop(user) || isspythief(user) || (user in src.friends))
			if (user.a_intent == (INTENT_HELP || INTENT_GRAB))
				if(isalive(src))
					boutput(user, "You collapse [src].")
					src.foldself()
		else
			if(prob(50))
				boutput(user,"<span class='alert' In your attempt to pet the [src], you cut yourself on its blades! </span>")
				random_brute_damage(user, 7)
				take_bleeding_damage(user, null, 7, DAMAGE_CUT, 1)
		..()


	Life()
		..()
		if(prob(5)) communalbeep()
		if(!isalive(src)) src.set_density(0) //according to lizzle something in the mob life resets density so this has to be below parent

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/sawfly_blades
		HH.name = "sawfly blades"
		HH.limb_name = HH.name
		HH.can_hold_items = FALSE
		HH.can_range_attack = TRUE

	proc/Shoot(var/target, var/start, var/user, var/bullet = 0)
		if(prob(5)) communalbeep()
		if(target == start)
			return
		if (!isturf(target))
			return

		shoot_projectile_ST(src,  new/datum/projectile/laser/drill/sawfly(), target)
		return


/datum/limb/gun/flock_stunner/attack_range(atom/target, var/mob/living/critter/flock/drone/user, params)
	if(!target || !user)
		return
	return ..()
