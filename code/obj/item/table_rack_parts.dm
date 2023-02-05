/*
CONTAINS:
TABLE PARTS(+wood,round,roundwood)
REINFORCED TABLE PARTS(+bar,chemistry)
RACK PARTS
*/

/* -------------------- Furniture Parts-------------------- */
ABSTRACT_TYPE(/obj/item/furniture_parts)
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
	health = 8
	var/furniture_type = /obj/table/auto
	var/furniture_name = "table"
	var/reinforced = 0
	var/build_duration = 50
	var/obj/contained_storage = null // used for desks' drawers atm, if src is deconstructed it'll dump its contents on the ground and be deleted
	var/density_check = TRUE //! Do we want to prevent building on turfs with something dense there?

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
			stack_trace("[user] tries to build a piece of furniture from [identify_object(src)] but its furniture_type is null and it is being deleted.")
			user.u_equip(src)
			qdel(src)
			return

		if (newThing)
			if (src.material)
				newThing.setMaterial(src.material)
			if (user)
				newThing.add_fingerprint(user)
				logTheThing(LOG_STATION, user, "builds \a [newThing] (<b>Material:</b> [newThing.material && newThing.material.mat_id ? "[newThing.material.mat_id]" : "*UNKNOWN*"]) at [log_loc(T)].")
				user.u_equip(src)
		qdel(src)
		return newThing

	proc/deconstruct(var/reinforcement = 0)
		if (src.contained_storage && length(src.contained_storage.contents))
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

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			src.deconstruct(src.reinforced ? 1 : null)
			qdel(src)
		else
			return ..()

	afterattack(atom/target, mob/user)
		if (!isturf(target) || target.density)
			return ..()
		actions.start(new /datum/action/bar/icon/furniture_build(src, src.furniture_name, src.build_duration, target), user)

	attack_self(mob/user as mob)
		actions.start(new /datum/action/bar/icon/furniture_build(src, src.furniture_name, src.build_duration, get_turf(user)), user)

	mouse_drop(atom/movable/target)
		. = ..()
		if (HAS_ATOM_PROPERTY(usr, PROP_MOB_CAN_CONSTRUCT_WITHOUT_HOLDING) && isturf(target))
			actions.start(new /datum/action/bar/icon/furniture_build(src, src.furniture_name, src.build_duration, target), usr)

	disposing()
		if (src.contained_storage && length(src.contained_storage.contents))
			var/turf/T = get_turf(src)
			for (var/atom/movable/A in src.contained_storage)
				A.set_loc(T)
			var/obj/O = src.contained_storage
			src.contained_storage = null
			qdel(O)
		..()

/* ---------- Table Parts ---------- */
#define TABLE_WARNING(user) boutput(user, "<span class='alert'>You can't build a table under yourself! You'll have to build it somewhere adjacent instead.</span>")
/obj/item/furniture_parts/table
	name = "table parts"
	desc = "A collection of parts that can be used to make a table."
	material_amt = 0.2

	afterattack(atom/target, mob/user)
		if (isturf(target) && target == get_turf(user))
			TABLE_WARNING(user)
			return
		else
			return ..()

	attack_self(mob/user)
		TABLE_WARNING(user)

#undef TABLE_WARNING

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

/obj/item/furniture_parts/table/regal
	name = "regal table parts"
	desc = "A collection of parts that can be used to make a regal table."
	icon = 'icons/obj/furniture/table_regal.dmi'
	furniture_type = /obj/table/regal/auto

/obj/item/furniture_parts/table/clothred
	name = "red event table parts"
	desc = "A collection of parts that can be used to make a red event table."
	icon = 'icons/obj/furniture/table_clothred.dmi'
	furniture_type = /obj/table/clothred/auto

/obj/item/furniture_parts/table/neon
	name = "neon table parts"
	desc = "A collection of parts that can be used to make a neon table."
	icon = 'icons/obj/furniture/table_neon.dmi'
	furniture_type = /obj/table/neon/auto

/obj/item/furniture_parts/table/scrap
	name = "scrap table parts"
	desc = "A collection of trash that can be used to make a scrap table."
	icon = 'icons/obj/furniture/table_scrap.dmi'
	furniture_type = /obj/table/scrap/auto

