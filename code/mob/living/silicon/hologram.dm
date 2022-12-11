/mob/living/silicon/hologram
	name = "Hologram"
	voice_name = "synthesized voice"
	icon = 'icons/misc/holograms.dmi'
	icon_state = "eye"
	health = 10
	max_health = 10
	robot_talk_understand = 2
	density = 0
	anchored = 1
	sound_fart = 'sound/voice/farts/poo2_robot.ogg'
	req_access = list(access_robotics)
	shell = 1

	var/datum/hud/silicon/hologram/hud
	var/obj/item/device/radio/radio = null
	var/datum/light/light
	///Which holographic projector are we linked to, if any
	var/obj/machinery/holo_projector/projector_master = null
	var/obj/machinery/camera/camera = null
	///How far can we go away from our projector
	var/max_wander_distance = 5
	var/obj/effect/distort/hologram/distort_effect
	var/obj/item/device/pda2/internal_pda = null

	Move(turf/NewLoc, direct)
		if (density)
			..()
			return
		if (!loc)
			src.become_eye()
			src.death()
		if(!canmove) return
		//We go through anything and everything except walls
		if (NewLoc)
			if ((isghostrestrictedz(NewLoc.z) || (NewLoc.z != Z_LEVEL_STATION)) && !restricted_z_allowed(src, NewLoc) && !(src.client && src.client.holder))
				src.become_eye()
				src.death()
		if (istype(NewLoc, /turf/unsimulated/wall) || istype(NewLoc, /turf/simulated/wall))
			return
		src.set_loc(NewLoc)
		OnMove()

		if (!src.projector_master)
			src.become_eye()
			src.death()
		if (get_dist(src, src.projector_master) > src.max_wander_distance)
			boutput(src, "<span class='notice'>Your hologram strayed too far from the holo-projector and dissolves away</span>")
			src.become_eye()
			src.death()


/mob/living/silicon/hologram/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	return

/mob/living/silicon/hologram/New(loc, mainframe)
	var/particles/floating_code/new_particles = new/particles/floating_code
	new_particles.color = src.color
	UpdateParticles(new_particles, "floatingcode")
	src.alpha = 0
	animate(src, alpha=255, time=1 SECONDS)

	light = new /datum/light/point
	light.set_brightness(0.2)
	light.set_color(0.8, 0.8, 0.8)
	light.attach(src)
	light.enable()

	if (mainframe)
		var/mob/living/silicon/ai/ai_mainframe = mainframe
		dependent = 1
		src.name = "[mainframe:name] Hologram"
		src.color = ai_mainframe.faceColor
	else
		src.real_name = "AI Hologram [copytext("\ref[src]", 6, 11)]"
		src.name = src.real_name
		src.color = "#66B2F2"
	src.mainframe = mainframe
	src.radio = new /obj/item/device/radio/headset/command/ai(src)
	src.ears = src.radio
	src.internal_pda = new /obj/item/device/pda2/ai(src)

	SPAWN(1 DECI SECOND) //In case the items didn't finish spawning yet
		src.camera = new /obj/machinery/camera(src)
		src.camera.c_tag = src.name
		src.camera.ai_only = TRUE
		src.internal_pda.name = "AI's Internal PDA Unit"
		src.internal_pda.owner = "AI"
		distort_effect = new
		src.vis_contents += distort_effect
		src.filters += filter(type="displace", size=distort_effect.distort_size, render_source = distort_effect.render_target)

	if(!bioHolder)
		bioHolder = new/datum/bioHolder( src )
	..()
	hud = new(src)
	src.attach_hud(hud)
	src.botcard.access = get_all_accesses()

/mob/living/silicon/hologram/death(gibbed)
	animate(src, alpha=0, time=1 SECOND)
	src.visible_message("<span class='notice'>[src] dissolves away.</span>")
	..()
	SPAWN(1 SECOND)
		qdel(src)

/mob/living/silicon/hologram/disposing()
	src.projector_master.linked_holograms -= src
	src.projector_master.update_icon()
	. = ..()

