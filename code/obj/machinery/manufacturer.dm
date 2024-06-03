#define MAX_QUEUE_LENGTH 20 //! maximum amount of blueprints which may be queued for printing
#define WIRE_EXTEND 1 //! wire which reveals blueprints in the "hidden" type
#define WIRE_POWER 2 //! wire which can disable machine power
#define WIRE_MALF 3 //! wire which causes machine to malfunction
#define WIRE_SHOCK 4 //! this wire is in the machine specifically to shock curious staff assistants
#define MODE_READY "ready" //! machine is ready to produce more things
#define MODE_WORKING "working" //! machine is making some things
#define MODE_HALT "halt" //! machine had to stop making things or couldnt due to some problem that occured
#define MIN_SPEED 1 //! lowest speed fabricator can function at
#define DEFAULT_SPEED 3 //! speed which manufacturers run at by default
#define MAX_SPEED 3 //! maximum speed default manufacturers can be set to
#define MAX_SPEED_HACKED 5 //! maximum speed manufacturers which are hacked (WIRE_EXTEND has been pulsed) can be set to
#define MAX_SPEED_DAMAGED 8 //! maximum speed that fabricators which flip_out() can be set to, randomly.
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
	// req_access is used to lock out specific featurs and not limit deconstruciton therefore DECON_NO_ACCESS is required
	req_access = list(access_heads)
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_NO_ACCESS
	flags = NOSPLASH | FLUID_SUBMERGE
	layer = STORAGE_LAYER
	// General stuff
	var/health = 100
	var/supplemental_desc = null //! appended in get_desc() to the base description, to make subtype definitions cleaner
	var/mode = MODE_READY //! the current status of the machine. Ready, working, or halt are all modes used currently.
	var/error = null
	var/active_power_consumption = 0 //! How much power is consumed while active? This is determined automatically when the unit starts a production cycle
	var/panel_open = FALSE
	var/dismantle_stage = 0
	var/hacked = FALSE
	var/malfunction = FALSE
	var/power_wire_cut = FALSE
	var/electrified = 0 //! This is a timer and not a true/false; it's decremented every process() tick
	var/output_target = null
	var/list/nearby_turfs = list()
	var/wires = 15 //! This is a bitflag used to track wire states, for hacking and such. Replace it with something cleaner if an option exists when you're reading this :p
	var/output_message_user = null //! Used as a cache when outputting messages to users
	var/frequency = FREQ_PDA
	var/net_id = null
	var/device_tag = "PNET_MANUFACTURER"
	var/obj/machinery/power/data_terminal/link = null
	var/datum/db_record/account = null //! Used when deducting payment for ores from a Rockbox

	// Printing and queues
	var/original_duration = 0 //! duration of the currently queued print, used to keep track of progress when M.time gets modified weirdly in queueing
	var/time_left = 0 //! time the current blueprint will take to manufacture
	var/time_started = 0 //! time the last blueprint was queued
	var/speed = DEFAULT_SPEED
	var/repeat = FALSE
	var/manual_stop = FALSE
	var/output_cap = 20
	var/list/queue = list()

	// Resources/materials
	var/base_material_class = /obj/item/material_piece //! Base class for material pieces that the manufacturer accepts. Keep this as material pieces only unless you're making larger changes to the system
	var/obj/item/disk/data/floppy/manudrive/manudrive = null
	/// Associated list of material ID strings to amount (in bars) to add to the manufacturer.
	var/list/free_resources = list()
	var/list/materials_in_use = list()
	var/should_update_static = TRUE //! true by default to update first time around, set to true whenever something is done that invalidates static data
	var/list/material_patterns_by_ref = list() //! Helper list which stores all the material patterns each loaded material satisfies, by ref to the piece

	// Production options
	var/search = null
	var/category = null
	var/list/categories = list("Tool", "Clothing", "Resource", "Component", "Machinery", "Medicine", "Miscellaneous", "Downloaded")
	var/accept_blueprints = TRUE
	var/list/available = list() //! A list of every option available in this unit subtype by default
	var/list/download = list() //! Options gained from scanned blueprints
	var/list/drive_recipes = list() //! Options provided by an inserted manudrive
	var/list/hidden = list() //! These options are available by default, but can't be printed unless the machine is hacked

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
			if(1)
				. += "<br>[SPAN_ALERT("It's partially dismantled. To deconstruct it, use a crowbar. To repair it, use a wrench.")]"
			if(2)
				. += "<br>[SPAN_ALERT("It's partially dismantled. To deconstruct it, use wirecutters. To repair it, add reinforced metal.")]"
			if(3)
				. += "<br>[SPAN_ALERT("It's partially dismantled. To deconstruct it, use a wrench. To repair it, add some cable.")]"

	process(mult)
		if (status & NOPOWER)
			return

		..()

		if (src.mode == MODE_WORKING)
			use_power(src.active_power_consumption)

		if (src.electrified > 0)
			src.electrified--
		/*
		if (src.mode == MODE_WORKING)
			if (src.malfunction && prob(8))
				src.flip_out()
			src.time_left -= src.speed * 4.4 * mult
			use_power(src.active_power_consumption)
			if (src.time_left < 1)
				src.output_loop(src.queue[1])
				SPAWN(0)
					if (length(src.queue) < 1)
						src.manual_stop = 0
						playsound(src.loc, src.sound_happy, 50, 1)
						src.visible_message(SPAN_NOTICE("[src] finishes its production queue."))
						src.mode = MODE_READY
						src.build_icon()
		*/

	proc/finish_work()
		if(length(src.queue))
			output_loop(src.queue[1])
			if (!src.repeat)
				src.queue -= src.queue[1]

		if (length(src.queue) < 1)
			src.manual_stop = 0
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
		if(src.is_broken())
			src.build_icon()
		else
			if(src.powered() && src.dismantle_stage < 3)
				src.check_power_status()
				src.build_icon()
			else
				SPAWN(rand(0, 15))
					src.check_power_status()
					src.build_icon()

	// Overriden to not disable if no power, wire maintenence to restore power is on the GUI which creates catch-22 situation
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

		// Send material data as tuples of material name, material id, material amount
		var/resource_data = list()
		for (var/obj/item/material_piece/P as anything in src.get_contents())
			if (!P.material)
				continue
			resource_data += list(list("name" = P.material.getName(), "id" = P.material.getID(), "amount" = P.amount, "byondRef" = "\ref[P]", "satisfies" = src.material_patterns_by_ref["\ref[P]"]))

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
			"manudrive_uses_left" = src.get_drive_uses_left(),
			"indicators" = list("electrified" = src.electrified,
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
	proc/blueprints_as_list	(var/list/L, mob/user, var/static_elements = FALSE)
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
				M.item_names += R.name

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
			requirement_data += list(list("name" = R.name, "id" = R.id, "amount" = M.item_requirements[R]))

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

	attack_hand(mob/user)
		// We do this here instead of on New() as a tiny optimization to keep some overhead off of map load
		if (length(free_resources) > 0)
			claim_free_resources()
		if(src.electrified)
			if (!(status & NOPOWER || status & BROKEN))
				if (src.shock(user, 33))
					return
		src.ui_interact(user)

	proc/validate_disp(datum/manufacture/M)
		. = FALSE
		if(src.available && (M in src.available))
			return TRUE

		if(src.download && (M in src.download))
			return TRUE

		if(src.drive_recipes && (M in src.drive_recipes))
			return TRUE

		if(src.hacked && src.hidden && (M in src.hidden))
			return TRUE

	/// Clear src.queue but not the current working print if it exists
	proc/clear_queue()
		if (!length(src.queue))
			return
		src.queue = list()

	/// Try to shock the target if the machine is electrified, returns whether or not the target got shocked
	proc/try_shock(mob/target, var/chance)
		if (src.electrified)
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
		if (!isnull(message) && !isnull(target))
			boutput(target, SPAN_ALERT(message))
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
				if(!validate_disp(I))
					// Since a manufacturer may get unhacked or a downloaded item could get deleted between someone
					// opening the window and clicking the button we can't assume intent here, so no cluwne
					return
				if (!check_enough_materials(I))
					src.grump_message(usr, "Insufficient usable materials to manufacture that item.", sound = TRUE)

				else if (length(src.queue) >= MAX_QUEUE_LENGTH)
					src.grump_message(usr, "Manufacturer queue length limit reached.", sound = TRUE)
				else
					src.queue += I
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
				src.clear_queue()
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
						src.grump_message(usr, "ERROR: Could not re-validate authenticaion credentials. Aborting.", sound = TRUE)
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
		else
			src.output_message_user = null
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
							minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX&trade;-MAILBOT",  "group"=list(MGD_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [amount_per_account] credits earned from Rockbox&trade; sale, deposited to your account.")
					else
						leftovers = subtotal
						minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX&trade;-MAILBOT",  "group"=list(MGD_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [leftovers + sum_taxes] credits earned from Rockbox&trade; sale, deposited to the shipping budget.")
					wagesystem.shipping_budget += (leftovers + sum_taxes)
					SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, minerSignal)
					src.should_update_static = TRUE

					//src.output_message_user = "Enjoy your purchase!" its not grumpy but its not shown either
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

	attackby(obj/item/W, mob/user)
		if (src.electrified)
			if (src.shock(user, 33))
				return

		if (istype(W, /obj/item/ore_scoop))
			var/obj/item/ore_scoop/scoop = W
			W = scoop.satchel

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

		else if (istype(W, /obj/item/satchel))
			user.visible_message(SPAN_NOTICE("[user] uses [src]'s automatic loader on [W]!"), SPAN_NOTICE("You use [src]'s automatic loader on [W]."))
			var/amtload = 0
			for (var/obj/item/M in W.contents)
				if (!istype(M,src.base_material_class))
					continue
				src.change_contents(mat_piece = M)
				amtload++
			W:UpdateIcon()
			if (amtload) boutput(user, SPAN_NOTICE("[amtload] materials loaded from [W]!"))
			else boutput(user, SPAN_ALERT("No materials loaded!"))

		else if (isscrewingtool(W))
			if (!src.panel_open)
				src.panel_open = TRUE
			else
				src.panel_open = FALSE
			boutput(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
			src.build_icon()
			tgui_process.try_update_ui(user, src)

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
				src.change_contents(mat_piece = W, user = user)
			else
				if (src.health < 50)
					boutput(user, SPAN_ALERT("It's too badly damaged. You'll need to replace the wiring first."))
				else if(W:try_weld(user, 1))
					src.take_damage(-10)
					user.visible_message("<b>[user]</b> uses [W] to repair some of [src]'s damage.")
					if (src.health == 100)
						boutput(user, SPAN_NOTICE("<b>[src] looks fully repaired!</b>"))

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
				src.change_contents(mat_piece = C, user = user)
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
				src.change_contents(mat_piece = W, user = user)
			else
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if (src.dismantle_stage == 0)
					user.visible_message("<b>[user]</b> loosens [src]'s external plating bolts.")
					src.dismantle_stage = 1
				else if (src.dismantle_stage == 1)
					user.visible_message("<b>[user]</b> fastens [src]'s external plating bolts.")
					src.dismantle_stage = 0
				else if (src.dismantle_stage == 3)
					user.visible_message("<b>[user]</b> dismantles [src]'s mechanisms.")
					new /obj/item/sheet/steel/reinforced(src.loc)
					qdel(src)
					return
				src.build_icon()

		else if (ispryingtool(W) && src.dismantle_stage == 1)
			user.visible_message("<b>[user]</b> pries off [src]'s plating.")
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			src.dismantle_stage = 2
			new /obj/item/sheet/steel/reinforced(src.loc)
			src.build_icon()

		else if (issnippingtool(W) && src.dismantle_stage == 2)
			if (!(status & NOPOWER))
				if (src.shock(user,100))
					return
			user.visible_message("<b>[user]</b> disconnects [src]'s cabling.")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
			src.dismantle_stage = 3
			src.check_power_status()
			var/obj/item/cable_coil/C = new /obj/item/cable_coil(src.loc)
			C.amount = 1
			C.UpdateIcon()
			src.build_icon()

		else if (istype(W,/obj/item/sheet/steel/reinforced) && src.dismantle_stage == 2)
			user.visible_message("<b>[user]</b> adds plating to [src].")
			src.dismantle_stage = 1
			qdel(W)
			src.build_icon()

		else if (istype(W,/obj/item/cable_coil) && src.dismantle_stage == 3)
			user.visible_message("<b>[user]</b> adds cabling to [src].")
			src.dismantle_stage = 2
			var/obj/item/cable_coil/C = W
			C.use(1)
			src.check_power_status()
			src.shock(user,100)
			src.build_icon()

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


		else if (istype(W,/obj/item/sheet/) || (istype(W,/obj/item/cable_coil/ || (istype(W,/obj/item/raw_material/ )))))
			src.grump_message(user, "The fabricator rejects the [W]. You'll need to refine them in a reclaimer first.", sound = TRUE)
			return

		else if (istype(W, src.base_material_class) && src.accept_loading(user))
			user.visible_message(SPAN_NOTICE("[user] loads [W] into [src]."), SPAN_NOTICE("You load [W] into [src]."))
			src.change_contents(mat_piece = W, user = user)

		else if (src.panel_open && (issnippingtool(W) || ispulsingtool(W)))
			src.Attackhand(user)
			return

		else if(scan_card(W))
			return

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
				src.change_contents(mat_piece = M, user = user)
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
				src.change_contents(mat_piece = M, user = user)
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
				src.clear_queue()

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
		if (src.dismantle_stage > 0)
			return FALSE
		if (!isliving(user))
			return FALSE
		if (issilicon(user) && !allow_silicon)
			return FALSE
		var/mob/living/L = user
		if (L.stat || L.transforming)
			return FALSE
		return TRUE

	proc/isWireColorCut(wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		return ((src.wires & wireFlag) == 0)

	proc/isWireCut(wireIndex)
		var/wireFlag = APCIndexToFlag[wireIndex]
		return ((src.wires & wireFlag) == 0)

	proc/cut(mob/user, wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires &= ~wireFlag
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = FALSE
			if(WIRE_SHOCK)
				src.electrified = -1
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
				src.electrified = 0
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
				src.electrified = 30
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

	proc/match_material_pattern(pattern, datum/material/mat)
		if (!mat) // Marq fix for various cannot read null. runtimes
			return FALSE

		if (pattern == "ALL") // anything at all
			return TRUE
		if (pattern == "ORG|RUB")
			return mat.getMaterialFlags() & MATERIAL_RUBBER || mat.getMaterialFlags() & MATERIAL_ORGANIC
		if (pattern == "RUB")
			return mat.getMaterialFlags() & MATERIAL_RUBBER
		if (pattern == "WOOD")
			return mat.getMaterialFlags() & MATERIAL_WOOD
		else if (copytext(pattern, 4, 5) == "-") // wildcard
			var/firstpart = copytext(pattern, 1, 4)
			var/secondpart = text2num_safe(copytext(pattern, 5))
			switch(firstpart)
				// this was kind of thrown together in a panic when i felt shitty so if its horrible
				// go ahead and clean it up a bit
				if ("MET")

					if (mat.getMaterialFlags() & MATERIAL_METAL)
						// maux hardness = 15
						// bohr hardness = 33
						switch(secondpart)
							if(2)
								return mat.getProperty("hard") * 2 + mat.getProperty("density") >= 10
							if(3 to INFINITY)
								return mat.getProperty("hard") * 2 + mat.getProperty("density") >= 15
							else
								return TRUE
				if ("CRY")
					if (mat.getMaterialFlags() & MATERIAL_CRYSTAL)

						switch(secondpart)
							if(2)
								return mat.getProperty("density") >= 7
							else
								return TRUE
				if ("REF")
					return (mat.getProperty("reflective") >= 6)
				if ("CON")
					switch(secondpart)
						if(2)
							return (mat.getProperty("electrical") >= 8)
						else
							return (mat.getProperty("electrical") >= 6)
				if ("INS")
					switch(secondpart)
						if(2)
							return mat.getProperty("electrical") <= 2 && (mat.getMaterialFlags() & (MATERIAL_CLOTH | MATERIAL_RUBBER))
						else
							return mat.getProperty("electrical") <= 4 && (mat.getMaterialFlags() & (MATERIAL_CLOTH | MATERIAL_RUBBER))
				if ("DEN")
					switch(secondpart)
						if(2)
							return mat.getProperty("density") >= 6
						else
							return mat.getProperty("density") >= 4
				if ("POW")
					if (mat.getMaterialFlags() & MATERIAL_ENERGY)
						switch(secondpart)
							if(3)
								return mat.getProperty("radioactive") >= 5 //soulsteel and erebite basically
							if(2)
								return mat.getProperty("radioactive") >= 2
							else
								return TRUE
				if ("FAB")
					return mat.getMaterialFlags() & (MATERIAL_CLOTH | MATERIAL_RUBBER | MATERIAL_ORGANIC)
				if ("GEM")
					return istype(mat, /datum/material/crystal/gemstone)
		else if (pattern == mat.getID()) // specific material id
			return TRUE
		return FALSE

	/// Get a list of the patterns a material satisfies. Does not include "ALL" in list, as it is assumed such a requirement is handled separately.
	/// Includes all previous material tier strings for simple "x in y" checks, as well as material ID for those recipies which need exact mat.
	proc/get_requirements_material_satisfies(datum/material/M)
		. = list()
		for (var/R_id as anything in requirement_cache)
			var/datum/manufacturing_requirement/R = getRequirement(R_id)
			if (R.is_match(M))
				. += R.id

	/// Returns material in storage which first satisfies a pattern, otherwise returns null
	/// Similar to get_materials_needed, but ignores amounts and implications of choosing materials
	proc/get_material_for_pattern(var/pattern)
		var/list/C = src.get_contents()
		if (!length(C))
			return null
		if (pattern == "ALL")
			return C[1]
		for (var/piece_index in 1 to length(C))
			var/obj/item/material_piece/P = C[piece_index]
			if (pattern in src.material_patterns_by_ref["\ref[P]"])
				return P
		return null

	/// Returns material which matches ref from storage, else returns null
	proc/get_material_by_ref(var/mat_ref)
		for (var/obj/item/material_piece/P as anything in src.get_contents())
			if ("\ref[P]" == mat_ref)
				return P
		return null

	/// Returns associative list of manufacturing requirement to material piece reference, but does not guarantee all item_paths are satisfied or that
	/// the blueprint will have the required materials ready by the time it reaches the front of the queue. Mats not used are not added to the return value
	proc/get_materials_needed(datum/manufacture/M)
		var/list/C = src.get_contents()

		var/list/mats_used = list()
		var/list/mats_projected = list()
		for (var/obj/item/material_piece/P in C)
			mats_projected["\ref[P]"] = P.amount * 10

		for (var/datum/manufacturing_requirement/R as anything in M.item_requirements)
			var/required_amount = M.item_requirements[R]
			for (var/obj/item/material_piece/P in C)
				var/P_ref = "\ref[P]"
				if (mats_projected[P_ref] < required_amount)
					continue
				if (R.is_match(P.material))
					mats_used[R] = P_ref
					mats_projected[P_ref] -= required_amount
					break

		return mats_used

	/// Check if a blueprint can be manufactured with the current materials.
	proc/check_enough_materials(datum/manufacture/M)
		var/list/mats_used = get_materials_needed(M)
		if (length(mats_used) == length(M.item_requirements)) // we have enough materials, so return the materials list, else return null
			return mats_used

	/// Go through the material requirements of a blueprint, and remove the matching materials from materials_in_use in appropriate quantities
	proc/remove_materials(datum/manufacture/M)
		var/list/mats_used = check_enough_materials(M)
		if (isnull(mats_used))
			return // how
		for (var/datum/manufacturing_requirement/R as anything in M.item_requirements)
			var/required_amount = M.item_requirements[R]
			src.change_contents(-required_amount/10, mat_piece = locate(mats_used[R]))

	/// Get how many more times a drive can produce items it is stocked with
	proc/get_drive_uses_left()
		if(src.manudrive)
			if (src.manudrive.fablimit == -1)
				return -1 // Represents unlimited with manudrives, we roll with it
			for (var/datum/computer/file/manudrive/MD in src.manudrive.root.contents)
				if(!isnull(MD.num_working))
					return src.manudrive.fablimit - MD.num_working
		return 0 // none loaded

	proc/begin_work(new_production = TRUE)
		src.error = null
		if (status & NOPOWER || status & BROKEN)
			return
		if (!length(src.queue))
			src.manual_stop = 0
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
			var/list/mats_used = check_enough_materials(M)
			if (!mats_used)
				src.mode = MODE_HALT
				src.error = "Insufficient usable materials to continue queue production."
				src.visible_message(SPAN_ALERT("[src] emits an angry buzz!"))
				playsound(src.loc, src.sound_grump, 50, 1)
				src.build_icon()
				return
			else
				src.materials_in_use = mats_used

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
		var/mcheck = check_enough_materials(M)
		if(mcheck)
			var/make = clamp(M.create, 0, src.output_cap)
			switch(M.randomise_output)
				if(1) // pick a new item each loop
					while (make > 0)
						src.dispense_product(pick(M.item_outputs),M)
						make--
				if(2) // get a random item from the list and produce it
					var/to_make = pick(M.item_outputs)
					while (make > 0)
						src.dispense_product(to_make,M)
						make--
				else // produce every item in the list once per loop
					while (make > 0)
						for (var/X in M.item_outputs)
							src.dispense_product(X,M)
						make--

			src.remove_materials(M)
		else
			src.mode = MODE_HALT
			src.error = "Insufficient usable materials to continue queue production."
			src.visible_message(SPAN_ALERT("[src] emits an angry buzz!"))
			playsound(src.loc, src.sound_grump, 50, 1)
			src.build_icon()

		return

	proc/dispense_product(product,datum/manufacture/M)
		if (ispath(product))
			if (istype(M,/datum/manufacture/))
				var/atom/movable/A = new product(src)
				if (isitem(A))
					var/obj/item/I = A
					M.modify_output(src, I, src.materials_in_use)
					I.set_loc(src.get_output_location(I))
				else
					A.set_loc(src.get_output_location(A))
			else
				new product(get_output_location())

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
			var/obj/dummy = new /obj/item(get_turf(src))
			dummy.name = "strange thing"
			dummy.desc = "The fuck is this?"
			dummy.icon = welp

		else if (isfile(product)) // adapted from vending machine code
			var/S = sound(product)
			if (S)
				playsound(src.loc, S, 50, 0)

		else if (isobj(product))
			var/obj/X = product
			X.set_loc(get_output_location())

		else if (ismob(product))
			var/mob/X = product
			X.set_loc(get_output_location())

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
			if (!src.electrified)
				src.electrified = 5

	proc/build_icon()
		icon_state = "fab[src.icon_base ? "-[src.icon_base]" : null]"

		if (status & BROKEN)
			src.UpdateOverlays(null, "work")
			src.UpdateOverlays(null, "activity")
			icon_state = "[src.icon_base]-broken"
		else if (src.dismantle_stage >= 2)
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

	/// Safely gets our storage contents. In case someone does something like load materials into the machine before we have initialized our storage
	/// Also ejects things w/o material or that aren't pieces, to ensure safety
	proc/get_contents()
		if (isnull(src.storage))
			src.create_storage(/datum/storage/no_hud, can_hold=list(/obj/item/material_piece))
		var/list/storage_contents = src.storage.get_contents()
		for (var/obj/item/I as anything in storage_contents)
			if (!istype(I, /obj/item/material_piece) || isnull(I.material))
				// Invalid thing somehow, fuck
				src.storage.transfer_stored_item(I, src.loc)
		return storage_contents

	/*
	Safely modifies our storage contents. In case someone does something like load materials into the machine before we have initialized our storage
	Parameters for selection of material (requires at least one non-null):
	mat_id = material id to set. creates a new material if none of that id exists
	mat_path = material path to use. creates material of path with amount arg or default amount if null
	mat_piece = physical object to add. transfers it to the storage, but adds it to an existing stack instead of applicable
	material = material datum to add. acts as/overrides mat_id if provided
	amount = delta material to add. 5 to add 5 bars, -5 to remove 5 bars, 0.5 to add 0.5 bars, etc.
	user = (optional) any mob that may be loading this
	*/
	proc/change_contents(var/amount = null, var/mat_id = null, var/mat_path = null, var/obj/item/material_piece/mat_piece = null, var/datum/material/mat_datum = null, var/mob/living/user = null)
		if (!isnull(mat_path))
			mat_piece = new mat_path
			if (amount)
				mat_piece.amount = amount

		if (!amount)
			if (isnull(mat_piece))
				return
			else
				amount = mat_piece.amount

		if (isnull(mat_id) && isnull(mat_piece) && isnull(mat_datum) && isnull(mat_path))
			CRASH("add_contents on [src] cannot add null material to contents. something probably tried to add a material but gave null!")

		// Try stacking with existing same material in storage
		var/list/C = src.get_contents()
		if (!isnull(mat_datum))
			mat_id = mat_datum.getID()
		for (var/obj/item/material_piece/P as anything in C)
			if (!P.material)
				continue
			// Match by material piece or id
			if (mat_piece && mat_piece.material && P.material.isSameMaterial(mat_piece.material) ||\
				mat_id && mat_id == P.material.getID())
				// fuck floating point, lets pretend we only use tenths
				P.change_stack_amount(amount)
				// Handle inserting pieces into the machine
				if (user)
					user.u_equip(mat_piece)
					mat_piece.dropped(user)
					qdel(mat_piece)
				if (P.amount <= 0)
					qdel(P)
				return

		// No same material in storage, create/add the one we have and update the requirements index accordingly
		if (!isnull(mat_piece))
			if (isnull(mat_piece.material))
				return
			src.storage.add_contents(mat_piece, user = user, visible = FALSE)
			material_patterns_by_ref["\ref[mat_piece]"] = src.get_requirements_material_satisfies(mat_piece.material)
			return

		if (isnull(mat_datum))
			// we gave an ID but no M, so override 'M' for this
			mat_datum = getMaterial(mat_id)

		var/T = getProcessedMaterialForm(mat_datum)
		var/obj/item/material_piece/P = new T
		P.amount = max(0, amount)
		src.storage.add_contents(P, user = user, visible = FALSE)

		material_patterns_by_ref["\ref[mat_piece]"] = src.get_requirements_material_satisfies(P.material)

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

	proc/get_our_material(mat_id)
		for (var/obj/item/material_piece/M as anything in src.get_contents())
			if (M.material && M.material.getID() == mat_id)
				return M.material

	/// Adds the resources we define in free_resources to our storage, and clears the list when we're done
	/// to represent we do not have more resources to claim
	proc/claim_free_resources()
		if (src.deconstruct_flags & DECON_BUILT)
			free_resources = list()
			return

		for (var/mat_path in src.free_resources)
			src.change_contents(amount = src.free_resources[mat_path], mat_path = mat_path)

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
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
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

// Fabricator Defines

/obj/machinery/manufacturer/general
	name = "general manufacturer"
	supplemental_desc = "This one produces tools and other hardware, as well as general-purpose items like replacement lights."
	free_resources = list(/obj/item/material_piece/steel = 5,
		/obj/item/material_piece/copper = 5,
		/obj/item/material_piece/glass = 5)
	available = list(/datum/manufacture/screwdriver,
		/datum/manufacture/wirecutters,
		/datum/manufacture/wrench,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/welder,
		/datum/manufacture/flashlight,
		/datum/manufacture/weldingmask,
		/datum/manufacture/metal,
		/datum/manufacture/metalR,
		/datum/manufacture/rods2,
		/datum/manufacture/glass,
		/datum/manufacture/glassR,
		/datum/manufacture/atmos_can,
		/datum/manufacture/gastank,
		/datum/manufacture/miniplasmatank,
		/datum/manufacture/minioxygentank,
		/datum/manufacture/player_module,
		/datum/manufacture/cable,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
		/datum/manufacture/light_bulb,
		/datum/manufacture/red_bulb,
		/datum/manufacture/yellow_bulb,
		/datum/manufacture/green_bulb,
		/datum/manufacture/cyan_bulb,
		/datum/manufacture/blue_bulb,
		/datum/manufacture/purple_bulb,
		/datum/manufacture/blacklight_bulb,
		/datum/manufacture/light_tube,
		/datum/manufacture/red_tube,
		/datum/manufacture/yellow_tube,
		/datum/manufacture/green_tube,
		/datum/manufacture/cyan_tube,
		/datum/manufacture/blue_tube,
		/datum/manufacture/purple_tube,
		/datum/manufacture/blacklight_tube,
		/datum/manufacture/table_folding,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/shoes,
#ifdef UNDERWATER_MAP
		/datum/manufacture/flippers,
#endif
		/datum/manufacture/breathmask,
#ifdef MAP_OVERRIDE_NADIR
		/datum/manufacture/nanoloom,
		/datum/manufacture/nanoloom_cart,
#endif
		/datum/manufacture/fluidcanister,
		/datum/manufacture/meteorshieldgen,
		/datum/manufacture/shieldgen,
		/datum/manufacture/doorshieldgen,
		/datum/manufacture/patch,
		/datum/manufacture/saxophone,
		/datum/manufacture/trumpet)
	hidden = list(/datum/manufacture/RCDammo,
		/datum/manufacture/RCDammomedium,
		/datum/manufacture/RCDammolarge,
		/datum/manufacture/bottle,
		/datum/manufacture/vuvuzela,
		/datum/manufacture/harmonica,
		/datum/manufacture/bikehorn,
		/datum/manufacture/bullet_22,
		/datum/manufacture/bullet_smoke,
		/datum/manufacture/stapler,
		/datum/manufacture/bagpipe,
		/datum/manufacture/fiddle,
		/datum/manufacture/whistle)

#define MALFUNCTION_WIRE_CUT 15 & ~(1<<WIRE_MALF)

/obj/machinery/manufacturer/general/grody
	name = "grody manufacturer"
	desc = "It's covered in more gunk than a truck stop ashtray. Is this thing even safe?"
	supplemental_desc = "This one has seen better days. There are bits and pieces of the internal mechanisms poking out the side."
	free_resources = list()
	malfunction = TRUE
	wires = MALFUNCTION_WIRE_CUT

#undef MALFUNCTION_WIRE_CUT

/obj/machinery/manufacturer/robotics
	name = "robotics fabricator"
	supplemental_desc = "This one produces robot parts, cybernetic organs, and other robotics-related equipment."
	icon_state = "fab-robotics"
	icon_base = "robotics"
	free_resources = list(/obj/item/material_piece/steel = 5,
		/obj/item/material_piece/copper = 5,
		/obj/item/material_piece/glass = 5)
	available = list(/datum/manufacture/robo_frame,
		/datum/manufacture/full_cyborg_standard,
		/datum/manufacture/full_cyborg_light,
		/datum/manufacture/robo_head,
		/datum/manufacture/robo_chest,
		/datum/manufacture/robo_arm_r,
		/datum/manufacture/robo_arm_l,
		/datum/manufacture/robo_leg_r,
		/datum/manufacture/robo_leg_l,
		/datum/manufacture/robo_head_light,
		/datum/manufacture/robo_chest_light,
		/datum/manufacture/robo_arm_r_light,
		/datum/manufacture/robo_arm_l_light,
		/datum/manufacture/robo_leg_r_light,
		/datum/manufacture/robo_leg_l_light,
		/datum/manufacture/robo_leg_treads,
		/datum/manufacture/robo_head_screen,
		/datum/manufacture/robo_module,
		/datum/manufacture/cyberheart,
		/datum/manufacture/cybereye,
		/datum/manufacture/cybereye_meson,
		/datum/manufacture/cybereye_spectro,
		/datum/manufacture/cybereye_prodoc,
		/datum/manufacture/cybereye_camera,
		/datum/manufacture/shell_frame,
		/datum/manufacture/ai_interface,
		/datum/manufacture/latejoin_brain,
		/datum/manufacture/shell_cell,
		/datum/manufacture/cable,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
		/datum/manufacture/crowbar,
		/datum/manufacture/wrench,
		/datum/manufacture/screwdriver,
		/datum/manufacture/scalpel,
		/datum/manufacture/circular_saw,
		/datum/manufacture/surgical_scissors,
		/datum/manufacture/hemostat,
		/datum/manufacture/suture,
		/datum/manufacture/stapler,
		/datum/manufacture/surgical_spoon,
		/datum/manufacture/implanter,
		/datum/manufacture/secbot,
		/datum/manufacture/medbot,
		/datum/manufacture/firebot,
		/datum/manufacture/floorbot,
		/datum/manufacture/cleanbot,
		/datum/manufacture/digbot,
		/datum/manufacture/visor,
		/datum/manufacture/deafhs,
		/datum/manufacture/robup_jetpack,
		/datum/manufacture/robup_healthgoggles,
		/datum/manufacture/robup_sechudgoggles,
		/datum/manufacture/robup_spectro,
		/datum/manufacture/robup_recharge,
		/datum/manufacture/robup_repairpack,
		/datum/manufacture/robup_speed,
		/datum/manufacture/robup_mag,
		/datum/manufacture/robup_meson,
		/datum/manufacture/robup_aware,
		/datum/manufacture/robup_physshield,
		/datum/manufacture/robup_fireshield,
		/datum/manufacture/robup_teleport,
		/datum/manufacture/robup_visualizer,
		/*/datum/manufacture/robup_thermal,*/
		/datum/manufacture/robup_efficiency,
		/datum/manufacture/robup_repair,
		/datum/manufacture/implant_robotalk,
		/datum/manufacture/sbradio,
		/datum/manufacture/implant_health,
		/datum/manufacture/implant_antirot,
		/datum/manufacture/cyberappendix,
		/datum/manufacture/cyberpancreas,
		/datum/manufacture/cyberspleen,
		/datum/manufacture/cyberintestines,
		/datum/manufacture/cyberstomach,
		/datum/manufacture/cyberkidney,
		/datum/manufacture/cyberliver,
		/datum/manufacture/cyberlung_left,
		/datum/manufacture/cyberlung_right,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass,
		/datum/manufacture/asimov_laws,
		/datum/manufacture/borg_linker)

	hidden = list(/datum/manufacture/flash,
		/datum/manufacture/cybereye_thermal,
		/datum/manufacture/cybereye_laser,
		/datum/manufacture/cyberbutt,
		/datum/manufacture/robup_expand,
		/datum/manufacture/cardboard_ai,
		/datum/manufacture/corporate_laws,
		/datum/manufacture/robocop_laws)

/obj/machinery/manufacturer/medical
	name = "medical fabricator"
	supplemental_desc = "This one produces medical equipment and sterile clothing."
	icon_state = "fab-med"
	icon_base = "med"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2,
		/obj/item/material_piece/cloth/cottonfabric = 2)
	available = list(
		/datum/manufacture/scalpel,
		/datum/manufacture/circular_saw,
		/datum/manufacture/surgical_scissors,
		/datum/manufacture/hemostat,
		/datum/manufacture/suture,
		/datum/manufacture/stapler,
		/datum/manufacture/surgical_spoon,
		/datum/manufacture/prodocs,
		/datum/manufacture/glasses,
		/datum/manufacture/visor,
		/datum/manufacture/deafhs,
		/datum/manufacture/hypospray,
		/datum/manufacture/patch,
		/datum/manufacture/mender,
		/datum/manufacture/penlight,
		/datum/manufacture/stethoscope,
		/datum/manufacture/latex_gloves,
		/datum/manufacture/surgical_mask,
		/datum/manufacture/surgical_shield,
		/datum/manufacture/scrubs_white,
		/datum/manufacture/scrubs_teal,
		/datum/manufacture/scrubs_maroon,
		/datum/manufacture/scrubs_blue,
		/datum/manufacture/scrubs_purple,
		/datum/manufacture/scrubs_orange,
		/datum/manufacture/scrubs_pink,
		/datum/manufacture/patient_gown,
		/datum/manufacture/eyepatch,
		/datum/manufacture/blindfold,
		/datum/manufacture/muzzle,
		/datum/manufacture/stress_ball,
		/datum/manufacture/body_bag,
		/datum/manufacture/implanter,
		/datum/manufacture/implant_health,
		/datum/manufacture/implant_antirot,
		/datum/manufacture/floppydisk,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/cyberappendix,
		/datum/manufacture/cyberpancreas,
		/datum/manufacture/cyberspleen,
		/datum/manufacture/cyberintestines,
		/datum/manufacture/cyberstomach,
		/datum/manufacture/cyberkidney,
		/datum/manufacture/cyberliver,
		/datum/manufacture/cyberlung_left,
		/datum/manufacture/cyberlung_right,
		/datum/manufacture/empty_kit,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass
	)

	hidden = list(/datum/manufacture/cyberheart,
	/datum/manufacture/cybereye)

/obj/machinery/manufacturer/science
	name = "science fabricator"
	supplemental_desc = "This one produces science equipment for experiments as well as expeditions."
	icon_state = "fab-sci"
	icon_base = "sci"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2,
		/obj/item/material_piece/cloth/cottonfabric = 2,
		/obj/item/material_piece/cobryl = 2)
	available = list(
		/datum/manufacture/flashlight,
		/datum/manufacture/gps,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/welder,
		/datum/manufacture/patch,
		/datum/manufacture/atmos_can,
		/datum/manufacture/artifactforms,
		/datum/manufacture/fluidcanister,
		/datum/manufacture/chembarrel,
		/datum/manufacture/chembarrel/yellow,
		/datum/manufacture/chembarrel/red,
		/datum/manufacture/condenser,
		/datum/manufacture/fractionalcondenser,
		/datum/manufacture/beaker_lid_box,
		/datum/manufacture/bunsen_burner,
		/datum/manufacture/spectrogoggles,
		/datum/manufacture/atmos_goggles,
		/datum/manufacture/reagentscanner,
		/datum/manufacture/dropper,
		/datum/manufacture/mechdropper,
		/datum/manufacture/patient_gown,
		/datum/manufacture/blindfold,
		/datum/manufacture/muzzle,
		/datum/manufacture/audiotape,
		/datum/manufacture/audiolog,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass)

	hidden = list(/datum/manufacture/scalpel,
		/datum/manufacture/circular_saw,
		/datum/manufacture/surgical_scissors,
		/datum/manufacture/hemostat,
		/datum/manufacture/suture,
		/datum/manufacture/stapler,
		/datum/manufacture/surgical_spoon
	)

/obj/machinery/manufacturer/mining
	name = "mining fabricator"
	supplemental_desc = "This one produces mining equipment like concussive charges and powered tools."
	icon_state = "fab-mining"
	icon_base = "mining"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)
	available = list(/datum/manufacture/pick,
		/datum/manufacture/powerpick,
		/datum/manufacture/blastchargeslite,
		/datum/manufacture/blastcharges,
		/datum/manufacture/powerhammer,
		/datum/manufacture/drill,
		/datum/manufacture/conc_gloves,
		/datum/manufacture/digbot,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/shoes,
		/datum/manufacture/breathmask,
		/datum/manufacture/engspacesuit,
		/datum/manufacture/lightengspacesuit,
#ifdef UNDERWATER_MAP
		/datum/manufacture/engdivesuit,
		/datum/manufacture/flippers,
#endif
		/datum/manufacture/industrialarmor,
		/datum/manufacture/industrialboots,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
		/datum/manufacture/ore_scoop,
		/datum/manufacture/oresatchel,
		/datum/manufacture/oresatchelL,
		/datum/manufacture/microjetpack,
		/datum/manufacture/jetpack,
#ifdef UNDERWATER_MAP
		/datum/manufacture/jetpackmkII,
#endif
		/datum/manufacture/geoscanner,
		/datum/manufacture/geigercounter,
		/datum/manufacture/eyes_meson,
		/datum/manufacture/flashlight,
		/datum/manufacture/ore_accumulator,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
#ifndef UNDERWATER_MAP
		/datum/manufacture/mining_magnet
#endif
		)

