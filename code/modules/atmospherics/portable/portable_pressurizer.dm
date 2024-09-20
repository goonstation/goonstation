/// Fan Off
#define FAN_OFF 0
/// Fan On and pulling in from enviroment
#define FAN_ON_INLET 1
/// Fan On and pushing air out to enviroment
#define FAN_ON_OUTLET 2
/// No active material processing
#define PROCESS_OFF 0
/// Actively processing an item
#define PROCESS_ACTIVE 1
/// Material Processing Paused...
#define PROCESS_PAUSED 2
/// Minimum delay for armed blast
#define MIN_BLAST_DELAY (5 SECONDS)
/// Maximum delay for armed blast
#define MAX_BLAST_DELAY (30 SECONDS)
/// Minimum % pressure where visual effect and sonic boom
#define BLAST_EFFECT_RATIO (0.7)

/** Portable Pressurization Device
 *  Acts as a [/obj/machinery/portable_atmospherics/pump] + [/obj/machinery/manufacturer/gas]
 * 	Allows for input/output of enviromental air and will convert objects made of materials that produce gas to.. gas.
 * 	Once sufficient pressure has been reached it can be released spreading it across the current airgroup with a minor stun explosion.
  */
TYPEINFO(/obj/machinery/portable_atmospherics/pressurizer)
	mats = list("metal" = 15,
				"metal_dense" = 3,
				"insulated" = 3,
				"conductive" = 10)
