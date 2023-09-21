//device for engineers to construct that counteracts the effects of random events in its zone,
//if it has been set up a sufficient time in advance

/obj/machinery/interdictor
	name = "spatial interdictor"
	desc = "A sophisticated device that lessens or nullifies the effects of assorted stellar phenomena."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdictor"
	power_usage = 1250 //drawn while interdiction field is active; charging is a separate usage value that can be concurrent
	density = 1
	var/resisted = FALSE //Changes if someone is being protected from a radstorm
	anchored = UNANCHORED
	req_access = list(access_engineering)

	///Internal capacitor; the cell installed internally during construction, which acts as a capacitor for energy used in interdictor operation.
	var/obj/item/cell/intcap = null

	///Current target rate at which the internal capacitor may be charged, in cell units restored per tick.
	var/chargerate = 100
	///Maximum allowable internal capacitor charge rate for user configuration.
	var/chargerate_max = 500
	///Minimum allowable internal capacitor charge rate for user configuration.
	var/chargerate_min = 50

	///Tracks whether interdictor is tied into area power and ready to attempt operation.
	var/connected = 0

	///Cooldown after the magnetic lock switches on or off before it can be toggled again.
	var/maglock_cooldown = 3 SECONDS

	///Tracks whether the interdictor has been emagged, removing the device's maglock access restriction.
	var/emagged = 0

	///Indication of operability; if 0, whether from depletion or new installation, internal cell must fill to set this to 1 and activate interdiction
	var/canInterdict = 0

	///Tally of power used for interdiction in this machine tick. Used to determine presence and volume of the interdictor operating noise.
	var/cumulative_cost = 0

	///Set during radstorm interdiction; when true, a cost has been paid in this tick, and further radstorm interdictions inside the tick are free.
	var/radstorm_paid = FALSE

	///Range of the interdictor's field; for effects that are wide-band interdicted, such as solar flares, this should dictate the response strength.
	var/interdict_range = 5

	///Type of interdictor. Standard interdictors provide only the stellar phenomena protection; alternate variants unlock new functionality.
	var/interdict_class = ITDR_STANDARD

	///Interdiction cost multiplier. Some part selections can influence this value, raising or lowing the effective energy cost of device functions.
	var/interdict_cost_mult = 1

	///List of fields that the interdictor has deployed; these fields are strictly visual, and outline the interdictor's operating range for clarity.
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
			if(altrod.power_multiplier)
				src.interdict_cost_mult *= altrod.power_multiplier
			qdel(altrod)

		if(altboard)
			src.interdict_class = altboard.interdict_class
			switch(src.interdict_class)
				if(ITDR_STANDARD)
					src.interdict_range++
				if(ITDR_NIMBUS)
					src.name = "Nimbus-class [src.name]"
					src.desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. This one charges cyborgs, too!"
				if(ITDR_ZEPHYR)
					src.name = "Zephyr-class [src.name]"
					src.desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. This one comes with a second wind."
				if(ITDR_DEVERA)
					src.name = "Devera-class [src.name]"
					src.desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. Smells faintly of ozone."
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
		if(!emagged && !src.allowed(user))
			boutput(user, "<span class='alert'>Engineering clearance is required to operate the interdictor's locks.</span>")
			return
		if(!ON_COOLDOWN(src, "maglocks", src.maglock_cooldown))
			if(anchored)
				if(src.canInterdict)
					src.stop_interdicting()
				src.anchored = UNANCHORED
				src.connected = 0
				boutput(user, "You deactivate the interdictor's magnetic lock.")
				playsound(src.loc, src.sound_togglebolts, 50, 0)
			else
				var/clear_field = TRUE
				for_by_tcl(IX, /obj/machinery/interdictor)
					if(IX.canInterdict)
						var/net_range = max(src.interdict_range,IX.interdict_range)
						if(IN_RANGE(src,IX,net_range))
							clear_field = FALSE
							break
				if(clear_field)
					src.anchored = ANCHORED
					src.connected = 1
					boutput(user, "You activate the interdictor's magnetic lock.")
					playsound(src.loc, src.sound_togglebolts, 50, 0)
					if(intcap.charge >= (intcap.maxcharge * 0.7) && !src.canInterdict)
						src.start_interdicting()
				else
					boutput(user, "<span class='alert'>An interdictor is already active within range.</span>")
		else
			boutput(user, "<span class='alert'>The interdictor's magnetic locks were just toggled and can't yet be toggled again.</span>")

	attackby(obj/item/W, mob/user)
		if(ispulsingtool(W))
			if(emagged || src.allowed(user))
				var/chargescale = input(user,"Minimum [src.chargerate_min] | Maximum [src.chargerate_max] | Current [src.chargerate]","Target Recharge per Cycle","1") as num
				chargescale = clamp(chargescale,src.chargerate_min,src.chargerate_max)
				src.chargerate = chargescale
				return
		else if(istype(W, /obj/item/card/id))
			if(!emagged && !src.check_access(W))
				boutput(user, "<span class='alert'>Engineering clearance is required to operate the interdictor's locks.</span>")
				return
			else if(!ON_COOLDOWN(src, "maglocks", src.maglock_cooldown))
				if(anchored)
					if(src.canInterdict)
						src.stop_interdicting()
					src.anchored = UNANCHORED
					src.connected = 0
					boutput(user, "You deactivate the interdictor's magnetic lock.")
					playsound(src.loc, src.sound_togglebolts, 50, 0)
				else
					var/clear_field = TRUE
					for_by_tcl(IX, /obj/machinery/interdictor)
						if(IX.canInterdict)
							var/net_range = max(src.interdict_range,IX.interdict_range)
							if(IN_RANGE(src,IX,net_range))
								clear_field = FALSE
								break
					if(clear_field)
						src.anchored = ANCHORED
						src.connected = 1
						boutput(user, "You activate the interdictor's magnetic lock.")
						playsound(src.loc, src.sound_togglebolts, 50, 0)
						if(intcap.charge >= (intcap.maxcharge * 0.7) && !src.canInterdict)
							src.start_interdicting()
					else
						boutput(user, "<span class='alert'>Cannot activate interdictor - another field is already active within operating bounds.</span>")
		else
			..()

	examine()
		. = ..()
		. += "\n <span class='notice'>The interdictor's internal capacitor is currently at [src.intcap.charge] of [src.intcap.maxcharge] units.</span>"

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.intcap)
			src.intcap = null

	// Typed variants for manual spawning or map placement

	unlocked
		req_access = null
		name = "unlocked spatial interdictor"
		desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. A small tag indicates its access requirement has been removed."

	nimbus
		interdict_class = ITDR_NIMBUS
		name = "Nimbus-class spatial interdictor"
		desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. This one charges cyborgs, too!"

	zephyr
		interdict_class = ITDR_ZEPHYR
		name = "Zephyr-class spatial interdictor"
		desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. This one comes with a second wind."

	devera
		interdict_class = ITDR_DEVERA
		name = "Devera-class spatial interdictor"
		desc = "A device that lessens or nullifies the effects of assorted stellar phenomena. Smells fainly of ozone."


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


