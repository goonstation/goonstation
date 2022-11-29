/obj/item/organ/appendix
	name = "appendix"
	organ_name = "appendix"
	organ_holder_name = "appendix"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 3
	icon_state = "appendix"
	failure_disease = /datum/ailment/disease/appendicitis

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() >= fail_damage && prob(src.get_damage() * 0.2) && !robotic)
			donor.contract_disease(failure_disease,null,null,1)
		return 1

/obj/item/organ/appendix/synth
	name = "synthappendix"
	organ_name = "synthappendix"
	icon_state = "plant"
	desc = "A plant-based alternative to the normal appendix..."
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_appendix", "plant_appendix_bloom")

/obj/item/organ/appendix/cyber
	name = "cyberappendix"
	desc = "A fancy robotic appendix to replace one that someone's lost!"
	icon_state = "cyber-appendix"
	// item_state = "cyber-"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	made_from = "pharosium"
	edible = 0
	mats = 6

	//A bad version of the robutsec... For now.
	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() < fail_damage && probmult(10) && donor.health <= donor.max_health)
			var/reagID = pick("saline", "salbutamol", "salicylic_acid", "charcoal")
			donor.reagents.add_reagent(reagID, reagID == "salicyclic_acid" ? 2 : 4) //salicyclic has very low depletion, reduce chances of overdose
			if(donor.health <= donor.max_health * 0.9)
				src.take_damage(0, 0, 1)

		if(emagged && !broken && donor.health < 0) //emagged and we're in crit
			src.take_damage(200, 200, 200)
		return 1

	on_broken(var/mult = 1)
		if (!..())
			return
		if(emagged)
			donor.reagents.add_reagent("toxin", 0.5 * mult) //Will really start to feel it after the omnizine wears off
			if (prob(20))
				donor.emote(pick("twitch", "groan"))

	breakme()
		if(..() && emagged)
			donor.emote("collapse")
			donor.setStatus("weakened", 3 SECONDS)

			donor.reagents.add_reagent("salbutamol", 20) //copied mostly from robusttec
			donor.reagents.add_reagent("epinephrine", 15)
			donor.reagents.add_reagent("omnizine", 15) //reduced omnizine amount
			donor.reagents.add_reagent("teporone", 20)
			#ifdef CREATE_PATHOGENS
			add_pathogens(donor, 30) //oh no
			#endif
			boutput(donor, "<span class='alert'>Your appendix has burst! It has given you medical help... though you might want to see a doctor very soon.</span>")
