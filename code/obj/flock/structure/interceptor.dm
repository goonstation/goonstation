/obj/flock_structure/interceptor
	icon_state = "interceptor-off" // placeholder sprites
	name = "gnesis fountain"
	desc = "Some sort of gnesis fountain. The gnesis appears very active."
	flock_desc = "A defense turret that fires high speed gnesis bolts at nearby projectiles, annihilating them."
	flock_id = "Interceptor"
	health = 50
	health_max = 50
	repair_per_resource = 2.5
	resourcecost = 100
	passthrough = TRUE
	show_in_tutorial = TRUE
	compute = 0
	var/online_compute_cost = 30

	/// if the interceptor has enough compute to work
	var/powered = FALSE
	/// if the interceptor's projectile checkers are checking for projectiles
	var/checkers_powered = FALSE

	/// projectile destroying radius of the interceptor
	var/checker_radius = 2
	/// list of projectile checker objects the interceptor uses to work
	var/list/projectile_checkers = null

	New(atom/location, datum/flock/F = null)
		..()
		var/turf/src_turf = get_turf(src)
		var/list/turfs = block(locate(max(src_turf.x - src.checker_radius, 1), max(src_turf.y - src.checker_radius, 1), src_turf.z), locate(min(src_turf.x + src.checker_radius, world.maxx), min(src_turf.y + src.checker_radius, world.maxy), src_turf.z))

		src.projectile_checkers = list()
		for (var/turf/T as anything in turfs)
			src.projectile_checkers += new /obj/interceptor_projectile_checker(T, src)

		src.info_tag.set_info_tag("Not generating bolt")

	building_specific_info()
		return src.check_bolt_status() + "."

	process(mult)
		if (src.flock?.can_afford_compute(src.online_compute_cost))
			src.compute = -src.online_compute_cost
			if (!src.powered)
				ON_COOLDOWN(src, "bolt_gen_time", 10 SECONDS)
				src.update_flock_compute("apply")
				src.powered = TRUE
		else if (!src.flock || src.flock.used_compute > src.flock.total_compute() || !src.powered)
			if (src.powered)
				if (src.flock)
					src.update_flock_compute("remove")
				if (src.checkers_powered)
					src.power_projectile_checkers(FALSE)
			src.compute = 0
			src.powered = FALSE

		if (src.powered)
			if (GET_COOLDOWN(src, "bolt_gen_time"))
				src.icon_state = "interceptor-generating"
				if (src.checkers_powered)
					src.power_projectile_checkers(FALSE)
			else
				src.icon_state = "interceptor-ready"
				if (!src.checkers_powered)
					src.power_projectile_checkers(TRUE)
		else
			src.icon_state = "interceptor-off"

		src.info_tag.set_info_tag(src.check_bolt_status())

	proc/power_projectile_checkers(state)
		for (var/obj/interceptor_projectile_checker/checker as anything in src.projectile_checkers)
			checker.on = state
		src.checkers_powered = state

	proc/check_bolt_status()
		if (!src.powered)
			return "Not generating bolt"
		else if (GET_COOLDOWN(src, "bolt_gen_time"))
			return "Generation time left: [round(GET_COOLDOWN(src, "bolt_gen_time") / 10)] seconds"
		else
			return "Bolt ready"

	proc/activate(obj/projectile/bullet)
		ON_COOLDOWN(src, "bolt_gen_time", 10 SECONDS)
		src.icon_state = "interceptor-generating"
		src.power_projectile_checkers(FALSE)
		var/list/gnesis_bolt_objs = DrawLine(src, bullet, /obj/line_obj/gnesis_bolt, 'icons/obj/projectiles.dmi', "WholeGnesisBolt", TRUE, TRUE, "HalfStartGnesisBolt", "HalfEndGnesisBolt")
		SPAWN(0.25 SECONDS)
			for (var/obj/line_obj/gnesis_bolt/gnesis_bolt_obj as anything in gnesis_bolt_objs)
				qdel(gnesis_bolt_obj)
		playsound(src, 'sound/weapons/railgun.ogg', 50, TRUE) // placeholder sound
		qdel(bullet)

	disposing()
		for (var/obj/interceptor_projectile_checker/checker as anything in src.projectile_checkers)
			qdel(checker)
			checker.connected_structure = null
		src.projectile_checkers = null
		..()


/obj/interceptor_projectile_checker
	name = null
	desc = null
	anchored = TRUE
	density = FALSE
	flags = UNCRUSHABLE
	event_handler_flags = IMMUNE_SINGULARITY
	invisibility = INVIS_ALWAYS
	opacity = FALSE
	mouse_opacity = 0

	var/on = FALSE
	var/obj/flock_structure/interceptor/connected_structure = null

	New(turf/T, obj/flock_structure/interceptor/interceptor)
		..()
		src.connected_structure = interceptor

	Crossed(atom/movable/AM)
		if (!istype(AM, /obj/projectile) || AM.disposed)
			return ..()
		if (!src.on || !src.connected_structure)
			return ..()
		if (GET_COOLDOWN(src.connected_structure, "bolt_gen_time"))
			return ..()
		var/obj/projectile/bullet = AM
		if (!istype(bullet.proj_data, /datum/projectile/bullet))
			return ..()
		for (var/obj/flock_structure/interceptor/interceptor in view(src.connected_structure.checker_radius, src))
			if (src.connected_structure == interceptor)
				src.connected_structure.activate(bullet)
				return
		..()

	ex_act(severity)
		return

/obj/line_obj/gnesis_bolt
	name = "gnesis bolt"
	desc = null
	anchored = TRUE
	density = FALSE
	flags = UNCRUSHABLE
	event_handler_flags = IMMUNE_SINGULARITY
	opacity = FALSE
