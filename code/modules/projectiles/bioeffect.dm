/datum/projectile/bioeffect_beam
	name = "ionising blast"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "wave-g"
	brightness = 1
	//How much of a punch this has, tends to be seconds/damage before any resist
	power = 0
	//How much ammo this costs
	cost = 50
	//How fast the power goes away
	dissipation_rate = 1
	//How many tiles till it starts to lose power
	dissipation_delay = 10
	//Kill/Stun ratio
	ks_ratio = 0
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

	var/bioeffect = ""

	on_hit(atom/hit)
		if (ismob(hit))
			var/mob/M = hit
			if (M.bioHolder.HasEffect(src.bioeffect))
				return
			M.bioHolder.AddEffect(src.bioeffect)
		return

/datum/projectile/bioeffect_beam/stinky
	bioeffect = "sims_stinky"


