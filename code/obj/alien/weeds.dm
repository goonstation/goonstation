
/obj/alien/weeds
	name = "weeds"
	desc = "weird purple weeds"
	icon_state = "weeds"

	layer = TURF_LAYER
	anchored = 1
	density = 0

	New()
		if(istype(src.loc, /turf/space))
			qdel(src)
			return

	attackby(obj/item/W, mob/user)
		if (!W) return
		if (!user) return
		if (istool(W, TOOL_CUTTING | TOOL_SAWING | TOOL_SCREWING | TOOL_SNIPPING | TOOL_WELDING)) qdel(src)
		..()

	proc/Life()

		var/count = 0
		while(count < 6)
			if (!src) return
			var/Vspread
			if (prob(50)) Vspread = locate(src.x + rand(-1,1),src.y,src.z)
			else Vspread = locate(src.x,src.y + rand(-1, 1),src.z)
			var/dogrowth = 1
			if (!istype(Vspread, /turf/simulated/floor)) dogrowth = 0
			for(var/obj/O in Vspread)
				if (istype(O, /obj/window) || istype(O, /obj/forcefield) || istype(O, /obj/blob) || istype(O, /obj/spacevine) || istype(O, /obj/alien/weeds)) dogrowth = 0
				if (istype(O, /obj/machinery/door/))
					if(!O:panel_open && prob(70))
						O:open()
						O:operating = -1
					else dogrowth = 0
			if (dogrowth == 1)
				var/obj/alien/weeds/B = new /obj/alien/weeds(Vspread)
				SPAWN(5 SECONDS)
					if(B)
						B.Life()
			count++
			sleep(5 SECONDS)

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					qdel(src)
					return
			if(3)
				if (prob(5))
					qdel(src)
					return
			else
		return

/*
/obj/alien/weeds/burn(fi_amount)
	if (fi_amount > 18000)
		SPAWN( 0 )
			qdel(src)
			return
		return 0
	return 1
*/
