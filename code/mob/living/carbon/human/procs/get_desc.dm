
/mob/living/carbon/human/get_desc(ignore_all_checks, skip_afk_check)

	var/ignore_checks = isobserver(usr) || ignore_all_checks
	var/examine_stopper = src.bioHolder?.HasEffect("examine_stopper")
	if (!ignore_checks && examine_stopper && GET_DIST(usr.client.eye, src) > 3 - 2 * examine_stopper)
		return "<br>[SPAN_ALERT("You can't seem to make yourself look at [src.name] long enough to observe anything!")]"

	if (src.simple_examine || isghostdrone(usr))
		return

	if (!usr.client.eye)
		return // heh

	. = list()
	. += ..()
	if (isalive(usr))
		. += "<br>[SPAN_NOTICE("You look closely at <B>[src.name] ([src.get_pronouns()])</B>.")]"

	if (!isobserver(usr) && !isintangible(usr))
		if (!ignore_checks && (GET_DIST(usr.client.eye, src) > 7 && (!usr.client || !usr.client.eye || !usr.client.holder || usr.client.holder.state != 2)))
			return "[jointext(., "")]<br>[SPAN_ALERT("<B>[src.name]</B> is too far away to see clearly.")]"

	if(src.face_visible() && src.bioHolder?.mobAppearance.flavor_text)
		var/disguisered = FALSE
		for (var/obj/item/device/disguiser/D in src)
			disguisered |= D.active
			if (disguisered)
				break
		if(!disguisered)
			. = "<br>[src.bioHolder.mobAppearance.flavor_text]"

	// crappy hack because you can't do \his[src] etc
	var/t_his = his_or_her(src)
	var/t_him = him_or_her(src)

	. +=  "<br>[SPAN_NOTICE("*---------*")]"
	var/datum/ailment_data/found = src.find_ailment_by_type(/datum/ailment/disability/memetic_madness)
	if (!ignore_checks && found)
		if (!ishuman(usr))
			. += "<br>[SPAN_ALERT("You can't focus on [t_him], it's like looking through smoked glass.")]"
			return jointext(., "")
		else
			var/mob/living/carbon/human/H = usr
			var/datum/ailment_data/memetic_madness/MM = H.find_ailment_by_type(/datum/ailment/disability/memetic_madness)
			if (istype(MM) && istype(MM.master,/datum/ailment/disability/memetic_madness))
				H.contract_memetic_madness(MM.progenitor)
				return jointext(., "")

			. += "<br>[SPAN_NOTICE("A servant of His Grace...")]"

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
		. += "<br>[SPAN_ALERT("[src.name] has bloody hands!")]"

	if (src.shoes && !(src.wear_suit?.hides_from_examine & C_SHOES))
		. += "<br><span class='[src.shoes.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.shoes)] [src.shoes.name] on [t_his] feet.</span>"
	else if (islist(src.tracked_blood))
		. += "<br>[SPAN_ALERT("[src.name] has bloody feet!")]"

	if (src.back)
		. += "<br><span class='[src.back.blood_DNA ? "alert" : "notice"]'>[src.name] has [bicon(src.back)] [src.back.blood_DNA ? "a bloody [src.back.name]" : "\an [src.back.name]"] on [t_his] back.</span>"

	if (src.wear_id)
		if (istype(src.wear_id, /obj/item/card/id))
			if (src.wear_id:registered != src.real_name && in_interact_range(src, usr) && prob(10))
				. += "<br>[SPAN_ALERT("[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name] yet doesn't seem to be that person!!!")]"
			else
				. += "<br>[SPAN_NOTICE("[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name].")]"
		else if ((istype(src.wear_id, /obj/item/device/pda2) && src.wear_id:ID_card) || istype(src.wear_id, /obj/item/clothing/lanyard))
			var/obj/item/card/id/desc_id_card
			if (istype(src.wear_id, /obj/item/clothing/lanyard))
				var/obj/item/clothing/lanyard/lanyard = src.wear_id
				desc_id_card = lanyard.get_stored_id()
			else
				desc_id_card = src.wear_id:ID_card
			if (desc_id_card)
				if (desc_id_card.registered != src.real_name && in_interact_range(src, usr) && prob(10))
					. += "<br>[SPAN_ALERT("[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name] with [bicon(desc_id_card)] [desc_id_card.name] in it yet doesn't seem to be that person!!!")]"
				else
					. += "<br>[SPAN_NOTICE("[src.name] is wearing [bicon(src.wear_id)] [src.wear_id.name] with [bicon(desc_id_card)] [desc_id_card.name] in it.")]"

	if(global.client_image_groups?[CLIENT_IMAGE_GROUP_ARREST_ICONS]?.subscribed_mobs_with_subcount[usr]) // are you in the list of people who can see arrest icons??
		var/datum/db_record/sec_record = data_core.security.find_record("name", src.name)
		if(sec_record)
			var/sechud_flag = sec_record["sec_flag"]
			if (lowertext(sechud_flag) != "none")
				. += "<br>[SPAN_NOTICE("[src.name] has a Security HUD flag set:")] [SPAN_ALERT("[sechud_flag]")]"

	if (locate(/obj/item/implant/projectile/body_visible/dart) in src.implant)
		var/count = 0
		for (var/obj/item/implant/projectile/body_visible/dart/P in src.implant)
			count++
		. += "<br>[SPAN_ALERT("[src] has [count > 1 ? "darts" : "a dart"] stuck in [him_or_her(src)]!")]"

	if (locate(/obj/item/implant/projectile/body_visible/syringe) in src.implant)
		var/count = 0
		for (var/obj/item/implant/projectile/body_visible/syringe/P in src.implant)
			count++
		. += "<br>[SPAN_ALERT("[src] has [count > 1 ? "syringes" : "a syringe"] stuck in [him_or_her(src)]!")]"

	if (locate(/obj/item/implant/projectile/body_visible/arrow) in src.implant)
		var/count = 0
		for (var/obj/item/implant/projectile/body_visible/arrow/P in src.implant)
			count++
		. += "<br>[SPAN_ALERT("[src] has [count > 1 ? "arrows" : "an arrow"] stuck in [him_or_her(src)]!")]"

	if (locate(/obj/item/implant/projectile/body_visible/seed) in src.implant)
		var/count = 0
		for (var/obj/item/implant/projectile/body_visible/seed/P in src.implant)
			count++
		. += "<br>[SPAN_ALERT("[src] has [count > 1 ? "seeds" : "a seed"] stuck in [him_or_her(src)]!")]"

	if (src.is_jittery)
		switch(src.jitteriness)
			if (300 to INFINITY)
				. += "<br>[SPAN_ALERT("[src] is violently convulsing.")]"
			if (200 to 300)
				. += "<br>[SPAN_ALERT("[src] looks extremely jittery.")]"
			if (100 to 200)
				. += "<br>[SPAN_ALERT("[src] is twitching ever so slightly.")]"

	if (src.organHolder)
		if (src.organHolder.head)
			if (face_visible())
				if (!src.organHolder.skull)
					. += "<br>[SPAN_ALERT("<B>[src.name] no longer has a skull in [t_his] head, [t_his] face is just empty skin mush!</B>")]"

				if (!src.organHolder.right_eye && !src.organHolder.left_eye)
					. += "<br>[SPAN_ALERT("<B>[src.name]'s eyes are missing!</B>")]"
				else
					if (!src.organHolder.left_eye)
						. += "<br>[SPAN_ALERT("<B>[src.name]'s left eye is missing!</B>")]"
					else if (src.organHolder.left_eye.show_on_examine)
						. += "<br>[SPAN_NOTICE("[src.name] has [bicon(src.organHolder.left_eye)] \an [src.organHolder.left_eye.organ_name] in [t_his] left eye socket.")]"
					if (!src.organHolder.right_eye)
						. += "<br>[SPAN_ALERT("<B>[src.name]'s right eye is missing!</B>")]"
					else if (src.organHolder.right_eye.show_on_examine)
						. += "<br>[SPAN_NOTICE("[src.name] has [bicon(src.organHolder.right_eye)] \an [src.organHolder.right_eye.organ_name] in [t_his] right eye socket.")]"

				if (src.organHolder.head.scalp_op_stage > 0)
					if (src.organHolder.head.scalp_op_stage >= 5.0)
						if (!src.organHolder.skull)
							. += "<br>[SPAN_ALERT("<B>There's a gaping hole in [src.name]'s head and [t_his] skull is gone!</B>")]"
						else if (!src.organHolder.brain)
							. += "<br>[SPAN_ALERT("<B>There's a gaping hole in [src.name]'s head and [t_his] brain is gone!</B>")]"
						else
							. += "<br>[SPAN_ALERT("<B>There's a gaping hole in [src.name]'s head!</B>")]"
					else if (src.organHolder.head.scalp_op_stage >= 4.0)
						if (!src.organHolder.brain)
							. += "<br>[SPAN_ALERT("<B>[src.name]'s head has been cut open and [t_his] brain is gone!</B>")]"
						else
							. += "<br>[SPAN_ALERT("<B>[src.name]'s head has been cut open!</B>")]"
					else
						. += "<br>[SPAN_ALERT("<B>[src.name] has an open incision on [t_his] head!</B>")]"

				if (src.organHolder.head.op_stage > 0.0)
					if (src.organHolder.head.op_stage >= 3.0)
						. += "<br>[SPAN_ALERT("<B>[src.name]'s head is barely attached!</B>")]"
					else
						. += "<br>[SPAN_ALERT("<B>[src.name] has a huge incision across [t_his] neck!</B>")]"

		else
			. += "<br>[SPAN_ALERT("<B>[src.name] has been decapitated!</B>")]"


		if (src.organHolder.chest)
			if (src.organHolder.chest.op_stage > 0.0)
				if (src.organHolder.chest.op_stage < 2.0)
					. += "<br>[SPAN_ALERT("<B>[src.name] has an indeterminate number of small surgical scars on [t_his] chest!</B>")]"
				if (src.organHolder.chest.op_stage >= 2.0)
					if (src.organHolder.heart)
						. += "<br>[SPAN_ALERT("<B>[src.name]'s chest is cut wide open!</B>")]"
					else
						. += "<br>[SPAN_ALERT("<B>[src.name]'s chest is cut wide open and [t_his] heart has been removed!</B>")]"
					if (!src.chest_cavity_clamped)
						. += "<br>[SPAN_ALERT("<B>Blood is slowly seeping out of [src.name]'s un-clamped chest wound.</B>")]"
			//tailstuff
			if (src.organHolder.tail) // Has a tail?
				// Comment if their tail deviates from the norm.
				if (src.organHolder.tail && (!(src.mob_flags & SHOULD_HAVE_A_TAIL) || src.organHolder.tail?.donor_original != src))
					if (!src.organHolder.butt) // no butt?
						. += "<br>[SPAN_NOTICE("[src.name] has [src.organHolder.tail.name] attached just above the spot where [t_his] butt should be.")]"
					else
						. += "<br>[SPAN_NOTICE("[src.name] has [src.organHolder.tail.name] attached just above [t_his] butt.")]"
				// don't bother telling people that you have the tail you're supposed to have. nobody congratulates me for having all my legs
				if (src.organHolder.back_op_stage >= BACK_SURGERY_OPENED && src.mob_flags & ~IS_BONEY) // assive ass wound? and not a skeleton?
					. += "<br>[SPAN_ALERT("<B>[src.name] has a long incision around the base of [t_his] tail!</B>")]"

			else // missing a tail?
				if (src.organHolder.back_op_stage >= BACK_SURGERY_OPENED) // first person to call this a tailhole is getting dropkicked into the sun
					if (src.mob_flags & SHOULD_HAVE_A_TAIL) // Are they supposed to have a tail?
						if (!src.organHolder.butt) // Also missing a butt?
							. += "<br>[SPAN_ALERT("<B>[src.name] has a large incision at the base of [t_his] back where [t_his] tail should be!</B>")]"
						else // has butt
							. += "<br>[SPAN_ALERT("<B>[src.name] has a large incision above [t_his] butt where [t_his] tail should be!</B>")]"
					else // Do they normally not have a tail?
						if (!src.organHolder.butt) // Also missing a butt?
							. += "<br>[SPAN_ALERT("<B>[src.name] has a large incision at the base of [t_his] back!</B>")]"
						else // has butt
							. += "<br>[SPAN_ALERT("<B>[src.name] has a large incision above [t_his] butt!</B>")]"
				else if (src.mob_flags & SHOULD_HAVE_A_TAIL) // No tail, no ass wound? Supposed to have a tail?
					. += "<br>[SPAN_ALERT("<B>[src.name] is missing [t_his] tail!</B>")]" // oh no my tails gone!!
					// Commenting on someone not having a tail when they shouldnt have a tail will be left up to the player
		else
			. += "<br>[SPAN_ALERT("<B>[src.name]'s entire chest is missing!</B>")]"

		if (!src.organHolder.butt)
			. += "<br>[SPAN_ALERT("<B>[src.name]'s butt seems to be missing!</B>")]"
		else if (src.organHolder.back_op_stage > BACK_SURGERY_CLOSED)
			. += "<br>[SPAN_ALERT("<B>[src.name] has an open incision on [t_his] butt!</B>")]"

	if (src.limbs)
		if (!src.limbs.l_arm)
			. += "<br>[SPAN_ALERT("<B>[src.name]'s left arm is completely severed!</B>")]"
		else
			var/limbtxt = src.limbs.l_arm.on_holder_examine()
			if (limbtxt)
				. += "<br>[SPAN_NOTICE("[src.name] [limbtxt] left arm.")]"

		if (!src.limbs.r_arm)
			. += "<br>[SPAN_ALERT("<B>[src.name]'s right arm is completely severed!</B>")]"
		else
			var/limbtxt = src.limbs.r_arm.on_holder_examine()
			if (limbtxt)
				. += "<br>[SPAN_NOTICE("[src.name] [limbtxt] right arm.")]"

		if (!src.limbs.l_leg)
			. += "<br>[SPAN_ALERT("<B>[src.name]'s left leg is completely severed!</B>")]"
		else
			var/limbtxt = src.limbs.l_leg.on_holder_examine()
			if (limbtxt)
				. += "<br>[SPAN_NOTICE("[src.name] [limbtxt] left leg.")]"

		if (!src.limbs.r_leg)
			. += "<br>[SPAN_ALERT("<B>[src.name]'s right leg is completely severed!</B>")]"
		else
			var/limbtxt = src.limbs.r_leg.on_holder_examine()
			if (limbtxt)
				. += "<br>[SPAN_NOTICE("[src.name] [limbtxt] right leg.")]"
	if (src.bleeding && !isdead(src))
		switch (src.bleeding)
			if (1 to 2)
				. += "<br>[SPAN_ALERT("[src.name] is bleeding a little bit.")]"
			if (2 to 3)
				. += "<br>[SPAN_ALERT("<B>[src.name] is bleeding!</B>")]"
			if (3 to 4)
				. += "<br>[SPAN_ALERT("<B>[src.name] is bleeding a lot!</B>")]"
			if (4 to INFINITY)
				. += "<br>[SPAN_ALERT("<B>[src.name] is bleeding very badly!</B>")]"
