/obj/machinery/autochem
	name = "Automatic ChemDispenser"
	desc = "Like the ChemDispenser, but controlable with components"
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	//flags = NOSPLASH not sure if I want to do an interface or not
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	dispensable_reagents = basic_elements
