// ------------------------------------------------------------
// Experimental: charge-slam using a projectile as a line mover
// ------------------------------------------------------------
/datum/projectile/slam
	name = "slam"
	icon = null
	icon_state = "slam"
	damage = 1
	damage_type = D_SPECIAL
	hit_ground_chance = 0
	dissipation_delay = 3
	projectile_speed = 32
	dissipation_rate = 1
	shot_sound = null


	on_launch(var/obj/projectile/O)
		if (!("owner" in O.special_data))
			O.die()
			return
		O.special_data["valid_loc"] = get_turf(O)
		O.special_data["orig_turf"] = get_turf(O)
		var/datum/targetable/critter/slam/owner = O.special_data["owner"]
		var/mob/charger = owner.holder.owner
		O.special_data["charger"] = charger
		charger.transforming = 1
		charger.canmove = 0
		charger.set_loc(O)
		O.set_dir(angle_to_dir(O.angle))
		O.name = charger.name
		O.icon = null
		O.overlays += charger
		O.transform = null

	tick(var/obj/projectile/O)
		if (O.disposed)
			return
		var/mob/charger = O.special_data["charger"]
		var/obj/overlay/dummy = new(get_turf(O))
		dummy.mouse_opacity = 0
		dummy.name = null
		dummy.set_density(0)
		dummy.anchored = 1
		dummy.set_opacity(0)
		dummy.icon = null
		dummy.overlays += charger
		dummy.alpha = 255
		dummy.pixel_x = O.pixel_x
		dummy.pixel_y = O.pixel_y
		dummy.set_dir(O.dir)
		animate(dummy, alpha=0, time=3)
		SPAWN(0.3 SECONDS)
			qdel(dummy)

	on_hit(atom/hit, angle, var/obj/projectile/O)
		O.special_data["valid_loc"] = get_turf(hit)
		var/mob/charger = O.special_data["charger"]
		if (isturf(hit))
			hit.visible_message("<span class='alert'>[charger] slams into [hit]!</span>", "You hear something slam!")
			boutput(charger, "<span class='alert'>You slam into [hit]! Ouch!</span>")
			charger.changeStatus("stunned", 3 SECONDS)
			playsound(hit, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
		else if (isobj(hit))
			var/obj/H = hit
			if (H.anchored)
				hit.visible_message("<span class='alert'>[charger] slams into [hit]!</span>", "You hear something slam!")
				boutput(charger, "<span class='alert'>You slam into [hit]! Ouch!</span>")
				charger.changeStatus("stunned", 3 SECONDS)
				playsound(hit, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
			else
				hit.visible_message("<span class='alert'>[charger] slams into [hit]!</span>", "You hear something slam!")
				playsound(hit, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
				boutput(charger, "<span class='alert'>You slam into [hit]!</span>")
				var/kbdir = angle_to_dir(angle)
				step(H, kbdir, 2)
				if (prob(10))
					SPAWN(0.2 SECONDS)
						step(H, kbdir, 2)
		else if (ismob(hit))
			var/mob/M = hit
			playsound(hit, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
			hit.visible_message("<span class='alert'>[charger] slams into [hit]!</span>", "You hear something slam!")
			boutput(charger, "<span class='alert'>You slam into [hit]!</span>")
			boutput(M, "<span class='alert'><b>[charger] slams into you!</b></span>")
			logTheThing(LOG_COMBAT, charger, "slams [constructTarget(M,"combat")].")
			var/kbdir = angle_to_dir(angle)
			step(M, kbdir, 2)
			M.changeStatus("weakened", 4 SECONDS)

	on_end(var/obj/projectile/O)
		var/keys = ""
		for (var/dp in O.special_data)
			keys = "[keys][dp], "
		var/mob/charger = O.special_data["charger"] //can somehow get a null value???
		charger.transforming = 0
		charger.canmove = 1
		charger.set_loc(get_turf(O))
		charger.set_dir(get_dir(O.special_data["orig_turf"], charger.loc))
		if (!charger.loc)
			charger.set_loc(O.special_data["valid_loc"])

/datum/targetable/critter/slam
	name = "Slam"
	desc = "Charge over a short distance, until you hit a mob or an object. Knocks down mobs."
	icon_state = "slam"
	cooldown = 100
	targeted = 1
	target_anything = 1

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		var/turf/T = get_turf(target)
		if (!T)
			return 1
		var/mob/M = holder.owner
		var/turf/S = get_turf(M)
		var/obj/projectile/O = initialize_projectile_ST(S, proj, T)
		if (!O)
			return 1
		if (!O.was_setup)
			O.setup()
		O.special_data["owner"] = src
		O.launch()
		return 0

/datum/targetable/critter/slam_polymorph
	name = "Slam"
	desc = "Charge over a short distance, until you hit a mob or an object. Knocks down mobs."
	icon_state = "slam_polymorph"
	cooldown = 100
	targeted = 1
	target_anything = 1

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		var/turf/T = get_turf(target)
		if (!T)
			return 1
		var/mob/M = holder.owner
		var/turf/S = get_turf(M)
		var/obj/projectile/O = initialize_projectile_ST(S, proj, T)
		if (!O)
			return 1
		if (!O.was_setup)
			O.setup()
		O.special_data["owner"] = src
		O.launch()
		return 0
