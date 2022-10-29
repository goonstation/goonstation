/datum/projectile/fireball
	name = "a fireball"
	icon_state = "fireball"
	icon = 'icons/obj/wizard.dmi'
	shot_sound = 'sound/effects/mag_fireballlaunch.ogg'

	is_magical = 1

	on_hit(atom/hit, direction, var/obj/projectile/projectile)
		var/turf/T = get_turf(hit)
		if (projectile.mob_shooter && projectile.mob_shooter:wizard_spellpower(projectile.mob_shooter:abilityHolder:getAbility(/datum/targetable/spell/fireball)))
			explosion(projectile, T, -1, -1, 2, 2)
		else if(projectile.mob_shooter)
			if(prob(50))
				explosion(projectile, T, -1, -1, 1, 1)
			boutput(projectile.mob_shooter, "<span class='notice'>Your spell is weakened without a staff to channel it.</span>")
		fireflash(T, 1, 1)

/datum/projectile/fireball/fire_elemental
	is_magical = 0

	on_hit(atom/hit, direction, obj/projectile/projectile)
		var/turf/T = get_turf(hit)
		explosion(projectile, T, -1, -1, 0, 1)
		fireflash(T, 1, 1)

/datum/targetable/spell/fireball
	name = "Fireball"
	desc = "Launches an explosive fireball at the target."
	icon_state = "fireball"
	targeted = 1
	target_anything = 1
	cooldown = 350
	requires_robes = 1
	requires_being_on_turf = TRUE
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

		var/obj/projectile/P = initialize_projectile_ST( holder.owner, fb_proj, target)
		if (P)
			P.mob_shooter = holder.owner
			P.launch()

/datum/targetable/critter/fireball
	name = "Fireball"
	icon_state = "fire-e-fireball"
	desc = "Launches an explosive fireball at the target."
	cooldown = 500
	targeted = 1
	target_anything = 1

	var/datum/projectile/fireball/fire_elemental/fb_proj = new

	cast(atom/target)
		var/obj/projectile/P = initialize_projectile_ST( holder.owner, fb_proj, target )
		logTheThing(LOG_COMBAT, usr, "used their [src.name] ability at [log_loc(usr)]")
		if (P)
			P.mob_shooter = holder.owner
			P.launch()
