/datum/random_event/major/emp_storm
	name = "EMP Storm"
	weight = 80
	centcom_headline = "Electromagnetic Storm"
	centcom_message = {"Electromagnetic storm passing by the station. Electromagnetic anomalies have been detected on the station. Evacuate any areas containing abnormal electronic activity. Monitor electronic equipment for faults."}
	centcom_origin = ALERT_WEATHER
	customization_available = 1
	var/min_pulses_per_event = 10
	var/max_pulses_per_event = 40
	var/min_delay_between_pulses = 2
	var/max_delay_between_pulses = 8

	admin_call(var/source)
		if (..())
			return

		src.min_pulses_per_event = input(usr, "Minimum amount of EMP bursts? (Default = 10)", src.name, 0) as num|null
		src.max_pulses_per_event = input(usr, "Maximum amount of EMP bursts? (Default = 40)", src.name, 0) as num|null
		src.min_delay_between_pulses = input(usr, "Minimum delay between bursts? (Default = 2)", src.name, 0) as num|null
		src.max_delay_between_pulses = input(usr, "Maximum delay between bursts? (Default = 8)", src.name, 0) as num|null

		event_effect(source)

	event_effect()
		..()
		var/pulse_amt = rand(min_pulses_per_event,max_pulses_per_event)
		var/pulse_delay = rand(min_delay_between_pulses,max_delay_between_pulses)
		var/turf/pulseloc = null

		SPAWN(0)
			for (var/pulses = pulse_amt, pulses > 0, pulses--)
				pulseloc = pick(random_floor_turfs)
				new /obj/anomaly/emp_burst(pulseloc)
				sleep(pulse_delay)

/obj/anomaly/emp_burst
	name = "shimmering anomaly"
	desc = "Your hair is standing on end. You're probably too close to whatever this is."
	icon = 'icons/effects/particles.dmi'
	icon_state = "electro"
	color = "#ffda00"
	density = 0
	alpha = 100
	var/sound_list = list('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg', 'sound/effects/sparks5.ogg', 'sound/effects/sparks6.ogg')

	New(var/loc,var/lifespan = 120)
		..()
		animate(src, alpha = 0, time = rand(3,8), loop = -1, easing = LINEAR_EASING)
		animate(alpha = 100, time = rand(3,8), loop = -1, easing = LINEAR_EASING)
		if(!particleMaster.CheckSystemExists(/datum/particleSystem/emp_warning, src))
			particleMaster.SpawnSystem(new /datum/particleSystem/emp_warning(src))
		SPAWN(lifespan)
			playsound(src, pick(sound_list), 50, TRUE)
			emp_burst(get_turf(src))
			SPAWN(0)
				qdel(src)
			return

	proc/emp_burst(var/turf/T)
		if (T)
			playsound(T, pick(sound_list), 25, TRUE)

			var/reach_rand = rand(6,14) // they don't all need to be max screensize EMPs
			var/reach = "[reach_rand]x[reach_rand]"

			T.hotspot_expose(700,125)

			var/obj/overlay/pulse = new/obj/overlay(T)
			pulse.icon = 'icons/effects/effects.dmi'
			pulse.icon_state = "emppulse"
			pulse.name = "emp pulse"
			pulse.anchored = ANCHORED
			SPAWN(2 SECONDS)
				if (pulse) qdel(pulse)

			for (var/turf/tile in range(reach, T))
				for (var/atom/O in tile.contents)
					var/area/t = get_area(O)
					if(t?.sanctuary) continue
					O.emp_act()

/datum/particleSystem/emp_warning
	New(var/atom/location = null)
		..(location, "emp_warning", 5)

	Run()
		if (..())
			for(var/i=0, i<4, i++)
				sleep(0.2 SECONDS)
				SpawnParticle()
			state = 1

/datum/particleType/emp_warning
	name = "emp_warning"
	icon = 'icons/effects/particles.dmi'
	icon_state = "32x32ring"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.color = "#ffda00"
			par.alpha = 255

			first.Scale(0.1,0.1)
			par.transform = first

			first.Scale(80)
			animate(par, transform = first, time = 5, alpha = 5)
			first.Reset()
