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

	var/cumulative_cost = 0 // keeps a tally of used power per tick
	//used to play interdiction noise / modulate its volume

	var/interdict_range = 5 // range of the interdictor's field
	//for effects that are wide-band interdicted, such as solar flares, this should dictate the response strength

	var/interdict_class = ITDR_STANDARD // type of interdictor
	//standard interdictors provide only the stellar phenomena protection; alternate variants unlock new functionality

	var/list/deployed_fields = list()

	var/sound/sound_interdict_on = 'sound/machines/interdictor_activate.ogg'
	var/sound/sound_interdict_off = 'sound/machines/interdictor_deactivate.ogg'
	var/sound/sound_interdict_run = 'sound/machines/interdictor_operate.ogg'
	var/sound/sound_togglebolts = 'sound/machines/click.ogg'

	New(spawnlocation,var/obj/item/cell/altcap,var/obj/item/interdictor_rod/altrod,var/obj/item/interdictor_board/altboard,var/datum/material/mat)
		if(altcap)
			altcap.set_loc(src)
			src.intcap = altcap
		else
			src.intcap = new /obj/item/cell/supercell/charged(src)

		if(altrod)
			src.interdict_range = altrod.interdist
			qdel(altrod)

		if(altboard)
			src.interdict_class = altboard.interdict_class
			switch(src.interdict_class)
				if(ITDR_NIMBUS)
					src.name = "Nimbus-class [src.name]"
					src.desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. This one charges cyborgs, too!"
				if(ITDR_ZEPHYR)
					src.name = "Zephyr-class [src.name]"
					src.desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. This one comes with a second wind."
			qdel(altboard)

		if(mat)
			src.setMaterial(mat)
		else
			src.setMaterial(material_cache["steel"])
		..()
		START_TRACKING
		src.UpdateIcon()

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

	attack_hand(mob/user)
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

	attackby(obj/item/W, mob/user)
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

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.intcap)
			src.intcap = null

	// Typed variants for manual spawning

	nimbus
		interdict_class = ITDR_NIMBUS
		name = "Nimbus-class spatial interdictor"
		desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. This one charges cyborgs, too!"

	zephyr
		interdict_class = ITDR_ZEPHYR
		name = "Nimbus-class spatial interdictor"
		desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. This one comes with a second wind."


/obj/machinery/interdictor/update_icon()
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
		message_admins("Interdictor at ([log_loc(src)]) is missing a power cell. This is not supposed to happen, yell at kubius")
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
	if(src.cumulative_cost)
		var/sound_strength = clamp(cumulative_cost/30,5,30)
		if(src.canInterdict)
			playsound(src.loc, src.sound_interdict_run, sound_strength, 0)
		src.cumulative_cost = 0

	if(doupdateicon)
		src.UpdateIcon()



//call this from an event to determine if sufficient power is remaining to complete an interdiction,
//passing an amount in cell charge that is required to interdict the event.
//returns 1 if interdiction was successful, 0 if power was insufficient

//first arg specifies the cell charge required to successfully Do the Thing

//second arg specifies where the interdiction is happening, in the case of localized interdictions; leave null for things like solar flares

//third arg optionally skips immediate visual update (use if potential for very high amounts of individual calls)

//fourth arg optionally specifies an alternate function type the operation requires (used for/by the alternate mainboards)

/obj/machinery/interdictor/proc/expend_interdict(var/stopcost,var/target = null,var/skipanim = FALSE,var/alt_function)
	if (status & BROKEN || !src.canInterdict || (alt_function && alt_function != src.interdict_class))
		return 0
	if (target && !IN_RANGE(src,target,src.interdict_range))
		return 0
	if (!intcap || intcap.charge < stopcost)
		src.stop_interdicting()
		return 0
	else
		intcap.use(stopcost)
		src.cumulative_cost += stopcost
		if(!skipanim) src.updatecharge()
		return 1


//initalizes interdiction, including visual depiction of range
/obj/machinery/interdictor/proc/start_interdicting()
	for(var/turf/T in orange(src.interdict_range,src))
		if (GET_DIST(T,src) != src.interdict_range)
			continue
		var/obj/interdict_edge/YEE = new /obj/interdict_edge(T)
		src.deployed_fields += YEE

	src.canInterdict = 1
	playsound(src.loc, src.sound_interdict_on, 40, 0)
	SPAWN(rand(30,40)) //after it's been on for a little bit, check for tears
		if(src.canInterdict)
			for (var/obj/forcefield/event/tear in by_type[/obj/forcefield/event])
				SPAWN(rand(8,22)) //stagger stabilizations, since it's getting stabilized post-formation
					if (!tear.stabilized && IN_RANGE(src,tear,src.interdict_range) && src.expend_interdict(800))
						tear.stabilize()
	src.UpdateIcon()


//ceases interdiction
/obj/machinery/interdictor/proc/stop_interdicting()
	for(var/obj/interdict_edge/YEE in src.deployed_fields)
		src.deployed_fields -= YEE
		qdel(YEE)

	src.canInterdict = 0
	playsound(src.loc, src.sound_interdict_off, 40, 1)
	src.UpdateIcon()


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

//interdictor rod: the doohickey that lets the interdictor do its thing
//these are a primary factor for scarcity as they require several materials to manufacture, alongside the power cells
//can be manufactured by installing /obj/item/disk/data/floppy/manudrive/interdictor_parts

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

