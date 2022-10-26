// connect reactors to central fission engine

// Load for a typical station is about 50,000

/**********************************************
ENGINE
**********************************************/

/obj/machinery/power/fission/engine
	name = "fission engine"
	desc = "a fission engine, used to convert matter into energy via fission"

	icon = 'icons/obj/machines/nuclear.dmi'
	icon_state = "engineoff"

	anchored = 1
	density = 1

	directwired = 1

	// To connect it to the computer
	var/id = 0

	var/lastpower = 0
	var/active = 0
	// Maximum of 3 reactors attached the fission computer
	var/list/obj/machinery/fission/reactor/reactors = list()

	New()
		..()
		SPAWN(1 DECI SECOND)
			setupLinks()



	proc/setupLinks()
		for(var/obj/machinery/fission/reactor/R in machine_registry[MACHINES_FISSION])
			if(src.id == R.id)
				src.reactors.Add(R)
		for(var/obj/machinery/computer/fission/F in machine_registry[MACHINES_FISSION])
			if(src.id == F.id)
				F.theEngine = src

	update_icon()
		if(status & BROKEN)
			icon_state = "enginebrok"
			active = 0
			return
		if(status & NOPOWER)
			icon_state = "enginenopow"
			active = 0
			return
		if(active)
			if(lastpower > 0)
				icon_state = "enginepoweredworking"
			else
				icon_state = "enginepowered"
		else
			icon_state = "engineoff"

	power_change()
		UpdateIcon()
		..()

	process()

		if(src.active == 0)
			return

		var/power = 0
		var/efficiency = 5

		for(var/obj/machinery/fission/reactor/R in reactors)

			power += R.getEnergy()
			R.setEnergyZero()

		power = power*efficiency
		src.lastpower = power
		add_avail(power)
		..()

	attack_hand(mob/user)
		if(status & (BROKEN | NOPOWER))
			boutput(user, "The engine won't turn on.")
			return
		else
			src.active = !src.active
			boutput(user, "You turn [src.active ? "on" : "off"] the engine.")
			if(src.active == 0) src.lastpower = 0
			UpdateIcon()
			return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/device/analyzer/atmospheric))
			boutput(user, "<span class='notice'>The analyzer detects that [lastpower]W are being produced.</span>")

		else
			src.add_fingerprint(user)
			boutput(user, "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")
			for(var/mob/M in AIviewers(src))
				if(M == user)	continue
				M.show_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>")


/**********************************************
REACTOR
**********************************************/

/obj/fission
	anchored = 1
	density = 1
	invisibility = INVIS_ALWAYS

