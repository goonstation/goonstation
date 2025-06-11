/datum/ailment/malady/flatline
	name = "Cardiac Arrest"
	scantype = "Medical Emergency"
	info = "The patient's heart has stopped."
	max_stages = 1
	cure_flags = CURE_ELEC_SHOCK
	affected_species = list("Human","Monkey")
	reagentcure = list("atropine" = 0.01, // atropine is not recommended for use in treating cardiac arrest anymore but SHRUG
	"epinephrine" = 0.1) // epi is recommended though

/datum/ailment/malady/flatline/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
	if (..())
		return
	if (ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if (!H.organHolder)
			H.cure_disease(D)
			return
		if (!H.organHolder.heart)
			H.cure_disease(D)
			return
		else if (H.organHolder.heart && H.organHolder.heart.robotic && !H.organHolder.heart.broken && !D.robo_restart)
			boutput(H, SPAN_ALERT("Your cyberheart detects a cardiac event and attempts to return to its normal rhythm!"))

			if (probmult(20) && H.organHolder.heart.emagged)
				H.cure_disease(D)
				D.robo_restart = 1
				if (H.organHolder.heart.emagged)
					SPAWN(20 SECONDS)
						D.robo_restart = 0
				else
					SPAWN(30 SECONDS)
						D.robo_restart = 0
				SPAWN(3 SECONDS)
					boutput(H, SPAN_ALERT("Your cyberheart returns to its normal rhythm!"))
					return

			else if (probmult(10))
				H.cure_disease(D)
				D.robo_restart = 1
				if (H.organHolder.heart.emagged)
					SPAWN(20 SECONDS)
						D?.robo_restart = 0
				else
					SPAWN(30 SECONDS)
						D?.robo_restart = 0
				SPAWN(3 SECONDS)
					boutput(H, SPAN_ALERT("Your cyberheart returns to its normal rhythm!"))
					return

			else
				D.robo_restart = 1
				if (H.organHolder.heart.emagged)
					SPAWN(20 SECONDS)
						D?.robo_restart = 0
				else
					SPAWN(30 SECONDS)
						D?.robo_restart = 0
				SPAWN(3 SECONDS)
					boutput(H, SPAN_ALERT("Your cyberheart fails to return to its normal rhythm!"))
		else
			if (H.get_oxygen_deprivation())
				H.take_brain_damage(3 * mult)
			else if (prob(10))
				H.take_brain_damage(1 * mult)

		H.changeStatus("knockdown", 6 * mult SECONDS)
		H.losebreath+=20 * mult
		H.take_oxygen_deprivation(20 * mult)
