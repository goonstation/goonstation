#define FAITH_SHOOT_COST 250
/obj/item/gun/faith
	name = "Faith"
	desc = "'Cause ya gotta have Faith."
	icon = 'icons/obj/items/guns/kinetic.dmi'
	icon_state = "faith"
	force = MELEE_DMG_PISTOL
	w_class = W_CLASS_SMALL
	muzzle_flash = null
	fire_animation = TRUE
	add_residue = TRUE
	current_projectile = new/datum/projectile/bullet/bullet_22

	canshoot(mob/user)
		if (!user.traitHolder.hasTrait("training_chaplain"))
			return 0

		var/datum/trait/job/chaplain/T = get_chaplain_trait(user)
		if (T.faith >= FAITH_SHOOT_COST)
			return 1
		return 0

	process_ammo(var/mob/user)
		var/datum/trait/job/chaplain/C = get_chaplain_trait(user)
		C.faith -= FAITH_SHOOT_COST
		var/turf/T = get_turf(src)
		if(T)
			new src.current_projectile.casing(T, src.forensic_ID)
		return 1

	examine(mob/user)
		. = ..()
		. += "There are 0 bullets left!"
		if (user.traitHolder.hasTrait("training_chaplain"))
			. += "If you have faith, maybe it will shoot."
