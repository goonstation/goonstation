

/obj/machinery/bot/goosebot
	name = "THE GOOSE"
	desc = "How did this manage to pass Nanotrasen's safety regulations?"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "goosebot"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	on = 1
	health = 10
	no_camera = 1

/obj/machinery/bot/goosebot/proc/quack(var/message)
	if (!src.on || !message || src.muted)
		return
	src.visible_message("<span class='game say'><span class='name'>[src]</span> blares, \"[message]\"")
	return

/obj/machinery/bot/goosebot/proc/wakka_wakka()
		var/turf/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
		if(isturf(moveto) && !moveto.density) step_towards(src, moveto)

/obj/machinery/bot/goosebot/process()
	if(prob(50) && src.on == 1)
		SPAWN_DBG(0)
			var/message = pick("HONK", "HOOOOOOONK","WACK WACK","GOWGOW","SCREEEEEE")
			quack(message)
			wakka_wakka()
			if(prob(50))
				playsound(src.loc, "sound/misc/thegoose_honk.ogg", 100, 0)
				throw_egg_is_true()
			else
				playsound(src.loc, "sound/misc/thegoose_song.ogg", 100, 0)



/obj/machinery/bot/goosebot/attack_hand(mob/user as mob, params)
	var/dat
	dat += "<TT><I>YOU CHOICE</I></TT><BR>"
	dat += "<TT><B>THE GOOSE</B></TT><BR>"
	dat += "NEW EDITION!<BR><BR>"
	dat += "LATEST TECHNOLOGY SPECIAL STYLE<BR><BR>"
	dat += "SPECIFICATIONS COLOURS AND CONTENTS MAY VARY FROM ILLUSTRATIONS<BR>"
	dat += "THE HEAD CAN TURN<BR>"
	dat += "Lamplight beautiful melody THE WHOLE BODY WILL SWING<BR>"
	dat += "WILL LAY EGG<BR>"
	dat += "USE 3 AA BATTERIES (BOT INCLUDED)<BR>"
	dat += "BUMP THE SHOT WILL TURN A CORNER<BR>"
	dat += "INSTALL THE EGG<BR>"

	if (user.client.tooltipHolder)
		user.client.tooltipHolder.showClickTip(src, list(
			"params" = params,
			"title" = "THE GOOSE",
			"content" = dat,
		))

	return

/obj/machinery/bot/goosebot/attackby(obj/item/W as obj, mob/user as mob)
	src.visible_message("<span class='combat'>[user] hits [src] with [W]!</span>")
	src.health -= W.force * 0.5
	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/goosebot/gib()
	return src.explode()

/obj/machinery/bot/goosebot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='combat'><B>[src] blows apart!</B></span>", 1)
	explosion(src, src.loc , 0, 0, 1, 1)
	qdel(src)
	return

/obj/machinery/bot/goosebot/proc/throw_egg_is_true()
	var/mob/living/target = locate() in view(7,src)
	if(target && !target.lying)
		var/obj/item/a_gift/easter/E = new /obj/item/a_gift/easter(src.loc)
		E.throwforce = 40
		E.name = "goose egg"
		E.desc = "A goose's egg, apparently."
		E.throw_at(target, 16, 3)

		icon_state = "goosebot-wild"
		src.visible_message("<span class='combat'><b>[src] fires an egg at [target.name]!</b></span>")
		playsound(src.loc, "sound/effects/pump.ogg", 50, 1)
		SPAWN_DBG(1 SECOND)
			E.throwforce = 1
			sleep(4 SECONDS)
			icon_state = "goosebot"

	return
