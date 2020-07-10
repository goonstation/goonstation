/datum/projectile/fireball
	name = "a fireball"
	icon_state = "fireball"
	icon = 'icons/obj/wizard.dmi'
	shot_sound = 'sound/effects/mag_fireballlaunch.ogg'

	is_magical = 1

	on_hit(atom/hit, direction, var/obj/projectile/projectile)
		var/turf/T = get_turf(hit)
		if (projectile.mob_shooter && projectile.mob_shooter:wizard_spellpower())
			explosion(projectile, T, -1, -1, 2, 2)
		else if(projectile.mob_shooter)
			if(prob(50))
				explosion(projectile, T, -1, -1, 1, 1)
			boutput(projectile.mob_shooter, "<span class='notice'>Your spell is weakened without a staff to channel it.</span>")
		fireflash(T, 1, 1)

/datum/targetable/spell/fireball
	name = "Fireball"
	desc = "Launches an explosive fireball at the target."
	icon_state = "fireball"
	targeted = 1
	target_anything = 1
	cooldown = 350
	requires_robes = 1
	offensive = 1
	sticky = 1
	voice_grim = "sound/voice/wizard/FireballGrim.ogg"
	voice_fem = "sound/voice/wizard/FireballFem.ogg"
	voice_other = "sound/voice/wizard/FireballLoud.ogg"

	var/datum/projectile/fireball/fb_proj = new

	cast(atom/target)
		holder.owner.say("MHOL HOTTOV")
		..()

		var/obj/projectile/P = initialize_projectile_ST( holder.owner, fb_proj, target )
		if (P)
			P.mob_shooter = holder.owner
			P.launch()
