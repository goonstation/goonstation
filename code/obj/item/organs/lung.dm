#define LUNG_COUNT 2
/*=========================*/
/*----------Lungs----------*/
/*=========================*/
/obj/item/organ/lung
	name = "lungs"
	organ_name = "lung"
	desc = "Inflating meat airsacks that pass breathed oxygen into a person's blood and expels carbon dioxide back out. Hopefully whoever used to have these doesn't need them anymore."
	organ_holder_location = "chest"
	icon = 'icons/obj/items/organs/lung.dmi'
	icon_state = "lung_R"
	failure_disease = /datum/ailment/disease/respiratory_failure
	surgery_flags = SURGERY_SNIPPING | SURGERY_CUTTING | SURGERY_SAWING
	region = RIBS
	var/temp_tolerance = DEFAULT_LUNG_AIR_TEMP_TOLERANCE_MAX

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_co2_max = 9 // Yes it's an arbitrary value who cares?
	var/safe_toxins_max = 0.4
	var/n2o_para_min = 1
	var/n2o_sleep_min = 5
	var/fart_smell_min = 0.69 // don't ask ~warc
	var/fart_vomit_min = 6.9
	var/fart_choke_min = 16.9
	var/rad_immune = FALSE
	var/breaths_oxygen = TRUE

	attach_organ(mob/living/carbon/M, mob/user)
		. = ..()
		if (M.traitHolder?.hasTrait("plasmalungs") && src.breaths_oxygen)
			src.broken = TRUE

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (body_side == L_ORGAN)
			if (src.holder.left_lung && src.holder.left_lung.get_damage() > fail_damage && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		else
			if (src.holder.right_lung && src.holder.right_lung.get_damage() > fail_damage && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		return 1

	// on_broken()
	// 	if (body_side == L_ORGAN)
	// 		if (src.holder.left_lung && src.holder.left_lung.get_damage() > fail_damage && prob(src.get_damage() * 0.2))
	// 			donor.contract_disease(failure_disease,null,null,1)
	// 	else
	// 		if (src.holder.right_lung && src.holder.right_lung.get_damage() > fail_damage && prob(src.get_damage() * 0.2))
	// 			donor.contract_disease(failure_disease,null,null,1)

	///Return value indicates whether we have enough oxygen to breathe
	proc/breathe(datum/gas_mixture/breath, underwater, mult, datum/organ_status/lung/update)
		. = FALSE
		var/breath_moles = TOTAL_MOLES(breath)
		if(breath_moles == 0)
			breath_moles = ATMOS_EPSILON
		var/breath_pressure = (breath_moles*R_IDEAL_GAS_EQUATION*breath.temperature)/breath.volume
		//Partial pressure of the O2 in our breath
		var/O2_pp = (breath.oxygen/breath_moles)*breath_pressure
		// Same, but for the toxins
		var/Toxins_pp = (breath.toxins/breath_moles)*breath_pressure
		// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
		var/CO2_pp = (breath.carbon_dioxide/breath_moles)*breath_pressure
		var/FARD_pp = (breath.farts/breath_moles)*breath_pressure
		var/Radgas_pp = (breath.radgas/breath_moles)*breath_pressure
		var/oxygen_used

		if(breaths_oxygen)
			if (O2_pp < safe_oxygen_min) 			// Too little oxygen
				if (prob(20))
					if (underwater)
						update.emotes |= "gurgle"
					else
						update.emotes |= "gasp"
				if (O2_pp > 0)
					var/ratio = round(safe_oxygen_min/(O2_pp + 0.1))
					donor.take_oxygen_deprivation(min(5*ratio, 5)/LUNG_COUNT) // Don't fuck them up too fast (space only does 7 after all!)
					oxygen_used = min(breath.oxygen*ratio/6, breath.oxygen)
				else
					donor.take_oxygen_deprivation(3 * mult/LUNG_COUNT)
				update.show_oxy_indicator = TRUE
			else 									// We're in safe limits
				. = TRUE
				donor.take_oxygen_deprivation(-6 * mult/LUNG_COUNT)
				oxygen_used = breath.oxygen/6

			breath.oxygen -= oxygen_used
			breath.carbon_dioxide += oxygen_used

		if (CO2_pp > safe_co2_max)
			if (!donor.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				donor.co2overloadtime = world.time
			else if (world.time - donor.co2overloadtime > 12 SECONDS)
				donor.changeStatus("unconscious", 4 SECONDS * mult/LUNG_COUNT)
				donor.take_oxygen_deprivation(1.8 * mult/LUNG_COUNT) // Lets hurt em a little, let them know we mean business
				if (world.time - donor.co2overloadtime > 30 SECONDS) // They've been in here 30s now, lets start to kill them for their own good!
					donor.take_oxygen_deprivation(7 * mult/LUNG_COUNT)
			if (probmult(20)) // Lets give them some chance to know somethings not right though I guess.
				update.emotes |= "cough"
		else
			donor.co2overloadtime = 0

		if (Toxins_pp > safe_toxins_max) // Too much toxins
			var/ratio = breath.toxins/safe_toxins_max
			donor.take_toxin_damage(min(ratio * 125,20) * mult/LUNG_COUNT)
			update.show_tox_indicator = TRUE

		if (Radgas_pp > 0) //any fallout is too much fallout
			donor.take_radiation_dose(min(0.03 * Radgas_pp, 0.2) * mult/LUNG_COUNT, internal=TRUE) //not a lethal dose in one second tho
			breath.radgas *= 0.5 //lets say you keep half of it in your lungs.

		var/N2O_pp = (breath.nitrous_oxide/breath_moles)*breath_pressure
		if (N2O_pp > n2o_para_min) // Enough to make us paralysed for a bit
			donor.changeStatus("unconscious", 5 SECONDS/LUNG_COUNT)
			if (N2O_pp > n2o_sleep_min) // Enough to make us sleep as well
				donor.sleeping = max(donor.sleeping, 2)
		else if (N2O_pp > 0.5)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if (probmult(20))
				update.emotes |= pick("giggle", "laugh")
		breath.nitrogen += breath.nitrous_oxide //it gets converted to nitrogen via magic. I'm no biochemist.
		breath.nitrous_oxide = 0

		if (prob(15) && (FARD_pp > fart_smell_min))
			boutput(donor, SPAN_ALERT("Smells like someone [pick("died","soiled themselves","let one rip","made a bad fart","peeled a dozen eggs")] in here!"))
			if ((FARD_pp > fart_vomit_min) && prob(50))
				var/vomit_message = SPAN_NOTICE("[donor] vomits from the [pick("stink","stench","awful odor")]!!")
				donor.vomit(0, null, vomit_message)
		if (FARD_pp > fart_choke_min)
			donor.take_oxygen_deprivation(6.9 * mult/LUNG_COUNT)
			if (prob(20))
				update.emotes |= "cough"
				if (prob(30))
					boutput(donor, SPAN_ALERT("Oh god it's so bad you could choke to death in here!"))

		if (breath.temperature > min(temp_tolerance) && !donor.is_heat_resistant()) // Hot air hurts :(
			var/lung_burn = clamp(breath.temperature - temp_tolerance, 0, 30) / 3
			donor.TakeDamage("chest", 0, (lung_burn / LUNG_COUNT) + 3, 0, DAMAGE_BURN)
			if(prob(20))
				boutput(donor, SPAN_ALERT("This air is searing hot!"))
				if (prob(80))
					holder.damage_organ(0, lung_burn + 6, 0, organ_holder_name)

			update.show_fire_indicator = TRUE
			if (prob(4))
				boutput(donor, SPAN_ALERT("Your lungs hurt like hell! This can't be good!"))


	disposing()
		if (holder)
			if (holder.left_lung == src)
				holder.left_lung = null
			if (holder.right_lung == src)
				holder.right_lung = null
		..()

/obj/item/organ/lung/left
	name = "left lung"
	desc = "Inflating meat airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a left lung, since it has three lobes. Hopefully whoever used to have this one doesn't need it anymore."
	organ_name = "lung_L"
	organ_holder_name = "left_lung"
	icon_state = "lung_L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/left

/obj/item/organ/lung/right
	name = "right lung"
	desc = "Inflating meat airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a right lung, since it has two lobes and a cardiac notch, where the heart would be. Hopefully whoever used to have this one doesn't need it anymore."
	organ_name = "lung_R"
	organ_holder_name = "right_lung"
	icon_state = "lung_R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/right

TYPEINFO(/obj/item/organ/lung/cyber)
	mats = 6

/obj/item/organ/lung/cyber
	name = "cyberlungs"
	desc = "Fancy robotic lungs!"
	icon_state = "cyber-lungs_L"
	default_material = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	temp_tolerance = T0C+500
	var/overloading = 0
	var/grace_period = 30
	safe_oxygen_min = 9
	safe_co2_max = 18
	safe_toxins_max = 5		//making it a lot higher than regular, because even doubling the regular value is pitifully low. This is still reasonably low, but it might be noticable
	rad_immune = TRUE

	add_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/rebreather) || !aholder)
			return ..()
		var/datum/targetable/organAbility/rebreather/OA = aholder.getAbility(abil)//addAbility(abil)
		if (istype(OA)) // already has an emagged lung. You need both for the ability to function
			OA.linked_organ = list(OA.linked_organ, src)
		else
			OA = aholder.addAbility(abil)
			if (istype(OA))
				OA.linked_organ = src

	remove_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/rebreather) || !aholder)
			return ..()
		var/datum/targetable/organAbility/rebreather/OA = aholder.getAbility(abil)
		if (!OA) // what??
			return
		if (islist(OA.linked_organ)) // two emagged lungs, just remove us :3
			var/list/lorgans = OA.linked_organ
			if(OA.is_on)
				OA.handleCast() //turn it off - we only have one left!
			lorgans -= src // remove us from the list so only the other lung is left and thus will be lorgans[1]
			OA.linked_organ = lorgans[1]
		else // just us!
			aholder.removeAbility(abil)

	on_life(var/mult = 1)
		if(!..())
			return 0

		if(overloading)
			src.grace_period = max(grace_period - 3 * mult, 0)
			if(grace_period <= 5)
				src.take_damage(0, 1 * mult)
		else
			src.grace_period = min(grace_period + 1 * mult, initial(src.grace_period))
		return 1

	disposing()
		if(donor)
			REMOVE_ATOM_PROPERTY(donor, PROP_MOB_REBREATHING, "cyberlungs")
		..()

	emag_act(mob/user, obj/item/card/emag/E)
		..()
		organ_abilities = list(/datum/targetable/organAbility/rebreather)

	demag(mob/user)
		..()
		organ_abilities = initial(organ_abilities)

