//device for engineers to construct that counteracts the effects of random events in its radius,
//if it has been set up a sufficient time in advance

/obj/machinery/interdictor
	name = "spatial interdictor"
	desc = "A sophisticated device that lessens or nullifies the effects of assorted stellar phenomena."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdictor"
	power_usage = 120
	density = 1
	anchored = 0
	var/obj/item/cell/intcap = null
	var/chargerate = 500 // internal cell charge rate, per tick
	var/canInterdict = 0
	var/sound/sound_on = "sound/effects/shielddown.ogg"
	var/sound/sound_off = "sound/effects/shielddown2.ogg"
	var/sound/sound_shieldhit = "sound/effects/shieldhit2.ogg"
	var/sound/sound_battwarning = "sound/machines/pod_alarm.ogg"

	New()
		src.intcap = new /obj/item/cell/supercell(src) //deliberately not charged
		..()
		src.update_icon()


/obj/machinery/interdictor/proc/update_icon()

	var/ratio = min(1, src.intcap.charge / src.intcap.maxcharge)
	ratio = round(ratio, 0.33) * 100
	var/image/I_chrg = SafeGetOverlayImage("charge", 'icons/obj/machines/interdictor.dmi', "idx-charge-[ratio]")
	I_chrg.plane = PLANE_LIGHTING
	UpdateOverlays(I_chrg, "charge", 0, 1)

	var/gridtie = !(status & (BROKEN|NOPOWER))
	var/image/I_grid = SafeGetOverlayImage("grid", 'icons/obj/machines/interdictor.dmi', "idx-grid-[gridtie]")
	I_grid.plane = PLANE_LIGHTING
	UpdateOverlays(I_grid, "grid", 0, 1)

	var/image/I_actv = SafeGetOverlayImage("active", 'icons/obj/machines/interdictor.dmi', "idx-active-[canInterdict]")
	I_actv.plane = PLANE_LIGHTING
	UpdateOverlays(I_actv, "active", 0, 1)


/obj/machinery/interdictor/process(mult)
	if (status & BROKEN)
		return
	if (intcap && intcap.charge < intcap.maxcharge)
		power_usage = 120 + src.chargerate / CELLRATE
	else
		power_usage = 120
		src.canInterdict = 1
	..()
	//boutput(world, "ccpt [intcap] [stat]")
	if(status & NOPOWER)
		if(src.overlays && length(src.overlays))
			src.updateicon()
		return
	if(!intcap)
		src.updateicon()
		status |= BROKEN
		message_admins("Interdictor at ([showCoords(src.x, src.y, src.z)]) is missing a power cell. This is not supposed to happen, yell at kubius")
		return

	var/added = intcap.give(src.chargerate * mult)
	use_power(added / CELLRATE)

	src.updateicon()

//call this from an event to determine if sufficient power is remaining to complete an interdiction,
//passing an amount in cell charge that is required to interdict the event.
//returns 1 if interdiction was successful, 0 if power was insufficient
/obj/machinery/interdictor/expend_interdict(var/stopcost)
	if (status & BROKEN)
		return 0
	if (!intcap || intcap.charge < stopcost)
		return 0
	else
		intcap.use(stopcost)
		return 1
