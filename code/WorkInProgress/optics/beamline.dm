/obj/beam/custom
	var/obj/item/lens/lens = null


/obj/machinery/industrial_laser
	name = "industrial laser"
	desc = "An industrial laser beam emitter."
	icon = 'icons/obj/machines/fusion.dmi'
	icon_state = "laser-premade"
	var/obj/item/lens/lens = null
	var/obj/beam/custom/beam = null
	var/setup_beam_length = 48

	New ()
		..()
		if (!src.lens)
			src.lens = new/obj/item/lens(src)

	disposing()
		if (src.beam)
			src.beam.dispose()
			src.beam = null
		..()

	process()
		if (status & BROKEN)
			if (src.beam)
				src.beam.dispose()
			return
		power_usage = 1000
		..()
		if (status & NOPOWER)
			if (src.beam)
				src.beam.dispose()
			return

		use_power(power_usage)

		if (!src.beam)
			var/turf/beamTurf = get_step(src, src.dir)
			if (!istype(beamTurf) || beamTurf.density)
				return
			src.beam = new /obj/beam/custom(beamTurf, setup_beam_length)
			src.beam.set_dir(src.dir)
			src.beam.lens = src.lens

			return

		return

	power_change()
		if(powered())
			status &= ~NOPOWER
			src.UpdateIcon()
		else
			SPAWN(rand(0, 15))
				status |= NOPOWER
				src.UpdateIcon()

	ex_act(severity)
		switch(severity)
			if(1)
				//dispose()
				src.dispose()
				return
			if(2)
				if (prob(50))
					src.status |= BROKEN
					src.UpdateIcon()
			if(3)
				if (prob(25))
					src.status |= BROKEN
					src.UpdateIcon()
			else
		return


	update_icon()
		if (status & (NOPOWER|BROKEN))
			//src.icon_state = "heptemitter-p"
			if (src.beam)
				//qdel(src.beam)
				src.beam.dispose()
		//else
			//src.icon_state = "heptemitter[src.beam ? "1" : "0"]"
		return



/obj/machinery/beamline
	name = "beamline component"
	desc = "Some sort of heavy machinery for use with a heavy laser setup."
	icon = 'icons/obj/machines/beamline64x32.dmi'
	icon_state = "beamline"


	bullet_act()
		// todo: write in a system for these to react to laser shots
		return

/obj/machinery/beamline/amplifier
	name = "beamline amplifier"
	desc = "Supercharges lasers that pass through it."
	icon = 'icons/obj/machines/beamline64x32.dmi'
	icon_state = "amplifier-0"

/obj/machinery/beamline/spectrometer
	name = "spectrometer"
	desc = "A huge mass spectrometer that works with laser setups."
	icon = 'icons/obj/machines/beamline64x32.dmi'
	icon_state = "spectrometer-0"


