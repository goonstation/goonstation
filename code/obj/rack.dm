/obj/rack
	name = "rack"
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack_base"
	density = 1
	layer = STORAGE_LAYER
	flags = NOSPLASH
	anchored = ANCHORED
	desc = "A metal frame used to hold objects. Can be wrenched and made portable."
	event_handler_flags = USE_FLUID_ENTER
	mechanics_interaction = MECHANICS_INTERACTION_SKIP_IF_FAIL
	material_amt = 0.1

	proc/rackbreak()
		src.icon_state = initial(src.icon_state) + "-broken"
		src.set_density(0)

/obj/rack/New()
	..()
	var/bonus = 0
	for (var/obj/O in loc)
		if (isitem(O))
			bonus += 4
		if (istype(O, /obj/table))
			return
		if (istype(O, /obj/rack) && O != src)
			return
	var/area/Ar = get_area(src)
	if (Ar)
		Ar.sims_score = min(Ar.sims_score + bonus, 100)

/obj/rack/ex_act(severity)
	switch(severity)
		if(1)
			//src.deconstruct()
			qdel(src)
			return
		if(2)
			if (prob(50))
				src.deconstruct()
				return
		if(3)
			if (prob(25))
				rackbreak()

/obj/rack/blob_act(var/power)
	if(prob(power * 2.5))
		src.deconstruct()
		return
	else if(prob(power * 2.5))
		rackbreak()
		return

/obj/rack/Cross(atom/movable/mover)
	if (mover.flags & TABLEPASS)
		return 1
	else
		return 0

/obj/rack/MouseDrop_T(obj/O as obj, mob/user as mob)
	if (!isitem(O) || !in_interact_range(user, src) || !in_interact_range(user, O) || user.restrained() || user.getStatusDuration("unconscious") || user.sleeping || user.stat || user.lying)
		return
	var/obj/item/I = O
	if (istype(I,/obj/item/satchel))
		var/obj/item/satchel/S = I
		if (length(S.contents) < 1)
			boutput(user, SPAN_ALERT("There's nothing in [S]!"))
		else
			user.visible_message(SPAN_NOTICE("[user] dumps out [S]'s contents onto [src]!"))
			for (var/obj/item/thing in S.contents)
				thing.set_loc(src.loc)
			S.tooltip_rebuild = TRUE
			S.UpdateIcon()
			return
	if (isrobot(user) || user.equipped() != I || (I.cant_drop || I.cant_self_remove))
		return
	user.drop_item()
	if (I.loc != src.loc)
		step(I, get_dir(I, src))
	return

/obj/rack/disposing()
	var/turf/OL = get_turf(src)
	if (!OL)
		return
	if (!(locate(/obj/table) in OL) && !(locate(/obj/rack) in OL))
		var/area/Ar = OL.loc
		for (var/obj/item/I in OL)
			Ar.sims_score -= 4
		Ar.sims_score = max(Ar.sims_score, 0)
	..()

/obj/rack/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		actions.start(new /datum/action/bar/icon/rack_tool_interact(src, W), user)
	else
		src.place_on(W, user)
	return

/obj/rack/proc/deconstruct()
	var/obj/item/furniture_parts/P = new /obj/item/furniture_parts/rack(src.loc)
	if (P && src.material)
		P.setMaterial(src.material)
	qdel(src)

/obj/rack/meteorhit(obj/O as obj)
	if(prob(75))
		qdel(src)
		return
	else
		rackbreak()
	return

