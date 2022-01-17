/obj/decal/fakeobjects/catalytic_doodad
	name = "catalytic generator pipe"
	desc = "Pipe section allowing a catalytic rod to contact outside fluid for catalysis."
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "doodad"
	anchored = 1

/obj/machinery/power/catalytic_generator
	name = "catalytic generator core"
	desc = "Harnesses catalysts' reactions with a large body of appropriate fluid to generate electricity."
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "core"

/obj/machinery/catalytic_rod_unit
	name = "catalytic rod unit"
	desc = "Accepts a rod of catalytic material for use in electricity generation."
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "nonvis"
	density = 1
	///Directionality to be given to overlays; should be 4 for right unit and 8 for left
	var/overlay_dir = 1
	///Possible modes: open (rod clamp exposed and load/unloadable), inactive (clamp squared away, whether a rod is inserted or not), active (active)
	var/mode = "inactive"
	///True while toggling between modes
	var/toggling = FALSE
	///Rod contained within the rod unit
	var/obj/item/contained_rod
	///Rod material class requirement; defining this is an optional part of rod parameters
	var/rodmat_class
	///Rod material qualitative parameters; the closer a rod is to these parameters, the more effectively it will operate
	var/list/rodmat_parameters

	right
		name = "Catalytic Anode Unit"
		icon_state = "base-r"
		overlay_dir = 8
		contained_rod = new /obj/item/catalytic_rod/anode_default()

	left
		name = "Catalytic Cathode Unit"
		icon_state = "base-l"
		overlay_dir = 4
		contained_rod = new /obj/item/catalytic_rod/cathode_default()


/obj/item/catalytic_rod
	name = "catalytic rod"
	desc = "Rod of material extruded in a suitable form for catalytic electrical generation. Hopefully it's good for that."
	icon = 'icons/obj/machines/catalysis.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "roditem"
	item_state = "rods"

	anode_default
		name = "catalytic anode rod"
		desc = "Rod of material extruded in a suitable form for catalytic electrical generation. It's stamped deeply with an indicative symbol."
		New()
			..()
			var/datum/material/M = getMaterial("mauxite")
			src.setMaterial(M)

	cathode_default
		name = "catalytic cathode rod"
		desc = "Rod of material extruded in a suitable form for catalytic electrical generation. It's stamped deeply with an indicative symbol."
		New()
			..()
			var/datum/material/M = getMaterial("copper")
			src.setMaterial(M)