/obj/machinery/manufacturer/hangar
	name = "ship component fabricator"
	supplemental_desc = "This one produces modules for space pods or minisubs."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)
	available = list(
#ifdef UNDERWATER_MAP
		/datum/manufacture/sub/preassembeled_parts,
#else
		/datum/manufacture/putt/preassembeled_parts,
		/datum/manufacture/pod/preassembeled_parts,
#endif
		/datum/manufacture/pod/armor_light,
		/datum/manufacture/pod/armor_heavy,
		/datum/manufacture/pod/armor_industrial,
		/datum/manufacture/cargohold,
		/datum/manufacture/storagehold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/bad_mining,
		/datum/manufacture/pod/weapon/mining,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/engine,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/beaconkit,
		/datum/manufacture/podgps
	)

/obj/machinery/manufacturer/uniform // add more stuff to this as needed, but it should be for regular uniforms the HoP might hand out, not tons of gimmicks. -cogwerks
	name = "uniform manufacturer"
	supplemental_desc = "This one can create a wide variety of one-size-fits-all jumpsuits, as well as backpacks and radio headsets."
	icon_state = "fab-jumpsuit"
	icon_base = "jumpsuit"
	free_resources = list(/obj/item/material_piece/cloth/cottonfabric = 5,
		/obj/item/material_piece/steel = 5,
		/obj/item/material_piece/copper = 5)
	accept_blueprints = FALSE
	available = list(/datum/manufacture/shoes,	//hey if you update these please remember to add it to /hop_and_uniform's list too
		/datum/manufacture/shoes_brown,
		/datum/manufacture/shoes_white,
		/datum/manufacture/flippers,
		/datum/manufacture/civilian_headset,
		/datum/manufacture/jumpsuit_assistant,
		/datum/manufacture/jumpsuit_pink,
		/datum/manufacture/jumpsuit_red,
		/datum/manufacture/jumpsuit_orange,
		/datum/manufacture/jumpsuit_yellow,
		/datum/manufacture/jumpsuit_green,
		/datum/manufacture/jumpsuit_blue,
		/datum/manufacture/jumpsuit_purple,
		/datum/manufacture/jumpsuit_black,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/jumpsuit_white,
		/datum/manufacture/jumpsuit_brown,
		/datum/manufacture/pride_lgbt,
		/datum/manufacture/pride_ace,
		/datum/manufacture/pride_aro,
		/datum/manufacture/pride_bi,
		/datum/manufacture/pride_inter,
		/datum/manufacture/pride_lesb,
		/datum/manufacture/pride_gay,
		/datum/manufacture/pride_nb,
		/datum/manufacture/pride_pan,
		/datum/manufacture/pride_poly,
		/datum/manufacture/pride_trans,
		/datum/manufacture/suit_black,
		/datum/manufacture/dress_black,
		/datum/manufacture/hat_black,
		/datum/manufacture/hat_white,
		/datum/manufacture/hat_pink,
		/datum/manufacture/hat_red,
		/datum/manufacture/hat_yellow,
		/datum/manufacture/hat_orange,
		/datum/manufacture/hat_green,
		/datum/manufacture/hat_blue,
		/datum/manufacture/hat_purple,
		/datum/manufacture/hat_tophat,
		/datum/manufacture/backpack,
		/datum/manufacture/backpack_red,
		/datum/manufacture/backpack_green,
		/datum/manufacture/backpack_blue,
		/datum/manufacture/satchel,
		/datum/manufacture/satchel_red,
		/datum/manufacture/satchel_green,
		/datum/manufacture/satchel_blue)

	hidden = list(/datum/manufacture/breathmask,
		/datum/manufacture/patch,
		/datum/manufacture/towel,
		/datum/manufacture/handkerchief,
		/datum/manufacture/tricolor,
		/datum/manufacture/hat_ltophat)

