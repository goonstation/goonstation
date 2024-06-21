///A prototypist "artifact reverse-engineer" reward: hybridized Martian tech turning food into synthflesh "patches"
/obj/machinery/medimulcher
	name = "APS-4 bio-integrator"
	desc = "According to the label, eats food and turns it into medicine. According to your eyes, possibly a crime against nature."
	icon = 'icons/obj/manufacturer.dmi'
	//icon_state = "medimulcher"
	anchored = ANCHORED
	density = 1
	flags = NOSPLASH
	power_usage = 2 KILO WATTS
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR

	///Current amount of held food.
	var/stomach = 0
	///How many "units" of food can be held in wait for digestion.
	var/max_stomach = 100
