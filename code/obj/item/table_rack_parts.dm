/*
CONTAINS:
TABLE PARTS(+wood,round,roundwood)
REINFORCED TABLE PARTS(+bar,chemistry)
RACK PARTS
*/

/* -------------------- Furniture Parts-------------------- */
/obj/item/furniture_parts
	name = "furniture parts"
	desc = "A collection of parts that can be used to make some kind of furniture."
	icon = 'icons/obj/furniture/table.dmi'
	icon_state = "table_parts"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	flags = FPRINT | TABLEPASS | CONDUCT
	stamina_damage = 35
	stamina_cost = 22
	stamina_crit_chance = 10
	var/furniture_type = /obj/table/auto
	var/furniture_name = "table"
	var/reinforced = 0
	var/build_duration = 50
	var/obj/contained_storage = null // used for desks' drawers atm, if src is deconstructed it'll dump its contents on the ground and be deleted

	New(loc, obj/storage_thing)
		..()
		if (storage_thing)
			src.contained_storage = storage_thing
			src.contained_storage.set_loc(src)
		BLOCK_SETUP(BLOCK_LARGE)

	proc/construct(mob/user as mob, turf/T as turf)
		var/obj/newThing = null

		if (!T)
			T = user ? get_turf(user) : get_turf(src)
			if (!T) // buh??
				return
		if (ispath(src.furniture_type))
			newThing = new src.furniture_type(T, src.contained_storage ? src.contained_storage : null)
		else
			logTheThing("diary", user, null, "tries to build a piece of furniture from [src] ([src.type]) but its furniture_type is null and it is being deleted.", "station")
			user.u_equip(src)
			qdel(src)
			return

		if (newThing)
			if (src.material)
				newThing.setMaterial(src.material)
			if (user)
				newThing.add_fingerprint(user)
				logTheThing("station", user, null, "builds \a [newThing] (<b>Material:</b> [newThing.material && newThing.material.mat_id ? "[newThing.material.mat_id]" : "*UNKNOWN*"]) at [log_loc(T)].")
				user.u_equip(src)
		qdel(src)
		return newThing

	proc/deconstruct(var/reinforcement = 0)
		if (src.contained_storage && src.contained_storage.contents.len)
			var/turf/T = get_turf(src)
			for (var/atom/movable/A in src.contained_storage)
				A.set_loc(T)
			var/obj/O = src.contained_storage
			src.contained_storage = null
			qdel(O)

		var/obj/item/sheet/A = new /obj/item/sheet(get_turf(src))
		if (src.material)
			A.setMaterial(src.material)
			if (reinforcement == 1)
				A.set_reinforcement(src.material)
				// will have to come back to this later
		else
			var/datum/material/M = getMaterial("steel")
			A.setMaterial(M)
			if (reinforcement == 1)
				A.set_reinforcement(M)

	attackby(obj/item/W as obj, mob/user as mob)
		if (iswrenchingtool(W))
			src.deconstruct(src.reinforced ? 1 : null)
			qdel(src)
		else
			return ..()

	attack_self(mob/user as mob)
		actions.start(new /datum/action/bar/icon/furniture_build(src, src.furniture_name, src.build_duration), user)

	disposing()
		if (src.contained_storage && src.contained_storage.contents.len)
			var/turf/T = get_turf(src)
			for (var/atom/movable/A in src.contained_storage)
				A.set_loc(T)
			var/obj/O = src.contained_storage
			src.contained_storage = null
			qdel(O)
		..()

/* ---------- Table Parts ---------- */
/obj/item/furniture_parts/table
	name = "table parts"
	desc = "A collection of parts that can be used to make a table."

/obj/item/furniture_parts/table/desk
	name = "desk parts"
	desc = "A collection of parts that can be used to make a desk."
	icon = 'icons/obj/furniture/table_desk.dmi'
	furniture_type = /obj/table/auto/desk
	furniture_name = "desk"

/obj/item/furniture_parts/table/wood
	name = "wood table parts"
	desc = "A collection of parts that can be used to make a wooden table."
	icon = 'icons/obj/furniture/table_wood.dmi'
	furniture_type = /obj/table/wood/auto
	furniture_name = "wooden table"