/// cogwerks - a gas extractor for the engine

/obj/machinery/manufacturer/gas
	name = "gas extractor"
	supplemental_desc = "This one can create gas canisters, either empty or filled with gases extracted from certain minerals."
	icon_state = "fab-atmos"
	icon_base = "atmos"
	accept_blueprints = FALSE
	available = list(
		/datum/manufacture/atmos_can,
		/datum/manufacture/air_can/large,
		/datum/manufacture/o2_can,
		/datum/manufacture/co2_can,
		/datum/manufacture/n2_can,
		/datum/manufacture/plasma_can,
		/datum/manufacture/red_o2_grenade)

// a blank manufacturer for mechanics

/obj/machinery/manufacturer/mechanic
	name = "reverse-engineering fabricator"
	desc = "A specialized manufacturing unit designed to create new things (or copies of existing things) from blueprints."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)

/obj/machinery/manufacturer/personnel
	name = "personnel equipment manufacturer"
	supplemental_desc = "This one can produce blank ID cards and access implants."
	icon_state = "fab-access"
	icon_base = "access"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)
	available = list(/datum/manufacture/id_card, /datum/manufacture/implant_access,	/datum/manufacture/implanter)
	hidden = list(/datum/manufacture/id_card_gold, /datum/manufacture/implant_access_infinite)

