//node1, air1, network1 correspond to input
//node2, air2, network2 correspond to output
//
#define LEFT_CIRCULATOR 1
#define RIGHT_CIRCULATOR 2
#define BASE_LUBE_CHECK_RATE 5

// Circulator variants
/// no backflow
#define BACKFLOW_PROTECTION	 (1<<0)
/// periodically leaks input gas
#define LEAKS_GAS						 (1<<1)
/// periodically leaks/eats lube
#define LEAKS_LUBE 					 (1<<2)
/// LUBE Drain
#define LUBE_DRAIN_OPEN			 (1<<3)

// Warning Lights
/// Lack of surplus power and drain exceeds current perapc
#define WARNING_APC_DRAINING (1<<0)
/// Expected to drain cell in ~5min
#define WARNING_5MIN (1<<1)
/// Expected to drain cell in ~1min
#define WARNING_1MIN (1<<2)
/// Gas molar quantity is problematic!
#define WARNING_LOW_MOLES (1<<3)

// Machinery rate is 4 (0.4 seconds) subdivided into 8 groups
#define TIME_PER_PROCESS (4 * 8)
#define WARNING_FAIL_5MIN_ITERS (5 MINUTES / TIME_PER_PROCESS)
#define WARNING_FAIL_1MIN_ITERS (1 MINUTES / TIME_PER_PROCESS)

// TEG variants
/// HIGH TEMP Model
#define TEG_HIGH_TEMP	(1<<0)
/// LOW TEMP Model
#define TEG_LOW_TEMP (1<<1)

/// TEG Semiconductor Present and Installed
#define TEG_SEMI_STATE_INSTALLED 0
/// TEG Semiconductor Cover unscrewed
#define TEG_SEMI_STATE_UNSCREWED 1
/// TEG Semiconductor Connected with Extra Wires
#define TEG_SEMI_STATE_CONNECTED 2
/// TEG Semiconductor Present but disconnected
#define TEG_SEMI_STATE_DISCONNECTED 3
/// TEG Semiconductor Missing
#define TEG_SEMI_STATE_MISSING 4

