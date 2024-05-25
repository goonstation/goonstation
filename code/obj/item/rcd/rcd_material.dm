/*
	Material specific RCD variants
*/
/obj/item/rcd/material
	///Material the RCD will build specifically windows out of (if left null, defaults to the same material as the structure)
	var/window_material = null

	do_build_window(atom/A, mob/user)
		// Is /auto always the one to use here? hm. //yes, yes it should be
		var/obj/window/auto/T = new (get_turf(A))
		log_construction(user, "builds a window")
		if(window_material)
			T.setMaterial(getMaterial(window_material))
		else
			T.setMaterial(getMaterial(material_name))
		return

TYPEINFO(/obj/item/rcd/material/cardboard)
	mats = list("crystal_dense" = 10,
				"energy_high" = 10,
				"cardboard" = 30)
/obj/item/rcd/material/cardboard
	name = "cardboard rapid construction Device"
	icon_state = "base_cardboard"
	desc = "Also known as a C-RCD, this device is able to rapidly construct cardboard props."
	force = 0
	matter_create_floor = 0.5
	time_create_floor = 0 SECONDS

	matter_create_wall = 3
	time_create_wall = 5 SECONDS

	matter_reinforce_wall = 2.5
	time_reinforce_wall = 5 SECONDS

	matter_create_wall_girder = 2
	time_create_wall_girder = 2 SECONDS

	matter_create_door = 4
	time_create_door = 5 SECONDS

	matter_create_window = 2
	time_create_window = 2 SECONDS

	matter_remove_door = -2
	time_remove_door = 5 SECONDS

	matter_remove_floor = 0
	time_remove_floor = 5 SECONDS

	matter_remove_lattice = 0
	time_remove_lattice = 5 SECONDS

	matter_remove_wall = -1
	time_remove_wall = 5 SECONDS

	matter_unreinforce_wall = -1
	time_unreinforce_wall = 5 SECONDS

	matter_remove_girder = -1
	time_remove_girder = 2 SECONDS

	matter_remove_window = -1
	time_remove_window = 5 SECONDS


	unsafe = FALSE

	material_name = "cardboard"
	restricted_materials = list("cardboard")
	safe_deconstruct = TRUE

	modes = list(RCD_MODE_FLOORSWALLS, RCD_MODE_AIRLOCK, RCD_MODE_DECONSTRUCT, RCD_MODE_WINDOWS)


	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/rcd_ammo))
			..()
		else if (isExploitableObject(W))
			boutput(user, "Recycling [W] just doesn't work.")
		else if (istype(W, /obj/item/paper/book))
			matter += 5
			boutput(user, "\The [src] recycles [W], and now holds [src.matter]/[src.max_matter] [material_name]-units.")
			qdel(W)
		else if (istype(W, /obj/item/paper))
			matter += 0.5
			boutput(user, "\The [src] recycles [W], and now holds [src.matter]/[src.max_matter] [material_name]-units.")
			qdel(W)
		else if (istype(W, /obj/item/paper_booklet))
			var/obj/item/paper_booklet/booklet = W
			matter += booklet.pages.len/2
			boutput(user, "\The [src] recycles [W], and now holds [src.matter]/[src.max_matter] [material_name]-units.")
			qdel(W)
		else if (W?.material?.getID() == "wood")
			matter += 20
			boutput(user, "\The [src] pulps [W], and now holds [src.matter]/[src.max_matter] [material_name]-units.")
			qdel(W)

	do_build_airlock(var/turf/A, mob/user)
		var/door_dir = user.dir
		var/obj/machinery/door/unpowered/wood/T = new (A)
		T.set_dir(door_dir)
		T.setMaterial(getMaterial(material_name))
		log_construction(user, null, "builds a door ([T]")


/obj/item/rcd/material/viscerite
	name = "biomimetic rapid construction device"
	desc = "Have you ever wanted to build with meat? No? Too bad."
	force = 0
	unsafe = FALSE

	material_name = "viscerite"
	window_material = "tensed_viscerite"
	restricted_materials = list("viscerite","tensed_viscerite")
	safe_deconstruct = TRUE

	matter_create_wall = 3
	matter_reinforce_wall = 3
	matter_create_wall_girder = 2
	matter_create_window = 2
	matter_remove_floor = 0
	matter_remove_lattice = 0
	matter_remove_wall = -1
	matter_unreinforce_wall = -1
	matter_remove_girder = -1
	matter_remove_window = -1

	modes = list(RCD_MODE_FLOORSWALLS, RCD_MODE_DECONSTRUCT, RCD_MODE_WINDOWS)

	/// Load the RCD from a stack of items at an (optional) fill ratio
	proc/reload_from_stack(obj/item/stack, mob/user, fill_ratio = 1)
		var/amount_needed = ceil((src.max_matter - src.matter) / fill_ratio)
		var/partial_eat = FALSE
		if(amount_needed == 0)
			boutput(user, "\The [src] is full.")
			return
		if(stack.amount > amount_needed)
			stack.change_stack_amount(-amount_needed)
			src.matter = src.max_matter
			partial_eat = TRUE
		else
			src.matter += round(stack.amount * fill_ratio)
			qdel(stack)
		boutput(user, "\The [src] [partial_eat ? "partially " : null]absorbs \the [stack.name] into its internal buffer, and now holds [src.matter]/[src.max_matter] [material_name]-units.")
		src.UpdateIcon()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/rcd_ammo))
			..()
		else if (istype(W, /obj/item/sheet)) //allow selective direct recycle (prices have been adjusted)
			var/sheet_mat_id = W.material.getID()
			if(sheet_mat_id == "viscerite" || sheet_mat_id == "tensed_viscerite")
				src.reload_from_stack(W, user)
		else if (isExploitableObject(W))
			boutput(user, "Recycling [W] just doesn't work.")
		else if (istype(W, /obj/item/raw_material/martian))
			src.reload_from_stack(W, user, 10)
		else if (istype(W, /obj/item/material_piece/viscerite))
			src.reload_from_stack(W, user, 10)
		else if (istype(W, /obj/item/reagent_containers/food/snacks/yuck))
			matter += 0.5
			boutput(user, "\The [src] absorbs [W] into its internal buffer, and now holds [src.matter]/[src.max_matter] [material_name]-units.")
			qdel(W)
			src.UpdateIcon()
