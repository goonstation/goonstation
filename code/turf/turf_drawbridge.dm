/turf/simulated/drawbridge
	name = "bridge"
	icon = 'icons/turf/drawbridge.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0

	meteorhit()
		return

/turf/simulated/drawbridge/wall
	name = "drawbridge wall"
	icon_state = "wall"
	var/icon_style = "wall"
	opacity = 0
	density = 1
	gas_impermeable = 1
	pathable = 0

/turf/simulated/drawbridge/floor
	name = "drawbridge floor"
	icon_state = "floor"

// airbridge

/turf/simulated/floor/airbridge
	// regular white steel floor for now but a good candidate for new sprites!
	icon_state = "airbridge"
	name = "airbridge floor"

/turf/simulated/wall/airbridge
	icon_state = "airbridge"
	name = "airbridge wall"