/obj/machinery/atmospherics/binary/circulatorTemp
	name = "hot gas circulator"
	desc = "It's the gas circulator of a thermoeletric generator."
	icon = 'icons/obj/atmospherics/pipes.dmi'
	icon_state = "circ1-off"
	var/obj/machinery/power/generatorTemp/generator = null

	var/side = null // 1=left 2=right
	var/last_pressure_delta = 0
	var/static/list/circulator_preferred_reagents // white list of prefferred reagents where viscocity should be ignored for special value
	var/lube_cycle = 0 // current state in cycle
	var/lube_cycle_duration = BASE_LUBE_CHECK_RATE //rate at which reagents are adjusted for leaks/consumption in atmos machinery processes
	var/reagents_consumed = 0 //amount of reagents consumed by active leak or variant
	var/variant_description
	var/lube_boost = 1.0
	var/circulator_flags = BACKFLOW_PROTECTION
	var/fan_efficiency = 0.9 // 0.9 ideal
	var/min_circ_pressure = 75
	var/target_pressure	// crew entered desired pressure for inlet to outlet
	var/target_pressure_enabled	// crew desired pressure is active
	var/serial_num = "CIRC-FEEDDEADBEEF"
	var/repairstate = 0
	var/repair_desc = ""
	var/variant_b_active = FALSE
	var/warning_active = FALSE

	anchored = 1.0
	density = 1

	var/datum/pump_ui/ui

	initialize()
		..()
		ui = new/datum/pump_ui/circulator_ui(src)

	New()
		. = ..()
		circulator_preferred_reagents = list("oil"=1.0,"lube"=1.1,"superlube"=1.12)
		create_reagents(400)
		reagents.add_reagent("oil", reagents.maximum_volume*0.50)
		target_pressure = min_circ_pressure
		target_pressure_enabled = FALSE

	proc/assign_variant(partial_serial_num, variant_a, variant_b=null)
		src.serial_num = "CIRC-[partial_serial_num][variant_a][rand(100,999)]"
		src.serial_num += src.side==1? "L":"R"
		if(variant_b)
			src.serial_num += "-[variant_b]"
			variant_b_active = TRUE

	disposing()
		switch (side)
			if (LEFT_CIRCULATOR)
				src.generator?.circ1 = null
			if (RIGHT_CIRCULATOR)
				src.generator?.circ2 = null
		src.generator = null
		..()

	get_desc(dist, mob/user)
		if(variant_description || generator.variant_description)
			. += variant_description
			. += generator.variant_description
			. += "The instruction manual should have more information."
		if(dist <= 5)
			. += "[repair_desc]"
			. += "<br><span class='notice'>The maintenance panel is [src.is_open_container() ? "open" : "closed"].</span>"
		if(dist <= 2)
			. += "<br><span class='notice'>Serial Number: [serial_num].</span>"
		if(dist <= 2 && reagents && is_open_container() )
			. += "<br><span class='notice'>The drain valve is [circulator_flags & LUBE_DRAIN_OPEN ? "open" : "closed"].</span>"
			. += "<br><span class='notice'>[reagents.get_description(user,RC_SCALE)]</span>"


	attackby(obj/item/W as obj, mob/user as mob)
		var/open = is_open_container()

		// Weld > Crowbar > Rods > Weld
		if(open && repairstate)
			switch(repairstate)
				if(1)
					if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
						actions.start(new /datum/action/bar/icon/teg_circulator_repair(src, W, 5 SECONDS), user)
						return
				if(2)
					if (istool(W, TOOL_PRYING))
						actions.start(new /datum/action/bar/icon/teg_circulator_repair(src, W, 5 SECONDS), user)
						return
				if(3)
					if (istype(W, /obj/item/rods))
						var/obj/item/rods/S = W
						if (S.amount >= 5)
							actions.start(new /datum/action/bar/icon/teg_circulator_repair(src, W, 5 SECONDS), user)
						return
				if(4)
					if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
						actions.start(new /datum/action/bar/icon/teg_circulator_repair(src, W, 5 SECONDS), user)
						return

		if(isscrewingtool(W))
			open = !open
			src.add_fingerprint(user)
			playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
			user.visible_message("<span class='notice'>[user] [open ? "opens" : "closes"] the maintenance panel on the [src].</span>", "<span class='notice'>You [open ? "open" : "close"] the maintenance panel on the [src].</span>")
			flags ^= OPENCONTAINER
			update_icon()
		else if(iswrenchingtool(W) && open)
			src.add_fingerprint(user)
			playsound(src.loc, "sound/items/Ratchet.ogg", 30, 1)
			circulator_flags ^= LUBE_DRAIN_OPEN
			open = circulator_flags & LUBE_DRAIN_OPEN
			user.visible_message("<span class='notice'>[user] adjusts the [src] drain valve.</span>", "<span class='notice'>You [open ? "open" : "close"] the [src] drain valve.</span>")
		else if(ispulsingtool(W))
			ui.show_ui(user)
		else
			..()

	proc/return_transfer_air()
		var/input_starting_pressure = MIXTURE_PRESSURE(src.air1)
		var/output_starting_pressure = MIXTURE_PRESSURE(src.air2)
		var/fan_power_draw = 0
		var/desired_pressure = 0

		desired_pressure = src.min_circ_pressure
		if(src.target_pressure_enabled) desired_pressure = src.target_pressure

		if(!input_starting_pressure)
			return null

		var/datum/gas_mixture/gas_input = air1
		var/datum/gas_mixture/gas_output = air2

		//Calculate necessary moles to transfer using PV = nRT
		var/pressure_delta = (input_starting_pressure - output_starting_pressure)/2

		src.warning_active = FALSE
		// Check if fan/blower is required to overcome passive gate
		if(circulator_flags & BACKFLOW_PROTECTION)
			if(input_starting_pressure < (output_starting_pressure + desired_pressure))
				// Use maximum of minimum circulator pressure OR calculated pressure required to ensure an amount that won't get rounded away by quantization
				// Note - ( 5 * ATMOS_EPSILON ) used to allow for a ratio of multiple gas specific heats to be utilized in the mixture
				pressure_delta = max( desired_pressure, ( ( 5 * ATMOS_EPSILON ) * (src.air1.temperature * R_IDEAL_GAS_EQUATION) / max(src.air2.volume,1) ) )

				// P = dp q / μf, q ignored for simplification of system
				var/total_pressure = (output_starting_pressure + pressure_delta - input_starting_pressure)
				fan_power_draw = round((total_pressure) / src.fan_efficiency)
				if(src.reagents.has_reagent("voltagen", 1))
					fan_power_draw = max(0, 10*log(total_pressure))


				if(pressure_delta > desired_pressure) src.warning_active |= WARNING_LOW_MOLES
				if(src.generator)
					var/area/A = get_area(src)
					var/apc_charge
					var/cell_wattage
					var/surplus
					if(istype(A, /area/station/))
						var/obj/machinery/power/apc/P = A.area_apc
						if(P)
							apc_charge = P.terminal.powernet?.perapc
							cell_wattage = P.cell.charge/CELLRATE
							surplus = P.surplus()

						if(surplus <= 0 && fan_power_draw > apc_charge)
							src.warning_active |= WARNING_APC_DRAINING

						if(fan_power_draw * WARNING_FAIL_1MIN_ITERS > (cell_wattage + (apc_charge * WARNING_FAIL_1MIN_ITERS)))
							src.warning_active |= WARNING_1MIN
						else if(fan_power_draw * WARNING_FAIL_5MIN_ITERS > (cell_wattage + (apc_charge * WARNING_FAIL_5MIN_ITERS)))
							src.warning_active |= WARNING_5MIN

		else if(pressure_delta < 0)
			gas_input = air2
			gas_output = air1

		pressure_delta *= src.lube_boost

		if(fan_power_draw)
			if(src.status & NOPOWER)
				src.last_pressure_delta = 0
				return null
			else src.use_power(fan_power_draw WATTS)

		// Calculate and perform gas transfer from in to out
		var/transfer_moles = abs(pressure_delta)*gas_output.volume/max(gas_input.temperature * R_IDEAL_GAS_EQUATION, 1) //Stop annoying runtime errors
		src.last_pressure_delta = pressure_delta
		var/datum/gas_mixture/removed = gas_input.remove(transfer_moles)

		handle_reactions(removed)

		// Leaks gas variant
		if((circulator_flags & LEAKS_GAS ) && prob(5))
			var/datum/gas_mixture/leaked = gas_input.remove_ratio(rand(2,8)*0.01)
			src.audible_message("<span class='alert'>[src] makes a hissing sound.</span>")
			if(leaked) loc.assume_air(leaked)

		src.network1?.update = 1
		src.network2?.update = 1

		return removed


	// This is special handeling for reagent interactions and reagent reactions with circulator
	proc/handle_reactions(var/datum/gas_mixture/gas_passed)
		var/reaction_temp = 0
		var/reagent_amount

		// Interactions with circulator
		if( !(src.circulator_flags & LEAKS_LUBE)							\
			&& ( src.reagents.has_reagent("pacid", 10)					\
		    || src.reagents.has_reagent("clacid", 10)					\
		    || src.reagents.has_reagent("nitric_acid", 10))		\
		  && prob(10))
			src.circulator_flags |= LEAKS_LUBE
			// Circulator system has been damaged and will leak 1/5th the contents
			src.reagents_consumed = src.reagents.maximum_volume / 5
			src.lube_cycle_duration = 1
			src.repairstate = 1
			if(src.is_open_container() && src.reagents.total_volume )
				src.visible_message("<span class='alert'>Fluid is starting to drip from inside the [src] maintenance panel.</span>")
				playsound(src.loc, "sound/effects/bubbles3.ogg", 80, 1, -3, pitch=0.7)
			else
				src.audible_message("<span class='alert'>An unsettling gurgling sound can be heard from [src].</span>")
				playsound(src.loc, "sound/effects/bubbles3.ogg", 20, 1, -3, pitch=0.7)

			src.repair_desc = "Lubrication system is a mess and needs replacing, the piping needs to be cut up with a welder prior to removal."

		if( src.reagents.has_reagent("hugs") && src.generator.grump && prob(5) )
			reagent_amount = src.reagents.get_reagent_amount("hugs")
			src.generator.grump -= reagent_amount * 5
			src.reagents.remove_reagent("hugs", 1)
			src.audible_message("<span class='alert'>The [src] makes a fun gurgling sound.</span>")

		if( src.reagents.has_reagent("love") && src.generator.grump > 20 && prob(5)  )
			src.reagents.remove_reagent("love", 1)
			src.generator.grump -= 100
			src.audible_message("<span class='alert'>A oddly distinctive sound of contentment can be heard from [src]. How wonderful!</span>")

		// Interactions with transferred gas
		if(gas_passed)
			if(src.reagents.has_active_reaction("cryostylane_cold"))
				reaction_temp -= 200
				if(prob(5))
					src.visible_message("<span class='alert'>A thin layer of frost momentarily forms around [src].</span>")
			if(src.reagents.has_active_reaction("thalmerite_heat"))
				reaction_temp += 200
				if(prob(5))
					src.visible_message("<span class='alert'>The [src] looks kind of hazey for a moment.</span>")

			if(reaction_temp)
				gas_passed.temperature += reaction_temp
				gas_passed.temperature = max(gas_passed.temperature,1)

	proc/is_circulator_active()
		return last_pressure_delta > src.min_circ_pressure

	proc/circulate_gas(datum/gas_mixture/gas)
		var/datum/gas_mixture/gas_input = air1
		var/datum/gas_mixture/gas_output = air2

		//flowing backwards
		if(last_pressure_delta < 0 && !(src.circulator_flags & BACKFLOW_PROTECTION))
			gas_input = air2
			gas_output = air1

		if(gas) gas_output.merge(gas)

		if(!is_circulator_active() && !(src.circulator_flags & BACKFLOW_PROTECTION))
			gas_input.share(gas_output)

		if(is_circulator_active())
			if(prob(5))
				switch(src.lube_boost)
					if(0.0 to 0.8)
						src.audible_message("<span class='alert'>[src] makes an unsettling grinding sound!</span>")
					if(0.8 to 0.9)
						src.audible_message("<span class='alert'>[src] makes an unsettling buzzing sound!</span>")


	proc/lube_loss_check()
		if(src.reagents?.total_volume == 0) return

		if( src.circulator_flags & LUBE_DRAIN_OPEN )
			var/datum/reagents/leaked = src.reagents.remove_any_to(reagents.maximum_volume * 0.25)
			leaked.reaction(get_step(src, SOUTH))

		if(!(src.circulator_flags & LEAKS_LUBE) || !src.reagents_consumed || !src.is_circulator_active() )
			return

		// Skip off cycle consumption checks
		if(src.lube_cycle-- > 0) return

		if(lube_cycle <= 0)
			src.lube_cycle = src.lube_cycle_duration
			if( (src.circulator_flags & LEAKS_LUBE) && prob(80) )
				playsound(get_turf(src), "sound/effects/spray.ogg", 40, 1)
				var/datum/reagents/leaked = src.reagents.remove_any_to(src.reagents_consumed)
				leaked.reaction(get_step(src, pick(alldirs)))

	// Calculate an adjusted average reagent viscosity to determine boost for lube efficiency.
	// Viscosity value is inconsistant in some cases so a white list is used to ensure high performance of specific reagents.
	on_reagent_change(add)
		. = ..()
		var/lube_efficiency = 0.0

		if(src.reagents?.total_volume)
			for(var/reagent_id as anything in src.reagents.reagent_list)
				var/datum/reagent/R = src.reagents.reagent_list[reagent_id]
				// Iterate over reagents looking for sweet sweet lube
				if (reagent_id in circulator_preferred_reagents)
					lube_efficiency += (R.volume/src.reagents.total_volume) * circulator_preferred_reagents[reagent_id]
				else if(R.is_solid())
					lube_efficiency += (R.volume/src.reagents.total_volume) * (0.4 * R.viscosity + 0.7 ) // -30% to +10% through linear transform
				else
					lube_efficiency += (R.volume/src.reagents.total_volume) * (0.2 * R.viscosity + 0.9 ) // -10% to +10% through linear transform
		else lube_efficiency = 0.60

		src.lube_boost = lube_efficiency

		if(src.generator?.transformation_mngr)
			src.generator.transformation_mngr.check_reagent_transformation()

	process()
		..()
		src.lube_loss_check()
		if(src.status & NOPOWER )	// Force off target pressure
			src.target_pressure_enabled = FALSE
		update_icon()

	update_icon()
		if(src.status & (BROKEN|NOPOWER))
			icon_state = "circ[side]-p"
		else if(src.last_pressure_delta >= src.min_circ_pressure)
			if(src.last_pressure_delta > ONE_ATMOSPHERE)
				icon_state = "circ[side]-run"
			else
				icon_state = "circ[side]-slow"
		else
			icon_state = "circ[side]-off"

		if(src.is_open_container())
			if(src.GetOverlayImage("open")) return 1

			var/icon/open_icon = icon('icons/obj/atmospherics/atmos.dmi',"can-oT")
			if(src.side == RIGHT_CIRCULATOR)
				open_icon.Flip(WEST)
				open_icon.Shift(SOUTH,5)
				open_icon.Shift(EAST,5)
			else
				open_icon.Shift(SOUTH,5)
				open_icon.Shift(WEST,5)
			src.UpdateOverlays(image(open_icon), "open")
		else
			src.UpdateOverlays(null, "open")

		if(src.variant_b_active)
			UpdateOverlays(image('icons/obj/atmospherics/pipes.dmi', "circ[side]-o1"), "variant")
		else
			UpdateOverlays(null, "variant")

		return 1

