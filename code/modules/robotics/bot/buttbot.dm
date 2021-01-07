// whatever man

/obj/machinery/bot/buttbot
	name = "buttbot"
	desc = "Well I... uh... huh."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "buttbot"
	layer = 5.0 // Todo layer
	density = 0
	anchored = 0
	on = 1
	health = 5
	no_camera = 1
	var/toned = 0
	var/s_tone = "#FAD7D0"
	/// Its a butt
	dynamic_processing = 0
	speakverbs = list("ferts", "toots", "honks", "parps")
	bot_voice = 'sound/misc/talk/bottalk_2.ogg'
	var/list/fartsounds = list('sound/voice/farts/poo2.ogg', \
								'sound/voice/farts/fart1.ogg', \
								'sound/voice/farts/fart2.ogg', \
								'sound/voice/farts/fart3.ogg', \
								'sound/voice/farts/fart4.ogg', \
								'sound/voice/farts/fart5.ogg')


/obj/machinery/bot/buttbot/New()
	..()
	SPAWN_DBG(0)
		if (src.toned)
			var/icon/new_icon = icon(src.icon, "butt_ncbot")
			if (src.s_tone)
				new_icon.Blend(s_tone, ICON_MULTIPLY)
			var/icon/my_icon = icon(src.icon, src.icon_state)
			my_icon.Blend(new_icon, ICON_OVERLAY)
			src.icon = my_icon

/obj/machinery/bot/buttbot/emp_act()
	src.emag_act()

/obj/machinery/bot/buttbot/cyber
	name = "robuttbot"
	icon_state = "cyberbuttbot"

/obj/machinery/bot/buttbot/text2speech
	text2speech = 1


/obj/machinery/bot/buttbot/process()
	if (src.on == 1)
		if(prob(10))
			SPAWN_DBG(0)
				var/message = pick("butts", "butt")
				speak(message)
		if(prob(10))
			var/fartmessage = src.fart()
			if(fartmessage)
				src.audible_message("[fartmessage]")
				src.robo_expel_fart_gas(0)
	if (src.emagged == 1)
		SPAWN_DBG(0)
			var/message = pick("BuTTS", "buTt", "b##t", "bztBUTT", "b^%t", "BUTT", "buott", "bats", "bates", "bouuts", "buttH", "b&/t", "beats", "boats", "booots", "BAAAAATS&/", "//t/%/")
			if (prob(2))
				playsound(src.loc, "sound/misc/extreme_ass.ogg", 50, 1)
			else
				playsound(src.loc, 'sound/vox/poo.ogg', 50, 1)
			speak(message)
		var/fartmessage = src.fart()
		if(fartmessage)
			src.audible_message("[fartmessage]")
			src.robo_expel_fart_gas(1)
	. = ..()

/obj/machinery/bot/buttbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if (user)
			user.show_text("You short out the vocal emitter on [src].", "red")
			src.processing_tier = src.PT_active
			src.SubscribeToProcess()
		SPAWN_DBG(0)
			src.visible_message("<span class='alert'><B>[src] buzzes oddly!</B></span>")
			playsound(src.loc, "sound/misc/extreme_ass.ogg", 50, 1)
		src.emagged = 1
		return 1
	return 0

/obj/machinery/bot/buttbot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s vocal emitter. Thank God.", "blue")
	src.emagged = 0
	src.processing_tier = src.PT_idle
	src.SubscribeToProcess()
	return 1

/obj/machinery/bot/buttbot/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/card/emag))
		//Do not hit the buttbot with the emag tia
	else
		src.visible_message("<span class='alert'>[user] hits [src] with [W]!</span>")
		src.health -= W.force * 0.5
		if (src.health <= 0)
			src.explode()

