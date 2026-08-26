
TYPEINFO(/datum/random_event/major/white_hole)
	initialization_args = list(
		EVENT_INFO("target_turf", DATA_INPUT_REFPICKER, "Pick location"),
		EVENT_INFO_EXT("grow_duration", DATA_INPUT_NUM, "White Hole Growth Time", 0, 1 HOUR),
		EVENT_INFO_EXT("duration", DATA_INPUT_NUM, "White Hole Duration", 0, 1 HOUR),
		EVENT_INFO_EXT("activity_modifier", DATA_INPUT_NUM, "White Hole Activity Modifier", 0, 250),
		EVENT_INFO_EXT("source_location", DATA_INPUT_LIST_CHILDREN_OF, "Pick source location", /datum/whitehole_spawner)
	)


/datum/random_event/major/white_hole
	name = "White Hole"
	required_elapsed_round_time = 20 MINUTES
	customization_available = TRUE

	var/turf/target_turf
	var/grow_duration = 2 MINUTES
	var/duration = 40 SECONDS
	var/source_location = null
	var/activity_modifier = 1

	admin_call(source)
		if (..())
			return
		var/datum/random_event_editor/E = new /datum/random_event_editor(usr, src)
		if(E)
			E.ui_interact(usr)
		else
			switch(tgui_alert(usr, "Do you want to pick white hole location?", "Pick location", list("Pick", "Random", "Cancel")))
				if("Pick")
					target_turf = get_turf(pick_ref(usr))
					if(isnull(target_turf))
						boutput(usr, SPAN_ALERT("Cancelled. You must select a turf."))
						return
				if("Random")
					target_turf = null
				if("Cancel")
					boutput(usr, SPAN_ALERT("Cancelled."))
					return

			grow_duration = tgui_input_number(usr, "How long should it take for the white hole to grow?", "White Hole Growth Time", 2 MINUTES, 1 HOUR, 0)
			if(isnull(grow_duration))
				boutput(usr, SPAN_ALERT("Cancelled."))
				return

			duration = tgui_input_number(usr, "How long should the white hole be active?", "White Hole Duration", 40 SECONDS, 1 HOUR, 0)
			if(isnull(duration))
				boutput(usr, SPAN_ALERT("Cancelled."))
				return

			switch(tgui_alert(usr, "Do you want to pick white hole source location?", "Pick source location", list("Pick", "Random", "Cancel")))
				if("Pick")
					var/list/spawner_list = concrete_typesof(/datum/whitehole_spawner/main)
					var/list/datum/whitehole_spawner/pick_list = list()
					for(var/spawner_type in spawner_list)
						var/datum/whitehole_spawner/spawner = new spawner_type
						pick_list[spawner.name] = spawner
					source_location = tgui_input_list(usr, "Which white hole source location?", "White Hole Source Location", pick_list)
				if("Random")
					source_location = null
				if("Cancel")
					boutput(usr, SPAN_ALERT("Cancelled."))
					return

			activity_modifier = tgui_input_number(usr, "How much should the white hole activity be modified?", "White Hole Activity Modifier", 1, 10, 0, round_input=FALSE)

			src.event_effect(source, target_turf, grow_duration, duration, source_location, activity_modifier)

	event_effect(source)
		..()
		var/turf/T = target_turf
		if (isatom(T))
			T = get_turf(target_turf)
		if (!istype(T,/turf/))
			if(isnull(random_floor_turfs))
				build_random_floor_turf_list()
			while(isnull(T) || istype(T, /turf/simulated/floor/airless/plating/catwalk) || total_density(T) > 0 || !istype(T.loc, /area/station))
				T = pick(random_floor_turfs)
				if(prob(1)) break // prevent infinite loop

		if(isnull(grow_duration))
			grow_duration = 2 MINUTES + rand(-30 SECONDS, 30 SECONDS)

		if(isnull(duration))
			duration = 40 SECONDS + rand(-10 SECONDS, 10 SECONDS)

		var/obj/whitehole/whitehole = new (T, grow_duration, duration, source_location, TRUE)
		whitehole.activity_modifier = activity_modifier
		message_admins("White Hole anomaly with origin [whitehole.source_location.name] spawning in [log_loc(T)]")
		message_ghosts("<b>\A [whitehole.source_location.name] white hole</b> is spawning at [log_loc(T, ghostjump=TRUE)].")
		logTheThing(LOG_ADMIN, usr, "Spawned a white hole anomaly with origin [whitehole.source_location.name] at [log_loc(T)]")
		src.cleanup()

	cleanup()
		src.target_turf = initial(src.target_turf)
		src.grow_duration = initial(src.grow_duration)
		src.duration = initial(src.duration)
		src.source_location = initial(src.source_location)
		src.activity_modifier = initial(src.activity_modifier)


