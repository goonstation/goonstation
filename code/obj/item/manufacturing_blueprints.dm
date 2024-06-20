
/// Manufacturer blueprints can be read by any manufacturer unit to add the referenced object to the unit's production options.
/obj/item/paper/manufacturer_blueprint
	name = "manufacturer blueprint"
	desc = "This is a laminated blueprint covered in specialized instructions. A manufacturing unit could build something from this."
	info = "There's all manner of confusing diagrams and instructions on here. It's meant for a machine to read."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "blueprint"
	item_state = "sheet"
	var/datum/manufacture/blueprint = null
	var/override_name_desc = TRUE //! If non-zero, the name and description of this blueprint will be overriden on New() with standardized values

	New(loc, schematic = null)
		..()
		if(istype(schematic, /datum/manufacture))
			src.blueprint = schematic
		else if (!schematic)
			if (ispath(src.blueprint))
				src.blueprint = get_schematic_from_path(src.blueprint)
			else
				qdel(src)
				return FALSE
		else
			if (istext(schematic))
				src.blueprint = get_schematic_from_name(schematic)
			else if (ispath(schematic))
				src.blueprint = get_schematic_from_path(schematic)
		if (!src.blueprint)
			qdel(src)
			return FALSE
		if(src.override_name_desc)
			src.name = "manufacturer blueprint: [src.blueprint.name]"
			src.desc = "This laminated blueprint could be read by a manufacturing unit to add \the [src.blueprint.name] to its production options."
		src.pixel_x = rand(-4, 4)
		src.pixel_y = rand(-4, 4)
		return TRUE

/obj/item/paper/manufacturer_blueprint/clonepod
	blueprint = /datum/manufacture/mechanics/clonepod

/obj/item/paper/manufacturer_blueprint/clonegrinder
	blueprint = /datum/manufacture/mechanics/clonegrinder

/obj/item/paper/manufacturer_blueprint/clone_scanner
	blueprint = /datum/manufacture/mechanics/clone_scanner

/obj/item/paper/manufacturer_blueprint/loafer
	blueprint = /datum/manufacture/mechanics/loafer

/obj/item/paper/manufacturer_blueprint/lawrack
	blueprint = /datum/manufacture/mechanics/lawrack

/obj/item/paper/manufacturer_blueprint/ai_status_display
	blueprint = /datum/manufacture/mechanics/ai_status_display

/obj/item/paper/manufacturer_blueprint/thrusters
	name = "manufacturer blueprint: Alastor Pattern Thrusters"
	desc = "This blueprint lacks the usual human-readable documentation, and is smudged with traces of charcoal. Huh."
	icon = 'icons/obj/writing.dmi'
	icon_state = "blueprint"
	blueprint = /datum/manufacture/thrusters

/obj/item/paper/manufacturer_blueprint/alastor
	name = "manufacturer blueprint: Alastor Pattern Laser Rifle"
	desc = "This blueprint lacks the usual human-readable documentation, and is smudged with traces of charcoal. Huh."
	icon = 'icons/obj/writing.dmi'
	icon_state = "blueprint"
	blueprint = /datum/manufacture/alastor

/obj/item/paper/manufacturer_blueprint/interdictor_kit
	name = "Interdictor Frame Kit"
	icon = 'icons/obj/writing.dmi'
	icon_state = "interdictor_blueprint"
	blueprint = /datum/manufacture/interdictor_kit

/obj/item/paper/manufacturer_blueprint/interdictor_rod_lambda
	name = "Lambda Phase-Control Rod"
	icon = 'icons/obj/writing.dmi'
	icon_state = "interdictor_blueprint"
	blueprint = /datum/manufacture/interdictor_rod_lambda

/obj/item/paper/manufacturer_blueprint/interdictor_rod_sigma
	name = "Sigma Phase-Control Rod"
	icon = 'icons/obj/writing.dmi'
	icon_state = "interdictor_blueprint"
	blueprint = /datum/manufacture/interdictor_rod_sigma

/obj/item/paper/manufacturer_blueprint/gunbot
	name = "manufacturer blueprint: AP-Class Security Robot"
	desc = "This blueprint seems to detail a very old model of security bot dating back to the 2030s. Hopefully the manufacturers have legacy support."
	blueprint = /datum/manufacture/mechanics/gunbot
	override_name_desc = FALSE

#ifdef ENABLE_ARTEMIS
/obj/machinery/manufacturer/artemis
	name = "Scout Vessel Manufacturer"
	desc = "A manufacturing unit that can produce equipment for scouting vessels."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	accept_blueprints = 0
	available = list(
	/datum/manufacture/nav_sat)
#endif
/******************** Nadir Resonators *******************/

/obj/item/paper/manufacturer_blueprint/resonator_type_ax
	name = "Type-AX Resonator"
	blueprint = /datum/manufacture/resonator_type_ax

/obj/item/paper/manufacturer_blueprint/resonator_type_sm
	name = "Type-SM Resonator"
	blueprint = /datum/manufacture/resonator_type_sm


/// This is a special item that breaks apart into blueprints for the machines needed to build/repair a cloner.
/obj/item/cloner_blueprints_folder
	name = "dirty manila folder"
	desc = "An old manila folder covered in stains. It looks like it'll fall apart at the slightest touch."
	icon = 'icons/obj/writing.dmi'
	icon_state = "folder"
	w_class = W_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 10

	attack_self(mob/user)
		boutput(user, SPAN_ALERT("The folder disintegrates in your hands, and papers scatter out. Shit!"))
		new /obj/item/paper/manufacturer_blueprint/clonepod(get_turf(src))
		new /obj/item/paper/manufacturer_blueprint/clonegrinder(get_turf(src))
		new /obj/item/paper/manufacturer_blueprint/clone_scanner(get_turf(src))
		new /obj/item/paper/hecate(get_turf(src))
		qdel(src)
