/datum/projectile/ectoblaster
	name = "ectobolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ecto"
	stun = 4
	cost = 20
	dissipation_rate = 2
	dissipation_delay = 4
	sname = "dewraithize"
	shot_sound = 'sound/weapons/Taser.ogg'
	shot_number = 1

	damage_type = 0
	hit_ground_chance = 0
	window_pass = 0
	brightness = 0.8
	color_red = 0.6
	color_green = 0.9
	color_blue = 0.2

	disruption = 0

	hits_ghosts = 1
	hits_wraiths = 1

	on_hit(atom/hit)
		if(istype(hit, /mob/living/intangible/wraith))
			var/mob/living/intangible/wraith/W = hit
			W.changeStatus("corporeal", 1.5 SECONDS, TRUE)
			W.TakeDamage(null, 0, src.power)
		// kyle TODO: add Spooktober stuff, sucking energy from ghosts or something
		// add some flavourful harmless interaction when hitting humans?
