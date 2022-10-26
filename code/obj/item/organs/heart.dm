/*=========================*/
/*----------Heart----------*/
/*=========================*/

#define HEART_REAGENT_CAP 100
#define HEART_WRING_AMOUNT src.reagents.maximum_volume * 0.25
/obj/item/organ/heart
	name = "heart"
	organ_name = "heart"
	desc = "Offal, just offal."
	organ_holder_name = "heart"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 9
	icon_state = "heart"
	item_state = "heart"
	// var/broken = 0		//Might still want this. As like a "dead organ var", maybe not needed at all tho?
	var/list/diseases = null
	var/body_image = null // don't have time to completely refactor this, but, what name does the heart icon have in human.dmi?
	var/transplant_XP = 5
	var/blood_id = "blood"
	var/squeeze_sound = 'sound/impact_sounds/Slimy_Splat_1.ogg'

	New(loc, datum/organHolder/nholder)
		. = ..()
		reagents = new/datum/reagents(HEART_REAGENT_CAP)

#undef HEART_REAGENT_CAP

	disposing()
		if (holder)
			holder.heart = null
		..()

	attack_self(mob/user)
		..()
		if (!src.reagents)
			return
		if (!src.reagents.total_volume)
			boutput(user, "<span class='alert'>There's nothing in \the [src] to wring out!</span>")
			return

		if (!ON_COOLDOWN(src, "heart_wring", 2 SECONDS))
			playsound(user, squeeze_sound, 30, 1)
			logTheThing(LOG_CHEMISTRY, user, "wrings out [src] containing [log_reagents(src)] at [log_loc(user)].")
			src.reagents.trans_to(get_turf(src), HEART_WRING_AMOUNT)
			boutput(user, "<span class='notice'>You wring out \the [src].</span>")

#undef HEART_WRING_AMOUNT

	on_transplant(var/mob/M as mob)
		..()
		if (src.donor.reagents && src.reagents)
			src.reagents.trans_to(src.donor, src.reagents.total_volume)

		if (src.robotic)
			if (src.emagged)
				APPLY_ATOM_PROPERTY(src.donor, PROP_MOB_STAMINA_REGEN_BONUS, "heart", 15)
				src.donor.add_stam_mod_max("heart", 90)
				APPLY_ATOM_PROPERTY(src.donor, PROP_MOB_STUN_RESIST, "heart", 30)
				APPLY_ATOM_PROPERTY(src.donor, PROP_MOB_STUN_RESIST_MAX, "heart", 30)
			else
				APPLY_ATOM_PROPERTY(src.donor, PROP_MOB_STAMINA_REGEN_BONUS, "heart", 5)
				src.donor.add_stam_mod_max("heart", 40)
				APPLY_ATOM_PROPERTY(src.donor, PROP_MOB_STUN_RESIST, "heart", 15)
				APPLY_ATOM_PROPERTY(src.donor, PROP_MOB_STUN_RESIST_MAX, "heart", 15)

		if (src.donor)
			for (var/datum/ailment_data/disease in src.donor.ailments)
				if (disease.cure == "Heart Transplant")
					src.donor.cure_disease(disease)
			src.donor.blood_id = (ischangeling(src.donor) && src.blood_id == "blood") ? "bloodc" : src.blood_id
		if (ishuman(M) && islist(src.diseases))
			var/mob/living/carbon/human/H = M
			for (var/datum/ailment_data/AD in src.diseases)
				H.contract_disease(null, null, AD, 1)
				src.diseases.Remove(AD)
			return

	on_removal()
		if (donor)
			if (src.donor.reagents && src.reagents)
				src.donor.reagents.trans_to(src, src.reagents.maximum_volume - src.reagents.total_volume)

			if (!ischangeling(donor) && !donor.nodamage)
				donor.changeStatus("weakened", 8 SECONDS)
				donor.losebreath += 20
				donor.take_oxygen_deprivation(20)

			src.blood_id = src.donor.blood_id //keep our owner's blood (for mutantraces etc)

			if (src.robotic)
				REMOVE_ATOM_PROPERTY(src.donor, PROP_MOB_STAMINA_REGEN_BONUS, "heart")
				src.donor.remove_stam_mod_max("heart")
				REMOVE_ATOM_PROPERTY(src.donor, PROP_MOB_STUN_RESIST, "heart")
				REMOVE_ATOM_PROPERTY(src.donor, PROP_MOB_STUN_RESIST_MAX, "heart")

			var/datum/ailment_data/malady/HD = donor.find_ailment_by_type(/datum/ailment/malady/heartdisease)
			if (HD)
				if (!islist(src.diseases))
					src.diseases = list()
				HD.master.on_remove(donor,HD)
				donor.ailments.Remove(HD)
				HD.affected_mob = null
				src.diseases.Add(HD)
		..()
		return

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for attaching heads. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		var/success = ..(H, user)

		if (success)
			if (!isdead(H))
				JOB_XP(user, "Medical Doctor", src.health > 0 ? transplant_XP*2 : transplant_XP)
			return 1
		else
			return 0

