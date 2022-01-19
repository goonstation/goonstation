/obj/item/clothing/suit/cardboard_box
	name = "cardboard box"
	desc = "A pretty large box, made of cardboard. Looks a bit worn out."
	icon = 'icons/obj/clothing/overcoats/item_suit_cardboard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_cardboard.dmi'
	icon_state = "c_box"
	item_state = "c_box"
	density = 1
	see_face = 0
	over_hair = 1
	wear_layer = MOB_OVERLAY_BASE
	c_flags = COVERSEYES | COVERSMOUTH
	body_parts_covered = HEAD|TORSO|LEGS|ARMS
	permeability_coefficient = 0.8
	var/eyeholes = FALSE
	var/accessory = FALSE
	var/face = null
	block_vision = 1

	New()
		..()
		if (face)
			src.UpdateOverlays(image(src.icon, "face-[face]"), "face")
			src.wear_image.overlays += image(src.wear_image_icon, "face-[face]")

	setupProperties()
		..()
		setProperty("movespeed", 0.7)
		setProperty("coldprot", 33)
		setProperty("heatprot", 33)
		setProperty("meleeprot", 1)

	attack_hand(mob/user as mob)
		if (user.a_intent == INTENT_HARM)
			user.visible_message("<span class='notice'>[user] taps [src].</span>",\
			"<span class='notice'>You tap [src].</span>")
		else
			return ..()

	attackby(obj/item/W, mob/user)
		if (issnippingtool(W))
			if (src.eyeholes)
				boutput(user, "<span class='notice'>[src] already has eyeholes cut out of it!</span>")
			else
				user.visible_message("<span class='notice'>[user] begins cutting eyeholes out of [src].</span>",\
				"<span class='notice'>You begin cutting eyeholes out of [src].</span>")
				if (!do_after(user, 2 SECONDS))
					user.show_text("You were interrupted!", "red")
					return
				src.eyeholes = TRUE
				block_vision = 0
				src.UpdateOverlays(image(src.icon, "eyeholes"), "eyeholes")
				src.wear_image.overlays += image(src.wear_image_icon, "eyeholes")
				playsound(src, "sound/items/Scissor.ogg", 100, 1)
				user.visible_message("<span class='notice'>[user] cuts eyeholes out of [src].</span>",\
				"<span class='notice'>You cut eyeholes out of [src].</span>")
		else if (istype(W, /obj/item/pen/crayon))
			if (src.face)
				boutput(user, "<span class='notice'>[src] already has a face!</span>")
			else
				var/obj/item/pen/crayon/C = W
				var/emotion = alert("What face would you like to draw on [src]?",,"happy","angry","sad")
				src.face = emotion
				var/image/item_image = image(src.icon, "face-[face]")
				item_image.color = C.font_color
				src.UpdateOverlays(item_image, "face")
				var/image/worn_image = image(src.wear_image_icon, "face-[face]")
				worn_image.color = C.font_color
				src.wear_image.overlays += worn_image
				user.visible_message("<span class='notice'>[user] draws a [emotion] face on [src].</span>",\
				"<span class='notice'>You draw a [emotion] face on [src].</span>")
		else if (istype(W, /obj/item/clothing/mask/moustache))
			if (src.accessory)
				boutput(user, "<span class='notice'>[src] already has an accessory!</span>")
			else
				src.accessory = TRUE
				src.UpdateOverlays(image(src.icon, "moustache"), "accessory")
				src.wear_image.overlays += image(src.wear_image_icon, "moustache")
				user.visible_message("<span class='notice'>[user] adds [W] to [src]!</span>",\
				"<span class='notice'>You add [W] to [src]!</span>")
				user.u_equip(W)
				qdel(W)
		else
			..()

/obj/item/clothing/suit/cardboard_box/head_surgeon
	name = "cardboard box - 'Head Surgeon'"
	desc = "The HS looks a lot different today!"
	face = "HS"
	var/text2speech = 1

	New()
		..()
		START_TRACKING_CAT(TR_CAT_HEAD_SURGEON)
		if (prob(50))
			new /obj/machinery/bot/medbot/head_surgeon(src.loc)
			qdel(src)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_HEAD_SURGEON)
		. = ..()

	proc/speak(var/message)
		if (!message)
			return
		src.audible_message("<span class='game say'><span class='name'>[src]</span> [pick("rustles", "folds", "womps", "boxes", "foffs", "flaps")], \"[message]\"")
		if (src.text2speech)
			var/audio = dectalk("\[:nk\][message]")
			if (audio["audio"])
				for (var/mob/O in hearers(src, null))
					if (!O.client)
						continue
					ehjax.send(O.client, "browseroutput", list("dectalk" = audio["audio"]))
				return 1
			else
				return 0
		return

/obj/item/clothing/suit/cardboard_box/captain
	name = "cardboard box - 'Captain'"
	desc = "The Captain looks a lot different today!"
	face = "cap"

/obj/item/clothing/suit/cardboard_box/colorful
	desc = "There are paint splatters on this box. Paint splatters? Blood splatters. Colorful blood splatters."
	icon_state = "c_box-colorful"

/obj/item/clothing/suit/cardboard_box/colorful/clown
	name = "cardboard box - 'Clown'"
	desc = "Much like a real clown car, it's more spacious on the inside. Must be, to fit the clown."
	face = "clown"

/obj/item/clothing/suit/cardboard_box/ai
	name = "cardboard box - 'AI'"
	desc = "It can probably still open doors!"
	face = "ai"

/obj/item/cardboardbits
	name = "Unfinished cardboard armor"
	icon = 'icons/obj/clothing/overcoats/item_suit_cardboard.dmi'
	icon_state = "cardboardsuitbits"
	item_state= "cardboardsuitbits"

	desc = "A work in progress piece of cardboard armor. "
	var/status = FALSE

	attackby(obj/item/W as obj, mob/user as mob)
		if (isscrewingtool(W))
			if(status)
				boutput(user, "<span class='notice'>You have already stabbed holes in the cardboard</span>")
			else
				status = TRUE
				boutput(user, "<span class='notice'>You poke strategic holes in the cardboard </span>")
				icon_state = "cardboardsuitholes"
				item_state = "cardboardsuitholes"
		if(status)
			if(istype(W, /obj/item/cable_coil )) // if tarm is allowed to do this with pipe bombs and not cost wire, why not armor?


				var/obj/item/cable_coil/coil = W
				if(coil.use(30))
					boutput(user, "<span class='notice'>You thread the wire through the holes </span>")
					new /obj/item/clothing/suit/armor/cardboard(get_turf(src))
					qdel(src)
				else
					boutput(user, "<span class='notice'>You feel like you'll need more wire than what you have if you want this thing to be sturdy. A full coil's worth should do. </span>")




	get_desc()
		if(status)// weird way of doing this but I think it'll work
			. +=  "Now all it needs is something to thread through the holes"
		else
			. +="If you plan on wearing this, you'll need some way to hold it together. Maybe poke holes for wire?"


