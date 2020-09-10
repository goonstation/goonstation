////////////////// MISC BULLSHIT //////////////////

/mob/proc/fake_damage(var/amount,var/seconds)
	if (!amount || !seconds)
		return

	src.fakeloss += amount

	SPAWN_DBG(seconds * 10)
		src.fakeloss -= amount

/mob/proc/false_death(var/seconds)
	if (!seconds)
		return

	src.fakedead = 1
	boutput(src, "<B>[src]</B> seizes up and falls limp, [his_or_her(src)] eyes dead and lifeless...")
	src.changeStatus("weakened", 5 SECONDS)

	SPAWN_DBG(seconds * 10)
		src.fakedead = 0
		src.delStatus("weakened")

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
	if(src.bioHolder && src.bioHolder.HasOneOfTheseEffects("cold_resist","thermal_resist"))
		return 1
	if(ischangeling(src))
		return 1
	if(src.nodamage)
		return 1
	return 0

/mob/proc/is_heat_resistant()
	if (!src)
		return 0
	if(src.bioHolder && src.bioHolder.HasOneOfTheseEffects("fire_resist","thermal_resist"))
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
		boutput(src, "<span class='alert'><b>[H.name] attacks [src.name] with [I]!</b></span>")
		if (I.hitsound)
			src.playsound_local(src.loc, I.hitsound, 50, 1)
		src.fake_damage(I.force,100)
	else
		if (!ishuman(H))
			return
		if (!src.canmove)
			src.playsound_local(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 25, 1, -1)
			boutput(src, "<span class='alert'><B>[H.name] kicks [src.name]!</B></span>")
		else
			src.playsound_local(src.loc, pick(sounds_punch), 25, 1, -1)
			boutput(src, "<span class='alert'><B>[H.name] punches [src.name]!</B></span>")
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
	anchored = 1
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
	anchored = 1
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "comp_button"
	var/steps_until_pressable = 18
	var/being_pressed = 0
	var/has_been_pressed = 0

	attack_hand(mob/user as mob)
		if (being_pressed)
			boutput(user, "<span class='alert'>You can't press it while someone else is about to press it!</span>")
			return
		if (has_been_pressed)
			boutput(user, "<span class='alert'>Someone has already pressed the button!</span>")
			return

		if (steps_until_pressable > 0)
			boutput(user, "<span class='alert'>You can't press the button.</span>")
			return
		else
			being_pressed = 1
			user.visible_message("<span class='alert'><b>[user] reaches for the button...</b></span>")
			var/input = null

			input = alert("Are you sure you want to press the button?","DONT PRESS IT","Yes","No")
			if (input != "Yes")
				boutput(user, "<span class='notice'>You made the right decision.</span>")
				being_pressed = 0
				return

			input = alert("Are you REALLY sure?","DONT PRESS IT","Yes","No")
			if (input != "Yes")
				boutput(user, "<span class='notice'>You made the right decision.</span>")
				being_pressed = 0
				return

			input = alert("Should you press the button?","DONT PRESS IT","Yes","No")
			if (input != "No")
				boutput(user, "<span class='alert'>Haven't you been paying attention?</span>")
				being_pressed = 0
				return

			input = alert("Are you like double-ultra turbo sure you want to press the button?","DONT PRESS IT","No","Yes")
			if (input != "Yes")
				boutput(user, "<span class='notice'>You made the right decision.</span>")
				being_pressed = 0
				return

			boutput(user, "<span class='alert'>Pressing button. Please wait thirty seconds.</span>")
			sleep(30 SECONDS)

			input = alert("For real though, you're okay with pressing the button?","DONT PRESS IT","Yes","No")
			if (input != "Yes")
				boutput(user, "<span class='notice'>You made the right decision.</span>")
				being_pressed = 0
				return

			if (user.getStatusDuration("paralysis") || user.stat || user.getStatusDuration("stunned") || user.getStatusDuration("weakened"))
				boutput(user, "<span class='alert'>You can't press it when you're incapacitated.</span>")
				being_pressed = 0
				return
			if (get_dist(user,src) > 1)
				boutput(user, "<span class='alert'>You can't press it from over there.</span>")
				being_pressed = 0
				return

			user.visible_message("<span class='alert'><b>[user] presses the button!</b></span>")
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
				A.updateicon()
				LAGCHECK(LAG_LOW)

			sleep(30 SECONDS)

			siren.repeat = 0
			siren.status = SOUND_UPDATE
			siren.channel = 5
			world << siren
			for(var/area/A in world)
				LAGCHECK(LAG_LOW)
				A.eject = 0
				A.updateicon()

			for (var/obj/critter/dog/george/G in by_type[/obj/critter/dog/george])
				G.visible_message("<span class='alert'><b>[G]</b> pees on the floor. Bad dog!</span>")
				make_cleanable( /obj/decal/cleanable/urine ,get_turf(G))
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (iswrenchingtool(W) && steps_until_pressable == 18)
			boutput(user, "<span class='notice'>You remove the metal bolts.</span>")
			steps_until_pressable--
			return
		if (isweldingtool(W) && W:try_weld(user,0,-1,0,0) && steps_until_pressable == 17)
			boutput(user, "<span class='notice'>You un-weld the casing.</span>")
			steps_until_pressable--
			return
		if (ispryingtool(W) && steps_until_pressable == 16)
			boutput(user, "<span class='notice'>You pry off the casing. Now what?</span>")
			steps_until_pressable--
			return
		if (issnippingtool(W) && steps_until_pressable == 15)
			boutput(user, "<span class='notice'>You cut up the metal mesh. This is kind of a pain in the ass.</span>")
			steps_until_pressable--
			return
		if (isscrewingtool(W) && steps_until_pressable == 14)
			boutput(user, "<span class='notice'>You unscrew the case. There's no way this is worth it.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/kitchen/utensil/knife) && steps_until_pressable == 13)
			boutput(user, "<span class='notice'>You pry out the loose screw with the knife. This is just ridiculous.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/knife/butcher) && steps_until_pressable == 13)
			boutput(user, "<span class='alert'>That's a bit excessive. A regular knife will do.</span>")
			return
		if (istype(W,/obj/item/shovel) && steps_until_pressable == 12)
			boutput(user, "<span class='notice'>You lever off the case with the shovel. You should probably give up.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/slag_shovel) && steps_until_pressable == 12)
			boutput(user, "<span class='notice'>You lever off the case with the shovel. You should probably give up.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/sponge) && steps_until_pressable == 11)
			boutput(user, "<span class='notice'>You clean off the lock. You should definitely give up.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/stamp) && steps_until_pressable == 10)
			boutput(user, "<span class='notice'>You stamp the lock. Stop. Stop now. Please. Stop.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/gun/russianrevolver) && steps_until_pressable == 9)
			boutput(user, "<span class='notice'>You stick the revolver in the lock. No, seriously. Stop. This isn't worth it.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/staple_gun) && steps_until_pressable == 8)
			boutput(user, "<span class='notice'>You staple the locks. Come on, man. Know when to fold em. Just walk away.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/surgical_spoon) && steps_until_pressable == 7)
			boutput(user, "<span class='notice'>You remove the eyeball. Stop now. I'm not kidding.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/mining_tool) && steps_until_pressable == 6)
			boutput(user, "<span class='notice'>You cut the wires. This is a very, VERY bad idea. You won't be able to undo this.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/baton) && steps_until_pressable == 5)
			boutput(user, "<span class='notice'>You stun the button. Look, honestly, your persistence is NOT doing you any favors here.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/device/igniter) && steps_until_pressable == 4)
			boutput(user, "<span class='notice'>You warm up the button. Have you not considered WHY there's so many steps stopping you?</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/paint_can) && steps_until_pressable == 3)
			boutput(user, "<span class='notice'>You paint the butOH FOR FUCKS SAKE JUST STOP LIKE IVE BEEN ASKING YOU TO</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/paint) && steps_until_pressable == 3)
			boutput(user, "<span class='notice'>You paint the butOH FOR FUCKS SAKE JUST STOP LIKE IVE BEEN ASKING YOU TO</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/reagent_containers/glass/bottle/holywater) && steps_until_pressable == 2)
			boutput(user, "<span class='alert'>Stop it.</span>")
			steps_until_pressable--
			return
		if (istype(W,/obj/item/gnomechompski) && steps_until_pressable == 1)
			boutput(user, "<span class='alert'>You are nearing the point of no return. Walk away. Please.</span>")
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

/proc/ass_day_popup(var/mob/M)
	if (!M || !M.client)
		return
	M << csound("sound/misc/Warning_AssDay.ogg")

	var/dat = "<b>!!! ASS DAY !!!</b><BR><HR><BR>"

	dat += {"You have joined us for Ass Day, an event that occurs on the 13th of every month. During this time, the rules
	and their enforcement are heavily relaxed on this server. If you choose to join the game, expect complete and total chaos,
	rampant grief, and levels of violence that would make Joe Pesci cry. Of course, there's nothing stopping you from causing
	all that yourself if you choose to."}

	dat += "<BR><BR>"

	dat += {"<B>Bear in mind that a few rules are still in effect, however:</B><BR>
	<B>1)</B> No intentionally crashing the server or causing lag.<BR>
	<B>2)</B> No bigotry.<BR>
	<B>3)</B> No sexual stuff.<BR>
	<B>4)</B> No creepy shit.<BR>
	<B>5)</B> No impersonating the admins.<BR>
	<B>6)</B> No giving out secret recipes and the like.<BR>
	<B>7)</B> If an admin tells you to quit doing something, quit it."}

	dat += "<BR><BR>"

	dat += {"If you do not see this popup, that means it is not Ass Day. Rule-breakers invoking Ass Day when it is not Ass Day
	will be dealt with incredibly severely, so don't fuck this up! A good rule of thumb to keep in mind - Ass Day begins and ends
	when the admins or the game itself say it is, not when you say it is."}

	dat += "<BR><BR>"

	dat += {"Does all this sound like it doesn't appeal to you? No problem, Ass Day is a feature of this server only and is not
	in effect on our other servers, so if you'd like a bit of peace and quiet go ahead and check them out. We won't mind."}

	M.Browse(dat, "window=assday;size=500x600;can_resize=0;can_minimize=0")
