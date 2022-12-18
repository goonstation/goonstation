//The vortex appears, sends out some manner of vile thing, and fades away.
//Or sometimes it just blows up.

/obj/vortex
	name = "vortex"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	desc = "I wonder what this is."
	anchored = 1

	New()
		..()
		SPAWN(1 SECOND)
			if(prob(25))
				elecflash(src,power=3)

			var/event_type = rand(1,5)
			switch(event_type)
				if(1, 2, 3)
					spawn_horror()
				/*
				if(2)
					if(isturf(src.loc))
						src.loc:hotspot_expose(700,125)

						explosion(src, src.loc, -1, -1, 2, 3)

					qdel(src)
					return
					*/

				if(4)
					src.visible_message("<span class='alert'><b>[src] explodes in a burst of intense light!</b></span>")
					for (var/mob/living/C in view(3,src))
						C.apply_flash(30, 1, 0, 0, 0, rand(0, 2))
					qdel(src)
					return

				/*if(5)
					src.visible_message("<span class='alert'><b>[src] gives off an electromagnetic burst!</b></span>","<span class='alert'>You hear a sharp buzzing.</span>")
					var/obj/item/old_grenade/emp/G = new /obj/item/old_grenade/emp(src.loc)
					G.invisibility = INVIS_ALWAYS
					G.prime()
					qdel(src)
					return*/

				if(5)
					qdel(src)


		return

	proc/spawn_horror()
		var/horror_path = null
		if(derelict_mode)
			horror_path = pick(/obj/critter/shade,
			/obj/critter/shade,
			/obj/critter/shade,
			/obj/critter/shade,
			/obj/critter/shade,
			/obj/critter/crunched,
			/obj/critter/crunched,
			/obj/critter/crunched,
			/obj/critter/bloodling,
			/obj/critter/ancient_thing,
			/obj/critter/ancient_thing,
			/obj/critter/ancient_repairbot/grumpy,
			/obj/critter/ancient_repairbot/grumpy,
			/obj/critter/ancient_repairbot/security,
			/obj/critter/ancient_repairbot/security,
			/obj/critter/gunbot/heavy,
			/obj/machinery/bot/medbot/terrifying,
			/obj/machinery/bot/medbot/terrifying)
			if(prob(3))
				horror_path = pick(/obj/critter/gunbot/drone/buzzdrone,/obj/critter/gunbot/drone/buzzdrone, /obj/critter/aberration)
			if (was_eaten && prob(15))
				horror_path = /obj/critter/blobman/meaty_martha
		else
			horror_path = pick(/obj/critter/killertomato, /obj/critter/spore, /obj/critter/zombie, /obj/critter/martian/warrior, /obj/machinery/bot/firebot/emagged, /obj/machinery/bot/secbot/emagged, /obj/machinery/bot/medbot/mysterious/emagged, /obj/machinery/bot/cleanbot/emagged)
		var/obj/horror = new horror_path(src.loc)
		src.visible_message("<span class='alert'><b>[horror] emerges from the [src]!</b></span>","<span class='alert'>You hear a sharp buzzing noise.</span>")
		SPAWN(20 SECONDS)
			qdel(src)

		return

