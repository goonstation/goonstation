/obj/fake_genetics_console
	name = "strange genetics console"
	desc = "This looks like an antiquated model of the genetics console back on station. You can't make heads or tails of this."
	icon = 'icons/obj/computer.dmi'
	icon_state = "scanner"
	density = TRUE
	anchored = TRUE

	attack_hand(mob/user)
		boutput(user, "<span class='notice'>You push a few random buttons but the machine appears unresponsive.</span>")
		return

	New()
		START_TRACKING
		. = ..()

	disposing()
		STOP_TRACKING
		. = ..()

/obj/fake_gene_scanner //Only the crazy geneticist knows how to use this thing
	name = "weird scanner"
	desc = "A rusty GeneTek scanner of a model you do not recognize."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner_0"
	density = TRUE
	anchored = TRUE
	var/flips_to_exit = 10 //Failsafe in case lock_and_gene hangs or something
	var/total_flips = 0

	New()
		START_TRACKING
		. = ..()

	attack_hand(mob/user)
		boutput(user, "<span class='notice'>You can't seem to be able to find the opening mechanism on this pod.</span>")
		return

	proc/lock_and_gene(var/mob/M)
		if (!M || !M.loc)
			return
		SPAWN(0)
			M.set_loc(src)
			src.icon_state = "scanner_1"
			playsound(src.loc, 'sound/machines/sleeper_close.ogg', 50, 1)
			sleep (2 SECONDS)
			if (!M.bioHolder)
				src.eject(M)
				src.visible_message("<span class='notice'>[src] automatically releases [M], unable to modify their genes.</span>")
			for (var/i in 1 to pick(6,8))
				if (M.loc != src)//The mob left somehow
					src.icon_state = "scanner_0"
					return
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				M.bioHolder.RandomEffect("either")
				var/random_duration = rand(1,3) SECONDS
				sleep (random_duration)
			src.eject(M)
			src.visible_message("<span class='notice'>[src] automatically releases [M].</span>")
			return

	disposing()
		for (var/mob/M in src)
			M.set_loc(src.loc)
		STOP_TRACKING
		. = ..()

	mob_flip_inside(mob/user)
		. = ..()
		src.total_flips++
		if (src.total_flips >= src.flips_to_exit)
			src.eject(user)
			src.visible_message("<span class='notice'>[src]'s lock moves out of the latch and releases [user].</span>")

	proc/eject(var/mob/M)
		M.set_loc(src.loc)
		playsound(src.loc, 'sound/machines/sleeper_open.ogg', 50, 1)
		src.icon_state = "scanner_0"
		src.total_flips = 0