/obj/machinery/portable_atmospherics/pressurizer
	name = "Extreme-Pressure Pressurization Device"
	desc = "Some kind of nightmare contraption to make a lot of noise or pressurize rooms."

	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "pressurizer"
	density = 1
	status = REQ_PHYSICAL_ACCESS
	flags = CONDUCT | TGUI_INTERACTIVE
	requires_power = FALSE //power only required for material processing
	p_class = 3

	var/fan_state = FAN_OFF
	var/process_materials = PROCESS_OFF
	var/blast_delay = 5 SECONDS
	var/blast_armed = FALSE
	var/min_blast_ratio = 0.2
	var/material_progress = 0
	/// Object actively being processed
	var/obj/item/target_material = null
	/// Default processable materials
	var/whitelist = list("molitz", "viscerite")
	/// Items enabled by emag
	var/blacklist = list("char", "plasmastone")
	var/release_pressure = ONE_ATMOSPHERE
	/// Rate at which materials will be processed
	var/process_rate = 2
	var/powconsumption = 0
	var/emagged = 0

	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_MULTITOOL

	var/image/image_fan
	var/image/image_fab
	var/image/image_blow
	volume = 750

	New()
		..()
		image_fan = image('icons/obj/atmospherics/atmos.dmi', "pressurizer-fan")
		image_fab = image('icons/obj/atmospherics/atmos.dmi', "pressurizer-fab")
		image_blow = image('icons/obj/atmospherics/atmos.dmi', "pressurizer-blow")

	process()
		..()
		if(!loc) return
		if(src.contained) return

		src.process_fan()

		if(src.contents.len && !src.process_materials)
			src.process_materials = PROCESS_ACTIVE
		if(process_materials)
			src.powconsumption = 500 * src.process_rate ** 2
			src.process_raw_materials()
			src.updateDialog()

		src.UpdateIcon()
		return

	update_icon()
		if(src.fan_state != FAN_OFF)
			UpdateOverlays(image_fan, "fan")
		else
			UpdateOverlays(null, "fan")

		if(src.process_materials)
			image_fab.color = null
			if(src.status & NOPOWER)
				image_fab.color = "#800"
			else if(src.process_materials == PROCESS_PAUSED)
				image_fab.color = "#dd0"
			else
				image_fab.color = "#0d0"
			UpdateOverlays(image_fab, "fab")
		else
			UpdateOverlays(null, "fab")

		if(src.blast_armed)
			UpdateOverlays(image_blow, "armed")
		else
			UpdateOverlays(null, "armed")

	return_air(direct = FALSE)
		return air_contents

	proc/process_fan()
		var/datum/gas_mixture/environment
		var/datum/gas_mixture/removed

		environment = loc.return_air()

		switch( fan_state)
			if(FAN_ON_OUTLET)
				var/pressure_delta = src.release_pressure - MIXTURE_PRESSURE(environment)
				var/transfer_moles = 0
				if(air_contents.temperature > 0)
					transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)
					removed = air_contents.remove(transfer_moles)
					loc.assume_air(removed)

			if(FAN_ON_INLET)
				var/transfer_rate = 200
				var/transfer_ratio = max(1, transfer_rate/environment.volume)

				if(MIXTURE_PRESSURE(src.air_contents) < src.maximum_pressure)
					removed = environment.remove_ratio(transfer_ratio)
					air_contents.merge(removed)

	proc/is_air_safe()
		var/total_moles = max(TOTAL_MOLES(src.air_contents),1)
		return(((src.air_contents.toxins/total_moles) < 0.01) && ((src.air_contents.carbon_dioxide/total_moles) < 0.05) && (src.air_contents.temperature < FIRE_MINIMUM_TEMPERATURE_TO_SPREAD))

	proc/process_raw_materials()
		if(status & NOPOWER)
			return

		if(!target_material)
			material_progress = 0
			if(length(src.contents))
				target_material = pick(src.contents)
				if((target_material.amount > 1) && (target_material.material?.getName() in src.whitelist))
					var/atom/movable/splitStack = target_material.split_stack(target_material.amount-1)
					splitStack.set_loc(src)
				target_material.set_loc(null)
			else
				process_materials = PROCESS_OFF
				return

		if(MIXTURE_PRESSURE(air_contents) > maximum_pressure*2)
			process_materials = PROCESS_PAUSED
			return
		else if(material_progress < 100)
			process_materials = PROCESS_ACTIVE
			var/progress = min(src.process_rate * 5,100-material_progress)
			var/datum/gas_mixture/GM = new /datum/gas_mixture
			GM.temperature = T20C
			if(target_material.material?.getName() in src.whitelist)
				switch(target_material.material.getName())
					if("molitz")
						GM.oxygen += 1500 * progress / 100
					if("viscerite")
						GM.nitrogen += 1500 * progress / 100
					if("char")
						GM.carbon_dioxide += 500 * progress / 100
					if("plasmastone")
						GM.toxins += 500 * progress / 100
			else
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 20)
				process_materials = PROCESS_PAUSED
				target_material?.set_loc(src.loc)
				target_material = null
				return
			src.air_contents.merge(GM)
			material_progress = clamp(material_progress + progress, 0, 100)
			use_power(src.powconsumption)
		else
			qdel(target_material)
			target_material = null

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user)
				user.show_text("You short out the material processor on [src].", "red")
			src.audible_message(SPAN_COMBAT("<B>[src] buzzes oddly!</B>"))
			playsound(src.loc, "sparks", 50, 1, -1)
			whitelist += blacklist
			src.emagged = TRUE
			return 1
		return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You repair [src]'s material processor.", "blue")
		src.emagged = FALSE
		src.process_rate = min(src.process_rate, 3)
		whitelist = initial(whitelist)
		return 1

	// attack by item places it in to disposal
	attackby(obj/item/I, mob/user)
		if(status & BROKEN)
			return
		if(iswrenchingtool(I) || istype(I,/obj/item/device/analyzer/atmospheric) || istype(I,/obj/item/card/emag))
			..()
			return
		if(istype(I,/obj/item/electronics/scanner) || istype(I,/obj/item/deconstructor) || (istype(I,/obj/item/device/pda2)))
			user.visible_message(SPAN_ALERT("<B>[user] hits [src] with [I]!</B>"))
			return
		if (istype(I,/obj/item/satchel/) && I.contents.len)
			var/obj/item/satchel/S = I
			for(var/obj/item/O in S.contents) O.set_loc(src)
			S.UpdateIcon()
			S.tooltip_rebuild = 1
			user.visible_message("<b>[user.name]</b> dumps out [S] into [src].")
			return
		if (length(I.storage?.get_contents()))
			for(var/obj/item/O in I.storage.get_contents())
				I.storage.transfer_stored_item(O, src, user = user)
				user.visible_message("<b>[user.name]</b> dumps out [I] into [src].")
			return

		var/obj/item/grab/G = I
		if(istype(G))	// handle grabbed mob
			if(ismob(G.affecting))
				boutput(user, SPAN_ALERT("That won't fit!"))
				return
		else
			if(!user.drop_item())
				return
			else if(I.w_class > W_CLASS_NORMAL)
				boutput(user, SPAN_ALERT("That won't fit!"))
				return
			I.set_loc(src)
			user.visible_message("[user.name] places \the [I] into \the [src].",\
			"You place \the [I] into \the [src].")
			actions.interrupt(user, INTERRUPT_ACT)

	// eject the contents of the unit
	proc/eject()
		for(var/atom/movable/AM in src)
			AM.set_loc(src.loc)

	proc/arm_blast()
		if(src.blast_armed)
			src.blast_armed = FALSE
		else
			var/blast_key = rand()
			blast_armed = blast_key
			SPAWN(blast_delay)
				if(src.blast_armed == blast_key && src.is_air_safe())
					blast_release()

	proc/blast_visual_effects(pressure)
		// Perform jump animation if more than 70% maximum pressure
		if(pressure > maximum_pressure * BLAST_EFFECT_RATIO)
			var/orig_x = src.pixel_x
			var/orig_y = src.pixel_y
			animate(src, pixel_x=orig_x, pixel_y=orig_y, flags=ANIMATION_PARALLEL, time=0.01 SECONDS)
			for(var/i in 1 to 3)
				animate(pixel_x=orig_x + rand(-2, 2), pixel_y=orig_y + rand(-2, 2), easing=JUMP_EASING, time=0.1 SECONDS)
			animate(pixel_x=orig_x, pixel_y=orig_y)

		var/obj/overlay/poof = new/obj/overlay(get_turf(src))
		poof.icon = 'icons/obj/atmospherics/atmos.dmi'
		poof.color=rgb(air_contents.toxins/TOTAL_MOLES(air_contents)*255, 	\
						air_contents.oxygen/TOTAL_MOLES(air_contents)*255,	\
						air_contents.oxygen+air_contents.toxins/TOTAL_MOLES(air_contents)*255)
		poof.alpha = clamp(MIXTURE_PRESSURE(src.air_contents)/src.maximum_pressure*180, 90, 220)
		flick("pressurizer-poof", poof)
		SPAWN(0.8 SECONDS)
			if(poof) qdel(poof)

	proc/blast_release()
		var/pressure = MIXTURE_PRESSURE(src.air_contents)
		src.blast_visual_effects(pressure)

		// Flashbang pressure wave is 30,000 psi thus 206 MPa
		var/volume = clamp(pressure KILO PASCALS / 206 MEGA PASCAL * 35, 15, 70)
		playsound(src, 'sound/effects/exlow.ogg', volume, 1)

		var/turf/simulated/T = get_turf(src)
		if(T && istype(T))
			if(T.air)
				// Use temporary gas mixture to not dispose air_contents through merge
				var/datum/gas_mixture/temp = air_contents.remove_ratio(1)
				if(T.parent?.group_processing)
					T.parent.air.merge(temp)
				else
					var/count = length(T.parent?.members)
					if(count)
						if(count>1)
							temp = temp.remove_ratio(1/count)
						var/datum/gas_mixture/GM
						for(var/turf/simulated/MT as() in T.parent.members)
							GM = new /datum/gas_mixture
							GM.copy_from(temp)
							MT.assume_air(GM)
					else
						T.assume_air(temp)

			if(pressure > (maximum_pressure * BLAST_EFFECT_RATIO))
				for(var/mob/living/HH in hearers(8, T))
					var/checkdist = GET_DIST(HH.loc, T)

					// Reduced sonic boom effect with increased misstep from shockwave
					var/misstep = clamp(1 + 10 * (5 - checkdist), 0, 40)
					var/ear_damage = max(0, (3 - checkdist))
					var/ear_tempdeaf = max(0, (5 - checkdist))
					var/stamina = clamp(30 * (7 - checkdist), 0, 120)
					HH.apply_sonic_stun(0, 0, misstep, 0, 2, ear_damage, ear_tempdeaf, stamina)

		src.blast_armed = FALSE
		UpdateIcon()

	proc/set_release_pressure(pressure as num)
		src.release_pressure = clamp(pressure, PORTABLE_ATMOS_MIN_RELEASE_PRESSURE, PORTABLE_ATMOS_MAX_RELEASE_PRESSURE)
		return TRUE

	proc/set_arm_delay(delay as num)
		src.blast_delay = clamp(delay, MIN_BLAST_DELAY, MAX_BLAST_DELAY)
		return TRUE

	proc/set_process_rate(rate as num)
		src.process_rate = clamp(rate, 1, (src.emagged ? 5 : 3))
		return TRUE


