/datum/targetable/changeling/sting
	name = "Sting"
	desc = "Transfer some toxins into your target."
	var/stealthy = 1
	var/venom_id = "toxin"
	var/inject_amount = 50
	cooldown = 900
	targeted = 1
	target_anything = 1
	target_in_inventory = 1
	sticky = 1

	cast(atom/target)
		if (..())
			return 1

		if (target.is_open_container() || istype(target,/obj/item/reagent_containers/food) || istype(target,/obj/item/reagent_containers/patch))
			if (get_dist(holder.owner, target) > 1)
				boutput(holder.owner, __red("We cannot reach that target with our stinger."))
				return 1
			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				boutput(holder.owner, "<span class='alert'>[target] is full.</span>")
				return 1
			if (istype(target,/obj/item/reagent_containers/patch))
				var/obj/item/reagent_containers/patch/P = target
				if (P.medical)
					//break the seal
					boutput(holder.owner, "<span class='alert'>You break [P]'s tamper-proof seal!</span>")
					P.medical = 0
			logTheThing("combat", holder.owner, target, "stings [target] with [name] as a changeling at [log_loc(holder.owner)].")
			target.reagents.add_reagent(venom_id, inject_amount)
			holder.owner.show_message(__blue("We stealthily sting [target]."))
			return 0


		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("We cannot sting without a target."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("We cannot reach that target with our stinger."))
			return 1
		var/mob/MT = target
		if (!MT.reagents)
			boutput(holder.owner, __red("That does not hold reagents, apparently."))
			return 1
		if (!stealthy)
			holder.owner.visible_message(__red("<b>[holder.owner] stings [target]!</b>"))
		else
			holder.owner.show_message(__blue("We stealthily sting [target]."))
		MT.reagents?.add_reagent(venom_id, inject_amount)

		if (isliving(MT))
			MT:was_harmed(holder.owner, special = "ling")
		logTheThing("combat", holder.owner, MT, "stings [constructTarget(MT,"combat")] with [name] as a changeling [log_loc(holder.owner)].")

	neurotoxin
		name = "Neurotoxic Sting"
		desc = "Transfer some neurotoxin into your target."
		icon_state = "stingneuro"
		venom_id = "neurotoxin"

	//neuro replacement for RP
	capulettium
		name = "Capulettium Sting"
		desc = "Transfer some capulettium into your target."
		icon_state = "stingneuro"
		venom_id = "capulettium"
		inject_amount = 20

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

		New()
			..()

		onAttach(var/datum/abilityHolder/H)
			targeting = H.addAbility(/datum/targetable/changeling/dna_target_select)
			targeting.sting = src
			if (H.owner)
				object.suffix = "\[[holder.owner.name]\]"

		cast(atom/target)
			if (..())
				return 1
			if (target.is_open_container() == 1 || istype(target,/obj/item/reagent_containers/food) || istype(target,/obj/item/reagent_containers/patch))
				if (target.reagents.total_volume >= target.reagents.maximum_volume)
					return 0
				var/max_amount = min(15,target.reagents.maximum_volume - target.reagents.total_volume)
				target.reagents?.add_reagent("blood", max_amount, targeting.dna_sting_target)
				return 0
			var/mob/MT = target
			MT.reagents?.add_reagent("blood", 15, targeting.dna_sting_target)
			return 0

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


/datum/targetable/changeling/dna_target_select
	name = "Select DNA Sting target"
	desc = "Select target for DNA sting"
	icon_state = "stingdna"
	cooldown = 0
	targeted = 0
	target_anything = 0
	copiable = 0
	dont_lock_holder = 1
	ignore_holder_lock = 1
	var/datum/bioHolder/dna_sting_target = null
	var/datum/targetable/changeling/sting = null
	sticky = 1

	onAttach(var/datum/abilityHolder/G)
		var/datum/abilityHolder/changeling/H = G
		if (istype(H) && H.absorbed_dna.len > 0)
			dna_sting_target = H.absorbed_dna[H.absorbed_dna[1]]

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, __red("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		var/target_name = input("Select new DNA sting target!", "DNA Sting Target", null) as null|anything in H.absorbed_dna
		if (!target_name)
			boutput(holder.owner, __blue("We change our mind."))
			return 1

		dna_sting_target = H.absorbed_dna[target_name]
		if (sting)
			sting.object.suffix = "\[[target_name]\]"

		return 0