/obj/item/organ/lung/synth
	name = "synthlungs"
	icon_state = "plant"
	desc = "Surprisingly, doesn't produce its own oxygen. Luckily, it works just as well at moving oxygen to the bloodstream."
	synthetic = 1
	failure_disease = /datum/ailment/disease/respiratory_failure
	safe_co2_max = INFINITY

	New()
		..()
		src.icon_state = pick("plant_lung_t", "plant_lung_t_bloom")

	breathe(datum/gas_mixture/breath, underwater, mult, datum/organ_status/lung/update)
		breath.carbon_dioxide /= 2
		breath.oxygen += breath.carbon_dioxide
		. = ..()
		breath.oxygen += breath.carbon_dioxide
		breath.carbon_dioxide = 0

/obj/item/organ/lung/synth/left
	name = "left lung"
	organ_name = "synthlung_L"
	icon_state = "plant"
	desc = "Surprisingly, doesn't produce its own oxygen. Luckily, it works just as well at moving oxygen to the bloodstream. This is a left lung, since it has three lobes. Hopefully whoever used to have this one doesn't need it anymore."
	organ_holder_name = "left_lung"
	body_side = L_ORGAN
	synthetic = 1
	failure_disease = /datum/ailment/disease/respiratory_failure/left
	New()
		..()
		src.icon_state = pick("plant_lung_L", "plant_lung_L_bloom")

