/*
	A fancy schmancy nuclear engine being built for Manta

	Uses radioactive stuff to make electricity

*/

#define MELTDOWN_TEMP 1405 // Melting point of Uranium in kelvin
#define DECAY_CONSTANT = 0.00057762265 // ln(2)/(ticks per half life). Currently set to 20 minute half life
#define NUCLEAR_TICK_CONSTANT eulers ** DECAY_CONSTANT

/obj/machinery/nuclear_engine
	name = "Nuclear reactor core"
	desc = "I'm sure there's no way this could go wrong!"
	icon = 'icons/obj/machines/nuclear128x64.dmi'
	icon_state = "reactor_off"
	anchored = 2
	density = 1


	var/list/obj/item/fuel_rod/fuel_rods = list()
	var/list/obj/item/control_rod/control_rods = list()
	var/list/

	var/control_rod_level = 100

	var/temperature = T20C // Start at room temperature

	New()
		..()

	process()
		..()

		// Heat up accoding to strength
		for(var/obj/item/nuclear_fuel_rod)
			return

// TODO: Irradiate people based on the number of fuel rods currently in the reactors
/area/station/engine/core/nuclear
	name = "Nuclear reactor room"

/obj/item/nuclear_fuel_rod
	desc = "Put it in a reactor core. Ideally while wearing radiation protection gear. Or not. Do whatever, I'm not your mom."
	var/strength = 0

/obj/item/nuclear_fuel_rod/u235
	name = "Uranium-235 Fuel Rod"
	color = "#00FF00"
	strength = 1

/obj/item/nuclear_control_rod
	name = "Control rod"
	desc = "A rod of boron capable of absorbing excess neutrons released from nuclear fission."
