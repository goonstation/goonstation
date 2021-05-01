/obj/item/rod
	name = "rod"
	desc = ""

	var/lowered

// Control rod to slow down fission processes by absorbing more neutrons
/obj/item/rod/control
	name = "control rod"
	desc = "a control rod which can be used to absorb neutrons"

	icon = 'icons/obj/machinery/nuclear.dmi'
	icon_state = "Sing2"

	anchored = 0
	density = 0

	lowered = 0
	var/condition = 100




// We'll say that the better elements that you can use give you more amounts of fuel
// since they basically give you more bang for your buck, if that doesn't make sense
// then fuck you

// should probably make these reagents and make the fuel rod a reagent container but i'll
// do that later

// an empty fuel rod
/obj/item/rod/fuel
	name = "fuel rod"
	desc = "an empty rod"
	anchored = 0
	density = 0

	icon = 'icons/obj/machinery/nuclear.dmi'
	icon_state = "fr"

	lowered = 0
	var/activated = 0

	var/maxAmount = 0
	// empty fuel rod has nothing
	amount = 0

	var/chainReactionPossible = 0

	New()
		..()
		maxAmount = amount

/*****************************************
// uranium
*****************************************/

/obj/item/rod/fuel/uranium
	name = "uranium fuel rod"

	desc = "a rod filled with uranium fuel"

	amount = 10000

	icon_state = "fr3"


// natural uranium, this will come standard, mixture of U238 and U235
// this will need to be enriched to 235 to make a chain
// reaction possible in a reactor
/obj/item/rod/fuel/uranium/natural
	name = "natural uranium fuel rod"


// enriched uranium, mainly U235
// created via isotope seperation
// this is also weapons grade uranium...
/obj/item/rod/fuel/uranium/enriched
	name = "enriched uranium fuel rod"
	chainReactionPossible = 1


// depleted uranium, mainly U238
/obj/item/rod/fuel/uranium/depleted
	name = "depleted uranium fuel rod"

// U239
// is what you get when neutron capture occurs with U238
/obj/item/rod/fuel/uranium/TwoThreeNine
	name = "uranium 239 fuel rod"

	New()
		..()
		src.process()

	process()
		if(prob(0.1))
			if(locate(src.loc))
				new /obj/item/rod/fuel/neptunium/TwoThreeNine(src.loc)
				qdel(src)
		SPAWN_DBG(1 SECOND)
			process()

/*****************************************
// plutonium
*****************************************/

/obj/item/rod/fuel/plutonium
	name = "plutonium fuel rod"

	desc = "a rod filled with plutonium fuel"

	icon_state = "fr1"

// Pu239
// created via decay of Np239 (via beta- )
// this is what nukes are made from (p much)
/obj/item/rod/fuel/plutonium/TwoThreeNine
	name = "plutonium 239 fuel rod"

	desc = "a rod filled with plutonium fuel"

	amount = 15000
	chainReactionPossible = 1

// Pu240
// created by using P239 and the neutron capture process
/obj/item/rod/fuel/plutonium/TwoFourZero
	name = "plutonium 240 fuel rod"

	desc = "a rod filled with plutonium fuel"

	amount = 20000
	chainReactionPossible = 1

// Pu241
// created by using P240 and the neutron capture process
// for shits and giggles we'll say this is the best one to get
/obj/item/rod/fuel/plutonium/TwoFourOne
	name = "plutonium 241 fuel rod"

	desc = "a rod filled with plutonium fuel"

	amount = 50000
	chainReactionPossible = 1

/*****************************************
// neptunium
*****************************************/

// Np239
// created via decay of U239 (via beta- )
/obj/item/rod/fuel/neptunium/TwoThreeNine
	name = "neptunium 239 fuel rod"

	desc = "a rod filled with neptunium fuel"

	icon_state = "fr2"

	New()
		..()
		src.process()

	process()
		if(prob(0.1))
			if(locate(src.loc))
				new /obj/item/rod/fuel/plutonium/TwoThreeNine(src.loc)
				qdel(src)
		SPAWN_DBG(1 SECOND)
			process()