/obj/item/organ/lung/synth/right
	name = "right lung"
	organ_name = "synthlung_R"
	icon_state = "plant"
	desc = "Surprisingly, doesn't produce its own oxygen. Luckily, it works just as well at moving oxygen to the bloodstream. This is a right lung, since it has two lobes and a cardiac notch, where the heart would be. Hopefully whoever used to have this one doesn't need it anymore."
	organ_holder_name = "right_lung"
	body_side = R_ORGAN
	synthetic = 1
	failure_disease = /datum/ailment/disease/respiratory_failure/right
	New()
		..()
		src.icon_state = pick("plant_lung_R", "plant_lung_R_bloom")

/obj/item/organ/lung/cyber/left
	name = "left lung"
	desc = "Inflating robotic airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a left lung, since it has three lobes. Hopefully whoever used to have this one doesn't need it anymore."
	organ_name = "cyber_lung_L"
	organ_holder_name = "left_lung"
	icon_state = "cyber-lung-L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/left

/obj/item/organ/lung/cyber/right
	name = "right lung"
	organ_name = "cyber_lung_R"
	desc = "Inflating robotic airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a right lung, since it has two lobes and a cardiac notch, where the heart would be. Hopefully whoever used to have this one doesn't need it anymore."
	organ_holder_name = "right_lung"
	icon_state = "cyber-lung-R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/right

