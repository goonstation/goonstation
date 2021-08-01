////////////////////////////////////////////////////////////////////////////////////////////////////
// objects found in sealab
//	-sea decorations
//	-sea plants
//	-trader npcs
//  -trench/oshan cave wall
//	-etc
////////////////////////////////////////////////////////////////////////////////////////////////////


//DECOR
/obj/item/seashell
	name = "seashell"
	icon = 'icons/obj/sealab_objects.dmi'
	desc = "Hey, you remember collecting these things as a kid! Wait - you didn't grow up here!"
	w_class = W_CLASS_TINY
	rand_pos = 1
	var/database_id = null

	New()
		..()
		var/my_seashell = rand(1,14)
		src.icon_state = "shell_[my_seashell]"
		src.database_id = "seashell_[my_seashell]"
		src.create_reagents(10)
		reagents.add_reagent("calcium_carbonate", 10)


//PLANTS
/obj/sea_plant
	name = "sea plant"
	icon = 'icons/obj/sealab_objects.dmi'
	desc = "It's thriving."
	anchored = 1
	density = 0
	layer = EFFECTS_LAYER_UNDER_1
	var/database_id = null
	var/random_color = 1
	var/drop_type = 0
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER | USE_CANPASS

	New()
		..()
		if (src.random_color)
			src.color = random_saturated_hex_color()
		if (!src.pixel_x)
			src.pixel_x = rand(-8,8)
		if (!src.pixel_y)
			src.pixel_y = rand(-8,8)

	attackby(obj/item/W, mob/user)
		if (issnippingtool(W))
			if(drop_type)
				var/obj/item/drop = new drop_type
				drop.set_loc(src.loc)
			src.visible_message("<span class='alert'>[user] cuts down [src].</span>")
			qdel(src)
		..()


//mbc : added dumb layer code to keep perspective intact *most of the time*
/obj/sea_plant/CanPass(atom/A, turf/T)
	if (ismob(A))

		var/mob/M = A

		var/has_fluid_move_gear = 0
		for(var/atom in M.get_equipped_items())
			var/obj/item/I = atom
			if (I.getProperty("negate_fluid_speed_penalty"))
				has_fluid_move_gear = 1
				break

		if (!has_fluid_move_gear)
			if (ishuman(A))
				var/mob/living/carbon/human/H = A
				if (H.mutantrace && H.mutantrace.aquatic)
					has_fluid_move_gear = 1

		if (!has_fluid_move_gear)
			A.setStatus("slowed", 0.5 SECONDS, optional = 4)

		if (get_dir(src,A) & SOUTH || pixel_y > 0) //If we approach from underneath, fudge the layer so the drawing order doesn't break perspective
			src.layer = 3.9
		else
			src.layer = EFFECTS_LAYER_UNDER_1
		return 1
	else if(istype(A,/obj/machinery/vehicle/tank) || istype(A,/mob/living/critter/aquatic/king_crab))
		animate_door_squeeze(src)
		return 1
	//else if (istype(A,/obj/storage))
	//	return 1
	else return 1

/obj/sea_plant/HasExited(atom/movable/A as mob|obj)
	..()
	if (ismob(A))
		if (A.dir & SOUTH) //If mob exiting south, dont break perspective
			src.layer = 3.9
		else
			src.layer = EFFECTS_LAYER_UNDER_1

//TODO : make all plants drop things!
/obj/sea_plant/bulbous
	name = "bulbous coral"
	icon_state = "bulbous"
	database_id = "sea_plant_bluecoral"
	drop_type = /obj/item/material_piece/coral

/obj/sea_plant/branching
	name = "branching coral"
	icon_state = "branching"
	database_id = "sea_plant_branchcoral"
	drop_type = /obj/item/material_piece/coral

/obj/sea_plant/coralfingers
	name = "stylophora coral"
	icon_state = "coralfingers"
	database_id = "sea_plant_fingercoral"
	drop_type = /obj/item/material_piece/coral

/obj/sea_plant/anemone
	name = "sea anemone"
	icon_state = "anemone"
	database_id = "sea_plant_anemone"

/obj/sea_plant/anemone/lit
	name = "glowing sea anemone"
	icon_state = "anemone_lit"
	database_id = "sea_plant_lit_anemone"
	var/datum/light/point/light = 0
	var/init = 0

	disposing()
		light = 0
		..()

	initialize()
		..()
		if (!init)
			init = 1
			var/datum/color/C = new
			C.from_hex(src.color)
			if (!light)
				light = new
				light.attach(src)
			light.set_brightness(1)
			light.set_color(C.r/255, C.g * 0.25/255, C.b * 0.25/255)
			light.set_height(3)
			light.enable()

/obj/sea_plant/kelp
	name = "kelp"
	icon_state = "kelp"
	database_id = "sea_plant_kelp"
	random_color = 0

/obj/sea_plant/seaweed
	name = "seaweed"
	icon_state = "seaweed"
	database_id = "sea_plant_seaweed"
	random_color = 0
	drop_type = /obj/item/reagent_containers/food/snacks/ingredient/seaweed

/obj/sea_plant/tubesponge
	name = "tube sponge"
	icon_state = "tubesponge"
	database_id = "sea_plant_tubesponge"
	drop_type = /obj/item/sponge

/obj/sea_plant/tubesponge/small
	icon_state = "tubesponge_small"
	database_id = "sea_plant_tubesponge-small"

//TURFS
/turf/unsimulated/wall/trench
	name = "trench wall"
	icon_state = "trench-top"
	fullbright = 0

/turf/unsimulated/wall/trench/side
	name = "trench wall"
	icon_state = "trench-side"
	fullbright = 0
