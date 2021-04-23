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
	var/chargerate = 400 // internal cell charge rate, per tick
	var/canInterdict = 0 // indication of operability
	//if 0, whether from depletion or new installation, battery charge must reach 100% to set to 1 and activate interdiction

	var/sound/sound_interdict_on = "sound/machines/interdictor_activate.ogg"
	var/sound/sound_interdict_off = "sound/machines/interdictor_deactivate.ogg"

	New()
		src.intcap = new /obj/item/cell/supercell(src) //deliberately not charged
		..()
		src.updateicon()

	disposing()
		PCEL?.dispose()
		PCEL = null
		sound_on = null
		sound_off = null
		..()

/obj/machinery/interdictor/proc/updateicon()
	var/ratio = max(0, src.intcap.charge / src.intcap.maxcharge)
	ratio = round(ratio, 0.33) * 100
	boutput(world, "yep [ratio]")
	var/image/I_chrg = SafeGetOverlayImage("charge", 'icons/obj/machines/interdictor.dmi', "idx-charge-[ratio]")
	I_chrg.plane = PLANE_OVERLAY_EFFECTS
	UpdateOverlays(I_chrg, "charge", 0, 1)

	var/gridtie = !(status & (BROKEN|NOPOWER))
	var/image/I_grid = SafeGetOverlayImage("grid", 'icons/obj/machines/interdictor.dmi', "idx-grid-[gridtie]")
	I_grid.plane = PLANE_OVERLAY_EFFECTS
	UpdateOverlays(I_grid, "grid", 0, 1)

	var/image/I_actv = SafeGetOverlayImage("active", 'icons/obj/machines/interdictor.dmi', "idx-active-[canInterdict]")
	I_actv.plane = PLANE_OVERLAY_EFFECTS
	UpdateOverlays(I_actv, "active", 0, 1)


/obj/machinery/interdictor/process(mult)
	if (status & BROKEN)
		return
	..()
	//boutput(world, "yep [power_usage] [chargerate]")
	if(!intcap)
		status |= BROKEN
		src.canInterdict = 0
		playsound(src.loc, src.sound_interdict_off, 50, 1)
		src.updateicon()
		message_admins("Interdictor at ([showCoords(src.x, src.y, src.z)]) is missing a power cell. This is not supposed to happen, yell at kubius")
		return
	if(intcap.charge < intcap.maxcharge)
		var/added = intcap.give(src.chargerate * mult)
		use_power(added / CELLRATE)
	if(intcap.charge == intcap.maxcharge)
		src.canInterdict = 1
		playsound(src.loc, src.sound_interdict_on, 50, 1)

	src.updateicon()

//call this from an event to determine if sufficient power is remaining to complete an interdiction,
//passing an amount in cell charge that is required to interdict the event.
//returns 1 if interdiction was successful, 0 if power was insufficient
/obj/machinery/interdictor/proc/expend_interdict(var/stopcost)
	if (status & BROKEN || !src.canInterdict)
		return 0
	if (!intcap || intcap.charge < stopcost)
		src.canInterdict = 0
		playsound(src.loc, src.sound_interdict_off, 50, 1)
		return 0
	else
		intcap.use(stopcost)
		return 1
