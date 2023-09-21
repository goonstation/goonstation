// <drsingh>: just what the game needs, more copy pasted and slightly adjusted junk
/obj/dartboard
	name = "Dartboard"
	desc = "A dartboard."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dartboard"
	anchored = ANCHORED
	density = 0
	opacity = 0
	var/last_score = 0
	event_handler_flags = USE_FLUID_ENTER

	Crossed(atom/movable/M)
		..()
		if (istype(M, /obj/item/implant/projectile/body_visible/dart/bardart) && M.dir == 1)
			M.pixel_y += rand(22,38)
			M.pixel_x += rand(-8,8)
			last_score = rand(1,60)
			src.throwing = 0
			playsound(src.loc, 'sound/effects/syringeproj.ogg', 100, 1)
			src.visible_message("<span class='notice'>Score: [last_score].</span>")
		if (src.last_score == 50)
			src.visible_message("<span class='alert'>It's a bullseye!</span>")

/obj/item/storage/box/lawndart_kit
	name = "Lawn Darts box"
	desc = "Contains three darts, hours of outdoors fun guaranteed!"
	icon_state = "box"
	spawn_contents = list(/obj/item/implant/projectile/body_visible/dart/lawndart = 3)
