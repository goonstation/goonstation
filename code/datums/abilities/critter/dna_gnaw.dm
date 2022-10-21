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

	var/datum/projectile/slam/proj = new

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
			var/mob/living/MT = M
			//Only able to absorb 4 dna points from a living target (out of a total of 10)
			if (istype (MT,/mob/living/carbon/human) && (istype(MT:mutantrace, /datum/mutantrace/monkey) || isnpc(MT)))
				boutput(holder.owner, "<span class='alert'>Our hunger will not be satisfied by this lesser being.</span>")
			else if (MT.dna_to_absorb > 0 && (isdead(MT) || MT.dna_to_absorb > 6))
				var/absorbed = 1
				if (isdead(MT) && MT.dna_to_absorb > 1)
					absorbed = 2
				boutput(holder.owner, "<span class='notice'>We gain [absorbed] DNA from [MT].</span>")
				holder.owner:absorbed_dna += absorbed
				MT.dna_to_absorb -= absorbed

				if (ishuman(MT))
					if (MT:blood_volume > 5)
						MT:blood_volume -= 5

				if (MT.dna_to_absorb <= 0)
					logTheThing(LOG_COMBAT, holder.owner, "drains [constructTarget(MT,"combat")] of all DNA as a handspider [log_loc(holder.owner)].")
					MT.real_name = "Unknown"
					MT.bioHolder.AddEffect("husk")
			else
				boutput(holder.owner, "<span class='notice'>We cannot gain any DNA from [MT] in their current state.</span>")

		holder.owner.TakeDamage("All", -5, -5)
		M.TakeDamageAccountArmor("All", 5, 0, 0, DAMAGE_CRUSH)
		return 0
