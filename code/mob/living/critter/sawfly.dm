/*
->The sawfly, by NightmareChamillian
This file is the critter itself, and all the custom procs it needs in order to function.

-For the AI, check the critter/AI folder, it should be in sawflyai.dm
-For the grenade and controller, check code/obj/sawflymisc.dm
*/
/mob/living/critter/robotic/sawfly

	name = "Ranodyne antipersonnel microdrone"
	desc = "A folding antipersonnel drone, made by Ranodyne LLC. It'd be pretty cute if it wasn't trying to kill people."
	icon = 'icons/obj/items/sawfly.dmi'
	death_text = "%src% jutters and falls from the air, whirring to a stop."
	icon_state = "sawflydeploy"
	flags = TABLEPASS

	var/beeptext = " "
	var/deathtimer = 0 // for catastrophic failure on death
	var/isnew = TRUE // for seeing whether or not they will make a new name on redeployment
	var/sawflynames = list("A", "B", "C", "D", "E", "F", "V", "W", "X", "Y", "Z", "Alpha", "Beta", "Gamma", "Lambda", "Delta")

	var/dontdolife = TRUE // these two will be enabled and disabled at the grenade's leisure.
	is_npc = FALSE
	var/obj/item/old_grenade/sawfly/ourgrenade = null



	var/isdisabled = FALSE //stops life() from doing anything when in grenade form
	speechverb_say = "whirrs"
	speechverb_exclaim = "buzzes"
	speechverb_ask = "hums"
	health = 50 //this value's pretty arbitrary, since it's overridden when they get their healtholders
	var/beeps = list('sound/machines/sawfly1.ogg','sound/machines/sawfly2.ogg','sound/machines/sawfly3.ogg')
	var/friends = list()
	misstep_chance = 40 //makes them behave more like drones, and harder to kite into a straightaway then shoot
	var/list/dummy_params = list("icon-x" = 16, "icon-y" = 16) //for the manual attack_hand retaliation

	//mob variables
	custom_gib_handler = /proc/robogibs
	isFlying = 1
	can_grab = FALSE
	can_help = FALSE
	can_disarm = FALSE
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
		animate_bumble(src) // gotta get the float goin' on
		src.set_a_intent(INTENT_HARM) // incredibly stupid way of ensuring they aren't passable but it works
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/robot_base, "robot_health_slow_immunity") //prevents them from having movespeed slowdown when injured
		START_TRACKING

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new/datum/limb/sawfly_blades
		HH.name = "sawfly blades"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "sawflysaw"
		HH.limb_name = HH.name
		HH.can_hold_items = FALSE
		HH.can_range_attack = FALSE

	disposing()
		. = ..()
		STOP_TRACKING

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				playsound(src, pick(src.beeps), 40, 1)
				src.visible_message("<b>[src] [pick(list("beeps",  "boops", "bwoops", "bips", "bwips", "bops", "chirps", "whirrs", "pings", "purrs", "thrums"))].</b>")


	proc/foldself()
		if(!isalive(src))
			return
		else
			var/obj/item/old_grenade/sawfly/N = new /obj/item/old_grenade/sawfly(get_turf(src))
			// pass our name and health
			N.name = "Compact [name]"
			N.desc = "A self-deploying antipersonnel robot. This one has seen some use."
			//N.tempname = src.name
			src.is_npc = FALSE
			src.dontdolife = TRUE
			src.ourgrenade = N
			N.heldfly = src
			src.set_loc(N)


	proc/communalbeep() // distributes the beepchance among the number of sawflies nearby
		var/fliesnearby = 1 //for rolling chance to beep
		for_by_tcl(E, /mob/living/critter/robotic/sawfly)
			if(isalive(E) && IN_RANGE(src, E, 16)) //counts all of them within more or less earshot
				fliesnearby += 1 //that's your buddies!
		var/beepchance = (1 / fliesnearby) * 100 //if two sawflies, give 50% chance that any one will beep
		if(fliesnearby<3) beepchance -=20 //heavily reduce chance of beep in swarm
		if(prob(beepchance))
			if(isalive(src))
				playsound(src, pick(src.beeps), 40, 1)
				src.visible_message("<b>[src] [pick(list("beeps",  "boops", "bwoops", "bips", "bwips", "bops", "chirps", "whirrs", "pings", "purrs", "thrums"))].</b>")


	emp_act() // allows armory's pulse rifles to wreck their shit
		if(prob(80))
			src.visible_message("<span class='combat'>[src] buzzes oddly and starts to spiral out of control!</span>")
			SPAWN(2 SECONDS)
				src.blowup()
		else
			src.foldself()

	Cross(atom/movable/mover) //code that ensures projectiles hit them when they're alive, but won't when they're dead
		if(istype(mover, /obj/projectile))
			return !isalive(src)
		return ..()

