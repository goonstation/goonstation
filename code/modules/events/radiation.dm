/datum/random_event/major/radiation
	name = "Radiation Storm"
	centcom_headline = "Radioactive Anomaly"
	centcom_message = {"Radioactive anomalies have been detected on the station. Evacuate any areas containing abnormal green or blue energy fields. Medical personnel are advised to prepare potassium iodide and anti-toxin treatments, and remain on standby to treat cases of irradiation."}
	centcom_origin = ALERT_WEATHER
	var/min_pulses_per_event = 30
	var/max_pulses_per_event = 100
	var/min_delay_between_pulses = 2
	var/max_delay_between_pulses = 8
	var/min_pulse_lifespan = 10
	var/max_pulse_lifespan = 100

	event_effect()
		..()
		var/pulse_amt = rand(min_pulses_per_event,max_pulses_per_event)
		var/pulse_delay = rand(min_delay_between_pulses,max_delay_between_pulses)
		var/pulse_lifespan = null
		var/turf/pulseloc = null

		SPAWN(0)
			for (var/pulses = pulse_amt, pulses > 0, pulses--)
				pulseloc = pick(random_floor_turfs)
				pulse_lifespan = rand(min_pulse_lifespan,max_pulse_lifespan)
				pick(prob(90); new /obj/anomaly/radioactive_burst(pulseloc,lifespan = pulse_lifespan), prob(50); new /obj/anomaly/neutron_burst(pulseloc,lifespan = pulse_lifespan))
				sleep(pulse_delay)



/obj/anomaly/radioactive_burst
	name = "shimmering anomaly"
	desc = "Looking at this anomaly makes you feel strange, like something is pushing at your eyes."
	icon = 'icons/effects/particles.dmi'
	icon_state = "32x32circle"
	color = "#00FF00"
	density = 0
	alpha = 100
	var/sound/pulse_sound = 'sound/weapons/ACgun2.ogg'
	var/rad_strength = (25/40) SIEVERTS
	var/pulse_range = 5
	var/mutate_prob = 25
	var/bad_mut_prob = 75

	New(var/loc,var/lifespan = 120)
		..()
		animate(src, alpha = 0, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
		animate(alpha = 100, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
		if(!particleMaster.CheckSystemExists(/datum/particleSystem/rads_warning, src))
			particleMaster.SpawnSystem(new /datum/particleSystem/rads_warning(src))
		sleep(lifespan)
		playsound(src,pulse_sound,50,1)
		irradiate_turf(get_turf(src))
		for (var/turf/T in circular_range(src,pulse_range))
			irradiate_turf(T)
		SPAWN(0)
			qdel(src)
		return

	disposing()
		if(particleMaster.CheckSystemExists(/datum/particleSystem/rads_warning, src))
			particleMaster.RemoveSystem(/datum/particleSystem/rads_warning)
		..()

	proc/irradiate_turf(var/turf/T)
		if (!isturf(T))
			return
		//spatial interdictor: nullify radiation pulses
		//consumes 100 units of charge per tile protected
		for_by_tcl(IX, /obj/machinery/interdictor)
			if (IX.expend_interdict(100,T,1))
				animate_flash_color_fill_inherit(T,"#FFDD00",1,5)
				return
		animate_flash_color_fill_inherit(T,"#00FF00",1,5)
		for (var/mob/living/carbon/M in T.contents)
			M.take_radiation_dose(rad_strength)
			if (prob(mutate_prob) && M.bioHolder)
				if (prob(bad_mut_prob))
					M.bioHolder.RandomEffect("bad")
				else
					M.bioHolder.RandomEffect("good")

/obj/anomaly/neutron_burst
	name = "iridescent anomaly"
	desc = "Looking at this anomaly makes you feel ill, like something is pushing at the back your eyes."
	icon = 'icons/effects/particles.dmi'
	icon_state = "32x32circle"
	color = "#0084ff"
	density = 0
	alpha = 100
	var/sound/pulse_sound = 'sound/weapons/ACgun1.ogg'
	var/rad_strength = (50/40) SIEVERTS
	var/pulse_range = 3
	var/mutate_prob = 10
	var/bad_mut_prob = 90

	New(var/loc,var/lifespan = 45)
		..()
		animate(src, alpha = 0, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
		animate(alpha = 100, time = rand(5,10), loop = -1, easing = LINEAR_EASING)
		if(!particleMaster.CheckSystemExists(/datum/particleSystem/rads_warning, src))
			particleMaster.SpawnSystem(new /datum/particleSystem/rads_warning(src))
		sleep(lifespan)
		playsound(src,pulse_sound,50,1)
		irradiate_turf(get_turf(src))
		for (var/turf/T in circular_range(src,pulse_range))
			irradiate_turf(T)
		SPAWN(0)
			qdel(src)
		return

	disposing()
		if(particleMaster.CheckSystemExists(/datum/particleSystem/rads_warning, src))
			particleMaster.RemoveSystem(/datum/particleSystem/rads_warning)
		..()

	proc/irradiate_turf(var/turf/T)
		if (!isturf(T))
			return
		//spatial interdictor: nullify radiation pulses
		//consumes 150 units of charge per tile protected
		for_by_tcl(IX, /obj/machinery/interdictor)
			if (IX.expend_interdict(150,T,1))
				animate_flash_color_fill_inherit(T,"#FFDD00",1,5)
				return
		animate_flash_color_fill_inherit(T,"#0084ff",1,5)
		for (var/mob/A in T.contents)
			A.take_radiation_dose(rad_strength)
			if(iscarbon(A))
				var/mob/living/carbon/M = A
				if (prob(mutate_prob) && M.bioHolder)
					if (prob(bad_mut_prob))
						M.bioHolder.RandomEffect("bad")
					else
						M.bioHolder.RandomEffect("good")


// Oldest version of event - just unavoidably puts radiation on everyone

/datum/random_event/special/mutation
	name = "Radiation Wave"
	centcom_headline = "Radiation Wave"
	centcom_message = "A large wave of radiation is approaching the station. Personnel should use caution when traversing the station and seek medical attention if they experience any side effects from the wave."
	centcom_origin = ALERT_WEATHER

	event_effect(var/source)
		..()
		SPAWN(rand(100, 300))
		for (var/mob/living/carbon/human/H in mobs)
			if (isdead(H))
				continue
			if (prob(10))
				H.bioHolder.RandomEffect("good")
			else
				H.bioHolder.RandomEffect("bad")
			H << sound('sound/ambience/industrial/LavaPowerPlant_Rumbling3.ogg')

// Particle FX

/datum/particleSystem/rads_warning
	New(var/atom/location = null)
		..(location, "rads_warning", 5)

	Run()
		if (..())
			for(var/i=0, i<4, i++)
				sleep(0.2 SECONDS)
				SpawnParticle()
			state = 1

/datum/particleType/rads_warning
	name = "rads_warning"
	icon = 'icons/effects/particles.dmi'
	icon_state = "32x32ring"

	MatrixInit()
		first = matrix()

	Apply(var/obj/particle/par)
		if(..())
			par.color = "#00FF00"
			par.alpha = 255

			first.Scale(0.1,0.1)
			par.transform = first

			first.Scale(80)
			animate(par, transform = first, time = 5, alpha = 5)
			first.Reset()
