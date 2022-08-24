/obj/alien/egg
	desc = "It looks like a weird egg"
	name = "egg"
	icon_state = "egg"
	layer = MOB_LAYER
	density = 1
	anchored = 1

	var/health = 25

	New()
		SPAWN(90 SECONDS)
			if(src.health > 0)
				src.open()

	proc/open()
		SPAWN(1 SECOND)
			src.set_density(0)
			src.icon_state = "egg_hatched"
			new /obj/alien/facehugger(src.loc)

	attackby(obj/item/W, mob/user)
		if (src.health <= 0)
			src.visible_message("<span class='alert'><B>[user] has destroyed the egg!</B></span>")
			src.death()
			return

		switch(W.damtype)
			if("fire")
				src.health -= W.force * 0.75
			if("brute")
				src.health -= W.force * 0.1
			else
		..()

	proc/death()
		src.icon_state = "egg_destroyed"	//need an icon for this
		src.set_density(0)
