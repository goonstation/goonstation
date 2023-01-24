/datum/intercept_text
	var/text
	var/prob_correct_person_lower = 20
	var/prob_correct_person_higher = 80
	var/prob_correct_job_lower = 20
	var/prob_correct_job_higher = 80
	var/prob_correct_prints_lower = 20
	var/prob_correct_print_higher = 80
	var/prob_correct_objective_lower = 20
	var/prob_correct_objective_higher = 80
	var/list/org_names_1 = list()
	var/list/org_names_2 = list()
	var/list/anomalies = list()
	var/list/SWF_names = list()

/datum/intercept_text/New()
	..()
	src.org_names_1.Add("Blighted", "Defiled", "Unholy", "Murderous", "Ugly", "French", "Blue", "Psychotic", "Farmer")
	src.org_names_2.Add("Reapers", "Swarm", "Rogues", "Menace", "Jeff Worshippers", "Drunks", "Strikers", "Creed")
	src.anomalies.Add("Huge electrical storm", "Photon emitter", "Meson generator", "Blue swirly thing")
	src.SWF_names.Add("Grand Wizard", "His Most Unholy Master", "The Most Angry", "Bighands", "Tall Hat", "Deadly Sandals")
//
/datum/intercept_text/proc/build(var/mode_type, correct_mob)
	switch(mode_type)
		if("revolution")
			src.text = ""
			src.build_rev(correct_mob)
			return src.text
		if("wizard")
			src.text = ""
			src.build_wizard(correct_mob)
			return src.text
		if("nuke")
			src.text = ""
			src.build_nuke(correct_mob)
			return src.text
		if("traitor")
			src.text = ""
			src.build_traitor(correct_mob)
			return src.text
		if("vampire")
			src.text = ""
			src.build_vampire(correct_mob)
			return src.text
		if(ROLE_CHANGELING)
			src.text = ""
			src.build_changeling(correct_mob)
			return src.text
		else
			return null

/datum/intercept_text/proc/pick_mob()
	var/list/dudes = list()
	for(var/mob/living/carbon/human/man in mobs)
		dudes += man
	var/dude = pick(dudes)
	return dude

/datum/intercept_text/proc/pick_fingerprints()
	var/mob/living/carbon/human/dude = src.pick_mob()
	var/print = "[dude.bioHolder.fingerprints]"
	return print

/datum/intercept_text/proc/build_traitor(correct_mob)
	var/name_1 = pick(src.org_names_1)
	var/name_2 = pick(src.org_names_2)
	var/fingerprints
	var/traitor_name
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	if(prob(prob_right_dude) && (ticker?.mode && istype(ticker.mode, /datum/game_mode/traitor)))
		if (correct_mob)
			traitor_name = correct_mob:current
	else if(prob(prob_right_dude))
		traitor_name = src.pick_mob()
	else
		fingerprints = src.pick_fingerprints()

	src.text += "<BR><BR>The [name_1] [name_2] implied an undercover operative was acting on their behalf on the station currently.<BR>"
	src.text += "After some investigation, we "
	if(traitor_name)
		src.text += "are [prob_right_dude]% sure that [traitor_name] may have been involved, and should be closely observed."
		src.text += "<BR>Note: This group are known to be untrustworthy, so do not act on this information without proper discourse."
	else
		src.text += "discovered the following set of fingerprints ([fingerprints]) on sensitive materials, and their owner should be closely observed."
		src.text += "However, these could also belong to a current Cent. Com employee, so do not act on this without reason."

/datum/intercept_text/proc/build_rev(correct_mob)
	var/name_1 = pick(src.org_names_1)
	var/name_2 = pick(src.org_names_2)
	var/traitor_name
	var/traitor_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job))
		if (correct_mob)
			traitor_job = correct_mob:assigned_role
	else
		var/list/job_tmp = get_all_jobs()
		job_tmp.Remove("Captain", "Security Officer", "Security Assistant", "Vice Officer", "Detective", "Head Of Security", "Head of Personnel", "Chief Engineer", "Research Director")
		traitor_job = pick(job_tmp)
	if(prob(prob_right_dude) && (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution)))
		if (correct_mob)
			traitor_name = correct_mob:current
	else
		traitor_name = src.pick_mob()

	src.text += "<BR><BR>It has been brought to our attention that the [name_1] [name_2] are attempting to stir unrest on one of our stations in your sector. <BR>"
	src.text += "Based on our intelligence, we are [prob_right_job]% sure that if true, someone doing the job of [traitor_job] on your station may have been brainwashed "
	src.text += "at a recent conference, and their department should be closely monitored for signs of mutiny. "
	if(prob(prob_right_dude))
		src.text += "<BR> In addition, we are [prob_right_dude]% sure that [traitor_name] may have also some in to contact with this "
		src.text += "organisation."
	src.text += "<BR>However, if this information is acted on without substantial evidence, those responsible will face severe repercussions."

/datum/intercept_text/proc/build_wizard(correct_mob)
	var/SWF_desc = pick(SWF_names)

	src.text += "<BR><BR>The evil Space Wizards Federation have recently broke their most feared wizard, known only as \"[SWF_desc]\" out of space jail. "
	src.text += "He is on the run, last spotted in a system near your present location. If anybody suspicious is located aboard, please "
	src.text += "approach with EXTREME caution. Cent. Com also recommends that it would be wise to not inform the crew of this, due to it's fearful nature."
	src.text += "Known attributes include: Brown sandals, a large blue hat, a voluptous white beard, and an inclination to cast spells."

/datum/intercept_text/proc/build_nuke(correct_mob)
	src.text += "<BR><BR>Cent. Com recently received a report of a plot to destroy one of our stations in your area. We believe an elite strike team is "
	src.text += "preparing to plant and activate a nuclear device aboard one of them. The security department should take all necessary precautions "
	src.text += "to repel an enemy boarding party if the need arises. As this may cause panic among the crew, all efforts should be made to keep this "
	src.text += "information a secret from all but the most trusted members."

/datum/intercept_text/proc/build_changeling(correct_mob)
	src.text += "<BR><BR>A mutagenic organism has escaped from a research lab in your sector. "
	src.text += "This organism is capable of mimicking any carbon based life form and is considered extremely dangerous. "
	src.text += "The crew should remain alert and report any individuals acting oddly."

/datum/intercept_text/proc/build_vampire(correct_mob)
	src.text += "<BR><BR>We have intercepted reports that a Space Wizard Federation menagerie facility in your sector has suffered a containment breach. "
	src.text += "It is possible that a Vampire has escaped from their cells and is likely to have taken refuge on the station. It is likely weak from its "
	src.text += "extended containment, but it will become increasingly more powerful if allowed to consume human blood. If caught, it must be terminated."
