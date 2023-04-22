/obj/machinery/autochem

	name = "Automatic ChemDispenser"
	desc = "Like the ChemDispenser, but controlable with components"
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenserautoidle"
	//Connected Chemi compiler
	var/connected_CC = null
	var/output_reservoir = 1
	var/selected_element = null

	var/list/dispensable_reagents = null
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL



	New()
		..()
		dispensable_reagents = list("aluminium","barium","bromine","calcium","carbon","chlorine", \
		"chromium","copper","ethanol","fluorine","hydrogen", \
		"iodine","iron","lithium","magnesium","mercury","nickel", \
		"nitrogen","oxygen","phosphorus","plasma","platinum","potassium", \
		"radium","silicon","silver","sodium","sugar","sulfur","water") //allows the strange option for someone to add automatic alcohol dispenser, also just yoinked from ChemDispenser code :)
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "element", .proc/setelement)
		selected_element = "aluminium" //to make it not pour null


	proc/setelement(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Select an element to dispense:", "Element", null) as text | null
		if(!input || !dispensable_reagents.Find(input))
			return
		else
			selected_element = input

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the dispenser's output target.</span>")
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, "<span class='alert'>The dispenser is too far away from the target!</span>")
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		else if (istype(over_object,/obj/machinery/chemicompiler_stationary))
			src.connected_CC = over_object
			boutput(usr, "<span class='notice'>You set the dispenser to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return
					//TODO
					//Make iconstate change to dispenserauto while active
					//Make machine connectable to chemicompiler
					//Add a config signal to change reservoir number
					//Integrate power functions into this (should just have to copy a bunch of stuff from other machines)
					//Make the machine actually dispense chemicals
					//Add instructions into qm package