///Small visual update proc used for interdictions that want to immediately show an expenditure of charge and don't need a full update_icon
/obj/machinery/interdictor/proc/updatecharge()
	var/ratio = max(0, src.intcap.charge / src.intcap.maxcharge)
	ratio = round(ratio, 0.33) * 100
	var/image/I_chrg = SafeGetOverlayImage("charge", 'icons/obj/machines/interdictor.dmi', "idx-charge-[ratio]")
	I_chrg.plane = PLANE_OVERLAY_EFFECTS
	I_chrg.appearance_flags |= RESET_COLOR
	UpdateOverlays(I_chrg, "charge", 0, 1)


/obj/machinery/interdictor/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		src.emagged = 1
		playsound(src, 'sound/effects/sparks4.ogg', 50)
		if(user)
			boutput(user, "You short out the access lock on [src].")
		return 1
	return 0

/obj/machinery/interdictor/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair the access lock on [src].")
	src.emagged = 0
	return 1


/obj/machinery/interdictor/process()
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
		if (src.resisted)
			radstorm_interdict(src)
			src.resisted = FALSE
		if(intcap.charge < intcap.maxcharge && powered())
			var/amount_to_add = min(round(intcap.maxcharge - intcap.charge, 10), src.chargerate)
			if(amount_to_add)
				var/added = intcap.give(amount_to_add)
				if(!src.canInterdict && !ON_COOLDOWN(src, "interdictor_noise", 20 SECONDS))
					playsound(src.loc, src.sound_interdict_run, 5, 0, 0, 0.8)
				use_power(added / CELLRATE)
		if(intcap.charge >= (intcap.maxcharge * 0.7) && !src.canInterdict)
			doupdateicon = 0
			src.start_interdicting()
		if(src.canInterdict)
			use_power(src.power_usage)
	else
		if(src.canInterdict)
			doupdateicon = 0
			src.stop_interdicting()
	if(src.cumulative_cost)
		if(src.cumulative_cost >= 50) //if the cost was very minor, don't even make a sound
			var/sound_strength = clamp(cumulative_cost/10,5,25)
			if(src.canInterdict && !ON_COOLDOWN(src, "interdictor_noise", 20 SECONDS))
				playsound(src.loc, src.sound_interdict_run, sound_strength, 0)
		src.cumulative_cost = 0
	if(src.radstorm_paid)
		src.updatecharge()
		src.radstorm_paid = FALSE

	if(doupdateicon)
		src.UpdateIcon()