/obj/machinery/atmospherics/binary/circulatorTemp/right
	icon_state = "circ2-off"
	name = "cold gas circulator"


/datum/action/bar/icon/teg_circulator_repair
	id = "teg_circulator_repair1"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 200
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/atmospherics/binary/circulatorTemp/circ
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			circ = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (circ == null || the_tool == null || owner == null || !in_interact_range(circ, owner))
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		// Weld > Crowbar > Rods > Weld
		if (circ.repairstate == 1)
			playsound(get_turf(circ), "sound/items/Welder.ogg", 50, 1)
			owner.visible_message("<span class='notice'>[owner] begins to cut up the damaged piping of the lubrication system.</span>")
		if (circ.repairstate == 2)
			owner.visible_message("<span class='notice'>[owner] begins prying out the damaged lubrication system.</span>")
			playsound(get_turf(circ), "sound/items/Crowbar.ogg", 60, 1)
		if (circ.repairstate == 3)
			playsound(get_turf(circ), "sound/impact_sounds/Generic_Stab_1.ogg", 60, 1)
			owner.visible_message("<span class='notice'>[owner] begins replacing the sections of lubrication piping.</span>")
		if (circ.repairstate == 4)
			playsound(get_turf(circ), "sound/items/Welder.ogg", 60, 1)
			owner.visible_message("<span class='notice'>[owner] begins to weld the lubrication piping.</span>")

	onEnd()
		..()
		// Weld > Crowbar > Rods > Weld
		if (circ.repairstate == 1)
			circ.repairstate = 2
			boutput(owner, "<span class='notice'>You slice up the damage piping for removal.</span>")
			playsound(get_turf(circ), "sound/items/Deconstruct.ogg", 80, 1)
			circ.repair_desc = "Lubrication system is a mess but you should be able to pry it out now."
			return
		if (circ.repairstate == 2)
			circ.repairstate = 3
			boutput(owner, "<span class='notice'>You pry out the damaged lubrication system.</span>")
			playsound(get_turf(circ), "sound/items/Deconstruct.ogg", 80, 1)
			circ.repair_desc = "Lubrication system piping is missing, should be able to make a new one out of rods."
			return

		if (circ.repairstate == 3)
			circ.repairstate = 4
			boutput(owner, "<span class='notice'>You finish rebuilding the lubrication system.</span>")
			playsound(get_turf(circ), "sound/items/Deconstruct.ogg", 80, 1)
			circ.repair_desc = "Lubrication system is nearly fixed, just have to weld a few pipes."
			if (the_tool != null)
				the_tool.amount -= 5
				if(the_tool.amount <= 0)
					qdel(the_tool)
				else if(istype(the_tool, /obj/item/rods))
					var/obj/item/rods/R = the_tool
					R.update_icon()
			return

		if (circ.repairstate == 4)
			circ.repairstate = 0
			circ.circulator_flags ^= LEAKS_LUBE
			circ.reagents_consumed = initial(circ.reagents_consumed)
			circ.lube_cycle_duration = initial(circ.lube_cycle_duration)
			circ.repair_desc = ""
			boutput(owner, "<span class='notice'>You finish welding the replacement lubrication system, the circulator is again in working condition.</span>")
			playsound(get_turf(circ), "sound/items/Deconstruct.ogg", 80, 1)

datum/pump_ui/circulator_ui
	value_name = "Target Transfer Pressure"
	value_units = "kPa"
	min_value = 0
	max_value = 1e5
	incr_sm = 10
	incr_lg = 100
	var/obj/machinery/atmospherics/binary/circulatorTemp/our_circ

	New(obj/machinery/atmospherics/binary/circulatorTemp/C)
		..()
		src.our_circ = C
		pump_name = "Blower Manual Override"

	set_value(val)
		our_circ.target_pressure = val

	toggle_power()
		our_circ.target_pressure_enabled = !our_circ.target_pressure_enabled

	is_on()
		return our_circ.target_pressure_enabled

	get_value()
		return our_circ.target_pressure

	get_atom()
		return our_circ


/obj/machinery/power/monitor
	name = "Power Monitoring Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"
	density = 1
	anchored = 1

