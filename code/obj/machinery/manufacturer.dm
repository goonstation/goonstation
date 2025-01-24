#define MAX_QUEUE_LENGTH 20 //! maximum amount of blueprints which may be queued for printing
#define MAX_OUTPUT 20 //! maximum amount of items produced for a blueprint at once
#define WIRE_EXTEND 1 //! wire which reveals blueprints in the "hidden" type
#define WIRE_POWER 2 //! wire which can disable machine power
#define WIRE_MALF 3 //! wire which causes machine to malfunction
#define WIRE_SHOCK 4 //! this wire is in the machine specifically to shock curious staff assistants
#define MODE_READY "ready" //! machine is ready to produce more things
#define MODE_WORKING "working" //! machine is making some things
#define MODE_HALT "halt" //! machine had to stop making things or couldnt due to some problem that occured
#define MIN_SPEED 1 //! lowest speed manufacturer can function at
#define DEFAULT_SPEED 3 //! speed which manufacturers run at by default
#define MAX_SPEED 3 //! maximum speed default manufacturers can be set to
#define MAX_SPEED_HACKED 5 //! maximum speed manufacturers which are hacked (WIRE_EXTEND has been pulsed) can be set to
#define MAX_SPEED_DAMAGED 8 //! maximum speed that manufacturers which flip_out() can be set to, randomly.
#define DISMANTLE_NONE 0 //! 0 - Undismantled state. Changed to 1 (DISMANTLE_PLATING_BOLTS) with a wrenching tool, or back to 0 with a wrenching tool too.
#define DISMANTLE_PLATING_BOLTS 1 //! 1 - External plating pryable. Changed to 2 (DISMANTLE_PLATING_SHEETS) with a prying tool, or back to 1 with renforced metal sheets.
#define DISMANTLE_PLATING_SHEETS 2 //! 2 - Internal wiring exposed. Changed to 3 (DISMANTLE_WIRES) with a snipping tool, changed to 2 by adding cabling back.
#define DISMANTLE_WIRES 3 //! 3 - internal mechanism exposed. Using a wrenching tool at this point disassembles it into sheet metal.
#define ALL_BLUEPRINTS (src.available + src.download + src.hidden + src.drive_recipes)
#define ORE_TAX(price) round(max(rockbox_globals.rockbox_client_fee_min,abs(price*rockbox_globals.rockbox_client_fee_pct/100)),0.01)

TYPEINFO(/obj/machinery/manufacturer)
	mats = 20