/**
 * Things capable of being influenced by a spatial interdictor call this proc when iterating over interdictors.
 * The core function of interdictors is to suppress energy-based random events; other beneficial functions are provided by alternate mainboards.
 *
 * The first argument (use_cost) is the cost in cell power units, charged to the interdictor's internal cell on successful expenditure.
 * It's passed through modified_use_cost to take into account any multipliers on efficiency provided by installed parts.
 *
 * The second argument (target) specifies a range-checking target for localized effect application (i.e. blocking a radiation pulse).
 * To perform a global interdiction (such as shielding from solar flares), this argument can be skipped entirely.
 *
 * The third argument (skipanim), if set to true, skips immediate visual update of the interdictor (instead allowing it to update on machine tick).
 * For high-volume blocking, such as shielding a large set of tiles from an effect, this should be used.
 *
 * The fourth argument (itdr_class) optionally passes in an interdictor class that's required for successful expenditure.
 * This is used for alternate functionality, such as wireless cyborg charging; random event blocking should not pass a specific class requirement.
 * These classes are numbers, but should use the defines, such as ITDR_ZEPHYR. Interdictors are given a class by the mainboard used in assembly.
 */
/obj/machinery/interdictor/proc/expend_interdict(var/use_cost,var/target = null,var/skipanim = FALSE,var/itdr_class)
	if (status & BROKEN || !src.canInterdict || (itdr_class && itdr_class != src.interdict_class))
		return 0
	if (target && !IN_RANGE(src,target,src.interdict_range))
		return 0
	var/net_use_cost = ceil(use_cost * src.interdict_cost_mult)
	if (!intcap || intcap.charge < net_use_cost)
		src.stop_interdicting()
		return 0
	else
		intcap.use(net_use_cost)
		src.cumulative_cost += net_use_cost
		if(!skipanim) src.updatecharge()
		return 1

///Specialized radiation storm interdiction proc that allows multiple protections under a single unified cost per process.
/obj/machinery/interdictor/proc/radstorm_interdict()
	var/use_cost = 350 //how much it costs per machine tick to interdict radstorms, regardless of number of mobs protected
	if (!src.resisted) //Don't spend power if no one is around to protect
		return
	if (status & BROKEN || !src.canInterdict)
		return 0
	if (!intcap)
		src.stop_interdicting()
		return 0
	else
		if(!src.radstorm_paid) //check if we still need to pay the cost for this machine tick; if we don't, good to go, just return right away
			var/net_use_cost = ceil(use_cost * src.interdict_cost_mult)
			if(intcap.charge > net_use_cost)
				intcap.use(net_use_cost)
				src.cumulative_cost += net_use_cost
				src.radstorm_paid = TRUE
			else
				src.stop_interdicting()
				return 0
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
					if (!tear.stabilized && src.expend_interdict(800,tear))
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
	anchored = ANCHORED
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

	///How far the interdictor constructed with this rod will extend its interdiction field. Also influences strength against non-localized phenomena.
	var/interdist = 4

	///If present, influences the efficiency of interdictor operation. Lower number is more efficiency.
	var/power_multiplier = null

	phi
		name = "Phi phase-control rod"
		desc = "A large, narrow cylinder with a conductive core and control circuitry. Substantially increases interdictor efficiency at a cost of range."
		interdist = 2
		power_multiplier = 0.6

	sigma
		name = "Sigma phase-control rod"
		desc = "A large, narrow cylinder with a highly conductive core and inbuilt control circuitry. Grants full range to interdictors."
		icon_state = "interdict-rod-ex"
		interdist = 6

	epsilon
		name = "Epsilon phase-control rod"
		desc = "A large, narrow cylinder with a conductive core and control circuitry. Substantially increases interdictor range at a cost of efficiency."
		icon_state = "interdict-rod-ex"
		interdist = 10
		power_multiplier = 1.8

