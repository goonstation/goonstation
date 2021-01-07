// by request

/obj/machinery/bot/duckbot
	name = "Amusing Duck"
	desc = "Bump'n go action! Ages 3 and up."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "duckbot"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	on = 1 // ACTION
	health = 5
	var/eggs = 0
	/// When it gets to 100, free egg!
	var/egg_process = 0
	no_camera = 1
	/// ha ha NO.
	dynamic_processing = 0

/obj/machinery/bot/duckbot/proc/wakka_wakka()
	step_rand(src,1)

/obj/machinery/bot/duckbot/process()
	. = ..()
	if(prob(40) && src.on == 1)
		SPAWN_DBG(0)
			var/message = pick("wacka", "quack","quacky","gaggle")
			src.speak(message)
			wakka_wakka()
			if(prob(10))
				playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 0) // MUSIC
			else if(prob (1) && src.eggs >= 1)
				var/obj/item/a_gift/easter/E = new /obj/item/a_gift/easter(src.loc)
				E.name = "duck egg"
				src.eggs--
				playsound(src.loc, "sound/misc/eggdrop.ogg", 50, 0)
	if(src.emagged == 1)
		SPAWN_DBG(0)
			var/message = pick("QUacK", "WHaCKA", "quURK", "bzzACK", "quock", "queck", "WOcka", "wacKY","GOggEL","gugel","goEGL","GeGGal")
			src.speak(message)
			wakka_wakka()
			if(prob(70))
				playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 1) // MUSIC
			else if(prob (10) && src.eggs >= 1)
				var/obj/item/a_gift/easter/E = new /obj/item/a_gift/easter(src.loc)
				E.name = "duck egg"
				src.eggs--
				playsound(src.loc, "sound/misc/eggdrop.ogg", 50, 1)
	src.egg_process++
	if(src.egg_process >= 100 && prob(20))
		src.eggs++
		src.egg_process = 0

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
			boutput(user, "<span class='alert'>You short out the horn on [src].</span>")
		SPAWN_DBG(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='alert'><B>[src] quacks loudly!</B></span>", 1)
				playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 1)
				src.eggs += rand(3,9)
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
		src.visible_message("<span class='alert'>[user] hits [src] with [W]!</span>")
		src.health -= W.force * 0.5
		if (src.health <= 0)
			src.explode()

/obj/machinery/bot/duckbot/gib()
	return src.explode()

/obj/machinery/bot/duckbot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
	elecflash(src, radius=1, power=3, exclude_center = 0)
	qdel(src)
	return
