///ship components have their work proc called in the vehicle's process
/obj/item/shipcomponent
	name = "Ship Component"
	icon = 'icons/obj/ship.dmi'
	icon_state = "default"
	flags = FPRINT | TABLEPASS| CONDUCT
	/// How much of the engine's capacity the part takes up
	var/power_used = 0
	/// The owner of the part
	var/obj/machinery/vehicle/ship = null
	/// If the part is working or not
	var/active = 0
	/// Some parts need setup before full functionality
	var/ready = 1
	/// Determines if a part can be installed.
	var/component_class = 0
	/// What system it is, to avoid a bunch of istype checks
	var/system = "part"

// Code to clean up a shipcomponent that is no longer in use
/obj/item/shipcomponent/disposing()
	if(src.loc == ship)
		ship.components -= src
	ship = null
	..()

//Code for when device needs recharging
/obj/item/shipcomponent/proc/ready()
	return

/obj/item/shipcomponent/proc/toggle()
	if (active)
		deactivate()
	else
		activate()

//What the component does when activated
/obj/item/shipcomponent/proc/activate()
	if(src.active == 1 || !ship)//NYI find out why ship is null
		return
	if(ship.powercapacity < (ship.powercurrent + power_used))
		for(var/mob/M in ship)
			boutput(M, "[ship.ship_message("Not enough power to activate [src]!")]")
			return
	else
		ship.powercurrent += power_used

	src.active = 1
	for(var/mob/M in src.ship)
		boutput(M, "[ship.ship_message("[src] is coming online...")]")
		mob_activate(M)
	if (src.ship.myhud)
		src.ship.myhud.update_states()
	return

///Component does this constantly
/obj/item/shipcomponent/proc/run_component()
	return

///What the component does when deactived
/obj/item/shipcomponent/proc/deactivate()
	if(src.active == 0)
		return
	src.active = 0
	ship.powercurrent -= power_used
	for(var/mob/M in src.ship)
		boutput(M, "[ship.ship_message("[src] is shutting down...")]")
		mob_deactivate(M)
	src.ship.myhud.update_states()
	return
///Handles mob entering ship
/obj/item/shipcomponent/proc/mob_activate(mob/M as mob)
	return
///Handles mob exiting from ship
/obj/item/shipcomponent/proc/mob_deactivate(mob/M as mob)
	return
//Opens the control panel for that component if it has one
/obj/item/shipcomponent/proc/opencomputer()
	return

/obj/item/shipcomponent/proc/after_time(time as num)
	var/turf/T = ship.loc
	sleep(time)
	if (ship.loc == T )
		return 1
	else
		return 0

//In case stuff should be done when the ship breaks
/obj/item/shipcomponent/proc/on_shipdeath(var/obj/machinery/vehicle/ship)
	src.ship = null
	return
