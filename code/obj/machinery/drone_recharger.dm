
/obj/machinery/drone_recharger
	name = "Drone Recharger"
	icon = 'icons/obj/32x64.dmi'
	desc = "A wall-mounted station for drones to recharge at. Automatically activated on approach."
	icon_state = "drone-charger-idle"
	density = 0
	anchored = 1
	mats = 10
	power_usage = 50
	machine_registry_idx = MACHINES_DRONERECHARGERS
	var/chargerate = 400
	var/mob/living/silicon/ghostdrone/occupant = null
	var/transition = 0 //For when closing
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	New()
		..()

	disposing()
		if(occupant)
			occupant.set_loc(get_turf(src.loc))
			occupant = null
		..()

	process()
		if(!(status & BROKEN))
			if (occupant)
				power_usage = 500
			else
				power_usage = 50
			..()
		if(status & (NOPOWER|BROKEN) || !anchored)
			if (src.occupant)
				src.turnOff("nopower")
			return

		if(src.occupant)
			if (src.occupant.loc != src.loc || isdead(src.occupant)) // they left or died
				src.turnOff()
				return
			if (!occupant.cell)
				return
			else if (occupant.cell.charge >= occupant.cell.maxcharge) //fully charged yo
				occupant.cell.charge = occupant.cell.maxcharge
				src.turnOff("fullcharge")
				return
			else
				occupant.cell.charge += src.chargerate
				use_power(50)
				return
		return 1

	HasEntered(atom/movable/AM as mob|obj, atom/OldLoc)
		..()
		if (!src.occupant && isghostdrone(AM) && !src.transition)
			src.turnOn(AM)

	HasExited(atom/movable/AM as mob|obj)
		..()
		if (AM.loc != src.loc && src.occupant == AM && isghostdrone(AM))
			src.turnOff()

	examine()
		. = ..()
		if (src.occupant)
			. += "<span class='notice'>[src.occupant] is currently using it.</span>"

	proc/turnOn(mob/living/silicon/ghostdrone/G)
		if (!G || G.getStatusDuration("stunned")) return 0

		out(G, "<span class='notice'>The [src] grabs you as you float by and begins charging your power cell.</span>")
		src.set_density(1)
		G.canmove = 0

		//Do opening thing
		src.icon_state = "drone-charger-open"
		SPAWN_DBG(0.7 SECONDS) //Animation is 6 ticks, 1 extra for byond
			src.occupant = G
			src.updateSprite()
			G.charging = 1
			G.set_dir(SOUTH)
			G.updateSprite()
			G.canmove = 1

		return 1

	proc/turnOff(reason)
		if (!src.occupant || src.occupant.newDrone) return 0

		var/msg = "<span class='notice'>"
		if (reason == "nopower")
			msg += "The [src] spits you out seconds before running out of power."
		else if (reason == "fullcharge")
			msg += "The [src] beeps happily and disengages. You are full."
		else
			msg += "The [src] disengages, allowing you to float [pick("serenely", "hurriedly", "briskly", "lazily")] away."
		out(src.occupant, "[msg]</span>")

		src.occupant.charging = 0
		src.occupant.setFace(src.occupant.faceType, src.occupant.faceColor)
		src.occupant.updateHoverDiscs(src.occupant.faceColor)
		src.occupant.updateSprite()
		src.occupant = null

		//Do closing thing
		src.icon_state = "drone-charger-close"
		src.transition = 1
		SPAWN_DBG(0.7 SECONDS)
			src.set_density(0)
			src.transition = 0
			src.updateSprite()

		return 1

	proc/updateSprite()
		if (src.occupant)
			src.icon_state = "drone-charger-charging"
		else
			src.icon_state = "drone-charger-idle"

		return 1


	ex_act(severity)

	blob_act(var/power)

	meteorhit()

	emp_act()

	bullet_act(var/obj/projectile/P)

	power_change()

	attack_hand(var/mob/user as mob)

	emag_act(var/mob/user, var/obj/item/card/emag/E)

	attackby(obj/item/W as obj, mob/user as mob)


/obj/machinery/drone_recharger/factory
	var/id = "ghostdrone"
	mats = 0
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	HasEntered(atom/movable/AM as mob|obj, atom/OldLoc)
		if (!src.occupant && istype(AM, /obj/item/ghostdrone_assembly) && !src.transition)
			src.createDrone(AM)
		..()

	proc/createDrone(var/obj/item/ghostdrone_assembly/G)
		if (!istype(G))
			return 0
		var/mob/living/silicon/ghostdrone/GD = new(src.loc)
		if (GD)
			pool(G)
			GD.newDrone = 1
			available_ghostdrones += GD
			src.turnOn(GD)
			if (ghostdrone_factory_working)
				ghostdrone_factory_working = null
			return 1
		return 0
