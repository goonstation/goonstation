/datum/ailment/disease/dnaspread
	name = "Space Rhinovirus"
	max_stages = 4
	spread = "Airborne"
	cure = "Antibiotics"
	curable = 0
	associated_reagent = "liquid dna"
	affected_species = list("Human")
	var/list/original_dna = list()
	var/transformed = 0

//
/datum/ailment/disease/dnaspread/stage_act()
	..()
	switch(stage)
		if(2, 3) //Pretend to be a cold and give time to spread.
			if(prob(8))
				affected_mob.emote("sneeze")
			if(prob(8))
				affected_mob.emote("cough")
			if(prob(1))
				boutput(affected_mob, "<span class='alert'>Your muscles ache.</span>")
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			if(prob(1))
				boutput(affected_mob, "<span class='alert'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.take_toxin_damage(2)
		if(4)
			if(!src.transformed)
				if ((!strain_data["name"]) || (!strain_data["UI"]) || (!strain_data["SE"]))
					affected_mob.ailments -= src
					return

				//Save original dna for when the disease is cured.
				src.original_dna["name"] = affected_mob.real_name
				src.original_dna["UI"] = affected_mob.dna.uni_identity
				src.original_dna["SE"] = affected_mob.dna.struc_enzymes

				boutput(affected_mob, "<span class='alert'>You don't feel like yourself..</span>")
				affected_mob.dna.uni_identity = strain_data["UI"]
				updateappearance(affected_mob, affected_mob.dna.uni_identity)
				affected_mob.dna.struc_enzymes = strain_data["SE"]
				affected_mob.real_name = strain_data["name"]
				domutcheck(affected_mob)

				src.transformed = 1
				src.carrier = 1 //Just chill out at stage 4

	return

/datum/ailment/disease/dnaspread/disposing()
	if (affected_mob)
		if ((original_dna["name"]) && (original_dna["UI"]) && (original_dna["SE"]))
			affected_mob.dna.uni_identity = original_dna["UI"]
			updateappearance(affected_mob, affected_mob.dna.uni_identity)
			affected_mob.dna.struc_enzymes = original_dna["SE"]
			affected_mob.real_name = original_dna["name"]

			boutput(affected_mob, "<span class='notice'>You feel more like yourself.</span>")
		affected_mob = null
	..()
