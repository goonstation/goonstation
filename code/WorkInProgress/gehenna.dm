#define GEHENNA_TIME 250
#define WASTELAND_MIN_TEMP 250
#define WASTELAND_MAX_TEMP 350


// Gehenna shit tho
/turf/gehenna
	name = "planet gehenna"
	desc = "errrr"

/turf/simulated/wall/asteroid/gehenna
	name = "sulferous rock"
	desc = "looks loosely packed"
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna_rock"
	floor_turf = "/turf/gehenna/desert/path"
	New()
		..()
		src.icon_state = initial(src.icon_state)
	space_overlays()
		return

/turf/simulated/wall/asteroid/gehenna/tough
	name = "dense sulferous rock"
	desc = "looks densely packed"
	icon_state = "gehenna_rock2"

/turf/unsimulated/wall/gehenna/
	name = "monolithic sulferous rock"
	desc = "looks conveniently impenetrable"
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna_rock3"

/turf/gehenna/desert
	name = "barren wasteland"
	desc = "Looks really dry out there."
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna"
	carbon_dioxide = 5*(sin(GEHENNA_TIME - 90)+ 1)
	oxygen = MOLES_O2STANDARD
	temperature = WASTELAND_MIN_TEMP + ((0.5*sin(GEHENNA_TIME-45)+0.5)*(WASTELAND_MAX_TEMP - WASTELAND_MIN_TEMP))

	luminosity = 0.5*(sin(GEHENNA_TIME)+ 1)

	var/datum/light/point/light = null
	var/light_r = 0.5*(sin(GEHENNA_TIME)+1)
	var/light_g = 0.3*(sin(GEHENNA_TIME )+1)
	var/light_b = 0.4*(sin(GEHENNA_TIME - 45 )+1)
	var/light_brightness = 0.6*(sin(GEHENNA_TIME)+0.8) + 0.3
	var/light_height = 3
	var/generateLight = 1
	var/stone_color

	New()
		..()
		if (generateLight)
			src.make_light() /*
			generateLight = 0
			if (z != 3) //nono z3
				for (var/dir in alldirs)
					var/turf/T = get_step(src,dir)
					if (istype(T, /turf/simulated))
						generateLight = 1
						src.make_light()
						break */


	make_light()
		if (!light)
			light = new
			light.attach(src)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		light.enable()



	plating
		name = "sand-covered plating"
		desc = "The desert slowly creeps upon everything we build."
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_tile"

		podbay
			icon_state = "gehenna_plating"

	path
		name = "beaten earth"
		desc = "for seven years we toiled, to tame wild Gehenna"
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_edge"

	corner
		name = "beaten earth"
		desc = "for seven years we toiled, to tame wild Gehenna"
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_corner"


/area/gehenna

/area/gehenna/wasteland
	icon_state = "red"
	name = "the barren wastes"
	teleport_blocked = 0


/obj/machinery/computer/sea_elevator/sec
	upper = /area/shuttle/sea_elevator/upper/sec
	lower = /area/shuttle/sea_elevator/lower/sec

/obj/machinery/computer/sea_elevator/eng
	upper = /area/shuttle/sea_elevator/upper/eng
	lower = /area/shuttle/sea_elevator/lower/eng

/obj/machinery/computer/sea_elevator/med
	upper = /area/shuttle/sea_elevator/upper/med
	lower = /area/shuttle/sea_elevator/lower/med

/obj/machinery/computer/sea_elevator/QM
	upper = /area/shuttle/sea_elevator/upper/QM
	lower = /area/shuttle/sea_elevator/lower/QM