/obj/machinery/power/generatorTemp
	name = "generator"
	desc = "A high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = 1
	density = 1
	//var/lightsbusted = 0

	var/obj/machinery/atmospherics/binary/circulatorTemp/circ1
	var/obj/machinery/atmospherics/binary/circulatorTemp/right/circ2
	var/list/obj/machinery/power/furnace/furnaces
	var/datum/teg_transformation/active_form
	var/datum/teg_transformation_mngr/transformation_mngr
	var/obj/item/teg_semiconductor/semiconductor

	var/lastgen = 0
	var/lastgenlev = -1
	var/overloaded = 0
	var/running = 0
	var/spam_limiter = 0  // stop the lights and icon updates from spazzing out as much at the threshold between power tiers
	var/efficiency_controller = 52 // cogwerks - debugging/testing var
	var/datum/light/light
	var/variant_a = null
	var/variant_b = null
	var/variant_description
	var/conductor_temp = T20C
	var/semiconductor_state = TEG_SEMI_STATE_INSTALLED

	var/semiconductor_repair

	var/warning_light_desc = null // warning light description

	var/boost = 0
	var/generator_flags = 0
	var/last_max_warning

	var/grump = 0 // best var 2013
	var/static/list/grump_prefix
	var/static/list/grump_suffix

	var/sound_engine1 = 'sound/machines/tractor_running.ogg'
	var/sound_engine2 = 'sound/machines/engine_highpower.ogg'
	var/sound_tractorrev = 'sound/machines/tractorrev.ogg'
	var/sound_engine_alert1 = 'sound/machines/engine_alert1.ogg'
	var/sound_engine_alert2 = 'sound/machines/engine_alert2.ogg'
	var/sound_engine_alert3 = 'sound/machines/engine_alert3.ogg'
	var/sound_bigzap = 'sound/effects/elec_bigzap.ogg'
	var/sound_bellalert = 'sound/machines/bellalert.ogg'
	var/sound_warningbuzzer = 'sound/machines/warning-buzzer.ogg'

	var/list/history
	var/const/history_max = 50

	proc/generate_variants(a=null,b=null)
		// CIRC-122333-4-5
		// 	1 - RNG (Fluff Family/Location of Assembly)
		// 	2 - Variant A (Minor Variants to impact circulator)
		// 	3 - RNG (Fluff unique identifier for QA and root cause analysis)
		//  4 - L or R depending on circulator
		// 	5 - Variant B (Major Variants "Experimental" to impact generator) these should only happen occasionally
		var/prepend_serial_num = "[pick(consonants_upper)]" // Lore: Production facility identifier
		var/instructions_footnote = ""

		if(is_null_or_space(a))
			//Set initial value for standard variants
			src.variant_a = rand(10,19)
			//New Variant A to follow and are identified by numerical ranges
		else src.variant_a = a

		if(is_null_or_space(b))
			if(prob(30)) src.variant_b = pick(uppercase_letters)
		else src.variant_b = b

		if(src.variant_b)
			if(src.variant_b in list("A","B","C","D"))
				src.generator_flags |= TEG_HIGH_TEMP
				instructions_footnote += {"<b><i>Note</i>: Thermo-Electric Generator utilizes experimental alloys optimized for temperatures above 4358K.</b><br>"}
				variant_description = "An experimental Thermo-Electric Generator! Based on the conductive material it looks like it may be for extremely high temperatures. "
			else if(src.variant_b in list("E","F","G","H"))
				src.generator_flags |= TEG_LOW_TEMP
				instructions_footnote += {"<b><i>Note</i>: Thermo-Electric Generator utilizes experimental alloys optimized for temperatures below 1550K.</b><br>"}
				variant_description = "An experimental Thermo-Electric Generator! Based on the conductive material it looks like it may be designed for cooler temperatures. "
			else
				// Reassign variant_b to null so unsupported variants aren't shown to players
				// to avoid confusion
				src.variant_b = null
				variant_description = null

		src.circ1?.assign_variant(prepend_serial_num, src.variant_a, src.variant_b)
		src.circ2?.assign_variant(prepend_serial_num, src.variant_a, src.variant_b)

		src.updateicon()
		src.circ1?.update_icon()
		src.circ2?.update_icon()

		// Note:
		// 	THIS WILL NEED TO BE UPDATE IFF WE HAVE MORE THAN 1 TEG PER dmm/zlevel...
		//
		// Iterate over TEG instructions on our current zlevel to account for prefabs.
		for_by_tcl(instructions, /obj/item/paper/engine)
			if(src.z == instructions.z) // Ensure instructions are only updated for relevant Z level.
				instructions.info = initial(instructions.info) + instructions_footnote

	New()
		..()

		//List init
		history = list()
		furnaces = list()
		transformation_mngr = new(src)
		grump_prefix = list("an upsetting", "an unsettling", "a scary", "a loud", "a sassy", "a grouchy", "a grumpy",
												"an awful", "a horrible", "a despicable", "a pretty rad", "a godawful")
		grump_suffix = list("noise", "racket", "ruckus", "sound", "clatter", "fracas", "hubbub")

		light = new /datum/light/point
		light.attach(src)

		SPAWN_DBG(0.5 SECONDS)
			src.circ1 = locate(/obj/machinery/atmospherics/binary/circulatorTemp) in get_step(src,WEST)
			src.circ2 = locate(/obj/machinery/atmospherics/binary/circulatorTemp) in get_step(src,EAST)
			if(!src.circ1 || !src.circ2)
				src.status |= BROKEN

			src.circ1?.generator = src
			src.circ1?.side = LEFT_CIRCULATOR
			src.circ2?.generator = src
			src.circ2?.side = RIGHT_CIRCULATOR
			src.transformation_mngr.generator = src

			//furnaces
			for(var/obj/machinery/power/furnace/F in orange(15, src.loc))
				src.furnaces += F

			src.generate_variants()

			if(!src.semiconductor)
				semiconductor = new(src)

			updateicon()

	disposing()
		src.circ1?.generator = null
		src.circ1 = null
		src.circ2?.generator = null
		src.circ2 = null
		qdel(transformation_mngr)
		src.active_form = null
		..()

	get_desc(dist, mob/user)
		if(dist <= 5 && semiconductor_repair)
			. += "<br>[semiconductor_repair]"

	proc/updateicon()

		if(status & (NOPOWER))
			UpdateOverlays(null, "power")
		else if(status & (BROKEN))
			UpdateOverlays(image('icons/obj/power.dmi', "teg-err"), "power")
		else
			if(lastgenlev != 0)
				UpdateOverlays(image('icons/obj/power.dmi', "teg-op[lastgenlev]"), "power")
			else
				UpdateOverlays(null, "power")

		if(src.variant_b)
			UpdateOverlays(image('icons/obj/power.dmi', "teg_var"), "variant")
		else
			UpdateOverlays(null, "variant")

		var/max_warning = src.circ1?.warning_active | src.circ2?.warning_active
		if( max_warning )
			if(max_warning > WARNING_5MIN && !(src.status & (BROKEN | NOPOWER)))
				if(!ON_COOLDOWN(src, "klaxon", 10 SECOND))
					playsound(src.loc, "sound/misc/klaxon.ogg", 40, pitch=1.1)
			var/warning_side = 0
			if( src.circ1?.warning_active && src.circ2?.warning_active )
				warning_side = NORTH
			else if( src.circ1?.warning_active )
				warning_side = WEST
			else if( src.circ2?.warning_active )
				warning_side = EAST

			// Use single light if we are variant b (only has one light) OR if we are ONLY in the APC draining state
			var/one_light = src.variant_b || ( max_warning == WARNING_APC_DRAINING )
			var/image/warning = image('icons/obj/power.dmi', one_light ? "tegv_lights" : "teg_lights", dir=warning_side)
			if(max_warning > WARNING_5MIN)
				warning.color = "#ff0000"
				warning_light_desc = "<br><span class='alert'>The power emergency lights are flashing.</span>"
			else
				warning.color = "#feb308"
				warning_light_desc = "<br><span class='alert'>The power caution light[one_light ? " is" : "s are"] flashing.</span>"
			UpdateOverlays(warning, "warning")

			if(lastgenlev)
				if(max_warning > WARNING_5MIN)
					light.set_color(1, 0, 0)
				else
					light.set_color(1.0, 0.70, 0.03)
				light.set_brightness(0.6)
				light.enable()
			else
				light.disable()

		else
			UpdateOverlays(null, "warning")
			warning_light_desc = null

			switch (lastgenlev)
				if(0)
					light.disable()
				if(1 to 11)
					light.set_color(1, 1, 1)
					light.set_brightness(0.3)
				if(12 to 15)
					light.set_color(0.30, 0.30, 0.90)
					light.set_brightness(0.6)
					light.enable()
				if(16 to 17)
					light.set_color(0.90, 0.90, 0.10)
					light.set_brightness(0.6)
					light.enable()
				if(18 to 22)
					playsound(src.loc, "sound/effects/elec_bzzz.ogg", 50,0)
					light.set_color(0.90, 0.10, 0.10)
					light.set_brightness(0.6)
					light.enable()
				if(18 to 25)
					playsound(src.loc, "sound/effects/elec_bigzap.ogg", 50,0)
					light.set_color(0.90, 0.10, 0.10)
					light.set_brightness(1)
					light.enable()
				if(26 to INFINITY)
					playsound(src.loc, "sound/effects/electric_shock.ogg", 50,0)
					light.set_color(0.90, 0.00, 0.90)
					light.set_brightness(1.5)
					light.enable()
					// this needs a safer lightbust proc

	process()
		if(!src.circ1 || !src.circ2)
			return

		var/datum/gas_mixture/hot_air = src.circ1.return_transfer_air()
		var/datum/gas_mixture/cold_air = src.circ2.return_transfer_air()

		var/swapped = 0

		if(hot_air && cold_air && hot_air.temperature < cold_air.temperature)
			var/swapTmp = hot_air
			hot_air = cold_air
			cold_air = swapTmp
			swapped = 1

		lastgen = 0

		if(!(src.status & BROKEN) && cold_air && hot_air)
			var/cold_air_heat_capacity = HEAT_CAPACITY(cold_air)
			var/hot_air_heat_capacity = HEAT_CAPACITY(hot_air)

			var/delta_temperature = hot_air.temperature - cold_air.temperature

			// uncomment to debug
			// logTheThing("debug", null, null, "pre delta, cold temp = [cold_air.temperature], hot temp = [hot_air.temperature]")
			// logTheThing("debug", null, null, "pre prod, delta : [delta_temperature], cold cap [cold_air_heat_capacity], hot cap [hot_air_heat_capacity]")
			if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
				// carnot efficiency * 65%
				var/efficiency = (1 - cold_air.temperature/hot_air.temperature) * src.get_efficiency_scale(delta_temperature, hot_air_heat_capacity, cold_air_heat_capacity) //controller expressed as a percentage

				// energy transfer required to bring the hot and cold loops to thermal equilibrium (accounting for the energy removed by the engine)
				var/energy_transfer = delta_temperature * hot_air_heat_capacity * cold_air_heat_capacity / (hot_air_heat_capacity + cold_air_heat_capacity - hot_air_heat_capacity*efficiency)
				hot_air.temperature -= energy_transfer/hot_air_heat_capacity

				lastgen = energy_transfer*efficiency
				add_avail(lastgen WATTS)

				src.history += src.lastgen
				if (src.history.len > src.history_max)
					src.history.Cut(1, 2) //drop the oldest entry

				cold_air.temperature += energy_transfer*(1-efficiency)/cold_air_heat_capacity // pass the remaining energy through to the cold side

				// uncomment to debug
				// logTheThing("debug", null, null, "POWER: [lastgen] W generated at [efficiency*100]% efficiency and sinks sizes [cold_air_heat_capacity], [hot_air_heat_capacity]")
		// update icon overlays only if displayed level has changed

		if(swapped)
			var/swapTmp = hot_air
			hot_air = cold_air
			cold_air = swapTmp

		if(hot_air) src.circ1.circulate_gas(hot_air)
		if(cold_air) src.circ2.circulate_gas(cold_air)

		desc = "Current Output: [engineering_notation(lastgen)]W [warning_light_desc]"
		var/genlev = max(0, min(round(26*lastgen / 4000000), 26)) // raised 2MW toplevel to 3MW, dudes were hitting 2mw way too easily
		var/warnings = src.circ1?.warning_active | src.circ2?.warning_active

		if(((genlev != lastgenlev) || (warnings != last_max_warning)) && !spam_limiter)
			spam_limiter = 1
			lastgenlev = genlev
			last_max_warning = warnings
			updateicon()
			if(!genlev)
				running = 0
			else if (genlev && !running)
				playsound(src.loc, sound_tractorrev, 55, 0)
				running = 1
			SPAWN_DBG(0.5 SECONDS)
				spam_limiter = 0
		else if(warnings > WARNING_5MIN && !(src.status & (BROKEN | NOPOWER)))
			// Allow for klaxon to trigger when off cooldown if updateicon() not called
			if(!ON_COOLDOWN(src, "klaxon", 10 SECOND))
				playsound(src.loc, "sound/misc/klaxon.ogg", 40, pitch=1.1)

		process_grump()

		src.transformation_mngr.check_material_transformation()

	proc/get_efficiency_scale(delta_temperature, heat_capacity, cold_capacity)
		var/efficiency_scale = efficiency_controller

		if(src.generator_flags & (TEG_HIGH_TEMP | TEG_LOW_TEMP))
			var/heat = delta_temperature * (heat_capacity* cold_capacity /(heat_capacity + cold_capacity))
			src.conductor_temp += heat/heat_capacity
			src.conductor_temp -= heat/cold_capacity
			src.conductor_temp = max(src.conductor_temp, 1)

			if(src.generator_flags & TEG_HIGH_TEMP)
				efficiency_scale += clamp(-15 + 1.79 * log(src.conductor_temp), -5, 15)
			else if(src.generator_flags & TEG_LOW_TEMP)
				efficiency_scale += clamp(46.5 + -6.33 * log(src.conductor_temp), -15, 15)

		return efficiency_scale * 0.01

	attackby(obj/item/W as obj, mob/user as mob)
		// Weld > Crowbar > Rods > Weld
		switch(semiconductor_state)
			if(TEG_SEMI_STATE_INSTALLED)
				if (istool(W, TOOL_SCREWING))
					actions.start(new /datum/action/bar/icon/teg_semiconductor_removal(src, W, 5 SECONDS), user)
					return
			if(TEG_SEMI_STATE_UNSCREWED)
				if (istool(W, TOOL_SNIPPING))
					actions.start(new /datum/action/bar/icon/teg_semiconductor_removal(src, W, 5 SECONDS), user)
					return
				if (istool(W, TOOL_SCREWING))
					actions.start(new /datum/action/bar/icon/teg_semiconductor_replace(src, W, 5 SECONDS), user)
					return
			if(TEG_SEMI_STATE_CONNECTED)
				if (istool(W, TOOL_SNIPPING))
					actions.start(new /datum/action/bar/icon/teg_semiconductor_replace(src, W, 5 SECONDS), user)
					return
			if(TEG_SEMI_STATE_DISCONNECTED)
				if (istool(W, TOOL_PRYING))
					actions.start(new /datum/action/bar/icon/teg_semiconductor_removal(src, W, 5 SECONDS), user)
					return
				if (istype(W, /obj/item/cable_coil))
					var/obj/item/cable_coil/C = W
					if (C.amount >= 4)
						actions.start(new /datum/action/bar/icon/teg_semiconductor_replace(src, W, 5 SECONDS), user)
						return
			if(TEG_SEMI_STATE_MISSING)
				if(istype(W,/obj/item/teg_semiconductor))
					actions.start(new /datum/action/bar/icon/teg_semiconductor_replace(src, W, 5 SECONDS), user)
					return

		..()

	proc/process_grump()
		var/stoked_sum = 0
		if(lastgenlev > 0)
			if(grump < 0) grump = 0 // no negative grump plz
			grump++ // get grump'd

		for(var/obj/machinery/power/furnace/F as anything in src.furnaces)
			if( F.active ) stoked_sum += F.stoked

		if(stoked_sum > 10)
			if(prob(50)) grump--
			if(prob(5)) grump -= min(stoked_sum/10, 15)

		// Use classic grump if not handled by variant
		if(!src.active_form?.on_grump(src))
			classic_grump()

	// engine looping sounds and hazards
	proc/classic_grump()
		if(grump >= 100 && prob(5))
			playsound(src.loc, pick(sounds_enginegrump), 70, 0)
			src.audible_message("<span class='alert'>[src] makes [pick(grump_prefix)] [pick(grump_suffix)]!</span>")
			grump -= 5

		switch (lastgenlev)
			if(0) return
			if(1 to 2)
				playsound(src.loc, sound_engine1, 60, 0)
				if(prob(5))
					playsound(src.loc, pick(sounds_engine), 70, 0)
			if(3 to 11)
				playsound(src.loc, sound_engine1, 60, 0)
			if(12 to 15)
				playsound(src.loc, sound_engine2, 60, 0)
			if(16 to 18)
				playsound(src.loc, sound_bellalert, 60, 0)
				if (prob(5))
					elecflash(src, power = 3)
			if(19 to 21)
				playsound(src.loc, sound_warningbuzzer, 50, 0)
				if (prob(5))
					var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
					smoke.set_up(1, 0, src.loc)
					smoke.attach(src)
					smoke.start()
					src.visible_message("<span class='alert'>[src] starts smoking!</span>")
				if (grump >= 100 && prob(5))
					playsound(src.loc, "sound/machines/engine_grump1.ogg", 50, 0)
					src.visible_message("<span class='alert'>[src] erupts in flame!</span>")
					fireflash(src, 1)
					grump -= 10
			if(22 to 23)
				playsound(src.loc, sound_engine_alert1, 55, 0)
				if (prob(5)) zapStuff()
				if (prob(5))
					var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
					smoke.set_up(1, 0, src.loc)
					smoke.attach(src)
					smoke.start()
					src.visible_message("<span class='alert'>[src] starts smoking!</span>")
				if (grump >= 100 && prob(5))
					playsound(src.loc, "sound/machines/engine_grump1.ogg", 50, 0)
					src.visible_message("<span class='alert'>[src] erupts in flame!</span>")
					fireflash(src, rand(1,3))
					grump -= 30

			if(24 to 25)
				playsound(src.loc, sound_engine_alert1, 55, 0)
				if (prob(10)) // lowering a bit more
					zapStuff()
				if (prob(5))
					var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
					smoke.set_up(1, 0, src.loc)
					smoke.attach(src)
					smoke.start()
					src.visible_message("<span class='alert'>[src] starts smoking!</span>")
				if (grump >= 100 && prob(10)) // probably not good if this happens several times in a row
					playsound(src.loc, "sound/weapons/rocket.ogg", 50, 0)
					src.visible_message("<span class='alert'>[src] explodes in flame!</span>")
					var/firesize = rand(1,4)
					fireflash(src, firesize)
					for(var/atom/movable/M in view(firesize, src.loc)) // fuck up those jerkbag engineers
						if(M.anchored) continue
						if(ismob(M)) if(hasvar(M,"weakened")) M:changeStatus("weakened", 80)
						if(ismob(M)) random_brute_damage(M, 10)
						if(ismob(M))
							var/atom/targetTurf = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
							M.throw_at(targetTurf, 200, 4)
						else if (prob(15)) // cut down the number of other junk things that get blown around
							var/atom/targetTurf = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
							M.throw_at(targetTurf, 200, 4)
					grump -= 30

			if(26 to INFINITY)
				playsound(src.loc, sound_engine_alert3, 55, 0)
				if(grump >= 100 && prob(6))
					src.audible_message("<span class='alert'><b>[src] [pick("resonates", "shakes", "rumbles", "grumbles", "vibrates", "roars")] [pick("dangerously", "strangely", "ominously", "frighteningly", "grumpily")]!</b></span>")
					playsound(src.loc, "sound/effects/explosionfar.ogg", 65, 1)
					for (var/obj/window/W in range(6, src.loc)) // smash nearby windows
						if (W.health_max >= 80) // plasma glass or better, no break please and thank you
							continue
						if (prob(get_dist(W,src.loc)*6))
							continue
						W.health = 0
						W.smash()
					for (var/mob/living/M in range(6, src.loc))
						shake_camera(M, 3, 16)
						M.changeStatus("weakened", 1 SECOND)
					for (var/atom/A in range(rand(1,3), src.loc))
						if (istype(A, /turf/simulated))
							A.pixel_x = rand(-1,1)
							A.pixel_y = rand(-1,1)
					grump -= 30

					if(src.lastgen >= 10000000)
						for (var/turf/T in range(6, src))
							var/T_dist = get_dist(T, src)
							var/T_effect_prob = 100 * (1 - (max(T_dist-1,1) / 5))

							for (var/obj/item/I in T)
								if ( prob(T_effect_prob) )
									animate_float(I, 1, 3)

				if (prob(33)) // lowered because all the DEL procs related to zap are stacking up in the profiler
					zapStuff()
				if(prob(5))
					src.audible_message("<span class='alert'>[src] [pick("rumbles", "groans", "shudders", "grustles", "hums", "thrums")] [pick("ominously", "oddly", "strangely", "oddly", "worringly", "softly", "loudly")]!</span>")
				else if (prob(2))
					src.visible_message("<span class='alert'><b>[src] hungers!</b></span>")
				// todo: sorta run happily at this extreme level as long as it gets a steady influx of corpses OR WEED into the furnaces

	proc/zapStuff()
		var/atom/target = null
		var/atom/last = src

		var/list/starts = new/list()
		for(var/atom/movable/M in orange(3, src))
			if(istype(M, /obj/overlay/tile_effect) || M.invisibility) continue
			starts.Add(M)

		if(!starts.len) return

		if(prob(10))
			var/person = null
			person = (locate(/mob/living) in starts)
			if(person)
				target = person
			else
				target = pick(starts)
		else
			target = pick(starts)

		if(isturf(target))
			return //This should not be possible. But byond.

		playsound(target, sound_bigzap, 40, 1)

		for(var/count=0, count<3, count++)

			if(target == null) break

			var/list/affected = DrawLine(last, target, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

			for(var/obj/O in affected)
				SPAWN_DBG(0.6 SECONDS) pool(O)

			//var/turf/currTurf = get_turf(target)
			//currTurf.hotspot_expose(2000, 400)

			if(isliving(target)) //Probably unsafe.
				target:TakeDamage("chest", 0, 20)

			var/list/next = new/list()
			for(var/atom/movable/M in orange(2, target))
				if(istype(M, /obj/overlay/tile_effect) || istype(M, /obj/line_obj/elec) || M.invisibility) continue
				next.Add(M)

			last = target
			target = pick(next)

	power_change()
		..()
		// Why don't the circulators get this from the APC directly?
		src.circ1?.power_change()
		src.circ2?.power_change()
		updateicon()

/obj/machinery/power/generatorTemp/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TEG", src.name)
		ui.open()

/obj/machinery/power/generatorTemp/ui_data(mob/user)
	. = list(
		"output" = src.lastgen,
		"history" = src.history,
	)
	if(src.circ1)
		. += list(
			"hotCircStatus" = src.circ1,
			"hotInletTemp" = src.circ1.air1.temperature,
			"hotOutletTemp" = src.circ1.air2.temperature,
			"hotInletPres" = MIXTURE_PRESSURE(src.circ1.air1) KILO PASCALS,
			"hotOutletPres" = MIXTURE_PRESSURE(src.circ1.air2) KILO PASCALS,
		)
	else
		. += list(
			"hotCircStatus" = null,
			"hotInletTemp" = 0,
			"hotOutletTemp" = 0,
			"hotInletPres" = 0,
			"hotOutletPres" = 0,
		)
	if(src.circ2)
		. += list(
			"coldCircStatus" = src.circ2,
			"coldInletTemp" = src.circ2.air1.temperature,
			"coldOutletTemp" = src.circ2.air2.temperature,
			"coldInletPres" = MIXTURE_PRESSURE(src.circ2.air1) KILO PASCALS,
			"coldOutletPres" = MIXTURE_PRESSURE(src.circ2.air2) KILO PASCALS,
		)
	else
		. += list(
			"coldCircStatus" = null,
			"coldInletTemp" = 0,
			"coldOutletTemp" = 0,
			"coldInletPres" = 0,
			"coldOutletPres" = 0,
		)

/*
  0         1         	2         	3        	4
Present 	Unscrewed  Connected 	Unconnected		Missing
     (Screw)                (Snip)        (Pry)              >>-->> REMOVAL
     (Screw)                (Snip)        (COIL)   (Item)		<<--<< REPLACEMNT
*/

/datum/action/bar/icon/teg_semiconductor_removal
	id = "teg_semiconductor_removal"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 15 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/power/generatorTemp/generator
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			generator = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (generator == null || the_tool == null || owner == null || !in_interact_range(generator, owner))
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		// SCREW->SNIP->CROW (REMOVAL)
		switch( generator.semiconductor_state )
			if (TEG_SEMI_STATE_INSTALLED)
				owner.visible_message("<span class='notice'>[owner] begins to dismantle \the [generator] to get access to the semiconductor.</span>")
				playsound(get_turf(generator), "sound/items/Screwdriver.ogg", 50, 1)
			if (TEG_SEMI_STATE_UNSCREWED)
				owner.visible_message("<span class='notice'>[owner] begins to snip wiring between the semiconductor and \the [generator].</span>")
				playsound(get_turf(generator), "sound/items/Scissor.ogg", 60, 1)
			if (TEG_SEMI_STATE_DISCONNECTED)
				owner.visible_message("<span class='notice'>[owner] begins prying out the semiconductor from \the [generator].</span>")
				playsound(get_turf(generator), "sound/items/Crowbar.ogg", 60, 1)

	onEnd()
		..()
		// SCREW->SNIP->CROW (REMOVAL)
		switch( generator.semiconductor_state )
			if (TEG_SEMI_STATE_INSTALLED)
				generator.semiconductor_state = TEG_SEMI_STATE_UNSCREWED
				playsound(get_turf(generator), "sound/items/Screwdriver.ogg", 50, 1)
				owner.visible_message("<span class='notice'>[owner] opens up access to the semiconductor.</span>", "<span class='notice'>You unscrew \the [generator] to gain access to the semiconductor.</span>")
				generator.semiconductor_repair = "The semiconductor is visible and needs to be disconnected from the TEG with some wirecutters or closed up with a screwdriver."

			if (TEG_SEMI_STATE_UNSCREWED)
				generator.semiconductor_state = TEG_SEMI_STATE_DISCONNECTED
				boutput(owner, "<span class='notice'>You snip the last piece of the electrical system connected to the semiconductor.</span>")
				playsound(get_turf(generator), "sound/items/Scissor.ogg", 80, 1)
				generator.semiconductor_repair = "The semiconductor has been disconnected and can be pried out or reconnected with additional cable."
				generator.status = BROKEN // SEMICONDUCTOR DISCONNECTED IT BROKEN
				generator.updateicon()

			if (TEG_SEMI_STATE_DISCONNECTED)
				generator.semiconductor_state = TEG_SEMI_STATE_MISSING
				boutput(owner, "<span class='notice'>You finish prying the semiconductor out of \the [generator].</span>")
				playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 80, 1)
				generator.semiconductor_repair = "The semiconductor is missing..."

				generator.semiconductor.set_loc(get_turf(generator))
				generator.semiconductor = null

