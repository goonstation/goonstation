// ------
// Tackle
// ------
/datum/targetable/critter/selfdestruct
	name = "Self Destruct"
	desc = "Start your bomb timer"
	cooldown = 10
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
				boutput(holder.owner, __red("Nothing to tackle there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to tackle."))
			return 1
		// Duplication of /obj/item/old_grenade/stinger explosion
		var/turf/T = ..()
		if (T)
			playsound(T, "sound/weapons/grenade.ogg", 25, 1)
			explosion(holder.owner, T, -1, -1, -0.25, 1)
			var/obj/overlay/O = new/obj/overlay(get_turf(T))
			O.anchored = 1
			O.name = "Explosion"
			O.layer = NOLIGHT_EFFECTS_LAYER_BASE
			O.icon = 'icons/effects/64x64.dmi'
			O.icon_state = "explo_fiery"
			var/datum/projectile/special/spreader/uniform_burst/circle/PJ = new /datum/projectile/special/spreader/uniform_burst/circle(T)
			PJ.pellets_to_fire = 20
			var/targetx = holder.owner.y - rand(-5,5)
			var/targety = holder.owner.y - rand(-5,5)
			var/turf/newtarget = locate(targetx, targety, holder.owner.z)
			shoot_projectile_ST(holder.owner, PJ, newtarget)
			SPAWN_DBG(0.5 SECONDS)
				qdel(O)
				qdel(holder.owner)
		else
			qdel(holder.owner)
		return 0
