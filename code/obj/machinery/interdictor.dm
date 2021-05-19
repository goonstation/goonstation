//device for engineers to construct that counteracts the effects of random events in its zone,
//if it has been set up a sufficient time in advance

/obj/machinery/interdictor
	name = "spatial interdictor"
	desc = "A sophisticated device that lessens or nullifies the effects of assorted stellar phenomena."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdictor"
	power_usage = 1250 //drawn while interdiction field is active; charging is a separate usage value that can be concurrent
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

	var/interdict_range = 7 // range of the interdictor's field
	//for effects that are wide-band interdicted, such as solar flares, this should dictate the response strength

	var/list/deployed_fields = list()

	var/sound/sound_interdict_on = "sound/machines/interdictor_activate.ogg"
	var/sound/sound_interdict_off = "sound/machines/interdictor_deactivate.ogg"
	var/sound/sound_interdict_run = "sound/machines/interdictor_operate.ogg"
	var/sound/sound_togglebolts = "sound/machines/click.ogg"

	New(spawnlocation,var/obj/item/cell/altcap,var/obj/item/interdictor_rod/altrod,var/datum/material/mat)
		if(altcap)
			altcap.set_loc(src)
			src.intcap = altcap
		else
			src.intcap = new /obj/item/cell/supercell(src) //deliberately not charged
		if(altrod)
			src.interdict_range = altrod.interdist
			qdel(altrod)
		if(mat)
			src.setMaterial(mat)
		else
			src.setMaterial(material_cache["steel"])
		..()
		START_TRACKING
		src.updateicon()

	disposing()
		STOP_TRACKING
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
			boutput(user, "<span class='alert'>The interdictor's magnetic locks were just toggled and can't yet be toggled again.</span>")

	attackby(obj/item/W as obj, mob/user as mob)
		if(ispulsingtool(W))
			boutput(user, "<span class='notice'>The interdictor's internal capacitor is currently at [src.intcap.charge] of [src.intcap.maxcharge] units.</span>")
			return
		else if(istype(W, /obj/item/card/id))
			if(!src.check_access(W))
				boutput(user, "<span class='alert'>Engineering clearance is required to operate the interdictor's locks.</span>")
				return
			else if(!ON_COOLDOWN(src, "maglocks", src.maglock_cooldown))
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
			..()


/obj/machinery/interdictor/proc/updateicon()
	var/ratio = max(0, src.intcap.charge / src.intcap.maxcharge)
	ratio = round(ratio, 0.33) * 100
	var/image/I_chrg = SafeGetOverlayImage("charge", 'icons/obj/machines/interdictor.dmi', "idx-charge-[ratio]")
	I_chrg.plane = PLANE_OVERLAY_EFFECTS
	I_chrg.appearance_flags |= RESET_COLOR
	UpdateOverlays(I_chrg, "charge", 0, 1)

	var/gridtie = src.connected && powered()
	var/image/I_grid = SafeGetOverlayImage("grid", 'icons/obj/machines/interdictor.dmi', "idx-grid-[gridtie]")
	I_grid.plane = PLANE_OVERLAY_EFFECTS
	I_grid.appearance_flags |= RESET_COLOR
	UpdateOverlays(I_grid, "grid", 0, 1)

	var/image/I_actv = SafeGetOverlayImage("active", 'icons/obj/machines/interdictor.dmi', "idx-active-[canInterdict]")
	I_actv.plane = PLANE_OVERLAY_EFFECTS
	I_actv.appearance_flags |= RESET_COLOR
	UpdateOverlays(I_actv, "active", 0, 1)


//updates only the charge overlay, used when charge is depleted by interdiction
/obj/machinery/interdictor/proc/updatecharge()
	var/ratio = max(0, src.intcap.charge / src.intcap.maxcharge)
	ratio = round(ratio, 0.33) * 100
	var/image/I_chrg = SafeGetOverlayImage("charge", 'icons/obj/machines/interdictor.dmi', "idx-charge-[ratio]")
	I_chrg.plane = PLANE_OVERLAY_EFFECTS
	I_chrg.appearance_flags |= RESET_COLOR
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
			playsound(src.loc, src.sound_interdict_run, 30, 0)

	if(doupdateicon)
		src.updateicon()



