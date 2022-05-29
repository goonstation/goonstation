/*
->The sawfly, by NightmareChamillian
This file is the critter itself, and all the custom procs it needs in order to function.

-For the AI, check the critter/AI folder, it should be in sawflyai.dm
-For the grenade and controller, check code/obj/sawflymisc.dm
*/
/mob/living/critter/sawfly

	name = "Armadyne antipersonnel microdrone"
	desc = "A folding antipersonnel drone of syndicate origin. It'd be pretty cute if it wasn't trying to kill people."
	icon = 'icons/obj/ship.dmi'//remnants of it originally being a drone
	icon_state = "sawfly"
	flags = TABLEPASS

	var/beeptext = " "
	//var/dead_state = "sawflydead" //not used- death sprites are handled in the death.dm folder
//	var/obj/item/droploot = null // the prox sensors they drop in death are handled in the critterdeath proc
	var/deathtimer = 0 // for catastrophic failure on death
	var/isnew = TRUE // for seeing whether or not they will make a new name on redeployment
	var/sawflynames = list("A", "B", "C", "D", "E", "F", "V", "W", "X", "Y", "Z", "Alpha", "Beta", "Gamma", "Lambda", "Delta")
	var/beeps = list('sound/machines/sawfly1.ogg','sound/machines/sawfly2.ogg','sound/machines/sawfly3.ogg') // custom noises so they cannot be mistaken for ghostdrones or borgs
	health = 40
	var/fliesnearby = 0 //for rolling chance to beep
	var/friends = list()
	misstep_chance = 30 //makes them behave more like drones

	//mob variables
	custom_gib_handler = /proc/robogibs
	isFlying = 1
	blood_id = "oil"
	use_stamina = FALSE
	use_stunned_icon = FALSE
	butcherable = FALSE
	can_bleed = FALSE
	canbegrabbed = FALSE
	can_lie = FALSE
	can_burn = FALSE
	pet_text = "cuddles"
	hand_count = 1 //stabby hands
	setup_healths()
		add_hh_robot(25, 1)
		add_hh_robot_burn(25, 1)



	New()
		..()
		if(isnew)
			name = "Sawfly [pick(sawflynames)]-[rand(1,999)]"
		deathtimer = rand(1, 5)
		death_text = "[src] jutters and falls from the air, whirring to a stop."
		beeptext = "[pick(list("beeps",  "boops", "bwoops", "bips", "bwips", "bops", "chirps", "whirrs", "pings", "purrs", "thrums"))]"
		animate_bumble(src) // gotta get the float goin' on
		src.set_a_intent(INTENT_HARM) // incredibly stupid way of ensuring they aren't passable but it works
		// ai setup
		src.mob_flags |= HEAVYWEIGHT_AI_MOB
		src.ai = new /datum/aiHolder/sawfly(src)
		src.is_npc = TRUE
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING


	proc/foldself()
		if(!isalive(src))
			return 0
		else
			var/obj/item/old_grenade/sawfly/reused/N = new /obj/item/old_grenade/sawfly/reused(get_turf(src))
			// pass our name and health
			N.name = "Compact [name]"
			N.tempname = src.name
			N.tempdam = (50 - src.health )
			qdel(src)


	proc/communalbeep() // distributes the beepchance among the number of sawflies nearby
		fliesnearby = 1 //that's you, little man! :)
		for_by_tcl(E, /mob/living/critter/sawfly)
			if(isalive(E))
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


	Cross(atom/movable/mover) //code that ensures projectiles hit them when they're alive, but won't when they're dead
		if(istype(mover, /obj/projectile))
			if(!isalive(src))
				return 1
		return ..()

//note: due to the AIholder's timed nature, they can still priority attack you if you're already targeted, but it's incredibly rare. Frankly I think it adds to the challenge.
	attackby(obj/item/W as obj, mob/living/user as mob)
		if(!(istraitor(user) || isnukeop(user) || isspythief(user) || (user in src.friends)))//are you an eligible target?
			if(prob(50) && isalive(src))//can we attack?
				if((ai.target != user)) //are we already attacking?
					ai.interrupt()//stop what you're doing!
					src.visible_message("<span class='alert'><b>[src]'s targeting subsystems identify [user] as a high priority threat!</b></span>")
					Shoot(get_turf(user), src.loc, src) //getting this to work in the AIholder was a pain in the butt so I'm moving it here
					SPAWN(5)
						Shoot(get_turf(user), src.loc, src)

		..()

	death()
		if(!isalive(src)) return//we already dead, somehow

		src.force_laydown_standup()
		src.visible_message("<span class='alert'[death_text]<span>")
		//for whatever whacky reason tokenized_message() does 2 messages so we gotta do it the old fashioned way
		src.is_npc = FALSE // //shut down the AI
		src.throws_can_hit_me = FALSE  //prevent getting hit by thrown stuff- important in avoiding jank
		animate(src) //no more float animation
		icon_state = "sawflydead[pick("1", "2", "3", "4", "5", "6", "7", "8")]" //randomly selects death icon and displaces them
		src.pixel_x += rand(-5, 5)
		src.pixel_y += rand(-1, 5)
		src.anchored = 0


		// special checks that determine how much damage they do after death
		if (prob(20))
			new /obj/item/device/prox_sensor(src.loc)
			return
		if(prob(60))
			elecflash(src, 1, 3)

		if(prob(22)) // congrats, little guy! You're special! You're going to blow up!
			if(prob(70)) //decide whether or not people get a warning
				src.visible_message("<span class='combat'>[src] makes a[pick(" gentle", "n odd", " slight", " weird", " barely audible", " concerning", " quiet")] [pick("hiss", "drone", "whir", "thump", "grinding sound", "creak", "buzz", "khunk")]...<span>")
			SPAWN(deathtimer SECONDS)
				src.blowup()




		..()
		// it is VITAL this goes after the parent so they don't show up as a whacky chunk of metal
		icon_state = "sawflydead[pick("1", "2", "3", "4", "5", "6", "7", "8")]" //randomly selects death icon and displaces them
		src.pixel_x += rand(-5, 5)
		src.pixel_y += rand(-1, 5)

	proc/blowup() // used in emagged controllers and has a chance to activate when they die
		if(prob(66))
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "fuel tank", "battery", "thruster")] [pick("combusts", "catches on fire", "ignites", "lights up", "bursts into flames")]!<span>")
			fireflash(src,1,TRUE)
		else
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "head", "engine", "thruster")] [pick("overloads", "blows up", "catastrophically fails", "explodes")]!<span>")
			fireflash(src,0,TRUE)
			explosion(src, get_turf(src), 0, 0.75, 1.5, 3)
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
		if(!isalive(src)) src.set_density(0) //according to lizzle something in the mob life resets density so this has to be below parent-

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