/obj/machinery/bot/buttbot/hear_talk(var/mob/living/carbon/speaker, messages, real_name, lang_id)
	if(!messages || !src.on)
		return
	var/message = (lang_id == "english" || lang_id == "") ? messages[1] : messages[2]
	if(prob(25))
		var/list/speech_list = splittext(message, " ")
		if(!speech_list || !speech_list.len)
			return

		var/num_butts = rand(1,4)
		var/counter = 0
		while(num_butts)
			counter++
			num_butts--
			speech_list[rand(1,speech_list.len)] = "butt"
			if(counter >= (speech_list.len / 2) )
				num_butts = 0

		src.speak( jointext(speech_list, " ") )
	return

/obj/machinery/bot/buttbot/gib()
	return src.explode()

/obj/machinery/bot/buttbot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message("<span class='alert'><B>[src] blows apart!</B></span>")
	playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
	elecflash(src, radius=1, power=3, exclude_center = 0)
	qdel(src)
	return

/// cant possibly be a bad idea
/obj/machinery/bot/buttbot/proc/robo_expel_fart_gas(var/gross)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/gas = unpool(/datum/gas_mixture)
	gas.vacuum()
	if(gross)
		gas.farts = 0.5
	else
		gas.oxygen = 1
	gas.temperature = T20C
	gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
	if (T)
		T.assume_air(gas)

