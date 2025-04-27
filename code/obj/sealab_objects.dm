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
	anchored = ANCHORED
	density = 0
	layer = EFFECTS_LAYER_UNDER_1
	var/database_id = null
	var/random_color = 1
	var/drop_type = 0
	event_handler_flags = USE_FLUID_ENTER

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
			src.visible_message(SPAN_ALERT("[user] cuts down [src]."))
			qdel(src)
		..()


//mbc : added dumb layer code to keep perspective intact *most of the time*
/obj/sea_plant/Cross(atom/A)
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
				if (H.mutantrace.aquatic)
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

/obj/sea_plant/Uncrossed(atom/movable/A as mob|obj)
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


//NADIR DOODADS (indev)
//stony and weird "plants" and rocks that you can mine, sometimes yielding resources
/obj/nadir_doodad
	name = "strange thing"
	icon = 'icons/obj/nadir_seaobj.dmi'
	desc = "Is it a plant? A rock? Probably a rock plant."
	anchored = ANCHORED
	density = 1
	var/random_color = TRUE
	var/luminant = FALSE //automatically propagates a light overlay based on icon state name
	var/image/luminant_img
	//var/datum/light/point/light = null
	var/init = 0

	var/drop_table = list() //table of drops and their probabilities of appearing
	var/dig_hp = 7 //how much mining power needs to go into breaking it apart

	New()
		..()
		src.dir = pick(cardinal)
		if (src.random_color)
			src.color = rgb(rand(90,255), rand(90, 255), 255)
	/*
	disposing()
		light = 0
		..()
	*/
	initialize()
		..()
		if (luminant && !init)
			init = 1
			/*
			var/datum/color/C = new
			C.from_hex(src.color)
			if (!light)
				light = new
				light.attach(src)
			light.set_brightness(0.4)
			light.set_color(C.r/255, C.g/255, 1)
			light.enable()
			*/
			src.luminant_img = image('icons/obj/nadir_seaobj.dmi', "[src.icon_state]-glow", -1)
			luminant_img.plane = PLANE_LIGHTING
			luminant_img.layer = LIGHTING_LAYER_BASE
			luminant_img.color = src.color
			luminant_img.dir = src.dir
			src.AddOverlays(luminant_img, "luminant_img")

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/mining_tool))
			if(!ON_COOLDOWN(user, "mine_a_doodad", 1.1 SECONDS))
				var/obj/item/mining_tool/mining_tool = W
				var/digstr = mining_tool.get_dig_strength()
				playsound(user.loc, mining_tool.get_mining_sound(), 50, 1)
				src.dig_hp -= digstr
				if(src.dig_hp <= 0)
					src.visible_message(SPAN_ALERT("[src] breaks apart."))
					break_apart()
			else
				return
		..()

	meteorhit()
		break_apart()

	blob_act()
		break_apart()

	bullet_act()
		break_apart()

	proc/break_apart()
		if(length(drop_table))
			for(var/field in drop_table)
				if(prob(drop_table[field]) && ispath(field))
					var/obj/item/drop = new field
					drop.set_loc(src.loc)
		qdel(src)

	Cross(atom/A)
		if (istype(A, /obj/machinery/vehicle)) //handled here to make it so the vehicle never stops in the first place, improving smoothness
			var/obj/machinery/vehicle/vehicle = A
			var/vehicle_power = vehicle.get_move_velocity_magnitude()
			if(vehicle_power > 5)
				vehicle.health -= 1
				vehicle.checkhealth()
				playsound(vehicle.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 35, 1)
				for (var/mob/C in vehicle)
					shake_camera(C, 3, 5)
				break_apart()
				return TRUE
		return ..()

/obj/nadir_doodad/sinkspires
	name = "sinkspire cluster"
	icon_state = "sinkspires"
	desc = "Strange pillars rising from cracks in the ground. They're covered in tiny pores."
	luminant = TRUE
	drop_table = list(
		/obj/item/raw_material/rock = 60,
		/obj/item/raw_material/molitz = 50,
		/obj/item/raw_material/cobryl = 30,
		/obj/item/raw_material/pharosium = 20
	)

/obj/nadir_doodad/bitelung
	name = "bitelung"
	icon_state = "bitelung"
	desc = "A cairn-like organism. It seems to be 'breathing', almost too slowly to detect with the eye."
	drop_table = list(
		/obj/item/raw_material/rock = 100,
		/obj/item/raw_material/rock = 80,
		/obj/item/raw_material/mauxite = 60,
		/obj/item/raw_material/fibrilith = 50
	)

/obj/plasma_coral // so it doesn't generate randomly with the rest of the sea plants
	name = "plasma coral"
	icon = 'icons/obj/sealab_objects.dmi'
	desc = "It's somehow thriving."
	anchored = ANCHORED
	density = 0
	layer = EFFECTS_LAYER_UNDER_1
	var/database_id = null
	var/random_color = 1
	var/drop_type = 0
	event_handler_flags = USE_FLUID_ENTER

	default_material = "plasmacoral"
	uses_default_material_appearance = FALSE


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
			src.visible_message(SPAN_ALERT("[user] cuts down [src]."))
			qdel(src)
		..()


//mbc : added dumb layer code to keep perspective intact *most of the time*
/obj/plasma_coral/Cross(atom/A)
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
				if (H.mutantrace.aquatic)
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

/obj/plasma_coral/Uncrossed(atom/movable/A as mob|obj)
	..()
	if (ismob(A))
		if (A.dir & SOUTH) //If mob exiting south, dont break perspective
			src.layer = 3.9
		else
			src.layer = EFFECTS_LAYER_UNDER_1

/obj/plasma_coral/bulbous
	name = "bulbous plasmacoral"
	icon_state = "plascoral3"
	database_id = "sea_plant_bluecoral"
	drop_type = /obj/item/raw_material/plasmastone

/obj/plasma_coral/branching
	name = "branching plasmacoral"
	icon_state = "plascoral2"
	database_id = "sea_plant_branchcoral"
	drop_type = /obj/item/raw_material/plasmastone

/obj/plasma_coral/coralfingers
	name = "stylophora plasmacoral"
	icon_state = "plascoral1"
	database_id = "sea_plant_fingercoral"
	drop_type = /obj/item/raw_material/plasmastone

//TURFS
/turf/unsimulated/wall/trench
	name = "trench wall"
	icon_state = "trench-top"
	fullbright = 0
	occlude_foreground_parallax_layers = TRUE
	fulltile_foreground_parallax_occlusion_overlay = TRUE

/turf/unsimulated/wall/trench/side
	name = "trench wall"
	icon_state = "trench-side"
	fullbright = 0
	occlude_foreground_parallax_layers = FALSE