// 3 or so reactors or whatever
/obj/machinery/fission/reactor
	name = "fission reactor"
	desc = "one of the reactors for a fission engine"

	anchored = 1
	density = 1

	icon = 'icons/obj/machines/nuclear64x32.dmi'
	icon_state = "reactoroff"

	machine_registry_idx = MACHINES_FISSION
	// We can have at any time a maximum of 5 fuel rods and 5 control rods
	var/list/obj/item/rod/fuel/fuelRods = list()
	var/list/obj/item/rod/control/controlRods = list()

	var/obj/fission/daughter

	// Icon related
	// If the rods are lowered
	var/rodsLowered = 0

	// Meltdown is 0 when no meltdown is occuring
	// Meltdown is 1 when a meltdown is occuring
	// Meltdown is 2 when a meltdown has occured
	var/meltdown = 0
	// It is active when there is a fission reaction going down
	// I.e. we're not turning it off or on
	var/active = 0
	// Use this so as to not loose energy in our calculations
	var/setEnergyZero = 0
	// To connect it to the engine
	var/id = 0
	// Energy generated
	var/energy = 0
	// Temperature of the reactor
	var/temperature = T20C
	// Pressure of the reactor
	var/pressure = ONE_ATMOSPHERE;

	proc/getEnergy()
		return src.energy

	proc/setEnergyZero()
		src.setEnergyZero = 1

	New()
		..()
		daughter = new/obj/fission(get_step(src, EAST))
		setupCherenkovRad()

		// 5 Rods of each type
		fuelRods.len = 5
		controlRods.len = 5

	process()
		UpdateIcon()

		if (status & BROKEN)
			return

		if(meltdown)
			// Might put some code in here to continiously pump gases into the station
			return

		checkChainReaction()

		// It cools or heats if inactive
		if(!src.active)
			if(temperature < T20C)
				temperature += 0.01
			else if(temperature > T20C)
				temperature -= 0.01
			if(temperature / T20C < 1.1 && temperature / T20C > 0.9)
				temperature = T20C
			return

		var/tempenergy

		var/numConRods = 1
		// Control rods absorb neutrons leading to less chain reactions,
		// therefore less fuel is depleted and temperature and energy are less
		for(var/obj/item/rod/control/CR in controlRods)
			if(CR.condition > 0 && CR.lowered)
				CR.condition -= 2
				numConRods++

			else if (CR.condition <= 0) CR.condition = 0

		// So for the maximum number of rods
		// Minimum temperature increase is: 50
		// Maximum temperature increase is: 300
		// Maximum fuel depletion is 60 per rod
		// Minimum fuel depletion is 10 per rod
		for(var/obj/item/rod/fuel/FR in fuelRods)
			if(!FR.chainReactionPossible || !FR.lowered)
				continue
			FR.activated = 1

			if(FR.amount > 0)

				// used to be rad particle code here creating it

				temperature += 60 / numConRods
				FR.amount -= 60 / numConRods

			else FR.amount = 0

		if(setEnergyZero)
			src.energy = 0
			src.setEnergyZero = 0

		// Roughly 8 minutes on full, or 50 minutes if you're careful
		// Adjust for fun
		if(temperature > 150000)
			meltdown()

		// Heat energy converts to light energy, sound energy, and electrical energy
		// SHIT THATS REALLY INEFFICIENT
		// Typical station needs ~50,000W
		// Each engine (assuming 3) should generate 16,666W then
		// But we want to make it so that if they're generating this then
		// They're very close to melting down so 0.1 solves this.
		tempenergy += temperature*0.1
		// Meltdown happens when the fuel rods melt and the fuel leaks into the coolant
		src.energy += tempenergy

		..()

	proc/setupCherenkovRad()

	UpdateIcon()
		if (status & BROKEN)
			icon_state = "reactoroff"
			return

		if(meltdown == 1)
			icon_state = "meltdown"

		else if (meltdown == 2)
			icon_state = "broken"

		else
			if(temperature > 100000)
				if(rodsLowered)
					icon_state = "toohot3"
				else
					icon_state = "toohot0"
			else
				if(rodsLowered)
					icon_state = "norm3"
				else
					icon_state = "norm0"

	proc/meltdown()
		meltdown = 1

		// used to be rad particle code here creating it

		SPAWN(0.8 SECONDS)
			meltdown = 2


	proc/checkChainReaction()
		// At least one fuel rod should be activated
		for(var/obj/item/rod/fuel/FR in fuelRods)
			if(!FR.chainReactionPossible) continue
			if(FR.activated && FR.lowered)
				src.active = 1
				return
		src.active = 0

	attack_hand(mob/user)
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/rod/fuel))
			// Putting it into an empty list variable
			for(var/i = 1; i<=fuelRods.len; i++)
				if(isnull(fuelRods[i]))
					fuelRods[i] = W
					// Unequipping
					user.u_equip(W)
					W.set_loc(src)
					W.dropped(user)
					// Letting everyone around know
					boutput(user, "<span class='alert'>You insert the [W] into the [src].</span>")
					for(var/mob/M in AIviewers(src))
						if(M == user)	continue
						M.show_message("<span class='alert'>[user.name] inserts the [W] into the [src].</span>")
					return

			boutput(user, "<span class='alert'>No more fuel rods can fit into the reactor.</span>")

		else if(istype(W, /obj/item/rod/control))
			for(var/i = 1; i<=controlRods.len; i++)
				if(isnull(controlRods[i]))
					controlRods[i] = W
					user.u_equip(W)
					W.set_loc(src)
					W.dropped(user)
					boutput(user, "<span class='alert'>You insert the [W] into the [src].</span>")
					for(var/mob/M in AIviewers(src))
						if(M == user)	continue
						M.show_message("<span class='alert'>[user.name] inserts the [W] into the [src].</span>")
					return

			boutput(user, "<span class='alert'>No more control rods can fit into the reactor.</span>")

		else
			src.add_fingerprint(user)
			boutput(user, "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")
			for(var/mob/M in AIviewers(src))
				if(M == user)	continue
				M.show_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>")

	ex_act(severity)
		if(meltdown)
			return

		// Called when an object is in an explosion
		// Higher "severity" means the object was further from the centre of the explosion
		switch(severity)
			if(1)
				status |= BROKEN
				return
			if(2)
				if (prob(50))
					status |= BROKEN
					return
			if(3)
				if (prob(25))
					status |= BROKEN
					return
			else
		return
