// whatever man
#define BUTT_FLESH "Biological"
#define BUTT_ROBOT "Bionic"
#define BUTT_PLANT "Botanical"
#define BUTT_BROKE "Buggy" // Fallback in case it gets a weird-ass butt
#define BUTTBOT_MOVE_SPEED 10
/obj/machinery/bot/buttbot
	name = "buttbot"
	desc = "Well I... uh... huh."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "buttbot"
	layer = 5.0 // Todo layer
	bot_move_delay = BUTTBOT_MOVE_SPEED
	density = 0
	anchored = UNANCHORED
	on = 1
	health = 5
	no_camera = 1
	/// Its a butt
	dynamic_processing = 0
	/// A really obnoxious one at that
	PT_idle = PROCESSING_SIXTEENTH
	speakverbs = list("ferts", "toots", "honks", "parps")
	bot_voice = 'sound/misc/talk/bottalk_2.ogg'

	/// Can this wretched thing *move*?
	var/buttmobile = TRUE
	/// Can this awful thing *fart*?
	var/buttfart = TRUE
	/// Butt up things it heard?
	var/buttranslate = TRUE

	/// List of things overheard
	var/list/butt_memory = list()
	/// List of people farted on
	var/list/fart_memory = list()
	/// What kind of butt is this? For fluff purposes
	var/butt_fluff = BUTT_BROKE
	/// You can't superfart your way out of hell
	var/no_more_butt_explosions

	var/last_fart
	/// Minimum time between farts
	var/fart_cooldown = 10 SECONDS

	var/last_scoot
	/// Minimum time between moves
	var/scoot_cooldown = 2 SECONDS

	var/last_butt
	/// Minimum butt between butts
	var/butt_cooldown = 3 SECONDS

	/// hello this is my butt
	var/obj/item/clothing/head/butt/butt
	/// and this is the arm sticking out of my butt
	var/obj/item/parts/buttarm
	/// and this is the fallback butt I have if someone spawns me
	var/default_butt = /obj/item/clothing/head/butt
	var/list/fartsounds = list('sound/voice/farts/poo2.ogg', \
								'sound/voice/farts/fart1.ogg', \
								'sound/voice/farts/fart2.ogg', \
								'sound/voice/farts/fart3.ogg', \
								'sound/voice/farts/fart4.ogg', \
								'sound/voice/farts/fart5.ogg')

/obj/machinery/bot/buttbot/cyber
	name = "robuttbot"
	icon_state = "cyberbuttbot"
	default_butt = /obj/item/clothing/head/butt/cyberbutt

/obj/machinery/bot/buttbot/text2speech
	text2speech = 1

/obj/machinery/bot/buttbot/synth //Opinion: i personally think this should be in the same file as buttbots
	name = "Organic Buttbot" //TODO: This and synthbutts need to use the new green synthbutt sprites
	desc = "What part of this even makes any sense."
	default_butt = /obj/item/clothing/head/butt/synth

/obj/machinery/bot/buttbot/New(var/_butt, var/_arm)
	..()
	if(istype(_butt, /obj/item/clothing/head/butt))
		src.butt = _butt
	else
		src.butt = new src.default_butt(src)
	if(istype(_arm, /obj/item/parts))
		src.buttarm = _arm
	else
		src.buttarm = new/obj/item/parts/robot_parts/arm/left/light(src)

	if(src.butt?.toned)
		var/icon/new_icon = icon(src.icon, "butt_ncbot")
		if(butt.s_tone)
			new_icon.Blend(butt.s_tone, ICON_MULTIPLY)
		var/icon/my_icon = icon(src.icon, src.icon_state)
		my_icon.Blend(new_icon, ICON_OVERLAY)
		src.icon = my_icon
	switch(src.butt?.type)
		if(/obj/item/clothing/head/butt/synth)
			src.butt_fluff = BUTT_PLANT
		if(/obj/item/clothing/head/butt/cyberbutt)
			src.butt_fluff = BUTT_ROBOT
		else
			src.butt_fluff = BUTT_FLESH

/obj/machinery/bot/buttbot/emp_act()
	src.emag_act()

/// Makes the buttbot mill around aimlessly, or chase people if emagged
/obj/machinery/bot/buttbot/proc/scoot()
	if(moving) return
	if(src.emagged)
		for(var/atom/A as anything in view(5, src))
			if(!(A.event_handler_flags & IS_FARTABLE) && !(A in src.fart_memory))
				src.navigate_to(A, BUTTBOT_MOVE_SPEED, 0, 15)
				break
	else
		step_rand(src, BUTTBOT_MOVE_SPEED)