/obj/item/organ/heart/synth
	name = "synthheart"
	desc = "I guess you could call this a... hearti-choke"
	synthetic = 1
	item_state = "plant"
	transplant_XP = 6
	squeeze_sound = 'sound/items/rubberduck.ogg'

	New()
		..()
		src.icon_state = pick("plant_heart", "plant_heart_bloom")

/obj/item/organ/heart/cyber
	name = "cyberheart"
	desc = "A cybernetic heart. Is this thing really medical-grade?"
	icon_state = "heart_robo1"
	item_state = "heart_robo1"
	//created_decal = /obj/decal/cleanable/oil
	edible = 0
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	mats = 8
	made_from = "pharosium"
	transplant_XP = 7
	squeeze_sound = 'sound/voice/screams/Robot_Scream_2.ogg'

	emp_act()
		..()
		if (src.broken)
			boutput(donor, "<span class='alert'><B>Your cyberheart malfunctions and shuts down!</B></span>")
			donor.contract_disease(/datum/ailment/malady/flatline,null,null,1)

/obj/item/organ/heart/flock
	name = "pulsing octahedron"
	desc = "It beats ceaselessly to a peculiar rhythm. Like it's trying to tap out a distress signal."
	icon_state = "flockdrone_heart"
	item_state = "flockdrone_heart"
	body_image = "heart_flock"
	created_decal = /obj/decal/cleanable/flockdrone_debris/fluid
	made_from = "gnesis"
	var/resources = 0 // reagents for humans go in heart, resources for flockdrone go in heart, now, not the brain
	var/flockjuice_limit = 20 // pump flockjuice into the human host forever, but only a small bit
	var/min_blood_amount = 450
	squeeze_sound = 'sound/misc/flockmind/flockdrone_grump2.ogg'
	blood_id = "flockdrone_fluid"

	on_transplant(var/mob/M as mob)
		..()
		if (ishuman(M))
			M:blood_color = "#4d736d"
			// there is no undo for this. wear the stain of your weird alien blood, pal
	//was do_process
	on_life()
		var/mob/living/M = src.holder.donor
		if(!M || !ishuman(M)) // flockdrones shouldn't have these problems
			return
		var/mob/living/carbon/human/H = M
		// handle flockjuice addition and capping
		if(H.reagents)
			var/datum/reagents/R = H.reagents
			var/flockjuice = R.get_reagent_amount("flockdrone_fluid")
			if(flockjuice <= 0)
				R.add_reagent("flockdrone_fluid", 10)
			if(flockjuice > flockjuice_limit)
				R.remove_reagent("flockdrone_fluid", flockjuice - flockjuice_limit)
			// handle blood synthesis
			if(H.blood_volume < min_blood_amount)
				// consume flockjuice, convert into blood
				var/converted_amt = min(flockjuice, min_blood_amount - H.blood_volume)
				R.remove_reagent("flockdrone_fluid", converted_amt)
				H.blood_volume += converted_amt

/obj/item/organ/heart/flock/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> Resource repository
		<br><span class='bold'>Resources:</span> [src.resources]
		<br><span class='bold'>###=-</span></span>"}