//interdictor board: power management circuitry and whatnot. alternate boards yield different functionality
//can be manufactured by installing /obj/item/disk/data/floppy/manudrive/interdictor_parts

TYPEINFO(/obj/item/interdictor_board)
	mats = 6

/obj/item/interdictor_board
	name = "spatial interdictor mainboard"
	desc = "A custom-fabricated circuit board with a cutting-edge miniaturized retro-encabulator."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdict-board"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
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

	devera
		name = "Devera interdictor mainboard"
		desc = "A custom-fabricated circuit board with an ionization lattice. Causes interdictors' field to suppress some topical and aerosolized microbes."
		interdict_class = ITDR_DEVERA

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
			playsound(src, 'sound/items/Deconstruct.ogg', 40, TRUE)

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
					playsound(src, 'sound/items/Deconstruct.ogg', 40, TRUE)

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
				if (isscrewingtool(I))
					actions.start(new /datum/action/bar/icon/interdictor_assembly(src, I, 1 SECOND), user)
				else
					..()
			if(6)
				if (istype(I, /obj/item/sheet))
					var/obj/item/sheet/sheets = I
					if (sheets.amount < 4 || !(sheets.material.getMaterialFlags() & MATERIAL_METAL))
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
//5 > 6 (screw down wire terminals)
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
			playsound(itdr, 'sound/items/Ratchet.ogg', 40, TRUE)
		if (itdr.state == 1)
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
		if (itdr.state == 2)
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
		if (itdr.state == 4)
			playsound(itdr, 'sound/items/Deconstruct.ogg', 40, TRUE)
		if (itdr.state == 5)
			playsound(itdr, 'sound/items/Screwdriver.ogg', 30, TRUE)
		if (itdr.state == 6)
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
	onEnd()
		..()
		if (itdr.state == 0) //unassembled > no components
			itdr.state = 1
			itdr.icon_state = "interframe-1"
			boutput(owner, "<span class='notice'>You assemble and secure the frame components.</span>")
			playsound(itdr, 'sound/items/Ratchet.ogg', 40, TRUE)
			itdr.desc = "A frame for a spatial interdictor. It's missing its mainboard."
			return
		if (itdr.state == 1) //no components > mainboard
			itdr.state = 2
			itdr.icon_state = "interframe-2"
			boutput(owner, "<span class='notice'>You install the interdictor mainboard.</span>")
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)

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
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)

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
			playsound(itdr, 'sound/items/Deconstruct.ogg', 40, TRUE)

			the_tool.amount -= 4
			if (the_tool.amount < 1)
				var/mob/source = owner
				source.u_equip(the_tool)
				qdel(the_tool)
			else if(the_tool.inventory_counter)
				the_tool.inventory_counter.update_number(the_tool.amount)

			itdr.desc = "A nearly-complete frame for a spatial interdictor. Its wire terminals haven't been secured."
			return
		if (itdr.state == 5) //all components and wired > all components and secured
			itdr.state = 6
			itdr.icon_state = "interframe-5"
			boutput(owner, "<span class='notice'>You finish securing the wire terminals. The internal systems are now fully installed.</span>")
			playsound(itdr, 'sound/items/Screwdriver.ogg', 30, TRUE)
			itdr.desc = "A nearly-complete frame for a spatial interdictor. It's missing a casing."
			return
		if (itdr.state == 6)
			boutput(owner, "<span class='notice'>You install a metal casing onto the interdictor, completing its construction.</span>")
			playsound(itdr, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)

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