//interdictor board: power management circuitry and whatnot. alternate boards yield different functionality
//can be manufactured by installing /obj/item/disk/data/floppy/manudrive/interdictor_parts

/obj/item/interdictor_board
	name = "spatial interdictor mainboard"
	desc = "A custom-fabricated circuit board with a cutting-edge miniaturized retro-encabulator."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdict-board"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	mats = 6
	health = 6
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS | CONDUCT
	var/interdict_class = ITDR_STANDARD

	nimbus
		name = "Nimbus interdictor mainboard"
		desc = "A custom-fabricated circuit board with additional micro-transformers. Grants interdictors the ability to wirelessly charge cyborgs."
		interdict_class = ITDR_NIMBUS

	zephyr
		name = "Zephyr interdictor mainboard"
		desc = "A custom-fabricated circuit board with biomimetic coprocessing. Causes interdictors' field to gain beneficial bioelectric properties."
		interdict_class = ITDR_ZEPHYR

//interdictor frame kit: supplies the frame that is the basis for assembling the interdictor (lo and behold)
//can be manufactured by installing /obj/item/disk/data/floppy/manudrive/interdictor_parts

/obj/item/interdictor_kit
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
			var/obj/frame = new /obj/interdictor_frame( get_turf(user) )
			frame.fingerprints = src.fingerprints
			frame.fingerprints_full = src.fingerprints_full
			qdel(src)

//unconstructed interdictor, where the assembly procedure happens

/obj/interdictor_frame
	name = "spatial interdictor frame"
	desc = "An unassembled frame for a spatial interdictor. Several bolts are sticking out."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interframe-0"
	density = 1
	var/state = 0
	var/obj/intcap = null
	var/obj/introd = null
	var/obj/intboard = null

	attack_hand(mob/user)
		if(state == 4) //permit removal of cell before you install wires
			src.state = 3
			src.icon_state = "interframe-3"
			boutput(user, "<span class='notice'>You remove \the [intcap] from the interdictor's cell compartment.</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 40, 1)

			user.put_in_hand_or_drop(src.intcap)
			src.intcap = null
			src.desc = "A semi-complete frame for a spatial interdictor. Its power cell compartment is empty."
			return
		..()

	attackby(var/obj/item/I, var/mob/user)
		switch(state)
			if(0)
				if (iswrenchingtool(I))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 2 SECONDS), user)
				else
					..()
			if(1)
				if (istype(I, /obj/item/interdictor_board))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 1 SECOND), user)
				else
					..()
			if(2)
				if (istype(I, /obj/item/interdictor_rod))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 1 SECOND), user)
				else
					..()
			if(3)
				if (istype(I, /obj/item/cell))
					src.state = 4
					src.icon_state = "interframe-4"
					boutput(user, "<span class='notice'>You install \the [I] into the interdictor's cell compartment.</span>")
					playsound(src, 'sound/items/Deconstruct.ogg', 40, 1)

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
						actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 1 SECOND), user)
				else
					..()
			if(5)
				if (istype(I, /obj/item/electronics/soldering))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 1 SECOND), user)
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
		if (itdr == null || the_tool == null || owner == null || BOUNDS_DIST(owner, itdr) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (itdr.state == 0)
			playsound(itdr, 'sound/items/Ratchet.ogg', 40, 1)
		if (itdr.state == 1)
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
		if (itdr.state == 2)
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
		if (itdr.state == 4)
			playsound(itdr, 'sound/items/Deconstruct.ogg', 40, 1)
		if (itdr.state == 5)
			playsound(itdr, 'sound/effects/zzzt.ogg', 30, 1)
		if (itdr.state == 6)
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
	onEnd()
		..()
		if (itdr.state == 0) //unassembled > no components
			itdr.state = 1
			itdr.icon_state = "interframe-1"
			boutput(owner, "<span class='notice'>You assemble and secure the frame components.</span>")
			playsound(itdr, 'sound/items/Ratchet.ogg', 40, 1)
			itdr.desc = "A frame for a spatial interdictor. It's missing its mainboard."
			return
		if (itdr.state == 1) //no components > mainboard
			itdr.state = 2
			itdr.icon_state = "interframe-2"
			boutput(owner, "<span class='notice'>You install the interdictor mainboard.</span>")
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)

			var/mob/source = owner
			source.u_equip(the_tool)
			the_tool.set_loc(itdr)
			itdr.intboard = the_tool

			itdr.desc = "A frame for a spatial interdictor. It's missing a phase-control rod."
			return
		if (itdr.state == 2) //mainboard > mainboard and rod
			itdr.state = 3
			itdr.icon_state = "interframe-3"
			boutput(owner, "<span class='notice'>You install the phase-control rod.</span>")
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)

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
			playsound(itdr, 'sound/items/Deconstruct.ogg', 40, 1)

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
			playsound(itdr, 'sound/effects/zzzt.ogg', 40, 1)
			itdr.desc = "A nearly-complete frame for a spatial interdictor. It's missing a casing."
			return
		if (itdr.state == 6)
			boutput(owner, "<span class='notice'>You install a metal casing onto the interdictor, completing its construction.</span>")
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)

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
			var/obj/llama = new /obj/machinery/interdictor(T,itdr.intcap,itdr.introd,itdr.intboard,mat)
			itdr.intcap.set_loc(llama) //this may not be necessary but I feel like it'll stop something from randomly breaking due to timing
			qdel(itdr)
			return