//note: due to the AIholder's timed nature, they can still priority attack you if you're already targeted, but it's incredibly rare. Frankly I think it adds to the challenge.
//doublenote: the absolute agony that was trying to get this to function in any way that wasn't incredibly obtuse and hacky without going back to the projectile.
	attackby(obj/item/W as obj, mob/living/user as mob)
		if(!(istraitor(user) || isnukeop(user) || isspythief(user) || (user in src.friends)) || (user.health < 40))//are you an eligible target: nonantag or healthy enough?
			if(prob(50) && isalive(src))//now that you're eligible, are WE eligible?
				if((ai.target != user))
					ai.interrupt()//even though the AI doing this is nigh impossible, we'll still want to tell the AI that something's happening
					src.visible_message("<span class='alert'><b>[src]'s targeting subsystems identify [user] as a high priority threat!</b></span>")
					playsound(src, pick(src.beeps), 40, 1)
					//first attack is with the hand, so the sawfly can't triple attack if it was just now harming somone
					src.set_dir(get_dir(src, user))
					src.hand_attack(user, dummy_params)
					//second attack is hardcoded, since the limb has a cooldown of 1 seconds between attacks that interferes otherwise
					SPAWN(5)
						if(isalive(src) && IN_RANGE(src, user, 1)) //account for SPAWN() jank
							src.visible_message("<b class='alert'>[src] [pick(list("gouges", "carves", "cleaves", "lacerates", "shreds", "cuts", "tears", "saws", "mutilates", "hacks", "slashes"))] [user]!</b>")
							playsound(src, 'sound/machines/chainsaw_green.ogg', 50, 1)
							take_bleeding_damage(user, null, 10, DAMAGE_STAB)
							random_brute_damage(user, 14, TRUE)
		..()

	death(var/gibbed)
		if(!isalive(src)) return//we already dead, somehow

		src.force_laydown_standup()

		//for whatever whacky reason tokenized_message() does 2 messages so we gotta do it the old fashioned way
		src.is_npc = FALSE // //shut down the AI

		src.throws_can_hit_me = FALSE  //prevent getting hit by thrown stuff- important in avoiding jank

		if(!gibbed)
			animate(src) //no more float animation
			src.visible_message("<span class='alert'[death_text]<span>") //this has to be done here, and without tokenized message, otherwise it duplicates. Idunno why.
			src.anchored = 0
			desc = "A folding antipersonnel drone, made by Ranodyne LLC. It's totally wrecked."
		// checks that determine rolled behavior on death
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

	proc/blowup() //chance to activate when they die and get EMP'd
		if(prob(66))
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "fuel tank", "battery", "thruster")] [pick("combusts", "catches on fire", "ignites", "lights up", "bursts into flames")]!<span>")
			fireflash(src,1,TRUE)
		else
			src.visible_message("<span class='combat'>[src]'s [pick("motor", "core", "head", "engine", "thruster")] [pick("overloads", "blows up", "catastrophically fails", "explodes")]!<span>")
			fireflash(src,0,TRUE)
			explosion(src, get_turf(src), 0, 0.75, 1.5, 3)
			qdel(src)

		if(isalive(src)) // if they get EMP'd, they don't *actually* die, so we'll want to fix that
			qdel(src)

	attack_hand(var/mob/user as mob)
		if (issawflybuddy(user) || (user in src.friends))
			if (user.a_intent == INTENT_HELP || user.a_intent == INTENT_GRAB)
				if(isalive(src))
					src.is_npc = FALSE
					boutput(user, "You collapse [src].")
					src.foldself()
		else
			if(prob(50)&& isalive(src))
				boutput(user, "<span class='alert' In your attempt to pet [src], you cut yourself on it's blades!</span>")

				random_brute_damage(user, 7)
				take_bleeding_damage(user, null, 7, DAMAGE_CUT, 1)
		..()

	Life()
		if(src.dontdolife) //prevents them from doing much of anything when in grenade form
			return
		..()
		if(prob(8)) communalbeep()
		if(!isalive(src)) src.set_density(FALSE) //something in the mob life resets density so it has to be below parent

/mob/living/critter/robotic/sawfly/ai_controlled //don't use this normally- sawflies' AIs will be determined by the grenade
	New()
		..()
		// gotta get the AI chuggin' along
		src.mob_flags |= HEAVYWEIGHT_AI_MOB
		src.is_npc = TRUE
		src.dontdolife = FALSE
		src.ai = new /datum/aiHolder/sawfly(src)

/mob/living/critter/robotic/sawfly/standalone // for when you want to spawn a normal, set up sawfly.
	New()
		src.dontdolife = FALSE
		..()
