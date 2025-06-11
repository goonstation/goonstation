/datum/ailment/disability/memetic_madness
	name = "Memetic Kill Agent"
	cure_flags = CURE_UNKNOWN
	affected_species = list("Human")
	max_stages = 4
	stage_advance_prob = 8
	strain_type = /datum/ailment_data/memetic_madness

	stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D,mult,var/obj/item/storage/toolbox/memetic/progenitor)
		if (..())
			return
		if(progenitor in affected_mob.contents)
			if(affected_mob.get_oxygen_deprivation())
				affected_mob.take_oxygen_deprivation(-5 * mult)
			affected_mob:HealDamage("All", 12 * mult, 12 * mult)
			if(affected_mob.get_toxin_damage())
				affected_mob.take_toxin_damage(-5 * mult)
			affected_mob.remove_stuns()
			affected_mob.dizziness = max(0,affected_mob.dizziness-10 * mult)
			affected_mob.changeStatus("drowsy", -20 * mult SECONDS)
			affected_mob:sleeping = 0
			D.stage = 1
			switch (progenitor.hunger)
				if (10 to 60)
					if (progenitor.hunger_message_level < 1)
						progenitor.hunger_message_level = 1
						boutput(affected_mob, "<i><b><font face = Tempus Sans ITC>Feed Me the unclean ones...They will be purified...</font></b></i>")
				if (61 to 120)
					if (progenitor.hunger_message_level < 2)
						progenitor.hunger_message_level = 2
						boutput(affected_mob, "<i><b><font face = Tempus Sans ITC>I hunger for the flesh of the impure...</font></b></i>")
				if (121 to 210)
					if (prob(10) && progenitor.hunger_message_level < 3)
						progenitor.hunger_message_level = 3
						boutput(affected_mob, "<i><b><font face = Tempus Sans ITC>The hunger of Your Master grows with every passing moment.  Feed Me at once.</font></b></i>")
				if (230 to 399)
					if (progenitor.hunger_message_level < 4)
						progenitor.hunger_message_level = 4
						boutput(affected_mob, "<i><b><font face = Tempus Sans ITC>His Grace starves in your hands.  Feed Me the unclean or suffer.</font></b></i>")
				if (300 to INFINITY)
					affected_mob.visible_message(SPAN_ALERT("<b>[progenitor] consumes [affected_mob] whole!</b>"))
					progenitor.consume(affected_mob)
					return

			progenitor.hunger += clamp((progenitor.force / 10), 1, 10) * mult

		else if(D.stage == 4)
			if(GET_DIST(get_turf(progenitor),src) <= 7)
				D.stage = 1
				return
			if(probmult(4))
				boutput(affected_mob, SPAN_ALERT("We are too far from His Grace..."))
				affected_mob.take_toxin_damage(5)
			else if(probmult(6))
				boutput(affected_mob, SPAN_ALERT("You feel weak."))
				random_brute_damage(affected_mob, 5)

			if (ismob(progenitor.loc))
				progenitor.hunger += 1 * mult

		return

/datum/ailment_data/memetic_madness
	var/obj/item/storage/toolbox/memetic/progenitor = null
	stage_advance_prob = 8

	New()
		..()
		master = get_disease_from_path(/datum/ailment/disability/memetic_madness)

	stage_act(mult)
		if (!istype(master,/datum/ailment/) || !src.progenitor)
			affected_mob.ailments -= src
			qdel(src)
			return

		if(stage > master.max_stages)
			stage = master.max_stages

		if(probmult(stage_advance_prob) && stage < master.max_stages)
			stage++

		master.stage_act(affected_mob,src,mult,progenitor)

		return

/mob/living/proc/contract_memetic_madness(var/obj/item/storage/toolbox/memetic/newprogenitor)
	if(src.find_ailment_by_type(/datum/ailment/disability/memetic_madness))
		return

	src.resistances -= /datum/ailment/disability/memetic_madness
	// just going to have to set it up manually i guess
	var/datum/ailment_data/memetic_madness/AD = get_disease_from_path(/datum/ailment/disability/memetic_madness).setup_strain()

	if(istype(newprogenitor,/obj/item/storage/toolbox/memetic/))
		AD.progenitor = newprogenitor
		AD.affected_mob = src
		src.contract_disease(/datum/ailment/disability/memetic_madness, null, AD, TRUE)
		newprogenitor.servantlinks.Add(AD)
		newprogenitor.force += 4
		newprogenitor.throwforce += 4
	else
		qdel(AD)
		return

	var/acount = 0
	var/amax = rand(10,15)
	var/screamstring = null
	var/asize = 1
	while(acount <= amax)
		screamstring += "<font size=[asize]>a</font>"
		if(acount > (amax/2))
			asize--
		else
			asize++
		acount++
	src.playsound_local(src.loc,'sound/effects/screech.ogg', 50, 1)
	shake_camera(src, 20, 16)
	boutput(src, SPAN_ALERT("[screamstring]"))
	boutput(src, "<i><b><font face = Tempus Sans ITC>His Grace accepts thee, spread His will! All who look close to the Enlightened may share His gifts.</font></b></i>")
	return


/*
 *	His Grace for Dummies
 */

/obj/item/paper/memetic_manual
	name = "paper- 'So You Want to Worship His Grace'"
	info = {"<center><h4>Worship QuickStart</h4></center><ol>
	<li>Gaze into His Grace. Observe His magnificence. Examine the quality of His form.</li>
	<li>Carry His Grace. Show the unbelievers the power of Him.  Know that all who gaze upon the splendor of His Chosen will know of Him.</li>
	<li>His Grace hungers! Take the unworthy ones in your hands and place them inside Him!</li>
	<li>After every nourishment, His Grace will hold their spoils. Remove these from Him and make great use of them, as gifts.</li>
	<li>Know that the His might will grow with every new Chosen and, in turn, the power of the Chosen carrying Him. But be warned! As He grows in strength, so doth His appetite!</li>
	</ol>
	"}
