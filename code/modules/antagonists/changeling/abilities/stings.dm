/datum/targetable/changeling/sting
	name = "Sting"
	desc = "Transfer some toxins into your target."
	var/stealthy = 1
	var/venom_id = "toxin"
	var/inject_amount = 50
	cooldown = 1400
	targeted = 1
	target_anything = 1
	target_in_inventory = 1
	sticky = 1

	proc/create_toxins()
		var/datum/reagents/temp_holder = new /datum/reagents(inject_amount)
		temp_holder.add_reagent(venom_id, inject_amount)
		return temp_holder

	cast(atom/target)
		if (..())
			return 1

		var/stinging_reagent_holder = FALSE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("We cannot reach that target with our stinger."))
			return 1
		if (target == holder.owner)
			return 1
		if (isobj(target) && (target.is_open_container(TRUE) || istype(target,/obj/item/reagent_containers/food) || istype(target,/obj/item/reagent_containers/patch)))
			stinging_reagent_holder = TRUE
		if (stinging_reagent_holder && !target.reagents)
			boutput(holder.owner, SPAN_NOTICE("We cannot seem to sting [target]."))
			return 1
		// stinging a mob should always work, so we need a separate check for plain old objects
		if (stinging_reagent_holder && (target.reagents.total_volume >= target.reagents.maximum_volume))
			boutput(holder.owner, SPAN_ALERT("[target] is full."))
			return 1
		if (istype(target,/obj/item/reagent_containers/patch))
			var/obj/item/reagent_containers/patch/P = target
			if (P.medical)
				//break the seal
				boutput(holder.owner, SPAN_ALERT("You break [P]'s tamper-proof seal!"))
				P.medical = 0
		var/datum/reagents/toxin_holder = src.create_toxins()
		if (!stinging_reagent_holder)
			if (isobj(target))
				target = get_turf(target)
			if (isturf(target))
				target = locate(/mob/living) in target
				if (!target)
					boutput(holder.owner, SPAN_ALERT("We cannot sting without a target."))
					return 1
			var/mob/MT = target
			if (!MT.reagents)
				boutput(holder.owner, SPAN_ALERT("That does not hold reagents, apparently."))
				return 1
			if (target == holder.owner)
				return 1
			// make some room in the target
			if (MT.reagents.total_volume + toxin_holder.total_volume > MT.reagents.maximum_volume)
				MT.reagents.remove_any((MT.reagents.total_volume + toxin_holder.total_volume) - MT.reagents.maximum_volume)
			if (isliving(MT))
				MT:was_harmed(holder.owner, special = "ling")
		if (!stealthy)
			holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] stings [target]!</b>"))
		else
			holder.owner.show_message(SPAN_NOTICE("We stealthily sting [target]."))
		toxin_holder.trans_to(target, toxin_holder.total_volume)
		logTheThing(LOG_COMBAT, holder.owner, "stings [constructTarget(target,"combat")] with [name] as a changeling [log_loc(holder.owner)].")
		return 0

	neurotoxin
		name = "Neurotoxin Sting"
		desc = "Transfer neurotoxin into your target. Very good at ambushing a single target."
		icon_state = "stingneuro"
		venom_id = "neurotoxin"

	neurodepressant
		name = "Neurodepressant Sting"
		desc = "Transfer neurodepressant into your target. Good for escaping chases and disorienting targets."
		icon_state = "stingdepres"
		venom_id = "neurodepressant"
		inject_amount = 5
		cooldown = 20 SECONDS

	hemotoxin
		name = "Hemotoxin Sting"
		desc = "Transfer hemotoxin into your target. Drains target's blood, may need multiple stings to be lethal."
		icon_state = "stinghemot"
		venom_id = "hemotoxin"
		inject_amount = 9
		cooldown = 300

	madness
		name = "Madness Toxin Sting"
		desc = "Transfer Rajaijah into your target. Causes a target to attack all nearby, but has a long cooldown and DNA cost."
		icon_state = "stingmadness"
		venom_id = "madness_toxin"
		inject_amount = 15
		pointCost = 5
		cooldown = 2400

	lsd
		name = "Hallucinogenic Sting"
		desc = "Transfer some LSD into your target."
		icon_state = "stinglsd"
		venom_id = "LSD"
		inject_amount = 30

	dna
		name = "DNA Sting"
		desc = "Injects stable mutagen and the blood of the selected victim into your target."
		icon_state = "stingdna"
		venom_id = "dna_mutagen"
		inject_amount = 30
		pointCost = 4
		var/datum/targetable/changeling/dna_target_select/targeting = null

		create_toxins()
			var/datum/reagents/temp_holder = ..()
			temp_holder.maximum_volume += 15
			temp_holder.add_reagent("blood", 15, targeting.dna_sting_target.bioHolder)
			return temp_holder

		New()
			..()

		onAttach(var/datum/abilityHolder/H)
			targeting = H.addAbility(/datum/targetable/changeling/dna_target_select)
			targeting.sting = src
			if (H.owner)
				object.suffix = "\[[holder.owner.name]\]"

	fartonium
		name = "Fartonium Sting"
		desc = "Let someone else let 'er rip"
		icon_state = "stingfart"
		venom_id = "fartonium"
		inject_amount = 25
		cooldown = 600

	simethicone
		name = "Anti-farting sting"
		desc = "You fartless bastard"
		icon_state = "stingnofart"
		venom_id = "anti_fart"
		inject_amount = 25
		cooldown = 600

	chemical
		name = "Neurotoxic Sting"
		desc = "Transfer chemicals into your target."
		icon_state = "stingneuro"
		venom_id = "neurotoxin"
		inject_amount = 50
		cooldown = 1400
		var/datum/targetable/changeling/sting_chem_select/targeting = null

		New()
			..()

		onAttach(var/datum/abilityHolder/H)
			targeting = H.addAbility(/datum/targetable/changeling/sting_chem_select)
			targeting.chemical = src