/obj/machinery/portable_atmospherics/pressurizer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Pressurizer", name)
		ui.open()

/obj/machinery/portable_atmospherics/pressurizer/ui_data(mob/user)
	. = list(
		"pressure" = MIXTURE_PRESSURE(src.air_contents),
		"connected" = src.connected_port ? TRUE : FALSE,
		"fanState" = src.fan_state,
		"maxPressure" = src.maximum_pressure,
		"releasePressure" = src.release_pressure,
		"blastArmed" = src.blast_armed,
		"blastDelay" = src.blast_delay/10,
		"minBlastPercent" = src.min_blast_ratio,
		"materialsCount" = length(src.contents),
		"materialsProgress" = src.material_progress,
		"targetMaterial" = src.target_material,
		"processRate" = src.process_rate,
		"emagged" = src.emagged,
		"airSafe" = src.is_air_safe()
	)

/obj/machinery/portable_atmospherics/pressurizer/ui_static_data(mob/user)
	. = list(
		"minRelease" = PORTABLE_ATMOS_MIN_RELEASE_PRESSURE,
		"maxRelease" = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE,
		"minArmDelay" = MIN_BLAST_DELAY/10,
		"maxArmDelay" = MAX_BLAST_DELAY/10,
	)

/obj/machinery/portable_atmospherics/pressurizer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("set-pressure")
			var/target_pressure = params["releasePressure"]
			if(isnum(target_pressure))
				. = set_release_pressure(target_pressure)

		if("arm")
			if(MIXTURE_PRESSURE(src.air_contents) < (maximum_pressure * min_blast_ratio) || !is_air_safe())
				return
			src.arm_blast()
			src.UpdateIcon()
			. = TRUE

		if("fan")
			var/target_mode = params["fanState"]
			src.fan_state = target_mode
			src.UpdateIcon()
			. = TRUE

		if("eject-materials")
			src.eject()
			. = TRUE

		if("set-blast-delay")
			var/target_delay = params["blastDelay"]
			if(isnum(target_delay))
				. = set_arm_delay(target_delay SECONDS)

		if("set-process_rate")
			var/target_rate = params["processRate"]
			if(isnum(target_rate))
				. = set_process_rate(target_rate)

#undef FAN_OFF
#undef FAN_ON_INLET
#undef FAN_ON_OUTLET
#undef PROCESS_OFF
#undef PROCESS_ACTIVE
#undef PROCESS_PAUSED
#undef MIN_BLAST_DELAY
#undef MAX_BLAST_DELAY
#undef BLAST_EFFECT_RATIO