ADMIN_INTERACT_PROCS(/obj/whitehole, proc/admin_activate)
/obj/whitehole
	name = "white hole"
	icon = 'icons/effects/160x160.dmi'
	desc = "HHHAAA KCUF KCUF KCUF"
	icon_state = "whole"
	opacity = 0
	density = 1
	anchored = ANCHORED_ALWAYS
	pixel_x = -64
	pixel_y = -64
	event_handler_flags = IMMUNE_SINGULARITY
	plane = PLANE_NOSHADOW_BELOW
	pixel_point = TRUE
	var/datum/whitehole_spawner/source_location = null
	var/start_time
	var/state = "static"
	var/triggered_by_event = FALSE
	var/grow_duration = 0
	var/active_duration = 0
	var/activity_modifier = 1.0 // multiplies how many objects spawn each "tick"
	var/datum/light/light = null

	New(var/loc, grow_duration = 0, active_duration = null, spawner_set = null, triggered_by_event = FALSE)
		..()
		src.start_time = TIME
		src.triggered_by_event = triggered_by_event
		src.grow_duration = grow_duration

		if (active_duration < 1)
			active_duration = rand(5 SECONDS, 40 SECONDS)
		src.active_duration = active_duration

		if(ispath(text2path(spawner_set), /datum/whitehole_spawner))
			var/datum/whitehole_spawner/new_spawner = new spawner_set
			src.source_location = new_spawner
		else if(isnull(spawner_set))
			src.source_location = choose_location()
		else
			src.source_location = spawner_set

		var/image/illum = image(src.icon, src.icon_state)
		illum.plane = PLANE_LIGHTING
		illum.blend_mode = BLEND_ADD
		illum.alpha = 100
		src.AddOverlays(illum, "illum")

		light = new /datum/light/point
		light.set_brightness(0.7)
		light.attach(src)
		light.enable()

		var/image/location_image = image('icons/effects/white_hole_views96x96.dmi', src.source_location.icon_view)
		location_image.alpha = 160
		location_image.pixel_x = 32
		location_image.pixel_y = 32
		src.AddOverlays(location_image, "source_location")

		src.transform = matrix(32 / 160, MATRIX_SCALE)

		if(!particleMaster.CheckSystemExists(/datum/particleSystem/whitehole_warning, src))
			particleMaster.SpawnSystem(new /datum/particleSystem/whitehole_warning(src))

		if(triggered_by_event)
			for_clients_in_range(C, get_turf(src), 15)
				boutput(C, SPAN_ALERT("The air grows light and thin. Something feels terribly wrong."))
				shake_camera(C.mob, 5, 16)

			playsound(src,'sound/effects/creaking_metal1.ogg',100,FALSE,5,-0.5)
			SEND_GLOBAL_SIGNAL(COMSIG_GRAVITY_EVENT, GRAVITY_EVENT_DISRUPT, src.z)

		processing_items |= src

	proc/admin_activate()
		set name = "Activate"
		start_time = TIME - grow_duration

	bullet_act(obj/projectile/P)
		shoot_reflected_to_sender(P, src)
		P.die()

	Bumped(atom/movable/A)
		if(QDELETED(A) || A.throwing || istype(A, /obj/projectile))
			return
		if(!ON_COOLDOWN(A, "white_hole_bump", 0.2 SECONDS)) //okay this will REALLY prevent infinite loops (hopefully)
			step_away(A, src)

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/fishing_rod))
			. = ..()
		else
			boutput(user, SPAN_ALERT("\The [I] seems to be repulsed by the anti-gravitational field of [src]!"))

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		. = ..()
		SPAWN(0)
			AM.throw_at( \
				thr.thrown_from,
				thr.range,
				thr.speed
			)

	ex_act(severity)
		return

	proc/process()
		var/time_since_start = TIME - start_time

		if(state == "dying")
			qdel(src)

		if(triggered_by_event)
			//spatial interdictor: can't stop the white hole, but it can mitigate it
			//consumes 500 units of charge (250,000 joules) to reduce white hole duration
			for_by_tcl(IX, /obj/machinery/interdictor)
				if (IX.expend_interdict(500, src))
					if(prob(20))
						playsound(IX,'sound/machines/alarm_a.ogg',20,FALSE,5,-1.5)
						IX.visible_message(SPAN_ALERT("<b>[IX] emits an anti-gravitational anomaly warning!</b>"))
					if(state != "active")
						grow_duration += 4 SECOND
					else
						active_duration -= 1 SECOND

		if(time_since_start < grow_duration)
			var/scale = 32 / 160 + (160 - 32) / 160 * clamp(((time_since_start + 3 SECONDS) - grow_duration / 3) / (grow_duration * 2 / 3), 0, 1)
			animate(src, transform = matrix(scale, MATRIX_SCALE), time = 3 SECONDS, loop = 0, easing = LINEAR_EASING)

		if(time_since_start < grow_duration / 3)
			return
		else if(time_since_start < grow_duration)
			if(state == "static")
				state = "growing"
				src.visible_message(SPAN_ALERT("<b>[src] begins to uncollapse out of itself!</b>"))
				playsound(src,'sound/machines/engine_alert3.ogg',100,FALSE,5,-0.5)
				if (random_events.announce_events && triggered_by_event)
					command_alert("A severe anti-gravitational anomaly has been detected on the [station_or_ship()] in [get_area(src)]. It will uncollapse into a white hole. Consider quarantining it off.", "Gravitational Anomaly", alert_origin = ALERT_ANOMALY)
			return

		if(state == "growing")
			state = "active"
			src.visible_message(SPAN_ALERT("<b>[src] uncollapses into a white hole!</b>"))
			playsound(src, 'sound/machines/singulo_start.ogg', 90, FALSE, 5, -1)
			animate(src, transform = matrix(1.2, MATRIX_SCALE), time = 0.3 SECONDS, loop = 0, easing = BOUNCE_EASING)
			animate(transform = matrix(1, MATRIX_SCALE), time = 0.3 SECONDS, loop = 0, easing = BOUNCE_EASING)

		if(time_since_start > grow_duration + active_duration)
			animate(src)
			SPAWN(0)
				animate(src, transform = matrix() / 100, time = 3 SECONDS, loop = 0)
			state = "dying"
			playsound(src, 'sound/machines/singulo_start.ogg', 90, FALSE, 5, -2)

		// push or throw things away from the white hole
		for (var/atom/movable/X in range(7,src))
			if (istype(X, /obj/structure/girder) && prob(40)) //mess up girders too
				X.ex_act(3)
			if (X.event_handler_flags & IMMUNE_SINGULARITY || X.anchored)
				continue

			if(prob(30))
				continue
			else if(prob(50))
				step_away(X, src)
			else
				X.throw_at( \
					locate_throw_target(X), \
					rand(1, 6), \
					randfloat(1, 3), \
					bonus_throwforce = 50 / (1 + GET_DIST(X, src)) \
				)

		for (var/turf/simulated/wall/wall in range(1, src)) //make it a little harder to wall them off
			wall.ex_act(3)
			break //just smack one wall at a time

		var/time_interval = 3 SECONDS
		var/spew_count = round(randfloat(1, 15 * src.activity_modifier))
		spew_out_stuff(src.source_location)
		if(spew_count > 1)
			SPAWN(time_interval / spew_count)
				for(var/i = 1 to spew_count - 1)
					if(QDELETED(src) || state == "dying")
						return
					spew_out_stuff(src.source_location)
					sleep(time_interval / spew_count)


	proc/get_target_mob()
		var/list/mob/living/valid_mobs = list()
		for(var/mob/living/L in view(7, src))
			if(isdead(L))
				continue
			if(ismobcritter(L) && prob(80))
				continue
			valid_mobs += L
		if(length(valid_mobs))
			return pick(valid_mobs)

	proc/generate_thing(var/datum/whitehole_spawner/spawner)
		var/atom/movable/AM = spawner.unleash(src)

		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			if(I.pixel_x == 0 && I.pixel_y == 0)
				I.pixel_x = rand(-16, 16)
				I.pixel_y = rand(-16, 16)

		if(istype(AM, /mob/living))
			var/mob/living/L = AM
			if(ismobcritter(L))
				L.TakeDamage("chest", rand(0, 15), rand(0, 15), rand(0, 15))
			else
				L.TakeDamage("chest", rand(0, 80), rand(0, 80), rand(0, 80))
			if(ishuman(AM))
				var/mob/living/carbon/human/H = AM
				H.is_npc = TRUE
				SPAWN(1)
					var/list/limbs = list("l_arm", "r_arm", "l_leg", "r_leg")
					shuffle_list(limbs)
					for(var/i in 1 to pick(5; 0,   10; 1,   10; 2,   5; 3,   2; 4))
						H.limbs?.sever(limbs[i])
					if(prob(25))
						H.emote("scream")
					if(prob(25))
						for(var/i in 1 to 20)
							sleep(rand(3 SECONDS, 35 SECONDS))
							if(isdead(H))
								break
							if(prob(90))
								H.say(phrase_log.random_phrase("say"))
							else
								H.emote("me", TRUE, phrase_log.random_phrase("emote"))
		else if(istype(AM, /obj/item/reagent_containers/food/snacks/plant/tomato))
			var/obj/item/reagent_containers/food/snacks/plant/tomato/tomato = AM
			tomato.reagents.add_reagent("juice_tomato", rand(5, 15))

		// renaming
		if(istype(AM, /mob))
			var/mob/M = AM
			if(istype(M, /mob/living/silicon/ai) && prob(80))
				M.real_name = phrase_log.random_phrase("name-ai")
			else if(istype(M, /mob/living/silicon/robot) && prob(80))
				M.real_name = phrase_log.random_phrase("name-cyborg")
			else if(istype(M, /mob/living/carbon/human/normal/clown) && prob(80))
				M.real_name = phrase_log.random_phrase("name-clown")
			else if(istype(M, /mob/living/carbon/human) && prob(80))
				M.real_name = phrase_log.random_phrase("name-human")
			if(!M.real_name)
				M.real_name = M.name // revert in case of a fail
			M.name = M.real_name
			M.choose_name(1, null, M.real_name, force_instead=TRUE)

		return AM

	proc/locate_throw_target(atom/thrown, turf_search_dist = 64)
		var/turf/init_turf = get_turf(thrown)
		var/turf/hole_turf = get_turf(src)
		if(!init_turf || !hole_turf)
			return null
		if(hole_turf.z != init_turf.z)
			return null

		// basically make sure we're not throwing it into a wall
		var/list/valid_sectors = list()
		for(var/dir in global.cardinal)
			var/turf/first_turf = get_step(init_turf, dir)
			if(init_turf != hole_turf && get_step_towards(init_turf, hole_turf) == first_turf) // skip the dir towards the hole
				continue
			if(first_turf.density)
				continue
			for(var/atom/movable/AM in first_turf)
				if(AM.density)
					continue
			var/angle = dir_to_angle(dir)
			// this asymmetry really sucks but that's just how our throwing works :whelm:
			var/angle_size = (dir & (NORTH|SOUTH)) ? 28 : 180 - 28
			valid_sectors += list(list(angle - angle_size / 2, angle + angle_size / 2))

		var/angle
		if(!length(valid_sectors))
			angle = rand(0, 360)
		else
			var/list/sector = pick(valid_sectors)
			angle = rand(sector[1], sector[2])

		var/turf/T = null
		while(isnull(T) && turf_search_dist >= 0)
			T = locate(
				round(init_turf.x + cos(angle) * turf_search_dist),
				round(init_turf.y + sin(angle) * turf_search_dist),
				init_turf.z
			)
			turf_search_dist -= 4

		return T


	proc/spew_out_stuff(var/datum/whitehole_spawner/spawner)
		if(QDELETED(src))
			return

		animate(src, transform = matrix(1.05, MATRIX_SCALE), time = 0.1 SECONDS, loop = 0, easing = SINE_EASING, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		animate(transform = matrix(1, MATRIX_SCALE), time = 0.1 SECONDS, loop = 0, easing = SINE_EASING)

		var/atom/movable/thing = generate_thing(spawner)
		if(!thing)
			return

		if(istype(thing, /obj/projectile))
			return // don't throw bullets

		var/throw_speed = randfloat(1, 3)
		var/throw_range = 50

		var/turf/T = locate_throw_target(thing)
		if(isnull(T))
			return
		thing.throw_at(T, throw_range, throw_speed, allow_anchored=TRUE, bonus_throwforce=30, throw_type=THROW_PHASE)

	proc/choose_location()
		var/list/locations_list = concrete_typesof(/datum/whitehole_spawner)
		var/list/weighted_locations = list()
		for(var/location_type in locations_list)
			var/datum/whitehole_spawner/main/location = new location_type
			if(location.weight_rarity > 0)
				weighted_locations[location] = location.weight_rarity
		return weighted_pick(weighted_locations)

	disposing()
		if(src.light)
			qdel(src.light)
			src.light = null
		processing_items.Remove(src)
		if(particleMaster.CheckSystemExists(/datum/particleSystem/whitehole_warning, src))
			particleMaster.RemoveSystem(/datum/particleSystem/whitehole_warning)
		..()



// Particle FX

/datum/particleSystem/whitehole_warning
	New(var/atom/location = null)
		..(location, "whitehole_warning", 300)

	Run()
		if (..())
			for(var/i=0, i<10, i++)
				sleep(rand(3,6))
				SpawnParticle()
			state = 1

/datum/particleType/whitehole_warning
	name = "whitehole_warning"
	icon = 'icons/effects/particles.dmi'
	icon_state = "32x32circle"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.pixel_x += rand(-128,128)
			par.pixel_y += rand(-128,128)
			par.color = "#ffffff"
			par.alpha = 2
			par.plane = PLANE_NOSHADOW_ABOVE

			var/image/illum = par.SafeGetOverlayImage("illum", src.icon, src.icon_state)
			illum.appearance_flags = PIXEL_SCALE | RESET_ALPHA
			illum.plane = PLANE_LIGHTING
			illum.blend_mode = BLEND_ADD
			illum.alpha = 6
			par.AddOverlays(illum, "illum")

			first.Scale(0.1,0.1)
			par.transform = first

			first.Scale(50)
			animate(par, transform = first, time = 15 SECONDS, alpha = 30)

			first.Scale(0.1 / 50)
			animate(transform = first, time = 15 SECONDS, alpha = 5)
			first.Reset()


/datum/fishing_spot/whitehole
	rod_tier_required = 2
	fishing_atom_type = /obj/whitehole

	generate_fish(mob/user, obj/item/fishing_rod/fishing_rod, atom/target)
		var/obj/whitehole/whitehole = target
		if(!istype(whitehole))
			CRASH("generate_fish called on whitehole fishing spot with non-whitehole target")
		var/atom/fish = whitehole.generate_thing(whitehole.source_location)
		fish.name += "fish"
		return fish

	try_fish(mob/user, obj/item/fishing_rod/fishing_rod, atom/target)
		. = ..()
		if(.)
			var/obj/whitehole/whitehole = target
			if(!istype(whitehole))
				CRASH("try_fish called on whitehole fishing spot with non-whitehole target")
			if(prob(5))
				whitehole.spew_out_stuff(whitehole.source_location)
			if(whitehole.state in list("static", "growing"))
				whitehole.grow_duration += 10 SECONDS
				boutput(user, SPAN_NOTICE("You feel the white hole shrink a little."))
			else
				whitehole.active_duration -= 5 SECONDS