/obj/machinery/bot/buttbot/process(mult)
	if(src.exploding)
		return
	if(src.on == 1)
		if(src.buttranslate && prob(60*mult) && !ON_COOLDOWN(global, "butt_talker", src.butt_cooldown))
			if(length(src.butt_memory) >= 1)
				speak(src.buttify())
			else
				speak(pick("butts", "butt"))
		if(src.buttfart && prob(25) && !ON_COOLDOWN(global, "butt_farter", src.fart_cooldown))
			var/fartmessage = src.fart()
			if(fartmessage)
				src.audible_message("[fartmessage]")
				src.robo_expel_fart_gas(0)
		if(src.buttmobile && prob(80) && !ON_COOLDOWN(global, "butt_scooter", src.scoot_cooldown))
			src.scoot()
	if(src.emagged == 1)
		var/message = src.buttifricky()
		if(prob(2))
			playsound(src.loc, 'sound/misc/extreme_ass.ogg', 35, 1)
		speak(message)
		var/fartmessage = src.fart()
		if(fartmessage)
			src.audible_message("[fartmessage]")
			src.robo_expel_fart_gas(1)
		if(prob(1)) // small chance to blow its ass out
			src.superfart()
		if(!moving)
			src.scoot()
	if(frustration >= 8)
		src.KillPathAndGiveUp(1)
	. = ..()

/obj/machinery/bot/buttbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if(!src.emagged)
		if(user)
			user.show_text("You short out the vocal emitter on [src].", "red")
		src.visible_message(SPAN_ALERT("<B>[src] buzzes oddly!</B>"))
		playsound(src.loc, 'sound/misc/extreme_ass.ogg', 35, 1)
		src.emagged = 1
		return 1
	return 0

/obj/machinery/bot/buttbot/demag(var/mob/user)
	if(!src.emagged)
		return 0
	if(user)
		user.show_text("You repair [src]'s vocal emitter. Thank God.", "blue")
	src.emagged = 0
	return 1

/obj/machinery/bot/buttbot/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/card/emag))
		return // Do not hit the buttbot with the emag tia
	else
		src.visible_message(SPAN_ALERT("[user] hits [src] with [W]!"))
		src.health -= W.force * 0.5
		if(src.health <= 0)
			src.explode()

/obj/machinery/bot/buttbot/proc/buttifricky()
	if(prob(50))
		return pick("BuTTS", "buTt", "b##t", "bztBUTT", "b^%t", "BUTT", "buott", "bats", "bates", "bouuts", "buttH", "b&/t", "beats", "boats", "booots", "BAAAAATS&/", "//t/%/")
	else
		var/l
		for(var/i in 1 to rand(4,10))
			l = pick("b", "u", "t", "o", "a", "h", "s", "/", "#", "&", 10;"butt")
			if(prob(40))
				l = capitalize(l)
			. += l

/obj/machinery/bot/buttbot/proc/buttify()
	if(length(src.butt_memory) < 1) return "butt..."
	var/butt_index = rand(1,length(src.butt_memory))
	var/list/speech_list = splittext(src.butt_memory[butt_index], " ")
	if(prob(50))
		src.butt_memory -= src.butt_memory[butt_index]

	var/num_butts = rand(1,4)
	var/counter = 0
	while(num_butts)
		counter++
		num_butts--
		speech_list[rand(1,speech_list.len)] = "butt"
		if(counter >= (speech_list.len / 2) )
			num_butts = 0

	return jointext(speech_list, " ")

/obj/machinery/bot/buttbot/hear_talk(var/mob/living/carbon/speaker, messages, real_name, lang_id)
	if(!messages || !src.on)
		return
	var/message = (lang_id == "english" || lang_id == "") ? messages[1] : messages[2]
	if(message && !(message in src.butt_memory))
		src.butt_memory += message
	return


