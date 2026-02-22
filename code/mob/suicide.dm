/mob/var/suiciding = 0

/obj/var/custom_suicide = 0
/obj/var/suicide_distance = 1
/obj/proc/suicide(var/mob/user as mob)
	return

/obj/proc/user_can_suicide(var/mob/user as mob)
	if (!istype(user) || GET_DIST(user, src) > src.suicide_distance || user.stat || user.restrained() || user.getStatusDuration("unconscious") || user.getStatusDuration("stunned"))
		return FALSE
	return TRUE

/obj/item/var/suicide_in_hand = TRUE // does it have to be held to be used for suicide?
/obj/item/user_can_suicide(var/mob/user as mob)

	if (!istype(user) || (src.suicide_in_hand && !user.find_in_hand(src)) || GET_DIST(user, src) > src.suicide_distance || user.stat || user.restrained() || user.getStatusDuration("unconscious") || user.getStatusDuration("stunned"))
		return FALSE
	return TRUE

/mob/verb/suicide()

	if ((!isliving(src) || isdead(src)) && !isAIeye(src))
		boutput(src, SPAN_ALERT("You're already dead!"))
		return

	if(src.suiciding)
		if(tgui_alert(src, "You're suiciding. Are you sure you wish to succumb?", "Clippy's Very Best Suicide Helper", list("Yes", "No"), 15 SECONDS) == "Yes")
			if(src.suiciding)
				src.death()
			else
				boutput(src, SPAN_ALERT("Too late! You've decided to live on."))
		return

	if (src.health < 0)
		succumb()
		return

	if(src.mind && src.mind.damned)
		boutput(src,SPAN_ALERT("You can't suicide. You're already in hell!"))
		return

	if(src.is_zombie)
		boutput(src,SPAN_ALERT("You can't suicide. Brains..."))
		return

	if (!ticker)
		boutput(src, SPAN_ALERT("You can't commit suicide before the game starts!"))
		return

	if (!suicide_allowed)
		boutput(src, SPAN_ALERT("You find yourself unable to go through with killing yourself!"))
		return

	var/area/area = get_area(src)
	if (area?.sanctuary)
		boutput(src, SPAN_ALERT("You can't hurt yourself here."))
		return

	if (locate(/datum/ailment/parasite/headspider) in src.ailments)
		boutput(src, SPAN_ALERT("You feel a deep alien hunger for survival crush your attempt to escape your fate."))
		return

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(HAS_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM))
			boutput(H, SPAN_ALERT("You cannot bring yourself to commit suicide!"))
			return

	if (src.do_suicide()) //                           <------ put mob unique behaviour here in an override!!!!
		src.suiciding = TRUE
		logTheThing(LOG_COMBAT, src, "commits suicide")
		src.unlock_medal("Damned", 1) //You don't get the medal if you tried to wuss out!
		if (src.suiciding)
			if (src.suicide_alert)
				message_attack("[key_name(src)] commits suicide shortly after joining.")
				src.suicide_alert = FALSE
	else //they didn't do it!!!
		src.suiciding = FALSE



// !!!! OVERRIDE THIS PROC FOR YOUR NEW SUICIDE BEHAVIOUR FOR YOUR NEW FLYING CHAIR MOB OR WHATEVER !!!!
/mob/proc/do_suicide()
	.= FALSE

