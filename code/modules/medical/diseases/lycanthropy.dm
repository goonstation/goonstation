/datum/ailment/disease/lycanthropy
	name = "Lycanthropy"
	print_name = "Unidentified virus"
	max_stages = 5
	spread = "Saliva"
	cure = "Incurable"
	reagentcure = list("silver_nitrate")
	recureprob = 10
	affected_species = list("Human")
	var/triggered_transformation = 0

/datum/ailment/disease/lycanthropy/stage_act(var/mob/living/affected_mob,  var/datum/ailment_data/D, mult)
	if (..())
		return
	if (ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		switch (D.stage)
			if (1)
				if(probmult(3))
					D.stage_prob = initial(D.stage_prob)
			if (2)
				if (probmult(1))
					H.emote("sneeze")

			if (3)
				if (probmult(5))
					H.emote("cough")
				else if (probmult(5))
					H.emote("gasp")
				if (probmult(10))
					boutput(H, "<span class='alert'>You're starting to feel weak.</span>")

			if (4)
				if (probmult(10))
					H.emote("cough")
				if (probmult(5) && !H.getStatusDuration("weakened") && !H.getStatusDuration("paralysis"))
					boutput(H, "<span class='alert'>You suddenly feel very weak.</span>")
					H.emote("collapse")

			if (5)
				boutput(H, "<span class='alert'>Your body feels as if it's on fire!</span>")
				if (probmult(50) && src.triggered_transformation == 0)
					if (!istype(H.mutantrace, /datum/mutantrace/werewolf))
						H.visible_message("<span class='alert'><B>[H] starts having a seizure!</B></span>")
						H.changeStatus("weakened", 15 SECONDS)
						H.stuttering = max(10, H.stuttering)
						H.make_jittery(1000)
					else
						boutput(H, "<span class='alert'>You feel a wave of lethargy wash over you!</span>")
						H.changeStatus("drowsy", 30 SECONDS)
					src.triggered_transformation = 1

					SPAWN(rand(100, 300))
						if (H && D)
							if (!istype(H.mutantrace, /datum/mutantrace/werewolf))
								D.stage_prob = 0
							D.stage = 1
							H.werewolf_transform() // Less code duplication and stuff. See werewolf.dm (Convair880).
						src.triggered_transformation = 0 // Necessary. Disease datums seem to be pooled or something, dunno.

					return


/datum/ailment/disease/lycanthropy/on_remove(mob/living/affected_mob, datum/ailment_data/D)
	. = ..()
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if (istype(H.mutantrace, /datum/mutantrace/werewolf))
			H.werewolf_transform()