//call this from an event to determine if sufficient power is remaining to complete an interdiction,
//passing an amount in cell charge that is required to interdict the event.
//returns 1 if interdiction was successful, 0 if power was insufficient
//second arg skips immediate visual update (use if potential for very high amounts of individual calls)
/obj/machinery/interdictor/proc/expend_interdict(var/stopcost,var/skipanim)
	if (status & BROKEN || !src.canInterdict)
		return 0
	if (!intcap || intcap.charge < stopcost)
		src.stop_interdicting()
		return 0
	else
		intcap.use(stopcost)
		src.hasInterdicted = 1
		if(!skipanim) src.updatecharge()
		return 1


//initalizes interdiction, including visual depiction of range
/obj/machinery/interdictor/proc/start_interdicting()
	for(var/turf/T in orange(src.interdict_range,src))
		if (get_dist(T,src) != src.interdict_range)
			continue
		var/obj/interdict_edge/YEE = new /obj/interdict_edge(T)
		src.deployed_fields += YEE

	src.canInterdict = 1
	playsound(src.loc, src.sound_interdict_on, 40, 0)
	src.updateicon()


//ceases interdiction
/obj/machinery/interdictor/proc/stop_interdicting()
	for(var/obj/interdict_edge/YEE in src.deployed_fields)
		src.deployed_fields -= YEE
		qdel(YEE)

	src.canInterdict = 0
	playsound(src.loc, src.sound_interdict_off, 40, 1)
	src.updateicon()


/obj/interdict_edge
	name = "interdiction barrier"
	desc = "Delineates the functional area of a nearby spatial interdictor."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdict-edge"
	anchored = 1
	density = 0
	alpha = 80
	plane = PLANE_OVERLAY_EFFECTS


//assembly zone

//interdictor guide: how to make it and use it
//engineering should start with one of these
//adjacent to the rod/frame blueprint and the mainboards

