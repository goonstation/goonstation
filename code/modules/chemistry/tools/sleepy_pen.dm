/obj/item/pen/sleepypen
	flags = FPRINT | ONBELT | TABLEPASS | NOSPLASH | OPENCONTAINER
	hide_attack = TRUE
	move_triggered = TRUE
	can_dip = FALSE

	New()
		..()
		if (prob(50))
			desc = "The humble National Notary 'Arundel' model pen. It's a normal black ink pen. With a sharp point."
		else
			name = "fancy pen"
			desc = "One of those really fancy National Notary pens. Looks like the 'Grand Duchess' model with the marblewood handle. And a sharp point."
			icon_state = "pen_fancy"
			item_state = "pen_fancy"
			font_color = "blue"
			font = "'Dancing Script', cursive"
			webfont = "Dancing Script"
			uses_handwriting = TRUE
		src.create_reagents(100)
		reagents.add_reagent("ketamine", 100)

	attack(mob/M, mob/user)
		if (!ismob(M))
			return
		if (src.reagents.total_volume)
			if (!M.reagents || (M.reagents && M.reagents.is_full()))
				user.show_text("[M] cannot absorb any chemicals.", "red")
				return

			boutput(user, "<span class='alert'>You stab [M] with the pen.</span>")
			logTheThing(LOG_COMBAT, user, "stabs [constructTarget(M,"combat")] with the sleepy pen [log_reagents(src)] at [log_loc(user)].")
			src.reagents.trans_to(M, 50)

		else
			user.show_text("The sleepy pen is empty.", "red")

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)
/obj/item/pen/sleepypen/discount
	name = "greasy pen"
	icon_state = "pen-greasy"
	desc = "Holy shit...that pen is fucking greasy."
	flags = FPRINT | ONBELT | TABLEPASS | NOSPLASH | OPENCONTAINER
	hide_attack = ATTACK_PARTIALLY_HIDDEN

	New()
		..()
		src.reagents.clear_reagents()
		src.reagents.maximum_volume = 30
		if (src.reagents)
			if (prob(33))
				src.reagents.add_reagent(pick("bathsalts", "catdrugs", "crank"), 10)
				src.reagents.add_reagent(pick("psilocybin", "sugar", "ethanol", "ants"), 7)
				src.reagents.add_reagent(pick("spiders", "vomit", "space_drugs", "mutagen"), 5)
			else
				src.reagents.add_reagent(pick("water", "krokodil", "methamphetamine"), 4)
				src.reagents.add_reagent(pick("LSD", "lsd_bee", "nicotine", "jenkem", "glitter"), 6)
				src.reagents.add_reagent(pick("radium", "porktonium", "bathsalts", "gvomit"), 2)

	attack(mob/M, mob/user)
		if (!ismob(M))
			return
		if (src.reagents.total_volume)
			if (!M.reagents || (M.reagents && M.reagents.is_full()))
				user.show_text("[M] cannot absorb any chemicals.", "red")
				return
			var/luck = pick(1,2,3)
			if(luck==1)
				boutput(user, "<span class='alert'>You stab [M == user ? "yourself" : "[M]"] with the correct end of this greasy sleepy pen[M == user ? ", gross!" : "."]</span>")
				logTheThing(LOG_COMBAT, user, "stabs [constructTarget(M,"combat")] with the discount sleepy pen [log_reagents(src)] at [log_loc(user)].")
				src.reagents.trans_to(M, 30)
			if(luck==2)
				if(src.reagents.total_volume)
					boutput(user, "<span class='alert'>You poke [M == user ? "yourself" : "[M]"] but the greasy pen leaks quite badly!</span>")
					logTheThing(LOG_COMBAT, user, "tries to stab [constructTarget(M,"combat")] with the discount sleepy pen with [log_reagents(src)] but fails at [log_loc(user)].")
					src.reagents.reaction(get_turf(src), TOUCH, min(30, src.reagents.total_volume))
					src.reagents.remove_any(30)
					if(user != M)
						M.show_text("<b>[user] poked you with their leaking pen! Urgh!</b>", "red")
				else
			if(luck==3)
				boutput(user, "<span class='alert'>You stab yourself with the pointy end of the greasy sleepy pen.")
				logTheThing(LOG_COMBAT, user, "tries to stab [constructTarget(M,"combat")] with the discount sleepy pen [log_reagents(src)] but uses it on themselves at [log_loc(user)].")
				src.reagents.trans_to(user, 30)

		else
			user.show_text("The sleepy pen is empty.", "red")
