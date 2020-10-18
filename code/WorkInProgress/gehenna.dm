#define GEHENNA_TIME 90

//aw fuck he's doin it again


/obj/landmark/viscontents_spawn
	name = "visual mirror spawn"
	desc = "Links a pair of corresponding turfs in holy Viscontent Matrimony. You shouldnt be seeing this."
	var/targetZ = 1 // target z-level to push it's contents to
	var/xOffset = 0 // use only for pushing to the same z-level
	var/yOffset = 0 // use only for pushing to the same z-level
	add_to_landmarks = FALSE

	New()
		var/turf/greasedupFrenchman = loc
		greasedupFrenchman.vistarget = locate(src.x + xOffset, src.y + yOffset, src.targetZ)
		greasedupFrenchman.vistarget.warptarget = greasedupFrenchman
		greasedupFrenchman.updateVis()
		..()


/turf/var/turf/vistarget = null	// target turf for projecting its contents elsewhere
/turf/var/turf/warptarget = null // target turf for teleporting its contents elsewhere
/*
/turf/proc/updateVis() // locates all appropriate objects on this turf, and pushes them to the vis_contents of the target
	if(vistarget)
		vistarget.overlays.Cut()
		vistarget.vis_contents = list()
		for(var/atom/A in src.contents)
			if (istype(A, (/obj/overlay)))
				continue
			if (istype(A, (/mob/dead)))
				continue
			if (istype(A, (/mob/living/intangible)))
				continue
			vistarget.vis_contents += A
*/
/turf/proc/updateVis()
	if(vistarget)
		vistarget.overlays.Cut()
		vistarget.vis_contents = src
		var/obj/overlay/tile_effect/lighting/L = locate() in vistarget.vis_contents
		if(L)
			vistarget.vis_contents -= L

// No mor vis shit
// Gehenna shit tho
/turf/gehenna
	name = "planet gehenna"
	desc = "errrr"

/turf/simulated/wall/asteroid/gehenna
	name = "sulferous rock"
	desc = "looks loosely packed"
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna_rock"

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
	carbon_dioxide = 5*(sin(GEHENNA_TIME + 3)+ 1)
	oxygen = MOLES_O2STANDARD
	//temperature = WASTELAND_MIN_TEMP + (0.5*sin(GEHENNA_TIME)+1)*(WASTELAND_MAX_TEMP - WASTELAND_MIN_TEMP)

	luminosity = 0.5*(sin(GEHENNA_TIME)+ 1)

	var/datum/light/point/light = null
	var/light_r = 0.5*(sin(GEHENNA_TIME)+1)
	var/light_g = 0.3*(sin(GEHENNA_TIME )+1)
	var/light_b = 0.3*(sin(GEHENNA_TIME + 3 )+1)
	var/light_brightness = 0.6*(sin(GEHENNA_TIME)+1)
	var/light_height = 3
	var/generateLight = 1

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
