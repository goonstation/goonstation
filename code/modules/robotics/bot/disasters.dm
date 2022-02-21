// migrated from disaster game mode

/obj/machinery/bot/secbot/emagged
	desc = "A tattered and rusted security bot, held together only by the will of some wretched elder god."
	health = 5
	emagged = 1
	auto_patrol = 1
	no_camera = 1
	var/blow_up = 1

	New()
		..()
		src.name = pick("Commissar Beepevich","The Beeper","Murderbot","Killtron","Lawmaker")
		SPAWN(1 MINUTE)
			if (src?.blow_up == 1)
				src.explode()
		return

/obj/machinery/bot/secbot/emagged/no_selfdestruct
	blow_up = 0

/obj/machinery/bot/medbot/mysterious/emagged
	emagged = 1
	desc = "An eldritch medibot from outside of time, crafted from a non-euclidean first-aid kit."
	no_camera = 1
	var/blow_up = 1

	New()
		..()
		src.pick_poison()
		src.name = pick("Herr Doktor","Heals McGee","Wild-Eye","Jack","Boston Strangler","Insanobot")
		SPAWN(1 MINUTE)
			if (src?.blow_up == 1)
				src.explode()
		return

/obj/machinery/bot/medbot/mysterious/emagged/no_selfdestruct
	blow_up = 0

/obj/machinery/bot/firebot/emagged
	emagged = 1
	desc = "A firebot, but all wrong.  Nothing seems to fit together properly."
	no_camera = 1
	var/blow_up = 1

	New()
		..()
		src.name = pick("Montag","Fire-Killer","Burns","Murdermaster","Guardbot","Axe Man")
		SPAWN(1 MINUTE)
			if (src?.blow_up == 1)
				src.explode()
		return

/obj/machinery/bot/firebot/emagged/no_selfdestruct
	blow_up = 0

/obj/machinery/bot/cleanbot/emagged
	emagged = 1
	desc = "A cleanbot straight from the depths of hell."
	no_camera = 1
	var/blow_up = 1

	New()
		..()
		src.name = pick("Mr. Clean","Slip-o-Matic","The Janitor","Port-a-Lube","Galoshes-be-Gone","Slipmeister")
		SPAWN(1 MINUTE)
			if (src?.blow_up == 1)
				src.explode()
		return

/obj/machinery/bot/cleanbot/emagged/no_selfdestruct
	blow_up = 0
