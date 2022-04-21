
/datum/ailment/malady
	name = "Malady"
	scantype = "Medical Malady"
	cure = "Unknown"

/datum/ailment_data/malady
	var/robo_restart = 0 // used for cyberheart stuff
	var/affected_area = null // used for bloodclots, can be chest (heart, eventually lung), head (brain), limb

	New()
		..()
		master = get_disease_from_path(/datum/ailment/malady)
		master.tickcount = 0

	stage_act(mult)
		if (!affected_mob || disposed)
			return 1

		if (!istype(master,/datum/ailment/))
			affected_mob.ailments -= src
			qdel(src)
			return 1

		if (stage > master.max_stages)
			stage = master.max_stages

		if (stage < 1) // if it's less than one just get rid of it, goddamn
			affected_mob.cure_disease(src)
			return 1

		var/advance_prob = stage_prob
		if (state == "Acute")
			advance_prob *= 2

		if (probmult(advance_prob))
			if (state == "Remissive")
				stage--
				if (stage < 1)
					affected_mob.cure_disease(src)
				return 1
			else if (stage < master.max_stages)
				if (master.tickcount >= master.min_advance_ticks)
					master.tickcount = 0
					stage++

		// Common cures
		if (cure != "Incurable")
			if (cure == "Sleep" && affected_mob.sleeping && probmult(33))
				state = "Remissive"
				return 1

			else if (cure == "Self-Curing" && probmult(5))
				state = "Remissive"
				return 1

			else if (cure == "Beatings" && affected_mob.get_brute_damage() >= 40)
				state = "Remissive"
				return 1

			else if (cure == "Burnings" && (affected_mob.get_burn_damage() >= 40 || affected_mob.getStatusDuration("burning")))
				state = "Remissive"
				return 1

			else if (affected_mob.bodytemperature >= temperature_cure)
				state = "Remissive"
				return 1

			if (reagentcure.len && affected_mob.reagents)
				for (var/current_id in affected_mob.reagents.reagent_list)
					if (reagentcure.Find(current_id))
						var/we_are_cured = 0
						var/reagcure_prob = reagentcure[current_id]
						if (isnum(reagcure_prob))
							if (probmult(reagcure_prob))
								we_are_cured = 1
						else if (probmult(recureprob))
							we_are_cured = 1
						if (we_are_cured)
							state = "Remissive"
							return 1

		if (state == "Asymptomatic")
			return 1

		SPAWN(rand(1,5))
			// vary it up a bit so the processing doesnt look quite as transparent
			if (master)
				master.stage_act(affected_mob, src, mult)

		master.tickcount++

		return 0

/* -------------------- Shock -------------------- */
/datum/ailment/malady/shock
	name = "Shock"
	scantype = "Medical Emergency"
	info = "The patient is in shock."
	max_stages = 3
	cure = "Saline Solution"
	reagentcure = list("saline")
	recureprob = 10
	affected_species = list("Human","Monkey")
	stage_prob = 6
	min_advance_ticks = 5 //delay!!

/datum/ailment/malady/shock/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
	if (..())
		return
	if (affected_mob.health >= 25 && affected_mob.nutrition >= 0)
		var/mob/living/carbon/human/H = null
		if(ishuman(affected_mob))
			H = affected_mob
		if(!H || H.blood_volume > 250)
			boutput(affected_mob, "<span class='notice'>You feel better.</span>")
			affected_mob.cure_disease(D)
			return
	switch(D.stage)
		if (1)
			if (probmult(0.1))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
				return
			if (probmult(8))
				affected_mob.emote(pick("shiver", "pale", "moan"))
			if (probmult(5))
				boutput(affected_mob, "<span class='alert'>You feel weak!</span>")
		if (2)
			if (probmult(0.1))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
				return
			if (probmult(8))
				affected_mob.emote(pick("shiver", "pale", "moan", "shudder", "tremble"))
			if (probmult(5))
				affected_mob.emote("faint", "collapse", "groan")
			if (probmult(5))
				boutput(affected_mob, "<span class='alert'>You feel absolutely terrible!</span>")
		if (3)
			if (probmult(0.1))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
				return
			if (probmult(8))
				affected_mob.emote(pick("shudder", "pale", "tremble", "groan", "shake"))
			if (probmult(5))
				affected_mob.emote(pick("faint", "collapse", "groan"))
			if (probmult(5))
				boutput(affected_mob, "<span class='alert'>You feel horrible!</span>")
			if (probmult(7))
				boutput(affected_mob, "<span class='alert'>You can't breathe!</span>")
				affected_mob.losebreath++
			if (probmult(5))
				affected_mob.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)

