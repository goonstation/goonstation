//device for engineers to construct that counteracts the effects of random events in its radius,
//if it has been set up a sufficient time in advance

//all references to range should use INTERDICT_RANGE (defined in _std\defines\construction.dm)

/obj/machinery/interdictor
	name = "spatial interdictor"
	desc = "A sophisticated device that lessens or nullifies the effects of assorted stellar phenomena."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdictor"
	power_usage = 0 //draws only based on cell charge
	density = 1
	anchored = 0
	var/obj/item/cell/intcap = null //short for internal capacitor.
	var/chargerate = 500 // internal cell charge rate, per tick
	var/connected = 0 //whether this is tied into a wire
	var/maglock_cooldown = 3 SECONDS

	var/canInterdict = 0 // indication of operability
	//if 0, whether from depletion or new installation, battery charge must reach 100% to set to 1 and activate interdiction

	var/hasInterdicted = 0 // indication of operation in progress
	//if 1, play interdiction active sound on next machine tick

	var/list/deployed_fields = list()

	var/sound/sound_interdict_on = "sound/machines/interdictor_activate.ogg"
	var/sound/sound_interdict_off = "sound/machines/interdictor_deactivate.ogg"
	var/sound/sound_interdict_run = "sound/machines/interdictor_operate.ogg"
	var/sound/sound_togglebolts = "sound/machines/click.ogg"

	New()
		src.intcap = new /obj/item/cell/supercell(src) //deliberately not charged
		..()
		src.updateicon()

	disposing()
		src.stop_interdicting()
		intcap?.dispose()
		intcap = null
		sound_interdict_on = null
		sound_interdict_off = null
		sound_interdict_run = null
		sound_togglebolts = null
		deployed_fields = list()
		..()

	attack_hand(mob/user as mob)
		if(!ON_COOLDOWN(src, "maglocks", src.maglock_cooldown))
			if(anchored)
				if(src.canInterdict)
					src.stop_interdicting()
				src.anchored = 0
				src.connected = 0
				boutput(user, "You deactivate the interdictor's magnetic lock.")
				playsound(src.loc, src.sound_togglebolts, 50, 0)
			else
				var/obj/cable/C = locate() in get_turf(src)
				if(C)
					src.connected = 1
					src.anchored = 1
					boutput(user, "You activate the interdictor's magnetic lock.")
					playsound(src.loc, src.sound_togglebolts, 50, 0)
					if(intcap.charge == intcap.maxcharge && !src.canInterdict)
						src.start_interdicting()
				else
					boutput(user, "<span class='alert'>The interdictor must be installed onto an electrical cable.</span>")
		else
			boutput(user, "<span class='alert'>The interdictor's magnetic locks have just toggled, and can't currently be toggled again.</span>")

	attackby(obj/item/W as obj, mob/user as mob)
		if(ispulsingtool(W))
			boutput(user, "<span class='notice'>The interdictor's internal capacitor is currently at [src.intcap.charge] of [src.intcap.maxcharge] units.</span>")
		else
			..()


/obj/machinery/interdictor/proc/updateicon()
	var/ratio = max(0, src.intcap.charge / src.intcap.maxcharge)
	ratio = round(ratio, 0.33) * 100
	var/image/I_chrg = SafeGetOverlayImage("charge", 'icons/obj/machines/interdictor.dmi', "idx-charge-[ratio]")
	I_chrg.plane = PLANE_OVERLAY_EFFECTS
	UpdateOverlays(I_chrg, "charge", 0, 1)

	var/gridtie = src.connected && powered()
	var/image/I_grid = SafeGetOverlayImage("grid", 'icons/obj/machines/interdictor.dmi', "idx-grid-[gridtie]")
	I_grid.plane = PLANE_OVERLAY_EFFECTS
	UpdateOverlays(I_grid, "grid", 0, 1)

	var/image/I_actv = SafeGetOverlayImage("active", 'icons/obj/machines/interdictor.dmi', "idx-active-[canInterdict]")
	I_actv.plane = PLANE_OVERLAY_EFFECTS
	UpdateOverlays(I_actv, "active", 0, 1)


/obj/machinery/interdictor/process(mult)
	var/doupdateicon = 1 //avoids repeating icon updates, might be goofy
	if (status & BROKEN)
		return
	if(!intcap)
		status |= BROKEN
		doupdateicon = 0
		src.stop_interdicting()
		message_admins("Interdictor at ([showCoords(src.x, src.y, src.z)]) is missing a power cell. This is not supposed to happen, yell at kubius")
		return
	if(anchored)
		if(intcap.charge < intcap.maxcharge && powered())
			var/added = intcap.give(src.chargerate * mult)
			//boutput(world, "yep [added / CELLRATE]")
			if(!src.canInterdict)
				playsound(src.loc, src.sound_interdict_run, 5, 0, 0, 0.8)
			use_power(added / CELLRATE)
		if(intcap.charge == intcap.maxcharge && !src.canInterdict)
			doupdateicon = 0
			src.start_interdicting()
	else
		if(src.canInterdict)
			doupdateicon = 0
			src.stop_interdicting()
	if(src.hasInterdicted)
		src.hasInterdicted = 0
		playsound(src.loc, src.sound_interdict_run, 50, 0)

	if(doupdateicon)
		src.updateicon()



//call this from an event to determine if sufficient power is remaining to complete an interdiction,
//passing an amount in cell charge that is required to interdict the event.
//returns 1 if interdiction was successful, 0 if power was insufficient
/obj/machinery/interdictor/proc/expend_interdict(var/stopcost)
	if (status & BROKEN || !src.canInterdict)
		return 0
	if (!intcap || intcap.charge < stopcost)
		src.stop_interdicting()
		return 0
	else
		intcap.use(stopcost)
		return 1


//initalizes interdiction, including visual depiction of range
/obj/machinery/interdictor/proc/start_interdicting()
	for(var/turf/T in orange(INTERDICT_RANGE,src))
		if (get_dist(T,src) != INTERDICT_RANGE)
			continue
		var/obj/interdict_edge/YEE = new /obj/interdict_edge(T)
		src.deployed_fields += YEE

	src.canInterdict = 1
	playsound(src.loc, src.sound_interdict_on, 50, 1)
	src.updateicon()


//ceases interdiction
/obj/machinery/interdictor/proc/stop_interdicting()
	for(var/obj/interdict_edge/YEE in src.deployed_fields)
		src.deployed_fields -= YEE
		qdel(YEE)

	src.canInterdict = 0
	playsound(src.loc, src.sound_interdict_off, 50, 1)
	src.updateicon()


/obj/interdict_edge
	name = "interdiction barrier"
	desc = "Delineates the functional area of a nearby spatial interdictor."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdict-edge"
	anchored = 1
	density = 0
	alpha = 128
	plane = PLANE_OVERLAY_EFFECTS
