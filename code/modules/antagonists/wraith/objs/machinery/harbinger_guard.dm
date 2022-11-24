/obj/machinery/wraith/harbinger_guard
	name = "Ghostly sentry"
	icon = 'icons/obj/wraith_objects.dmi'
	icon_state = "harbinger_guard"
	desc = "An immobile guardian, ready to slam on anyone getting close to it."
	anchored = 1
	density = 1
	_health = 25
	var/mob/living/intangible/wraith/wraith_harbinger/master = null
	var/datum/light/light
	var/cooldown_attack = 8 SECONDS
	var/attack_delay = 1.2 SECONDS

	New(var/turf/T, var/mob/living/intangible/wraith/wraith_harbinger/W)
		src.set_loc(T)
		src.visible_message("<span class='alert'>A [src] manifests!</b></span>")
		light = new /datum/light/point
		light.set_brightness(0.1)
		light.set_color(150, 40, 40)
		light.attach(src)
		light.enable()
		START_TRACKING
		src.master = W
		setup_use_proximity()
		src.alpha = 0
		animate(src, alpha=255, time=2 SECONDS)
		ON_COOLDOWN(src, "attack", 3 SECONDS)
		..()

	process()
		if (GET_COOLDOWN(src, "attack"))
			return

		for (var/mob/living/M in range(src, 2))
			if ((ishuman(M) || issilicon(M)) && !isdead(M))
				ON_COOLDOWN(src, "attack", cooldown_attack)
				src.attack(M)
				UpdateIcon()
				break


	disposing()
		if (src.master != null)
			src.master.guard_amount --
		. = ..()

	attackby(obj/item/P as obj, mob/living/user as mob)
		src._health -= P.force
		attack_particle(user,src)
		user.lastattacked = src
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_3.ogg', 60, 1)
		if(src._health <= 0)
			qdel(src)

	HasProximity(atom/movable/AM)
		if (GET_COOLDOWN(src, "attack"))
			return

		if (isliving(AM))
			var/mob/M = AM
			if ((ishuman(M) || issilicon(M)) && !isdead(M))
				ON_COOLDOWN(src, "attack", cooldown_attack)
				src.attack(M)
				UpdateIcon()

	proc/attack(var/mob/living/M)
		var/list/attacked = list()
		var/direction = get_dir(src, M)
		src.set_dir(direction)
		var/turf/one = get_step(src, direction)
		new/obj/decal/guard_attack_marker(one, src.attack_delay)
		var/turf/two = get_step(one, direction)
		new/obj/decal/guard_attack_marker(two, src.attack_delay)
		SPAWN(src.attack_delay)
			if (!QDELETED(src))
				for(var/turf/T in list(one, two))
					for(var/atom/A in T)
						if(A in attacked) continue
						if(ismob(A) && !isobserver(A))
							var/mob/target_mob = A
							target_mob.TakeDamageAccountArmor("All", 18, 0, 0, DAMAGE_BLUNT)
							attacked += A
							playsound(src.loc, 'sound/impact_sounds/Generic_Hit_2.ogg', 80, 1)
							src.visible_message("<span class='combat'>[src] slams the ground and hits [target_mob]!</b></span>")
