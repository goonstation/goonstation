#define GEN_ANODE 1
#define GEN_CATHODE 2

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
	icon_state = "roditem-100"
	item_state = "rods"
	///Rod condition: decays over time, combines with generation efficacy to yield a production rate
	var/condition = 100
	///Generation efficacy for anode use. Influenced by material properties
	var/anode_efficacy = 0
	///Generation efficacy for cathode use. Influenced by material properties
	var/cathode_efficacy = 0
	///Decay ratio: how fast rod will fall apart. Influenced by material corrosion resistance
	var/decay_ratio = 0.999

	anode_default
		name = "catalytic anode rod"
		desc = "Rod of material extruded in a suitable form for catalytic electrical generation. It's stamped on one end with an indicative symbol."
		New()
			var/datum/material/M = getMaterial("copper")
			src.setMaterial(M)
			..()

	cathode_default
		name = "catalytic cathode rod"
		desc = "Rod of material extruded in a suitable form for catalytic electrical generation. It's stamped on one end with an indicative symbol."
		New()
			var/datum/material/M = getMaterial("mauxite")
			src.setMaterial(M)
			..()

	New() //you should only be able to make these from things with a metal material flag
		///This is usually 35, meaning 0.99935 net decay ratio (60% after ~13m, 40% after ~24m). Total corrosion immunity = no decay.
		..()
		var/decay_ratio_adjustment = src.material.getProperty("corrosion") * 0.00001
		src.decay_ratio = src.decay_ratio + decay_ratio_adjustment
		src.anode_efficacy = 150 - (abs(75-src.material.getProperty("electrical")) * 2)
		if(src.material.material_flags & MATERIAL_ENERGY && src.anode_efficacy)
			src.anode_efficacy = src.anode_efficacy * 1.2
		src.cathode_efficacy = 150 - (abs(75-src.material.getProperty("density")) * 2) + min(src.material.getProperty("stability")-50,0)

	///Consumes rod condition in furtherance of electrical generation; pass anode or cathode use for appropriate effectiveness factor
	proc/expend_rod(var/expend_type)
		. = FALSE //If rod is so ineffective in role as to yield no generation whatsoever, generator should abort operation
		switch(expend_type)
			if(GEN_ANODE)
				. = round(src.condition * src.anode_efficacy * 100000)
				src.condition = src.condition * ROD_DECAY_RATIO
			if(GEN_CATHODE)
				. = round(src.condition * src.cathode_efficacy * 100000)
				src.condition = src.condition * ROD_DECAY_RATIO
		return

	update_icon()
		..()
		var/ratio = min(round(condition, 20)+20,100)
		src.icon_state = "roditem-[ratio]"


#undef GEN_ANODE
#undef GEN_CATHODE
