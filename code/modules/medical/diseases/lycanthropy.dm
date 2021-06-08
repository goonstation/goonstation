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

/datum/ailment/disease/lycanthropy/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D)
	if (..())
		return
	if (ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if (!istype(H.mutantrace, /datum/mutantrace/werewolf))
			switch (D.stage)
				if (2)
					if (prob(1))
						H.emote("sneeze")

				if (3)
					if (prob(5))
						H.emote("cough")
					else if (prob(5))
						H.emote("gasp")
					if (prob(10))
						boutput(H, "<span class='alert'>You're starting to feel weak.</span>")

				if (4)
					if (prob(10))
						H.emote("cough")
					if (prob(5) && !H.getStatusDuration("weakened") && !H.getStatusDuration("paralysis"))
						boutput(H, "<span class='alert'>You suddenly feel very weak.</span>")
						H.emote("collapse")

				if (5)
					boutput(H, "<span class='alert'>Your body feels as if it's on fire!</span>")
					if (prob(50) && src.triggered_transformation == 0)
						H.visible_message("<span class='alert'><B>[H] starts having a seizure!</B></span>")
						H.changeStatus("weakened", 15 SECONDS)
						H.stuttering = max(10, H.stuttering)
						H.make_jittery(1000)
						src.triggered_transformation = 1

						SPAWN_DBG (rand(100, 300))
							if (H && D)
								H.werewolf_transform() // Less code duplication and stuff. See werewolf.dm (Convair880).
								D.stage_prob = 0
								D.stage = 1
							src.triggered_transformation = 0 // Necessary. Disease datums seem to be pooled or something, dunno.

						return
				else
					return
