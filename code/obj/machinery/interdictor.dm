//device for engineers to construct that counteracts the effects of random events in its radius,
//if it has been set up a sufficient time in advance

//all references to range should use INTERDICT_RANGE (defined in _std\defines\construction.dm)

/obj/machinery/interdictor
	name = "spatial interdictor"
	desc = "A sophisticated device that lessens or nullifies the effects of assorted stellar phenomena."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdictor"
	power_usage = 1250 //drawn only while interdiction field is active; charging is a separate usage value
	density = 1
	anchored = 0
	req_access = list(access_engineering)
	var/obj/item/cell/intcap = null //short for internal capacitor.
	var/chargerate = 700 // internal cell charge rate, per tick
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

	New(var/obj/item/cell/altcap)
		if(altcap)
			altcap.set_loc(src)
			src.intcap = altcap
		else
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
		if(!src.allowed(user))
			boutput(user, "<span class='alert'>Engineering clearance is required to operate the interdictor's locks.</span>")
			return
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
					src.anchored = 1
					src.connected = 1
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


//updates only the charge overlay, used when charge is depleted by interdiction
/obj/machinery/interdictor/proc/updatecharge()
	var/ratio = max(0, src.intcap.charge / src.intcap.maxcharge)
	ratio = round(ratio, 0.33) * 100
	var/image/I_chrg = SafeGetOverlayImage("charge", 'icons/obj/machines/interdictor.dmi', "idx-charge-[ratio]")
	I_chrg.plane = PLANE_OVERLAY_EFFECTS
	UpdateOverlays(I_chrg, "charge", 0, 1)


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
		if(src.canInterdict)
			use_power(src.power_usage)
	else
		if(src.canInterdict)
			doupdateicon = 0
			src.stop_interdicting()
	if(src.hasInterdicted)
		src.hasInterdicted = 0
		if(src.canInterdict)
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
		src.hasInterdicted = 1
		src.updatecharge()
		return 1


//initalizes interdiction, including visual depiction of range
/obj/machinery/interdictor/proc/start_interdicting()
	for(var/turf/T in orange(INTERDICT_RANGE,src))
		if (get_dist(T,src) != INTERDICT_RANGE)
			continue
		var/obj/interdict_edge/YEE = new /obj/interdict_edge(T)
		src.deployed_fields += YEE

	src.canInterdict = 1
	playsound(src.loc, src.sound_interdict_on, 50, 0)
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
	alpha = 64
	plane = PLANE_OVERLAY_EFFECTS


//assembly zone

/obj/item/interdictor_rod
	name = "interdictor phase-control rod"
	desc = "A large, narrow cylinder with a highly-conductive core and inbuilt control circuitry."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdict-rod"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | CONDUCT

/obj/item/interdictor_board
	name = "spatial interdictor mainboard"
	desc = "A custom-fabricated circuit board with a cutting-edge miniaturized retro-encabulator."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdict-board"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	mats = 6
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS | CONDUCT


/obj/interdictor_kit
	name = "spatial interdictor frame"
	desc = "A frame for a spatial interdictor. It's missing its mainboard."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interframe-1"
	density = 1
	var/state = 1
	var/obj/intcap = null

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		switch(state)
			if(1)
				if (istype(I, /obj/item/interdictor_board))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 2 SECONDS), user)
				else
					boutput(user, "<span style=\"color:red\">The control box is missing a mainboard.</span>")
			if(2)
				if (istype(I, /obj/item/interdictor_rod))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 2 SECONDS), user)
				else
					boutput(user, "<span style=\"color:red\">The pillar section seems to require some sort of tall rod.</span>")
			if(3)
				if (istype(I, /obj/item/cell))
					src.state = 4
					src.icon_state = "interframe-4"
					boutput(user, "<span class='notice'>You install.</span>")
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 40, 1)

					user.u_equip(I)
					I.set_loc(src)
					src.intcap = I

					src.desc = "A semi-complete frame for a spatial interdictor. Its components haven't been wired together."
					return
				else
					boutput(user, "<span style=\"color:red\">A small compartment with electrical contacts is sitting empty.</span>")
			if(4)
				if (istype(I, /obj/item/cable_coil))
					if (I.amount < 4)
						boutput(user, "<span style=\"color:red\">You don't have enough cable to connect the components (4 required).</span>")
					else
						actions.start(new /datum/action/bar/icon/warp_beacon_assembly(src, I, 4 SECONDS), user)
				else
					boutput(user, "<span style=\"color:red\">All the components seem to be installed, but there's no wiring.</span>")
			if(5)
				if (istype(I, /obj/item/soldering_iron))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 2 SECONDS), user)
				else
					boutput(user, "<span style=\"color:red\">The wiring hasn't been soldered into place.</span>")
			if(6)
				if (istype(I, /obj/item/sheet/steel))
					if (I.amount < 4)
						boutput(user, "<span style=\"color:red\">You don't have enough metal to install the outer covers (4 required).</span>")
					else
						actions.start(new /datum/action/bar/icon/warp_beacon_assembly(src, I, 2 SECONDS), user)
				else
					boutput(user, "<span style=\"color:red\">The interdictor's systems appear complete and ready to accept a metal casing.</span>")


