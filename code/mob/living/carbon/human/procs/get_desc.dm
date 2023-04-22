
/mob/living/carbon/human/get_desc()

	var/ignore_checks = isobserver(usr)
	var/examine_stopper = src.bioHolder?.HasEffect("examine_stopper")
	if (!ignore_checks && examine_stopper && GET_DIST(usr.client.eye, src) > 3 - 2 * examine_stopper)
		return "<br><span class='alert'>You can't seem to make yourself look at [src.name] long enough to observe anything!</span>"

	if (src.simple_examine || isghostdrone(usr))
		return

	if (!usr.client.eye)
		return // heh

	. = list()
	if (isalive(usr))
		. += "<br><span class='notice'>You look closely at <B>[src.name]</B>.</span>"
		sleep(GET_DIST(usr.client.eye, src) + 1)
		if (!usr.client.eye)
			return // heh heh

	if (!istype(usr, /mob/dead/target_observer))
		if (!ignore_checks && (GET_DIST(usr.client.eye, src) > 7 && (!usr.client || !usr.client.eye || !usr.client.holder || usr.client.holder.state != 2)))
			return "[jointext(., "")]<br><span class='alert'><B>[src.name]</B> is too far away to see clearly.</span>"

	if(src.face_visible() && src.bioHolder.mobAppearance.flavor_text)
		try
			. = "<br>[src.bioHolder.mobAppearance.flavor_text]"
		catch
			//nop

	. +=  "<br><span class='notice'>*---------*</span>"

	// crappy hack because you can't do \his[src] etc
	var/t_his = his_or_her(src)
	var/t_him = him_or_her(src)

	var/datum/ailment_data/found = src.find_ailment_by_type(/datum/ailment/disability/memetic_madness)
	if (!ignore_checks && found)
		if (!ishuman(usr))
			. += "<br><span class='alert'>You can't focus on [t_him], it's like looking through smoked glass.</span>"
			return jointext(., "")
		else
			var/mob/living/carbon/human/H = usr
			var/datum/ailment_data/memetic_madness/MM = H.find_ailment_by_type(/datum/ailment/disability/memetic_madness)
			if (istype(MM) && istype(MM.master,/datum/ailment/disability/memetic_madness))
				H.contract_memetic_madness(MM.progenitor)
				return jointext(., "")

			. += "<br><span class='notice'>A servant of His Grace...</span>"

	// unfortunately byond can't handle "[src.slot.blood_DNA ? "a bloody" : "\an"] [src.slot.name]" because then the \an is like "where the fuck is the thing I'm supposed to do something to???"
	// thanks, byondbama.
	if (src.hasStatus("handcuffed"))
		. +=  "<br><b class='alert'>[src.name] is [bicon(src.handcuffs)] handcuffed!</b>"

	if (src.w_uniform && !(src.wear_suit?.hides_from_examine & C_UNIFORM))
		. += "<br><span class='[src.w_uniform.blood_DNA ? "alert" : "notice"]'>[src.name] is wearing [bicon(src.w_uniform)] \an [src.w_uniform.name].</span>"

	if (src.wear_suit)
		. += "<br><span class='[src.wear_suit.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.wear_suit)] \an [src.wear_suit.name] on.</span>"

	if (src.ears && !(src.wear_suit?.hides_from_examine & C_EARS) && !(src.head?.hides_from_examine & C_EARS))
		if (istype(src.ears, /obj/item/clothing/))
			. += "<br><span class='[src.ears.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.ears)] \an [src.ears.name] by [t_his] mouth.</span>"
		else
			. += "<br><span class='[src.ears.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.ears)] [src.ears.blood_DNA ? "a bloody [src.ears.name]" : "\an [src.ears.name]"] by [t_his] mouth.</span>"

	if (src.head)
		. += "<br><span class='[src.head.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.head)] \an [src.head.name] on [t_his] head.</span>"

	if (src.wear_mask && !(src.wear_suit?.hides_from_examine & C_MASK) && !(src.head?.hides_from_examine & C_MASK))
		if (istype(src.l_hand, /obj/item/clothing/))
			. += "<br><span class='[src.wear_mask.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.wear_mask)] [src.wear_mask.blood_DNA ? "a bloody [src.wear_mask.name]" : "\an [src.wear_mask.name]"] on [t_his] face.</span>"
		else
			. += "<br><span class='[src.wear_mask.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.wear_mask)] \an [src.wear_mask.name] on [t_his] face.</span>"

	if (src.glasses && !(src.wear_suit?.hides_from_examine & C_GLASSES) && !(src.head?.hides_from_examine & C_GLASSES))
		if (face_visible())
			. += "<br><span class='[src.glasses.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.glasses)] \an [src.glasses.name] on [t_his] face.</span>"

	if (src.l_hand)
		if (istype(src.l_hand, /obj/item/clothing/))
			. += "<br><span class='[src.l_hand.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.l_hand)] \an [src.l_hand.name] in [t_his] left hand.</span>"
		else
			. += "<br><span class='[src.l_hand.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.l_hand)] [src.l_hand.blood_DNA ? "a bloody [src.l_hand.name]" : "\an [src.l_hand.name]"] in [t_his] left hand.</span>"

	if (src.r_hand)
		if (istype(src.r_hand, /obj/item/clothing/))
			. += "<br><span class='[src.r_hand.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.r_hand)] \an [src.r_hand.name] in [t_his] right hand.</span>"
		else
			. += "<br><span class='[src.r_hand.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.r_hand)] [src.r_hand.blood_DNA ? "a bloody [src.r_hand.name]" : "\an [src.r_hand.name]"] in [t_his] right hand.</span>"

	if (src.belt)
		. += "<br><span class='[src.belt.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.belt)] [src.belt.blood_DNA ? "a bloody [src.belt.name]" : "\an [src.belt.name]"] on [t_his] belt.</span>"

	if (src.gloves && !src.gloves.nodescripition)
		if(!(src.wear_suit && src.wear_suit?.hides_from_examine & C_GLOVES))
			. += "<br><span class='[src.gloves.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.gloves)] [src.gloves.name] on [t_his] hands.</span>"
	else if (src.blood_DNA)
		. += "<br><span class='alert'>[src.name] has bloody hands!</span>"

	if (src.shoes && !(src.wear_suit?.hides_from_examine & C_SHOES))
		. += "<br><span class='[src.shoes.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.shoes)] [src.shoes.name] on [t_his] feet.</span>"
	else if (islist(src.tracked_blood))
		. += "<br><span class='alert'>[src.name] has bloody feet!</span>"

	if (src.back)
		. += "<br><span class='[src.back.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.back)] [src.back.blood_DNA ? "a bloody [src.back.name]" : "\an [src.back.name]"] on [t_his] back.</span>"

	if (src.wear_id)
		if (istype(src.wear_id, /obj/item/card/id))
			if (src.wear_id:registered != src.real_name && in_interact_range(src, usr) && prob(10))
				. += "<br><span class='alert'>[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name] yet doesn't seem to be that person!!!</span>"
			else
				. += "<br><span class='notice'>[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name].</span>"
		else if (istype(src.wear_id, /obj/item/device/pda2) && src.wear_id:ID_card)
			if (src.wear_id:ID_card:registered != src.real_name && in_interact_range(src, usr) && prob(10))
				. += "<br><span class='alert'>[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name] with [bicon(src.wear_id:ID_card)] [src.wear_id:ID_card:name] in it yet doesn't seem to be that person!!!</span>"
			else
				. += "<br><span class='notice'>[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name] with [bicon(src.wear_id:ID_card)] [src.wear_id:ID_card:name] in it.</span>"

	if (src.arrestIcon?.icon_state)
		if(global.client_image_groups?[CLIENT_IMAGE_GROUP_ARREST_ICONS]?.subscribed_mobs_with_subcount[usr]) // are you in the list of people who can see arrest icons??
			var/datum/db_record/sec_record = data_core.security.find_record("name", src.name)
			if(sec_record)
				var/sechud_flag = sec_record["sec_flag"]
				if (lowertext(sechud_flag) != "none")
					. += "<br><span class='notice'>[src.name] has a Security HUD flag set:</span> <span class='alert'>[sechud_flag]</span>"

	if (locate(/obj/item/implant/projectile/body_visible/dart) in src.implant)
		var/count = 0
		for (var/obj/item/implant/projectile/body_visible/dart/P in src.implant)
			count++
		. += "<br><span class='alert'>[src] has [count > 1 ? "darts" : "a dart"] stuck in them!</span>"

	if (locate(/obj/item/implant/projectile/body_visible/syringe) in src.implant)
		var/count = 0
		for (var/obj/item/implant/projectile/body_visible/syringe/P in src.implant)
			count++
		. += "<br><span class='alert'>[src] has [count > 1 ? "syringes" : "a syringe"] stuck in them!</span>"

	if (locate(/obj/item/implant/projectile/body_visible/arrow) in src.implant)
		var/count = 0
		for (var/obj/item/implant/projectile/body_visible/arrow/P in src.implant)
			count++
		. += "<br><span class='alert'>[src] has [count > 1 ? "arrows" : "an arrow"] stuck in them!</span>"

	if (src.is_jittery)
		switch(src.jitteriness)
			if (300 to INFINITY)
				. += "<br><span class='alert'>[src] is violently convulsing.</span>"
			if (200 to 300)
				. += "<br><span class='alert'>[src] looks extremely jittery.</span>"
			if (100 to 200)
				. += "<br><span class='alert'>[src] is twitching ever so slightly.</span>"

	if (src.organHolder)
		if (src.organHolder.head)
			if (face_visible())
				if (!src.organHolder.skull)
					. += "<br><span class='alert'><B>[src.name] no longer has a skull in [t_his] head, [t_his] face is just empty skin mush!</B></span>"

				if (!src.organHolder.right_eye && !src.organHolder.left_eye)
					. += "<br><span class='alert'><B>[src.name]'s eyes are missing!</B></span>"
				else
					if (!src.organHolder.left_eye)
						. += "<br><span class='alert'><B>[src.name]'s left eye is missing!</B></span>"
					else if (src.organHolder.left_eye.show_on_examine)
						. += "<br><span class='notice'>[src.name] has [bicon(src.organHolder.left_eye)] \an [src.organHolder.left_eye.organ_name] in [t_his] left eye socket.</span>"
					if (!src.organHolder.right_eye)
						. += "<br><span class='alert'><B>[src.name]'s right eye is missing!</B></span>"
					else if (src.organHolder.right_eye.show_on_examine)
						. += "<br><span class='notice'>[src.name] has [bicon(src.organHolder.right_eye)] \an [src.organHolder.right_eye.organ_name] in [t_his] right eye socket.</span>"

				if (src.organHolder.head.scalp_op_stage > 0)
					if (src.organHolder.head.scalp_op_stage >= 5.0)
						if (!src.organHolder.skull)
							. += "<br><span class='alert'><B>There's a gaping hole in [src.name]'s head and [t_his] skull is gone!</B></span>"
						else if (!src.organHolder.brain)
							. += "<br><span class='alert'><B>There's a gaping hole in [src.name]'s head and [t_his] brain is gone!</B></span>"
						else
							. += "<br><span class='alert'><B>There's a gaping hole in [src.name]'s head!</B></span>"
					else if (src.organHolder.head.scalp_op_stage >= 4.0)
						if (!src.organHolder.brain)
							. += "<br><span class='alert'><B>[src.name]'s head has been cut open and [t_his] brain is gone!</B></span>"
						else
							. += "<br><span class='alert'><B>[src.name]'s head has been cut open!</B></span>"
					else
						. += "<br><span class='alert'><B>[src.name] has an open incision on [t_his] head!</B></span>"

				if (src.organHolder.head.op_stage > 0.0)
					if (src.organHolder.head.op_stage >= 3.0)
						. += "<br><span class='alert'><B>[src.name]'s head is barely attached!</B></span>"
					else
						. += "<br><span class='alert'><B>[src.name] has a huge incision across [t_his] neck!</B></span>"

		else
			. += "<br><span class='alert'><B>[src.name] has been decapitated!</B></span>"


		if (src.organHolder.chest)
			if (src.organHolder.chest.op_stage > 0.0)
				if (src.organHolder.chest.op_stage < 9.0)
					. += "<br><span class='alert'><B>[src.name] has an indeterminate number of small surgical scars on [t_his] chest!</B></span>"
				if (src.organHolder.chest.op_stage >= 9.0 && src.organHolder.chest.op_stage < 10.0)
					if (src.organHolder.heart)
						. += "<br><span class='alert'><B>[src.name]'s chest is cut wide open!</B></span>"
					else
						. += "<br><span class='alert'><B>[src.name]'s chest is cut wide open and [t_his] heart has been removed!</B></span>"
				else if(src.organHolder.chest.op_stage > 0.0)
					. += "<br><span class='alert'><B>[src.name] has an indeterminate number of small surgical scars on [t_his] chest!</B></span>"

			//tailstuff
			if (src.organHolder.tail) // Has a tail?
				// Comment if their tail deviates from the norm.
				if (src.organHolder.tail && (!(src.mob_flags & SHOULD_HAVE_A_TAIL) || src.organHolder.tail?.donor_original != src))
					if (!src.organHolder.butt) // no butt?
						. += "<br><span class='notice'>[src.name] has [src.organHolder.tail.name] attached just above the spot where [t_his] butt should be.</span>"
					else
						. += "<br><span class='notice'>[src.name] has [src.organHolder.tail.name] attached just above [t_his] butt.</span>"
				// don't bother telling people that you have the tail you're supposed to have. nobody congratulates me for having all my legs
				if (src.organHolder.chest.op_stage >= 10.0 && src.mob_flags & ~IS_BONEY) // assive ass wound? and not a skeleton?
					. += "<br><span class='alert'><B>[src.name] has a long incision around the base of [t_his] tail!</B></span>"

			else // missing a tail?
				if (src.organHolder.chest.op_stage >= 10.0) // first person to call this a tailhole is getting dropkicked into the sun
					if (src.mob_flags & SHOULD_HAVE_A_TAIL) // Are they supposed to have a tail?
						if (!src.organHolder.butt) // Also missing a butt?
							. += "<br><span class='alert'><B>[src.name] has a large incision at the base of [t_his] back where [t_his] tail should be!</B></span>"
						else // has butt
							. += "<br><span class='alert'><B>[src.name] has a large incision above [t_his] butt where [t_his] tail should be!</B></span>"
					else // Do they normally not have a tail?
						if (!src.organHolder.butt) // Also missing a butt?
							. += "<br><span class='alert'><B>[src.name] has a large incision at the base of [t_his] back!</B></span>"
						else // has butt
							. += "<br><span class='alert'><B>[src.name] has a large incision above [t_his] butt!</B></span>"
				else if (src.mob_flags & SHOULD_HAVE_A_TAIL) // No tail, no ass wound? Supposed to have a tail?
					. += "<br><span class='alert'><B>[src.name] is missing [t_his] tail!</B></span>" // oh no my tails gone!!
					// Commenting on someone not having a tail when they shouldnt have a tail will be left up to the player
		else
			. += "<br><span class='alert'><B>[src.name]'s entire chest is missing!</B></span>"


		if (src.butt_op_stage > 0)
			if (src.butt_op_stage >= 4)
				. += "<br><span class='alert'><B>[src.name]'s butt seems to be missing!</B></span>"
			else
				. += "<br><span class='alert'><B>[src.name] has an open incision on [t_his] butt!</B></span>"

	if (src.limbs)
		if (!src.limbs.l_arm)
			. += "<br><span class='alert'><B>[src.name]'s left arm is completely severed!</B></span>"
		else
			var/limbtxt = src.limbs.l_arm.on_holder_examine()
			if (limbtxt)
				. += "<br><span class='notice'>[src.name] [limbtxt] left arm.</span>"

		if (!src.limbs.r_arm)
			. += "<br><span class='alert'><B>[src.name]'s right arm is completely severed!</B></span>"
		else
			var/limbtxt = src.limbs.r_arm.on_holder_examine()
			if (limbtxt)
				. += "<br><span class='notice'>[src.name] [limbtxt] right arm.</span>"

		if (!src.limbs.l_leg)
			. += "<br><span class='alert'><B>[src.name]'s left leg is completely severed!</B></span>"
		else
			var/limbtxt = src.limbs.l_leg.on_holder_examine()
			if (limbtxt)
				. += "<br><span class='notice'>[src.name] [limbtxt] left leg.</span>"

		if (!src.limbs.r_leg)
			. += "<br><span class='alert'><B>[src.name]'s right leg is completely severed!</B></span>"
		else
			var/limbtxt = src.limbs.r_leg.on_holder_examine()
			if (limbtxt)
				. += "<br><span class='notice'>[src.name] [limbtxt] right leg.</span>"
	if (src.chest_cavity_open)
		. += "<br><span class='alert'><B>[src.name] has a large gaping hole down [t_his] chest!</B></span>"
	if (src.bleeding && !isdead(src))
		switch (src.bleeding)
			if (1 to 2)
				. += "<br><span class='alert'>[src.name] is bleeding a little bit.</span>"
			if (2 to 3)
				. += "<br><span class='alert'><B>[src.name] is bleeding!</B></span>"
			if (3 to 4)
				. += "<br><span class='alert'><B>[src.name] is bleeding a lot!</B></span>"
			if (4 to INFINITY)
				. += "<br><span class='alert'><B>[src.name] is bleeding very badly!</B></span>"