/obj/machinery/manufacturer
	name = "manufacturing unit"
	desc = "A 3D printer-like machine that can construct items from raw materials."
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "fab-general"
	var/icon_base = "general" //! This is used to make icon state changes cleaner by setting it to "fab-[icon_base]"
	density = TRUE
	anchored = ANCHORED
	power_usage = 200

	/// req_access is used to lock out specific features and not limit deconstruction therefore DECON_NO_ACCESS is required
	req_access = list(access_heads)
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_NO_ACCESS
	flags = NOSPLASH | FLUID_SUBMERGE
	layer = STORAGE_LAYER
	var/health = 100
	var/supplemental_desc = null //! Appended in get_desc() to the base description, to make subtype definitions cleaner
	/// The current status of the machine.
	/// "ready" / MODE_READY - The machine is ready to produce more blueprints.
	/// "working" / MODE_WORKING - The machine is currently producing a blueprint.
	/// "halt" / MODE_HALT - The machine stopped due to some problem arising.
	var/mode = MODE_READY
	/// A somewhat legacy variable to output silent yet visible errors to the user in the UI.
	/// Current uses include when there is a lack of materials, an invalid blueprint, and when there is not enough manudrive uses.
	var/error = null
	// If this is 0, then the machine is no longer electrified. Use src.is_electrified() to check if the machine is electrified.
	/// This is a timer decremented every process() tick representing how long the machine will be electrified for.
	var/time_left_electrified = 0
	var/active_power_consumption = 0 //! How much power is consumed while active? This is determined automatically when the unit starts a production cycle
	var/panel_open = FALSE //! Whether or not the wiring panel is open for the UI.
	var/dismantle_stage = DISMANTLE_NONE //! The dismantlement stage we are currently at. See manufacturer.dm line 15 for details on the defines
	var/hacked = FALSE //! Whether or not we are hacked, and thus will show our hidden blueprints + change our maximum speed setting.
	var/malfunction = FALSE //! Whether or not the manufacturer is malfunctioning, and thus will occasionally flip_out() among other glitchy things.
	var/emagged = FALSE //! Whether or not a traitor emagged the manufacturer, and thus will start acting really weird atop other things
	var/power_wire_cut = FALSE //! Whether or not the power wire is cut, removing the ability for the manufacturer to do work
	var/electrified = 0 //! This is a timer and not a true/false; it's decremented every process() tick
	var/atom/output_target = null //! The current atom we will output product into. Can be a turf, a crate, etc.
	var/list/turf/nearby_turfs = list() //! Turfs around the manufacturer are stored here for performance reasons
	var/wires = 15 //! This is a bitflag used to track wire states, for hacking and such. Replace it with something cleaner if an option exists when you're reading this :p
	var/frequency = FREQ_PDA
	var/net_id = null
	var/device_tag = "PNET_MANUFACTURER"
	var/obj/machinery/power/data_terminal/link = null //! The data terminal attached underfloor to this manufacturer. Allows use of PNET packets
	var/datum/db_record/account = null //! Card currently scanned into the machine, used when deducting payment for ores from a Rockbox

	/* Printing and queues */
	var/original_duration = 0 //! Original duration of the currently queued print, used to keep track of progress when M.time gets modified weirdly in queueing
	var/time_left = 0 //! Time left until the current blueprint is complete. Updated on pausing and on starting a new blueprint.
	var/time_started = 0 //! Time the blueprint was queued, or if paused/resumed, the time we resumed the blueprint.
	var/speed = DEFAULT_SPEED //! Controls how fast blueprints are produced. Higher speed settings have a exponential effect on power use.
	var/repeat = FALSE //! Controls whether or not to repeat the first item in the queue while working.
	var/output_cap = MAX_OUTPUT //! The maximum amount of produce this can dispense on outputting a blueprint's chosen outputs.
	var/list/datum/manufacture/queue = list() //! A list of manufacture datums in the form of a queue. Blueprints are taken from index 1 and added at the last index

	/* Resources/materials */
	/// Base class for material pieces that the manufacturer accepts.
	/// Keep this as material pieces only unless you're making larger changes to the system,
	/// Various parts of the code are coupled to assuming that this is a material piece w/ a material.
	var/base_material_class = /obj/item/material_piece
	/// The amount of each free resource that the manufacturer comes preloaded with.
	/// Separate from free_resources() as typically manufacturers use the same amount of each type.
	var/free_resource_amt = 0
	/// The types of material pieces of which the manufacturer will be spawned with.
	/// The amount of each resource is defined on free_resource_amt
	var/list/free_resources = list()
	var/obj/item/disk/data/floppy/manudrive/manudrive = null //! Where insertible manudrives are held for reading blueprints and getting/setting fablimits.
	var/should_update_static = TRUE //! true by default to update first time around, set to true whenever something is done that invalidates static data
	var/list/material_patterns_by_ref = list() //! Helper list which stores all the material patterns each loaded material satisfies, by ref to the piece
	var/list/cached_producibility_data = list() //! List which stores producibility data to be returned early in get_producibility_for_blueprints
	// Because of how get_producibility_for_blueprints works it only updates if the materials changed in quantity or order, so this makes sure we have something for comparison
	// The other option would be to manually set a trigger or flag whenever the contents are hard-coded to change but that would be unwarranted work onto future contributions
	var/list/stored_previous_materials_data = list() //! List which stores the materials as they were last seen in get_producibility_for_blueprints
	var/stored_previous_blueprint_data = "" //! JSON-encoded string of the blueprint data. used for comparisons in get_producibility_for_blueprints

	/* Production options */
	/// A list of valid categories the manufacturer will use. Any invalid provided categories are assigned "Miscellaneous".
	var/list/categories = list("Tool", "Clothing", "Resource", "Component", "Organ", "Machinery", "Medicine", "Miscellaneous", "Downloaded")
	var/accept_blueprints = TRUE //! Whether or not we accept blueprints from the ruk kit into this manufacturer.

	var/list/available = list() //! A list of every manufacture datum typepath available in this unit subtype by default
	var/list/download = list() //! Manufacture datum typepaths gained from scanned blueprints
	var/list/drive_recipes = list() //! Manufacture datum typepaths provided by an inserted manudrive
	var/list/hidden = list() //! These manufacture datum typepaths are available by default, but can't be printed or seen unless the machine is hacked

	// Unsorted stuff. The names for these should (hopefully!) be self-explanatory
	var/image/work_display = null
	var/image/activity_display = null
	var/image/panel_sprite = null
	var/sound_happy = 'sound/machines/chime.ogg'
	var/sound_grump = 'sound/machines/buzz-two.ogg'
	var/sound_beginwork = 'sound/machines/computerboot_pc.ogg'
	var/sound_damaged = 'sound/impact_sounds/Metal_Hit_Light_1.ogg'
	var/sound_destroyed = 'sound/impact_sounds/Machinery_Break_1.ogg'
	var/static/list/sounds_malfunction = list('sound/machines/engine_grump1.ogg','sound/machines/engine_grump2.ogg','sound/machines/engine_grump3.ogg',
	'sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/impact_sounds/Metal_Hit_Heavy_1.ogg','sound/machines/romhack1.ogg','sound/machines/romhack3.ogg')
	var/static/list/text_flipout_adjective = list("an awful","a terrible","a loud","a horrible","a nasty","a horrendous")
	var/static/list/text_flipout_noun = list("noise","racket","ruckus","clatter","commotion","din")
	var/static/list/text_bad_output_adjective = list("janky","crooked","warped","shoddy","shabby","lousy","crappy","shitty")
	var/datum/action/action_bar = null

	New()
		START_TRACKING
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, null, src.frequency)
		src.net_id = generate_net_id(src)

		if(!src.link)
			var/turf/T = get_turf(src)
			var/obj/machinery/power/data_terminal/test_link = locate() in T
			if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
				src.link = test_link
				src.link.master = src

		src.AddComponent(/datum/component/bullet_holes, 15, 5)

		if (istype(manuf_controls,/datum/manufacturing_controller))
			src.set_up_schematics()
			manuf_controls.manufacturing_units += src

		for (var/turf/T in view(5,src))
			nearby_turfs += T

		src.work_display = image('icons/obj/manufacturer.dmi', "")
		src.activity_display = image('icons/obj/manufacturer.dmi', "")
		src.panel_sprite = image('icons/obj/manufacturer.dmi', "")
		SPAWN(0)
			src.build_icon()

	disposing()
		STOP_TRACKING
		src.remove_storage()
		manuf_controls.manufacturing_units -= src
		src.work_display = null
		src.activity_display = null
		src.panel_sprite = null
		src.output_target = null
		src.manudrive = null
		src.available.len = 0
		src.available = null
		src.drive_recipes = null
		src.download.len = 0
		src.download = null
		src.hidden.len = 0
		src.hidden = null
		src.queue.len = 0
		src.queue = null
		src.nearby_turfs.len = 0
		src.nearby_turfs = null
		src.sound_happy = null
		src.sound_grump = null
		src.sound_beginwork = null
		src.sound_damaged = null
		src.sound_destroyed = null
		if (src.link)
			src.link.master = null
			src.link = null

		for (var/obj/O in src.contents)
			// unlikely now that manufacturers use storage datums but as said below
			O.set_loc(src.loc)
		for (var/mob/M in src.contents)
			// unlikely as this is to happen we might as well make sure everything is purged
			M.set_loc(src.loc)

		..()

	get_desc()
		if (supplemental_desc)
			. += " [supplemental_desc]"
		if (src.health < 100)
			if (src.health < 50)
				. += "<br>[SPAN_ALERT("It's rather badly damaged. It probably needs some wiring replaced inside.")]"
			else
				. += "<br>[SPAN_ALERT("It's a bit damaged. It looks like it needs some welding done.")]"

		if	(status & BROKEN)
			. += "<br>[SPAN_ALERT("It seems to be damaged beyond the point of operability!")]"
		if	(status & NOPOWER)
			. += "<br>[SPAN_ALERT("It seems to be offline.")]"

		switch(src.dismantle_stage)
			if(DISMANTLE_PLATING_BOLTS)
				. += "<br>[SPAN_ALERT("It's partially dismantled. To deconstruct it, use a crowbar. To repair it, use a wrench.")]"
			if(DISMANTLE_PLATING_SHEETS)
				. += "<br>[SPAN_ALERT("It's partially dismantled. To deconstruct it, use wirecutters. To repair it, add reinforced metal.")]"
			if(DISMANTLE_WIRES)
				. += "<br>[SPAN_ALERT("It's partially dismantled. To deconstruct it, use a wrench. To repair it, add some cable.")]"

	process(mult)
		if (status & NOPOWER)
			return

		..()

		if (src.mode == MODE_WORKING)
			use_power(src.active_power_consumption)

		if (src.time_left_electrified > 0)
			src.time_left_electrified--

	proc/finish_work()
		if(length(src.queue))
			output_loop(src.queue[1])
			if (!src.repeat)
				src.queue -= src.queue[1]

		if (length(src.queue) < 1)
			playsound(src.loc, src.sound_happy, 50, 1)
			src.visible_message(SPAN_NOTICE("[src] finishes its production queue."))
			src.mode = MODE_READY
			src.build_icon()

	ex_act(severity)
		switch(severity)
			if(1)
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				src.take_damage(rand(100,120))
			if(2)
				src.take_damage(rand(40,80))
			if(3)
				src.take_damage(rand(20,40))
		return

	blob_act(power)
		src.take_damage(randfloat(power * 0.5, power * 1.5))

	meteorhit()
		src.take_damage(rand(15,45))

	emp_act()
		src.take_damage(rand(5,10))
		src.malfunction = TRUE
		src.flip_out()

	bullet_act(obj/projectile/P)
		// swiped from guardbot.dm
		var/damage = 0
		damage = round(((P.power/3)*P.proj_data.ks_ratio), 1.0)

		src.material_trigger_on_bullet(src, P)

		if (!damage)
			return
		if(P.proj_data.damage_type == D_KINETIC || (P.proj_data.damage_type == D_ENERGY && damage))
			src.take_damage(damage / 2)
		else if (P.proj_data.damage_type == D_PIERCING)
			src.take_damage(damage)

	power_change()
		if (QDELETED(src))
			return
		if(src.is_broken())
			src.build_icon()
		else
			if(src.powered() && src.dismantle_stage < DISMANTLE_WIRES)
				src.check_power_status()
				src.build_icon()
			else
				SPAWN(rand(0, 15))
					src.check_power_status()
					src.build_icon()

	/// Overriden to not disable if no power, wire maintenence to restore power is on the GUI which creates catch-22 situation
	broken_state_topic(mob/user)
		. = user.shared_ui_interaction(src)
		if (src.is_broken())
			return min(., UI_CLOSE)
		else if (requires_power && status & (NOPOWER | POWEROFF))
			return min(., UI_INTERACTIVE)
		else if (status & MAINT)
			return min(., UI_UPDATE)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Manufacturer")
			ui.open()

	ui_data(mob/user)
		// When we update the UI, we must regenerate the blueprint data if the blueprints known to us has changed since last time
		// No need to do this if we're depowered/broken though
		if (should_update_static && !src.is_disabled())
			should_update_static = FALSE
			src.update_static_data(user)

		// Get data about resources in the manufacturer and what it can/can't make
		var/list/resource_data = list()
		for (var/obj/item/material_piece/P as anything in src.get_contents())
			if (!P.material)
				continue
			resource_data += list(list("name" = P.material.getName(), "id" = P.material.getID(), "amount" = P.amount, "byondRef" = "\ref[P]", "satisfies" = src.material_patterns_by_ref["\ref[P.material]"]))
		var/list/blueprint_producibility_by_ref = src.get_producibility_for_blueprints()

		// Package additional information into each queued item for the badges so that it can lookup its already sent information
		var/queue_data = list()
		for (var/datum/manufacture/M in src.queue)
			queue_data += list(list("name" = M.name, "category" = M.category, "type" = src.get_blueprint_type(M)))

		// This calculates the percentage progress of a blueprint by the time that already elapsed before a pause (0 if never paused)
		// added to the current time that has been elapsed, divided by the total time to be elapsed.
		// But we keep the pct a constant if we're paused, and just do time that was elapsed / time to elapse
		var/progress_pct = null // TODO: use predicted end time to have clientside progress animation instead of sending percentage
		if (length(src.queue))
			if (src.mode != MODE_WORKING)
				progress_pct = 1 - (src.time_left / src.original_duration)
			else
				progress_pct = ((src.original_duration - src.time_left) + (TIME - src.time_started)) / src.original_duration

		return list(
			"delete_allowed" = src.allowed(user),
			"queue" = queue_data,
			"progress_pct" = progress_pct,
			"panel_open" = src.panel_open,
			"hacked" = src.hacked,
			"malfunction" = src.malfunction,
			"mode" = src.mode,
			"wire_bitflags" = src.wires,
			"banking_info" = src.get_bank_data(),
			"speed" = src.speed,
			"repeat" = src.repeat,
			"error" = src.error,
			"resource_data" = resource_data,
			"producibility_data" = blueprint_producibility_by_ref,
			"manudrive_uses_left" = src.get_drive_uses_left(),
			"indicators" = list("electrified" = src.is_electrified(),
							    "malfunctioning" = src.malfunction,
								"hacked" = src.hacked,
								"hasPower" = !src.is_disabled(),
							   ),
		)

	ui_static_data(mob/user)
		return list (
			"fabricator_name" = src.name,
			"all_categories" = src.categories,
			"available_blueprints" = blueprints_as_list(src.available, user),
			"hidden_blueprints" = blueprints_as_list(src.hidden, user),
			"downloaded_blueprints" = blueprints_as_list(src.download, user),
			"recipe_blueprints" = blueprints_as_list(src.drive_recipes, user),
			"wires" = APCWireColorToIndex,
			"rockboxes" = rockboxes_as_list(),
			"manudrive" = list ("name" = "[src.manudrive]",
							   	"limit" = src.manudrive?.fablimit,
							   ),
			"min_speed" = MIN_SPEED,
			"max_speed_normal" = MAX_SPEED,
			"max_speed_hacked" = MAX_SPEED_HACKED,
		)

	/// Get whether a blueprint is available, hidden, downloaded, or a drive recipe. If in multiple print lists, picks the first result. Or null.
	proc/get_blueprint_type(var/datum/manufacture/M)
		if (M in src.available)
			return "available"
		else if (M in src.hidden)
			return "hidden"
		else if (M in src.download)
			return "download"
		else if (M in src.drive_recipes)
			return "drive_recipes"
		else
			return null

	/// Gets rockbox data as list for ui_static_data
	proc/rockboxes_as_list()
		var/rockboxes = list()
		for_by_tcl(cloud_container, /obj/machinery/ore_cloud_storage_container)
			if(cloud_container.is_broken())
				continue
			var/ore_data = list()
			for(var/ore_name as anything in cloud_container.ores)
				var/datum/ore_cloud_data/oredata = cloud_container.ores[ore_name]
				if(!oredata.for_sale || !oredata.amount)
					continue
				ore_data += list(list(
					"name" = ore_name,
					"amount" = oredata.amount,
					"cost" = oredata.price + ORE_TAX(oredata.price),
				))
			rockboxes += list(list(
				"name" = cloud_container.name,
				"area_name" = get_area(cloud_container),
				"byondRef" = "\ref[cloud_container]",
				"ores" = ore_data,
			))
		return rockboxes


	/// Converts list of manufacture datums to list keyed by category containing listified manufacture datums of said category.
	proc/blueprints_as_list(var/list/L, mob/user, var/static_elements = FALSE)
		var/list/as_list = list()
		for (var/datum/manufacture/M as anything in L)
			if (isnull(M.category) || !(M.category in src.categories)) // fix for not displaying blueprints/manudrives
				M.category = "Miscellaneous"
				logTheThing(LOG_DEBUG, src, "Manufacturing blueprint [M] has category [M.category], which is not on the list of categories for [src]!")
			if (length(as_list[M.category]) == 0)
				as_list[M.category] = list()
			as_list[M.category] += list(manufacture_as_list(M, user, static_elements))
		return as_list

	/// Converts a manufacture datum to a list with string keys to relevant vars for the UI
	proc/manufacture_as_list(datum/manufacture/M, mob/user)
		var/generated_names = list()
		var/generated_descriptions = list()

		// Fix not having generated material names for blueprints like multitools
		if (isnull(M.item_names))
			M.item_names = list()
			for (var/datum/manufacturing_requirement/R as anything in M.item_requirements)
				M.item_names += R.getName()

		for (var/i in 1 to length(M.item_outputs))
			var/T
			if (istype(M, /datum/manufacture/mechanics))
				var/datum/manufacture/mechanics/mech = M
				T = mech.frame_path
			else
				T = M.item_outputs[i]

			if (ispath(T, /atom/))
				var/atom/A = T
				generated_names += initial(A.name)
				generated_descriptions += "[initial(A.desc)]"

		var/img
		if (istype(M, /datum/manufacture/mechanics))
			var/datum/manufacture/mechanics/mech = M
			img = getItemIcon(mech.frame_path, C = user.client)
		else
			img = getItemIcon(M.item_outputs[1], C = user.client)

		var/requirement_data = list()
		for (var/datum/manufacturing_requirement/R as anything in M.item_requirements)
			requirement_data += list(list("name" = R.getName(), "id" = R.getID(), "amount" = M.item_requirements[R]))

		return list(
			"name" = M.name,
			"category" = M.category,
			"requirement_data" = requirement_data,
			"item_names" = generated_names,
			"item_descriptions" = generated_descriptions,
			"item_outputs" = M.item_outputs,
			"create" = M.create,
			"time" = M.time,
			"apply_material" = M.apply_material,
			"img" = img,
			"byondRef" = "\ref[M]",
			"isMechBlueprint" = istype(M, /datum/manufacture/mechanics),
		)

	/// Get an associated list for the UI of blueprintRef to associated list of requirement name to whether that one's producible, but only when necessary
	proc/get_producibility_for_blueprints()
		// Run a comparison against the shallow storage of the previous contents to see if it changed
		var/contents_changed = FALSE
		var/list/C = src.get_contents()
		var/list/refs_encountered = list() //! List to gather the refs still in the container, to find what might no longer exist in the container and prune it from stored data accordingly
		for (var/obj/item/material_piece/M as anything in C)
			var/M_ref = "\ref[M]"
			refs_encountered.Add(M_ref)
			// Do checks if we still aren't convinced contents changed
			if (!contents_changed)
				// Compare amounts, where stored_previous_materials_data[ref] contains the amount last recorded
				if (!(M_ref in src.stored_previous_materials_data) || M.amount != src.stored_previous_materials_data[M_ref])
					contents_changed = TRUE
			// After checking this one, overwrite the previous entry with the new
			src.stored_previous_materials_data[M_ref] = M.amount
		// Quick pass to remove any stored material refs that shouldn't exist
		for (var/ref in src.stored_previous_materials_data)
			if (!(ref in refs_encountered))
				src.stored_previous_materials_data.Remove(ref)
				contents_changed = TRUE
		// Do actual computation since contents changed
		if (contents_changed)
			return src.compute_producibility_for_blueprints()
		// Contents didn't change, but this nerd might have added blueprints so now we check if blueprints changed
		// Quick first pass to see if lengths differ. If they do, blueprints certainly changed.
		var/all_blueprints = ALL_BLUEPRINTS // just to compile the list once
		if (length(all_blueprints) != length(src.stored_previous_blueprint_data))
			src.stored_previous_blueprint_data = all_blueprints
			return src.compute_producibility_for_blueprints()
		// Slightly more in depth check over the blueprints to check if any are missing
		for (var/datum/manufacture/M as anything in all_blueprints)
			if (!(M in src.stored_previous_blueprint_data))
				// A blueprint was found that wasn't previously seen, so it changed
				src.stored_previous_blueprint_data = all_blueprints
				return src.compute_producibility_for_blueprints()
		// Nothing changed, return the cached data
		return src.cached_producibility_data

	/// Runs the actual computation for the above proc. Split apart so the caching can still be a bit more performant
	proc/compute_producibility_for_blueprints()
		var/list/output = list()
		for (var/datum/manufacture/M as anything in ALL_BLUEPRINTS)
			var/M_ref = "\ref[M]"
			var/list/mats_needed = src.get_materials_needed(M)
			output[M_ref] = list()
			// 'convert' the result of R = P_ref to R.name = boolean
			for (var/datum/manufacturing_requirement/needed_R as anything in M.item_requirements)
				output[M_ref][needed_R.getName()] = FALSE
				for (var/datum/manufacturing_requirement/satisfied_R as anything in mats_needed)
					if (satisfied_R == needed_R)
						output[M_ref][needed_R.getName()] = TRUE
						break
		// Store this as cached now that it has, in fact, changed
		src.cached_producibility_data = output
		return output

	attack_hand(mob/user)
		// We do this here instead of on New() as a tiny optimization to keep some overhead off of map load
		if (length(free_resources) > 0)
			claim_free_resources()
		if(src.is_electrified())
			if (!(status & NOPOWER || status & BROKEN))
				if (src.shock(user, 33))
					return
		src.ui_interact(user)

	proc/is_electrified()
		return src.time_left_electrified > 0

	/// Returns whether or not a blueprint is able to be used for printing
	proc/blueprint_is_available(datum/manufacture/M)
		. = FALSE
		if(src.available && (M in src.available))
			return TRUE

		if(src.download && (M in src.download))
			return TRUE

		if(src.drive_recipes && (M in src.drive_recipes))
			return TRUE

		if(src.hacked && src.hidden && (M in src.hidden))
			return TRUE

	/// Try to shock the target if the machine is electrified, returns whether or not the target got shocked
	proc/try_shock(mob/target, var/chance)
		if (src.is_electrified())
			return src.shock(usr, chance)
		return FALSE

	/// Check if the target is within arm's reach of the machine
	proc/has_physical_proximity(mob/target)
		return (BOUNDS_DIST(src, target) == 0) && istype(src.loc, /turf)

	/// Handle checking and outputting for not being close to the machine
	proc/check_physical_proximity(mob/target)
		if (!src.has_physical_proximity(target))
			src.grump_message(usr, "You need to be adjacent to the fabricator to do that!", sound = FALSE)
			return FALSE
		return TRUE

	/// Check if the target is allowed to interact with this at range. Silicons can, humans can't.
	proc/can_use_ranged(mob/target)
		return isAI(target) || isrobot(target)

	/// Helper to play the grump with or without a grump message/sound. Just as a note the sound is appropriate when the machine is reporting the error,
	/// if its a grump that the player probably had to think about or find out then theres no "reason" for there to be sound
	proc/grump_message(mob/target = null, var/message = null, var/sound = FALSE)
		if (!isnull(message))
			if (!isnull(target))
				boutput(target, SPAN_ALERT(message))
			else
				src.visible_message(SPAN_ALERT(message))
		if (sound)
			playsound(src.loc, src.sound_grump, 50, 1)

	ui_act(action, params)
		// Handle wire stuff first before forbidding for power loss
		if (action == "wire")
			if (!src.panel_open)
				src.grump_message(usr, "The panel is closed!")
				return

			switch (params["action"])
				if ("cut", "mend")
					if (!src.check_physical_proximity(usr))
						return
					if (src.try_shock(usr, 100))
						return
					if (!(issnippingtool(usr.equipped())))
						src.grump_message(usr, "You need to be holding a snipping tool for that!")
					else
						if (params["action"] == "cut")
							src.cut(usr, text2num_safe(params["wire"]))
						else
							src.mend(usr, text2num_safe(params["wire"]))
						return TRUE
				if ("pulse")
					if (!ispulsingtool(usr.equipped()))
						src.grump_message(usr, "You need to be holding a pulsing tool or similar for that!")
						return
					if (!((src.can_use_ranged(usr) || src.has_physical_proximity(usr))))
						src.grump_message(usr, "You need to be adjacent to the fabricator for that!")
						return
					src.pulse(usr, text2num_safe(params["wire"]))
					return TRUE

		// Call parent AFTER wires so you can at least fix the power on it
		. = ..()

		if(.)
			return

		if (!ON_COOLDOWN(src, "electrified_action", 1 DECI SECOND))
			if (src.try_shock(usr, 10))
				return

		if (!src.can_use_ranged(usr) && !src.has_physical_proximity(usr))
			return

		switch(action)
			if ("request_product")
				if (ON_COOLDOWN(src, "product", 1 DECI SECOND))
					src.grump_message(usr, "Slow down!")
					return
				var/datum/manufacture/I = locate(params["blueprint_ref"])
				if (!istype(I,/datum/manufacture/))
					return
				// Verify that there is no href fuckery abound
				if(!blueprint_is_available(I))
					// Since a manufacturer may get unhacked or a downloaded item could get deleted between someone
					// opening the window and clicking the button we can't assume intent here, so no cluwne
					return
				if (!check_enough_materials(I))
					src.grump_message(usr, "Insufficient usable materials to manufacture that item.", sound = TRUE)

				else if (length(src.queue) >= MAX_QUEUE_LENGTH)
					src.grump_message(usr, "Manufacturer queue length limit reached.", sound = TRUE)
				else
					src.queue += I
					logTheThing(LOG_STATION, usr, "queues manufacturing of [I.name] ([json_encode(I.item_outputs)])[repeat ? " on repeat":""] in [src] at [log_loc(src)]")
					if (src.mode == MODE_READY)
						src.begin_work( new_production = TRUE )
					return TRUE

			if ("material_eject")
				src.eject_material(params["resource"], usr)
				return TRUE

			if ("material_swap")
				// Not doing this would certainly allow for exploits/bugs since resource allocation is greedy and could fail with different orders
				if (src.mode == MODE_WORKING || src.mode == MODE_HALT)
					src.grump_message(usr, "You cannot do that while the unit is working, it is already using the current materials!")
					return
				src.swap_materials(usr, locate(params["resource_1"]), locate(params["resource_2"]))
				return TRUE

			if ("card")
				if (params["scan"])
					var/obj/item/I = usr.equipped()
					src.scan_card(I)
				if (params["remove"])
					src.account = null
				return TRUE

			if ("speed")
				if (src.mode == MODE_WORKING)
					src.grump_message(usr, "You cannot alter the speed setting while the unit is working.")
					return
				src.speed = clamp(params["value"], 1, (src.hacked ? MAX_SPEED_HACKED : MAX_SPEED))
				return TRUE

			if ("repeat")
				src.repeat = !src.repeat
				return TRUE

			if ("ore_purchase")
				if (ON_COOLDOWN(src, "ore_purchase", 1 SECOND))
					src.grump_message(usr, "Slow down!")
					return
				src.buy_ore(params["ore"], params["storage_ref"])
				return TRUE

			if ("clear") // clear entire queue
				if (ON_COOLDOWN(src, "clear", 1 SECOND))
					src.grump_message(usr, "Slow down!")
					return
				src.queue = list()
				src.mode = MODE_READY
				src.build_icon()
				if (src.action_bar)
					src.action_bar.interrupt(INTERRUPT_ALWAYS)
				return TRUE

			if ("pause_toggle")
				if (ON_COOLDOWN(src, "pause_toggle", 1 SECOND))
					src.grump_message(usr, "Slow down!")
					return
				if (params["action"] == "continue")
					if (!length(src.queue))
						src.grump_message(usr, "ERROR: Cannot find any items in queue to continue production.", sound = TRUE)
						return
					if (!check_enough_materials(src.queue[1]))
						src.grump_message(usr, "ERROR: Insufficient usable materials to manufacture first item in queue.", sound = TRUE)
					else
						src.begin_work( new_production = TRUE )
						src.time_started = TIME
					return TRUE
				else if (params["action"] == "pause")
					src.mode = MODE_HALT
					src.build_icon()
					if (src.action_bar)
						src.action_bar.interrupt(INTERRUPT_ALWAYS)
					return TRUE

			if ("remove") // remove queued blueprint
				if (ON_COOLDOWN(src, "remove", 1 DECI SECOND))
					src.grump_message(usr, "Slow down!")
					return
				var/operation = text2num_safe(params["index"])
				if (!isnum(operation) || !length(src.queue) || operation > length(src.queue))
					src.grump_message(usr, "ERROR: Invalid Operation.", sound = TRUE)
					return
				src.queue -= src.queue[operation]
				actions.interrupt(src, INTERRUPT_ALWAYS)

				// This is a new production if we removed the item at index 1, otherwise we just removed something not being produced yet
				begin_work( new_production = (operation == 1) )
				return TRUE

			if ("delete") // remove blueprint from storage
				if (ON_COOLDOWN(src, "delete", 1 SECOND))
					src.grump_message(usr, "Slow down!")
					return
				if(!src.allowed(usr))
					src.grump_message(usr, "ERROR: Access Denied.", sound = TRUE)
					return
				var/datum/manufacture/I = locate(params["blueprint_ref"])
				if (!istype(I,/datum/manufacture/mechanics/))
					src.grump_message(usr, "ERROR: Cannot delete this type of schematic.", sound = TRUE)
					return
				if(tgui_alert(usr, "Are you sure you want to remove [I.name] from the [src]?", "Confirmation", list("Yes", "No")) == "Yes")
					if (!src.allowed(usr))
						src.grump_message(usr, "ERROR: Could not re-validate authentication credentials. Aborting.", sound = TRUE)
						return
					if (!src.can_use_ranged(src) && !src.check_physical_proximity(usr))
						return
					src.download -= I
					should_update_static = TRUE
					return TRUE

			if ("manudrive")
				if (ON_COOLDOWN(src, "manudrive", 1 SECOND))
					src.grump_message(usr, "Slow down!")
					return
				if (params["action"] == "eject")
					if (src.mode != MODE_READY)
						src.grump_message(usr, "You can't do that while the unit is working!")
						return
					src.eject_manudrive(usr)
					return TRUE


	proc/buy_ore(ore_name, storage_ref)
		var/obj/machinery/ore_cloud_storage_container/storage = locate(storage_ref)
		var/datum/ore_cloud_data/OCD = storage.ores[ore_name]
		if (!OCD.amount || OCD.amount <= 0)
			src.grump_message(usr, "ERROR: That just ran out, hold your horses!", sound = TRUE)
		var/taxes = ORE_TAX(OCD.price) //transaction taxes for the station budget

		if(storage?.is_disabled())
			return

		if(!src.account)
			src.grump_message(usr, "ERROR: No card scanned. Please scan your ID.", sound = TRUE)
			return
		if (src.get_bank_data()["name"] in FrozenAccounts)
			src.grump_message(usr, "ERROR: Account cannot be liquidated due to active borrows.", sound = TRUE)
			return
		if (src.account)
			var/quantity = tgui_input_number(usr, "How many units do you want to purchase?", "Ore Purchase", default=1, max_value=OCD.amount, min_value=0)
			if(!isnum_safe(quantity))
				return
			////////////

			if(OCD.amount >= quantity && quantity > 0)
				var/subtotal = round(OCD.price * quantity)
				var/sum_taxes = round(taxes * quantity)
				var/rockbox_fees = (!rockbox_globals.rockbox_premium_purchased ? rockbox_globals.rockbox_standard_fee : 0) * quantity
				var/total = subtotal + sum_taxes + rockbox_fees
				if(account["current_money"] >= total)
					account["current_money"] -= total
					storage.eject_ores(ore_name, get_output_location(), quantity, transmit=1, user=usr)

						// This next bit is stolen from PTL Code
					var/list/accounts = \
						data_core.bank.find_records("job", "Chief Engineer") + \
						data_core.bank.find_records("job", "Miner")


					var/datum/signal/minerSignal = get_free_signal()
					minerSignal.source = src
					//any non-divisible amounts go to the shipping budget
					var/leftovers = 0
					if(length(accounts))
						leftovers = subtotal % length(accounts)
						var/divisible_amount = subtotal - leftovers
						if(divisible_amount)
							var/amount_per_account = divisible_amount/length(accounts)
							for(var/datum/db_record/t as anything in accounts)
								t["current_money"] += amount_per_account
							minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX™-MAILBOT",  "group"=list(MGD_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [amount_per_account] credits earned from Rockbox™ sale, deposited to your account.")
					else
						leftovers = subtotal
						minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX™-MAILBOT",  "group"=list(MGD_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [leftovers + sum_taxes] credits earned from Rockbox™ sale, deposited to the shipping budget.")
					wagesystem.shipping_budget += (leftovers + sum_taxes)
					SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, minerSignal)
					src.should_update_static = TRUE
				else
					src.grump_message(usr, "ERROR: You don't have enough dosh, bucko.", sound = TRUE)
			else
				if(quantity > 0)
					src.grump_message(usr, "ERROR: I don't have that many for sale, champ.", sound = TRUE)
				else
					src.grump_message(usr, "Enter some actual valid number, you doofus!", sound = TRUE)
		else
			src.grump_message(usr, "That card doesn't have an account anymore, you might wanna get that checked out.", sound = TRUE)

	emag_act(mob/user, obj/item/card/emag/E)
		if (!src.hacked)
			src.hacked = TRUE
			if(user)
				boutput(user, SPAN_NOTICE("You remove the [src]'s product locks!"))
			return TRUE
		return FALSE

	/*
	Handling for shocking the user
	Handling for getting the satchel of an ore scoop
	Handling for getting the blueprint into a fabricator
	Handling for loading material bars from a satchel
	Handling for tools (screwdriver, open maint panel)
	Handling for tools (welding, repair/load)
	Handling for cable coils (repair, load)
	Handling for tools (crowbar, dismantle)
	Handling for tools (snipping, dismantle)
	Handling for reconstruction (sheets, reconstruct)
	Handling for cable coils (reconstruct)
	Handling for inserting manudrives
	Grumping for trying to insert sheets/coils/raw mats
	Handling for inserting material pieces
	Handling for.. snipping/pulsing calling Attackhand when the panel is open?
	Handling for early return if a card is scanned successfully
	Handling for calling parent proc + hitting the machine
	*/

	attackby(obj/item/W, mob/user)
		// Handling for shocking the user
		if (src.is_electrified())
			if (src.shock(user, 33))
				return

		if (istype(W, /obj/item/deconstructor)) return  // handled in decon afterattack

		// Handling for getting the satchel of an ore scoop
		if (istype(W, /obj/item/ore_scoop))
			var/obj/item/ore_scoop/scoop = W
			W = scoop.satchel

		// Handling for getting the blueprint into a fabricator
		if (istype(W, /obj/item/paper/manufacturer_blueprint))
			if (!src.accept_blueprints)
				src.grump_message(user, "This manufacturer unit does not accept blueprints.")
				return
			var/obj/item/paper/manufacturer_blueprint/BP = W
			if (src.malfunction && prob(75))
				src.visible_message(SPAN_ALERT("[src] emits a [pick(src.text_flipout_adjective)] [pick(src.text_flipout_noun)]!"))
				playsound(src.loc, pick(src.sounds_malfunction), 50, 1)
				boutput(user, SPAN_ALERT("The manufacturer mangles and ruins the blueprint in the scanner! What the fuck?"))
				qdel(BP)
				return
			if (!BP.blueprint)
				src.visible_message(SPAN_ALERT("[src] emits a grumpy buzz!"))
				playsound(src.loc, src.sound_grump, 50, 1)
				boutput(user, SPAN_ALERT("The manufacturer rejects the blueprint. Is something wrong with it?"))
				return
			for (var/datum/manufacture/mechanics/M in (src.available + src.download))
				if(istype(M) && istype(BP.blueprint, /datum/manufacture/mechanics))
					var/datum/manufacture/mechanics/BPM = BP.blueprint
					if(M.frame_path == BPM.frame_path)
						src.visible_message(SPAN_ALERT("[src] emits an irritable buzz!"))
						playsound(src.loc, src.sound_grump, 50, 1)
						boutput(user, SPAN_ALERT("The manufacturer rejects the blueprint, as it already knows it."))
						return
				else if (BP.blueprint.name == M.name)
					src.visible_message(SPAN_ALERT("[src] emits an irritable buzz!"))
					playsound(src.loc, src.sound_grump, 50, 1)
					boutput(user, SPAN_ALERT("The manufacturer rejects the blueprint, as it already knows it."))
					return
			BP.dropped(user)
			src.download += BP.blueprint
			src.visible_message(SPAN_ALERT("[src] emits a pleased chime!"))
			playsound(src.loc, src.sound_happy, 50, 1)
			boutput(user, SPAN_NOTICE("The manufacturer accepts and scans the blueprint."))
			qdel(BP)
			should_update_static = TRUE
			return

		// Handling for loading material bars from a satchel
		else if (istype(W, /obj/item/satchel))
			user.visible_message(SPAN_NOTICE("[user] uses [src]'s automatic loader on [W]!"), SPAN_NOTICE("You use [src]'s automatic loader on [W]."))
			var/amtload = 0
			for (var/obj/item/M in W.contents)
				if (!istype(M,src.base_material_class))
					continue
				src.add_contents(M, user)
				amtload++
			W:UpdateIcon()
			if (amtload) boutput(user, SPAN_NOTICE("[amtload] materials loaded from [W]!"))
			else boutput(user, SPAN_ALERT("No materials loaded!"))

		// Handling for tools (screwdriver, open maint panel)
		else if (isscrewingtool(W))
			if (!src.panel_open)
				src.panel_open = TRUE
			else
				src.panel_open = FALSE
			boutput(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
			src.build_icon()
			tgui_process.try_update_ui(user, src)

		// Handling for tools (welding, repair/load)
		else if (isweldingtool(W))
			var/do_action = 0
			if (istype(W,src.base_material_class) && src.accept_loading(user))
				var/choice = tgui_alert(user, "What do you want to do with [W]?", "[src.name]", list("Repair", "Load it in"))
				if (!choice)
					return
				if (choice == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."), SPAN_NOTICE("You load [W] into the [src]."))
				src.add_contents(W, user)
			else
				if (src.health < 50)
					boutput(user, SPAN_ALERT("It's too badly damaged. You'll need to replace the wiring first."))
				else if(W:try_weld(user, 1))
					src.take_damage(-10)
					user.visible_message("<b>[user]</b> uses [W] to repair some of [src]'s damage.")
					if (src.health == 100)
						boutput(user, SPAN_NOTICE("<b>[src] looks fully repaired!</b>"))

		// Handling for cable coils (repair, load, reconstruct)
		else if (istype(W,/obj/item/cable_coil) && src.panel_open)
			var/obj/item/cable_coil/C = W
			var/do_action = 0
			if (istype(C,src.base_material_class) && src.accept_loading(user))
				var/choice = tgui_alert(user, "What do you want to do with [C]?", "[src.name]", list("Repair", "Load it in"))
				if (!choice)
					return
				if (choice == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message(SPAN_NOTICE("[user] loads [C] into the [src]."), SPAN_NOTICE("You load [C] into the [src]."))
				src.add_contents(C, user)
			else
				if (src.health >= 50)
					boutput(user, SPAN_ALERT("The wiring is fine. You need to weld the external plating to do further repairs."))
				else
					C.use(1)
					src.take_damage(-10)
					user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if (src.health >= 50)
						boutput(user, SPAN_NOTICE("The wiring is fully repaired. Now you need to weld the external plating."))

		// Handling for tools (wrench, dismantle/reconstruct/load)
		else if (iswrenchingtool(W))
			var/do_action = 0
			if (istype(W,src.base_material_class) && src.accept_loading(user))
				var/choice = tgui_alert(user, "What do you want to do with [W]?", "[src.name]", list("Dismantle/Construct", "Load it in"))
				if (!choice)
					return
				if (choice == "Load it in")
					do_action = 1
			if (do_action == 1)
				user.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."), SPAN_NOTICE("You load [W] into the [src]."))
				src.add_contents(W, user)
			else
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if (src.dismantle_stage == DISMANTLE_NONE)
					user.visible_message("<b>[user]</b> loosens [src]'s external plating bolts.")
					src.dismantle_stage = DISMANTLE_PLATING_BOLTS
				else if (src.dismantle_stage == DISMANTLE_PLATING_BOLTS)
					user.visible_message("<b>[user]</b> fastens [src]'s external plating bolts.")
					src.dismantle_stage = DISMANTLE_NONE
				else if (src.dismantle_stage == DISMANTLE_WIRES)
					user.visible_message("<b>[user]</b> dismantles [src]'s mechanisms.")
					new /obj/item/sheet/steel/reinforced(src.loc)
					qdel(src)
					return
				src.build_icon()

		// Handling for tools (crowbar, dismantle)
		else if (ispryingtool(W) && src.dismantle_stage == DISMANTLE_PLATING_BOLTS)
			user.visible_message("<b>[user]</b> pries off [src]'s plating.")
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			src.dismantle_stage = DISMANTLE_PLATING_SHEETS
			new /obj/item/sheet/steel/reinforced(src.loc)
			src.build_icon()

		// Handling for tools (snipping, dismantle)
		else if (issnippingtool(W) && src.dismantle_stage == DISMANTLE_PLATING_SHEETS)
			if (!(status & NOPOWER))
				if (src.shock(user,100))
					return
			user.visible_message("<b>[user]</b> disconnects [src]'s cabling.")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
			src.dismantle_stage = DISMANTLE_WIRES
			src.check_power_status()
			var/obj/item/cable_coil/C = new /obj/item/cable_coil(src.loc)
			C.amount = 1
			C.UpdateIcon()
			src.build_icon()

		// Handling for reconstruction (sheets, reconstruct)
		else if (istype(W,/obj/item/sheet/steel/reinforced) && src.dismantle_stage == DISMANTLE_PLATING_SHEETS)
			user.visible_message("<b>[user]</b> adds plating to [src].")
			src.dismantle_stage = DISMANTLE_PLATING_BOLTS
			qdel(W)
			src.build_icon()

		// Handling for cable coils (reconstruct)
		else if (istype(W,/obj/item/cable_coil) && src.dismantle_stage == DISMANTLE_WIRES)
			user.visible_message("<b>[user]</b> adds cabling to [src].")
			src.dismantle_stage = DISMANTLE_PLATING_SHEETS
			var/obj/item/cable_coil/C = W
			C.use(1)
			src.check_power_status()
			src.shock(user,100)
			src.build_icon()

		// Handling for inserting manudrives
		else if (istype(W,/obj/item/disk/data/floppy/manudrive))
			if (src.manudrive)
				boutput(user, SPAN_ALERT("You swap out the disk in the manufacturer with a different one."))
				src.eject_manudrive(user)
				src.manudrive = W
				if (user && W)
					user.u_equip(W)
					W.dropped(user)
				for (var/datum/computer/file/manudrive/MD in src.manudrive.root.contents)
					src.drive_recipes = MD.drivestored
			else
				boutput(user, SPAN_NOTICE("You insert [W]."))
				W.set_loc(src)
				src.manudrive = W
				if (user && W)
					user.u_equip(W)
					W.dropped(user)
				for (var/datum/computer/file/manudrive/MD in src.manudrive.root.contents)
					src.drive_recipes = MD.drivestored
			should_update_static = TRUE


		else if (istype(W, /obj/item/sheet/) || istype(W, /obj/item/cable_coil/) || istype(W, /obj/item/raw_material/))
			src.grump_message(user, "The fabricator rejects the [W]. You'll need to refine them in a reclaimer first.", sound = TRUE)
			return

		// Handling for inserting material pieces
		else if (istype(W, src.base_material_class) && src.accept_loading(user))
			user.visible_message(SPAN_NOTICE("[user] loads [W] into [src]."), SPAN_NOTICE("You load [W] into [src]."))
			src.add_contents(W, user)

		// Handling for.. snipping/pulsing calling Attackhand when the panel is open?
		else if (src.panel_open && (issnippingtool(W) || ispulsingtool(W)))
			src.Attackhand(user)
			return

		// Handling for early return if a card is scanned successfully
		else if(scan_card(W))
			return

		// Handling for calling parent proc + hitting the machine
		else
			..()
			user.lastattacked = src
			attack_particle(user,src)
			hit_twitch(src)
			if (W.hitsound)
				playsound(src.loc, W.hitsound, 50, 1)
			if (W.force)
				var/damage = W.force
				damage /= 3
				if (user.is_hulk())
					damage *= 4
				if (iscarbon(user))
					var/mob/living/carbon/C = user
					if (C.bioHolder && C.bioHolder.HasEffect("strong"))
						damage *= 2
				if (damage >= 5)
					src.take_damage(damage)

	/// Swap the "position" of two materials in the manufacturer for the sake of priority use management.
	proc/swap_materials(mob/user, var/material_1, var/material_2)
		// Could be ejected by someone else between the time of selecting what to swap and swapping it or be invalid
		var/list/storage = src.get_contents()
		var/index_1 = storage.Find(material_1)
		var/index_2 = storage.Find(material_2)
		if (!index_1 || !index_2)
			src.grump_message(user, "ERROR: One or both of those materials are not present in storage. Aborting.", sound = TRUE)
			return
		var/temp_hold = storage[index_1]
		storage[index_1] = storage[index_2]
		storage[index_2] = temp_hold
		src.should_update_static = TRUE

	/// Handles allowing the user to eject integer amounts of material
	proc/eject_material(var/mat_ref, mob/user)
		var/obj/item/material_piece/P = src.get_material_by_ref(mat_ref)
		if (!src.can_eject_material(P, user))
			return
		var/eject_amount = tgui_input_number(user,
											 "How many material pieces do you want to eject?",
											 title = "Eject Materials",
											 default = 0,
											 max_value = ceil(P.amount),
											 min_value = 0,
											 round_input = TRUE,
											)
		if (!src.can_eject_material(P, user))
			return
		// In case tgui_input_number() misses something or it's 0 (Likely trying to cancel action)
		if (!isnum(eject_amount) || !isnum_safe(eject_amount) || eject_amount < 1)
			src.grump_message(user, "ERROR: Cannot eject [eject_amount] piece\s.", sound = TRUE)
			return
		// This should never happen either
		if (eject_amount > P.amount)
			src.grump_message(user, "ERROR: Cannot eject [eject_amount] piece\s, as there are only [floor(P.amount)] piece\s available to eject.", sound = TRUE)
			eject_amount = floor(P.amount)
		if (eject_amount == P.amount)
			P.UpdateStackAppearance()
			P.set_loc(src.get_output_location())
		else
			var/obj/item/material_piece/output = P.split_stack(eject_amount)
			output.set_loc(src.get_output_location())

	/// Helper proc to check whether or not we can eject the material from storage or not.
	proc/can_eject_material(var/obj/item/material_piece/material_in_storage, mob/user)
		if (src.mode != MODE_READY)
			src.grump_message(user, "ERROR: Cannot eject materials while the unit is working.", sound = TRUE)
		else if (isnull(material_in_storage))
			src.grump_message(user, "ERROR: Cannot find material in storage. Aborting.", sound = TRUE)
		else if (material_in_storage.amount < 1)
			src.grump_message(user, "ERROR: Not enough material to eject whole amounts of bars.", sound = TRUE)
		else if (!src.check_physical_proximity(user))
			src.grump_message(user, "You have to be able to take that out yourself, you can't reach the bars from here!", sound = TRUE)
		else
			return TRUE
		return FALSE

	/// Scan in some supposed card into the machine, prompting the usr for a PIN. Returns TRUE if we managed to scan the card.
	proc/scan_card(obj/item/I)
		var/obj/item/card/id/ID = get_id_card(I)
		if (!istype(ID))
			src.grump_message(usr, "You need to be holding an ID or something with an ID to scan it in!", sound = TRUE)
			return
		boutput(usr, SPAN_NOTICE("You swipe the ID card in the card reader."))
		var/datum/db_record/bank_account = FindBankAccountByName(ID.registered)
		if(!bank_account)
			src.grump_message(usr, "No bank account associated with this ID found.")
			return
		var/enterpin = usr.enter_pin("Card Reader")
		if (enterpin != ID.pin)
			src.grump_message(usr, "PIN incorrect.")
			return
		boutput(usr, SPAN_NOTICE("Card authorized."))
		src.account = bank_account
		return TRUE

	/// Get the relevant bank record data from the current account. Returns null if there's no account scanned yet
	proc/get_bank_data()
		if (!src.account)
			return
		var/list/bank_info = list()
		var/list/keys_of_interest = list("name", "current_money")
		for (var/key in keys_of_interest)
			bank_info[key] = src.account.get_field(key)
		return bank_info

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, SPAN_ALERT("Only living mobs are able to set the manufacturer's output target."))
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, SPAN_ALERT("The manufacturing unit is too far away from the target!"))
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, SPAN_ALERT("You are too far away from the target!"))
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable crate as an output target."))
			else
				src.output_target = over_object
				boutput(usr, SPAN_NOTICE("You set the manufacturer to output to [over_object]!"))

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable cart as an output target."))
			else
				src.output_target = over_object
				boutput(usr, SPAN_NOTICE("You set the manufacturer to output to [over_object]!"))

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, SPAN_NOTICE("You set the manufacturer to output on top of [O]!"))

		else if (istype(over_object,/turf/simulated/floor/) || istype(over_object,/turf/unsimulated/floor/))
			src.output_target = over_object
			boutput(usr, SPAN_NOTICE("You set the manufacturer to output to [over_object]!"))

		else
			boutput(usr, SPAN_ALERT("You can't use that as an output target."))
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user)
		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, SPAN_ALERT("Only living mobs are able to use the manufacturer's quick-load feature."))
			return

		if (!istype(O,/obj/))
			boutput(user, SPAN_ALERT("You can't quick-load that."))
			return

		if(BOUNDS_DIST(O, user) > 0)
			boutput(user, SPAN_ALERT("You are too far away!"))
			return


		if (istype(O, /obj/item/paper/manufacturer_blueprint))
			src.Attackby(O, user)

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/) && src.accept_loading(user,1))
			if (O:welded || O:locked)
				boutput(user, SPAN_ALERT("You cannot load from a container that cannot open!"))
				return

			user.visible_message(SPAN_NOTICE("[user] uses [src]'s automatic loader on [O]!"), SPAN_NOTICE("You use [src]'s automatic loader on [O]."))
			var/amtload = 0
			for (var/obj/item/M in O.contents)
				if (!istype(M,src.base_material_class))
					continue
				src.get_contents() // Ensure contents exist first
				src.add_contents(M, user)
				amtload++
			if (amtload) boutput(user, SPAN_NOTICE("[amtload] materials loaded from [O]!"))
			else boutput(user, SPAN_ALERT("No material loaded!"))

		else if (isitem(O) && src.accept_loading(user,1))
			user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing materials into [src]!"))
			var/staystill = user.loc
			for(var/obj/item/M in view(1,user))
				if (!O || QDELETED(M) || !isturf(M.loc))
					continue
				if (!istype(M,O.type))
					continue
				if (!istype(M,src.base_material_class))
					continue
				if (O.loc == user)
					continue
				src.add_contents(M, user)
				sleep(0.5)
				if (user.loc != staystill) break
			boutput(user, SPAN_NOTICE("You finish stuffing materials into [src]!"))

		else ..()

	receive_signal(datum/signal/signal)
		if (!signal || signal.encryption || signal.transmission_method != TRANSMISSION_WIRE)
			return

		var/sender = signal.data["sender"]
		if (!sender) // important for replies etc.
			return

		var/address = signal.data["address_1"]
		if (address != src.net_id) // ping or they're not talking to us entirely
			if (address == "ping")
				var/list/ping_data = list()
				ping_data["address_1"] = sender
				ping_data["netid"] = src.net_id
				ping_data["sender"] = src.net_id
				ping_data["command"] = "ping_reply"
				ping_data["device"] = src.device_tag
				post_signal(ping_data)

			return

		var/command = signal.data["command"]
		if (!command) // not telling us to do anything
			return

		switch(command)
			if ("help")
				var/list/help = list()
				help["address_1"] = sender
				help["sender"] = src.net_id
				if (!signal.data["topic"])
					help["description"] = "[src.name] - Allows the manufacturing of various goods"
					help["topics"] = "status,queue,add,remove,clear,speed,resume,pause,repeat"

				else
					switch (signal.data["topic"])
						if ("status")
							help["description"] = "Returns data about the manufacturers current state."

						if ("queue")
							help["description"] = "Returns the manufacturers entire queue."

						if ("add")
							help["description"] = "Appends the item with the corresponding name to the queue."
							help["args"] = "data"

						if ("remove")
							help["description"] = "Removes the item at the corresponding index."
							help["args"] = "data"

						if ("clear")
							help["description"] = "Clears the entire queue."

						if ("speed")
							help["description"] = "Sets the manufacturers speed to the included state."
							help["args"] = "data"

						if ("resume")
							help["description"] = "Resumes building the current item."

						if ("pause")
							help["description"] = "Pauses bulding the current item."

						if ("repeat")
							help["description"] = "Sets whether or not the manufacturer is repeating building the current item based on the included state."
							help["args"] = "data"

				post_signal(help)
				return

			if ("status")
				post_signal(list("address_1" = sender, "sender" = src.net_id, "data" = "mode=[src.mode]&speed=[src.speed]&timeleft=[src.time_left]&repeat=[src.repeat]"))
				return

			if ("queue")
				post_signal(list("address_1" = sender, "sender" = src.net_id, "data" = src.queue.Join(",")))
				return

			if ("add")
				var/item_name = signal.data["data"]
				if (!item_name)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#BADITEMNAME"))
					return

				var/datum/manufacture/item_bp
				for (var/datum/manufacture/bp in src.available + src.download + src.drive_recipes + (src.hacked ? src.hidden : null))
					if (bp.name == item_name)
						item_bp = bp
						break

				if (!item_bp)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#NOITEMBLUEPRINT"))
					return
				// We do this here instead of on New() as a tiny optimization to keep some overhead off of map load - Also required for packets
				if (length(free_resources) > 0)
					claim_free_resources()

				if (!check_enough_materials(item_bp))
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#NOMATERIALS"))
					return

				else if (length(src.queue) >= MAX_QUEUE_LENGTH)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#QUEUEFULL"))
					return

				else
					src.queue += item_bp
					src.begin_work( new_production = TRUE )
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#APPENDED"))

			if ("clear")
				var/queue_length = length(src.queue)
				if (queue_length < 1) // Nothing in list
					return
				src.queue = list()

				if (length(src.queue) < 1)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#CLEARED"))

				else
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#WORKING"))

			if ("remove")
				var/operation = text2num_safe(signal.data["data"])
				if (!isnum(operation) || length(src.queue) < 1 || operation > length(src.queue))
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#BADOPERATION"))
					return

				if(ON_COOLDOWN(src, "remove", 1 SECOND))
					return

				src.queue -= src.queue[operation]
				begin_work( new_production = FALSE )
				post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#REMOVED"))

			if ("resume")
				if (length(src.queue) < 1)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#NOQUEUE"))
					return

				if (!check_enough_materials(src.queue[1]))
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#NOMATERIALS"))
					return

				else
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#RESUMED"))
					src.begin_work( new_production = FALSE )

			if ("pause")
				src.mode = MODE_HALT
				src.build_icon()
				if (src.action_bar)
					src.action_bar.interrupt(INTERRUPT_ALWAYS)

				post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#PAUSED"))

			if ("repeat")
				if (!signal.data["data"])
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#BADSTATE"))
					return

				var/state = text2num_safe(signal.data["data"])
				if (isnull(state))
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#BADSTATE"))
					return

				if (state)
					src.repeat = TRUE
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#REPEAT"))

				else
					src.repeat = FALSE
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#NOREPEAT"))

			if ("speed")
				var/upperbound = src.hacked ? MAX_SPEED_HACKED : MAX_SPEED
				var/given_speed = text2num(signal.data["data"])
				if (src.mode == MODE_WORKING)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#WORKING"))
					return

				if (isnull(given_speed) || given_speed < 1 || given_speed > upperbound)
					post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ERR#BADSPEED"))
					return

				src.speed = given_speed
				post_signal(list("address_1" = sender, "sender" = src.net_id, "command" = "term_message", "data" = "ACK#SPEEDSET"))

	proc/post_signal(var/list/data)
		var/datum/signal/new_signal = get_free_signal()
		new_signal.source = src
		new_signal.transmission_method = TRANSMISSION_WIRE
		new_signal.data = data
		src.link.post_signal(src, new_signal)

	proc/accept_loading(mob/user,allow_silicon)
		if (!user)
			return FALSE
		if (src.is_disabled())
			return FALSE
		if (src.dismantle_stage > DISMANTLE_NONE)
			return FALSE
		if (!isliving(user))
			return FALSE
		if (issilicon(user) && !allow_silicon)
			return FALSE
		var/mob/living/L = user
		if (L.stat || L.transforming)
			return FALSE
		return TRUE

	proc/cut(mob/user, wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires &= ~wireFlag
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = FALSE
			if(WIRE_SHOCK)
				src.time_left_electrified = 0
			if(WIRE_MALF)
				src.malfunction = TRUE
			if(WIRE_POWER)
				if(!src.is_disabled())
					src.shock(user, 100)
				src.power_wire_cut = TRUE
				src.check_power_status()

	proc/mend(mob/user, wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires |= wireFlag
		switch(wireIndex)
			if(WIRE_SHOCK)
				src.time_left_electrified = 0
			if(WIRE_MALF)
				src.malfunction = FALSE
			if(WIRE_POWER)
				src.power_wire_cut = FALSE
				src.check_power_status()
				if (!(src.status & BROKEN) && (src.status & NOPOWER))
					src.shock(user, 100)

	proc/pulse(mob/user, wireColor)
		var/wireIndex = APCWireColorToIndex[wireColor]
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = !src.hacked
			if (WIRE_SHOCK)
				src.time_left_electrified = 30
			if (WIRE_MALF)
				src.malfunction = !src.malfunction
			if (WIRE_POWER)
				if(!src.is_disabled())
					src.shock(user, 100)

	proc/shock(mob/user, prb)
		if(src.status & (BROKEN|NOPOWER))
			return FALSE

		var/netnum = FALSE
		for(var/turf/T in range(1, user))
			for(var/obj/cable/C in T.contents)
				netnum = C.netnum
				break
			if (netnum)
				break

		if (!netnum)
			return FALSE
		if (!IN_RANGE(src, user, 2))
			return FALSE
		if (src.electrocute(user,prb,netnum))
			return TRUE
		else
			return FALSE

	proc/add_schematic(schematic_path, add_to_list = "available")
		if (!ispath(schematic_path))
			return

		var/datum/manufacture/S = get_schematic_from_path(schematic_path)
		if (!istype(S,/datum/manufacture/))
			return

		switch(add_to_list)
			if ("hidden")
				src.hidden += S
			if ("download")
				src.download += S
			else
				src.available += S

	proc/set_up_schematics()
		for (var/X in src.available)
			if (ispath(X))
				src.add_schematic(X)
				src.available -= X

		for (var/X in src.hidden)
			if (ispath(X))
				src.add_schematic(X,"hidden")
				src.hidden -= X

	/// Get a list of the patterns a material satisfies. Does not include "ALL" in list, as it is assumed such a requirement is handled separately.
	/// Includes all previous material tier strings for simple "x in y" checks, as well as material ID for those recipies which need exact mat.
	proc/get_requirements_material_satisfies(datum/material/M)
		. = list()
		for (var/R_id as anything in requirement_cache)
			var/datum/manufacturing_requirement/R = getManufacturingRequirement(R_id)
			if (R.is_match(M))
				. += R.getID()

	/// Returns material which matches ref from storage, else returns null
	proc/get_material_by_ref(var/mat_ref)
		for (var/obj/item/material_piece/P as anything in src.get_contents())
			if ("\ref[P]" == mat_ref)
				return P
		return null

	/// Returns associative list of manufacturing requirement to material piece references, but does not guarantee all item_paths are satisfied or that
	/// the blueprint will have the required materials ready by the time it reaches the front of the queue. Reqs not satisfied are not added to mats_used
	proc/get_materials_needed(datum/manufacture/M)
		var/list/mats_used = list()
		var/list/mats_reserved = list()

		for (var/datum/manufacturing_requirement/R as anything in M.item_requirements)
			var/piece_ref = src.get_material_for_requirement(R, M.item_requirements[R], mats_reserved)
			if (!isnull(piece_ref))
				mats_used[R] = piece_ref

		return mats_used

	/// Get the material in storage which satisfies some amount of a requirement.
	proc/get_material_for_requirement(datum/manufacturing_requirement/R, var/required_amount, var/list/mats_reserved)
		var/list/C = src.get_contents()
		for (var/obj/item/material_piece/P as anything in C)
			if (!R.is_match(P.material))
				continue
			// We can use this material! Get the amount of free material and reserve/mark as used whatever is free.
			var/P_ref = "\ref[P]"
			var/amount_free = P.amount - mats_reserved[P_ref]
			var/amount_to_use = min(amount_free, required_amount / 10)
			if ((amount_to_use * 10) < required_amount)
				continue
			mats_reserved[P_ref] ||= 0
			mats_reserved[P_ref] += amount_to_use
			return P_ref

	/// Check if a blueprint can be manufactured with the current materials.
	/// mats_used - a list from get_materials_needed to avoid calling the proc twice
	proc/check_enough_materials(datum/manufacture/M, var/list/mats_used = null)
		if (isnull(mats_used))
			mats_used = get_materials_needed(M)
		return length(mats_used) == length(M.item_requirements)

	/// Go through the material requirements of a blueprint, removing the respective used materials
	proc/remove_materials(datum/manufacture/M)
		var/list/mats_used = get_materials_needed(M)
		for (var/datum/manufacturing_requirement/R as anything in M.item_requirements)
			var/required_amount = M.item_requirements[R]
			for (var/obj/item/material_piece/P as anything in src.get_contents())
				if ("\ref[P]" != mats_used[R])
					continue
				P.amount = round( (P.amount - (required_amount/10)), 0.1)
				if (P.amount <= 0)
					qdel(P)

	/// Get how many more times a drive can produce items it is stocked with
	proc/get_drive_uses_left()
		if(src.manudrive)
			if (src.manudrive.fablimit == -1)
				return -1 // Represents unlimited with manudrives, we roll with it
			for (var/datum/computer/file/manudrive/MD in src.manudrive.root.contents)
				if(!isnull(MD.num_working))
					return MD.fablimit - MD.num_working
		return 0 // none loaded

	proc/begin_work(new_production = TRUE)
		src.error = null
		if (status & NOPOWER || status & BROKEN)
			return
		if (!length(src.queue))
			src.mode = MODE_READY
			src.build_icon()
			return
		if (!istype(src.queue[1],/datum/manufacture/))
			src.mode = MODE_HALT
			src.error = "Corrupted entry purged from production queue."
			src.queue -= src.queue[1]
			src.visible_message(SPAN_ALERT("[src] emits an angry buzz!"))
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()
			return
		var/datum/manufacture/M = src.queue[1]
		//Wire: Fix for href exploit creating arbitrary items
		if (!(M in ALL_BLUEPRINTS) || (!src.hacked && (M in src.hidden)))
			src.mode = MODE_HALT
			src.error = "Corrupted entry purged from production queue."
			src.queue -= src.queue[1]
			src.visible_message(SPAN_ALERT("[src] emits an angry buzz!"))
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()
			return

		if (src.malfunction && prob(40))
			src.flip_out()
		if (new_production)
			var/list/mats_used = get_materials_needed(M)
			if (!(length(mats_used) == length(M.item_requirements)))
				src.mode = MODE_HALT
				src.error = "Insufficient usable materials to continue queue production."
				src.visible_message(SPAN_ALERT("[src] emits an angry buzz!"))
				playsound(src.loc, src.sound_grump, 50, 1)
				src.build_icon()
				return

			// speed/power usage
			// spd   time    new     old (1500 * speed * 1.5)
			// 1:    10.0s     750   2250
			// 2:     5.0s    3000   4500
			// 3:     3.3s    6750   6750
			// 4:     2.5s   12000   9000
			// 5:     2.0s   18750  11250
			src.active_power_consumption = 750 * src.speed ** 2
			// new item began fabrication, setup time variables
			if (new_production)
				src.time_left = M.time
				src.time_started = TIME
				if (src.malfunction)
					src.active_power_consumption += 3000
					src.time_left += rand(2,6)
					src.time_left *= 1.5
				src.time_left /= src.speed
				src.original_duration = src.time_left

		var/datum/computer/file/manudrive/manudrive_file = null
		if(src.manudrive)
			if(src.queue[1] in src.drive_recipes)
				var/obj/item/disk/data/floppy/manudrive/ManuD = src.manudrive
				for (var/datum/computer/file/manudrive/MD in ManuD.root.contents)
					if(MD.fablimit != -1 && MD.fablimit - MD.num_working <= 0)
						src.mode = MODE_READY
						playsound(src.loc, src.sound_grump, 50, 1)
						src.error = "The inserted ManuDrive is unable to operate further."
						src.visible_message(SPAN_ALERT("[src] emits an angry buzz!"))
						src.queue = list()
						return
					else
						MD.num_working++
					manudrive_file = MD

		playsound(src.loc, src.sound_beginwork, 50, 1, 0, 3)
		src.mode = MODE_WORKING
		src.build_icon()

		src.action_bar = actions.start(new/datum/action/bar/manufacturer(src, src.time_left, manudrive_file), src)


	proc/output_loop(datum/manufacture/M)

		if (!istype(M,/datum/manufacture/))
			return

		if (length(M.item_outputs) <= 0)
			return
		var/list/materials_used = src.get_materials_needed(M)
		if(src.check_enough_materials(M, materials_used))
			var/make = clamp(M.create, 0, src.output_cap)
			switch(M.randomise_output)
				if(1) // pick a new item each loop
					while (make > 0)
						src.dispense_product(pick(M.item_outputs), M, materials_used)
						make--
				if(2) // get a random item from the list and produce it
					var/to_make = pick(M.item_outputs)
					while (make > 0)
						src.dispense_product(to_make, M, materials_used)
						make--
				else // produce every item in the list once per loop
					while (make > 0)
						for (var/X in M.item_outputs)
							src.dispense_product(X, M, materials_used)
						make--

			src.remove_materials(M)
		else
			src.mode = MODE_HALT
			src.error = "Insufficient usable materials to continue queue production."
			src.visible_message(SPAN_ALERT("[src] emits an angry buzz!"))
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()

		return

	proc/dispense_product(product, datum/manufacture/M, var/list/materials_used)
		var/atom/movable/A
		if (ispath(product))
			if (istype(M,/datum/manufacture/))
				A = new product(src)
				if (isitem(A))
					var/obj/item/I = A
					M.modify_output(src, I, materials_used)
					I.set_loc(src.get_output_location(I))
				else
					A.set_loc(src.get_output_location(A))
			else
				A = new product(get_output_location())

		else if (istext(product) || isnum(product))
			if (istext(product) && copytext(product,1,8) == "reagent")
				var/the_reagent = copytext(product,9,length(product) + 1)
				if (M.create != 0)
					src.reagents.add_reagent(the_reagent,M.create / 10)
			else
				src.visible_message("<b>[src]</b> says, \"[product]\"")

		else if (isicon(product)) // adapted from vending machine code
			var/icon/welp = icon(product)
			if (welp.Width() > 32 || welp.Height() > 32)
				welp.Scale(32, 32)
				product = welp
			A = new /obj/item(get_turf(src))
			A.name = "strange thing"
			A.desc = "The fuck is this?"
			A.icon = welp
		else if (isfile(product)) // adapted from vending machine code
			var/S = sound(product)
			if (S)
				playsound(src.loc, S, 50, 0)

		else if (isobj(product) || ismob(product))
			A = product
			A.set_loc(get_output_location())

		return A

	proc/flip_out()
		if (status & BROKEN || status & NOPOWER || !src.malfunction)
			return
		animate_shake(src,5,rand(3,8),rand(3,8))
		src.visible_message(SPAN_ALERT("[src] makes [pick(src.text_flipout_adjective)] [pick(src.text_flipout_noun)]!"))
		playsound(src.loc, pick(src.sounds_malfunction), 50, 2)
		if (prob(15) && length(src.get_contents()) > 4 && src.mode != MODE_WORKING)
			var/to_throw = rand(1,4)
			var/obj/item/X = null
			while(to_throw > 0)
				if(!length(src.nearby_turfs)) //SpyGuy for RTE "pick() from empty list"
					break
				X = pick(src.get_contents())
				src.storage.transfer_stored_item(X, src.loc)
				X.throw_at(pick(src.nearby_turfs), 16, 3)
				to_throw--
		if (length(src.queue) > 1 && prob(20))
			var/list_counter = 0
			for (var/datum/manufacture/X in src.queue)
				list_counter++
				if (list_counter == 1)
					continue
				if (prob(33))
					src.queue -= X
		if (src.mode == MODE_WORKING)
			if (prob(5))
				src.mode = MODE_HALT
				src.build_icon()
			else
				if (prob(10))
					src.active_power_consumption *= 2
		if (prob(10))
			src.speed = rand(MIN_SPEED, MAX_SPEED_DAMAGED)
		if (prob(5))
			if (!src.is_electrified())
				src.time_left_electrified = 5

	proc/build_icon()
		icon_state = "fab[src.icon_base ? "-[src.icon_base]" : null]"

		if (status & BROKEN)
			src.UpdateOverlays(null, "work")
			src.UpdateOverlays(null, "activity")
			icon_state = "[src.icon_base]-broken"
		else if (src.dismantle_stage >= DISMANTLE_PLATING_SHEETS)
			src.UpdateOverlays(null, "work")
			src.UpdateOverlays(null, "activity")
			icon_state = "fab-noplate"

		if (!(status & NOPOWER) && !(status & BROKEN))
			if (src.malfunction && prob(50))
				switch  (rand(1,4))
					if (1) src.activity_display.icon_state = "light-ready"
					if (2) src.activity_display.icon_state = "light-halt"
					if (3) src.activity_display.icon_state = "light-working"
					else src.activity_display.icon_state = "light-malf"
			else
				src.activity_display.icon_state = "light-[src.mode]"

			var/animspeed = src.speed
			if (animspeed < 1 || animspeed > 5 || (src.malfunction && prob(50)))
				animspeed = "malf"

			if (src.mode == MODE_WORKING)
				src.work_display.icon_state = "fab-work[animspeed]"
			else
				src.work_display.icon_state = ""

			src.UpdateOverlays(src.work_display, "work")
			src.UpdateOverlays(src.activity_display, "activity")

		if (src.panel_open)
			src.panel_sprite.icon_state = "fab-panel"
			src.UpdateOverlays(src.panel_sprite, "panel")
		else
			src.UpdateOverlays(null, "panel")

	proc/eject_manudrive(mob/living/user)
		src.drive_recipes = null
		if (GET_DIST(user, src) <= 1)
			user.put_in_hand_or_drop(manudrive)
		else
			manudrive.set_loc(src.loc)
		src.manudrive = null
		should_update_static = TRUE

	proc/ensure_contents()
		if (isnull(src.storage))
			src.create_storage(/datum/storage/no_hud/machine, can_hold=list(/obj/item/material_piece), slots = INFINITY)

	proc/add_contents(obj/item/W, mob/user = null)
		src.ensure_contents()
		src.storage.add_contents(W, user, visible=FALSE)

	/// Safely gets our storage contents. In case someone does something like load materials into the machine before we have initialized our storage
	/// Also ejects things w/o material or that aren't pieces, to ensure safety
	proc/get_contents()
		src.ensure_contents()
		var/list/storage_contents = src.storage.get_contents()
		for (var/obj/item/I as anything in storage_contents)
			if (!istype(I, /obj/item/material_piece) || isnull(I.material))
				// Invalid thing somehow, fuck
				src.storage.transfer_stored_item(I, src.loc)
		return storage_contents

	on_add_contents(obj/item/I)
		if (!("\ref[I.material]" in src.material_patterns_by_ref))
			src.material_patterns_by_ref["\ref[I.material]"] = src.get_requirements_material_satisfies(I.material)

	proc/take_damage(damage_amount = 0)
		if (!damage_amount)
			return
		src.health = clamp(src.health - damage_amount, 0, 100)
		if (damage_amount > 0)
			playsound(src.loc, src.sound_damaged, 50, 2)
			if (src.health == 0)
				src.visible_message(SPAN_ALERT("<b>[src] is destroyed!</b>"))
				playsound(src.loc, src.sound_destroyed, 50, 2)
				robogibs(src.loc)
				qdel(src)
				return
			if (src.health <= 70 && !src.malfunction && prob(33))
				src.malfunction = TRUE
				src.flip_out()
			if (src.malfunction && prob(40))
				src.flip_out()
			if (src.health <= 25 && !(src.status & BROKEN))
				src.visible_message(SPAN_ALERT("<b>[src] breaks down and stops working!</b>"))
				src.status |= BROKEN
		else
			if (src.health >= 60 && src.status & BROKEN)
				src.visible_message(SPAN_ALERT("<b>[src] looks like it can function again!</b>"))
				status &= ~BROKEN

		src.build_icon()

	/// Adds the resources we define in free_resources to our storage, and clears the list when we're done
	/// to represent we do not have more resources to claim
	proc/claim_free_resources()
		if (src.deconstruct_flags & DECON_BUILT)
			free_resources = list()
			return

		src.get_contents() // potentially load storage datum if it doesnt exist yet
		for (var/mat_path in src.free_resources)
			var/obj/item/material_piece/P = new mat_path
			P.amount = src.free_resources[mat_path]
			src.add_contents(P)

		free_resources = list()

	proc/get_output_location(atom/A)
		if (!src.output_target)
			return src.loc

		if (BOUNDS_DIST(src.output_target, src) > 0)
			src.output_target = null
			return src.loc

		if (istype(src.output_target,/obj/storage/crate/))
			var/obj/storage/crate/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C
		if (istype(src.output_target,/obj/storage/cart/))
			var/obj/storage/cart/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C
		else if (istype(src.output_target,/obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = src.output_target
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > DISMANTLE_NONE)
				src.output_target = null
				return src.loc
			if (A && istype(A,M.base_material_class))
				return M
			else
				return M.loc

		else if (istype(src.output_target,/turf/simulated/floor/) || istype(src.output_target,/turf/unsimulated/floor/))
			return src.output_target

		else
			return src.loc

	proc/check_power_status()
		if (src.powered() && !src.power_wire_cut && src.dismantle_stage <= 2)
			src.status &= ~NOPOWER
		else
			src.status |= NOPOWER

/datum/action/bar/manufacturer
	duration = 100 SECONDS
	var/obj/machinery/manufacturer/MA
	var/completed = FALSE
	var/datum/computer/file/manudrive/manudrive_file

	New(machine, dur, datum/computer/file/manudrive/manudrive_file)
		MA = machine
		duration = dur
		src.manudrive_file = manudrive_file
		..()

	onUpdate()
		..()
		if (MA.malfunction && prob(8))
			MA.flip_out()

		if (MA.status & (NOPOWER | BROKEN))
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt()
		..()
		MA.time_left = src.duration - (TIME - src.started)
		MA.error = null
		MA.mode = MODE_READY
		MA.build_icon()
		if(src.manudrive_file)
			src.manudrive_file.num_working--
			if(src.manudrive_file.num_working < 0)
				CRASH("Manudrive num_working negative.")

	onEnd()
		..()
		src.completed = TRUE
		if(src.manudrive_file)
			src.manudrive_file.num_working--
			if(src.manudrive_file.num_working < 0)
				CRASH("Manudrive num_working negative.")
			if(src.manudrive_file.fablimit == 0)
				CRASH("Manudrive fablimit 0.")
			else if(src.manudrive_file.fablimit > 0)
				src.manudrive_file.fablimit--
		MA.finish_work()
		// call dispense

	onDelete()
		..()
		MA.action_bar = null
		if (src.completed && length(MA.queue))
			SPAWN(0.1 SECONDS)
				MA.begin_work(TRUE)

/// Pre-build the icons for things manufacturers make
/proc/build_manufacturer_icons()
	for (var/datum/manufacture/P as anything in concrete_typesof(/datum/manufacture, FALSE))
		if (ispath(P, /datum/manufacture/mechanics))
			var/datum/manufacture/mechanics/M = P
			if (!initial(M.frame_path))
				continue
			getItemIcon(initial(M.frame_path))

		else
			// temporarily create this so we can get the list from it
			// i tried very hard to use initial() here and got nowhere,
			// but the fact it's a list seems to not really go well with it
			// maybe someone else can get it to work.
			var/datum/manufacture/I = new P
			if (I && length(I.item_outputs) && I.item_outputs[1])
				getItemIcon(I.item_outputs[1])

#undef MAX_QUEUE_LENGTH
#undef DISMANTLE_NONE
#undef DISMANTLE_PLATING_BOLTS
#undef DISMANTLE_PLATING_SHEETS
#undef DISMANTLE_WIRES
#undef WIRE_EXTEND
#undef WIRE_POWER
#undef WIRE_MALF
#undef WIRE_SHOCK
#undef MODE_READY
#undef MODE_WORKING
#undef MODE_HALT
#undef MIN_SPEED
#undef DEFAULT_SPEED
#undef MAX_SPEED
#undef MAX_SPEED_HACKED
#undef MAX_SPEED_DAMAGED
#undef ALL_BLUEPRINTS
#undef ORE_TAX
