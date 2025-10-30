/*=================================*/
/*---------- Organ Items ----------*/
/*=================================*/

/obj/item/organ
	name = "organ"
	var/organ_name = "organ" // so you can refer to the organ by a simple name and not end up telling someone "Your Lia Alliman's left lung flies out your mouth!"
	desc = "What does this thing even do? Is it something you need?"
	var/organ_holder_name = "organ"
	var/organ_holder_location = "chest"
	icon = 'icons/obj/items/organs/brain.dmi'
	icon_state = "brain1"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "brain"
	force = 1
	health = 4
	w_class = W_CLASS_TINY
	throwforce = 1
	throw_speed = 3
	throw_range = 5
	stamina_damage = 5
	stamina_cost = 5
	edible = 1	// currently overridden by material settings
	material_amt = 0.3
	uses_default_material_appearance = FALSE
	uses_default_material_name = FALSE
	var/mob/living/carbon/human/donor = null // if I can't use "owner" I can at least use this
	/// Whoever had this organ first, the original owner
	var/mob/living/carbon/human/donor_original = null // So people'll know if a lizard's wearing someone else's tail
	var/datum/appearanceHolder/donor_AH //
	var/donor_name = null // so you don't get dumb "Unknown's skull mask" shit
	var/donor_DNA = null
	var/datum/organHolder/holder = null
	var/list/organ_abilities = null

	// So we can have an organ have a visible counterpart while inside someone, like a tail or some kind of krang
	// if you're making a tail, you need to have at least organ_image_under_suit_1 defined, or else it wont work
	var/organ_image_icon = null		// The icon group we'll be using, such as 'icons/effects/genetics.dmi'
	var/organ_image_over_suit = null		// Shows up over our suit, usually while the mob is facing north
	var/organ_image_under_suit_1 = null	// Shows up under our suit, usually while the mob is facing anywhere else
	var/organ_image_under_suit_2 = null	// If our organ needs another picture, usually for another coloration

	var/organ_color_1 = "#FFFFFF"		// Typically used to colorize the organ image
	var/organ_color_2 = "#FFFFFF"		// Might also be usable to color organs if their owner has funky colored blood. Shrug.

	/// If our organ's been severed and reattached. Used by heads to preserve their appearance across icon updates if reattached
	var/transplanted = FALSE

	var/op_stage = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/tox_dam = 0

	var/robotic = 0
	var/emagged = 0
	var/synthetic = 0
	var/broken = 0
	var/unusual = 0
	var/failure_disease = null		//The organ failure disease associated with this organ. Not used for Heart atm.

	var/max_damage = 100	//Max damage before organ "dies"
	var/fail_damage = 65	//Total damage amount at which organ failure starts

	var/created_decal = /obj/decal/cleanable/blood // what kinda mess it makes.  mostly so cyberhearts can splat oil on the ground, but idk maybe you wanna make something that creates a broken balloon or something on impact vOv
	var/blood_color = null
	var/blood_reagent = null
	var/decal_done = FALSE // fuckers are tossing these around a lot so I guess they're only gunna make one, ever now
	var/body_side = null // L_ORGAN/1 for left, R_ORGAN/2 for right
	var/datum/bone/bones = null
	rand_pos = 1

	default_material = "flesh" //Material this organ will produce.

	///if the organ is currently acting as an organ in a body
	var/in_body = FALSE
	///List of buttons we'll show when doing organ surgery
	var/list/datum/contextAction/surgery_contexts = null
	contextLayout = new /datum/contextLayout/experimentalcircle
	///Which type of surgery tools do we need to operate on this organ?
	var/surgery_flags = SURGERY_NONE
	var/removal_stage = 0
	///In which region is this organ supposed to be implanted? E.g. RIBS for the heart and lungs
	var/region = null
	///Can this organ be inserted on either side? (literally just kidneys, wegh)
	var/either_side = FALSE

	attack(var/mob/living/carbon/M, var/mob/user)
		if (!ismob(M))
			return

		src.add_fingerprint(user)

		var/attach_result = src.attach_organ(M, user)
		if (attach_result == 1) // success
			return
		else if (isnull(attach_result)) // failure but don't attack
			return
		else // failure and attack them with the organ
			return ..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/analyzer/healthanalyzer))
			var/obj/item/device/analyzer/healthanalyzer/HA = W

			if(HA.organ_scan)
				boutput(user, "<br><span style='color:purple'><b>[src]</b> - [src.get_damage()]</span>")
				return
			if (HA.organ_upgrade && !HA.organ_scan)
				boutput(user, "<br><span style='color:purple'><b>You need to turn on the organ scan function to get a reading.</span>")
				return
			else
				boutput(user, "<br><span style='color:purple'><b>This device is not equipped to scan organs.</span>")
				return

		else
			user.lastattacked = get_weakref(src)
			attack_particle(user,src)
			hit_twitch(src)
			playsound(src, 'sound/impact_sounds/Flesh_Stab_2.ogg', 100, TRUE)
			src.splat(get_turf(src))
			if(W.hit_type == DAMAGE_BURN)
				src.take_damage(0, W.force, 0, W.hit_type)
			else
				src.take_damage(W.force, 0, 0, W.hit_type)

		..()

	add_fingerprint(mob/living/M as mob, hidden_only = TRUE)
		. = ..()

	New(loc, datum/organHolder/nholder)
		..()
		if (istype(nholder) && nholder.donor)
			src.holder = nholder
			src.donor = nholder.donor
		if (src.donor)
			src.donor_original = src.donor
			src.in_body = TRUE
			if (src.donor.bioHolder)
				src.donor_AH = src.donor.bioHolder.mobAppearance
			if (src.donor.real_name)
				src.donor_name = src.donor.real_name
				src.name = "[src.donor_name]’s [initial(src.name)]"
			else if (src.donor.name)
				src.donor_name = src.donor.name
				src.name = "[src.donor_name]’s [initial(src.name)]"
			src.donor_DNA = src.donor.bioHolder ? src.donor.bioHolder.Uid : null
			src.blood_DNA = src.donor_DNA
			src.blood_type = src.donor.bioHolder?.bloodType
			src.blood_color = src.donor.bioHolder?.bloodColor
			src.blood_reagent = src.donor.blood_id

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		src.max_damage += passed_genes?.get_effective_value("endurance")
		src.fail_damage += passed_genes?.get_effective_value("endurance")
		return src

	disposing()
		if (src.holder)
			src.remove_organ_abilities()
			for(var/thing in holder.organ_list)
				if(thing == "all")
					continue
				if(holder.organ_list[thing] == src)
					holder.organ_list[thing] = null
				if((thing in holder.vars) && holder.vars[thing] == src) // organ holders suck, refactor when they no longer suck
					holder.vars[thing] = null

		donor_original = null
		donor = null

		if (bones)
			bones.dispose()

		holder = null
		..()

	proc/splat(turf/T)
		if(!istype(T) || src.decal_done || !ispath(src.created_decal))
			return FALSE
		playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, TRUE)
		var/obj/decal/cleanable/cleanable = make_cleanable(src.created_decal, T)
		cleanable.blood_DNA = src.blood_DNA
		cleanable.blood_type = src.blood_type
		if(istype(cleanable, /obj/decal/cleanable/blood))
			var/obj/decal/cleanable/blood/blood = cleanable
			blood.set_sample_reagent_custom(src.blood_reagent, 10)
			if(!isnull(src.blood_color))
				blood.color = src.blood_color
		src.decal_done = TRUE
		return cleanable

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A) //
		playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_2.ogg', 100, 1)
		src.splat(T)
		..() // call your goddamn parents

	//Returns true if the organ is broken or damage is over max health.
	//Under no circumstances should you ever reassign the donor or holder variables in here.
	//Not checking donor here because it's checked where it's called. And I can't think of ANY REASON to EVER call this from somewhere else. And if I do, then I'll delete this comment. - kyle
	proc/on_life(var/mult = 1)
		if (holder && (src.broken || src.get_damage() > max_damage) )
			return 0
		return 1

	/// What should happen each life tick when an organ is broken.
	proc/on_broken(var/mult = 1)
		//stupid check ikr? prolly remove.
		if (broken)
			return 1
		return 0

	//used by flockdrones, so I won't be removing. Don't know what it's about and I don't care. - kyle
	proc/do_process()
		return

	proc/do_missing()
		return

	//kyle-note come back
	proc/on_transplant(var/mob/M as mob)
		if (!ishuman(M))
			return

		var/mob/living/carbon/human/H = M
		src.donor = H
		src.holder = H.organHolder
		if(!istype(src.donor_original)) // If we were spawned without an owner, they're our new original owner
			src.donor_original = H

		if (src.robotic)
			H.robotic_organs++
			var/image/I = H.prodoc_icons["robotic_organs"]
			I.icon_state = "organs-cyber"

		//Kinda repeated below too. Cure the organ failure disease if this organ is above a certain HP
		if (src.donor)
			if (!src.broken  && failure_disease)
				src.donor.cure_disease(failure_disease)

		if (!broken && islist(src.organ_abilities) && length(src.organ_abilities))
			var/datum/abilityHolder/organ/A = M.get_ability_holder(/datum/abilityHolder/organ)
			if (!istype(A))
				A = M.add_ability_holder(/datum/abilityHolder/organ)
			if (!A)
				return
			for (var/abil in src.organ_abilities)
				src.add_ability(A, abil)

		return

	//kyle-note come back
	proc/on_removal()
		SHOULD_CALL_PARENT(TRUE)
		//all robotic organs have a stamina buff we must remove
		if (src.donor)
			if (failure_disease)
				src.donor.cure_disease(failure_disease)

			if (src.robotic)
				src.donor.robotic_organs--
				var/image/I = src.donor.prodoc_icons["robotic_organs"]
				if (src.donor.robotic_organs <= 0)
					I.icon_state = null

		if (!src.donor_DNA && src.donor && src.donor.bioHolder)
			src.donor_DNA = src.donor.bioHolder.Uid
			src.blood_DNA = src.donor_DNA
			src.blood_type = src.donor.bioHolder?.bloodType
		src.blood_color = src.donor?.bioHolder?.bloodColor
		src.blood_reagent = src.donor?.blood_id
		src.remove_organ_abilities()

		src.donor = null
		src.in_body = FALSE
		if (src.surgery_contexts)
			src.surgery_contexts = null
		return

	proc/remove_organ_abilities()
		if (islist(src.organ_abilities) && length(src.organ_abilities))
			var/datum/abilityHolder/aholder
			if (src.donor?.abilityHolder)
				aholder = src.donor.abilityHolder
			else if (src.holder?.donor?.abilityHolder)
				aholder = src.holder.donor.abilityHolder
			if (istype(aholder))
				for (var/abil in src.organ_abilities)
					src.remove_ability(aholder, abil)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.robotic)
			return
		if (user)
			user.show_text("You disable the safety limiters on [src].", "red")
		src.visible_message(SPAN_ALERT("<B>[src] sparks and shudders oddly!</B>"))
		src.emagged = 1
		return 1

	demag(var/mob/user)
		if (!src.robotic)
			return

		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You reactivate the safety limiters on [src].", "red")
		src.emagged = 0
		return 1

	emp_act()
		if (robotic)
			src.take_damage(20, 20, 20)

	on_forensic_scan(datum/forensic_scan/scan)
		. = ..()
		if(src.donor_DNA)
			scan.add_text("[src.organ_name]'s DNA: [src.donor_DNA]")

	proc/add_ability(var/datum/abilityHolder/aholder, var/abil) // in case things wanna do stuff instead of just straight-up adding/removing the abilities (see: laser eyes)
		if (!aholder || !abil)
			return
		var/datum/targetable/organAbility/OA = aholder.addAbility(abil)
		if (istype(OA))
			OA.linked_organ = src

	proc/remove_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!aholder || !abil)
			return
		aholder.removeAbility(abil)

	//damage/heal obj. Provide negative values for healing.	//maybe I'll change cause I don't like this. But this functionality is found in some other damage procs for other things, might as well keep it consistent.
	take_damage(brute, burn, tox, damage_type)
		if((isvampire(donor) || istype(ticker?.mode, /datum/game_mode/battle_royale)) && !(istype(src, /obj/item/organ/chest) || istype(src, /obj/item/organ/head)))
			return //vampires are already dead inside

		src.brute_dam += brute
		src.burn_dam += burn
		src.tox_dam += tox

		if(src.robotic && (src.organ_name in cyberorgan_brute_threshold) && abs(src.brute_dam - cyberorgan_brute_threshold[src.organ_name]) <= 2 && abs(src.burn_dam - cyberorgan_burn_threshold[src.organ_name]) <= 5)
			src.emag_act(null)

		//I don't think this is used at all, but I'm afraid to get rid of it - Kyle
		if (ishuman(donor))
			var/mob/living/carbon/human/H = donor
			//hit_twitch(H)		//no
			health_update_queue |= H
			if (bone_system && src.bones && brute && prob(brute * 2))
				src.bones.take_damage(damage_type)

		// if (src.get_damage() >= max_damage)
		if (src.brute_dam + src.burn_dam + src.tox_dam >= src.max_damage)
			src.breakme()
			donor?.contract_disease(failure_disease,null,null,1)
		health_update_queue |= donor
		return 1

	heal_damage(brute, burn, tox)
		if (broken || brute_dam <= 0 && burn_dam <= 0 && tox_dam <= 0)
			return 0
		src.brute_dam = max(0, src.brute_dam - brute)
		src.burn_dam = max(0, src.burn_dam - burn)
		src.tox_dam = max(0, src.tox_dam - tox)
		health_update_queue |= donor
		return 1

	get_damage()
		return src.brute_dam + src.burn_dam	+ src.tox_dam

	proc/can_attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Checks if an organ can be attached to a target mob */
		if (istype(/obj/item/organ/chest/, src))
			// We can't transplant a chest
			return FALSE

		if (user.zone_sel.selecting != src.organ_holder_location)
			return FALSE

		if (!can_act(user))
			return FALSE

		if (!surgeryCheck(M, user))
			return FALSE

		var/mob/living/carbon/human/H = M
		if (!H.organHolder)
			return FALSE
		switch (src.region)
			//Check if our relevant region is opened up. For example hearts need the ribs to be opened up
			if (null)
				return TRUE
			if (RIBS)
				if (H.organHolder.ribs_stage == REGION_OPENED && H.organHolder.chest?.op_stage >= 2)
					return TRUE
				return FALSE
			if (ABDOMINAL)
				if (H.organHolder.abdominal_stage == REGION_OPENED && H.organHolder.chest?.op_stage >= 2)
					return TRUE
				return FALSE
			if (SUBCOSTAL)
				if (H.organHolder.subcostal_stage == REGION_OPENED && H.organHolder.chest?.op_stage >= 2)
					return TRUE
			if (FLANKS)
				if (H.organHolder.flanks_stage == REGION_OPENED && H.organHolder.chest?.op_stage >= 2)
					return TRUE

		return FALSE

	proc/attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Attempts to attach this organ to the target mob M, if sucessful, displays surgery notifications and updates states in both user and target.
		Expected returns are 1 for success, 0 for a critical failure and null if a non-critical failure
		null is mostly used in the attack code to indicate that we failed to attach the organ but should not attack */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")
		var/obj/item/organ/organ_location = H.organHolder.get_organ(src.organ_holder_location)
		src.removal_stage = 0

		var/full_organ_name = src.organ_holder_name
		if (src.either_side)//Kidneys can go on the left or right, doesn't matter. Useful for cyber/synth kidneys
			if (!H.organHolder.get_organ("left_kidney"))
				full_organ_name = "left_kidney"
			else if (!H.organHolder.get_organ("right_kidney"))
				full_organ_name = "right_kidney"
			else
				return 0
		if (!H.organHolder.get_organ(full_organ_name))

			user.tri_message(H, SPAN_ALERT("<b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] [src.organ_holder_location]!"),\
				SPAN_ALERT("You [fluff] [src] into [user == H ? "your" : "[H]'s"] [src.organ_holder_location]!"),\
				SPAN_ALERT("[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your [src.organ_holder_location]!"))

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, full_organ_name, organ_location.op_stage)
			H.update_body()

			return 1
		else
			return 0

	proc/breakme()
		if (!broken)
			if (islist(src.organ_abilities) && length(src.organ_abilities))// remove abilities when broken
				var/datum/abilityHolder/aholder
				if (src.donor && src.donor.abilityHolder)
					aholder = src.donor.abilityHolder
				else if (src.holder && src.holder.donor && src.holder.donor.abilityHolder)
					aholder = src.holder.donor.abilityHolder
				if (istype(aholder))
					for (var/abil in src.organ_abilities)
						src.remove_ability(aholder, abil)
			src.broken = 1
			return TRUE

	proc/unbreakme()
		if (broken)
			if (islist(src.organ_abilities) && length(src.organ_abilities)) //put them back if fixed (somehow)
				var/datum/abilityHolder/organ/A = donor?.get_ability_holder(/datum/abilityHolder/organ)
				if (!istype(A))
					A = donor?.add_ability_holder(/datum/abilityHolder/organ)
				if (!A)
					return
				for (var/abil in src.organ_abilities)
					src.add_ability(A, abil)
			src.broken = 0
			return TRUE

	proc/build_organ_buttons()
		.= 0

		if (surgery_flags)
			.= 1

			if (src.surgery_contexts != null)
				return

			src.surgery_contexts = list()

			if (surgery_flags & SURGERY_CUTTING)
				var/datum/contextAction/organ_surgery/cut/action = new
				surgery_contexts += action
			if (surgery_flags & SURGERY_SNIPPING)
				var/datum/contextAction/organ_surgery/snip/action = new
				surgery_contexts += action
			if (surgery_flags & SURGERY_SAWING)
				var/datum/contextAction/organ_surgery/saw/action = new
				surgery_contexts += action

			.+= length(surgery_contexts)