/*------------------- Hypoglycemia -------------------*/
/datum/ailment/malady/hypoglycemia
	name = "Hypoglycemia"
	scantype = "Medical Emergency"
	max_stages = 3
	info = "The patient has low blood sugar."
	cure = "Deactivation of implants/augments combined with eating or glucose treatment"
	affected_species = list("Human")
	stage_prob = 1

/datum/ailment/malady/hypoglycemia/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
	if(..())
		return
	if(affected_mob.nutrition > 0)
		boutput(affected_mob, "<span class='notice'>You feel a lot better!</span>")
		affected_mob.cure_disease(D)
		return
	switch(D.stage)
		if (1)
			if (probmult(4))
				boutput(affected_mob, "<span class='alert'>You feel hungry!</span>")
			if (probmult(2))
				boutput(affected_mob, "<span class='alert'>You have a headache!</span>")
			if (probmult(2))
				boutput(affected_mob, "<span class='alert'>You feel [pick("anxious","depressed")]!</span>")
		if(2)
			if (probmult(4))
				boutput(affected_mob, "<span class='alert'>You feel like everything is wrong with your life!</span>")
			if (probmult(5))
				affected_mob.changeStatus("slowed", rand(8,32) SECONDS)
				boutput(affected_mob, "<span class='alert'>You feel [pick("tired", "exhausted", "sluggish")].</span>")
			if (probmult(5))
				affected_mob.changeStatus("weakened", 12 SECONDS)
				affected_mob.stuttering = max(10, affected_mob.stuttering)
				boutput(affected_mob, "<span class='alert'>You feel [pick("numb", "confused", "dizzy", "lightheaded")].</span>")
				affected_mob.emote("collapse")
		if(3)
			if(probmult(8))
				affected_mob.contract_disease(/datum/ailment/malady/shock,null,null,1)
			if(probmult(12))
				affected_mob.changeStatus("weakened", 12 SECONDS)
				affected_mob.stuttering = max(10, affected_mob.stuttering)
				boutput(affected_mob, "<span class='alert'>You feel [pick("numb", "confused", "dizzy", "lightheaded")].</span>")
				affected_mob.emote("collapse")
			if (probmult(12))
				boutput(affected_mob, "<span class='alert'>You feel [pick("tired", "exhausted", "sluggish")].</span>")
				affected_mob.changeStatus("slowed", rand(8,32) SECONDS)



/* -------------------- Blood Clot -------------------- */
/datum/ailment/malady/bloodclot
	name = "Blood Clot"
	scantype = "Potential Medical Emergency"
	max_stages = 1
	info = "The patient has a blood clot."
	cure = "Anticoagulants"
	reagentcure = list("heparin")
	recureprob = 10
	affected_species = list("Human","Monkey")
	stage_prob = 5

/datum/ailment/malady/bloodclot/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/malady/D)
	..()
	if (D)
		D.state = "Asymptomatic" // not doing anything at first

/datum/ailment/malady/bloodclot/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/malady/D)
	..()
	if (iscarbon(affected_mob))
		var/mob/living/carbon/C = affected_mob
		REMOVE_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot")
		C.remove_stam_mod_max("bloodclot")