/datum/action/bar/icon/rack_tool_interact
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 50
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/rack/the_rack
	var/obj/item/the_tool

	New(var/obj/rack/rak, var/obj/item/tool, var/duration_i)
		..()
		if (rak)
			the_rack = rak
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (the_rack == null || the_tool == null || owner == null || BOUNDS_DIST(owner, the_rack) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(the_rack, 'sound/items/Ratchet.ogg', 50, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] begins disassembling [the_rack]."))

	onEnd()
		..()
		playsound(the_rack, 'sound/items/Deconstruct.ogg', 50, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] disassembles [the_rack]."))
		the_rack.deconstruct()

#define RACK_SPAWN_DIAGONAL_PROBABILITY 10

/// Map-spawn helper for regularly stacked rack items
/obj/rack/organized
	var/initialized = FALSE //! Have we spawned our items yet
	var/list/obj/item/items_to_spawn = list() //! What items are we going to spawn
	var/order_override = "" //! Force a specific organization layout
	var/shuffle_chance = 1 //! Probability of the card order being shuffled
#ifdef IN_MAP_EDITOR
	icon = 'icons/obj/item_spawn.dmi'
	icon_state = "rack_filled"
#endif

/obj/rack/organized/New()
	if (!src.initialized)
		if (prob(shuffle_chance))
			shuffle_list(src.items_to_spawn)
		switch(src.order_override)
			if("zigzag")
				src.zigzag()
			if("diagonal")
				src.diagonal()
			else
				if (prob(RACK_SPAWN_DIAGONAL_PROBABILITY))
					src.diagonal()
				else
					src.zigzag()
		src.initialized = TRUE
	. = ..() // spawn items before calculating sims_score

#undef RACK_SPAWN_DIAGONAL_PROBABILITY

#define RACK_ZIGZAG_TOP 7
#define RACK_ZIGZAG_CENTER_OFFSET 5
#define RACK_ZIGZAG_VERTICAL_OFFSET 2

/// Lay out items in a zig-zag pattern
/obj/rack/organized/proc/zigzag()
	var/move_y = RACK_ZIGZAG_TOP
	var/left_side = FALSE // start on upper right
	for(var/item in src.items_to_spawn)
		var/obj/item/I = new item(get_turf(src))
		I.pixel_y = move_y
		I.pixel_x = left_side ? -RACK_ZIGZAG_CENTER_OFFSET : RACK_ZIGZAG_CENTER_OFFSET
		move_y = move_y - RACK_ZIGZAG_VERTICAL_OFFSET // zig
		left_side = !left_side // zag

#undef RACK_ZIGZAG_TOP
#undef RACK_ZIGZAG_CENTER_OFFSET
#undef RACK_ZIGZAG_VERTICAL_OFFSET

#define RACK_DIAGONAL_TOP 9
#define RACK_DIAGONAL_OFFSET 3

/// Lay out items from top left to bottom right
/obj/rack/organized/proc/diagonal()
	var/move_xy = RACK_DIAGONAL_TOP
	for(var/item in src.items_to_spawn)
		var/obj/item/I = new item(get_turf(src))
		I.pixel_y = move_xy
		I.pixel_x = -move_xy
		move_xy = move_xy - RACK_DIAGONAL_OFFSET

#undef RACK_DIAGONAL_TOP
#undef RACK_DIAGONAL_OFFSET

/// Technical Storage circuit board rack for engineering/supply
/obj/rack/organized/techstorage_eng
	items_to_spawn = list(
		/obj/item/circuitboard/arcade,
		/obj/item/circuitboard/qmorder,
		/obj/item/circuitboard/qmsupply,
		/obj/item/circuitboard/barcode,
		/obj/item/circuitboard/barcode_qm,
		/obj/item/circuitboard/telescope,
		/obj/item/circuitboard/powermonitor,
		/obj/item/circuitboard/powermonitor_smes,
	)

/// Includes the transception array board, for maps with transception cargo fulfillment
/obj/rack/organized/techstorage_eng/transception
	New()
		src.items_to_spawn += /obj/item/circuitboard/transception
		. = ..()

/// Technical Storage circuit board rack for medical/science/misc
/obj/rack/organized/techstorage_med
	items_to_spawn = list(
		/obj/item/circuitboard/card,
		/obj/item/circuitboard/teleporter,
		/obj/item/circuitboard/operating,
		/obj/item/circuitboard/cloning,
		/obj/item/circuitboard/genetics,
		/obj/item/circuitboard/robot_module_rewriter,
		/obj/item/circuitboard/chem_request,
		/obj/item/circuitboard/chem_request_receiver,
	)

/obj/rack/organized/techstorage_med/sea
	New()
		src.items_to_spawn += /obj/item/circuitboard/sea_elevator
		. = ..()
