/datum/projectile/bfg
	name = "BFG shot"
	icon_state = "bfg"
	damage = 400
	cost = 100
	sname = "plasma blast"
	shot_sound = null
	shot_number = 1
	brightness = 0.8
	color_red = 0
	color_green = 0.9
	color_blue = 0.2


	on_hit(atom/hit)
		if (!master) return
		var/obj/overlay/explosion = new(master.loc)
		explosion.pixel_x = -16
		explosion.pixel_y = -16
		explosion.icon = 'icons/effects/64x64.dmi'
		FLICK("bfg_explode", explosion)
		SPAWN(1.6 SECONDS)
			qdel(explosion)
		playsound(master, 'sound/weapons/DSRXPLOD.ogg', 75)
//		explosion(master, get_turf(master), 2, 3, 4, 5, lagreducer = 1)
		for(var/mob/M in range(master, 4))
			M.ex_act(clamp(GET_DIST(M, master), 1, 3))
		return