//combine personnel + uniform manufactuer here. this is 'cause destiny doesn't have enough room! arrg!
//and i hate this, i do, but you're gonna have to update this list whenever you update /personnel or /uniform
/obj/machinery/manufacturer/hop_and_uniform
	name = "personnel manufacturer"
	supplemental_desc = "This one is an multi-purpose model, and is able to produce uniforms, headsets, and identification equipment."
	icon_state = "fab-access"
	icon_base = "access"
	free_resources = list(/obj/item/material_piece/steel = 5,
		/obj/item/material_piece/copper = 5,
		/obj/item/material_piece/glass = 5,
		/obj/item/material_piece/cloth/cottonfabric = 5)
	accept_blueprints = FALSE
	available = list(/datum/manufacture/id_card,
		/datum/manufacture/implant_access,
		/datum/manufacture/implanter,
		/datum/manufacture/shoes,
		/datum/manufacture/shoes_brown,
		/datum/manufacture/shoes_white,
		/datum/manufacture/flippers,
		/datum/manufacture/civilian_headset,
		/datum/manufacture/jumpsuit_assistant,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/jumpsuit_white,
		/datum/manufacture/jumpsuit_pink,
		/datum/manufacture/jumpsuit_red,
		/datum/manufacture/jumpsuit_orange,
		/datum/manufacture/jumpsuit_yellow,
		/datum/manufacture/jumpsuit_green,
		/datum/manufacture/jumpsuit_blue,
		/datum/manufacture/jumpsuit_purple,
		/datum/manufacture/jumpsuit_black,
		/datum/manufacture/jumpsuit_brown,
		/datum/manufacture/pride_lgbt,
		/datum/manufacture/pride_ace,
		/datum/manufacture/pride_aro,
		/datum/manufacture/pride_bi,
		/datum/manufacture/pride_inter,
		/datum/manufacture/pride_lesb,
		/datum/manufacture/pride_gay,
		/datum/manufacture/pride_nb,
		/datum/manufacture/pride_pan,
		/datum/manufacture/pride_poly,
		/datum/manufacture/pride_trans,
		/datum/manufacture/hat_black,
		/datum/manufacture/hat_white,
		/datum/manufacture/hat_pink,
		/datum/manufacture/hat_red,
		/datum/manufacture/hat_yellow,
		/datum/manufacture/hat_orange,
		/datum/manufacture/hat_green,
		/datum/manufacture/hat_blue,
		/datum/manufacture/hat_purple,
		/datum/manufacture/hat_tophat)

	hidden = list(/datum/manufacture/id_card_gold,
		/datum/manufacture/implant_access_infinite,
		/datum/manufacture/breathmask,
		/datum/manufacture/patch,
		/datum/manufacture/tricolor,
		/datum/manufacture/hat_ltophat)

