////////////////// MISC BULLSHIT //////////////////

/mob/proc/fake_damage(var/amount,var/seconds)
	if (!amount || !seconds)
		return

	src.fakeloss += amount

	SPAWN(seconds * 10)
		src.fakeloss -= amount

/proc/get_mobs_of_type_at_point_blank(var/atom/object,var/mob_path)
	var/list/returning_list = list()
	if (!object || !mob_path)
		return returning_list

	if (istype(object,/area/))
		return returning_list

	for (var/mob/L in range(1,object))
		if (istype(L,mob_path))
			returning_list += L

	return returning_list

/proc/get_mobs_of_type_in_view(var/atom/object,var/mob_path)
	var/list/returning_list = list()
	if (!object || !mob_path)
		return returning_list

	if (istype(object,/area/))
		return returning_list

	for (var/mob/L in view(7,object))
		if (istype(L,mob_path))
			returning_list += L

	return returning_list

/mob/proc/get_current_active_item()
	return null

/mob/living/carbon/human/get_current_active_item()
	if (src.hand)
		return src.r_hand
	else
		return src.l_hand

/mob/living/silicon/robot/get_current_active_item()
	return src.module_active

/mob/proc/get_temp_deviation()
	var/tempdiff = src.bodytemperature - src.base_body_temp
	var/tol = src.temp_tolerance
	var/ntl = 0 - src.temp_tolerance // these are just to make the switch a bit easier to look at

	if (tempdiff > tol*3.5)
		return 4 // some like to be on fire
	else if (tempdiff < ntl*3.5)
		return -4 // i think my ears just froze off oh god
	else if (tempdiff > tol*2.5)
		return 3 // some like it too hot
	else if (tempdiff < ntl*2.5)
		return -3 // too chill
	else if (tempdiff > tol*1.5)
		return 2 // some like it hot
	else if (tempdiff < ntl*1.5)
		return -2 // pretty chill
	else if (tempdiff > tol*0.5)
		return 1 // some like it warm
	else if (tempdiff < ntl*0.5)
		return -1 // a little bit chill
	else
		return 0 // I'M APOLLO JUSTICE AND I'M FINE

/mob/proc/is_cold_resistant()
	if (!src)
		return 0
	if(src.bioHolder?.HasEffect("cold_resist") || src.bioHolder?.HasEffect("thermal_resist") > 1)
		return 1
	if(ischangeling(src))
		return 1
	if(src.nodamage)
		return 1
	return 0


// Hallucinations

/mob/living/proc/hallucinate_fake_melee_attack()
	var/list/PB_mobs = get_mobs_of_type_at_point_blank(src,/mob/living/)
	var/mob/living/H = pick(PB_mobs)
	if (H.stat)
		return
	var/obj/item/I = H.get_current_active_item()

	if (istype(I))
		boutput(src, SPAN_ALERT("<b>[H.name] attacks [src.name] with [I]!</b>"))
		if (I.hitsound)
			src.playsound_local(src.loc, I.hitsound, 50, 1)
		src.fake_damage(I.force,100)
	else
		if (!ishuman(H))
			return
		if (!src.canmove)
			src.playsound_local(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 25, 1, -1)
			boutput(src, SPAN_ALERT("<B>[H.name] kicks [src.name]!</B>"))
		else
			src.playsound_local(src.loc, pick(sounds_punch), 25, 1, -1)
			boutput(src, SPAN_ALERT("<B>[H.name] punches [src.name]!</B>"))
		src.fake_damage(rand(2,9),100)
	hit_twitch(src)

///////////////
// Anomalies //
///////////////

/obj/anomaly
	name = "anomaly"
	desc = "swirly thing alert!!!!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	density = 1
	opacity = 0
	anchored = ANCHORED
	event_handler_flags = IMMUNE_TRENCH_WARP
	var/has_processing_loop = 0

	New(var/turf/loc)
		..()
		if (has_processing_loop)
			global.processing_items.Add(src)
		return

	disposing()
		if (has_processing_loop)
			global.processing_items.Remove(src)
		..()

	proc/process()
		return 0

/obj/anomaly/test
	name = "boing anomaly"
	desc = "it goes boing and does stuff"
	has_processing_loop = 1

	process()
		playsound(src.loc, 'sound/voice/chanting.ogg', 100, 0, 5, 0.5)

