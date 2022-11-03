/datum/targetable/brain_slug/spit_slime
	name = "Spit slime"
	desc = "Turn some of your host's insides into slime, locking down doors or debilitating attackers. Costs stability to use."
	icon_state = "slimeshot"
	cooldown = 20 SECONDS
	targeted = 1
	target_anything = 1
	pointCost = 40

	cast(atom/target)
		if (..())
			return 1

		var/mob/shooter = holder.owner
		var/obj/projectile/proj = initialize_projectile_ST(shooter, new/datum/projectile/special/spreader/uniform_burst/slime, get_turf(target))
		while (!proj || proj.disposed)
			proj = initialize_projectile_ST(shooter, new/datum/projectile/special/spreader/uniform_burst/slime, get_turf(target))

		proj.targets = list(target)

		proj.launch()
