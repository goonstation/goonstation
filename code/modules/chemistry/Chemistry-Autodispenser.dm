/obj/machinery/autochem

	name = "Automatic ChemDispenser"
	desc = "Like the ChemDispenser, but controlable with components"
	density = 1
	anchored = UNANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenserautoidle"
	//Connected Chemi compiler
	var/obj/machinery/chemicompiler_stationary/connected_CC = null
	var/selected_element = null
	var/selected_reservoir = 1
	var/active = FALSE

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
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "Dispense", .proc/dispense)
		selected_element = "aluminium" //to make it not pour null


	proc/setelement(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Select an element to dispense:", "Element", null) as text | null
		if(!input)
			boutput(user, "That is not a valid chemical.")
			return
		if(lowertext(input) == "aluminum") //Anti-Bri'ish
			selected_element = "aluminium"
			boutput(user, "Selected chemical set to [selected_element]")
		if(!dispensable_reagents.Find(input))
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

	attackby(obj/item/W, mob/user)
		if(!iswrenchingtool(W))
			..()
			return
		if(src.anchored)
			src.anchored = UNANCHORED
			src.icon_state = "dispenserautoidle"
			boutput(user, "<span class='notice'>You unanchor the [name] from the floor.</span>")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		else
			src.anchored = ANCHORED
			src.icon_state = "dispenserauto"
			boutput(user, "<span class='notice'>You anchor the [name] to the floor.</span>")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)

	proc/dispense(var/datum/mechanicsMessage/input)
		if (status & (NOPOWER|BROKEN))
			return
		var/amount = clamp(round(text2num(input.signal)), 1, 100)
		if (!connected_CC)
			return
		if (connected_CC.executor)
			var/obj/item/B = connected_CC.executor.reservoirs[selected_reservoir]
			if(B && B.reagents)
				playsound(src.loc, dispense_sound, 50, 1, 0.3)
				B.reagents.add_reagent(selected_element, amount)
				B.reagents.handle_reactions()
				use_power(amount)




/obj/item/paper/autochem
	name = "AutoChem Dispenser setup guide"
	info = {"
	---------------------------<br>
	Guide to setting up your new Automatic Chemical Dispenser<br>
	---------------------------<br><br>
	Ever wanted to make a large amount of chemicals, but didn't like pressing that gosh-darned button on your chemical dispenser so much?<br><br>
	Ever wanted to make a ChemiCompiler setup that didn't need constant maintinence of filling the reservoirs?<br><br>
	<b>Well this is the product for you!</b><br><br>
	Packed with many little button pushers, this machine will dispense all the chemicals you need without all the work!<br><br><br>

	Step one: Anchor your new ACD to the floor.<br>
	This can be done easily with a wrench and a little elbow grease.<br><br>

	Step two: Hook it up to desired output by dragging onto desired output, this can be a fluid canister or a ChemiCompiler.<br><br>

	Step three: Use a Multitool on the ACD to configure settings and set your desired reagent, it can create any chemical the normal ChemDispenser can.<br>
	<b>Make sure it is actually spelled properly.</b><br><br>

	Step four: Use a Multitool to connect an input device to the Dispense input of the ACD with the reagent amount wanted. <br><br>


	If attached to a ChemiCompile you need to set the reservoir number to output to with the Multitool:<br><br>

	Now go make chemicals to your heart's content, just try not to get into any trouble.<br>

	"}


	//TODO
	//Integrate power functions into this (should just have to copy a bunch of stuff from other machines)
	//Some sort of playsound?
