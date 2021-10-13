// -------------------------
// Inject someone with venom
// -------------------------
/datum/targetable/critter/sting
	name = "Venomous Sting"
	desc = "Transfer some toxins into your target."
	var/stealthy = 0
	var/list/venom_ids = list("toxin")
	var/inject_amount = 25
	icon_state = "fermid_sting"
	cooldown = 60 SECONDS
	targeted = 1
	target_anything = 1

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("Nothing to sting there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to sting."))
			return 1
		var/mob/MT = target
		if (!MT.reagents)
			boutput(holder.owner, __red("That does not hold reagents, apparently."))
		if (!stealthy)
			holder.owner.visible_message(__red("<b>[holder.owner] stings [target]!</b>"))
		else
			holder.owner.show_message(__blue("You stealthily sting [target]."))
		for(var/venom_id in src.venom_ids)
			MT.reagents.add_reagent(venom_id, inject_amount)

	ice
		name = "Freezing Sting"
		desc = "Transfer some cryostylane into your target."
		venom_ids = list("cryostylane")

	sedative
		name = "Sedative Sting"
		desc = "Transfer some morphine into your target."
		venom_ids = list("morphine")

	eggs
		name = "Plant Eggs"
		desc = "Inject eggs into your target."
		venom_ids = list("spidereggs")
		inject_amount = 6

	fermid
		name = "Fermid Sting"
		desc = "Sting a dude with some nasty toxins."
		icon_state = "fermid_sting"
		venom_ids = list("haloperidol", "atropine")
		inject_amount = 10

	fermid_polymorph
		name = "Fermid Sting"
		desc = "Sting an adjacent target with some nasty toxins."
		icon_state = "fermid_sting"
		venom_ids = list("ants", "histamine")
		inject_amount = 8
