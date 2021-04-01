/obj/alien/egg/New()
	if(aliens_allowed)
		spawn(1800)
			src.open()
	else
		del(src)

/obj/alien/egg/proc/open()
	spawn(10)
		src.density = 0
		src.icon_state = "egg_hatched"
		new /obj/alien/facehugger(src.loc)