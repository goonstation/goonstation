/*=================================*/
/*---------- Organ Items ----------*/
/*=================================*/

/obj/item/organ
	name = "organ"
	var/organ_name = "organ" // so you can refer to the organ by a simple name and not end up telling someone "Your Lia Alliman's left lung flies out your mouth!"
	desc = "What does this thing even do? Is it something you need?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain1"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "brain"
	flags = TABLEPASS
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	stamina_damage = 5
	stamina_cost = 5
	edible = 1
	module_research = list("medicine" = 2) // why would you put this below the throw_impact() stuff
	module_research_type = /obj/item/organ // were you born in a fuckin barn
	var/mob/living/carbon/human/donor = null // if I can't use "owner" I can at least use this
	var/donor_name = null // so you don't get dumb "Unknown's skull mask" shit
	var/donor_DNA = null
	var/datum/organHolder/holder = null
	var/list/organ_abilities = null

	var/op_stage = 0.0
	var/brute_dam = 0
	var/burn_dam = 0
	var/tox_dam = 0

	var/robotic = 0
	var/emagged = 0
	var/synthetic = 0
	var/broken = 0
	var/failure_disease = null		//The organ failure disease associated with this organ. Not used for Heart atm.

	var/MAX_DAMAGE = 100	//Max damage before organ "dies"
	var/FAIL_DAMAGE = 65	//Total damage amount at which organ failure starts

	var/created_decal = /obj/decal/cleanable/blood // what kinda mess it makes.  mostly so cyberhearts can splat oil on the ground, but idk maybe you wanna make something that creates a broken balloon or something on impact vOv
	var/decal_done = 0 // fuckers are tossing these around a lot so I guess they're only gunna make one, ever now
	var/body_side = null // L_ORGAN/1 for left, R_ORGAN/2 for right
	var/datum/bone/bones = null
	rand_pos = 1

	var/made_from = "flesh" //Material this organ will produce.

	attackby(obj/item/W as obj, mob/user as mob)
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
			src.take_damage(W.force, 0, 0, W.hit_type)

		..()


	New(loc, datum/organHolder/nholder)
		..()
		SPAWN_DBG(0)
			if (istype(nholder) && nholder.donor)
				src.holder = nholder
				src.donor = nholder.donor
			if (src.donor)
				if (src.donor.real_name)
					src.donor_name = src.donor.real_name
					src.name = "[src.donor_name]'s [initial(src.name)]"
				else if (src.donor.name)
					src.donor_name = src.donor.name
					src.name = "[src.donor_name]'s [initial(src.name)]"
				src.donor_DNA = src.donor.bioHolder ? src.donor.bioHolder.Uid : null
			src.setMaterial(getMaterial(made_from), appearance = 0, setname = 0)

	disposing()
		if (src.holder)
			for(var/thing in holder.organ_list)
				if(thing == "all")
					continue
				if(holder.organ_list[thing] == src)
					holder.organ_list[thing] = null

			//mbc : this following one might be unnecessary but organs are now GC-clean so im afraid to touch it
			for(var/i = 1, i < src.holder.organ_list.len, i++)
				if (src.holder.organ_list[i] == src)
					src.holder.organ_list[i] = null


		if (donor && donor.organs) //not all mobs have organs/organholders (fish)
			donor.organs -= src
		donor = null

		if (bones)
			bones.disposing()

		holder = null
		..()

	throw_impact(var/turf/T)
		playsound(src.loc, "sound/impact_sounds/Flesh_Stab_2.ogg", 100, 1)
		if (T && !src.decal_done && ispath(src.created_decal))
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
			make_cleanable(src.created_decal,T)
			src.decal_done = 1
		..() // call your goddamn parents

	//Returns true if the organ is broken or damage is over max health.
	//Under no circumstances should you ever reassign the donor or holder variables in here.
	//Not checking donor here because it's checked where it's called. And I can't think of ANY REASON to EVER call this from somewhere else. And if I do, then I'll delete this comment. - kyle
	proc/on_life(var/mult = 1)
		if (holder && (src.broken || src.get_damage() > MAX_DAMAGE) )
			return 0
		if (emagged && prob(30))	//don't really need to check for robotic too since no other types of organs can or should be emagged
			take_damage(1, 0, 0)

		return 1

	//What should happen each life tick when an organ is broken.
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


		//Kinda repeated below too. Cure the organ failure disease if this organ is above a certain HP
		if (src.donor)
			if (!src.broken  && failure_disease)
				src.donor.cure_disease(failure_disease)

			//all robotic organs have a base stamina buff, some have others, see heart. maybe lungs in future
			if (src.robotic)
				if (src.emagged)
					src.donor.add_stam_mod_regen("cyber-[src.organ_name]", 5)
					src.donor.add_stam_mod_max("cyber-[src.organ_name]", 20)
				else
					src.donor.add_stam_mod_regen("cyber-[src.organ_name]", 2)
					src.donor.add_stam_mod_max("cyber-[src.organ_name]", 10)

		if (islist(src.organ_abilities) && src.organ_abilities.len)
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
		//all robotic organs have a stamina buff we must remove
		if (src.donor)
			if (failure_disease)
				src.donor.cure_disease(failure_disease)

			if (src.robotic)
				if (src.emagged)
					src.donor.remove_stam_mod_regen("cyber-[src.organ_name]")
					src.donor.remove_stam_mod_max("cyber-[src.organ_name]")
				else
					src.donor.remove_stam_mod_regen("cyber-[src.organ_name]")
					src.donor.remove_stam_mod_max("cyber-[src.organ_name]")

		if (!src.donor_DNA && src.donor && src.donor.bioHolder)
			src.donor_DNA = src.donor.bioHolder.Uid
		if (islist(src.organ_abilities) && src.organ_abilities.len)// && src.donor.abilityHolder)
			var/datum/abilityHolder/aholder
			if (src.donor && src.donor.abilityHolder)
				aholder = src.donor.abilityHolder
			else if (src.holder && src.holder.donor && src.holder.donor.abilityHolder)
				aholder = src.holder.donor.abilityHolder
			if (istype(aholder))
				for (var/abil in src.organ_abilities)
					src.remove_ability(aholder, abil)


		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.robotic)
			return
		if (user)
			user.show_text("You disable the safety limiters on [src].", "red")
		src.visible_message("<span style=\"color:red\"><B>[src] sparks and shudders oddly!</B></span>", 1)
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
			src.take_damage(20, 20, 0)

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
#if ASS_JAM //timestop stuff
		if (ishuman(donor))
			var/mob/living/carbon/human/H = donor
			if (H.paused)
				H.pausedburn = max(0, H.pausedburn + burn)
				H.pausedbrute = max(0, H.pausedbrute + brute)
				return 0
#endif
		src.brute_dam += brute
		src.burn_dam += burn
		src.tox_dam += tox

		//I don't think this is used at all, but I'm afraid to get rid of it - Kyle
		if (ishuman(donor))
			var/mob/living/carbon/human/H = donor
			//hit_twitch(H)		//no
			H.UpdateDamage()
			if (bone_system && src.bones && brute && prob(brute * 2))
				src.bones.take_damage(damage_type)

		// if (src.get_damage() >= MAX_DAMAGE)
		if (brute_dam + burn_dam + tox_dam >= MAX_DAMAGE)
			src.broken = 1
			donor.contract_disease(failure_disease,null,null,1)

		return 1

	heal_damage(brute, burn, tox)
		if (broken || brute_dam <= 0 && burn_dam <= 0 && tox_dam <= 0)
			return 0
		src.brute_dam = max(0, src.brute_dam - brute)
		src.burn_dam = max(0, src.burn_dam - burn)
		src.tox_dam = max(0, src.tox_dam - tox)
		return 1

	get_damage()
		return src.brute_dam + src.burn_dam	+ src.tox_dam
