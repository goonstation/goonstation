/obj/item/pen/sleepypen
	desc = "It's a normal black ink pen with a sharp point."
	flags = FPRINT | ONBELT | TABLEPASS | NOSPLASH | OPENCONTAINER
	hide_attack = 1

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("ketamine", 100)
		return

	attack(mob/M, mob/user as mob)
		if (!ismob(M))
			return
		if (src.reagents.total_volume)
			if (!M.reagents || (M.reagents && M.reagents.is_full()))
				user.show_text("[M] cannot absorb any chemicals.", "red")
				return

			boutput(user, "<span class='alert'>You stab [M] with the pen.</span>")
			logTheThing("combat", user, M, "stabs %target% with the sleepy pen [log_reagents(src)] at [log_loc(user)].")
			src.reagents.trans_to(M, 50)

		else
			user.show_text("The sleepy pen is empty.", "red")
		return
