//Corrupt nanomachines!Azungar's technogimmick fantasy fetish.

/datum/ailment/disease/corrupt_robotic_transformation
	name = "????"
	scantype = "Nano-Infection"
	max_stages = 6
	spread = "Non-Contagious"
	cure = "Electric Shock"
	associated_reagent = "corruptnanites"
	affected_species = list("Human","Monkey")

/datum/ailment/disease/corrupt_robotic_transformation/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!ishuman(affected_mob))
		affected_mob.cure_disease(D)
		return

	switch(D.stage)
		if(2)
			if (probmult(8))
				boutput(affected_mob, "Your joints start to feel stiff.")
				random_brute_damage(affected_mob, 1)
			if (probmult(9))
				boutput(affected_mob, "<span class='alert'>What is happening to me..? </span>")
			if (probmult(9))
				boutput(affected_mob, "<span class='alert'>You feel really terrible..</span>")
		if(3)
			if (probmult(8))
				boutput(affected_mob,pick("<span class='alert'>Your joints start to feel very stiff.</span>", "<span class='alert'>Your joints feel extremely stiff.</span>"))
				random_brute_damage(affected_mob, 5)
			if (probmult(8))
				affected_mob.say(pick("Something.. is in my veins..", "I can feel them crawling in my veins..", "Oh god.. What is inside me..?"))
			if (probmult(10))
				boutput(affected_mob, "Your skin starts to feel loose.")
				random_brute_damage(affected_mob, 5)
			if (probmult(4))
				boutput(affected_mob, "<span class='alert'>You feel a stabbing pain in your head.</span>")
				affected_mob.changeStatus("paralysis", 4 SECONDS)
			if (probmult(4))
				boutput(affected_mob, "<span class='alert'>You can feel something move...inside.</span>")
		if(4)
			if (probmult(8))
				boutput(affected_mob,pick("<span class='alert'>Your joints start to feel very stiff.</span>", "<span class='alert'>Your joints feel extremely stiff.</span>"))
				random_brute_damage(affected_mob, 5)
			if (probmult(8))
				affected_mob.say(pick("Something.. is in my veins..", "I can feel them crawling in my veins..", "Oh god.. What is inside me..?"))
			if (probmult(10))
				boutput(affected_mob, "Your skin starts to feel loose.")
				random_brute_damage(affected_mob, 5)
			if (probmult(4))
				boutput(affected_mob, "<span class='alert'>You feel a stabbing pain in your head.</span>")
				affected_mob.changeStatus("paralysis", 4 SECONDS)
			if (probmult(4))
				boutput(affected_mob, "<span class='alert'>You can feel something move...inside.</span>")
		if(5)
			if (probmult(10))
				boutput(affected_mob, "<span class='alert'>Your skin feels very loose.</span>")
				random_brute_damage(affected_mob, 8)
			if (probmult(20))
				affected_mob.say(pick("Ohh god the p..ain...", "Just.. kill mee...", "kkkiiiill mmme..", "I wwwaaannntt tttoo dddiiieeee..."))
			if (probmult(8))
				boutput(affected_mob, "<span class='alert'>You can feel... something...inside you.</span>")
		if(6)
			boutput(affected_mob, "<span class='alert'>Your skin feels as if it's about to burst off...</span>")
			affected_mob.take_toxin_damage(10 * mult)
			if(probmult(35)) //So everyone can feel like robot Seth Brundle

				var/bdna = null // For forensics (Convair880).
				var/btype = null
				if (affected_mob.bioHolder.Uid && affected_mob.bioHolder.bloodType)
					bdna = affected_mob.bioHolder.Uid
					btype = affected_mob.bioHolder.bloodType

				var/turf/T = get_turf(affected_mob)
				gibs(T, null, null, bdna, btype)

				if (isnpcmonkey(affected_mob))
					affected_mob.ghostize()
					var/robopath = pick(/obj/machinery/bot/guardbot,/obj/machinery/bot/secbot,/obj/machinery/bot/medbot,/obj/machinery/bot/firebot,/obj/machinery/bot/cleanbot,/obj/machinery/bot/floorbot)
					new robopath (T)
					qdel(affected_mob)
				else if (ishuman(affected_mob))
					affected_mob:Monsterize(1)
