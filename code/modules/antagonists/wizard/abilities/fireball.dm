/datum/projectile/fireball
	name = "a fireball"
	icon_state = "fireball"
	icon = 'icons/obj/wizard.dmi'
	shot_sound = 'sound/effects/mag_fireballlaunch.ogg'
	damage = 30
	/// TRUE if we have sufficient spell power for a powerful fireball, FALSE otherwise. Defaults to TRUE for edge case uses.
	var/has_spell_power = TRUE

	is_magical = TRUE

	on_hit(atom/hit, direction, var/obj/projectile/projectile)
		var/turf/T = get_turf(hit)
		if (src.has_spell_power)
			explosion_new(null, T, 3, 1.5, turf_safe = TRUE, range_cutoff_fraction = 0.75)
		else
			explosion_new(null, T, 2, 1.2, turf_safe = TRUE)
			boutput(projectile.mob_shooter, "<span class='notice'>Your spell is weakened without a staff to channel it.</span>")
		fireflash(T, 1, 1)

/datum/projectile/fireball/fire_elemental
	is_magical = FALSE

	on_hit(atom/hit, direction, obj/projectile/projectile)
		var/turf/T = get_turf(hit)
		explosion(projectile, T, -1, -1, 0, 1)
		fireflash(T, 1, 1)

/datum/targetable/spell/fireball
	name = "Fireball"
	desc = "Launches an explosive fireball at the target."
	icon_state = "fireball"
	targeted = TRUE
	target_anything = TRUE
	cooldown = 40 SECONDS
	requires_robes = 1
	can_cast_from_container = FALSE
	offensive = 1
	sticky = 1
	voice_grim = 'sound/voice/wizard/FireballGrim.ogg'
	voice_fem = 'sound/voice/wizard/FireballFem.ogg'
	voice_other = 'sound/voice/wizard/FireballLoud.ogg'

	var/datum/projectile/fireball/fb_proj = new
	maptext_colors = list("#fcdf74", "#eb9f2b", "#d75015")

	cast(atom/target)
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("MHOL HOTTOV", FALSE, maptext_style, maptext_colors)
		..()

		var/obj/projectile/P = initialize_projectile_pixel_spread( holder.owner, fb_proj, target)
		if (P)
			P.mob_shooter = holder.owner
			fb_proj.has_spell_power = src.wiz_holder.wizard_spellpower(src)
			P.launch()

/datum/targetable/critter/fireball
	name = "Fireball"
	icon_state = "fire-e-fireball"
	desc = "Launches an explosive fireball at the target."
	cooldown = 50 SECONDS
	targeted = TRUE
	target_anything = TRUE

	var/datum/projectile/fireball/fire_elemental/fb_proj = new

	cast(atom/target)
		var/obj/projectile/P = initialize_projectile_pixel_spread( holder.owner, fb_proj, target )
		logTheThing(LOG_COMBAT, usr, "used their [src.name] ability at [log_loc(usr)]")
		if (P)
			P.mob_shooter = holder.owner
			P.launch()
