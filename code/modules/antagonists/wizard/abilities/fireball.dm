/datum/projectile/fireball
	name = "a fireball"
	icon_state = "fireball"
	icon = 'icons/obj/wizard.dmi'
	shot_sound = 'sound/effects/mag_fireballlaunch.ogg'
	damage = 30

	is_magical = 1
	var/fire_color = CHEM_FIRE_RED

	on_hit(atom/hit, direction, var/obj/projectile/projectile)
		var/turf/T = get_turf(hit) || get_turf(projectile)
		if (projectile.mob_shooter && projectile.mob_shooter:wizard_spellpower(projectile.mob_shooter:abilityHolder:getAbility(/datum/targetable/spell/fireball)))
			explosion_new(null, T, 3, 1.5, turf_safe = TRUE, range_cutoff_fraction = 0.75)
		else if(projectile.mob_shooter)
			if(prob(50))
				explosion_new(null, T, 2, 1.2, turf_safe = TRUE)
			boutput(projectile.mob_shooter, SPAN_NOTICE("Your spell is weakened without a staff to channel it."))
		fireflash(T, 1, checkLos = FALSE, chemfire = src.fire_color)

/datum/projectile/fireball/fire_elemental
	is_magical = 0

	on_hit(atom/hit, direction, obj/projectile/projectile)
		var/turf/T = get_turf(hit)
		explosion(projectile, T, -1, -1, 0, 1)
		fireflash(T, 1, checkLos = FALSE, chemfire = src.fire_color)

/datum/targetable/spell/fireball
	name = "Fireball"
	desc = "Launches an explosive fireball at the target."
	icon_state = "fireball"
	targeted = 1
	target_anything = 1
	cooldown = 400
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
			holder.owner.say("MHOL HOTTOV", flags = SAYFLAG_IGNORE_STAMINA, message_params = list("maptext_css_values" = src.maptext_style, "maptext_animation_colours" = src.maptext_colors))
		..()

		var/obj/projectile/P = initialize_projectile_pixel_spread( holder.owner, fb_proj, target)

		var/fire_color = CHEM_FIRE_RED

		var/mob/living/carbon/human/H = src.holder.owner
		if (istype(H))
			if (istype(H.head, /obj/item/clothing/head/wizard/red))
				fire_color = CHEM_FIRE_RED
			else if (istype(H.head, /obj/item/clothing/head/wizard/purple))
				fire_color = CHEM_FIRE_PURPLE
			else if (istype(H.head, /obj/item/clothing/head/wizard/green))
				fire_color = CHEM_FIRE_GREEN
			else if (istype(H.head, /obj/item/clothing/head/wizard/witch) || istype(H.head, /obj/item/clothing/head/wizard/necro))
				fire_color = CHEM_FIRE_BLACK
			else
				fire_color = CHEM_FIRE_BLUE

		if (P)
			var/datum/projectile/fireball/fireball = P.proj_data
			fireball.fire_color = fire_color
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
		. = ..()
		var/obj/projectile/P = initialize_projectile_pixel_spread( holder.owner, fb_proj, target )
		if (P)
			P.mob_shooter = holder.owner
			P.launch()