/datum/targetable/changeling/sting_chem_select
	name = "Cycle Stings"
	desc = "Cycle through available sting toxins"
	icon_state = "stingcycle"
	cooldown = 0
	targeted = 0
	target_anything = 0
	copiable = 0
	lock_holder = FALSE
	ignore_holder_lock = 1
	do_logs = FALSE
	var/list/possible_stings = list(
				/datum/targetable/changeling/sting/neurotoxin,
				/datum/targetable/changeling/sting/neurodepressant,
				/datum/targetable/changeling/sting/hemotoxin,
				/datum/targetable/changeling/sting/madness)
	var/current_sting_index = 1;
	var/datum/targetable/changeling/sting/chemical = null
	sticky = 1

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, SPAN_ALERT("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		current_sting_index +=1
		if (current_sting_index > length(possible_stings))
			current_sting_index = 1

		var/datum/targetable/changeling/sting/chosen_sting = possible_stings[current_sting_index]

		if (chemical)
			chemical.name = chosen_sting.name
			chemical.desc = chosen_sting.desc
			chemical.icon_state = chosen_sting.icon_state
			chemical.venom_id = chosen_sting.venom_id
			chemical.inject_amount = chosen_sting.inject_amount
			chemical.cooldown = chosen_sting.cooldown
			chemical.pointCost = chosen_sting.pointCost

		return 0

/datum/targetable/changeling/dna_target_select
	name = "Select DNA Sting target"
	desc = "Select target for DNA sting"
	icon_state = "stingdna"
	cooldown = 0
	targeted = 0
	target_anything = 0
	copiable = 0
	lock_holder = FALSE
	ignore_holder_lock = 1
	var/datum/absorbedIdentity/dna_sting_target = null
	var/datum/targetable/changeling/sting = null
	sticky = 1

	onAttach(var/datum/abilityHolder/G)
		var/datum/abilityHolder/changeling/H = G
		if (istype(H) && length(H.absorbed_dna) > 0)
			dna_sting_target = H.absorbed_dna[H.absorbed_dna[1]]

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, SPAN_ALERT("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		var/target_name = tgui_input_list(holder.owner, "Select new DNA sting target!", "DNA Sting Target", sortList(H.absorbed_dna, /proc/cmp_text_asc))
		if (!target_name)
			boutput(holder.owner, SPAN_NOTICE("We change our mind."))
			return 1

		dna_sting_target = H.absorbed_dna[target_name]
		if (sting)
			sting.object.suffix = "\[[target_name]\]"

		return 0
