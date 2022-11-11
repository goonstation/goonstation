/*
Afterlife Stuff - Some fun (or unfun) places for the dead to mess about in.
Contents:
Afterlife bar areas
Hell area (send people here if they die in a shameful way)
*/
/area/afterlife
	dont_log_combat = TRUE

/area/afterlife/bar
	name = "The Afterlife Bar"
	skip_sims = 1
	sims_score = 100
	icon_state = "afterlife_bar"
	requires_power = 0
	teleport_blocked = 1

/area/afterlife/bar/sanctuary
	name = "The Afterlife Lounge"
	icon_state = "afterlife_lounge"
	sanctuary = 1

/area/afterlife/heaven
	name = "Heaven"
	sanctuary = 1
	ambient_light = rgb(20, 25, 30)

/area/afterlife/heaven/hydroponics
	name = "Heavenly Gardens"
	icon_state = "hydro"
	ambient_light = rgb(10, 13, 16)

/area/afterlife/heaven/hydroponics/inside
	name = "Heavenly Garden Forestry"
	icon_state = ""
	ambient_light = rgb(20, 22, 40)

	New()
		..()
		overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "rain_overlay", layer = EFFECTS_LAYER_BASE)

/area/afterlife/heaven/cafe
	name = "Cloud Nine Diner"
	ambient_light = rgb(0, 0, 0)

/area/afterlife/heaven/medical
	name = "Afterlife Medical Area"
	ambient_light = rgb(0, 0, 0)

/area/afterlife/heaven/zen
	name = "Afterlife Zen Garden"
	ambient_light = rgb(0, 0, 0)

/area/afterlife/heaven/strange
	name = "????"
	ambient_light = rgb(0, 0, 0)


/area/afterlife/bar/barspawn
	name = "Afterlife Bar Revival Point"
	skip_sims = 1
	sims_score = 100
	icon_state = "afterlife_bar_spawn"
	requires_power = 0
	teleport_blocked = 1
	sanctuary = 1

/area/afterlife/hell
	name = "Hell"
	skip_sims = 1
	sims_score = 0
	icon_state = "afterlife_hell"
	requires_power = 0
	teleport_blocked = 1

/area/afterlife/hell/hellspawn
	name = "hellspawn"
	skip_sims = 1
	sims_score = 0
	icon_state = "afterlife_hell_spawn"
	requires_power = 0
	teleport_blocked = 1

/area/afterlife/arena
	name = "THE ARENA"
	skip_sims = 1
	sims_score = 0
	icon_state = "afterlife_hell"
	requires_power = 0
	teleport_blocked = 1
	ambient_light = "#222222"

/area/afterlife/arenaspawn
	name = "THE ARENA SPAWN"
	skip_sims = 1
	sims_score = 0
	icon_state = "afterlife_hell_spawn"
	requires_power = 0
	teleport_blocked = 1

proc/inafterlifebar(var/mob/M as mob in world)
	return istype(get_area(M),/area/afterlife/bar) || istype(get_area(M),/area/afterlife/heaven)

proc/inafterlife(var/mob/M as mob in world)
	return istype(get_area(M),/area/afterlife)