/datum/action/bar/icon/teg_semiconductor_replace
	id = "teg_semiconductor_removal"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration =  15 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/power/generatorTemp/generator
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			generator = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (generator == null || the_tool == null || owner == null || !in_interact_range(generator, owner))
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		// (INSERT)->(COIL)->SNIP->SCREW
		switch(generator.semiconductor_state)
			if (TEG_SEMI_STATE_MISSING)
				owner.visible_message("<span class='notice'>[owner] begins to insert [the_tool] into \the [generator].</span>")
				playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 60, 1)
			if (TEG_SEMI_STATE_DISCONNECTED)
				owner.visible_message("<span class='notice'>[owner] begins to wire up the semiconductor and \the [generator].</span>")
				playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 60, 1)
			if (TEG_SEMI_STATE_CONNECTED)
				owner.visible_message("<span class='notice'>[owner] begins cutting the excess wire from the semiconductor.</span>")
				playsound(get_turf(generator), "sound/items/Scissor.ogg", 60, 1)
			if (TEG_SEMI_STATE_UNSCREWED)
				owner.visible_message("<span class='notice'>[owner] begins to close up \the [generator] access to the semiconductor.</span>")
				playsound(get_turf(generator), "sound/items/Screwdriver.ogg", 50, 1)

	onEnd()
		..()
		// (INSERT)->(COIL)->SNIP->SCREW
		switch(generator.semiconductor_state)
			if (TEG_SEMI_STATE_MISSING)
				if (the_tool != null)
					src.generator.semiconductor = the_tool
					if(ismob(owner))
						var/mob/M = owner
						M.drop_item(the_tool)
					generator.semiconductor.set_loc(generator)

					generator.semiconductor_state = TEG_SEMI_STATE_DISCONNECTED
					playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 80, 1)
					owner.visible_message("<span class='notice'>[owner] places [the_tool] inside [generator].</span>", "<span class='notice'>You successfully place semiconductor inside \the [generator].</span>")
					generator.semiconductor_repair = "The semiconductor has been disconnected and can be pried out or reconnected with additional cable."

			if (TEG_SEMI_STATE_DISCONNECTED)
				if (the_tool != null)
					the_tool.amount -= 4
					if(the_tool.amount <= 0)
						qdel(the_tool)
					else if(istype(the_tool, /obj/item/cable_coil))
						var/obj/item/cable_coil/C = the_tool
						C.updateicon()

					generator.semiconductor_state = TEG_SEMI_STATE_CONNECTED
					boutput(owner, "<span class='notice'>You wire up the semicondoctor to \the [generator].</span>")
					playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 80, 1)
					generator.semiconductor_repair = "The semiconductor has been wired in but has excess cable that must be removed."
					generator.status &= ~BROKEN // SEMICONDUCTOR RECONNECTED IT UNBROKEN
					generator.updateicon()

			if (TEG_SEMI_STATE_CONNECTED)
				generator.semiconductor_state = TEG_SEMI_STATE_UNSCREWED
				boutput(owner, "<span class='notice'>You snip the excess wires from the semiconductor.</span>")
				playsound(get_turf(generator), "sound/items/Scissor.ogg", 80, 1)
				generator.semiconductor_repair = "The semiconductor is visible and needs to be disconnected from \the [generator] with some wirecutters or closed up with a screwdriver."

			if (TEG_SEMI_STATE_UNSCREWED)
				generator.semiconductor_state = TEG_SEMI_STATE_INSTALLED

				owner.visible_message("<span class='notice'>[owner] closes up access to the semiconductor in \the [generator].</span>", "<span class='notice'>You successfully replaced the semiconductor.</span>")
				playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 80, 1)
				generator.semiconductor_repair = null