/mob/living/do_suicide()
	// default behaviour: just die, i guess
	var/confirm = tgui_alert(src, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"), 15 SECONDS)

	if(confirm == "Yes")
		src.unlock_medal("Damned", 1)
		src.death()
		return TRUE

	return FALSE

/mob/living/carbon/human/do_suicide()
	src.unkillable = 0 //Get owned, nerd!

	var/list/suicides = list("hold your breath")
	if (src.on_chair)
		suicides[src.on_chair.name] = src.on_chair

	for (var/obj/item/equipped in (src.get_equipped_items() + src.l_hand + src.r_hand))
		if (equipped.custom_suicide)
			suicides[equipped.name] = equipped

	if (!src.restrained() && !src.getStatusDuration("unconscious") && !src.getStatusDuration("stunned"))
		for (var/obj/O in orange(1,src))
			LAGCHECK(LAG_HIGH)
			if (O.custom_suicide && can_reach(src, O))
				if (isitem(O))
					var/obj/item/I = O
					if (I.suicide_in_hand)
						continue
				suicides[O.name] = O

	var/obj/selection //the thing we're suiciding on
	selection = tgui_input_list(src, "Choose your death:", "Selection", suicides, 10 SECONDS) //grab the name

	if (isnull(selection))
		return FALSE

	if (selection == "hold your breath") //breath suicide - special case, non-associative
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		src.visible_message(SPAN_ALERT("<b>[src] is holding [his_or_her(src)] breath. It looks like [hes_or_shes(src)] trying to commit suicide.</b>"))
		src.take_oxygen_deprivation(175)
		SPAWN(20 SECONDS) //dunno why this one is only 20 seconds but I guess I'll preserve that
			if (src && !isdead(src))
				src.suiciding = 0
		return TRUE

	selection = suicides[selection] //grab the actual object

	if (selection == src.on_chair) //chair suicide
		if (!src.on_chair)
			return FALSE //can't suicide on a chair when you aren't on a chair
		src.visible_message(SPAN_ALERT("<b>[src] jumps off of the chair straight onto [his_or_her(src)] head!</b>"))
		src.TakeDamage("head", 200, 0)
		src.pixel_y = 0
		reset_anchored(src)
		src.on_chair = null
		src.buckled = null

	else if (!selection.suicide(src))
		return FALSE //didn't work out, abort

	SPAWN(45 SECONDS)
		if (src && !isdead(src)) //if they're still alive they got saved, probably
			src.suiciding = 0

	return TRUE // we suicided somewhere up there

/mob/living/intangible/aieye/do_suicide()
	src.return_mainframe()
	src.mainframe.do_suicide()

/mob/living/silicon/ai/do_suicide()
	var/confirm = tgui_alert(src, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"), 15 SECONDS)
	if (confirm == "Yes")
		src.visible_message(SPAN_ALERT("<b>[src] is powering down. It looks like \he's trying to commit suicide.</b>"))
		src.unlock_medal("Damned", 1)
		SPAWN(3 SECONDS)
			src.death()
		return TRUE
	return FALSE

/mob/living/silicon/robot/do_suicide()
	var/confirm = tgui_alert(src, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"), 15 SECONDS)
	if (confirm == "Yes")
		var/mob/living/silicon/robot/R = src
		src.visible_message(SPAN_ALERT("<b>[src] is clutching its head strangely!</b>"))
		SPAWN(2 SECONDS)
			R.emote("scream")
		SPAWN(3 SECONDS)
			R.unlock_medal("Damned", 1)
			R.eject_brain()
			R.borg_death_alert(ROBOT_DEATH_MOD_SUICIDE)
		return TRUE
	return FALSE

/mob/living/silicon/ghostdrone/do_suicide()
	. = ..()
	if (.)
		src.visible_message(SPAN_ALERT("<b>[src] forcefully rips it's own soul from its body!</b>"))

/mob/living/carbon/cube/do_suicide()
	src.unlock_medal("Damned", 1)
	pop()

/mob/living/critter/do_suicide() // :effort:
	. = ..()
	if (.)
		src.visible_message(SPAN_ALERT("<b>[src] suddenly dies for no adequately explained reason!</b>"))

/mob/living/critter/flock/drone/do_suicide()
	if ((locate(/obj/flock_structure/relay) in src.flock.structures) && istype(src.controller, /mob/living/intangible/flock/flockmind) && !length(src.flock.getActiveTraces()))
		boutput(src, SPAN_ALERT("You can't abandon your Flock with the Relay active!"))
		return
	if (tgui_alert(src, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"), theme = "flock") == "Yes")
		var/mob/living/intangible/flock/C = src.controller
		src.release_control()
		C.do_suicide(TRUE)

/mob/living/intangible/flock/do_suicide(skip_prompt) // override, skip_prompt should be true for suiciding while in a drone
	return

/mob/living/intangible/flock/flockmind/do_suicide(skip_prompt)
	if ((locate(/obj/flock_structure/relay) in src.flock.structures) && !length(src.flock.getActiveTraces()))
		boutput(src, SPAN_ALERT("You can't abandon your Flock with the Relay active!"))
		return
	if (skip_prompt || tgui_alert(src, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"), theme = "flock") == "Yes")
		var/result = src.getTraceToPromote()
		if (istype(result, /mob/living/intangible/flock/trace))
			src.unlock_medal("Damned", 1)
			var/mob/living/intangible/flock/trace/T = result
			T.promoteToFlockmind(TRUE)
		else if (result == -1)
			src.unlock_medal("Damned", 1)
			src.death(suicide = TRUE)

/mob/living/intangible/flock/trace/do_suicide(skip_prompt)
	if (skip_prompt || tgui_alert(src, "Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"), theme = "flock") == "Yes")
		src.unlock_medal("Damned", 1)
		src.death(suicide = TRUE)