//this is to be used with the following transitions:
//1 > 2 (board installation)
//2 > 3 (core installation)
//4 > 5 (wire addition)
//5 > 6 (wire soldering)
//6 > complete (plating )
//transition 3 > 4 (battery installation) is done without an action bar as it's just putting a battery in a little slot
//there is no visual difference between stage 5 and 6, both use stage 5 icon state
/datum/action/bar/icon/interdictor_assembly
	id = "interdictor_assembly"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 2 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/interdictor_kit/itdr
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			itdr = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (itdr == null || the_tool == null || owner == null || get_dist(owner, itdr) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (itdr.state == 1)
			playsound(get_turf(itdr), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins installing a mainboard into \the [itdr].")
		if (itdr.state == 2)
			playsound(get_turf(itdr), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins installing a phase-control rod into \the [itdr].")
		if (itdr.state == 4)
			playsound(get_turf(itdr), "sound/items/Deconstruct.ogg", 40, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins connecting \the [itdr]'s electrical systems.")
		if (itdr.state == 5)
			playsound(get_turf(itdr), "sound/effects/zzzt.ogg", 30, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins soldering \the [itdr]'s wiring into place.")
		if (itdr.state == 6)
			playsound(get_turf(itdr), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins installing a casing onto \the [itdr].")
	onEnd()
		..()
		if (itdr.state == 1) //no components > mainboard
			itdr.state = 2
			itdr.icon_state = "interframe-2"
			boutput(owner, "<span class='notice'>You successfully install the interdictor mainboard.</span>")
			playsound(get_turf(itdr), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)

			var/mob/source = owner
			source.u_equip(the_tool)
			qdel(the_tool)

			itdr.desc = "A frame for a spatial interdictor. It's missing a phase-control rod."
			return
		if (itdr.state == 2) //mainboard > mainboard and rod
			itdr.state = 3
			itdr.icon_state = "interframe-3"
			boutput(owner, "<span class='notice'>You finish wiring together the itdr's electronics.</span>")
			playsound(get_turf(itdr), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)

			var/mob/source = owner
			source.u_equip(the_tool)
			qdel(the_tool)

			itdr.desc = "A semi-complete frame for a spatial interdictor. Its battery compartment is empty."
			return
		if (itdr.state == 4) //all components > all components and wired
			itdr.state = 5
			itdr.icon_state = "interframe-5"
			boutput(owner, "<span class='notice'>You finish wiring together the interdictor's systems.</span>")
			playsound(get_turf(itdr), "sound/items/Deconstruct.ogg", 40, 1)

			the_tool.amount -= 4
			if (the_tool.amount < 1)
				var/mob/source = owner
				source.u_equip(the_tool)
				qdel(the_tool)
			else if(the_tool.inventory_counter)
				the_tool.inventory_counter.update_number(the_tool.amount)

			itdr.desc = "A nearly-complete frame for a spatial interdictor. Its wiring hasn't been soldered in place."
			return
		if (itdr.state == 5) //all components and wired > all components and soldered
			itdr.state = 6
			itdr.icon_state = "interframe-5"
			boutput(owner, "<span class='notice'>You solder the wiring into place. The internal systems are now fully installed.</span>")
			playsound(get_turf(itdr), "sound/effects/zzzt.ogg", 40, 1)
			itdr.desc = "A nearly-complete frame for a spatial interdictor. It's missing a casing."
			return
		if (itdr.state == 6)
			boutput(owner, "<span class='notice'>You install a metal casing onto the interdictor, completing its construction.</span>")
			playsound(get_turf(itdr), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)

			the_tool.amount -= 4
			if (the_tool.amount < 1)
				var/mob/source = owner
				source.u_equip(the_tool)
				qdel(the_tool)
			else if(the_tool.inventory_counter)
				the_tool.inventory_counter.update_number(the_tool.amount)

			var/turf/T = get_turf(itdr)
			var/obj/llama = new /obj/machinery/interdictor(T,itdr.intcap)
			qdel(itdr)
			return
