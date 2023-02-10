/datum/adventure_submode/turf
	New()
		..()
		marker = new /obj/adventurepuzzle/marker()
	var/turf/A = null
	var/turftype = null
	var/obj/marker = null

	var/static/list/turfs = list("Ancient floor" = /turf/unsimulated/iomoon/ancient_floor, \
	"Ancient wall" = /turf/unsimulated/iomoon/ancient_wall, "Cave floor" = /turf/unsimulated/floor/cave, \
	"Cave wall" = /turf/unsimulated/wall/cave,  "Circuit floor: Blue" = /turf/unsimulated/floor/circuit, \
	"Circuit floor: Red" = /turf/unsimulated/floor/circuit/red, "Circuit floor: Purple" = /turf/unsimulated/floor/circuit/purple, \
	"Circuit floor: Vintage" = /turf/unsimulated/floor/circuit/vintage, "Circuit floor: Green" = /turf/unsimulated/floor/circuit/green, \
	"Dirt" = /turf/unsimulated/aprilfools/dirt, "Grass" = /turf/unsimulated/aprilfools/grass, \
	"Hive floor" = /turf/unsimulated/floor/setpieces/hivefloor, "Hive wall" = /turf/unsimulated/wall/auto/adventure/bee, \
	"Ice" = /turf/unsimulated/floor/arctic/snow/ice, "Lava" = /turf/unsimulated/floor/lava, "Martian floor" = /turf/simulated/martian/floor, \
	"Martian wall" = /turf/simulated/martian/wall, "Normal floor" = /turf/simulated/floor, "Normal wall" = /turf/simulated/wall, \
	"Reinforced floor" = /turf/simulated/floor/engine, "Reinforced wall" = /turf/simulated/wall/r_wall, "Shielded floor" = /turf/simulated/floor/engine, \
	"Shielded wall" = /turf/unsimulated/wall/setpieces/leadwall, "Shielded window" = /turf/unsimulated/wall/setpieces/leadwindow, "Showcase" = /turf/unsimulated/floor/wizard/showcase, \
	"Shuttle floor" = /turf/simulated/floor/shuttle, "Shuttle wall" = /turf/simulated/shuttle/wall, "Snow" = /turf/unsimulated/floor/arctic/snow, \
	"Void floor" = /turf/unsimulated/floor/void, "Void wall" = /turf/unsimulated/wall/void, "Wizard carpet: Cross" = /turf/unsimulated/floor/wizard/carpet/cross, "Wizard carpet: Edge" = /turf/unsimulated/floor/wizard/carpet/edge, \
	"Wizard carpet: Inner corners (1-2)" = /turf/unsimulated/floor/wizard/carpet/inner_corner_onetwo, "Wizard carpet: Inner Corners (3-4)" = /turf/unsimulated/floor/wizard/carpet/inner_corner_threefour, \
	"Wizard carpet: Narrow" = /turf/unsimulated/floor/wizard/carpet/narrow, "Wizard carpet: Narrow crossing" = /turf/unsimulated/floor/wizard/carpet/narrow/crossing, "Wizard carpet: Plain" = /turf/unsimulated/floor/wizard/carpet, \
	"Wizard false wall" = /turf/unsimulated/wall/adaptive/wizard_fake, "Wizard floor" = /turf/unsimulated/floor/wizard, "Wizard plating" = /turf/unsimulated/floor/wizard/plating,  \
	"Wizard stairs" = /turf/unsimulated/floor/wizard/stairs, "Wizard wall" = /turf/unsimulated/wall/adaptive/wizard, "Wizard window" = /turf/unsimulated/wall/adaptive/wizard_window)

	name = "Turf"

	click_left(var/atom/object, location, control, params)
		if(!turftype)
			return
		if (!A)
			A = get_turf(object)
			A.overlays += marker
			return
		else
			var/turf/B = get_turf(object)
			if (A.z != B.z)
				boutput(usr, "<span class='alert'>The two corners must be on the same Z!</span>")
				return

			for(var/turf/T in block(A, B))
				var/turf/at = T
				T.ReplaceWith(turftype, force=1)
				at.set_dir(holder.dir)
				blink(at)
				new /area/adventure(at)
				at.RL_Reset()
			A.overlays -= marker
			A = null

	click_right(var/atom/object, location, control, params)
		if (!A)
			A = get_turf(object)
			A.overlays += marker
			return
		else
			var/turf/B = get_turf(object)
			if (A.z != B.z)
				boutput(usr, "<span class='alert'>The two corners must be on the same Z!</span>")
				return

			for(var/turf/T in block(A, B))
				for(var/obj/O in T)
					qdel(O)
				blink(T)
				new /area(T)
				T.ReplaceWithSpaceForce()

			A.overlays -= marker
			A = null

	settings(var/ctrl, var/alt, var/shift)
		selected()

	selected()
		var/kind = input(usr, "What kind of turf?", "Turf type", "Ancient floor") in src.turfs
		turftype = src.turfs[kind]
		boutput(usr, "<span class='notice'>Now building [kind] turfs in wide area spawn mode.</span>")

	deselected()
		if (A)
			A.overlays -= marker
			A = null