/obj/machinery/manufacturer/qm // This manufacturer just creates different crated and boxes for the QM. Lets give their boring lives at least something more interesting.
	name = "crate manufacturer"
	supplemental_desc = "This one produces crates, carts, that sort of thing. Y'know, box stuff."
	icon_state = "fab-crates"
	icon_base = "crates"
	free_resources = list(/obj/item/material_piece/steel = 1,
		/obj/item/material_piece/organic/wood = 1)
	accept_blueprints = FALSE
	available = list(/datum/manufacture/crate,
		/datum/manufacture/packingcrate,
		/datum/manufacture/wooden,
		/datum/manufacture/medical,
		/datum/manufacture/biohazard,
		/datum/manufacture/freezer)

	hidden = list(/datum/manufacture/classcrate)

/obj/machinery/manufacturer/zombie_survival
	name = "\improper Uber-Extreme Survival Manufacturer"
	desc = "This manufacturing unit seems to have been loaded with a bunch of nonstandard blueprints, apparently to be useful in surviving \"extreme scenarios\"."
	icon_state = "fab-crates"
	icon_base = "crates"
	free_resources = list(/obj/item/material_piece/steel = 50,
		/obj/item/material_piece/copper = 50,
		/obj/item/material_piece/glass = 50,
		/obj/item/material_piece/cloth/cottonfabric = 50)
	accept_blueprints = FALSE
	available = list(
		/datum/manufacture/engspacesuit,
		/datum/manufacture/breathmask,
		/datum/manufacture/suture,
		/datum/manufacture/scalpel,
		/datum/manufacture/flashlight,
		/datum/manufacture/armor_vest,
		/datum/manufacture/bullet_22,
		/datum/manufacture/harmonica,
		/datum/manufacture/riot_shotgun,
		/datum/manufacture/riot_shotgun_ammo,
		/datum/manufacture/clock,
		/datum/manufacture/clock_ammo,
		/datum/manufacture/saa,
		/datum/manufacture/saa_ammo,
		/datum/manufacture/riot_launcher,
		/datum/manufacture/riot_launcher_ammo_pbr,
		/datum/manufacture/riot_launcher_ammo_flashbang,
		/datum/manufacture/sniper,
		/datum/manufacture/sniper_ammo,
		/datum/manufacture/tac_shotgun,
		/datum/manufacture/tac_shotgun_ammo,
		/datum/manufacture/gyrojet,
		/datum/manufacture/gyrojet_ammo,
		/datum/manufacture/plank,
		/datum/manufacture/brute_kit,
		/datum/manufacture/burn_kit,
		/datum/manufacture/crit_kit,
		/datum/manufacture/spacecillin,
		/datum/manufacture/bat,
		/datum/manufacture/quarterstaff,
		/datum/manufacture/cleaver,
		/datum/manufacture/fireaxe,
		/datum/manufacture/shovel)

