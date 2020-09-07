/mob/var/suiciding = 0
/mob/var/suicide_can_succumb = 0

/obj/var/custom_suicide = 0
/obj/var/suicide_distance = 1
/obj/proc/suicide(var/mob/user as mob)
	return

/obj/proc/user_can_suicide(var/mob/user as mob)
	if (!istype(user) || get_dist(user, src) > src.suicide_distance || user.stat || user.restrained() || user.getStatusDuration("paralysis") || user.getStatusDuration("stunned"))
		return 0
	return 1

/obj/item/var/suicide_in_hand = 1 // does it have to be held to be used for suicide?
/obj/item/user_can_suicide(var/mob/user as mob)
	if (!istype(user) || (src.suicide_in_hand && !user.find_in_hand(src)) || get_dist(user, src) > src.suicide_distance || user.stat || user.restrained() || user.getStatusDuration("paralysis") || user.getStatusDuration("stunned"))
		return 0
	return 1

// cirr here, the amount of code duplication for suicides a) made me sad and b) ought to have been in a parent proc to allow this functionality for everyone anyway
// the suiciding var is already at the mob level for fuck's sakes
/mob/verb/suicide()

	if (!isliving(src) || isdead(src))
		boutput(src, "You're already dead!")
		return

	if(src.suicide_can_succumb)
		if(alert(src, "You're suiciding. Are you sure you wish to succumb?", "Clippy's Very Best Suicide Helper", "Yes", "No") == "Yes")
			if(src.suicide_can_succumb)
				src.death()
			else
				boutput(src, "Sneaky sneaky little guy rrnt ya")
			return

	if(src.mind && src.mind.damned)
		boutput(src,"<span class='alert'>You can't suicide. You're already in hell!</span>")
		return


	if (!ticker)
		boutput(src, "You can't commit suicide before the game starts!")
		return

	if (!suicide_allowed)
		boutput(src, "You find yourself unable to go through with killing yourself!")
		return



	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		src.suiciding = 1
		if (src.client) // fix for "Cannot modify null.suicide"
			src.client.suicide = 1
		src.suicide_can_succumb = 1
		SPAWN_DBG(15 SECONDS)
			src.suicide_can_succumb = 0
		logTheThing("combat", src, null, "commits suicide")
		do_suicide() //                           <------ put mob unique behaviour here in an override!!!!
		if (src.suicide_alert)
			message_attack("[key_name(src)] commits suicide shortly after joining.")
			src.suicide_alert = 0
		SPAWN_DBG(20 SECONDS)
			src.suiciding = 0
		return
	else
		src.suiciding = 0


// !!!! OVERRIDE THIS PROC FOR YOUR NEW SUICIDE BEHAVIOUR FOR YOUR NEW FLYING CHAIR MOB OR WHATEVER !!!!
/mob/proc/do_suicide()
	.= 0

/mob/living/do_suicide()
	// default behaviour: just die, i guess
	src.unlock_medal("Damned", 1)
	src.death()

/mob/living/carbon/human/do_suicide()
	force_suicide() // something else in the codebase calls this without going through the suicide checks, so shrug

