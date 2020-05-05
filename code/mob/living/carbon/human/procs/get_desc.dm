
/mob/living/carbon/human/get_desc()

	var/ignore_checks = isobserver(usr)

	if (!ignore_checks && src.bioHolder && src.bioHolder.HasEffect("examine_stopper"))
		return "<br><span style='color:red'>You can't seem to make yourself look at [src.name] long enough to observe anything!</span>"

	if (src.simple_examine || isghostdrone(usr))
		return

	if (!usr.client.eye)
		return // heh

	. = ""
	if (isalive(usr))
		. += "<br><span style='color:blue'>You look closely at <B>[src.name]</B>.</span>"
		sleep(get_dist(usr.client.eye, src) + 1)
	if (!istype(usr, /mob/dead/target_observer))
		if (!ignore_checks && (get_dist(usr.client.eye, src) > 7 && (!usr.client || !usr.client.eye || !usr.client.holder || usr.client.holder.state != 2)))
			return "[.]<br><span style='color:red'><B>[src.name]</B> is too far away to see clearly.</span>"

	try
		. = "<br>[src.bioHolder.mobAppearance.flavor_text]"
	catch
		//nop

	. +=  "<br><span style='color:blue'>*---------*</span>"

	// crappy hack because you can't do \his[src] etc
	var/t_his = his_or_her(src)
	var/t_him = him_or_her(src)

	var/datum/ailment_data/found = src.find_ailment_by_type(/datum/ailment/disability/memetic_madness)
	if (!ignore_checks && found)
		if (!ishuman(usr))
			. += "<br><span style='color:red'>You can't focus on [t_him], it's like looking through smoked glass.</span>"
			return
		else
			var/mob/living/carbon/human/H = usr
			var/datum/ailment_data/memetic_madness/MM = H.find_ailment_by_type(/datum/ailment/disability/memetic_madness)
			if (istype(MM) && istype(MM.master,/datum/ailment/disability/memetic_madness))
				H.contract_memetic_madness(MM.progenitor)
				return

			. += "<br><span style='color:blue'>A servant of His Grace...</span>"

	// unfortunately byond can't handle "[src.slot.blood_DNA ? "a bloody" : "\an"] [src.slot.name]" because then the \an is like "where the fuck is the thing I'm supposed to do something to???"
	// thanks, byondbama.
	if (src.w_uniform)
		. += "<br><span style='color:[src.w_uniform.blood_DNA ? "red" : "blue"]'>[src.name] is wearing [bicon(src.w_uniform)] [src.w_uniform.blood_DNA ? "a bloody [src.w_uniform.name]" : "\an [src.w_uniform.name]"].</span>"

	if (src.hasStatus("handcuffed"))
		. +=  "<br><span style='color:blue'>[src.name] is [bicon(src.handcuffs)] handcuffed!</span>"

	if (src.wear_suit)
		. += "<br><span style='color:[src.wear_suit.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.wear_suit)] [src.wear_suit.blood_DNA ? "a bloody [src.wear_suit.name]" : "\an [src.wear_suit.name]"] on.</span>"

	if (src.ears)
		. += "<br><span style='color:[src.ears.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.ears)] [src.ears.blood_DNA ? "a bloody [src.ears.name]" : "\an [src.ears.name]"] by [t_his] mouth.</span>"

	if (src.head)
		. += "<br><span style='color:[src.head.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.head)] [src.head.blood_DNA ? "a bloody [src.head.name]" : "\an [src.head.name]"] on [t_his] head.</span>"

	if (src.wear_mask)
		. += "<br><span style='color:[src.wear_mask.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.wear_mask)] [src.wear_mask.blood_DNA ? "a bloody [src.wear_mask.name]" : "\an [src.wear_mask.name]"] on [t_his] face.</span>"

	if (src.glasses)
		if (((src.wear_mask && src.wear_mask.see_face) || !src.wear_mask) && ((src.head && src.head.see_face) || !src.head))
			. += "<br><span style='color:[src.glasses.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.glasses)] [src.glasses.blood_DNA ? "a bloody [src.glasses.name]" : "\an [src.glasses.name]"] on [t_his] face.</span>"

	if (src.l_hand)
		. += "<br><span style='color:[src.l_hand.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.l_hand)] [src.l_hand.blood_DNA ? "a bloody [src.l_hand.name]" : "\an [src.l_hand.name]"] in [t_his] left hand.</span>"

	if (src.r_hand)
		. += "<br><span style='color:[src.r_hand.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.r_hand)] [src.r_hand.blood_DNA ? "a bloody [src.r_hand.name]" : "\an [src.r_hand.name]"] in [t_his] right hand.</span>"

	if (src.belt)
		. += "<br><span style='color:[src.belt.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.belt)] [src.belt.blood_DNA ? "a bloody [src.belt.name]" : "\an [src.belt.name]"] on [t_his] belt.</span>"

	if (src.gloves)
		. += "<br><span style='color:[src.gloves.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.gloves)] [src.gloves.blood_DNA ? "bloody " : null][src.gloves.name] on [t_his] hands.</span>"
	else if (src.blood_DNA)
		. += "<br><span style='color:red'>[src.name] has bloody hands!</span>"

	if (src.shoes)
		. += "<br><span style='color:[src.shoes.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.shoes)] [src.shoes.blood_DNA ? "bloody " : null][src.shoes.name] on [t_his] feet.</span>"
	else if (islist(src.tracked_blood))
		. += "<br><span style='color:red'>[src.name] has bloody feet!</span>"

	if (src.back)
		. += "<br><span style='color:[src.back.blood_DNA ? "red" : "blue"]'>[src.name] has [bicon(src.back)] [src.back.blood_DNA ? "a bloody [src.back.name]" : "\an [src.back.name]"] on [t_his] back.</span>"

	if (src.wear_id)
		if (istype(src.wear_id, /obj/item/card/id))
			if (src.wear_id:registered != src.real_name && in_range(src, usr) && prob(10))
				. += "<br><span style='color:red'>[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name] yet doesn't seem to be that person!!!</span>"
			else
				. += "<br><span style='color:blue'>[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name].</span>"
		else if (istype(src.wear_id, /obj/item/device/pda2) && src.wear_id:ID_card)
			if (src.wear_id:ID_card:registered != src.real_name && in_range(src, usr) && prob(10))
				. += "<br><span style='color:red'>[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name] with [bicon(src.wear_id:ID_card)] [src.wear_id:ID_card:name] in it yet doesn't seem to be that person!!!</span>"
			else
				. += "<br><span style='color:blue'>[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name] with [bicon(src.wear_id:ID_card)] [src.wear_id:ID_card:name] in it.</span>"

	if (src.is_jittery)
		switch(src.jitteriness)
			if (300 to INFINITY)
				. += "<br><span style='color:red'>[src] is violently convulsing.</span>"
			if (200 to 300)
				. += "<br><span style='color:red'>[src] looks extremely jittery.</span>"
			if (100 to 200)
				. += "<br><span style='color:red'>[src] is twitching ever so slightly.</span>"

	if (src.organHolder)
		var/datum/organHolder/oH = src.organHolder
		if (oH.brain)
			if (oH.brain.op_stage > 0.0)
				. += "<br><span style='color:red'><B>[src.name] has an open incision on [t_his] head!</B></span>"
		else if (!oH.brain && oH.skull && oH.head)
			. += "<br><span style='color:red'><B>[src.name]'s head has been cut open and [t_his] brain is gone!</B></span>"
		else if (!oH.skull && oH.head)
			. += "<br><span style='color:red'><B>[src.name] no longer has a skull in [t_his] head, [t_his] face is just empty skin mush!</B></span>"
		else if (!oH.head)
			. += "<br><span style='color:red'><B>[src.name] has been decapitated!</B></span>"

		if (oH.head)
			if (((src.wear_mask && src.wear_mask.see_face) || !src.wear_mask) && ((src.head && src.head.see_face) || !src.head))
				if (!oH.right_eye && !oH.left_eye)
					. += "<br><span style='color:red'><B>[src.name]'s eyes are missing!</B></span>"
				else
					if (!oH.left_eye)
						. += "<br><span style='color:red'><B>[src.name]'s left eye is missing!</B></span>"
					else if (oH.left_eye.show_on_examine)
						. += "<br><span style='color:blue'>[src.name] has [bicon(oH.left_eye)] \an [oH.left_eye.organ_name] in their left eye socket.</span>"
					if (!oH.right_eye)
						. += "<br><span style='color:red'><B>[src.name]'s right eye is missing!</B></span>"
					else if (oH.right_eye.show_on_examine)
						. += "<br><span style='color:blue'>[src.name] has [bicon(oH.right_eye)] \an [oH.right_eye.organ_name] in their right eye socket.</span>"

		if (src.organHolder.heart)
			if (src.organHolder.heart.op_stage > 0.0)
				. += "<br><span style='color:red'><B>[src.name] has an open incision on [t_his] chest!</B></span>"
		else
			. += "<br><span style='color:red'><B>[src.name]'s chest is cut wide open and [t_his] heart has been removed!</B></span>"

		if (src.organHolder.chest.op_stage > 0.0)
			. += "<br><span style='color:red'><B>[src.name] has an indeterminate number of small surgical scars on [t_his] chest!</B></span>"

		if (src.butt_op_stage > 0)
			if (src.butt_op_stage >= 4)
				. += "<br><span style='color:red'><B>[src.name]'s butt seems to be missing!</B></span>"
			else
				. += "<br><span style='color:red'><B>[src.name] has an open incision on [t_his] butt!</B></span>"

	if (src.limbs)
		if (!src.limbs.l_arm)
			. += "<br><span style='color:red'><B>[src.name]'s left arm is completely severed!</B></span>"
		else
			var/limbtxt = src.limbs.l_arm.on_holder_examine()
			if (limbtxt)
				. += "<br><span style='color:blue'>[src.name] [limbtxt] left arm.</span>"

		if (!src.limbs.r_arm)
			. += "<br><span style='color:red'><B>[src.name]'s right arm is completely severed!</B></span>"
		else
			var/limbtxt = src.limbs.r_arm.on_holder_examine()
			if (limbtxt)
				. += "<br><span style='color:blue'>[src.name] [limbtxt] right arm.</span>"

		if (!src.limbs.l_leg)
			. += "<br><span style='color:red'><B>[src.name]'s left leg is completely severed!</B></span>"
		else
			var/limbtxt = src.limbs.l_leg.on_holder_examine()
			if (limbtxt)
				. += "<br><span style='color:blue'>[src.name] [limbtxt] left leg.</span>"

		if (!src.limbs.r_leg)
			. += "<br><span style='color:red'><B>[src.name]'s right leg is completely severed!</B></span>"
		else
			var/limbtxt = src.limbs.r_leg.on_holder_examine()
			if (limbtxt)
				. += "<br><span style='color:blue'>[src.name] [limbtxt] right leg.</span>"
	if (src.chest_cavity_open)
		. += "<br><span style=\"color:red\"><B>[src.name] has a large gaping hole down their chest!</B></span>"
	if (src.bleeding && !isdead(src))
		switch (src.bleeding)
			if (1 to 2)
				. += "<br><span style='color:red'>[src.name] is bleeding a little bit.</span>"
			if (2 to 3)
				. += "<br><span style='color:red'><B>[src.name] is bleeding!</B></span>"
			if (3 to 4)
				. += "<br><span style='color:red'><B>[src.name] is bleeding a lot!</B></span>"
			if (4 to INFINITY)
				. += "<br><span style='color:red'><B>[src.name] is bleeding very badly!</B></span>"