/obj/do_not_press_this_button
	name = "do not press this button"
	desc = "This button stand is covered in warnings that say not to press it. Huh. Guess you shouldn't press it."
	density = 1
	anchored = ANCHORED
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "button_comp_button_unpressed"
	var/steps_until_pressable = 18
	var/being_pressed = 0
	var/has_been_pressed = 0

	attack_hand(mob/user)
		if (being_pressed)
			boutput(user, SPAN_ALERT("You can't press it while someone else is about to press it!"))
			return
		if (has_been_pressed)
			boutput(user, SPAN_ALERT("Someone has already pressed the button!"))
			return

		if (steps_until_pressable > 0)
			boutput(user, SPAN_ALERT("You can't press the button."))
			return
		else
			being_pressed = 1
			user.visible_message(SPAN_ALERT("<b>[user] reaches for the button...</b>"))
			var/input = null

			input = tgui_alert(user, "Are you sure you want to press the button?", "DONT PRESS IT", list("Yes","No"))
			if (input != "Yes")
				boutput(user, SPAN_NOTICE("You made the right decision."))
				being_pressed = 0
				return

			input = tgui_alert(user, "Are you REALLY sure?", "DONT PRESS IT", list("Yes", "No"))
			if (input != "Yes")
				boutput(user, SPAN_NOTICE("You made the right decision."))
				being_pressed = 0
				return

			input = tgui_alert(user, "Should you press the button?", "DONT PRESS IT", list("Yes", "No"))
			if (input != "No")
				boutput(user, SPAN_ALERT("Haven't you been paying attention?"))
				being_pressed = 0
				return

			input = tgui_alert(user, "Are you like double-ultra turbo sure you want to press the button?", "DONT PRESS IT", list("No", "Yes"))
			if (input != "Yes")
				boutput(user, SPAN_NOTICE("You made the right decision."))
				being_pressed = 0
				return

			boutput(user, SPAN_ALERT("Pressing button. Please wait thirty seconds."))
			sleep(30 SECONDS)

			input = tgui_alert(user, "For real though, you're okay with pressing the button?", "DONT PRESS IT", list("Yes", "No"))
			if (input != "Yes")
				boutput(user, SPAN_NOTICE("You made the right decision."))
				being_pressed = 0
				return

			if (is_incapacitated(user))
				boutput(user, SPAN_ALERT("You can't press it when you're incapacitated."))
				being_pressed = 0
				return
			if (BOUNDS_DIST(user, src) > 0)
				boutput(user, SPAN_ALERT("You can't press it from over there."))
				being_pressed = 0
				return

			user.visible_message(SPAN_ALERT("<b>[user] presses the button!</b>"))
			user.unlock_medal("Button Pusher", 1)
			has_been_pressed = 1
			being_pressed = 0

			command_alert("Crewman [user] has pressed the button. Dog Voiding Sequence activated. Thirty seconds until George is Voided. This is not a drill.","Button Press Detected")
			var/sound/siren = sound('sound/misc/airraid_loop_short.ogg')
			siren.repeat = 1
			siren.channel = 5
			world << siren
			for(var/area/A in world)
				A.eject = 1
				A.UpdateIcon()
				LAGCHECK(LAG_LOW)

			sleep(30 SECONDS)

			siren.repeat = 0
			siren.status = SOUND_UPDATE
			siren.channel = 5
			world << siren
			for(var/area/A in world)
				LAGCHECK(LAG_LOW)
				A.eject = 0
				A.UpdateIcon()

			for_by_tcl(G, /mob/living/critter/small_animal/dog/george)
				G.visible_message(SPAN_ALERT("<b>[G]</b> pees on the floor. Bad dog!"))
				make_cleanable( /obj/decal/cleanable/water ,get_turf(G))
		return

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W) && steps_until_pressable == 18)
			boutput(user, SPAN_NOTICE("You remove the metal bolts."))
			steps_until_pressable--
			return
		if (isweldingtool(W) && W:try_weld(user,0,-1,0,0) && steps_until_pressable == 17)
			boutput(user, SPAN_NOTICE("You un-weld the casing."))
			steps_until_pressable--
			return
		if (ispryingtool(W) && steps_until_pressable == 16)
			boutput(user, SPAN_NOTICE("You pry off the casing. Now what?"))
			steps_until_pressable--
			return
		if (issnippingtool(W) && steps_until_pressable == 15)
			boutput(user, SPAN_NOTICE("You cut up the metal mesh. This is kind of a pain in the ass."))
			steps_until_pressable--
			return
		if (isscrewingtool(W) && steps_until_pressable == 14)
			boutput(user, SPAN_NOTICE("You unscrew the case. There's no way this is worth it."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/kitchen/utensil/knife) && steps_until_pressable == 13)
			boutput(user, SPAN_NOTICE("You pry out the loose screw with the knife. This is just ridiculous."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/knife/butcher) && steps_until_pressable == 13)
			boutput(user, SPAN_ALERT("That's a bit excessive. A regular knife will do."))
			return
		if (istype(W,/obj/item/shovel) && steps_until_pressable == 12)
			boutput(user, SPAN_NOTICE("You lever off the case with the shovel. You should probably give up."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/slag_shovel) && steps_until_pressable == 12)
			boutput(user, SPAN_NOTICE("You lever off the case with the shovel. You should probably give up."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/sponge) && steps_until_pressable == 11)
			boutput(user, SPAN_NOTICE("You clean off the lock. You should definitely give up."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/stamp) && steps_until_pressable == 10)
			boutput(user, SPAN_NOTICE("You stamp the lock. Stop. Stop now. Please. Stop."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/gun/russianrevolver) && steps_until_pressable == 9)
			boutput(user, SPAN_NOTICE("You stick the revolver in the lock. No, seriously. Stop. This isn't worth it."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/staple_gun) && steps_until_pressable == 8)
			boutput(user, SPAN_NOTICE("You staple the locks. Come on, man. Know when to fold em. Just walk away."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/surgical_spoon) && steps_until_pressable == 7)
			boutput(user, SPAN_NOTICE("You remove the eyeball. Stop now. I'm not kidding."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/mining_tool) && steps_until_pressable == 6)
			boutput(user, SPAN_NOTICE("You cut the wires. This is a very, VERY bad idea. You won't be able to undo this."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/baton) && steps_until_pressable == 5)
			boutput(user, SPAN_NOTICE("You stun the button. Look, honestly, your persistence is NOT doing you any favors here."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/device/igniter) && steps_until_pressable == 4)
			boutput(user, SPAN_NOTICE("You warm up the button. Have you not considered WHY there's so many steps stopping you?"))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/paint_can) && steps_until_pressable == 3)
			boutput(user, SPAN_NOTICE("You paint the butOH FOR FUCKS SAKE JUST STOP LIKE IVE BEEN ASKING YOU TO"))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/paint) && steps_until_pressable == 3)
			boutput(user, SPAN_NOTICE("You paint the butOH FOR FUCKS SAKE JUST STOP LIKE IVE BEEN ASKING YOU TO"))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/reagent_containers/glass/bottle/holywater) && steps_until_pressable == 2)
			boutput(user, SPAN_ALERT("Stop it."))
			steps_until_pressable--
			return
		if (istype(W,/obj/item/gnomechompski) && steps_until_pressable == 1)
			boutput(user, SPAN_ALERT("You are nearing the point of no return. Walk away. Please."))
			steps_until_pressable--
			return

		..()
		return

	get_desc()
		..()
		switch(steps_until_pressable)
			if(0) // Now you can press it
				return {"The button is exposed. You can now press it, but there's no doubt that it's a horrible idea. Come on now, just walk away. Do the smart thing.
			 	Remember the sunk costs fallacy? Sure you spent a lot of time getting this far, but that doesn't mean throwing good time after bad will turn out any better.
			 	Look, curiosity is good and all that, especially for a member of a research station, but you know full well there's some things that just shouldn't be pursued,
			 	and I can tell you with the utmost certainty that this is one of them. Yes, I used *I*. I'm literally breaking the fourth wall in an examine text to speak directly
			 	to you, not as a character, but a player. One man behind the man to another, so to speak. I mean, I coded this button. I KNOW what it does. If you're the first player
			 	to get this far you probably don't, but lemme tell you, it's not worth it. We're both going to walk away from this very disappointed in ourselves. I mean granted,
			 	it's not like this is some pretentious thought experiment or moral lecture or anything, I just don't want you to press it. I'm not asking for much here. This is all assuming
			 	you've actually been examining the object between each deconstruction step though, if not I guess it was a big waste of time to write all this."}
			if(1) // Gnome Chompski
				return "Wait, better idea. You know who are really good at pressing buttons? Gnomes."
			if(2) // Holy Water
				return "Wait, what if this button is cursed? You should use a holy water jug on it, just to be certain. Is it really outside the realm of possibility at this point?"
			if(3) // Paint Can
				return "Something's wrong.. no, this button is clearly the wrong color. You need to repaint it before you can press it."
			if(4) // Igniter
				return "The button is way too cold to press. Warm it up with an igniter first."
			if(5) // Stun Baton
				return "Some remnants of the energy field are left on the button. A strike from an electrified blunt object should disperse it."
			if(6) // Pickaxe
				return "The button is protected by some kind of powered energy field. If you cut the wires it'd probably lose power, but the wires are built exactly the right way to only be cuttable by a pickaxe."
			if(7) // Surgical Spoon
				return "The button is protected by some kind of powered energy field. There's a battery of some kind on the side but there's a mechanical eyeball staring at you and it's really distracting you."
			if(8) // Staple Gun
				return "The button is protected by some kind of powered energy field. There's a battery of some kind on the side but it's got several staple-shaped locks on it."
			if(9) // Russian Revolver
				return "There's a big padlock protecting the stand. The keyhole looks exactly the right size for a russian revolver."
			if(10) // Rubber Stamp
				return "There's a touch-based unlocking pad that looks about exactly the size of a rubber stamp."
			if(11) // Sponge
				return "there's some kind of unlocking pad here but it's way too dirty to tell anything about it. Get a sponge and clean that muck off!"
			if(12) // Shovel
				return "The button is protected by a plexiglass case. It's kind of big and heavy, you obviously need a shovel to pry it off."
			if(13) // Kitchen Knife
				return "One of the screws is stuck. You could probably pop it out of place with a kitchen knife."
			if(14) // Screwdriver
				return "The button is protected by a plexiglass case. Looks like it's screwed to the stand."
			if(15) // Wirecutters
				return "The button is protected by a plexiglass case. A metal wire mesh is covering the case."
			if(16) // Crowbar
				return "There is a metal casing over the button. Looks like it could be crowbarred off."
			if(17) // Welder
				return "There is a metal casing which seems to be welded onto the stand."
			if(18) // Wrench
				return "The metal button casing is locked in place by several large metal bolts."