/obj/item/paper/book/interdictor
	name = "Spatial Interdictor Assembly and Use, 3rd Edition"
	icon_state = "engiguide"
	info = {"<h1>SPATIAL INTERDICTOR ASSEMBLY AND USE</h1>
	<p><i>3rd Edition - Compiled for Nanotrasen by Servin Underwriting, LTD - (C) 2049 All Rights Reserved</i></p>
	<h2>PLEASE READ CAREFULLY</h2>
	<br>
	Congratulations on your recent acquisition or allocation of cutting-edge interdiction technology!
	<br>
	<br>
	Using the power of yottahertz-range electromagnetic counter-interference, the Spatial Interdictor provides robust protection against a wide array of stellar phenomena:
	<br>
	<br>
	Biomagnetic fields nulled on discharge
	<br>
	Black holes semi-stabilized, increasing time to respond**
	<br>
	Radiation pulses safely remodulated within field range
	<br>
	Radiation storms interdicted on a per-individual basis*
	<br>
	Solar flare disruptions reduced per onboard interdictor
	<br>
	Spatial tears stabilized, permitting limited traversal**
	<br>
	Unstable wormholes nulled when entry is attempted
	<br>
	<br>
	<i>*ADVISORY: heavy interdiction cost. Multiple interdictors or powerful cell recommended for crowds.</i>
	<br>
	<i>**WARNING: total interdiction impossible, and device must be active beforehand.</i>
	<br>
	<br>
	In just a few short steps, worrying about the myriad hazards of space will be a thing of the past!^
	<br>
	<br>
	<i>^Please be aware that no liability is assumed for failure to interdict any events absent from or present within the aforementioned list. Physical hazards such as meteor storms will not be interdicted.</i>
	<br>
	<br>
	<hr>
	<h3>ASSEMBLING THE DEVICE</h3>
	<br>
	(I) Assemble the frame kit and phase-control rod at any manufacturer using the blueprints included with your Spatial Interdictor Starter Kit. Materials not provided.
	<br>
	Phase control rods may be manufactured in Lambda or Sigma configurations. Lambda rods cover a three-unit radius, while the advanced but more materially complex Sigma rods cover a seven-unit radius.
	<br>
	<i>Use of non-standard phase-control rods is not supported in this guide. Please consult a Nanotrasen certified engineer for a custom interdiction solution, including appropriate power cell.</i>
	<br>
	<br>
	(II) Gather the following equipment before assembly:
	<br>
	- Interdictor frame kit
	<br>
	- Interdictor mainboard
	<br>
	- Interdictor phase-control rod
	<br>
	- Industry-compliant power cell (high-capacity heavily recommended, as installation is permanent)
	<br>
	- Four lengths of industry-compliant electrical cable
	<br>
	- Soldering iron
	<br>
	- Four sheets of industry-compliant steel
	<br>
	<br>
	(III) Assemble objects in the sequence they are listed in the enumeration. Once assembled, the device may be transported to the site of utilisation to be connected and activated.
	<br>
	<br>
	<hr>
	<h3>USING THE DEVICE</h3>
	<br>
	Due to the advanced technologies incorporated into the Spatial Interdictor's mainboard, it will automatically begin operating when conditions are suitable.
	<br>
	<br>
	Suitable conditions are: Adequate internal cell charge, direct link to an electrical grid cable, active magnetic anchoring.
	<br>
	<br>
	To activate magnetic anchoring, simply touch the control pad located on the front side of the rectangular regulator unit.
	<br>
	<br>
	For safety purposes, activating or deactivating magnetic anchoring requires the user to possess an identification card with at least base-level Engineering access.
	<br>
	<br>
	The Spatial Interdictor is equipped with three distinct indicators, each representing a different aspect of its functionality:
	<br>
	<br>
	- The charge meter, located on the side of the interdiction pillar. This represents the current capacity of the buffer cell, and <b>must be full for interdiction to begin.</b>
	<br>
	<br>
	- The interdiction emitter, located on the top of the interdiction pillar. While illuminated, the Interdictor is currently active and protecting its surroundings.
	<br>
	<br>
	- The grid-tie indicator, located on the front of the regulator unit. Illumination means the Interdictor is correctly installed, and able to charge, or activate if charged.
	<br>
	<hr>
	<p><i>For further information, ask for mentor help or consult Nanotrasen's on-line data-base. Thank you for your service to Nanotrasen.</i></p>
	"}

//interdictor rod: the doohickey that lets the interdictor do its thing
//the blueprint to create this should be in engineering along with guide, frame blueprint and mainboards
//these are the primary factor for scarcity as they require several materials to manufacture
//blueprint paths: /obj/item/paper/manufacturer_blueprint/interdictor_rod_lambda & /obj/item/paper/manufacturer_blueprint/interdictor_rod_sigma

/obj/item/interdictor_rod
	name = "Lambda phase-control rod"
	desc = "A large, narrow cylinder with a standard core and inbuilt control circuitry. Grants a lower range to interdictors."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdict-rod"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "rods"
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | CONDUCT
	var/interdist = 3
	//how far the interdictor constructed with this rod will extend its interdiction field

	sigma
		name = "Sigma phase-control rod"
		desc = "A large, narrow cylinder with a highly conductive core and inbuilt control circuitry. Grants full range to interdictors."
		icon_state = "interdict-rod-ex"
		interdist = 7

//interdictor board: power management circuitry and whatnot
//engineering should start with about three of these,
//adjacent to the rod/frame blueprint and the interdictor assembly and use guide.
//mechanics can scan to reproduce

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

//interdictor frame: main framework for assembling the interdictor (lo and behold)
//the blueprint to create this should be in engineering along with guide, rod blueprint and mainboards
//blueprint path is /obj/item/paper/manufacturer_blueprint/interdictor_frame

/obj/item/interdictor_frame_kit
	name = "spatial interdictor frame kit"
	desc = "You can hear an awful lot of junk rattling around in this box."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdict-kit"
	w_class = W_CLASS_BULKY

	attack_self(mob/user as mob)
		var/canbuild = 1

		var/turf/T = get_turf(user)
		var/atom/A

		if (istype(T, /turf/space))
			for (A in T)
				if (A == user)
					continue
				if (A.density)
					canbuild = 0
					boutput(user, "<span class='alert'>You can't build this here! [A] is in the way.</span>")
					break

		if (canbuild)
			boutput(user, "<span class='notice'>You empty the box of parts onto the floor.</span>")
			var/obj/O = new /obj/interdictor_frame( get_turf(user) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
			qdel(src)

/obj/interdictor_frame
	name = "spatial interdictor frame"
	desc = "An unassembled frame for a spatial interdictor. Several bolts are sticking out."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interframe-0"
	density = 1
	var/state = 0
	var/obj/intcap = null
	var/obj/introd = null

	attack_hand(mob/user as mob)
		if(state == 4) //permit removal of cell before you install wires
			src.state = 3
			src.icon_state = "interframe-3"
			boutput(user, "<span class='notice'>You remove \the [intcap] from the interdictor's cell compartment.</span>")
			playsound(get_turf(src), "sound/items/Deconstruct.ogg", 40, 1)

			user.put_in_hand_or_drop(src.intcap)
			src.intcap = null
			src.desc = "A semi-complete frame for a spatial interdictor. Its power cell compartment is empty."
			return
		..()

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		switch(state)
			if(0)
				if (iswrenchingtool(I))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 4 SECONDS), user)
				else
					..()
			if(1)
				if (istype(I, /obj/item/interdictor_board))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 2 SECONDS), user)
				else
					..()
			if(2)
				if (istype(I, /obj/item/interdictor_rod))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 2 SECONDS), user)
				else
					..()
			if(3)
				if (istype(I, /obj/item/cell))
					src.state = 4
					src.icon_state = "interframe-4"
					boutput(user, "<span class='notice'>You install \the [I] into the interdictor's cell compartment.</span>")
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 40, 1)

					user.u_equip(I)
					I.set_loc(src)
					src.intcap = I

					src.desc = "A semi-complete frame for a spatial interdictor. Its components haven't been wired together."
					return
				else
					..()
			if(4)
				if (istype(I, /obj/item/cable_coil))
					if (I.amount < 4)
						boutput(user, "<span style=\"color:red\">You don't have enough cable to connect the components (4 required).</span>")
					else
						actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 4 SECONDS), user)
				else
					..()
			if(5)
				if (istype(I, /obj/item/electronics/soldering))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 2 SECONDS), user)
				else
					..()
			if(6)
				if (istype(I, /obj/item/sheet))
					var/obj/item/sheet/sheets = I
					if (sheets.amount < 4 || !(sheets.material.material_flags & MATERIAL_METAL))
						boutput(user, "<span style=\"color:red\">You don't have enough metal to install the outer covers (4 required).</span>")
					else
						actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 2 SECONDS), user)
				else
					..()