/*			if (1 to 2)
				. += "<br><span style='color:red'>[src.name] is bleeding a little bit.</span>"
			if (3 to 5)
				. += "<br><span style='color:red'><B>[src.name] is bleeding!</B></span>"
			if (6 to 8)
				. += "<br><span style='color:red'><B>[src.name] is bleeding a lot!</B></span>"
			if (9 to INFINITY)
				. += "<br><span style='color:red'><B>[src.name] is bleeding very badly!</B></span>"
*/
	if (!isvampire(src)) // Added a check for vampires (Convair880).
		src.ensure_bp_list()
		switch (src.blood_pressure["total"])
			if (-INFINITY to 0) // welp
				. += "<br><span style='color:red'><B>[src.name] is pale as a ghost!</B></span>"
			if (1 to 374) // very low (90/60)
				. += "<br><span style='color:red'><B>[src.name] is very pale!</B></span>"
			if (374 to 414) // low (100/65)
				. += "<br><span style='color:red'><B>[src.name] is pale.</B></span>"
			if (585 to 666) // high (140/90)
				. += "<br><span style='color:red'>[src.name] is a little sweaty and red in the face.</span>"
			if (666 to 750) // very high (160/100)
				. += "<br><span style='color:red'><B>[src.name] is very sweaty and red in the face!</B></span>"
			if (750 to 1500) // critically high (180/110)
				. += "<br><span style='color:red'><B>[src.name] is sweating like a pig and red as a tomato!</B></span>"
			if (1500 to INFINITY) // critically high (180/110)
				. += "<br><span style='color:red'><B>[src.name] is sweating like a pig and red as a tomato!</B></span>"

	var/changeling_fakedeath = 0
	var/datum/abilityHolder/changeling/C = get_ability_holder(/datum/abilityHolder/changeling)
	if (C && C.in_fakedeath)
		changeling_fakedeath = 1

	if ((isdead(src)) || changeling_fakedeath || (src.reagents.has_reagent("capulettium") && src.getStatusDuration("paralysis")) || (src.reagents.has_reagent("capulettium_plus") && src.getStatusDuration("weakened")))
		if (!src.decomp_stage)
			. += "<br><span style='color:red'>[src] is limp and unresponsive, a dull lifeless look in [t_his] eyes.</span>"
	else
		var/brute = src.get_brute_damage()
		if (brute >= 5)
			if (brute < 30)
				. += "<br><span style='color:red'>[src.name] looks a little injured.</span>"
			else
				. += "<br><span style='color:red'><B>[src.name] looks severely injured!</B></span>"

		var/burn = src.get_burn_damage()
		if (burn >= 5)
			if (burn < 30)
				. += "<br><span style='color:red'>[src.name] looks a little burnt.</span>"
			else
				. += "<br><span style='color:red'><B>[src.name] looks severely burned!</B></span>"

		if (src.stat)
			. += "<br><span style='color:red'>[src.name] doesn't seem to be responding to anything around [t_him], [t_his] eyes closed as though asleep.</span>"
		else
			if (src.get_brain_damage() >= 60)
				. += "<br><span style='color:red'>[src.name] has a blank expression on [his_or_her(src)] face.</span>"

			if (!src.client)
				. += "<br>[src.name] seems to be staring blankly into space."

	switch (src.decomp_stage)
		if (1)
			. += "<br><span style='color:red'>[src] looks bloated and smells a bit rotten!</span>"
		if (2)
			. += "<br><span style='color:red'>[src]'s flesh is starting to rot away from [t_his] bones!</span>"
		if (3)
			. += "<br><span style='color:red'>[src]'s flesh is almost completely rotten away, revealing parts of [t_his] skeleton!</span>"
		if (4)
			. += "<br><span style='color:red'>[src]'s remains are completely skeletonized.</span>"

	if(usr.traitHolder && (usr.traitHolder.hasTrait("observant") || istype(usr, /mob/dead/observer)))
		if(src.traitHolder && src.traitHolder.traits.len)
			. += "<br><span style='color:blue'>[src] has the following traits:</span>"
			for(var/X in src.traitHolder.traits)
				var/obj/trait/T = getTraitById(X)
				. += "<br><span style='color:blue'>[T.cleanName]</span>"
		else
			. += "<br><span style='color:blue'>[src] does not appear to possess any special traits.</span>"

	if (src.juggling())
		var/items = ""
		var/count = 0
		for (var/obj/O in src.juggling)
			count ++
			if (src.juggling.len > 1 && count == src.juggling.len)
				items += " and [O]"
				continue
			items += ", [O]"
		items = copytext(items, 3)
		. += "<br><span style='color:blue'>[src] is juggling [items]!</span>"

	. += "<br><span style='color:blue'>*---------*</span>"

	if (get_dist(usr, src) < 4 && ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if (istype(H.glasses, /obj/item/clothing/glasses/healthgoggles))
			var/obj/item/clothing/glasses/healthgoggles/G = H.glasses
			if (G.scan_upgrade && G.health_scan)
				. += "<br><span style='color: red'>Your ProDocs analyze [src]'s vitals.</span><br>[scan_health(src, 0, 0)]"
			update_medical_record(src)
		else if (H.organ_istype("left_eye", /obj/item/organ/eye/cyber/prodoc) && H.organ_istype("right_eye", /obj/item/organ/eye/cyber/prodoc)) // two prodoc eyes = scan upgrade because that's cool
			. += "<br><span style='color: red'>Your ProDocs analyze [src]'s vitals.</span><br>[scan_health(src, 0, 0)]"
			update_medical_record(src)
