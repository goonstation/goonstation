/datum/ailment/malady/heartdisease
	name = "Heart Disease"
	scantype = "Medical Concern"
	info = "The patient's arteries have narrowed."
	max_stages = 2
	cure_flags = CURE_CUSTOM
	cure_desc = "Lifestyle Changes, Anticoagulants or Aspirin"
	reagentcure = list("heparin"=1, "salicylic_acid"=2)
	affected_species = list("Human","Monkey")
	stage_advance_prob = 1

/datum/ailment/malady/heartdisease/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/malady/D)
	..()
	if (iscarbon(affected_mob))
		var/mob/living/carbon/C = affected_mob
		APPLY_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "heartdisease", -2)
		C.add_stam_mod_max("heartdisease", -10)

/datum/ailment/malady/heartdisease/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/malady/D)
	..()
	if (iscarbon(affected_mob))
		var/mob/living/carbon/C = affected_mob
		REMOVE_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "heartdisease")
		C.remove_stam_mod_max("heartdisease")

/datum/ailment/malady/heartdisease/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
	if (..())
		return
	// chest pains, heartburn, shortness of breath (losebreath)
	if (ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if (H.organHolder)
			var/datum/organHolder/oH = H.organHolder
			if (!oH.heart) // where it go??  I don't know but it can't be diseased and hurt you if you don't have one sorry
				affected_mob.cure_disease(D)
				return
			if (oH.heart.robotic) // robit heart can't get disease!! not this kind at least
				affected_mob.cure_disease(D)
				return
		else // no organholder? shruuug
			affected_mob.cure_disease(D)
			return

		var/cureprob = 0
		if (H.blood_pressure["total"] < 666) // very high bp
			cureprob += 5
		if (H.blood_pressure["total"] < 585) // high bp
			cureprob += 5
		if (!H.bioHolder)
			cureprob += 5
		if (!H.reagents || !H.reagents.has_reagent("cholesterol"))
			cureprob += 5
		if (D.stage >= 2)
			cureprob -= 10

		if (probmult(cureprob))
			affected_mob.cure_disease(D)
			return
		else if (cureprob > 10 && src.reagentcure["heparin"] < 2)
			reagentcure = list("heparin"=2, "salicylic_acid"=4)

		if (D.stage >= 1) // chest pain, heartburn, shortness of breath and a little bit of damage from heart not getting enough oxygen
			if (probmult(5))
				var/msg = pick("Your chest hurts[prob(20) ? ". The pain radiates down your [pick("left arm", "back")]" : null].</span>",\
				"You feel a burning pain in your chest.</span>",\
				"Your chest feels tight.</span>",\
				"You feel a squeezing pressure in your chest.</span>",\
				"You feel short of breath.</span>")
				if (prob(1) && prob(10))
					msg = "It feels like you're being hugged real hard by a bear! Or maybe a robot! Maybe a robot bear!!</span><br>Point is that your chest hurts and it's hard to breath.[prob(5) ? "<br>A robot bear would be kinda cool though. Do they make those?" : null]"
				boutput(affected_mob, SPAN_ALERT("[msg]"))
			if (probmult(2))
				affected_mob.losebreath = max(affected_mob.losebreath, 1)
			if (probmult(2))
				affected_mob.take_oxygen_deprivation(1)
			if (probmult(2))
				affected_mob.emote("gasp")

		if (D.stage >= 2) // danger zone!! chance of heart attack!!
			if (probmult(1))
				affected_mob.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
