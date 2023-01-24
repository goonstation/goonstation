/*/datum/ailment/disease/flatline
	name = "Cardiac Arrest"
	scantype = "Medical Emergency"
	max_stages = 1
	spread = "The patient's heart has stopped."
	cure = "Electric Shock"
	affected_species = list("Human","Monkey")
	reagentcure = list("atropine" = list(1,1), // atropine is not recommended for use in treating cardiac arrest anymore but SHRUG
	"epinephrine" = list(1,10)) // epi is recommended though
	var/robo_restart = 0

/datum/ailment/disease/flatline/stage_act(var/mob/living/affected_mob, var/datum/ailment/D, mult)
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
		else if (H.organHolder.heart && H.organHolder.heart.robotic && !H.organHolder.heart.broken && !src.robo_restart)
			boutput(H, "<span class='alert'>Your cyberheart detects a cardiac event and attempts to return to its normal rhythm!</span>")

			if (prob(20) && H.organHolder.heart.emagged)
				H.cure_disease(D)
				src.robo_restart = 1
				if (H.organHolder.heart.emagged)
					SPAWN(20 SECONDS)
						src.robo_restart = 0
				else
					SPAWN(30 SECONDS)
						src.robo_restart = 0
				SPAWN(3 SECONDS)
					boutput(H, "<span class='alert'>Your cyberheart returns to its normal rhythm!</span>")
					return

			else if (prob(10))
				H.cure_disease(D)
				src.robo_restart = 1
				if (H.organHolder.heart.emagged)
					SPAWN(20 SECONDS)
						src.robo_restart = 0
				else
					SPAWN(30 SECONDS)
						src.robo_restart = 0
				SPAWN(3 SECONDS)
					boutput(H, "<span class='alert'>Your cyberheart returns to its normal rhythm!</span>")
					return

			else
				src.robo_restart = 1
				if (H.organHolder.heart.emagged)
					SPAWN(20 SECONDS)
						src.robo_restart = 0
				else
					SPAWN(30 SECONDS)
						src.robo_restart = 0
				SPAWN(3 SECONDS)
					boutput(H, "<span class='alert'>Your cyberheart fails to return to its normal rhythm!</span>")
		else
			if (H.get_oxygen_deprivation())
				H.take_brain_damage(3)
			else if (prob(10))
				H.take_brain_damage(1)

		H.weakened = max(H.weakened, 5)
		H.losebreath+=20
		H.take_oxygen_deprivation(20)
*/
