// -----------------
// Simple bite skill
// -----------------
/datum/targetable/critter/blood_bite
	name = "Blood Bite"
	desc = "Bite someone and take a tiny amount of blood."
	cooldown = 10 SECONDS
	targeted = 1
	target_anything = 1
	icon_state = "bloodbite"

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to bite there.</span>")
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to bite.</span>")
			return 1
		playsound(target,'sound/items/drink.ogg', rand(10,50), 1, pitch = 1.4)
		var/mob/M = target

		holder.owner.visible_message("<span class='alert'><b>[holder.owner] sucks some blood from [M]!</b></span>", "<span class='alert'>You suck some blood from [M]!</span>")
		holder.owner.reagents.add_reagent("blood", 1)
		if (isliving(M))
			if (M.reagents)
				holder.owner.reagents.trans_to(M,0.1) //swap a bit ;)
				M.reagents.trans_to(holder.owner,1.1)
			if (ishuman(M))
				var/mob/living/carbon/human/HH = M
				HH.blood_volume -= 1

		holder.owner.TakeDamage("All", -5, -5)
		return 0
