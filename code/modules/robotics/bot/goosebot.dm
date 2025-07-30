

/obj/machinery/bot/goosebot
	name = "THE GOOSE"
	desc = "How did this manage to pass Nanotrasen's safety regulations?"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "goosebot"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = UNANCHORED
	on = 1
	health = 10
	no_camera = 1
	speech_verb_say = "blares"

/obj/machinery/bot/goosebot/proc/wakka_wakka()
	src.navigate_to(get_step_rand(src), max_dist=6)

/obj/machinery/bot/goosebot/process()
	. = ..()
	if(prob(50) && src.on == 1)
		src.say("[pick("HONK", "HOOOOOOONK","WACK WACK","GOWGOW","SCREEEEEE")]")
		if(prob(50))
			playsound(src.loc, 'sound/misc/thegoose_honk.ogg', 100, 0)
			throw_egg_is_true()
		else
			playsound(src.loc, 'sound/misc/thegoose_song.ogg', 100, 0)



/obj/machinery/bot/goosebot/attack_hand(mob/user, params)
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

	if (user.client?.tooltips)
		user.client.tooltips.show(
			TOOLTIP_PINNED, src,
			mouse = params,
			title = "THE GOOSE",
			content = dat,
		)

	return

/obj/machinery/bot/goosebot/attackby(obj/item/W, mob/user)
	src.visible_message(SPAN_COMBAT("[user] hits [src] with [W]!"))
	src.health -= W.force * 0.5
	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/goosebot/gib()
	return src.explode()

/obj/machinery/bot/goosebot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message(SPAN_COMBAT("<B>[src] blows apart!</B>"))
	playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
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
		src.visible_message(SPAN_COMBAT("<b>[src] fires an egg at [target.name]!</b>"))
		playsound(src.loc, 'sound/effects/pump.ogg', 50, 1)
		SPAWN(1 SECOND)
			E.throwforce = 1
			sleep(4 SECONDS)
			icon_state = "goosebot"

	return
