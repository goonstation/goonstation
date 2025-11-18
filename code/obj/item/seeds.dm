ADMIN_INTERACT_PROCS(/obj/item/seed, proc/admin_set_mutation)
/obj/item/seed
	name = "plant seed"
	desc = "Plant this in soil to grow something."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "seeds"
	var/seedcolor = "#000000"
	w_class = W_CLASS_TINY
	var/auxillary_datum = null
	var/datum/plant/planttype = null
	var/datum/plantgenes/plantgenes = null
	var/seeddamage = 0 // This is used mostly for infusions. How likely a seed is to be destroyed.
	var/isstrange = 0  // Seeds cannot be gene scanned if they're strange seeds.
	var/generation = 0 // Keeps track of how many times a plant has been bred from the initial seed.
	var/dont_mutate = FALSE //! Do not randomly mutate this seed on plant
	var/charges = 1 // represents how many seeds are in this seed packet
	stamina_damage = 0
	stamina_cost = 0
	rand_pos = 1
	inventory_counter_enabled = 1

	New(var/loc,var/do_color = 1)
		..()
		src.plantgenes = new /datum/plantgenes(src)
		// Set up the base genes. Note we don't need to set up the planttype here - that's because
		// the setup for that is automatically handled during spawning a seed from the vendor or
		// harvesting a plant or what-have-you.
		// Scatter the seed's sprite around a bit so you can make big ol' piles of them.
		if (src.auxillary_datum && !src.planttype)
			src.planttype = HY_get_species_from_path(src.auxillary_datum)
		if (do_color)
			docolor()
		// Colors in the seed packet, if we want to do that. Any seed that doesn't use the
		// standard seed packet sprite shouldn't do this or it'll end up looking stupid.

		if (src.planttype)
			src.name = "[src.planttype.name] seed"
			if (charges > 1) name += " packet"
		if (charges > 1) src.inventory_counter.update_number(src.charges)


	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		// If the crop is just straight up seeds. Don't need reagents, but we do
		// need to pass genes and whatnot along like we did for fruit.
		var/datum/plant/child_planttype = HYPgenerateplanttypecopy(src, origin_plant)
		var/datum/plantgenes/child_genes = src.plantgenes
		var/datum/plantmutation/child_mutation = passed_genes.mutation
		// If the plant is a standard plant, our work here is mostly done
		if (!child_planttype.hybrid && !origin_plant.unique_seed)
			src.generic_seed_setup(child_planttype)
		else
			src.planttype = child_planttype
			src.plant_seed_color(child_planttype.seedcolor)
		//Now we generate the seeds name
		var/seedname = "[child_planttype.name]"
		if(istype(child_mutation,/datum/plantmutation/))
			if(!child_mutation.name_prefix && !child_mutation.name_suffix && child_mutation.name)
				seedname = "[child_mutation.name]"
			else if(child_mutation.name_prefix || child_mutation.name_suffix)
				seedname = "[child_mutation.name_prefix][child_planttype.name][child_mutation.name_suffix]"
		src.name = "[seedname] seed"
		if (charges > 1) src.name += " packet"
		//What's missing is transfering genes and the generation
		HYPpassplantgenes(passed_genes, child_genes)
		src.generation = harvested_plantpot.generation
		//Now the seed it created and we can release it upon the world
		return src


	//kudzumen can analyze seeds via ezamine when close.
	get_desc(dist, mob/user)
		if (dist >= 5)
			return
		if (iskudzuman(user))
			. = scan_plant(src, user, FALSE) // Replaced with global proc (Convair880).
		else
			return HYPphytoscopic_scan(user, src, TRUE)

	proc/docolor() //bleh, used when unpooling
		src.plant_seed_color(src.seedcolor)

	proc/removecolor()
		src.overlays = 0

	disposing()
		planttype = null
		plantgenes = null
		..()

	proc/generic_seed_setup(var/datum/plant/P, var/has_parent = FALSE)
		// This proc is pretty much entirely for regular seeds you find from the vendor
		// or harvest, stuff like artifact seeds generally shouldn't be calling this.
		if (!P)
			qdel(src)
			return
			// Sanity check. If the seed is of a null species it could cause trouble, so we
			// just get rid of the seed and don't do anything else.
		//var/datum/plant/Pl = new P.type(src)
		var/datum/plant/species = HY_get_species_from_path(P.type)
		if (!src.planttype)
			if (!species)
				if (src.auxillary_datum)
					src.planttype = new src.auxillary_datum(src)
				else
					qdel(src)
					return
			else
				src.planttype = species
		if (src.planttype)
			src.name = "[P.name] seed"
			src.plant_seed_color(P.seedcolor)
			// Calls on a variable in the referenced plant datum to get the seed packet's color.
			// Now we look if the baseline plant adds any kind of baseline commuts to the seed.
			// We call this only if the seed has not a parent. In this case, HYPpassplantgenes adds the commuts in question
			if (!has_parent && length(src.planttype.innate_commuts) > 0)
				for (var/commut_to_add in src.planttype.innate_commuts)
					HYPaddCommut(src.plantgenes, commut_to_add)
		else
			src.name = "[src.name] seed"
		if (src.charges > 1) src.name += " packet"


	proc/plant_seed_color(var/colorRef)
		// A small proc which usually takes the color reference from a plant datum and uses
		// it to color in the seed packet so you can recognise the packets at a glance.
		if (!colorRef) return
		if (!src.artifact)
			var/icon/I = new /icon('icons/obj/hydroponics/items_hydroponics.dmi',"seeds-ovl")
			I.Blend(colorRef, ICON_ADD)
			src.overlays += I

	proc/HYPinfusionS(var/reagent,var/obj/submachine/seed_manipulator/M)
		// The proc for when the manipulator is infusing seeds with a reagent. This is sort of a
		// framing proc simply to check if the seed is in good enough condition to withstand the
		// infusion or not - the actual gameplay effects are handled in a different proc:
		// proc/HYPinfusionP, /datums/plants.dm, line 111
		// Note that this continues down the chain and checks the proc for individual plant
		// datums after it's finished executing the base plant datum infusion proc.

		if (!src) return 1 // Error code 1 - seed destroyed/lost
		if (!reagent) return 2 // Error code 2 - reagent not found
		if (!M) return 3 // Error code 3 - we don't know what the fuck went wrong tbh
		src.seeddamage += rand(3,7) // Infusing costs a little bit of the seed's health
		if (src.seeddamage > 99 || !src.planttype || !src.plantgenes)
			M.seeds -= src
			qdel(src)
			return 1
			// Whoops, you did it too often and now the seed broke. Good job doofus!!

		var/datum/plant/P = src.planttype
		//this proc handles all statistics changes of the plant that depends on the chemical used, like phlogs 80-100 damage.
		P.HYPinfusionP(src,reagent)
		if (src.charges > 1) src.charges = floor(src.charges * 0.9) 	// Infusing reduces the number of viable seeds by a value that is
																		// 10% of its current value rounded up, to a minimum of 1.
		else src.charges = 1 // so the reagents don't have to worry about keeping minimum charges
		if (src.seeddamage > 99)
			// "Whoops you destroyed the seed you dumbass".
			M.seeds -= src
			qdel(src)
			return 1 // We'll want to tell the manipulator that so it can inform the user, too.
		else
			src.inventory_counter.update_number(src.charges)
			return 0 // Passes an "Everything went fine" code to the manipulator.

	proc/admin_set_mutation()
		set name = "Mutate"
		var/list/mutations = list()
		for (var/datum/plantmutation/mutation in src.planttype.mutations)
			mutations[mutation.name] = mutation

		var/selected = tgui_input_list(usr, "Pick mutation", "Mutation select", mutations)
		if (!selected)
			return
		src.plantgenes.mutation = mutations[selected]