/obj/item/furniture_parts/table/folding
	name = "folded folding table"
	desc = "A collapsed table that can be deployed quickly."
	icon = 'icons/obj/furniture/table_folding.dmi'
	furniture_type = /obj/table/folding
	furniture_name = "folding table"
	build_duration = 15

/obj/item/furniture_parts/table/syndicate
	name = "crimson glass table parts"
	desc = "A collection of parts that can be used to make a table with a sturdy red glass top."
	icon = 'icons/obj/furniture/table_syndicate.dmi'
	furniture_type = /obj/table/syndicate/auto

/obj/item/furniture_parts/table/nanotrasen
	name = "azure glass table parts"
	desc = "A collection of parts that can be used to make a table with a sturdy blue glass top."
	icon = 'icons/obj/furniture/table_nanotrasen.dmi'
	furniture_type = /obj/table/nanotrasen/auto

/* ---------- Glass Table Parts ---------- */
/obj/item/furniture_parts/table/glass
	name = "glass table parts"
	desc = "A collection of parts that can be used to make a glass table."
	icon = 'icons/obj/furniture/table_glass.dmi'
	mat_appearances_to_ignore = list("glass")
	furniture_type = /obj/table/glass/auto
	furniture_name = "glass table"
	density_check = FALSE //FOR NOW
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
	furniture_type = /obj/table/reinforced/industrial/auto

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
	icon_state = "rack_base_parts"
	stamina_damage = 25
	stamina_cost = 22
	stamina_crit_chance = 15
	furniture_type = /obj/rack
	furniture_name = "rack"
	material_amt = 0.1

//bookshelf part construction
	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/plank))
			user.visible_message("[user] starts to reinforce \the [src] with wood.", "You start to reinforce \the [src] with wood.")
			if (!do_after(user, 2 SECONDS))
				return
			user.visible_message("[user] reinforces \the [src] with wood.",  "You reinforce \the [src] with wood.")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			new /obj/item/furniture_parts/bookshelf(get_turf(src))
			qdel(src)
			qdel(W)
		else
			..()

/* ------- Single Table Parts ------- */

/obj/item/furniture_parts/endtable_classic
	name = "vintage endtable parts"
	desc = "A collection of parts that can be used to make a vintage endtable."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "endtableclassic_parts"
	furniture_type = /obj/table/endtable_classic
	furniture_name = "vintage endtable"

/obj/item/furniture_parts/endtable_gothic
	name = "gothic endtable parts"
	desc = "A collection of parts that can be used to make a gothic endtable."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "endtablegothic_parts"
	furniture_type = /obj/table/endtable_gothic
	furniture_name = "gothic endtable"

/obj/item/furniture_parts/podium_wood
	name = "wooden podium parts"
	desc = "A collection of parts that can be used to make a wooden podium."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "podiumwood_parts"
	furniture_type = /obj/table/podium_wood
	furniture_name = "wooden podium"

/obj/item/furniture_parts/podium_wood/nt
	icon_state = "podiumwoodnt_parts"
	furniture_type = /obj/table/podium_wood/nanotrasen

/obj/item/furniture_parts/podium_wood/syndie
	icon_state = "podiumwoodsnd_parts"
	furniture_type = /obj/table/podium_wood/syndicate

/obj/item/furniture_parts/podium_white
	name = "white podium parts"
	desc = "A collection of parts that can be used to make a white podium."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "podiumwhite_parts"
	furniture_type = /obj/table/podium_white
	furniture_name = "wooden podium"

/obj/item/furniture_parts/podium_white/nt
	icon_state = "podiumwhitent_parts"
	furniture_type = /obj/table/podium_white/nanotrasen

/obj/item/furniture_parts/podium_white/syndie
	icon_state = "podiumwhitesnd_parts"
	furniture_type = /obj/table/podium_white/syndicate

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

/obj/item/furniture_parts/stool/bee_bed/double
	name = "double bee bed parts"
	desc = "A pile of cloth and wicker that you can attempt to fumble back into a double bee bed."
	furniture_type = /obj/stool/bee_bed/double
	furniture_name = "double bee bed"

/obj/item/furniture_parts/stool/bar
	name = "bar stool parts"
	desc = "A collection of parts that can be used to make a bar stool."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "bstool_parts"
	furniture_type = /obj/stool/bar
	furniture_name = "bar stool"

