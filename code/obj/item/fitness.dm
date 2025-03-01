/obj/fitness/speedbag
	name = "punching bag"
	desc = "A punching bag. Can you get to speed level 4???"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "punchingbag"
	anchored = ANCHORED
	deconstruct_flags = DECON_SIMPLE
	layer = MOB_LAYER_BASE+1 // TODO LAYER

	attack_hand(mob/user)
		user.lastattacked = get_weakref(src)
		flick("[icon_state]2", src)
		playsound(src.loc, pick(sounds_punch + sounds_hit), 25, 1, -1)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.sims)
				H.sims.affectMotive("fun", 2)
		user.changeStatus("fitness_stam_regen", 100 SECONDS)

	wizard
		icon_state = "punchingbagwizard"
		desc = "It has a picture of a weird wizard on it."

	syndie
		icon_state = "punchingbagsyndie"
		desc = "It has a picture of a mean ol' syndicate on it."

	captain
		icon_state = "punchingbagcaptain"
		desc = "It has a picture of a dumb looking station captain on it."

	clown
		name = "clown bop bag"
		desc = "A bop bag in the shape of a goofy clown."
		icon_state = "bopbag"

		attack_hand(mob/user)
			user.lastattacked = get_weakref(src)
			flick("[icon_state]2", src)
			playsound(src.loc, pick(sounds_punch + sounds_hit), 25, 1, -1)
			playsound(src.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1, -1)
			user.changeStatus("fitness_stam_regen", 100 SECONDS)

/obj/fitness/stacklifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "fitnesslifter"
	density = 1
	anchored = ANCHORED
	deconstruct_flags = DECON_WRENCH
	var/in_use = 0

	MouseDrop_T(mob/M, mob/user)
		// Do not attempt to distantly pump iron.
		if (M != user || !can_reach(user, src) || !can_reach(user, M))
			return
		src.attack_hand(M)

	attack_hand(mob/user)
		if(in_use)
			boutput(user, SPAN_ALERT("Its already in use - wait a bit."))
			return
		else
			in_use = 1
			icon_state = "fitnesslifter2"
			APPLY_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "fitness_machine")
			user.transforming = 1
			user.set_dir(SOUTH)
			user.set_loc(src.loc)
			var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
			user.visible_message(SPAN_ALERT("<B>[user] is [bragmessage]!</B>"))
			var/lifts = 0
			while (lifts++ < 6)
				if (user.loc != src.loc)
					break
				sleep(0.3 SECONDS)
				user.pixel_y = -2
				sleep(0.3 SECONDS)
				user.pixel_y = -4
				sleep(0.3 SECONDS)
				playsound(user, 'sound/effects/spring.ogg', 60, TRUE)

			playsound(user, 'sound/machines/click.ogg', 60, TRUE)
			in_use = 0
			user.transforming = 0
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "fitness_machine")
			user.pixel_y = 0
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.sims)
					H.sims.affectMotive("fun", 4)
			var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
			icon_state = "fitnesslifter"
			user.changeStatus("fitness_stam_regen", 100 SECONDS)
			boutput(user, SPAN_NOTICE("[finishmessage]"))

/obj/fitness/weightlifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "fitnessweight"
	density = 1
	anchored = ANCHORED
	deconstruct_flags = DECON_WRENCH
	var/in_use = 0

	MouseDrop_T(mob/M, mob/user)
		// Do not attempt to distantly pump iron.
		if (M != user || !can_reach(user, src) || !can_reach(user, M))
			return
		src.attack_hand(M)

	attack_hand(mob/user)
		if(in_use)
			boutput(user, SPAN_ALERT("Its already in use - wait a bit."))
			return
		else if(HAS_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE))
			return
		else
			in_use = 1
			icon_state = "fitnessweight-c"
			user.transforming = 1
			APPLY_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "fitness_machine")
			user.set_dir(SOUTH)
			user.set_loc(src.loc)
			var/image/new_overlay = src.SafeGetOverlayImage("barbell", 'icons/obj/stationobjs.dmi', "fitnessweight-w", MOB_LAYER + 1)
			src.UpdateOverlays(new_overlay, "barbell")
			var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
			user.visible_message(SPAN_ALERT("<B>[user] is [bragmessage]!</B>"))
			var/reps = 0
			user.pixel_y = 5
			while (reps++ < 6)
				if (user.loc != src.loc)
					break

				for (var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
					sleep(0.3 SECONDS)
					user.pixel_y = (user.pixel_y == 3) ? 5 : 3

				playsound(user, 'sound/effects/spring.ogg', 60, TRUE)

			sleep(0.3 SECONDS)
			user.pixel_y = 2
			sleep(0.3 SECONDS)
			playsound(user, 'sound/machines/click.ogg', 60, TRUE)
			in_use = 0
			user.transforming = 0
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "fitness_machine")
			user.pixel_y = 0
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.sims)
					H.sims.affectMotive("fun", 4)
			var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
			icon_state = "fitnessweight"
			src.UpdateOverlays(null, "barbell")
			boutput(user, SPAN_NOTICE("[finishmessage]"))
			user.changeStatus("fitness_stam_max", 100 SECONDS)