/obj/machinery/bot/buttbot/Topic(href, href_list)
	if(!(BOUNDS_DIST(usr, src) == 0))
		boutput(usr, "You're too far away from [src], get closer.[prob(5) ? pick(" ...if you really want to."," It won't bite.") : ""]")
		return

	if(href_list["on"])
		on = !on

	if(href_list["butt_speak_toggle"])
		src.buttranslate = !src.buttranslate

	if(href_list["butt_move_toggle"])
		src.buttmobile = !src.buttmobile

	if(href_list["butt_fart_toggle"])
		src.buttfart = !src.buttfart

	src.Attackhand(usr)

/obj/machinery/bot/buttbot/attack_hand(mob/user)
	var/dat
	var/butt_engine = "Bio-Reactive Organic Ketone Engine"
	switch(src.butt_fluff)
		if(BUTT_FLESH)
			butt_engine = "Steato-Electric Armature Turbine"
		if(BUTT_ROBOT)
			butt_engine = "Battery Utilization Manifold"
		if(BUTT_PLANT)
			butt_engine = "Phyto-Active Induction Nodule"

	dat += "<TT><B>[src.butt_fluff] Utility Techno-Tool v4.5.5</B></TT><BR>"
	dat += "<U><h4>Autonomous Reactive Speech Emitter:</h4></U>"
	dat += "<A href='byond://?src=\ref[src];butt_speak_toggle=1'>[src.buttranslate ? "Active" : "Inactive"]</A><BR><BR>"
	dat += "<U><h4>\"Rolling Explorer\" Autonomous Rover:</h4></U>"
	dat += "<A href='byond://?src=\ref[src];butt_move_toggle=1'>[src.buttmobile ? "Active" : "Inactive"]</A><BR><BR>"
	dat += "<U><h4>Patty-Heinrich Atmospheric Replenishment Technique:</h4></U>"
	dat += "<A href='byond://?src=\ref[src];butt_fart_toggle=1'>[src.buttfart ? "Active" : "Inactive"]</A><BR><BR>"
	dat += "<U><h4>[butt_engine]:</h4></U>"
	dat += "<A href='byond://?src=\ref[src];on=1'>[src.on ? "Active" : "Inactive"]</A>"

	user.Browse("<HEAD><TITLE>B.U.T.T. BOT</TITLE></HEAD>[dat]", "window=buttbot")
	onclose(user, "buttbot")
	return


/obj/machinery/bot/buttbot/gib()
	return src.explode(1)

/obj/machinery/bot/buttbot/explode(var/gib)
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message(SPAN_ALERT("<B>[src] blows apart!</B>"))
	var/list/throwstuff = list()
	throwstuff += src.butt
	throwstuff += src.buttarm
	var/buttsploded = 0

	if(prob(20) || gib)
		buttsploded = 1 // The butt got destroyed
		throwstuff -= src.butt
		qdel(src.butt)

	if(src.butt_fluff == BUTT_ROBOT)
		robogibs(get_turf(src))
		handle_ejectables(get_turf(src), throwstuff)
		if(buttsploded)
			src.visible_message(SPAN_ALERT("<B>[src]'s butt shatters into a pile of scrap!</B>"))
	else
		gibs(get_turf(src), throwstuff)
		if(buttsploded)
			src.visible_message(SPAN_ALERT("<B>[src]'s butt explodes into gore!</B>"))

	qdel(src)
	return

/// cant possibly be a bad idea
/obj/machinery/bot/buttbot/proc/robo_expel_fart_gas(var/gross)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/gas = new /datum/gas_mixture
	if(gross == 1)
		gas.farts = 0.5
	else if(gross == 2)
		gas.farts = 20
	else
		gas.oxygen = 1
	gas.temperature = T20C
	gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
	if(T)
		T.assume_air(gas)

/obj/machinery/bot/buttbot/proc/superfart()
	src.exploding = 1
	var/oldtransform = src.transform
	src.visible_message(SPAN_ALERT("<b>[src]</b>'s exhaust port clogs!"))
	violent_standup_twitch(src)
	playsound(src, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)
	SPAWN(2 SECONDS)
		var/jitters = 30
		src.visible_message(SPAN_ALERT("<b>[src]</b> creaks ominously!"))
		src.transform *= 1.1
		var/old_x = src.pixel_x
		var/old_y = src.pixel_y
		while(jitters-- >= 1)
			var/amplitude = 1
			pixel_x = old_x + rand(-amplitude, amplitude)
			pixel_y = old_y + rand(-amplitude/3, amplitude/3)
			sleep(0.1 SECONDS)
		SPAWN(3 SECONDS)
			jitters = 30
			src.visible_message(SPAN_ALERT("<b>[src]</b> bulges!"))
			src.transform *= 1.1
			while(jitters-- >= 1)
				var/amplitude = 5
				if(prob(1))
					src.robo_expel_fart_gas(1)
					playsound(src, pick(src.fartsounds), 35, 1, channel=VOLUME_CHANNEL_EMOTE)
				pixel_x = old_x + rand(-amplitude, amplitude)
				pixel_y = old_y + rand(-amplitude/3, amplitude/3)
				sleep(0.1 SECONDS)
			SPAWN(3 SECONDS)
				src.visible_message(SPAN_ALERT("<b>[src]</b>'s ass explodes!"))
				playsound(src.loc, 'sound/voice/farts/superfart.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.robo_expel_fart_gas(2)
				var/turf/src_turf = get_turf(src)
				if(src_turf)
					src_turf.fluid_react_single("toxic_fart",50,airborne = 1)
					for(var/mob/living/V in range(get_turf(src),8))
						shake_camera(V,10,64)
						boutput(V, SPAN_ALERT("You are sent flying!"))
						V.changeStatus("knockdown", 3 SECONDS)
						var/turf/target = get_edge_target_turf(V, get_dir(src, V))
						V.throw_at(target, 8, 3, throw_type = THROW_GUNIMPACT)
				var/go2hell
				src.transform = oldtransform
				for (var/obj/item/bible/B in src.loc)
					go2hell = 1
					var/turf/oldloc = get_turf(src)
					src.visible_message(SPAN_ALERT("[src] blasts its ass all over the bible.<br><b>A mysterious force <u>is not pleased</u>!</b>"))
					src.set_loc(pick(get_area_turfs(/area/afterlife/hell/hellspawn)))
					B.burn_possible = FALSE // protect the book
					SPAWN(1 SECOND)
						if(B)
							B.burn_possible = initial(B.burn_possible) // But only till the explosion's gone
					explosion_new(oldloc, oldloc, 1, 1)
					if(src.butt_fluff == BUTT_ROBOT)
						robogibs(oldloc)
						src.visible_message(SPAN_ALERT("<B>[src]'s butt shatters into a pile of scrap!</B>"))
					else
						gibs(oldloc)
						src.visible_message(SPAN_ALERT("<B>[src]'s butt explodes into gore!</B>"))
					src.exploding = 0
					src.no_more_butt_explosions = 1
					break
				if(!go2hell)
					src.exploding = 0
					src.gib()

/obj/machinery/bot/buttbot/proc/fart()
	if(!farting_allowed)
		. = "<B>[src]</B> grunts for a moment. Nothing happens."
		return

	if(istype(src, /obj/machinery/bot/buttbot/cyber))
		playsound(src, 'sound/voice/farts/poo2_robot.ogg', 50, TRUE, channel=VOLUME_CHANNEL_EMOTE)
	else
		playsound(src, pick(src.fartsounds), 35, 1, channel=VOLUME_CHANNEL_EMOTE)

	var/fart_on_other = 0
	for (var/atom/A as anything in src.loc)
		if(A.event_handler_flags & IS_FARTABLE)
			if(istype(A,/mob/living))
				var/mob/living/M = A
				if(M == src || !M.lying)
					continue
				. = SPAN_ALERT("<B>[src]</B> farts in [M]'s face!")
				fart_on_other = 1
				src.fart_memory += A
				break
			else if(istype(A,/obj/item/bible))
				src.visible_message(SPAN_ALERT("[src] farts on the bible.<br><b>A mysterious force smites [src]!</b>"))
				fart_on_other = 1
				src.fart_memory += A
				src.gib()
				break
			else if(istype(A,/obj/item/book_kinginyellow))
				var/obj/item/book_kinginyellow/K = A
				src.visible_message(SPAN_ALERT("[src] farts on [A].<br><b>A mysterious force sucks [src] into the book!!</b>"))
				fart_on_other = 1
				src.fart_memory += A
				new/obj/decal/implo(get_turf(src))
				playsound(src, 'sound/effects/suck.ogg', 100, TRUE)
				src.set_loc(K)
				break
			else if(istype(A,/obj/item/photo/voodoo))
				var/obj/item/photo/voodoo/V = A
				var/mob/M = V.cursed_dude
				if(!M || !M.lying)
					continue
				playsound(M, pick(src.fartsounds), 35, 1, channel=VOLUME_CHANNEL_EMOTE)
				switch(rand(1, 7))
					if(1) M.visible_message(SPAN_EMOTE("<b>[M]</b> suddenly radiates an unwelcoming odor."))
					if(2) M.visible_message(SPAN_EMOTE("<b>[M]</b> is visited by ethereal incontinence."))
					if(3) M.visible_message(SPAN_EMOTE("<b>[M]</b> experiences paranormal gastrointestinal phenomena."))
					if(4) M.visible_message(SPAN_EMOTE("<b>[M]</b> involuntarily telecommutes to the farty party."))
					if(5) M.visible_message(SPAN_EMOTE("<b>[M]</b> is swept over by a mysterious draft."))
					if(6) M.visible_message(SPAN_EMOTE("<b>[M]</b> abruptly emits an odor of cheese."))
					if(7) M.visible_message(SPAN_EMOTE("<b>[M]</b> is set upon by extradimensional flatulence."))
				//break deliberately omitted

	if(!fart_on_other)
		switch(rand(1, 42))
			if(1) . = "<B>[src]</B> lets out a little 'toot' from their butt."
			if(2) . = "<B>[src]</B> farts loudly!"
			if(3) . = "<B>[src]</B> lets one rip!"
			if(4) . = "<B>[src]</B> farts! It sounds wet and smells like rotten eggs."
			if(5) . = "<B>[src]</B> farts robustly!"
			if(6) . = "<B>[src]</B> farted! It smells like something died."
			if(7) . = "<B>[src]</B> farts like a muppet!"
			if(8) . = "<B>[src]</B> defiles the station's air supply."
			if(9) . = "<B>[src]</B> farts a ten second long fart."
			if(10) . = "<B>[src]</B> groans and moans, farting like the world depended on it."
			if(11) . = "<B>[src]</B> breaks wind!"
			if(12) . = "<B>[src]</B> expels intestinal gas through the anus."
			if(13) . = "<B>[src]</B> release an audible discharge of intestinal gas."
			if(14) . = "<B>[src]</B> is a farting motherfucker!!!"
			if(15) . = "<B>[src]</B> suffers from flatulence!"
			if(16) . = "<B>[src]</B> releases flatus."
			if(17) . = "<B>[src]</B> releases methane."
			if(18) . = "<B>[src]</B> farts up a storm."
			if(19) . = "<B>[src]</B> farts. It smells like Soylent Surprise!"
			if(20) . = "<B>[src]</B> farts. It smells like pizza!"
			if(21) . = "<B>[src]</B> farts. It smells like George Melons' perfume!"
			if(22) . = "<B>[src]</B> farts. It smells like the kitchen!"
			if(23) . = "<B>[src]</B> farts. It smells like medbay in here now!"
			if(24) . = "<B>[src]</B> farts. It smells like the bridge in here now!"
			if(25) . = "<B>[src]</B> farts like a pubby!"
			if(26) . = "<B>[src]</B> farts like a goone!"
			if(27) . = "<B>[src]</B> sharts! That's just nasty."
			if(28) . = "<B>[src]</B> farts delicately."
			if(29) . = "<B>[src]</B> farts timidly."
			if(30) . = "<B>[src]</B> farts very, very quietly. The stench is OVERPOWERING."
			if(31) . = "<B>[src]</B> farts egregiously."
			if(32) . = "<B>[src]</B> farts voraciously."
			if(33) . = "<B>[src]</B> farts cantankerously."
			if(34) . = "<B>[src]</B> fart in they own butt. A shameful [src]."
			if(35) . = "<B>[src]</B> pretends to fart out pure plasma! [SPAN_ALERT("<B>Oh you!</B>")]"
			if(36) . = "<B>[src]</B> pretends to farts out pure oxygen. What the fuck did they eat?"
			if(37) . = "<B>[src]</B> breaks wind noisily!"
			if(38) . = "<B>[src]</B> releases gas with the power of the gods! The very station trembles!!"
			if(39) . = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
			if(40) . = "<B>[src]</B> laughs! Their breath smells like a fart."
			if(41) . = "<B>[src]</B> farts, and as such, blob cannot evoulate."
			if(42) . = "<b>[src]</B> farts. It might have been the Citizen Kane of farts."

	var/turf/T = get_turf(src)
	if(T && T == src.loc)
		if(prob(10) && istype(src.loc, /turf/simulated/floor/specialroom/freezer)) //ZeWaka: Fix for null.loc
			. = "<b>[src]</B> farts. The fart freezes in MID-AIR!!!"
			new/obj/item/material_piece/fart(src.loc)
			var/obj/item/material_piece/fart/F = new /obj/item/material_piece/fart
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
