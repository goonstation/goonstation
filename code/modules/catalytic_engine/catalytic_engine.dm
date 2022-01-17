/obj/decal/fakeobjects/catalytic_doodad
	name = "Catalytic Engine Pipe"
	desc = "Pipe section allowing a catalytic rod to contact outside fluid for catalysis."
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "doodad"
	anchored = 1

/obj/machinery/catalytic_receiver
	name = "Catalytic Rod Unit"
	desc = "Accepts a rod of catalytic material for use in electricity generation."
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "nonvis"
	density = 1

	left
		name = "Catalytic Cathode Unit"
		icon_state = "base-l"

	right
		name = "Catalytic Anode Unit"
		icon_state = "base-r"