/obj/item/furniture_parts/table/wood/round
	name = "round wood table parts"
	desc = "A collection of parts that can be used to make a round wooden table."
	icon = 'icons/obj/furniture/table_wood_round.dmi'
	furniture_type = /obj/table/wood/round/auto

/obj/item/furniture_parts/table/wood/desk
	name = "wood desk parts"
	desc = "A collection of parts that can be used to make a wooden desk."
	icon = 'icons/obj/furniture/table_wood_desk.dmi'
	furniture_type = /obj/table/wood/auto/desk
	furniture_name = "wooden desk"

/obj/item/furniture_parts/table/round
	name = "round table parts"
	desc = "A collection of parts that can be used to make a round table."
	icon = 'icons/obj/furniture/table_round.dmi'
	furniture_type = /obj/table/round/auto

/obj/item/furniture_parts/table/folding
	name = "folded folding table"
	desc = "A collapsed table that can be deployed quickly."
	icon = 'icons/obj/furniture/table_folding.dmi'
	furniture_type = /obj/table/folding
	furniture_name = "folding table"
	build_duration = 15

/* ---------- Glass Table Parts ---------- */
/obj/item/furniture_parts/table/glass
	name = "glass table parts"
	desc = "A collection of parts that can be used to make a glass table."
	icon = 'icons/obj/furniture/table_glass.dmi'
	mat_appearances_to_ignore = list("glass")
	furniture_type = /obj/table/glass/auto
	furniture_name = "glass table"
	var/has_glass = 1
	var/default_material = "glass"

	New()
		..()
		if (!src.material && default_material)
			var/datum/material/M
			M = getMaterial(default_material)
			src.setMaterial(M)

	UpdateName()
		if (!src.has_glass)
			src.name = "glass table frame[name_suffix(null, 1)]"
		else
			src.name = name_prefix(null, 1)
			if (length(src.name)) // name_prefix() returned something so we have some kinda material, probably
				src.name = "[src.reinforced ? "reinforced " : null][src.name]table parts[name_suffix(null, 1)]"
			else
				src.name = "[initial(src.name)][name_suffix(null, 1)]"

/obj/item/furniture_parts/table/glass/frame
	name = "glass table frame"
	desc = "A collection of parts that can be used to make a frame for a glass table. It has no glass, though."
	icon_state = "e_table_parts"
	furniture_type = /obj/table/glass/frame/auto
	furniture_name = "glass table frame"
	has_glass = 0

/obj/item/furniture_parts/table/glass/reinforced
	name = "reinforced glass table parts"
	desc = "A collection of parts that can be used to make a reinforced glass table."
	icon_state = "r_table_parts"
	furniture_type = /obj/table/glass/reinforced/auto
	furniture_name = "reinforced glass table"

/* ---------- Reinforced Table Parts ---------- */
/obj/item/furniture_parts/table/reinforced
	name = "reinforced table parts"
	desc = "A collection of parts that can be used to make a reinforced table."
	icon = 'icons/obj/furniture/table_reinforced.dmi'
	reinforced = 1
	stamina_damage = 40
	stamina_cost = 22
	stamina_crit_chance = 15
	furniture_type = /obj/table/reinforced/auto
	furniture_name = "reinforced table"

/obj/item/furniture_parts/table/reinforced/industrial
	name = "industrial table parts"
	desc = "A collection of parts that can be used to make an industrial looking table."
	icon = 'icons/obj/furniture/table_industrial.dmi'
	furniture_type = /obj/table/round/auto

/obj/item/furniture_parts/table/reinforced/bar
	name = "bar table parts"
	desc = "A collection of parts that can be used to make a bar table."
	icon = 'icons/obj/furniture/table_bar.dmi'
	furniture_type = /obj/table/reinforced/bar/auto
	furniture_name = "bar table"

/obj/item/furniture_parts/table/reinforced/roulette
	name = "roulette table parts"
	desc = "A collection of parts that can be used to make a roulette table."
	icon = 'icons/obj/furniture/table_bar.dmi'
	furniture_type = /obj/table/reinforced/roulette
	furniture_name = "roulette table"

