
/* ==================================================== */
/* -------------------- Fuel Tanks -------------------- */
/* ==================================================== */

// Why is this a drinking bottle now? Well, I want the same set of functionality (drag & drop, transference)
// without the C&P code a separate obj class would require. You can't use drinking bottles in beaker
// assemblies and the like in case you're worried about the availability of 400 units beakers (Convair880).
/obj/item/reagent_containers/food/drinks/fueltank
	name = "fuel tank"
	desc = "A specialized anti-static tank for holding flammable compounds"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bottlefuel"
	w_class = W_CLASS_NORMAL
	amount_per_transfer_from_this = 25
	incompatible_with_chem_dispensers = 1
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	rc_flags = RC_SCALE
	initial_volume = 400
	can_recycle = FALSE
	can_chug = 0
	initial_reagents = "fuel"
	rc_flags = RC_SPECTRO

/obj/item/reagent_containers/food/drinks/fueltank/empty
	initial_reagents = null

/obj/item/reagent_containers/food/drinks/fueltank/napalm
	initial_reagents = "napalm_goo"

/obj/item/reagent_containers/food/drinks/fueltank/chlorine // high capacity pool chlorine container! will probably do something later ~Warc
	initial_reagents = "chlorine"
	icon_state = "bottlecl"
	name = "Pool Chlorine"
