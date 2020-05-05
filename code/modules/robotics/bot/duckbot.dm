// by request

/obj/machinery/bot/duckbot
	name = "Amusing Duck"
	desc = "Bump'n go action! Ages 3 and up."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "duckbot"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	on = 1 // ACTION
	health = 5
	var/eggs = 0
	no_camera = 1

/obj/machinery/bot/duckbot/proc/quack(var/message)
	if(!src.on || !message || src.muted)
		return
	src.visible_message("<span class='game say'><span class='name'>[src]</span> honks, \"[message]\"</span>")
	return

/obj/machinery/bot/duckbot/proc/wakka_wakka()
		var/turf/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
		if(isturf(moveto) && !moveto.density) step_towards(src, moveto)

/obj/machinery/bot/duckbot/process()
	if(prob(10) && src.on == 1)
		SPAWN_DBG(0)
			var/message = pick("wacka", "quack","quacky","gaggle")
			quack(message)
			wakka_wakka()
			if(prob(40))
				playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 0) // MUSIC
			if(prob (3) && src.eggs >= 1)
				var/obj/item/a_gift/easter/E = new /obj/item/a_gift/easter(src.loc)
				E.name = "duck egg"
				src.eggs--
				playsound(src.loc, "sound/misc/eggdrop.ogg", 50, 0)
	if(src.emagged == 1)
		SPAWN_DBG(0)
			var/message = pick("QUacK", "WHaCKA", "quURK", "bzzACK", "quock", "queck", "WOcka", "wacKY","GOggEL","gugel","goEGL","GeGGal")
			quack(message)
			wakka_wakka()
			if(prob(70))
				playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 1) // MUSIC
			if(prob (10) && src.eggs >= 1)
				var/obj/item/a_gift/easter/E = new /obj/item/a_gift/easter(src.loc)
				E.name = "duck egg"
				src.eggs--
				playsound(src.loc, "sound/misc/eggdrop.ogg", 50, 1)

/obj/machinery/bot/duckbot/Topic(href, href_list)
	if (!(usr in range(1)))
		return
	if (href_list["on"])
		on = !on
	attack_hand(usr)

/obj/machinery/bot/duckbot/attack_hand(mob/user as mob)
	var/dat
	dat += "<TT><B>AMUSING DUCK</B></TT><BR>"
	dat += "<B>toy series with strong sense for playing</B><BR><BR>"
	dat += "LAY EGG IS: <A href='?src=\ref[src];on=1'>[src.on ? "TRUE!!!" : "NOT TRUE!!!"]</A><BR><BR>"
	dat += "AS THE DUCK ADVANCING,FLICKING THE PLUMAGE AND YAWNING THE MOUTH GO WITH MUSIC & LIGHT.<BR>"
	dat += "THE DUCK STOP,IT SWAYING TAIL THEN THE DUCK LAY AN EGG AS OPEN IT'S BUTTOCKS,<BR>GO WITH THE DUCK'S CALL"

	user.Browse("<HEAD><TITLE>Amusing Duck</TITLE></HEAD>[dat]", "window=ducky")
	onclose(user, "ducky")
	return
/obj/machinery/bot/duckbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, "<span style=\"color:red\">You short out the horn on [src].</span>")
		SPAWN_DBG(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span style=\"color:red\"><B>[src] quacks loudly!</B></span>", 1)
				playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 1)
				src.eggs = rand(3,9)
		src.emagged = 1
		return 1
	return 0

/obj/machinery/bot/duckbot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s horn. Thank God.", "blue")
	src.emagged = 0
	return 1

/obj/machinery/bot/duckbot/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/card/emag))
		emag_act(user, W)
	else
		src.visible_message("<span style=\"color:red\">[user] hits [src] with [W]!</span>")
		src.health -= W.force * 0.5
		if (src.health <= 0)
			src.explode()

/obj/machinery/bot/duckbot/gib()
	return src.explode()

/obj/machinery/bot/duckbot/explode()
	src.on = 0
	for(var/mob/O in hearers(src, null))
		O.show_message("<span style=\"color:red\"><B>[src] blows apart!</B></span>", 1)
	var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return