/obj/item/furniture_parts/table/reinforced/chemistry
	name = "chemistry countertop parts"
	desc = "A collection of parts that can be used to make a chemistry table."
	icon = 'icons/obj/furniture/table_chemistry.dmi'
	furniture_type = /obj/table/reinforced/chemistry/auto
	furniture_name = "chemistry countertop"

/* ---------- Rack Parts ---------- */
/obj/item/furniture_parts/rack
	name = "rack parts"
	desc = "A collection of parts that can be used to make a rack."
	icon = 'icons/obj/metal.dmi'
	icon_state = "rack_parts"
	stamina_damage = 25
	stamina_cost = 22
	stamina_crit_chance = 15
	furniture_type = /obj/rack
	furniture_name = "rack"

//bookshelf part construction
	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/plank))
			user.visible_message("[user] starts to reinforce \the [src] with wood.", "You start to reinforce \the [src] with wood.")
			if (!do_after(user, 2 SECONDS))
				return
			user.visible_message("[user] reinforces \the [src] with wood.",  "You reinforce \the [src] with wood.")
			playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
			new /obj/item/furniture_parts/bookshelf(get_turf(src))
			qdel(src)
			qdel(W)
		else
			..()

/* ---------- Stool Parts ---------- */
/obj/item/furniture_parts/stool
	name = "stool parts"
	desc = "A collection of parts that can be used to make a stool."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "stool_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool
	furniture_name = "stool"

/obj/item/furniture_parts/woodenstool
	name = "wooden stool parts"
	desc = "A collection of parts that can be used to make a wooden stool."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "wstool_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/wooden
	furniture_name = "wooden stool"


/obj/item/furniture_parts/stool/bee_bed
	name = "bee bed parts"
	desc = "A collection of parts that can be used to make a bee bed."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "comf_chair_parts-b"	// @TODO new icon, mprobably
	furniture_type = /obj/stool/bee_bed
	furniture_name = "bee bed"

/obj/item/furniture_parts/stool/bar
	name = "bar stool parts"
	desc = "A collection of parts that can be used to make a bar stool."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "bstool_parts"
	furniture_type = /obj/stool/bar
	furniture_name = "bar stool"

/* ---------- Bench Parts ---------- */
/obj/item/furniture_parts/bench
	name = "bench parts"
	desc = "A collection of parts that can be used to make a bench."
	icon = 'icons/obj/furniture/bench.dmi'
	icon_state = "bench_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/bench/auto
	furniture_name = "bench"

/obj/item/furniture_parts/bench/red
	icon = 'icons/obj/furniture/bench_red.dmi'
	furniture_type = /obj/stool/bench/red/auto

/obj/item/furniture_parts/bench/blue
	icon = 'icons/obj/furniture/bench_blue.dmi'
	furniture_type = /obj/stool/bench/blue/auto

/obj/item/furniture_parts/bench/green
	icon = 'icons/obj/furniture/bench_green.dmi'
	furniture_type = /obj/stool/bench/green/auto

/obj/item/furniture_parts/bench/yellow
	icon = 'icons/obj/furniture/bench_yellow.dmi'
	furniture_type = /obj/stool/bench/yellow/auto

/obj/item/furniture_parts/bench/wooden
	name = "wooden bench parts"
	desc = "A collection of parts that can be used to make a wooden bench."
	icon = 'icons/obj/furniture/bench_wood.dmi'
	furniture_type = /obj/stool/bench/wooden/auto

/obj/item/furniture_parts/bench/pew
	name = "pew parts"
	desc = "A collection of parts that can be used to make a pew."
	icon = 'icons/obj/furniture/bench_wood.dmi'
	furniture_type = /obj/stool/chair/pew

/* ---------- Chair Parts ---------- */
/obj/item/furniture_parts/wood_chair
	name = "wooden chair parts"
	desc = "A collection of parts that can be used to make a wooden chair."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "wchair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/wooden
	furniture_name = "wooden chair"

/obj/item/furniture_parts/wheelchair
	name = "wheelchair parts"
	desc = "A collection of parts that can be used to make a wheelchair."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "whchair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/comfy/wheelchair
	furniture_name = "wheelchair"

/obj/item/furniture_parts/barber_chair
	name = "barber chair parts"
	desc = "A collection of parts that can be used to make a barber chair. You know, for cutting hair?"
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "barberchair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/comfy/barber_chair
	furniture_name = "barber chair"