/obj/machinery/manufacturer/engineering
	name = "Engineering Specialist Manufacturer"
	desc = "This one produces specialist engineering devices."
	icon_state = "fab-engineering"
	icon_base = "engineering"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)
	available = list(
		/datum/manufacture/screwdriver/yellow,
		/datum/manufacture/wirecutters/yellow,
		/datum/manufacture/wrench/yellow,
		/datum/manufacture/crowbar/yellow,
		/datum/manufacture/extinguisher,
		/datum/manufacture/welder/yellow,
		/datum/manufacture/soldering,
		/datum/manufacture/multitool,
		/datum/manufacture/t_scanner,
		/datum/manufacture/RCD,
		/datum/manufacture/RCDammo,
		/datum/manufacture/RCDammomedium,
		/datum/manufacture/RCDammolarge,
		/datum/manufacture/atmos_goggles,
		/datum/manufacture/engivac,
		/datum/manufacture/lampmanufacturer,
		/datum/manufacture/breathmask,
		/datum/manufacture/engspacesuit,
		/datum/manufacture/lightengspacesuit,
		/datum/manufacture/floodlight,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
#ifdef UNDERWATER_MAP
		/datum/manufacture/engdivesuit,
		/datum/manufacture/flippers,
#endif
#ifdef MAP_OVERRIDE_OSHAN
	/datum/manufacture/cable/reinforced,
#endif
		/datum/manufacture/mechanics/laser_mirror,
		/datum/manufacture/mechanics/laser_splitter,
		/datum/manufacture/interdictor_kit,
		/datum/manufacture/interdictor_board_standard,
		/datum/manufacture/interdictor_board_nimbus,
		/datum/manufacture/interdictor_board_zephyr,
		/datum/manufacture/interdictor_board_devera,
		/datum/manufacture/interdictor_rod_lambda,
		/datum/manufacture/interdictor_rod_sigma,
		/datum/manufacture/interdictor_rod_epsilon,
		/datum/manufacture/interdictor_rod_phi
	)

	New()
		. = ..()
		if (isturf(src.loc)) //not inside a frame or something
			new /obj/item/paper/book/from_file/interdictor_guide(src.loc)

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
		MA.manual_stop = FALSE
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