/obj/item/organ/lung/plasmatoid
	unusual = TRUE
	breaths_oxygen = FALSE
	safe_toxins_max = INFINITY

	breathe(datum/gas_mixture/breath, underwater, mult, datum/organ_status/lung/update)
		. = ..()
		var/safe_oxygen_max = 0.4

		var/breath_moles = TOTAL_MOLES(breath)
		var/breath_pressure = (breath_moles*R_IDEAL_GAS_EQUATION*breath.temperature)/breath.volume
		if(breath_moles == 0)
			breath_moles = ATMOS_EPSILON
		var/Toxins_pp = (breath.toxins/breath_moles)*breath_pressure
		var/O2_pp = (breath.oxygen/breath_moles)*breath_pressure
		var/gas_used

		if (Toxins_pp < safe_oxygen_min) 			// Too little plasma
			if (prob(20))
				if (underwater)
					update.emotes |= "gurgle"
				else
					update.emotes |= "gasp"
			if (Toxins_pp > 0)
				var/ratio = round(safe_oxygen_min/(Toxins_pp + 0.1))
				donor.take_oxygen_deprivation(min(5*ratio, 5)/LUNG_COUNT) // Don't fuck them up too fast (space only does 7 after all!)
				gas_used = min(breath.toxins*ratio/6, breath.oxygen)
			else
				donor.take_oxygen_deprivation(3 * mult/LUNG_COUNT)
			update.show_oxy_indicator = TRUE
		else 									// We're in safe limits
			donor.take_oxygen_deprivation(-6 * mult/LUNG_COUNT)
			gas_used = breath.toxins/6

		breath.toxins -= gas_used
		breath.carbon_dioxide += gas_used

		if (O2_pp > safe_oxygen_max) // Too much toxins
			var/ratio = breath.oxygen/safe_oxygen_max
			donor.take_toxin_damage(min(ratio * 125,20) * mult/LUNG_COUNT)
			update.show_tox_indicator = TRUE

/obj/item/organ/lung/plasmatoid/left
	name = "left lung"
	desc = "Inflating airsack presumably that passes breathed in gas into a person's blood and hopefully expels carbon dioxide back out. This is a left lung, since it has three lobes. Whoever used to have this probably didn't want it anymore."
	organ_holder_name = "left_lung"
	organ_name = "plasma_lung_L"
	icon_state = "plasma_lung_L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/left

/obj/item/organ/lung/plasmatoid/right
	name = "right lung"
	desc = "Inflating airsack presumably that passes breathed in gas into a person's blood and hopefully expels carbon dioxide back out. This is a right lung, since it has two lobes and a cardiac notch, where the heart would be. Whoever used to have this probably didn't want it anymore."
	organ_name = "plasma_lung_R"
	organ_holder_name = "right_lung"
	icon_state = "plasma_lung_R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/right


/datum/organ_status/lung
	var/show_oxy_indicator = FALSE
	var/show_tox_indicator = FALSE
	var/show_fire_indicator = FALSE

	var/list/emotes = list()

#undef LUNG_COUNT
