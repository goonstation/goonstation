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
	var/knockback = FALSE

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
		dummy.anchored = ANCHORED
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
		..()
		O.special_data["valid_loc"] = get_turf(hit)
		var/mob/charger = O.special_data["charger"]
		if (isturf(hit))
			hit.visible_message(SPAN_ALERT("[charger] slams into [hit]!"), "You hear something slam!")
			boutput(charger, SPAN_ALERT("You slam into [hit]! Ouch!"))
			charger.changeStatus("stunned", 3 SECONDS)
			playsound(hit, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, TRUE, -1)
		else if (isobj(hit))
			var/obj/H = hit
			if (H.anchored)
				hit.visible_message(SPAN_ALERT("[charger] slams into [hit]!"), "You hear something slam!")
				boutput(charger, SPAN_ALERT("You slam into [hit]! Ouch!"))
				charger.changeStatus("stunned", 3 SECONDS)
				playsound(hit, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, TRUE, -1)
			else
				hit.visible_message(SPAN_ALERT("[charger] slams into [hit]!"), "You hear something slam!")
				playsound(hit, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, TRUE, -1)
				boutput(charger, SPAN_ALERT("You slam into [hit]!"))
				var/kbdir = angle_to_dir(angle)
				step(H, kbdir, 2)
				if (prob(10))
					SPAWN(0.2 SECONDS)
						step(H, kbdir, 2)
		else if (ismob(hit))
			var/mob/M = hit
			playsound(hit, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, TRUE, -1)
			hit.visible_message(SPAN_ALERT("[charger] slams into [hit]!"), "You hear something slam!")
			boutput(charger, SPAN_ALERT("You slam into [hit]!"))
			boutput(M, SPAN_ALERT("<b>[charger] slams into you!</b>"))
			logTheThing(LOG_COMBAT, charger, "slams [constructTarget(M,"combat")].")
			var/kbdir = angle_to_dir(angle)
			if(knockback)
				M.throw_at(get_edge_target_turf(M, get_dir_accurate(O.shooter, M)), 5, 1) //adds knockback to the slam. (I did not make these values adjustable)
			step(M, kbdir, 2)
			M.changeStatus("knockdown", 4 SECONDS)

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

/datum/projectile/slam/fermid
	knockback = TRUE

/datum/targetable/critter/slam
	name = "Slam"
	desc = "Charge over a short distance, until you hit a mob or an object. Knocks down mobs."
	icon_state = "slam"
	cooldown = 10 SECONDS
	targeted = TRUE
	target_anything = TRUE
	var/proj = new /datum/projectile/slam()

	cast(atom/target)
		if (..())
			return TRUE
		var/turf/T = get_turf(target)
		if (!T)
			return TRUE
		var/mob/M = holder.owner
		var/turf/S = get_turf(M)
		var/obj/projectile/O = initialize_projectile_pixel_spread(S, proj, T)
		O.special_data["owner"] = src
		O.launch()
		return FALSE

	polymorph
		icon_state = "slam_polymorph"

/datum/targetable/critter/slam/fermid
	name = "Slam"
	desc = "Throw yourself at your target to knock them back."
	icon_state = "slam_fermid"
	cooldown = 20 SECONDS
	targeted = TRUE
	target_anything = TRUE
	proj = new /datum/projectile/slam/fermid