/datum/ailment/malady/bloodclot/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
	if (D?.state == "Asymptomatic")
		if (prob(1) && (prob(1) || affected_mob.find_ailment_by_type(/datum/ailment/malady/heartdisease) || affected_mob.reagents && affected_mob.reagents.has_reagent("proconvertin"))) // very low prob to become...
			D.state = "Active"
			D.scantype = "Medical Emergency"
	if (..())
		return
	if (D?.state == "Active")
		if (!ishuman(affected_mob))
			affected_mob.cure_disease(D)
			return
		var/mob/living/carbon/human/H = affected_mob
		if (!D.affected_area && probmult(20))
			var/list/possible_areas = list()
			if (H.organHolder)
				if (H.organHolder.heart)
					possible_areas += "chest"
				if (H.organHolder.brain)
					possible_areas += "head"
			if (H.limbs)
				if (H.limbs.l_arm)
					possible_areas += "left arm"
				if (H.limbs.r_arm)
					possible_areas += "right arm"
				if (H.limbs.l_leg)
					possible_areas += "left leg"
				if (H.limbs.r_leg)
					possible_areas += "right leg"
			D.affected_area = pick(possible_areas)
			if (!D.affected_area)
				affected_mob.cure_disease(D)
				return
			boutput(affected_mob, "<span class='alert'>Your [D.affected_area] starts hurting!</span>")
		else if (probmult(3))
			boutput(affected_mob, "<span class='alert'>Your [D.affected_area] hurts!</span>")

		switch (D.affected_area)
			if ("chest")
				if (H.organHolder && !H.organHolder.heart) // you need a heart to have an embolism in it
					affected_mob.cure_disease(D)
					return
				if (probmult(5) && iscarbon(affected_mob))
					var/mob/living/carbon/C = affected_mob
					APPLY_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot", -2)
					C.add_stam_mod_max("bloodclot", -10)
				if (probmult(5))
					affected_mob.losebreath ++
				if (probmult(5))
					affected_mob.take_oxygen_deprivation(rand(1,2))
				if (probmult(5))
					affected_mob.emote(pick("twitch", "groan", "gasp"))
				if (probmult(1))
					affected_mob.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
			if ("head")
				if (H.organHolder && !H.organHolder.head || !H.organHolder.brain) // you need a brain to have an embolism in it
					affected_mob.cure_disease(D)
					return
				if (probmult(5) && iscarbon(affected_mob))
					var/mob/living/carbon/C = affected_mob
					APPLY_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot", -2)
					C.add_stam_mod_max("bloodclot", -10)
				if (probmult(8))
					affected_mob.take_brain_damage(10)
				if (probmult(5))
					affected_mob.stuttering += 1
				if (probmult(2))
					affected_mob.changeStatus("drowsy", 5 SECONDS)
				if (probmult(5))
					affected_mob.emote(pick("faint", "collapse", "twitch", "groan"))
			else // a limb or whatever
				if (H.limbs)
					if (D.affected_area == "left arm" && !H.limbs.l_arm)
						affected_mob.cure_disease(D)
						return
					else if (D.affected_area == "right arm" && !H.limbs.r_arm)
						affected_mob.cure_disease(D)
						return
					else if (D.affected_area == "left leg" && !H.limbs.l_leg)
						affected_mob.cure_disease(D)
						return
					else if (D.affected_area == "right leg" && !H.limbs.r_leg)
						affected_mob.cure_disease(D)
						return
				if (probmult(2)) // the clot moves
					boutput(affected_mob, "<span class='notice'>Your [D.affected_area] stops hurting.</span>")
					if (prob(1))
						affected_mob.cure_disease(D)
						return
					D.affected_area = null
					if (iscarbon(affected_mob))
						var/mob/living/carbon/C = affected_mob
						REMOVE_ATOM_PROPERTY(C, PROP_MOB_STAMINA_REGEN_BONUS, "bloodclot")
						C.remove_stam_mod_max("bloodclot")

/* -------------------- Heart Disease -------------------- */
/datum/ailment/malady/heartdisease
	name = "Heart Disease"
	scantype = "Medical Concern"
	info = "The patient's arteries have narrowed."
	max_stages = 2
	cure = "Lifestyle Changes, Anticoagulants or Aspirin"
	reagentcure = list("heparin"=1, "salicylic_acid"=2)
	affected_species = list("Human","Monkey")
	stage_prob = 1

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
				boutput(affected_mob, "<span class='alert'>[msg]")
			if (probmult(2))
				affected_mob.losebreath = max(affected_mob.losebreath, 1)
			if (probmult(2))
				affected_mob.take_oxygen_deprivation(1)
			if (probmult(2))
				affected_mob.emote("gasp")

		if (D.stage >= 2) // danger zone!! chance of heart attack!!
			if (probmult(1))
				affected_mob.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)

/* -------------------- Cardiac Failure -------------------- */
/datum/ailment/malady/heartfailure
	name = "Cardiac Failure"
	scantype = "Medical Emergency"
	info = "The patient is having a cardiac emergency."
	max_stages = 3
	cure = "Cardiac Stimulants"
	reagentcure = list("atropine"=8,"epinephrine"=10,"heparin"=5)
	recureprob = 10
	affected_species = list("Human","Monkey")
	stage_prob = 5

