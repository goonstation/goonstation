/datum/projectile/fourtymm
	name = "40mm projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "40mmgatling"
//How much of a punch this has, tends to be seconds/damage before any resist
	damage = 3
//How much ammo this costs
	cost = 1
//How fast the power goes away
	dissipation_rate = 1
//How many tiles till it starts to lose power
	dissipation_delay = 10
//name of the projectile setting, used when you change a guns setting
	sname = "40mm"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/gauss40mm.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
//What is our damage type
/*
kinetic - raw power
piercing - punches though things
slashing - cuts things
energy - energy
burning - hot
radioactive - rips apart cells or some shit
toxic - poisons
*/
	damage_type = D_PIERCING
	armor_ignored = 0.66
	//With what % do we hit mobs laying down
	hit_ground_chance = 90
	//Can we pass windows
	window_pass = 0
	brightness = 0.5
	color_red = 0.8
	color_green = 0
	color_blue = 0
	impact_image_state = "bhole-large"


//Any special things when it hits shit?
	on_hit(atom/hit)
		new/obj/overlay/fourtymmhit(hit.loc)
		return

/obj/overlay/fourtymmhit
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "40mmgatlingimpact"
	name = "sparks"
	density = 0
	opacity = 0
	anchored = 1
	New()
		..()
		src.pixel_x = rand(-8,8)
		src.pixel_y = rand(-8,8)
		SPAWN(0.5 SECONDS)	qdel(src)