/obj/machinery/bot/buttbot/proc/fart()
	if (!farting_allowed)
		. = "<B>[src]</B> grunts for a moment. Nothing happens."
		return

	if (istype(src, /obj/machinery/bot/buttbot/cyber))
		playsound(get_turf(src), "sound/voice/farts/poo2_robot.ogg", 50, 1, channel=VOLUME_CHANNEL_EMOTE)
	else
		if (narrator_mode)
			playsound(get_turf(src), 'sound/vox/fart.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
		else
			playsound(get_turf(src), pick(src.fartsounds), 50, 1, channel=VOLUME_CHANNEL_EMOTE)

	var/fart_on_other = 0
	for (var/atom/A as() in src.loc)
		if (A.event_handler_flags & IS_FARTABLE)
			if (istype(A,/mob/living))
				var/mob/living/M = A
				if (M == src || !M.lying)
					continue
				. = "<span class='alert'><B>[src]</B> farts in [M]'s face!</span>"
				fart_on_other = 1
				break
			else if (istype(A,/obj/item/storage/bible))
				src.visible_message("<span class='alert'>[src] farts on the bible.<br><b>A mysterious force smites [src]!</b></span>")
				fart_on_other = 1
				src.explode()
				break
			else if (istype(A,/obj/item/book_kinginyellow))
				var/obj/item/book_kinginyellow/K = A
				src.visible_message("<span class='alert'>[src] farts on [A].<br><b>A mysterious force sucks [src] into the book!!</b></span>")
				fart_on_other = 1
				new/obj/decal/implo(get_turf(src))
				playsound(get_turf(src), 'sound/effects/suck.ogg', 100, 1)
				src.set_loc(K)
				break
			else if (istype(A,/obj/item/photo/voodoo))
				var/obj/item/photo/voodoo/V = A
				var/mob/M = V.cursed_dude
				if (!M || !M.lying)
					continue
				playsound(get_turf(M), pick(src.fartsounds), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				switch(rand(1, 7))
					if (1) M.visible_message("<span class='emote'><b>[M]</b> suddenly radiates an unwelcoming odor.</span>")
					if (2) M.visible_message("<span class='emote'><b>[M]</b> is visited by ethereal incontinence.</span>")
					if (3) M.visible_message("<span class='emote'><b>[M]</b> experiences paranormal gastrointestinal phenomena.</span>")
					if (4) M.visible_message("<span class='emote'><b>[M]</b> involuntarily telecommutes to the farty party.</span>")
					if (5) M.visible_message("<span class='emote'><b>[M]</b> is swept over by a mysterious draft.</span>")
					if (6) M.visible_message("<span class='emote'><b>[M]</b> abruptly emits an odor of cheese.</span>")
					if (7) M.visible_message("<span class='emote'><b>[M]</b> is set upon by extradimensional flatulence.</span>")
				//break deliberately omitted

	if (!fart_on_other)
		switch(rand(1, 42))
			if (1) . = "<B>[src]</B> lets out a girly little 'toot' from their butt."
			if (2) . = "<B>[src]</B> farts loudly!"
			if (3) . = "<B>[src]</B> lets one rip!"
			if (4) . = "<B>[src]</B> farts! It sounds wet and smells like rotten eggs."
			if (5) . = "<B>[src]</B> farts robustly!"
			if (6) . = "<B>[src]</B> farted! It smells like something died."
			if (7) . = "<B>[src]</B> farts like a muppet!"
			if (8) . = "<B>[src]</B> defiles the station's air supply."
			if (9) . = "<B>[src]</B> farts a ten second long fart."
			if (10) . = "<B>[src]</B> groans and moans, farting like the world depended on it."
			if (11) . = "<B>[src]</B> breaks wind!"
			if (12) . = "<B>[src]</B> expels intestinal gas through the anus."
			if (13) . = "<B>[src]</B> release an audible discharge of intestinal gas."
			if (14) . = "<B>[src]</B> is a farting motherfucker!!!"
			if (15) . = "<B>[src]</B> suffers from flatulence!"
			if (16) . = "<B>[src]</B> releases flatus."
			if (17) . = "<B>[src]</B> releases methane."
			if (18) . = "<B>[src]</B> farts up a storm."
			if (19) . = "<B>[src]</B> farts. It smells like Soylent Surprise!"
			if (20) . = "<B>[src]</B> farts. It smells like pizza!"
			if (21) . = "<B>[src]</B> farts. It smells like George Melons' perfume!"
			if (22) . = "<B>[src]</B> farts. It smells like the kitchen!"
			if (23) . = "<B>[src]</B> farts. It smells like medbay in here now!"
			if (24) . = "<B>[src]</B> farts. It smells like the bridge in here now!"
			if (25) . = "<B>[src]</B> farts like a pubby!"
			if (26) . = "<B>[src]</B> farts like a goone!"
			if (27) . = "<B>[src]</B> sharts! That's just nasty."
			if (28) . = "<B>[src]</B> farts delicately."
			if (29) . = "<B>[src]</B> farts timidly."
			if (30) . = "<B>[src]</B> farts very, very quietly. The stench is OVERPOWERING."
			if (31) . = "<B>[src]</B> farts egregiously."
			if (32) . = "<B>[src]</B> farts voraciously."
			if (33) . = "<B>[src]</B> farts cantankerously."
			if (34) . = "<B>[src]</B> fart in they own mouth. A shameful [src]."
			if (35) . = "<B>[src]</B> pretends to fart out pure plasma! <span class='alert'><B>Oh you!</B></span>"
			if (36) . = "<B>[src]</B> pretends to farts out pure oxygen. What the fuck did they eat?"
			if (37) . = "<B>[src]</B> breaks wind noisily!"
			if (38) . = "<B>[src]</B> releases gas with the power of the gods! The very station trembles!!"
			if (39) . = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
			if (40) . = "<B>[src]</B> laughs! Their breath smells like a fart."
			if (41) . = "<B>[src]</B> farts, and as such, blob cannot evoulate."
			if (42) . = "<b>[src]</B> farts. It might have been the Citizen Kane of farts."

	var/turf/T = get_turf(src)
	if (T && T == src.loc)
		if(prob(10) && istype(src.loc, /turf/simulated/floor/specialroom/freezer)) //ZeWaka: Fix for null.loc
			. = "<b>[src]</B> farts. The fart freezes in MID-AIR!!!"
			new/obj/item/material_piece/fart(src.loc)
			var/obj/item/material_piece/fart/F = unpool(/obj/item/material_piece/fart)
			F.set_loc(src.loc)
	fartcount++
	if(fartcount == 69 || fartcount == 420)
		var/obj/item/paper/grillnasium/fartnasium_recruitment/flyer/F = new(get_turf(src))
		for(var/mob/living/carbon/C in view(2,src))
			if(C.put_in_hand_or_drop(F))
				break
		src.visible_message("<b>[src]</B> farts out a... wait is this viral marketing?")
#ifdef DATALOGGER
	game_stats.Increment("botfarts")
#endif