/** Thermoelectric Generator Semiconductor - A beautiful array of thermopiles */
/obj/item/teg_semiconductor
	name = "Prototype Semiconductor"
	desc = "A large rectangulr plate stamped with 'Prototype Thermo-Electric Generator Semiconductor.  If found please return to NanoTrasen.'"
	icon = 'icons/obj/power.dmi'
	icon_state = "semi"

/obj/machinery/atmospherics/unary/furnace_connector
	icon = 'icons/obj/atmospherics/heat_reservoir.dmi'
	icon_state = "intact_off"
	density = 1

	name = "Furnace Connector"
	desc = "Used to connect a furnace to a pipe network."

	var/current_temperature = T20C
	var/current_heat_capacity = 3000

	update_icon()
		if(node)
			icon_state = "intact_on"
		else
			icon_state = "exposed"
		return

	process()
		..()
		return

	proc/heat()
		var/air_heat_capacity = HEAT_CAPACITY(air_contents)
		var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
		var/old_temperature = air_contents.temperature

		if(combined_heat_capacity > 0)
			var/combined_energy = current_temperature*current_heat_capacity + air_heat_capacity*air_contents.temperature
			air_contents.temperature = combined_energy/combined_heat_capacity

		if(abs(old_temperature-air_contents.temperature) > 1)
			if(network)
				network.update = 1
		return 1

