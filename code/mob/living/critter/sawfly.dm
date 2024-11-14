/*
->The sawfly, by NightmareChamillian
This file is the critter itself, and all the custom procs it needs in order to function.

-For the AI, sawflies use a mostly generic critter AI with some localized baked-in changes
-For the grenade and controller, check code/obj/sawflymisc.dm
*/
/mob/living/critter/robotic/sawfly
	name = "\improper Ranodyne antipersonnel microdrone"
	desc = "A folding antipersonnel drone, made by Ranodyne LLC. It'd be pretty cute if it wasn't trying to kill people."
	icon = 'icons/obj/items/sawfly.dmi'
	death_text = "%src% jutters and falls from the air, whirring to a stop."
	icon_state = "sawflydeploy"
	flags = TABLEPASS

	var/sawflynames = list("A", "B", "C", "D", "E", "F", "V", "W", "X", "Y", "Z", "Alpha", "Beta", "Gamma", "Lambda", "Delta")
	var/static/list/priority_target_jobs = list("Head of Security", "Security Officer", "Nanotrasen Security Consultant")
	var/datum/weakref/master = null //first friendly they imprint upon for /datum/aiTask/timed/targeted/follower
	var/obj/item/old_grenade/sawfly/ourgrenade = null

	speechverb_say = "whirrs"
	speechverb_exclaim = "buzzes"
	speechverb_ask = "hums"
	health = 50 //this value's pretty arbitrary, since it's overridden when they get their healtholders
	var/beeps = list('sound/machines/sawfly1.ogg','sound/machines/sawfly2.ogg','sound/machines/sawfly3.ogg')
	var/retaliate = FALSE
	misstep_chance = 40 //makes them behave more like drones, and harder to kite into a straightaway then shoot

	HELP_MESSAGE_OVERRIDE({"Syndicate only: can be walked through if your intent is set to <span class='help'>help</span>. To deactivate, use the remote or (syndicate only) click on the sawfly with <span class='help'>help</span> or <span class='grab'>grab</span> intent."})

	//mob variables
	isFlying = 1
	can_grab = FALSE
	can_help = FALSE
	can_disarm = FALSE
	use_stamina = FALSE
	use_stunned_icon = FALSE
	canbegrabbed = FALSE
	can_lie = FALSE
	can_burn = FALSE
	pet_text = "cuddles"
	hand_count = 1 //stabby hands
	ailment_immune = TRUE

	faction = list(FACTION_SYNDICATE)

	New()
		..()
		remove_lifeprocess(/datum/lifeprocess/blindness)
		remove_lifeprocess(/datum/lifeprocess/blood)

		if(name == initial(name))
			name = "sawfly [pick(sawflynames)]-[rand(1,999)]"

		animate_bumble(src) // gotta get the float goin' on
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/robot_part/robot_base, "robot_health_slow_immunity") //prevents them from having movespeed slowdown when injured
		START_TRACKING

	setup_healths()
		add_hh_robot(25, 1)
		add_hh_robot_burn(25, 1)

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
		if(isdead(src))
			return
		else
			var/obj/item/old_grenade/sawfly/N = new /obj/item/old_grenade/sawfly(get_turf(src))
			// pass our name and health
			N.name = "Compact [name]"
			N.desc = "A self-deploying antipersonnel robot. This one has seen some use."
			//N.tempname = src.name
			src.ai?.disable()
			src.ourgrenade = N
			N.heldfly = src
			src.set_loc(N)

	emp_act() // allows armory's pulse rifles to wreck their shit
		if(prob(80))
			src.visible_message(SPAN_COMBAT("[src] buzzes oddly and starts to spiral out of control!"))
			SPAWN(2 SECONDS)
				src.blowup()
		else
			src.foldself()

	Cross(atom/movable/mover)

		//since sawflies have a density of 1 and will auto-set intent to harm, we have to recode tile-sharing
		if(istype(mover, /mob/living))
			var/mob/living/movingmob = mover
			if((issawflybuddy(movingmob)) && (movingmob.a_intent == INTENT_HELP))
				return TRUE
			else
				return ..() //default behavior

		//code that ensures projectiles hit them when they're alive, but won't when they're dead
		if(istype(mover, /obj/projectile)) //hardcoding for bullets going over dead bodies
			return isdead(src)

		return ..()

	attackby(obj/item/W as obj, mob/living/user as mob)
		do_retaliate(user)
		..()

	proc/do_retaliate(mob/living/user)
		if(!(issawflybuddy(user) || (user in src.friends) || (user.health < 40)))//are you an eligible target: nonantag or healthy enough?
			if(prob(50) && !ON_COOLDOWN(src, "sawfly_retaliate_cd", 5 SECONDS) && !isdead(src))//now that you're eligible, are WE eligible?
				if(ai && (ai.target != user))
					src.lastattacker = user
					src.retaliate = TRUE
					src.visible_message(SPAN_ALERT("<b>[src]'s targeting subsystems identify [user] as a high priority threat!</b>"))
					playsound(src, pick(src.beeps), 40, 1)
					ai.interrupt()

	death(var/gibbed)
		if(isdead(src)) return//we already dead, somehow
		src.force_laydown_standup()
		src.ai?.disable() //shut down the AI
		src.throws_can_hit_me = FALSE  //prevent getting hit by thrown stuff- important in avoiding jank

		if(!gibbed)
			animate(src) //no more float animation
			src.anchored = UNANCHORED
			desc = "A folding antipersonnel drone, made by Ranodyne LLC. It's totally wrecked."

			//time to roll for death effects
			if(prob(60))
				elecflash(src, 1, 3)

			if(prob(22)) // congrats, little guy! You're special! You're going to blow up!
				if(prob(70)) //decide whether or not people get a warning
					src.visible_message(SPAN_COMBAT("[src] makes a[pick(" gentle", "n odd", " slight", " weird", " barely audible", " concerning", " quiet")] [pick("hiss", "drone", "whir", "thump", "grinding sound", "creak", "buzz", "khunk")]..."))
				SPAWN(rand(1, 5) SECONDS)
					src?.blowup()

		..()
		// it is VITAL this goes after the parent so they don't show up as a whacky chunk of metal
		icon_state = "sawflydead[pick("1", "2", "3", "4", "5", "6", "7", "8")]" //randomly selects death icon and displaces them
		src.pixel_x += rand(-5, 5)
		src.pixel_y += rand(-1, 5)

		remove_lifeprocess(/datum/lifeprocess/disability)
		remove_lifeprocess(/datum/lifeprocess/hud)
		remove_lifeprocess(/datum/lifeprocess/mutations)
		remove_lifeprocess(/datum/lifeprocess/organs)
		remove_lifeprocess(/datum/lifeprocess/sight)
		remove_lifeprocess(/datum/lifeprocess/statusupdate)


	proc/blowup() //chance to activate when they die and get EMP'd
		if(prob(66))
			src.visible_message(SPAN_COMBAT("[src]'s [pick("motor", "core", "fuel tank", "battery", "thruster")] [pick("combusts", "catches on fire", "ignites", "lights up", "bursts into flames")]!"))
			fireflash(src,1, checkLos = FALSE, chemfire = CHEM_FIRE_RED)
		else
			src.visible_message(SPAN_COMBAT("[src]'s [pick("motor", "core", "head", "engine", "thruster")] [pick("overloads", "blows up", "catastrophically fails", "explodes")]!"))
			fireflash(src,0, checkLos = FALSE, chemfire = CHEM_FIRE_RED)
			explosion(src, get_turf(src), 0, 0.75, 1.5, 3)
			qdel(src)

		if(!isdead(src)) // if they get EMP'd, they don't *actually* die, so we'll want to fix that
			qdel(src)

	attack_hand(var/mob/user as mob)
		if (user.a_intent == INTENT_HELP || user.a_intent == INTENT_GRAB)
			if (issawflybuddy(user) || (user in src.friends))
				if(!isdead(src))
					src.ai?.disable()
					boutput(user, "You collapse [src].")
					src.foldself()
			else
				if(prob(50)&& !isdead(src))
					boutput(user, SPAN_ALERT("In your attempt to pet [src], you cut yourself on it's blades!"))
				random_brute_damage(user, 7)
				take_bleeding_damage(user, null, 7, DAMAGE_CUT, 1)
		else //harm or shove intent is an attack
			do_retaliate(user)
		..()

	proc/dobeep()
		if(isturf(src.loc) && !isdead(src))
			playsound(src, pick(src.beeps), 40, 1)
			src.visible_message("<b>[src] [pick(list("beeps",  "boops", "bwoops", "bips", "bwips", "bops", "chirps", "whirrs", "pings", "purrs", "thrums"))].</b>")

	Life()
		..()

		if(prob(5)) //roll chance to beep
			dobeep()

	seek_target(range) //ai mob critter targetting behaviour - returns a list of acceptable targets
		if(src.lastattacker && src.retaliate && GET_DIST(src, src.lastattacker) <= range)
			return list(src.lastattacker)
		var/targetcount = 0
		. = list()
		for (var/mob/living/C in viewers(range, src))
			if (C.health < -50 || isdead(C))
				continue
			if(istype(C, /mob/living/critter/robotic/sawfly))
				continue
			if (isintangible(C))
				continue
			if(C.mind?.special_role && issawflybuddy(C))
				if(!(C.weakref in src.friends))
					src.friends += get_weakref(C)
					if(src.master == null)
						src.master = get_weakref(C) //assign only one master
						boutput(C, SPAN_ALERT("[src]'s IFF system silently flags you as its master!"))
					else
						boutput(C, SPAN_ALERT("[src]'s IFF system silently flags you as an ally!"))
				continue
			if(C.job in priority_target_jobs)
				. = list(C) //go get em, tiger
				return
			. += C //you passed all the checks, now you get added to the list for consideration

			targetcount++
			if(targetcount >= 8) //prevents them from getting too hung up on finding folks
				break

	critter_attack(var/mob/target)
		if(src.retaliate)
			src.retaliate = FALSE
			..() //double stab for hitting back
			OVERRIDE_COOLDOWN(src, "sawfly_attackCD", 0 SECONDS)
		..()

/mob/living/critter/robotic/sawfly/ai_controlled //don't use this normally- sawflies' AIs will be determined by the grenade
	New()
		..()
		// gotta get the AI chuggin' along
		src.mob_flags |= HEAVYWEIGHT_AI_MOB
		src.is_npc = TRUE
		src.ai = new /datum/aiHolder/aggressive(src)

