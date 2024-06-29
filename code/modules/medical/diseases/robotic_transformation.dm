//Nanomachines!

/datum/ailment/disease/robotic_transformation
	name = "Robotic Transformation"
	scantype = "Nano-Infection"
	max_stages = 5
	spread = "Non-Contagious"
	cure_flags = CURE_ELEC_SHOCK
	associated_reagent = "nanites"
	affected_species = list("Human","Monkey")

/datum/ailment/disease/robotic_transformation/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!ishuman(affected_mob))
		affected_mob.cure_disease(D)
		return

	switch(D.stage)
		if(2)
			if (probmult(8))
				boutput(affected_mob, "Your joints feel stiff.")
				random_brute_damage(affected_mob, 1)
			if (probmult(9))
				boutput(affected_mob, SPAN_ALERT("Beep...boop.."))
			if (probmult(9))
				boutput(affected_mob, SPAN_ALERT("Bop...beeep..."))
		if(3)
			if (probmult(8))
				boutput(affected_mob, SPAN_ALERT("Your joints feel very stiff."))
				random_brute_damage(affected_mob, 5)
			if (probmult(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			if (probmult(10))
				boutput(affected_mob, "Your skin feels loose.")
				random_brute_damage(affected_mob, 5)
			if (probmult(4))
				boutput(affected_mob, SPAN_ALERT("You feel a stabbing pain in your head."))
				affected_mob.changeStatus("unconscious", 4 SECONDS)
			if (probmult(4))
				boutput(affected_mob, SPAN_ALERT("You can feel something move...inside."))
		if(4)
			if (probmult(10))
				boutput(affected_mob, SPAN_ALERT("Your skin feels very loose."))
				random_brute_damage(affected_mob, 8)
			if (probmult(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."))
			if (probmult(8))
				boutput(affected_mob, SPAN_ALERT("You can feel... something...inside you."))
		if(5)
			boutput(affected_mob, SPAN_ALERT("Your skin feels as if it's about to burst off..."))
			affected_mob.take_toxin_damage(10 * mult)
			if(probmult(40)) //So everyone can feel like robot Seth Brundle

				var/bdna = null // For forensics (Convair880).
				var/btype = null
				if (affected_mob.bioHolder.Uid && affected_mob.bioHolder.bloodType)
					bdna = affected_mob.bioHolder.Uid
					btype = affected_mob.bioHolder.bloodType

				var/turf/T = get_turf(affected_mob)

				if (isnpcmonkey(affected_mob) || jobban_isbanned(affected_mob, "Cyborg") || isvirtual(affected_mob))
					//affected_mob.ghostize()
					var/robopath = pick(/obj/machinery/bot/guardbot,/obj/machinery/bot/secbot,/obj/machinery/bot/medbot,/obj/machinery/bot/firebot,/obj/machinery/bot/cleanbot,/obj/machinery/bot/floorbot)
					var/obj/machinery/bot/X = new robopath (T)
					X.name = affected_mob.real_name //heh
					affected_mob.gib()
					qdel(affected_mob)
				else if (ishuman(affected_mob))
					logTheThing(LOG_COMBAT, affected_mob, "was transformed into a cyborg by the disease [name] at [log_loc(affected_mob)].")
					gibs(T, null, bdna, btype)
					affected_mob:Robotize_MK2(1)

// Looks identical to the evil one. Hope you trust the doctor who shoved this in you!
/datum/ailment/disease/good_robotic_transformation
	name = "Robotic Transformation"
	scantype = "Nano-Infection"
	max_stages = 5
	spread = "Non-Contagious"
	cure_flags = CURE_ELEC_SHOCK
	associated_reagent = "goodnanites"
	affected_species = list("Human")

/datum/ailment/disease/good_robotic_transformation/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!ishuman(affected_mob))
		affected_mob.cure_disease(D)
		return

	switch(D.stage)
		if(2)
			if (probmult(8))
				boutput(affected_mob, "Your joints feel stiff.")
			if (probmult(9))
				boutput(affected_mob, SPAN_ALERT("Beep...boop.."))
			if (probmult(9))
				boutput(affected_mob, SPAN_ALERT("Bop...beeep..."))
		if(3)
			if (probmult(8))
				boutput(affected_mob, SPAN_ALERT("Your joints feel very stiff."))
			if (probmult(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			if (probmult(10))
				boutput(affected_mob, "Your skin feels loose.")
			if (probmult(4))
				boutput(affected_mob, SPAN_ALERT("You feel a stabbing pain in your abdomen."))
				affected_mob.changeStatus("unconscious", 4 SECONDS)
			if (probmult(4))
				boutput(affected_mob, SPAN_ALERT("You can feel something move...inside."))
		if(4)
			if (probmult(10))
				boutput(affected_mob, SPAN_ALERT("Your insides twist and squirm!"))
			if (probmult(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "Oh god I can feel it moving inside me", "The pain!"))
			if (probmult(8))
				boutput(affected_mob, SPAN_ALERT("You can feel... something...inside you."))
		if(5)
			boutput(affected_mob, SPAN_ALERT("It feels like something is stabbing you!"))
			if(probmult(40))
				var/list/possible_replacements = list("heart", "left_lung","right_lung","left_kidney","right_kidney",
					"liver","spleen","pancreas","stomach","intestines","appendix","butt","r_leg","l_leg","r_arm","l_arm")

				// @TODO im pretty sure this can be done in a better way, perhaps with an assoc list
				// of "organ", "type to replace with", "message to use"
				// rather than, uh. this. yeah.
				// also maybe visible_message for horking up your organs and it being gross as hell
				var/mob/living/carbon/human/H
				var/replacing_organ = null
				if(ishuman(affected_mob))
					H = affected_mob
				for(var/i in 1 to 10)
					replacing_organ = pick(possible_replacements)
					DEBUG_MESSAGE("Trying to replace [replacing_organ].")
					var/do_replace = 0
					if(replacing_organ in list("heart", "left_lung","right_lung","left_kidney","right_kidney","liver","spleen","pancreas","stomach","intestines","appendix"))
						var/obj/item/organ/O = affected_mob.organHolder.get_organ(replacing_organ)
						do_replace = (O ? ((O.broken || O.get_damage() >= O.fail_damage || i > 6) && !O.robotic) : 1)
					else if (replacing_organ == "butt")
						var/obj/item/clothing/head/butt/cyberbutt/O = affected_mob.organHolder.get_organ(replacing_organ)
						do_replace = (O ? (!istype(O) && i > 6) : 1)
					else if (replacing_organ in list("r_leg","l_leg","r_arm","l_arm"))
						var/obj/item/parts/robot_parts/O = H?.limbs.get_limb(replacing_organ)
						do_replace = (H && (O ? (!istype(O) && i > 6) : 1))

					if(do_replace) break

				if(!replacing_organ)
					return

				switch(replacing_organ)
					if("heart")
						var/obj/item/organ/heart/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("heart")
						affected_mob.organHolder.receive_organ(new_organ,"heart")
						boutput(affected_mob, SPAN_ALERT("Your heart is painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("left_lung")
						var/obj/item/organ/lung/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("left_lung")
						affected_mob.organHolder.receive_organ(new_organ,"left_lung")
						boutput(affected_mob, SPAN_ALERT("One of your lungs is painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("right_lung")
						var/obj/item/organ/lung/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("right_lung")
						affected_mob.organHolder.receive_organ(new_organ,"right_lung")
						boutput(affected_mob, SPAN_ALERT("One of your lungs is painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("left_kidney")
						var/obj/item/organ/kidney/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("left_kidney")
						affected_mob.organHolder.receive_organ(new_organ,"left_kidney")
						boutput(affected_mob, SPAN_ALERT("One of your kidneys is painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("right_kidney")
						var/obj/item/organ/kidney/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("right_kidney")
						affected_mob.organHolder.receive_organ(new_organ,"right_kidney")
						boutput(affected_mob, SPAN_ALERT("One of your kidneys is painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("liver")
						var/obj/item/organ/liver/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("liver")
						affected_mob.organHolder.receive_organ(new_organ,"liver")
						boutput(affected_mob, SPAN_ALERT("Your liver is painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("spleen")
						var/obj/item/organ/spleen/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("spleen")
						affected_mob.organHolder.receive_organ(new_organ,"spleen")
						boutput(affected_mob, SPAN_ALERT("Your spleen is painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("stomach")
						var/obj/item/organ/stomach/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("stomach")
						affected_mob.organHolder.receive_organ(new_organ,"stomach")
						boutput(affected_mob, SPAN_ALERT("Your stomach is painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("intestines")
						var/obj/item/organ/intestines/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("intestines")
						affected_mob.organHolder.receive_organ(new_organ,"intestines")
						boutput(affected_mob, SPAN_ALERT("Your intestines are painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("appendix")
						var/obj/item/organ/appendix/cyber/new_organ = new
						affected_mob.organHolder.drop_organ("appendix")
						affected_mob.organHolder.receive_organ(new_organ,"appendix")
						boutput(affected_mob, SPAN_ALERT("Your appendix is painfully pushed out of your body!"))
						affected_mob.emote("scream")
					if("butt") // lol butts
						var/obj/item/clothing/head/butt/cyberbutt/new_organ = new
						affected_mob.organHolder.drop_organ("butt")
						affected_mob.organHolder.receive_organ(new_organ,"butt")
						boutput(affected_mob, SPAN_ALERT("You butt fall off!"))
						affected_mob.emote("scream")
					if("r_leg")
						H?.limbs.r_leg.sever()
						H?.limbs.replace_with("r_leg", /obj/item/parts/robot_parts/leg/right/standard, null , 0)
						boutput(affected_mob, SPAN_ALERT("Your right leg falls off as a robotic version grows in its place!"))
						affected_mob.emote("scream")
					if("l_leg")
						H?.limbs.l_leg.sever()
						H?.limbs.replace_with("l_leg", /obj/item/parts/robot_parts/leg/left/standard, null , 0)
						boutput(affected_mob, SPAN_ALERT("Your left leg falls off as a robotic version grows in its place!"))
						affected_mob.emote("scream")
					if("r_arm")
						H?.limbs.r_arm.sever()
						H?.limbs.replace_with("r_arm", /obj/item/parts/robot_parts/arm/right/standard, null , 0)
						boutput(affected_mob, SPAN_ALERT("Your right arm falls off as a robotic version grows in its place!"))
						affected_mob.emote("scream")
					if("l_arm")
						H?.limbs.l_arm.sever()
						H?.limbs.replace_with("l_arm", /obj/item/parts/robot_parts/arm/left/standard, null , 0)
						boutput(affected_mob, SPAN_ALERT("Your left_arm falls off as a robotic version grows in its place!"))
						affected_mob.emote("scream")

				if(prob(50))
					affected_mob.cure_disease(D)
				else
					D.stage = 1 // Half the time it restarts on a new organ. Nifty!