/obj/machinery/power/furnace/thermo
	name = "Furnace"
	desc = "Generates Heat for the thermoelectric generator."
	icon_state = "furnace"
	anchored = 1
	density = 1
	mats = 20
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

	var/obj/machinery/atmospherics/unary/furnace_connector/f_connector = null
	var/datum/digital_filter/exponential_moving_average/heat_filter = new

	proc/get_connector()
		for(var/obj/machinery/atmospherics/unary/furnace_connector/C in src.loc)
			f_connector = C
			break
		return

	New()
		..()
		heat_filter.init_basic(0.25)
		get_connector()

	process()
		if(!f_connector) get_connector()
		if(!f_connector) return
		..()
/*
		if(src.active)
			if(src.fuel)
				var/additional_heat = src.fuel * 4
				f_connector.current_temperature = T20C + 200 + additional_heat
				f_connector.heat()
				fuel--

			if(!src.fuel)
				src.visible_message("<span class='alert'>[src] runs out of fuel and shuts down!</span>")
				src.overlays = null
				src.active = 0

		update_icon()

	/*	//Holy lag batman!
		src.overlays = null
		if (src.active) src.overlays +=
		if (fuelperc >= 20) src.overlays += image('icons/obj/power.dmi', "furn-c1")
		if (fuelperc >= 40) src.overlays += image('icons/obj/power.dmi', "furn-c2")
		if (fuelperc >= 60) src.overlays += image('icons/obj/power.dmi', "furn-c3")
		if (fuelperc >= 80) src.overlays += image('icons/obj/power.dmi', "furn-c4")

	*/