//this is to be used with the following transitions:
//0 > 1 (frame assembly)
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

	var/obj/interdictor_frame/itdr
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
		if (itdr.state == 0)
			playsound(get_turf(itdr), "sound/items/Ratchet.ogg", 40, 1)
			owner.visible_message("<span class='bold'>[owner]</span> begins assembling \the [itdr].")
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
		if (itdr.state == 0) //unassembled > no components
			itdr.state = 1
			itdr.icon_state = "interframe-1"
			boutput(owner, "<span class='notice'>You assemble and secure the frame components.</span>")
			playsound(get_turf(itdr), "sound/items/Ratchet.ogg", 40, 1)
			itdr.desc = "A frame for a spatial interdictor. It's missing its mainboard."
			return
		if (itdr.state == 1) //no components > mainboard
			itdr.state = 2
			itdr.icon_state = "interframe-2"
			boutput(owner, "<span class='notice'>You install the interdictor mainboard.</span>")
			playsound(get_turf(itdr), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)

			var/mob/source = owner
			source.u_equip(the_tool)
			qdel(the_tool)

			itdr.desc = "A frame for a spatial interdictor. It's missing a phase-control rod."
			return
		if (itdr.state == 2) //mainboard > mainboard and rod
			itdr.state = 3
			itdr.icon_state = "interframe-3"
			boutput(owner, "<span class='notice'>You install the phase-control rod.</span>")
			playsound(get_turf(itdr), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)

			var/mob/source = owner
			source.u_equip(the_tool)
			the_tool.set_loc(itdr)
			itdr.introd = the_tool

			itdr.desc = "A semi-complete frame for a spatial interdictor. Its power cell compartment is empty."
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

			//setting up for custom interdictor casing
			var/obj/item/sheet/S = the_tool
			var/datum/material/mat
			if(S.material)
				mat = S.material

			the_tool.amount -= 4
			if (the_tool.amount < 1)
				var/mob/source = owner
				source.u_equip(the_tool)
				qdel(the_tool)
			else if(the_tool.inventory_counter)
				the_tool.inventory_counter.update_number(the_tool.amount)

			var/turf/T = get_turf(itdr)
			var/obj/llama = new /obj/machinery/interdictor(T,itdr.intcap,itdr.introd,mat)
			itdr.intcap.set_loc(llama) //this may not be necessary but I feel like it'll stop something from randomly breaking due to timing
			qdel(itdr)
			return