/obj/item/furniture_parts/stool/neon
	name = "neon bar stool parts"
	desc = "A collection of parts that can be used to make a neon bar stool."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "neonstool_parts"
	furniture_type = /obj/stool/neon
	furniture_name = "neon bar stool"

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

/obj/item/furniture_parts/wood_chair/regal
	name = "regal chair parts"
	desc = "A collection of parts that can be used to make a regal chair."
	icon_state = "regalchair_parts"
	furniture_type = /obj/stool/chair/wooden/regal

/obj/item/furniture_parts/wood_chair/scrap
	name = "scrap chair parts"
	desc = "A collection of trash that can be used to make a scrap chair."
	icon_state = "scrapchair_parts"
	furniture_type = /obj/stool/chair/wooden/scrap

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

/obj/item/furniture_parts/throne_gold
	name = "golden throne parts"
	desc = "A collection of parts that can be used to make a golden throne."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "thronegold_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/comfy/throne_gold
	furniture_name = "golden throne"

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

/* ---------- Decor Parts ---------- */
/obj/item/furniture_parts/decor/regallamp
	name = "regal lamp parts"
	desc = "A collection of parts that can be used to make a regal lamp."
	icon = 'icons/misc/walp_decor.dmi'
	icon_state = "lamp_regal_parts"
	furniture_type = /obj/decoration/regallamp
	furniture_name = "regal lamp"

/* -------------------- Furniture Actions -------------------- */
/datum/action/bar/icon/furniture_build
	id = "furniture_build"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/furniture_parts/parts //! The parts we're building from
	var/furniture_name = "piece of furniture" //! Displayed name for the thing we're building (for chat)
	var/turf/target_turf = null //! The turf we're trying to build on

	New(var/obj/item/furniture_parts/parts, var/name, var/duration, var/target_turf)
		..()
		src.parts = parts
		src.furniture_name = name
		src.target_turf = target_turf
		if (duration)
			src.duration = duration
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (parts == null || owner == null || BOUNDS_DIST(owner, parts) > 0 || BOUNDS_DIST(owner, target_turf) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		// cirrfix: ghost drones should be able to build furniture now
		if(istype(source) && !HAS_ATOM_PROPERTY(source, PROP_MOB_CAN_CONSTRUCT_WITHOUT_HOLDING))
			if(istype(source.equipped(), /obj/item/magtractor))
				// check to see it's holding the right thing
				var/obj/item/magtractor/M = source.equipped()
				if(parts != M.holding)
					interrupt(INTERRUPT_ALWAYS)
			else if (parts != source.equipped())
				interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (parts.density_check)
			if (length(target_turf.contents) > 50) // chosen fairly arbitrarily; prevent too much iteration. also how the fuck did you even click the turf
				boutput(owner, "<span class='alert'>There's way too much stuff in the way to build there!</span>")

			var/obj/blocker
			for (var/obj/O in target_turf)
				if (O.density)
					blocker = O
					break

			if (blocker)
				boutput(owner, "<span class='alert'>You try to build \a [furniture_name], but there's \a [blocker] in the way!</span>")
				src.resumable = FALSE
				interrupt(INTERRUPT_ALWAYS)
				return
		owner.visible_message("<span class='notice'>[owner] begins constructing \a [furniture_name]!</span>")

	onResume(datum/action/bar/icon/furniture_build/attempted) //guaranteed since we only resume with the same type
		..()
		if (attempted.target_turf != src.target_turf)
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()
		owner.visible_message("<span class='notice'>[owner] constructs \a [furniture_name]!</span>")
		parts.construct(owner, target_turf)

/datum/action/bar/icon/furniture_deconstruct
	id = "furniture_deconstruct"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	duration = 50
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/the_furniture
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			the_furniture = O
			place_to_put_bar = O
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
		if (the_furniture == null || the_tool == null || owner == null || BOUNDS_DIST(owner, the_furniture) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(the_furniture, 'sound/items/Ratchet.ogg', 50, 1)
		owner.visible_message("<span class='notice'>[owner] begins disassembling [the_furniture].</span>")

	onEnd()
		..()
		playsound(the_furniture, 'sound/items/Deconstruct.ogg', 50, 1)
		the_furniture:deconstruct() // yes a colon, bite me
		owner.visible_message("<span class='notice'>[owner] disassembles [the_furniture].</span>")
