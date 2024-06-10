/obj/machinery/shieldgenerator/meteorshield
	name = "meteor shield generator"
	desc = "Generates a force field that stops meteors."
	icon = 'icons/obj/meteor_shield.dmi'
	icon_state = "shieldgen"
	density = FALSE

	nocell
		starts_with_cell = FALSE

	shield_on()
		if (!PCEL)
			if (!powered()) //if NOT connected to power grid and there is power
				src.power_usage = 0
				return
			else //no power cell, not connected to grid: power down if active, do nothing otherwise
				src.power_usage = 30 * (src.range)
				generate_shield()
				return
		else
			if (PCEL.charge > 0)
				generate_shield()
				return

	proc/generate_shield()
		for(var/turf/space/T in orange(src.range,src))
			if (GET_DIST(T,src) != src.range)
				continue
			var/obj/forcefield/meteorshield/S = new /obj/forcefield/meteorshield(T)
			S.deployer = src
			src.deployed_shields += S

		src.anchored = ANCHORED
		src.active = 1
		playsound(src.loc, src.sound_on, 50, 1)
		build_icon()