/datum/ailment/malady/heartfailure/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
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
			var/datum/organHolder/oH = H.organHolder
			boutput(H, "<span class='alert'>Your cyberheart detects a cardiac event and attempts to return to its normal rhythm!</span>")
			if (probmult(40) && oH.heart.emagged)
				D.robo_restart = 1
				SPAWN(oH.heart.emagged ? 200 : 300)
					D.robo_restart = 0
				SPAWN(3 SECONDS)
					if (H)
						H.cure_disease(D)
						boutput(H, "<span class='alert'>Your cyberheart returns to its normal rhythm!</span>")
					return
			else if (probmult(25))
				D.robo_restart = 1
				SPAWN(oH.heart.emagged ? 200 : 300)
					if (D) //ZeWaka: Fix for null.robo_restart
						D.robo_restart = 0
				SPAWN(3 SECONDS)
					if (H)
						H.cure_disease(D)
						boutput(H, "<span class='alert'>Your cyberheart returns to its normal rhythm!</span>")
					return
			else
				D.robo_restart = 1
				SPAWN(oH.heart.emagged ? 200 : 300)
					if (D)
						D.robo_restart = 0
				SPAWN(3 SECONDS)
					if (H)
						boutput(H, "<span class='alert'>Your cyberheart fails to return to its normal rhythm!</span>")

	switch (D.stage)
		if (1)
			if (probmult(0.1))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
				return
			if (probmult(8))
				affected_mob.emote(pick("pale", "shudder"))
			if (probmult(5))
				boutput(affected_mob, "<span class='alert'>Your arm hurts!</span>")
			else if (probmult(5))
				boutput(affected_mob, "<span class='alert'>Your chest hurts!</span>")
		if (2)
			if (probmult(0.1))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.resistances += src.type
				affected_mob.ailments -= src
				return
			if (probmult(8))
				affected_mob.emote(pick("pale", "groan"))
			if (probmult(5))
				boutput(affected_mob, "<span class='alert'>Your heart lurches in your chest!</span>")
				affected_mob.losebreath++
			if (probmult(3))
				boutput(affected_mob, "<span class='alert'>Your heart stops beating!</span>")
				affected_mob.losebreath+=3
			if (probmult(5))
				affected_mob.emote(pick("faint", "collapse", "groan"))
		if (3)
			affected_mob.take_oxygen_deprivation(1)
			if (probmult(8))
				affected_mob.emote(pick("twitch", "gasp"))
			if (probmult(1) && !affected_mob.hasStatus("defibbed")) // down from 5
				affected_mob.contract_disease(/datum/ailment/malady/flatline,null,null,1)

/* -------------------- Cardiac Arrest -------------------- */
/datum/ailment/malady/flatline
	name = "Cardiac Arrest"
	scantype = "Medical Emergency"
	info = "The patient's heart has stopped."
	max_stages = 1
	cure = "Electric Shock"
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
			boutput(H, "<span class='alert'>Your cyberheart detects a cardiac event and attempts to return to its normal rhythm!</span>")

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
					boutput(H, "<span class='alert'>Your cyberheart returns to its normal rhythm!</span>")
					return

			else if (probmult(10))
				H.cure_disease(D)
				D.robo_restart = 1
				if (H.organHolder.heart.emagged)
					SPAWN(20 SECONDS)
						if (D) //ZeWaka: Fix for null.robo_restart x4
							D.robo_restart = 0
				else
					SPAWN(30 SECONDS)
						if (D)
							D.robo_restart = 0
				SPAWN(3 SECONDS)
					boutput(H, "<span class='alert'>Your cyberheart returns to its normal rhythm!</span>")
					return

			else
				D.robo_restart = 1
				if (H.organHolder.heart.emagged)
					SPAWN(20 SECONDS)
						if (D)
							D.robo_restart = 0
				else
					SPAWN(30 SECONDS)
						if (D)
							D.robo_restart = 0
				SPAWN(3 SECONDS)
					boutput(H, "<span class='alert'>Your cyberheart fails to return to its normal rhythm!</span>")
		else
			if (H.get_oxygen_deprivation())
				H.take_brain_damage(3 * mult)
			else if (prob(10))
				H.take_brain_damage(1 * mult)

		H.changeStatus("weakened", 6 * mult SECONDS)
		H.losebreath+=20 * mult
		H.take_oxygen_deprivation(20 * mult)
