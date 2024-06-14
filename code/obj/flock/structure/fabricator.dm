/obj/flock_structure/fabricator
	icon_state = "reclaimer" // placeholder
	name = "angled pedestal"
	desc = "A strange machine. It appears to have some sort of output slot?"
	flock_desc = "A converter that turns its contents into resource cubes."
	tutorial_desc = "A converter that turns its contents into resource cubes. Created by converting a human resource container (vending machine, fluid tank, etc.)."
	flock_id = "Fabricator"
	health = 20
	health_max = 20
	repair_per_resource = 1
	passthrough = TRUE
	show_in_tutorial = TRUE

	var/resources_to_produce = 0

	New(atom/location, datum/flock/F = null, obj/content_holder)
		..()
		if (istype(content_holder, /obj/machinery/vending))
			var/obj/machinery/vending/vending_machine = content_holder
			for (var/datum/data/vending_product/product as anything in vending_machine.product_list)
				src.resources_to_produce += get_initial_item_health(product.product_path) * product.product_amount
		else if (istype(content_holder, /obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/fab = content_holder
			if (length(fab.free_resources) > 0)
				for (var/obj/item/material_piece/mat_type as anything in fab.free_resources)
					src.resources_to_produce += get_initial_item_health(mat_type) * fab.free_resources[mat_type]
			else
				for (var/obj/item/material_piece/mat in fab.contents)
					src.resources_to_produce += get_initial_item_health(mat) * mat.amount
			src.resources_to_produce += round(fab.reagents.total_volume / 40)
		else if (istype(content_holder, /obj/submachine/seed_vendor))
			src.resources_to_produce += 100
		else if (istype(content_holder, /obj/machinery/dispenser))
			var/obj/machinery/dispenser/tank_holder = content_holder
			src.resources_to_produce += tank_holder.o2tanks * get_initial_item_health(/obj/item/tank/oxygen) + tank_holder.pltanks * get_initial_item_health(/obj/item/tank/plasma)
		else if (istype(content_holder, /obj/machinery/disposal_pipedispenser))
			src.resources_to_produce += 100
		else if (istype(content_holder, /obj/machinery/chem_dispenser) || istype(content_holder, /obj/machinery/chemicompiler_stationary))
			src.resources_to_produce += 100
		else if (istype(content_holder, /obj/reagent_dispensers))
			var/obj/reagent_dispensers/reagent_holder = content_holder
			src.resources_to_produce += round(reagent_holder.reagents.total_volume / 40) // welding fuel dispenser has 4000u of fuel, for 100 resources

		src.info_tag.set_info_tag("Resources left: [src.resources_to_produce]")

		if (!src.resources_to_produce)
			SPAWN(0.1 SECONDS)
				if (src)
					flock_speak(src, "ALERT: No resources available to produce.", src.flock)
					src.icon_state = "reclaimer-off" // placeholder
		else
			ON_COOLDOWN(src, "resource_production", 10 SECONDS)

	building_specific_info()
		return "[SPAN_BOLD("Resources left to produce:")] [src.resources_to_produce]."

	process(mult)
		if (!src.resources_to_produce)
			return
		if (ON_COOLDOWN(src, "resource_production", 10 SECONDS))
			return

		var/obj/item/flockcache/resource_cube = new(get_turf(src))
		resource_cube.resources = min(src.resources_to_produce, round(25 * mult))
		playsound(src, 'sound/effects/crackle3.ogg', 40, TRUE, -10) // placeholder
		src.resources_to_produce -= resource_cube.resources

		src.info_tag.set_info_tag("Resources left: [src.resources_to_produce]")

		if (!src.resources_to_produce)
			flock_speak(src, "ALERT: No resources left to produce", src.flock)
			src.icon_state = "reclaimer-off" // placeholder

	gib(atom/location)
		if (src.resources_to_produce)
			var/gnesis_amount = round(src.resources_to_produce / 4)
			if (gnesis_amount)
				src.create_reagents(gnesis_amount)
				src.reagents.add_reagent("flockdrone_fluid", gnesis_amount)
				src.reagents.trans_to(get_turf(src), gnesis_amount)
		..()
