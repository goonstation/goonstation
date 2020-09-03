//Nanomachines!

/datum/ailment/disease/robotic_transformation
	name = "Robotic Transformation"
	scantype = "Nano-Infection"
	max_stages = 5
	spread = "Non-Contagious"
	cure = "Electric Shock"
	associated_reagent = "nanites"
	affected_species = list("Human","Monkey")

/datum/ailment/disease/robotic_transformation/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	switch(D.stage)
		if(2)
			if (prob(8))
				boutput(affected_mob, "Your joints feel stiff.")
				random_brute_damage(affected_mob, 1)
			if (prob(9))
				boutput(affected_mob, "<span class='alert'>Beep...boop..</span>")
			if (prob(9))
				boutput(affected_mob, "<span class='alert'>Bop...beeep...</span>")
		if(3)
			if (prob(8))
				boutput(affected_mob, "<span class='alert'>Your joints feel very stiff.</span>")
				random_brute_damage(affected_mob, 5)
			if (prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			if (prob(10))
				boutput(affected_mob, "Your skin feels loose.")
				random_brute_damage(affected_mob, 5)
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>You feel a stabbing pain in your head.</span>")
				affected_mob.changeStatus("paralysis", 40)
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>You can feel something move...inside.</span>")
		if(4)
			if (prob(10))
				boutput(affected_mob, "<span class='alert'>Your skin feels very loose.</span>")
				random_brute_damage(affected_mob, 8)
			if (prob(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."))
			if (prob(8))
				boutput(affected_mob, "<span class='alert'>You can feel... something...inside you.</span>")
		if(5)
			boutput(affected_mob, "<span class='alert'>Your skin feels as if it's about to burst off...</span>")
			affected_mob.take_toxin_damage(10)
			if(prob(40)) //So everyone can feel like robot Seth Brundle

				var/bdna = null // For forensics (Convair880).
				var/btype = null
				if (affected_mob.bioHolder.Uid && affected_mob.bioHolder.bloodType)
					bdna = affected_mob.bioHolder.Uid
					btype = affected_mob.bioHolder.bloodType

				var/turf/T = get_turf(affected_mob)

				if (ismonkey(affected_mob) || jobban_isbanned(affected_mob, "Cyborg") || isvirtual(affected_mob))
					//affected_mob.ghostize()
					var/robopath = pick(/obj/machinery/bot/guardbot,/obj/machinery/bot/secbot,/obj/machinery/bot/medbot,/obj/machinery/bot/firebot,/obj/machinery/bot/cleanbot,/obj/machinery/bot/floorbot)
					var/obj/machinery/bot/X = new robopath (T)
					X.name = affected_mob.real_name //heh
					affected_mob.gib()
					qdel(affected_mob)
				else if (ishuman(affected_mob))
					gibs(T, null, null, bdna, btype)
					affected_mob:Robotize_MK2(1)

// Looks identical to the evil one. Hope you trust the doctor who shoved this in you!
/datum/ailment/disease/good_robotic_transformation
	name = "Robotic Transformation"
	scantype = "Nano-Infection"
	max_stages = 5
	spread = "Non-Contagious"
	cure = "Electric Shock"
	associated_reagent = "goodnanites"
	affected_species = list("Human")

/datum/ailment/disease/good_robotic_transformation/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	switch(D.stage)
		if(2)
			if (prob(8))
				boutput(affected_mob, "Your joints feel stiff.")
			if (prob(9))
				boutput(affected_mob, "<span class='alert'>Beep...boop..</span>")
			if (prob(9))
				boutput(affected_mob, "<span class='alert'>Bop...beeep...</span>")
		if(3)
			if (prob(8))
				boutput(affected_mob, "<span class='alert'>Your joints feel very stiff.</span>")
			if (prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			if (prob(10))
				boutput(affected_mob, "Your skin feels loose.")
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>You feel a stabbing pain in your abdomen.</span>")
				affected_mob.changeStatus("paralysis", 40)
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>You can feel something move...inside.</span>")
		if(4)
			if (prob(10))
				boutput(affected_mob, "<span class='alert'>Your insides twist and squirm!</span>")
			if (prob(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "Oh god I can feel it moving inside me", "The pain!"))
			if (prob(8))
				boutput(affected_mob, "<span class='alert'>You can feel... something...inside you.</span>")
		if(5)
			boutput(affected_mob, "<span class='alert'>It feels like something is stabbing you!</span>")
			if(prob(40))
				var/list/possible_replacements = list("heart", "left_lung","right_lung","left_kidney","right_kidney",
					"liver","spleen","pancreas","stomach","intestines","appendix","butt","r_leg","l_leg","r_arm","l_arm")

				var/replacing_organ = pick(possible_replacements)
				DEBUG_MESSAGE("Trying to replace [replacing_organ].")
				// @TODO im pretty sure this can be done in a better way, perhaps with an assoc list
				// of "organ", "type to replace with", "message to use"
				// rather than, uh. this. yeah.
				// also maybe visible_message for horking up your organs and it being gross as hell
				var/mob/living/carbon/human/H
				if(ishuman(affected_mob))
					H = affected_mob
				switch(replacing_organ)
					if("heart")
						if(istype(affected_mob.organHolder.get_organ("heart"),/obj/item/organ/heart/cyber))
							return
						else
							var/obj/item/organ/heart/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("heart")
							affected_mob.organHolder.receive_organ(new_organ,"heart")
							boutput(affected_mob, "<span class='alert'>Your heart is painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("left_lung")
						if(istype(affected_mob.organHolder.get_organ("left_lung"),/obj/item/organ/lung/cyber))
							return
						else
							var/obj/item/organ/lung/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("left_lung")
							affected_mob.organHolder.receive_organ(new_organ,"left_lung")
							boutput(affected_mob, "<span class='alert'>One of your lungs is painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("right_lung")
						if(istype(affected_mob.organHolder.get_organ("right_lung"),/obj/item/organ/lung/cyber))
							return
						else
							var/obj/item/organ/lung/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("right_lung")
							affected_mob.organHolder.receive_organ(new_organ,"right_lung")
							boutput(affected_mob, "<span class='alert'>One of your lungs is painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("left_kidney")
						if(istype(affected_mob.organHolder.get_organ("left_kidney"),/obj/item/organ/kidney/cyber))
							return
						else
							var/obj/item/organ/kidney/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("left_kidney")
							affected_mob.organHolder.receive_organ(new_organ,"left_kidney")
							boutput(affected_mob, "<span class='alert'>One of your kidneys is painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("right_kidney")
						if(istype(affected_mob.organHolder.get_organ("right_kidney"),/obj/item/organ/kidney/cyber))
							return
						else
							var/obj/item/organ/kidney/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("right_kidney")
							affected_mob.organHolder.receive_organ(new_organ,"right_kidney")
							boutput(affected_mob, "<span class='alert'>One of your kidneys is painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("liver")
						if(istype(affected_mob.organHolder.get_organ("liver"),/obj/item/organ/liver/cyber))
							return
						else
							var/obj/item/organ/liver/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("liver")
							affected_mob.organHolder.receive_organ(new_organ,"liver")
							boutput(affected_mob, "<span class='alert'>Your liver is painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("spleen")
						if(istype(affected_mob.organHolder.get_organ("spleen"),/obj/item/organ/spleen/cyber))
							return
						else
							var/obj/item/organ/spleen/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("spleen")
							affected_mob.organHolder.receive_organ(new_organ,"spleen")
							boutput(affected_mob, "<span class='alert'>Your spleen is painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("stomach")
						if(istype(affected_mob.organHolder.get_organ("stomach"),/obj/item/organ/stomach/cyber))
							return
						else
							var/obj/item/organ/stomach/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("stomach")
							affected_mob.organHolder.receive_organ(new_organ,"stomach")
							boutput(affected_mob, "<span class='alert'>Your stomach is painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("intestines")
						if(istype(affected_mob.organHolder.get_organ("intestines"),/obj/item/organ/intestines/cyber))
							return
						else
							var/obj/item/organ/intestines/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("intestines")
							affected_mob.organHolder.receive_organ(new_organ,"intestines")
							boutput(affected_mob, "<span class='alert'>Your intestines are painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("appendix")
						if(istype(affected_mob.organHolder.get_organ("appendix"),/obj/item/organ/appendix/cyber))
							return
						else
							var/obj/item/organ/appendix/cyber/new_organ = new
							affected_mob.organHolder.drop_organ("appendix")
							affected_mob.organHolder.receive_organ(new_organ,"appendix")
							boutput(affected_mob, "<span class='alert'>Your appendix is painfully pushed out of your body!</span>")
							affected_mob.emote("scream")
					if("butt") // lol butts
						if(istype(affected_mob.organHolder.get_organ("butt"),/obj/item/clothing/head/butt/cyberbutt))
							return
						else
							var/obj/item/clothing/head/butt/cyberbutt/new_organ = new
							affected_mob.organHolder.receive_organ(new_organ,"butt")
							boutput(affected_mob, "<span class='alert'>You butt fall off!</span>")
							affected_mob.emote("scream")
					if("r_leg")
						if(istype(H?.limbs.get_limb("r_leg"),/obj/item/parts/robot_parts))
							return
						else
							H?.limbs.r_leg.sever()
							H?.limbs.replace_with("r_leg", /obj/item/parts/robot_parts/leg/right, null , 0)
							boutput(affected_mob, "<span class='alert'>Your right leg falls off as a robotic version grows in its place!</span>")
							affected_mob.emote("scream")
					if("l_leg")
						if(istype(H?.limbs.get_limb("l_leg"),/obj/item/parts/robot_parts))
							return
						else
							H?.limbs.l_leg.sever()
							H?.limbs.replace_with("l_leg", /obj/item/parts/robot_parts/leg/left, null , 0)
							boutput(affected_mob, "<span class='alert'>Your left leg falls off as a robotic version grows in its place!</span>")
							affected_mob.emote("scream")
					if("r_arm")
						if(istype(H?.limbs.get_limb("r_arm"),/obj/item/parts/robot_parts))
							return
						else
							H?.limbs.r_arm.sever()
							H?.limbs.replace_with("r_arm", /obj/item/parts/robot_parts/arm/right, null , 0)
							boutput(affected_mob, "<span class='alert'>Your right arm falls off as a robotic version grows in its place!</span>")
							affected_mob.emote("scream")
					if("l_arm")
						if(istype(H?.limbs.get_limb("l_arm"),/obj/item/parts/robot_parts))
							return
						else
							H?.limbs.l_arm.sever()
							H?.limbs.replace_with("l_arm", /obj/item/parts/robot_parts/arm/left, null , 0)
							boutput(affected_mob, "<span class='alert'>Your left_arm falls off as a robotic version grows in its place!</span>")
							affected_mob.emote("scream")
				if(prob(50))
					affected_mob.cure_disease(D)
				else
					D.stage = 1 // Half the time it restarts on a new organ. Nifty!