/obj/item/furniture_parts/office_chair
	name = "office chair parts"
	desc = "A collection of parts that can be used to make an office chair."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "ochair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/office
	furniture_name = "office chair"

/obj/item/furniture_parts/office_chair/red
	icon_state = "ochair_parts-r"
	furniture_type = /obj/stool/chair/office/red

/obj/item/furniture_parts/office_chair/green
	icon_state = "ochair_parts-g"
	furniture_type = /obj/stool/chair/office/green

/obj/item/furniture_parts/office_chair/blue
	icon_state = "ochair_parts-b"
	furniture_type = /obj/stool/chair/office/blue

/obj/item/furniture_parts/office_chair/yellow
	icon_state = "ochair_parts-y"
	furniture_type = /obj/stool/chair/office/yellow

/obj/item/furniture_parts/office_chair/purple
	icon_state = "ochair_parts-p"
	furniture_type = /obj/stool/chair/office/purple

/obj/item/furniture_parts/comfy_chair
	name = "comfy chair parts"
	desc = "A collection of parts that can be used to make a comfy chair."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "comf_chair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/comfy
	furniture_name = "comfy chair"

/obj/item/furniture_parts/comfy_chair/blue
	icon_state = "comf_chair_parts-b"
	furniture_type = /obj/stool/chair/comfy/blue

/obj/item/furniture_parts/comfy_chair/red
	icon_state = "comf_chair_parts-r"
	furniture_type = /obj/stool/chair/comfy/red

/obj/item/furniture_parts/comfy_chair/green
	icon_state = "comf_chair_parts-g"
	furniture_type = /obj/stool/chair/comfy/green

/obj/item/furniture_parts/comfy_chair/yellow
	icon_state = "comf_chair_parts-y"
	furniture_type = /obj/stool/chair/comfy/yellow

/obj/item/furniture_parts/comfy_chair/purple
	icon_state = "comf_chair_parts-p"
	furniture_type = /obj/stool/chair/comfy/purple

/* ---------- Bed Parts ---------- */
/obj/item/furniture_parts/bed
	name = "bed parts"
	desc = "A collection of parts that can be used to make a bed."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "bed_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/bed
	furniture_name = "bed"

/obj/item/furniture_parts/bed/roller
	name = "roller bed parts"
	desc = "A collection of parts that can be used to make a roller bed."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "rbed_parts"
	furniture_type = /obj/stool/bed/moveable
	furniture_name = "roller bed"

/* -------------------- Furniture Actions -------------------- */
/datum/action/bar/icon/furniture_build
	id = "furniture_build"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 50
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/furniture_parts/fparts
	var/fname = "piece of furniture"

	New(var/obj/item/furniture_parts/fp, var/fn, var/duration_i)
		..()
		fparts = fp
		fname = fn
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (fparts == null || owner == null || get_dist(owner, fparts) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		// cirrfix: ghost drones should be able to build furniture now
		if(istype(source))
			if(istype(source.equipped(), /obj/item/magtractor))
				// check to see it's holding the right thing
				var/obj/item/magtractor/M = source.equipped()
				if(fparts != M.holding)
					interrupt(INTERRUPT_ALWAYS)
			else if (fparts != source.equipped())
				interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		owner.visible_message("<span class='notice'>[owner] begins constructing \an [fname]!</span>")

	onEnd()
		..()
		owner.visible_message("<span class='notice'>[owner] constructs \an [fname]!</span>")
		fparts.construct(owner)

/datum/action/bar/icon/furniture_deconstruct
	id = "furniture_deconstruct"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 50
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/the_furniture
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			the_furniture = O
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
		if (the_furniture == null || the_tool == null || owner == null || get_dist(owner, the_furniture) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(get_turf(the_furniture), "sound/items/Ratchet.ogg", 50, 1)
		owner.visible_message("<span class='notice'>[owner] begins disassembling [the_furniture].</span>")

	onEnd()
		..()
		playsound(get_turf(the_furniture), "sound/items/Deconstruct.ogg", 50, 1)
		the_furniture:deconstruct() // yes a colon, bite me
		owner.visible_message("<span class='notice'>[owner] disassembles [the_furniture].</span>")