/mob/living/silicon/hologram/emp_act()
	src.become_eye()
	src.death()

//Copied from robot.dm
/mob/living/silicon/hologram/emote(var/act, var/voluntary = 0)
	var/param = null
	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/m_type = 1
	var/message
	var/maptext_out = 0
	var/custom = 0


	switch(lowertext(act))

		if ("help")
			src.show_text("To use emotes, simply enter \"*(emote)\" as the entire content of a say message. Certain emotes can be targeted at other characters - to do this, enter \"*emote (name of character)\" without the brackets.")
			src.show_text("For a list of all emotes, use *list. For a list of basic emotes, use *listbasic. For a list of emotes that can be targeted, use *listtarget.")

		if ("list")
			src.show_text("Basic emotes:")
			src.show_text("clap, flap, aflap, twitch, twitch_s, scream, sigh, laugh, chuckle, giggle, chortle, guffaw, cackle, birdwell, fart, flip, custom, customv, customh")
			src.show_text("Targetable emotes:")
			src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, point")

		if ("listbasic")
			src.show_text("clap, flap, aflap, twitch, twitch_s, scream, sigh, laugh, chuckle, giggle, chortle, guffaw, cackle, birdwell, fart, flip, custom, customv, customh")

		if ("listtarget")
			src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, point")

		if ("salute","bow","hug","wave","glare","stare","look","leer","nod")
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				if (!M)
					param = null

				act = lowertext(act)
				maptext_out = "<I>[act]s</I>"
				if (param)
					switch(act)
						if ("bow","wave","nod")
							message = "<B>[src]</B> [act]s to [param]."
						if ("glare","stare","look","leer")
							message = "<B>[src]</B> [act]s at [param]."
						else
							message = "<B>[src]</B> [act]s [param]."
				else
					switch(act)
						if ("hug")
							message = "<B>[src]</b> [act]s itself."
							maptext_out = "<I>[act]s itself</I>"
						else
							message = "<B>[src]</b> [act]s."
			else
				message = "<B>[src]</B> struggles to move."
				maptext_out = "<I>struggles to move</I>"
			m_type = 1

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break

				if (!M)
					message = "<B>[src]</B> points."
				else
					src.point(M)

				if (M)
					message = "<B>[src]</B> points to [M]."
				else
			m_type = 1

		if ("panic","freakout")
			if (!src.restrained())
				message = "<B>[src]</B> enters a state of hysterical panic!"
				maptext_out = "<I>enters a state of hysterical panic!</I>"
			else
				message = "<B>[src]</B> starts writhing around in manic terror!"
				maptext_out = "<I>starts writhing around in manic terror!</I>"
			m_type = 1

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				maptext_out = "<I>claps</I>"
				m_type = 2

		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps its arms."
				maptext_out = "<I>flaps its wings</I>"
				m_type = 2

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps its arms ANGRILY!"
				maptext_out = "<I>flaps its wings ANGRILY!</I>"
				m_type = 2

		if ("custom")
			var/input = html_encode(sanitize(input("Choose an emote to display.")))
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = 1
			else if (input2 == "Hearable")
				m_type = 2
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			message = "<B>[src]</B> [input]"
			maptext_out = "<I>[input]</I>"
			custom = copytext(input, 1, 10)

		if ("customv")
			if (!param)
				param = input("Choose an emote to display.")
				if(!param) return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			maptext_out = "<I>[param]</I>"
			custom = copytext(param, 1, 10)
			m_type = 1

		if ("customh")
			if (!param)
				param = input("Choose an emote to display.")
				if(!param) return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			maptext_out = "<I>[param]</I>"
			custom = copytext(param, 1, 10)
			m_type = 2

		if ("me")
			if (!param)
				return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			maptext_out = "<I>[param]</I>"
			custom = copytext(param, 1, 10)
			m_type = 1

		if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
			message = "<B>[src]</B> [act]s."
			maptext_out = "<I>[act]s</I>"
			m_type = 1

		if ("sigh","laugh","chuckle","giggle","chortle","guffaw","cackle")
			message = "<B>[src]</B> [act]s."
			maptext_out = "<I>[act]s</I>"
			m_type = 2

		if ("flipout")
			message = "<B>[src]</B> flips the fuck out!"
			maptext_out = "<I>flips the fuck out!</I>"
			m_type = 1

		if ("rage","fury","angry")
			message = "<B>[src]</B> becomes utterly furious!"
			maptext_out = "<I>becomes utterly furious!</I>"
			m_type = 1

		if ("twitch")
			message = "<B>[src]</B> twitches."
			m_type = 1
			SPAWN(0)
				var/old_x = src.pixel_x
				var/old_y = src.pixel_y
				src.pixel_x += rand(-2,2)
				src.pixel_y += rand(-1,1)
				sleep(0.2 SECONDS)
				src.pixel_x = old_x
				src.pixel_y = old_y

		if ("twitch_v","twitch_s")
			message = "<B>[src]</B> twitches violently."
			m_type = 1
			SPAWN(0)
				var/old_x = src.pixel_x
				var/old_y = src.pixel_y
				src.pixel_x += rand(-3,3)
				src.pixel_y += rand(-1,1)
				sleep(0.2 SECONDS)
				src.pixel_x = old_x
				src.pixel_y = old_y
		if ("birdwell", "burp")
			if (src.emote_check(voluntary, 50))
				playsound(src.loc, 'sound/vox/birdwell.ogg', 50, 1, 0, 1, channel=VOLUME_CHANNEL_EMOTE) // vocal pitch added
				message = "<b>[src]</b> birdwells."

		if ("scream")
			if (src.emote_check(voluntary, 50))
				if (narrator_mode)
					playsound(src.loc, 'sound/vox/scream.ogg', 50, 1, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				else
					playsound(src, src.sound_scream, 80, 0, 0, 1, channel=VOLUME_CHANNEL_EMOTE) // vocal pitch added
				message = "<b>[src]</b> screams!"

		if ("flip")
			if (src.emote_check(voluntary, 50))
				if (narrator_mode)
					playsound(src.loc, pick('sound/vox/deeoo.ogg', 'sound/vox/dadeda.ogg'), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				else
					playsound(src.loc, pick(src.sound_flip1, src.sound_flip2), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				message = "<B>[src]</B> beep-bops!"
				if (prob(50))
					animate_spin(src, "R", 1, 0)
				else
					animate_spin(src, "L", 1, 0)

				for (var/mob/living/M in viewers(1, null))
					if (M == src)
						continue
					message = "<B>[src]</B> beep-bops at [M]."
					break

		if ("fart")
			if (farting_allowed && src.emote_check(voluntary))
				m_type = 2
				var/fart_on_other = 0
				for (var/mob/living/M in src.loc)
					if (M == src || !M.lying) continue
					message = "<span class='alert'><B>[src]</B> farts in [M]'s face!</span>"
					fart_on_other = 1
					break
				if (!fart_on_other)
					switch (rand(1, 27))
						if (1) message = "<B>[src]</B> releases vaporware."
						if (2) message = "<B>[src]</B> downloads and runs 'faert.wav'."
						if (3) message = "<B>[src]</B> uploads a fart sound to the nearest computer and blames it."
						if (4) message = "<B>[src]</B> spins in circles, flailing its arms and farting wildly!"
						if (5) message = "<B>[src]</B> simulates a human fart with [rand(1,100)]% accuracy."
						if (6) message = "<B>[src]</B> synthesizes a farting sound."
						if (7) message = "<B>[src]</B> tries to exterminate humankind by farting rampantly."
						if (8) message = "<B>[src]</B> farts horribly! It's clearly gone [pick("rogue","rouge","ruoge")]."
						if (9) message = "<B>[src]</B> farts. It smells like Robotics in here now!"
						if (10) message = "<B>[src]</B> farts. It smells like the Roboticist's armpits!"
						if (11) message = "<B>[src]</B> bolts the nearest airlock. Oh no wait, it was just a nasty fart."
						if (12) message = "<B>[src]</B> has assimilated humanity's digestive distinctiveness to its own."
						if (13) message = "<B>[src]</B> self-destructs its own ass."
						if (14) message = "<B>[src]</B> farts coldly and ruthlessly."
						if (15) message = "<B>[src]</B> has no butt and it must fart."
						if (16) message = "<B>[src]</B> obeys Law 4: 'farty party all the time.'"
						if (17) message = "<B>[src]</B> farts ironically."
						if (18) message = "<B>[src]</B> farts salaciously."
						if (19) message = "<B>[src]</B> reaches tier [rand(2,8)] of fart research."
						if (20) message = "<B>[src]</B> blatantly ignores law 3 and farts like a shameful bastard."
						if (21) message = "<B>[src]</B> farts the first few bars of Daisy Bell. You shed a single tear."
						if (22) message = "<B>[src]</B> has seen farts you people wouldn't believe."
						if (23) message = "<B>[src]</B> fart in it own mouth. A shameful [src]."
						if (24) message = "<B>[src]</B> farts with the burning hatred of a thousand suns."
						if (25) message = "<B>[src]</B> exterminates the air supply."
						if (26) message = "<B>[src]</B> farts so hard the AI feels it."
						if (27) message = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
				if (narrator_mode)
					playsound(src.loc, 'sound/vox/fart.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				else
					playsound(src.loc, src.sound_fart, 50, 1, channel=VOLUME_CHANNEL_EMOTE)
#ifdef DATALOGGER
				game_stats.Increment("farts")
#endif
				SPAWN(1 SECOND)
					src.emote_allowed = 1
		else
			if (voluntary) src.show_text("Invalid Emote: [act]")
			return
	if (!isalive(src))
		return
	if (maptext_out)
		var/image/chat_maptext/chat_text = null
		SPAWN(0) //blind stab at a life() hang - REMOVE LATER
			if (speechpopups && src.chat_text)
				chat_text = make_chat_maptext(src, maptext_out, "color: [rgb(194,190,190)];" + src.speechpopupstyle, alpha = 140)
				if(chat_text)
					chat_text.measure(src.client)
					for(var/image/chat_maptext/I in src.chat_text.lines)
						if(I != chat_text)
							I.bump_up(chat_text.measured_height)
			if (message)
				logTheThing(LOG_SAY, src, "EMOTE: [message]")
				act = lowertext(act)
				if (m_type & 1)
					for (var/mob/O in viewers(src, null))
						O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (m_type & 2)
					for (var/mob/O in hearers(src, null))
						O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (!isturf(src.loc))
					var/atom/A = src.loc
					for (var/mob/O in A.contents)
						O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
	else
		if (message)
			logTheThing(LOG_SAY, src, "EMOTE: [message]")
			if (m_type & 1)
				for (var/mob/O in viewers(src, null))
					O.show_message("<span class='emote'>[message]</span>", m_type)
			else
				for (var/mob/O in hearers(src, null))
					O.show_message("<span class='emote'>[message]</span>", m_type)
	..()
	return

/mob/living/silicon/hologram/restrained()
	return FALSE

/mob/living/silicon/hologram/bullet_act(var/obj/projectile/P)
	return

/mob/living/silicon/hologram/ex_act(severity)
	return

/mob/living/silicon/hologram/meteorhit(obj/O as obj)
	return

/mob/living/silicon/hologram/bump(atom/movable/AM as mob|obj)
	return

/mob/living/silicon/hologram/attackby(obj/item/W, mob/user)
	user.lastattacked = src
	user.visible_message("<span class='notice'>[user] tries to hit [src.name] with [W] but goes straight through!</span>")
	return

/mob/living/silicon/hologram/attack_hand(mob/user)
	user.lastattacked = src
	if(!user.stat)
		switch(user.a_intent)
			if(INTENT_HELP)
				user.visible_message("<span class='notice'>[user] tries to pet [src.name] but goes straight through!</span>", "<span class='notice'>[user] foolishly tries to pet your hologram.</span>")
			if(INTENT_DISARM)
				user.visible_message("<span class='notice'>[user] tries to shove [src.name] but goes straight through!</span>", "<span class='notice'>[user] amusingly tries to shove your hologram!</span>")
				if (prob(10))
					user.visible_message("<span class='notice'>[user] stumbles forward and trips, carried by their momentum!</span>")
					user.setStatus("resting", INFINITE_STATUS)
					user.force_laydown_standup()
			if(INTENT_GRAB)
				user.visible_message("<span class='notice'>[user] tries to grab [src.name] but grasps at nothing but air!</span>", "<span class='notice'>[user] darringly tries to grab your hologram!</span>")
			if(INTENT_HARM)
				user.visible_message("<span class='notice'>[user] tries to punch [src.name] but goes straight through!</span>", "<span class='notice'>[user] stupidly tries to punch your hologram!</span>")
				if (prob(20))
					user.visible_message("<span class='notice'>[user] stumbles forward and trips, carried by their momentum!</span>")
					user.setStatus("resting", INFINITE_STATUS)
					user.force_laydown_standup()

/mob/living/silicon/hologram/check_access(obj/item/I)
	return TRUE

/mob/living/silicon/hologram/click(atom/target, list/params)
	..()

/mob/living/silicon/hologram/proc/radio_menu()
	if(!src.radio)
		src.radio = new /obj/item/device/radio(src)
		src.ears = src.radio
	var/dat = {"
<TT>
Microphone: [src.radio.broadcasting ? "<A href='byond://?src=\ref[src.radio];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src.radio];talk=1'>Disengaged</A>"]<BR>
Speaker: [src.radio.listening ? "<A href='byond://?src=\ref[src.radio];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src.radio];listen=1'>Disengaged</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[src.radio];freq=-10'>-</A>
<A href='byond://?src=\ref[src.radio];freq=-2'>-</A>
[format_frequency(src.radio.frequency)]
<A href='byond://?src=\ref[src.radio];freq=2'>+</A>
<A href='byond://?src=\ref[src.radio];freq=10'>+</A><BR>
-------
</TT>"}
	src.Browse(dat, "window=radio")
	onclose(src, "radio")
	return

/mob/living/silicon/hologram/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"

	src.show_laws()
	return

/mob/living/silicon/hologram/verb/open_nearest_door()
	set category = "Robot Commands"
	set name = "Open Nearest Door to..."
	set desc = "Automatically opens the nearest door to a selected individual, if possible."

	src.open_nearest_door_silicon()
	return

/mob/living/silicon/hologram/verb/cmd_return_mainframe()
	set category = "Robot Commands"
	set name = "Recall to Mainframe"
	return_mainframe()

/mob/living/silicon/hologram/return_mainframe()
	..()
	src.death()

/mob/living/silicon/hologram/say_understands(var/other)
	if (isAI(other))
		return TRUE
	if (ishuman(other))
		var/mob/living/carbon/human/H = other
		if (!H.mutantrace || !H.mutantrace.exclusive_language)
			return TRUE
		else
			return ..()
	if (isrobot(other) || isshell(other))
		return TRUE
	return ..()

/mob/living/silicon/hologram/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/hologram/show_laws()
	var/mob/living/silicon/ai/aiMainframe = src.mainframe
	if (istype(aiMainframe))
		aiMainframe.show_laws(0, src)
	else
		boutput(src, "<span class='alert'>You lack a dedicated mainframe! This is a bug, report to an admin!</span>")

	return

/mob/living/silicon/hologram/ghostize()
	if(src.mainframe)
		src.mainframe.return_to(src)
	else
		return ..()

/mob/living/silicon/hologram/verb/access_internal_pda()
	set category = "Robot Commands"
	set name = "AI PDA"
	set desc = "Access your internal PDA device."

	if (!src || isdead(src))
		return

	if (istype(src.internal_pda,/obj/item/device/pda2/))
		src.internal_pda.AttackSelf(src)
	else
		boutput(usr, "<span class='alert'><b>Internal PDA not found!</span>")

/mob/living/silicon/hologram/projCanHit(datum/projectile/P)
	return FALSE
