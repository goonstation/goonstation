// -----------------
// Simple bite skill
// -----------------
/datum/targetable/critter/dna_gnaw
	name = "Gnaw"
	desc = "Sink your teeth into a mob in an attempt to rob them of some DNA."
	cooldown = 200
	targeted = 1
	target_anything = 1
	icon_state = "gnaw"

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
		playsound(target, 'sound/impact_sounds/Flesh_Tear_1.ogg', 50, 1, -1)
		var/mob/M = target

		holder.owner.visible_message("<span class='alert'><b>[holder.owner] gnaws into [M]!</b></span>", "<span class='alert'>We sink our teeth into [M]!</span>")
		if (istype(holder.owner, /mob/living/critter/changeling/handspider) && isliving(M))
			var/mob/living/carbon/human/H = M
			//Only able to absorb 4 dna points from a living target (out of a total of 10)
			if (!istype(H))
				boutput(holder.owner, "<span class='alert'>This creature is not compatible with our biology.</span>")
			else if (isnpcmonkey(H))
				boutput(holder.owner, "<span class='alert'>Our hunger will not be satisfied by this lesser being.</span>")
			else if (isnpc(H))
				boutput(holder.owner, "<span class='alert'>The DNA of this target seems inferior somehow, you have no desire to feed on it.</span>")
			else if (H.dna_to_absorb > 0 && (isdead(H) || H.dna_to_absorb > 6))
				var/absorbed = 1
				if (isdead(H) && H.dna_to_absorb > 1)
					absorbed = 2
				boutput(holder.owner, "<span class='notice'>We gain [absorbed] DNA from [H].</span>")
				holder.owner:absorbed_dna += absorbed
				H.dna_to_absorb -= absorbed

				if (H.blood_volume > 5)
					H.blood_volume -= 5

				if (H.dna_to_absorb <= 0)
					logTheThing(LOG_COMBAT, holder.owner, "drains [constructTarget(H,"combat")] of all DNA as a handspider [log_loc(holder.owner)].")
					H.real_name = "Unknown"
					H.bioHolder.AddEffect("husk")
			else
				boutput(holder.owner, "<span class='notice'>We cannot gain any DNA from [H] in their current state.</span>")

		holder.owner.TakeDamage("All", -5, -5)
		M.TakeDamageAccountArmor("All", 5, 0, 0, DAMAGE_CRUSH)
		return 0
