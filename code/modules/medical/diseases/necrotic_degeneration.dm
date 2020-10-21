/datum/ailment/disease/necrotic_degeneration
	name = "Necrotic Degeneration"
	max_stages = 5
	spread = "Non-Contagious"
	cure = "Healing Reagents"
	reagentcure = list("omnizine","cryoxadone","mannitol","penteticacid","styptic_powder")
	recureprob = 8
	associated_reagent = "necrovirus"
	affected_species = list("Human")
	var/zombie_mutantrace = /datum/mutantrace/zombie

/datum/ailment/disease/necrotic_degeneration/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	if (affected_mob.get_burn_damage() >= 80 && prob(60))
		affected_mob.cure_disease(D)
		return
	switch(D.stage)
		if(1)
			if (prob(5))
				affected_mob.emote(pick("shiver", "pale"))
		if(2)
			if (prob(8))
				boutput(affected_mob, "<span class='alert'>You notice a foul smell.</span>")
			if (prob(10))
				boutput(affected_mob, "<span class='alert'>You lose track of your thoughts.</span>")
				affected_mob.take_brain_damage(10)
			if (prob(4))
				boutput(affected_mob, "<span class='alert'>You pass out momentarily.</span>")
				affected_mob.changeStatus("paralysis", 40)
			if (prob(5))
				affected_mob.emote(pick("shiver","pale","drool"))

			//spaceacillin stalls the infection...
			var/amt = affected_mob.reagents?.get_reagent_amount("spaceacillin")
			if (amt)
				if (amt > 15)
					affected_mob.reagents?.remove_reagent("spaceacillin", 1)
				else
					affected_mob.reagents?.remove_reagent("spaceacillin", 0.4)
				D.stage--

		if(3)
			affected_mob.stuttering = 10
			if (prob(10))
				affected_mob.emote(pick("drool","moan"))
			if (prob(20))
				affected_mob.say(pick("Hungry...", "Must... kill...", "Brains..."))
		if(4)
			boutput(affected_mob, "<span class='alert'>Your heart seems to have stopped...</span>")
			affected_mob.set_mutantrace(zombie_mutantrace)
			if (ishuman(affected_mob))
				affected_mob:update_face()
				affected_mob:update_body()
			affected_mob:update_clothing()
			cure = "Incurable"
			D.stage++
		if(5)
			if(!istype(affected_mob:mutantrace, zombie_mutantrace))
				affected_mob.set_mutantrace(zombie_mutantrace)
				if (ishuman(affected_mob))
					affected_mob:update_face()
					affected_mob:update_body()
				affected_mob:update_clothing()
			affected_mob.stuttering = 10
			affected_mob.take_brain_damage(20)
			if (prob(10))
				affected_mob.emote(pick("moan"))

/datum/ailment/disease/necrotic_degeneration/can_infect_more
	zombie_mutantrace = /datum/mutantrace/zombie/can_infect