/obj/item/seed/grass
	name = "grass seed"
	seedcolor = "#CCFF99"
	auxillary_datum = /datum/plant/herb/grass

/obj/item/seed/maneater
	name = "strange seed"
	icon_state = "seeds-maneater"
	auxillary_datum = /datum/plant/maneater

	New()
		..()
		//since there is no way to generate maneater seeds save for syndicate buylist, and there is no proc to call on syndicate items spawned in, we can set up the seed here.
		src.generic_seed_setup(src.planttype, FALSE)

/obj/item/seed/crystal
	name = "crystal seed"
	seedcolor = "#DDFFFF"
	auxillary_datum = /datum/plant/crystal

/obj/item/seed/cannabis
	name = "cannabis seed"
	seedcolor = "#00FF00"
	auxillary_datum = /datum/plant/herb/cannabis

	New()
		. = ..()
		START_TRACKING_CAT(TR_CAT_CANNABIS_OBJ_ITEMS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_CANNABIS_OBJ_ITEMS)
		. = ..()

// weird alien plants

/obj/item/seed/alien
	name = "strange seed"
	icon_state = "seeds-alien"
	isstrange = 1

	New()
		..()
		gen_plant_type()

	proc/gen_plant_type()
		if (src.type == /obj/item/seed/alien)
			// let's make the base seed randomise itself for fun and also for functionality
			switch(rand(1,9))
				if (1) src.planttype = HY_get_species_from_path(/datum/plant/artifact/pukeplant, src)
				if (2) src.planttype = HY_get_species_from_path(/datum/plant/artifact/dripper, src)
				if (3) src.planttype = HY_get_species_from_path(/datum/plant/artifact/rocks, src)
				if (4) src.planttype = HY_get_species_from_path(/datum/plant/artifact/litelotus, src)
				if (5) src.planttype = HY_get_species_from_path(/datum/plant/artifact/peeker, src)
				if (6) src.planttype = HY_get_species_from_path(/datum/plant/artifact/plasma, src)
				if (7) src.planttype = HY_get_species_from_path(/datum/plant/artifact/goldfish, src)
				if (8) src.planttype = HY_get_species_from_path(/datum/plant/artifact/cat, src)
				if (9) src.planttype = HY_get_species_from_path(/datum/plant/artifact/creeper, src)

	HY_set_species(var/datum/plant/species)
		if (species)
			src.planttype = species

/obj/item/seed/alien/pukeplant
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/pukeplant, src)

/obj/item/seed/alien/dripper
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/dripper, src)

/obj/item/seed/alien/rocks
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/rocks, src)

/obj/item/seed/alien/litelotus
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/litelotus, src)

/obj/item/seed/alien/peeker
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/peeker, src)

/obj/item/seed/alien/plasma
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/plasma, src)

/obj/item/seed/alien/goldfish
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/goldfish, src)

/obj/item/seed/alien/cat
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/cat, src)

/obj/item/seed/alien/creeper
	seedcolor = "#CC00FF"
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/creeper, src)
