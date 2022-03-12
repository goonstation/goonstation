/*/* -------------------- Heart Disease -------------------- */
/datum/ailment/disease/heartdisease
	name = "Heart Disease"
	scantype = "Medical Concern"
	max_stages = 2
	spread = "The patient's arteries have narrowed."
	cure = "Lifestyle Changes"
	reagentcure = list("heparin"=1, "salicylic_acid"=2, "nitroglycerin"=5)
	affected_species = list("Human","Monkey")
	stage_prob = 1

/datum/ailment/disease/heartdisease/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/D)
	..()
	if (iscarbon(affected_mob))
		var/mob/living/carbon/C = affected_mob
		APPLY_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "heartdisease", -2)
		C.add_stam_mod_max("heartdisease", -10)

/datum/ailment/disease/heartdisease/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/D)
	..()
	if (iscarbon(affected_mob))
		var/mob/living/carbon/C = affected_mob
		REMOVE_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "heartdisease")
		C.remove_stam_mod_max("heartdisease")

/datum/ailment/disease/heartdisease/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
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

		if (prob(cureprob))
			affected_mob.cure_disease(D)
			return
		else if (cureprob > 10 && src.reagentcure["heparin"] < 2)
			return

		if (D.stage >= 1) // chest pain, heartburn, shortness of breath and a little bit of damage from heart not getting enough oxygen
			if (prob(5))
				var/msg = pick("Your chest hurts[prob(20) ? ". The pain radiates down your [pick("left arm", "back")]" : null]",\
				"You feel a burning pain in your chest")
				boutput(affected_mob, "<span class='alert'>[msg].</span>")
			if (prob(2))
				affected_mob.losebreath ++
			if (prob(2))
				affected_mob.take_oxygen_deprivation(1)
			if (prob(2))
				affected_mob.emote("gasp")

		if (D.stage >= 2) // danger zone!! chance of heart attack!!
			if (prob(1))
				affected_mob.contract_disease(/datum/ailment/disease/heartfailure,null,null,1)
*/
