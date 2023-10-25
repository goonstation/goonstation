/datum/targetable/critter/radiationblast
	name = "Radiation Blast"
	desc = "Focus your psychic powers to unleash a concentrated blast of radiation at a spot."
	cooldown = 100
	disabled = FALSE
	targeted = TRUE
	target_anything = TRUE

/datum/targetable/critter/radiationblast/cast(atom/target)
	if (..())
		return 1
	if (disabled)
		return
	var/turf/T = get_turf(target)
	if (isturf(T))
		var/pulse_lifespan = rand(20,40)
		new /obj/anomaly/radioactive_burst(T,lifespan = pulse_lifespan)
