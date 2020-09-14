/obj/artifact/wish_granter
	name = "artifact wish granter"
	associated_datum = /datum/artifact/wish_granter

/datum/artifact/wish_granter
	associated_object = /obj/artifact/wish_granter
	rarity_class = 4
	validtypes = list("wizard","eldritch")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/cold)
	activ_text = "begins glowing with an enticing light!"
	deact_text = "falls dark and quiet."
	react_xray = list(666,666,666,11,"NONE")
	var/list/wish_granted = list()
	var/evil = 0

	New()
		..()
		if (prob(50))
			evil = 1

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!isliving(user))
			return
		if (user.key in wish_granted)
			boutput(user, "<b>[O]</b> is silent.")
			return
		boutput(user, "<b>[O]</b> resonates, \"<big>I SHALL GRANT YOU ONE WISH...</big>\"")

		var/list/wishes = list("I wish to become rich!","I wish for great power!")

		var/wish = input("Make a wish?","[O]") as null|anything in wishes
		if (!wish)
			boutput(user, "You say nothing.")
			boutput(user, "<b>[O]</b> resonates, \"<big>YOU MAY RETURN LATER...</big>\"")
			return

		wish_granted += user.key
		user.say(wish)
		sleep(0.5 SECONDS)
		boutput(user, "<b>[O]</b> resonates, \"<big>SO BE IT...</big>\"")
		playsound(O, "sound/musical_instruments/Gong_Rumbling.ogg", 40, 1)
		O.visible_message("<span class='alert'><b>[O]</b> begins to charge up...</span>")
		sleep(3 SECONDS)
		if (prob(2))
			evil = !evil

		if (evil)
			switch(wish)
				if("I wish to become rich!")
					O.visible_message("<span class='alert'><b>[O]</b> envelops [user] in a golden light!</span>")
					playsound(user, "sound/weapons/flashbang.ogg", 50, 1)
					for(var/mob/N in viewers(user, null))
						N.flash(3 SECONDS)
						if(N.client)
							shake_camera(N, 6, 16)
					user.desc = "A statue of someone very wealthy"
					user.become_gold_statue()

				if("I wish for great power!")
					O.visible_message("<span class='alert'><b>[O] discharges a massive bolt of electricity!</b></span>")
					playsound(user, "sound/effects/elec_bigzap.ogg", 40, 1)
					var/list/affected = DrawLine(O,user,/obj/line_obj/elec,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')
					for(var/obj/OB in affected)
						SPAWN_DBG(0.6 SECONDS)
							pool(OB)
					user.elecgib()
		else
			switch(wish)
				if("I wish to become rich!")
					O.visible_message("<span class='alert'>A ton of money falls out of thin air! Woah!</span>")
					for(var/turf/T in range(user,3))
						if (T.density)
							continue
						var/obj/item/spacecash/million/S = unpool(/obj/item/spacecash/million)
						S.setup(T)

				if("I wish for great power!")
					O.visible_message("<span class='alert'><b>[O]</b> envelops [user] in a brilliant light!</span>")
					if (ishuman(user))
						var/mob/living/carbon/human/H = user
						if (H.bioHolder)
							H.bioHolder.RandomEffect("good")
							H.bioHolder.RandomEffect("good")
							H.bioHolder.RandomEffect("good")
					else if (isrobot(user))
						var/mob/living/silicon/robot/R = user
						if (istype(R.cell))
							R.cell.genrate = 100
							R.cell.maxcharge = 1000000
							R.cell.charge = R.cell.maxcharge