*/
	on_burn()
		var/datum/gas_mixture/environment = src.loc?.return_air()
		var/ambient_temp = T20C
		if(environment)
			ambient_temp = environment.temperature


		// -(1.2x - 1)^2 + 1 expands to 2.4x-1.44x^2
		// -0.48x*(3x-5)
		var/fuel_fuel_ratio = src.fuel/src.maxfuel
		var/fuel_burn_scale = ( -0.48 * fuel_fuel_ratio ) * ( (3*fuel_fuel_ratio)-5 )

		// charcoal actual high temp is 2500C
		var/additional_heat = fuel_burn_scale * (3000)

		src.f_connector.current_temperature = heat_filter.process(ambient_temp + 200 + additional_heat)
		f_connector.heat()

	on_inactive()
		var/datum/gas_mixture/environment = src.loc?.return_air()
		if(environment)
			heat_filter.process(environment.temperature)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define PUMP_POWERLEVEL_1 100
#define PUMP_POWERLEVEL_2 500
#define PUMP_POWERLEVEL_3 1000
#define PUMP_POWERLEVEL_4 2500
#define PUMP_POWERLEVEL_5 5000

/datum/pump_infoset
	var/power_status = 0
	var/target_output = 0
	var/id = ""

/obj/machinery/computer/atmosphere/pumpcontrol
	req_access = list() //Change
	req_access_txt = ""

	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"

	name = "Pump control computer"

	var/list/pump_infos

	var/last_change = 0
	var/message_delay = 1 MINUTE

	var/frequency = 1225
	var/datum/radio_frequency/radio_connection

	New()
		. = ..()
		pump_infos = new/list()

	attack_hand(mob/user)
		if(status & (BROKEN | NOPOWER))
			return
		user << browse(return_text(),"window=computer;can_close=1")
		src.add_dialog(user)
		onclose(user, "computer")

	process()
		..()
		if(status & (BROKEN | NOPOWER))
			return
		//src.updateUsrDialog()

	attackby(I as obj, user as mob)
			//Readd construction code + boards
		src.attack_hand(user)
		return

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption)
			return

		if(signal.data["device"] == "AGP")
			if (!signal.data["tag"] || !signal.data["power"] || !signal.data["target_output"])
				return

			var/datum/pump_infoset/I = new()
			I.id = signal.data["tag"]
			I.power_status = signal.data["power"]
			I.target_output = signal.data["target_output"]

			if (!(signal.source in pump_infos))
				var/area/pump_area = get_area(signal.source)
				if (istype(pump_area))
					var/area_label_position = pump_infos.Find(pump_area.name)
					if (area_label_position)
						while (1)
							area_label_position++
							if (area_label_position > pump_infos.len)
								break
							var/datum/pump_infoset/infoset = pump_infos[ pump_infos[area_label_position] ]
							if (!istype(infoset))
								break

							if (sorttext(I.id, infoset.id) == 1)
								break

						pump_infos.Insert(area_label_position, signal.source)

					else
						pump_infos += pump_area.name
						pump_infos += signal.source

			pump_infos[signal.source] = I

		src.updateUsrDialog()

	proc/return_text()
		var/pump_html = ""
		//var/count = 1
		for(var/A in pump_infos)
			if (istext(A))
				pump_html += "<center><b>[A]</b></center><br>"
				continue

			var/datum/pump_infoset/I = pump_infos[A]
			if (!istype(I))
				continue
			pump_html += "<B>[I.id] Status</B>:<BR>"
			//pump_html += "<B>Pump [count] Status</B>: <BR>"
			//pump_html += "	Pump Id: [I.id]<BR>"
			pump_html += "	Pump Status: <U><A href='?src=\ref[src];toggle=[I.id]'>[I.power_status == "on" ? "On":"Off"]</A></U><BR>"
			var/current_pump_level = 0
			switch (I.target_output)
				if (1 to PUMP_POWERLEVEL_1)
					current_pump_level = 1
				if (PUMP_POWERLEVEL_1 + 1 to PUMP_POWERLEVEL_2)
					current_pump_level = 2
				if (PUMP_POWERLEVEL_2 + 1 to PUMP_POWERLEVEL_3)
					current_pump_level = 3
				if (PUMP_POWERLEVEL_3 + 1 to PUMP_POWERLEVEL_4)
					current_pump_level = 4
				if (PUMP_POWERLEVEL_4 + 1 to INFINITY)
					current_pump_level = 5
			pump_html += "	Pump Pressure Level: "
			for (var/i =1, i < 6, i++)
				if (current_pump_level == i)
					pump_html += "<b>[i]</b> "
				else
					pump_html += "<A href='?src=\ref[src];setoutput=[i]&target=[I.id]'>[i]</A> "

			pump_html += "<BR><BR>"
			//count++

		var/output = "<B>[name]</B><BR><A href='?src=\ref[src];refresh=1'>Refresh</A><BR><HR><B>Pump Data: <BR><BR></B>[pump_html]<HR>"
		return output

	Topic(href, href_list)
		if(..())
			return
		if(!allowed(usr))
			boutput(usr, "<span class='alert'>Access Denied!</span>")
			return

		if(href_list["toggle"])
			src.add_fingerprint(usr)
			if(!radio_connection)
				return 0
			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio
			signal.source = src
			signal.data["tag"] = href_list["toggle"]
			signal.data["command"] = "power_toggle"
			radio_connection.post_signal(src, signal)

		if(href_list["setoutput"])
			src.add_fingerprint(usr)
			if(!radio_connection || !href_list["target"])
				return 0

			var/new_target = 0
			switch (href_list["setoutput"])
				if ("1")
					new_target = PUMP_POWERLEVEL_1
				if ("2")
					new_target = PUMP_POWERLEVEL_2
				if ("3")
					new_target = PUMP_POWERLEVEL_3
				if ("4")
					new_target = PUMP_POWERLEVEL_4
				if ("5")
					new_target = PUMP_POWERLEVEL_5

			if (!new_target)
				return

			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio
			signal.source = src
			signal.data["tag"] = href_list["target"]
			signal.data["command"] = "set_output_pressure"
			signal.data["parameter"] = new_target
			radio_connection.post_signal(src, signal)

		if(href_list["refresh"])
			src.add_fingerprint(usr)
			if(!radio_connection)
				return 0
			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio
			signal.source = src
			signal.data["command"] = "broadcast_status"
			radio_connection.post_signal(src, signal)
	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

	initialize()
		set_frequency(frequency)

#undef PUMP_POWERLEVEL_1
#undef PUMP_POWERLEVEL_2
#undef PUMP_POWERLEVEL_3
#undef PUMP_POWERLEVEL_4
#undef PUMP_POWERLEVEL_5
#undef LEFT_CIRCULATOR
#undef RIGHT_CIRCULATOR
#undef BASE_LUBE_CHECK_RATE
#undef BACKFLOW_PROTECTION
#undef LEAKS_GAS
#undef LEAKS_LUBE
#undef LUBE_DRAIN_OPEN
#undef WARNING_APC_DRAINING
#undef WARNING_5MIN
#undef WARNING_1MIN
#undef WARNING_LOW_MOLES
#undef TIME_PER_PROCESS
#undef WARNING_FAIL_5MIN_ITERS
#undef WARNING_FAIL_1MIN_ITERS

#undef TEG_HIGH_TEMP
#undef TEG_LOW_TEMP
#undef TEG_SEMI_STATE_INSTALLED
#undef TEG_SEMI_STATE_UNSCREWED
#undef TEG_SEMI_STATE_CONNECTED
#undef TEG_SEMI_STATE_DISCONNECTED
#undef TEG_SEMI_STATE_MISSING