/mob/living/carbon/human/proc/force_suicide()
	if (src.client) // fix for "Cannot modify null.suicide"
		src.client.suicide = 1
	src.suiciding = 1
	src.unkillable = 0 //Get owned, nerd!

	var/list/suicides = list("hold your breath")
	if (src.on_chair)
		suicides += src.on_chair

	if (src.wear_mask && src.wear_mask.custom_suicide && !istype(src.wear_mask,/obj/item/clothing/mask/cursedclown_hat)) //can't stare into the cluwne mask's eyes while wearing it...
		suicides += src.wear_mask

	if (src.head && src.head.custom_suicide)
		suicides += src.head

	if (src.w_uniform && src.w_uniform.custom_suicide)
		suicides += src.w_uniform

	if (!src.restrained() && !src.getStatusDuration("paralysis") && !src.getStatusDuration("stunned"))
		if (src.l_hand && src.l_hand.custom_suicide)
			suicides += src.l_hand

		if (src.r_hand && src.r_hand.custom_suicide)
			suicides += src.r_hand

		for (var/obj/O in orange(1,src))
			LAGCHECK(LAG_HIGH)
			if (O.custom_suicide)
				if (isitem(O))
					var/obj/item/I = O
					if (I.suicide_in_hand)
						continue
				suicides += O

	if (suicides.len)
		var/obj/selection
		if (suicides.len == 1)
			selection = suicides[1]
		else
			selection = input(src, "Choose your death:", "Selection") as null|anything in suicides
		if (isnull(selection))
			if (src)
				src.suiciding = 0
			return

		src.unlock_medal("Damned", 1) //You don't get the medal if you tried to wuss out!

		if (!isnull(src.on_chair) && selection == src.on_chair)
			src.visible_message("<span class='alert'><b>[src] jumps off of the chair straight onto [his_or_her(src)] head!</b></span>")
			src.TakeDamage("head", 200, 0)
			SPAWN_DBG(50 SECONDS)
				if (src && !isdead(src))
					src.suiciding = 0
			src.pixel_y = 0
			reset_anchored(src)
			src.on_chair = 0
			src.buckled = null
			return
		else if (istype(selection))
			selection.suicide(src)
			SPAWN_DBG(50 SECONDS)
				if (src && !isdead(src))
					src.suiciding = 0
		else
			//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
			src.visible_message("<span class='alert'><b>[src] is holding [his_or_her(src)] breath. It looks like [he_or_she(src)]'s trying to commit suicide.</b></span>")
			src.take_oxygen_deprivation(175)
			SPAWN_DBG(20 SECONDS) //in case they get revived by cryo chamber or something stupid like that, let them suicide again in 20 seconds
				if (src && !isdead(src))
					src.suiciding = 0
			return
	return

/mob/living/silicon/ai/do_suicide()
	src.visible_message("<span class='alert'><b>[src] is powering down. It looks like \he's trying to commit suicide.</b></span>")
	src.unlock_medal("Damned", 1)
	SPAWN_DBG(3 SECONDS)
		src.death()

/mob/living/silicon/robot/do_suicide()
	var/mob/living/silicon/robot/R = src
	src.visible_message("<span class='alert'><b>[src] is clutching its head strangely!</b></span>")
	SPAWN_DBG(2 SECONDS)
		R.emote("scream")
	SPAWN_DBG(3 SECONDS)
		//src.visible_message("<span class='alert'><b>[src] has torn out its head!</b></span>")
		//playsound(R.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
		/*
		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(5, 1, src)
		s.start()
		R.part_head.set_loc(src.loc)
		R.part_head.holder = null
		R.part_head = null
		R.update_bodypart("head")
		R.module_active = null
		R.update_appearance()
		*/
		R.unlock_medal("Damned", 1)
		R.eject_brain()
		R.borg_death_alert(ROBOT_DEATH_MOD_SUICIDE)

/mob/living/silicon/ghostdrone/do_suicide()
	src.visible_message("<span class='alert'><b>[src] forcefully rips it's own soul from its body!</b></span>")
	src.unlock_medal("Damned", 1)
	src.death()

/mob/living/carbon/cube/do_suicide()
	src.unlock_medal("Damned", 1)
	pop()

/mob/living/critter/do_suicide() // :effort:
	src.visible_message("<span class='alert'><b>[src] suddenly dies for no adequately explained reason!</b></span>")
	src.unlock_medal("Damned", 1)
	src.death()

// instead of dying, flockdrone suicide should hand control back to the mobcritter AI
/mob/living/critter/flock/drone/do_suicide()
	emote("beep")
	say("\[System notification: self-aware drone has voluntarily surrendered its self-awareness and returned to basic function.\]")
	var/mob/living/C = src.controller
	src.release_control()
	if(C)
		C.suicide()
		C.unlock_medal("Damned", 1)
