/obj/machinery/autochem

	name = "Automatic ChemDispenser"
	desc = "Like the ChemDispenser, but controlable with components"
	density = 1
	anchored = UNANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenserautoidle"
	//Connected Chemi compiler
	var/connected_CC = null
	var/output_reservoir = 1
	var/selected_element = null
	var/selected_reservoir = 1

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
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Element", .proc/setelement)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Set Reservoir", .proc/setreservoir)
		selected_element = "aluminium" //to make it not pour null


	proc/setelement(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Select an element to dispense:", "Element", null) as text | null
		if(!input || !dispensable_reagents.Find(input))
			boutput(user, "That is not a valid chemical.")
			return
		else
			selected_element = lowertext(input)
			boutput(user, "Selected chemical set to [selected_element]")
	proc/setreservoir(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Select an reservoir to dispense to:", "Reservoir", null) as num | null
		if(!input || input < 1 || input > 10) //checks if there is an input and if it is within the 1-10 reservoirs
			boutput(user, "That is not a valid reservoir number, try from 1-10.")
			return
		else
			selected_reservoir = input
			boutput(user, "Selected reservoir set to [selected_reservoir]")

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
	attackby(obj/item/W, mob/user)
		 if(iswrenchingtool(W))
		 	if(src.anchored)
				src.anchored = UNANCHORED
				boutput(user, "<span class='notice'>You unanchor [name] from the floor.</span>")
			else
				src.anchored = ANCHORED
				boutput(user, "<span class='notice'>You anchor [name] to the floor.</span>")
		else ..()






/obj/item/paper/autochem
	name = "AutoChem Dispenser setup guide"
	info = {"
	---------------------------<br>
	Guide to setting up your new Automatic Chemical Dispenser<br>
	---------------------------<br><br>
	Ever wanted to make a large amount of chemicals, but didn't like pressing that gosh-darned button on your chemical dispenser so much?<br><br>
	<b>Well this is the product for you!</b><br><br>
	Packed with many little button pushers, this machine will dispense all the chemicals you need without all the work!<br><br><br>

	Step one: Anchor your new ACD to the floor.<br>
	This can be done easily with a wrench and a little elbow grease.<br><br>

	Step two: Hook it up to desired output by dragging onto desired output, this can be a fluid canister or a ChemiCompiler.<br><br>

	Step three: Use a Multitool on the ACD to configure settings and set your desired element, it can create any chemical the normal ChemDispenser can.<br>
	<b>Make sure it is actually spelled properly.</b><br><br>

	Step four: Use a Multitool to connect an input device to the Start component of the ACD. <br><br>


	If attached to a ChemiCompile you need to set the reservoir number to output to with the Multitool:<br><br>

	Now go make chemicals to your heart's content, just try not to get into any trouble.<br>

	"}
