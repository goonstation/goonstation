/datum/projectile/bioeffect_beam
	name = "ionising blast"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "wave-g"
	brightness = 1
	damage = 1
	damage_type = D_SPECIAL
	//How much ammo this costs
	cost = 50
	//How fast the power goes away
	dissipation_rate = 0
	//How many tiles till it starts to lose power
	dissipation_delay = 10
	//name of the projectile setting, used when you change a guns setting
	sname = "mutation beam"
	//file location for the sound you want it to play
	shot_sound = 'sound/effects/splort.ogg'
	//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
	//What is our damage type
	damage_type = 0
	//With what % do we hit mobs laying down
	hit_ground_chance = 10
	//Can we pass windows
	window_pass = 0
	projectile_speed = 20

	max_range = 10
	has_impact_particles = TRUE
	kinetic_impact = FALSE
	var/bioeffect = ""

	on_hit(atom/hit)
		if (ismob(hit))
			var/mob/M = hit
			if (M.bioHolder.HasEffect(src.bioeffect))
				return
			M.bioHolder.AddEffect(src.bioeffect)
		return

/datum/projectile/bioeffect_beam/stinky
	sname = "stink ray"
	bioeffect = "sims_stinky"


