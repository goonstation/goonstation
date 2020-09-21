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
	if (prob(10) && src.on == 1)
		SPAWN_DBG(0)
			var/message = pick("butts", "butt")
			speak(message)
	if (src.emagged == 1)
		SPAWN_DBG(0)
			var/message = pick("BuTTS", "buTt", "b##t", "bztBUTT", "b^%t", "BUTT", "buott", "bats", "bates", "bouuts", "buttH", "b&/t", "beats", "boats", "booots", "BAAAAATS&/", "//t/%/")
			if (prob(2))
				playsound(src.loc, "sound/misc/extreme_ass.ogg", 50, 1)
			else
				playsound(src.loc, 'sound/vox/poo.ogg', 50, 1)
			speak(message)

/obj/machinery/bot/buttbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if (user)
			user.show_text("You short out the vocal emitter on [src].", "red")
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
	elecflash(src, radius=1, power=3, exclude_center = 0)
	qdel(src)
	return
