// -----------------
// Simple bite skill
// -----------------
/datum/targetable/critter/cauterize
	name = "Cauterize"
	desc = "Cauterize a mob, stopping all bleeding immediately but inflicting mild fire damage."
	icon_state = "fire_e_cauterize"
	cooldown = 150
	targeted = 1
	target_anything = 1

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to cauterize there.</span>")
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to cauterize.</span>")
			return 1
		var/mob/MT = target
		if (MT.is_heat_resistant())
			boutput(holder.owner, "<span class='alert'>[MT] cannot be cauterized.</span>")
			return 1
		MT.TakeDamage("All", 0, 8, 0, DAMAGE_BURN)
		holder.owner.visible_message("<span class='notice'><b>[holder.owner] cauterizes [MT]!</b></span>", "<span class='notice'>You cauterize [MT]!</span>")
		//if (MT.bleeding)
		//	boutput(MT, "<span class='notice'>Your bleeding stops!</span>")
		return 0