/*			if (1 to 2)
				. += "<br><span class='alert'>[src.name] is bleeding a little bit.</span>"
			if (3 to 5)
				. += "<br><span class='alert'><B>[src.name] is bleeding!</B></span>"
			if (6 to 8)
				. += "<br><span class='alert'><B>[src.name] is bleeding a lot!</B></span>"
			if (9 to INFINITY)
				. += "<br><span class='alert'><B>[src.name] is bleeding very badly!</B></span>"
*/
	if (!isvampire(src)) // Added a check for vampires (Convair880).
		switch (src.blood_pressure["total"])
			if (-INFINITY to 0) // welp
				. += "<br><span class='alert'><B>[src.name] is pale as a ghost!</B></span>"
			if (1 to 299) // very low (70/50)
				. += "<br><span class='alert'><B>[src.name] is very pale!</B></span>"
			if (300 to 414) // low (100/65)
				. += "<br><span class='alert'><B>[src.name] is pale.</B></span>"
			if (585 to 666) // high (140/90)
				. += "<br><span class='alert'>[src.name] is a little sweaty and red in the face.</span>"
			if (666 to 750) // very high (160/100)
				. += "<br><span class='alert'><B>[src.name] is very sweaty and red in the face!</B></span>"
			if (750 to 1500) // critically high (180/110)
				. += "<br><span class='alert'><B>[src.name] is sweating like a pig and red as a tomato!</B></span>"
			if (1500 to INFINITY) // critically high (180/110)
				. += "<br><span class='alert'><B>[src.name] is sweating like a pig and red as a tomato!</B></span>"

	var/changeling_fakedeath = 0
	var/datum/abilityHolder/changeling/C = get_ability_holder(/datum/abilityHolder/changeling)
	if (C?.in_fakedeath)
		changeling_fakedeath = 1

	if ((isdead(src)) || changeling_fakedeath || src.bioHolder?.HasEffect("dead_scan") == 2 || (src.reagents.has_reagent("capulettium") && src.getStatusDuration("weakened")) || (src.reagents.has_reagent("capulettium_plus") && src.hasStatus("resting")))
		if (!src.decomp_stage)
			. += "<br><span class='alert'>[src] is limp and unresponsive, a dull lifeless look in [t_his] eyes.</span>"
	else
		var/brute = src.get_brute_damage()
		if (brute >= 5)
			if (brute < 30)
				. += "<br><span class='alert'>[src.name] looks a little injured.</span>"
			else
				. += "<br><span class='alert'><B>[src.name] looks severely injured!</B></span>"

		var/burn = src.get_burn_damage()
		if (burn >= 5)
			if (burn < 30)
				. += "<br><span class='alert'>[src.name] looks a little burnt.</span>"
			else
				. += "<br><span class='alert'><B>[src.name] looks severely burned!</B></span>"

		if (src.stat)
			. += "<br><span class='alert'>[src.name] doesn't seem to be responding to anything around [t_him], [t_his] eyes closed as though asleep.</span>"
		else
			if (src.get_brain_damage() >= 60)
				. += "<br><span class='alert'>[src.name] has a blank expression on [his_or_her(src)] face.</span>"

			if (!src.client && !src.ai_active)
				var/using_vr_goggles = FALSE
				var/mob = find_player(src.last_ckey)?.client?.mob

				if (istype(mob, /mob/living/carbon/human/virtual))
					var/mob/living/carbon/human/virtual/vr_person = mob
					if (!vr_person.isghost) // rare but can happen if you leave your body while alive, and then decide to go into vr as a ghost
						using_vr_goggles = TRUE
				else if (istype(mob, /mob/living/critter/robotic/scuttlebot))
					var/mob/living/critter/robotic/scuttlebot/scuttlebot = mob
					if (scuttlebot.controller == src) // in case you mindswap into a scuttlebot
						using_vr_goggles = TRUE

				if (using_vr_goggles)
					if (!(src.wear_suit?.hides_from_examine & C_GLASSES) && !(src.head?.hides_from_examine & C_GLASSES))
						. += "<br><span style='color:#8600C8'>[src.name]'s mind is elsewhere.</span>"
				else
					. += "<br>[src.name] seems to be staring blankly into space."

	switch (src.decomp_stage)
		if (DECOMP_STAGE_BLOATED)
			. += "<br><span class='alert'>[src] looks bloated and smells a bit rotten!</span>"
		if (DECOMP_STAGE_DECAYED)
			. += "<br><span class='alert'>[src]'s flesh is starting to rot away from [t_his] bones!</span>"
		if (DECOMP_STAGE_HIGHLY_DECAYED)
			. += "<br><span class='alert'>[src]'s flesh is almost completely rotten away, revealing parts of [t_his] skeleton!</span>"
		if (DECOMP_STAGE_SKELETONIZED)
			. += "<br><span class='alert'>[src]'s remains are completely skeletonized.</span>"

	if(usr.traitHolder && (usr.traitHolder.hasTrait("observant") || istype(usr, /mob/dead/observer)))
		if(src.traitHolder && length(src.traitHolder.traits))
			. += "<br><span class='notice'>[src] has the following traits:</span>"
			for(var/id in src.traitHolder.traits)
				var/datum/trait/T = src.traitHolder.traits[id]
				. += "<br><span class='notice'>[T.name]</span>"
		else
			. += "<br><span class='notice'>[src] does not appear to possess any special traits.</span>"

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
		. += "<br><span class='notice'>[src] is juggling [items]!</span>"

	. += "<br><span class='notice'>*---------*</span>"

	if (GET_DIST(usr, src) < 4)
		if (GET_ATOM_PROPERTY(usr,PROP_MOB_EXAMINE_HEALTH))
			. += "<br><span class='alert'>You analyze [src]'s vitals.</span><br>[scan_health(src, 0, 0, syndicate = GET_ATOM_PROPERTY(usr,PROP_MOB_EXAMINE_HEALTH_SYNDICATE))]"
			scan_health_overhead(src, usr)
			update_medical_record(src)

	return jointext(., "")