/*			if (1 to 2)
				. += "<br>[SPAN_ALERT("[src.name] is bleeding a little bit.")]"
			if (3 to 5)
				. += "<br>[SPAN_ALERT("<B>[src.name] is bleeding!</B>")]"
			if (6 to 8)
				. += "<br>[SPAN_ALERT("<B>[src.name] is bleeding a lot!</B>")]"
			if (9 to INFINITY)
				. += "<br>[SPAN_ALERT("<B>[src.name] is bleeding very badly!</B>")]"
*/
	if (!isvampire(src)) // Added a check for vampires (Convair880).
		switch (src.blood_pressure["total"])
			if (-INFINITY to 0) // welp
				. += "<br>[SPAN_ALERT("<B>[src.name] is pale as a ghost!</B>")]"
			if (1 to 299) // very low (70/50)
				. += "<br>[SPAN_ALERT("<B>[src.name] is very pale!</B>")]"
			if (300 to 414) // low (100/65)
				. += "<br>[SPAN_ALERT("<B>[src.name] is pale.</B>")]"
			if (585 to 666) // high (140/90)
				. += "<br>[SPAN_ALERT("[src.name] is a little sweaty and red in the face.")]"
			if (666 to 750) // very high (160/100)
				. += "<br>[SPAN_ALERT("<B>[src.name] is very sweaty and red in the face!</B>")]"
			if (750 to 1500) // critically high (180/110)
				. += "<br>[SPAN_ALERT("<B>[src.name] is sweating like a pig and red as a tomato!</B>")]"
			if (1500 to INFINITY) // critically high (180/110)
				. += "<br>[SPAN_ALERT("<B>[src.name] is sweating like a pig and red as a tomato!</B>")]"

	var/changeling_fakedeath = 0
	var/datum/abilityHolder/changeling/C = get_ability_holder(/datum/abilityHolder/changeling)
	if (C?.in_fakedeath)
		changeling_fakedeath = 1

	if ((isdead(src)) || changeling_fakedeath || src.bioHolder?.HasEffect("dead_scan") == 2 || (src.reagents.has_reagent("capulettium") && is_incapacitated(src)) || (src.reagents.has_reagent("capulettium_plus") && src.hasStatus("resting")))
		if (!src.decomp_stage)
			. += "<br>[SPAN_ALERT("[src] is limp and unresponsive, a dull lifeless look in [t_his] eyes.")]"
	else
		var/brute = src.get_brute_damage()
		if (brute >= 5)
			if (brute < 30)
				. += "<br>[SPAN_ALERT("[src.name] looks a little injured.")]"
			else
				. += "<br>[SPAN_ALERT("<B>[src.name] looks severely injured!</B>")]"

		var/burn = src.get_burn_damage()
		if (burn >= 5)
			if (burn < 30)
				. += "<br>[SPAN_ALERT("[src.name] looks a little burnt.")]"
			else
				. += "<br>[SPAN_ALERT("<B>[src.name] looks severely burned!</B>")]"

		if (src.stat || src.hasStatus("paralysis"))
			. += "<br>[SPAN_ALERT("[src.name] doesn't seem to be responding to anything around [t_him], [t_his] eyes closed as though asleep.")]"
		else
			if (src.get_brain_damage() >= 60)
				. += "<br>[SPAN_ALERT("[src.name] has a blank expression on [his_or_her(src)] face.")]"

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
				else if (!skip_afk_check)
					. += "<br>[src.name] seems to be staring blankly into space. "
					if (src.last_ckey && src.logout_at)
						var/gone_time_s = floor((TIME - src.logout_at) / 10)
						var/gone_time_m = floor(gone_time_s / 60)
						if (gone_time_s <= 60)
							. += SPAN_SUBTLE("<br>They slipped into it [gone_time_s] second\s ago.")
						else
							. += SPAN_SUBTLE("<br>They've been like this for [gone_time_m] minute\s.")

	switch (src.decomp_stage)
		if (DECOMP_STAGE_BLOATED)
			. += "<br>[SPAN_ALERT("[src] looks bloated and smells a bit rotten!")]"
		if (DECOMP_STAGE_DECAYED)
			. += "<br>[SPAN_ALERT("[src]'s flesh is starting to rot away from [t_his] bones!")]"
		if (DECOMP_STAGE_HIGHLY_DECAYED)
			. += "<br>[SPAN_ALERT("[src]'s flesh is almost completely rotten away, revealing parts of [t_his] skeleton!")]"
		if (DECOMP_STAGE_SKELETONIZED)
			. += "<br>[SPAN_ALERT("[src]'s remains are completely skeletonized.")]"

	if(usr.traitHolder && (usr.traitHolder.hasTrait("observant") || istype(usr, /mob/dead/observer)))
		if(src.traitHolder && length(src.traitHolder.traits))
			. += "<br>[SPAN_NOTICE("[src] has the following traits:")]<br>"
			var/list/trait_names = list()
			for(var/id in src.traitHolder.traits)
				var/datum/trait/T = src.traitHolder.traits[id]
				trait_names += T.name
			. += SPAN_NOTICE(english_list(trait_names))

		else
			. += "<br>[SPAN_NOTICE("[src] does not appear to possess any special traits.")]"

	if (src.juggling())
		var/items = ""
		var/count = 0
		for (var/obj/O in src.juggling)
			count ++
			if (length(src.juggling) > 1 && count == src.juggling.len)
				items += " and [O]"
				continue
			items += ", [O]"
		items = copytext(items, 3)
		. += "<br>[SPAN_NOTICE("[src] is juggling [items]!")]"

	if (src.reagents.has_reagent("ethanol") && !isdead(src) && !src.hasStatus("paralysis"))
		var/et_amt = src.reagents.get_reagent_amount("ethanol")
		var/drunk_assess = ""
		if (!isalcoholresistant(src) || src.reagents.has_reagent("moonshine"))
			switch (et_amt)
				if (0 to 10)
					drunk_assess = "[capitalize("[he_or_she(src)]")] seem[blank_or_s(src)] <b>buzzed.</b>"
				if (10 to 20)
					drunk_assess = "[capitalize("[he_or_she(src)]")] look[blank_or_s(src)] a little <b>tipsy.</b>"
				if (20 to 40)
					drunk_assess = "[capitalize("[hes_or_shes(src)]")] pretty <b>[prob(10)? "stewed" : "drunk"].</b>"
				if (40 to 70)
					drunk_assess = "[capitalize("[hes_or_shes(src)]")] totally <b>smashed.</b>"
				if (70 to 100)
					drunk_assess = SPAN_ALERT("[capitalize("[hes_or_shes(src)]")] <b>[prob(3)? " zonked</b> off [his_or_her(src)] <b>rocker" : "badly inebriated"].</b>")
				if (100 to INFINITY)
					drunk_assess = SPAN_ALERT("[capitalize("[hes_or_shes(src)]")] <b>dying of drink.</b>")
		else
			drunk_assess = "[capitalize("[his_or_her(src)]")] inebriaton is almost <b>imperceptible</b> to you."
		. += "<br> [drunk_assess]"

	. += "<br>[SPAN_NOTICE("*---------*")]"

	if (GET_DIST(usr, src) < 4)
		if (GET_ATOM_PROPERTY(usr,PROP_MOB_EXAMINE_HEALTH))
			. += "<br>[SPAN_ALERT("You analyze [src]'s vitals.")]<br>[scan_health(src, 0, 0, syndicate = GET_ATOM_PROPERTY(usr,PROP_MOB_EXAMINE_HEALTH_SYNDICATE))]"
			scan_health_overhead(src, usr)
			update_medical_record(src)

	return jointext(., "")
