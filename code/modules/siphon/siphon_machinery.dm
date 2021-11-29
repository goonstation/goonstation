ABSTRACT_TYPE(/obj/machinery/siphon)
/obj/machinery/siphon
	New()
		..()

	disposing()
		..()

/obj/machinery/siphon/core
	name = "harmonic siphon"
	desc = "An egregiously complicated device purpose-built for turning magic space rocks into unmagic useful rocks."
	icon = 'icons/obj/machines/neodrill_32x64.dmi'
	icon_state = "drill-high"
	density = 1
	anchored = 1
	layer = 4
	power_usage = 200

	///sum of baseline draw from siphon and current draw from paired resonators
	var/total_draw
	///possible modes: high (raised and inactive), low (drill is set over hole, resonators lock in place), active (drilling)
	var/mode = "high"
	///true while toggling between high and low
	var/toggling = FALSE
	///list of paired resonators, built when drill enters active position
	var/list/resonators = list()
	///list of possible siphon targets for the siphon
	var/list/can_extract = list()
	///progress in extraction, incremented each process by total intensity of resonators; more valuable materials take more ticks to extract
	var/extract_ticks = 0
	///where extracted minerals are sent
	var/output_target = null

	//resonance parameters for mineral extraction
	var/x_torque = 0
	var/y_torque = 0
	var/shear = 0

	New()
		..()
		for(var/mineral in concrete_typesof(/datum/siphon_mineral))
			src.can_extract += new mineral

	disposing()
		..()

	process(var/mult)
		if (status & NOPOWER)
			return
		total_draw = 200
		if(src.mode == "active")
			src.calibrate_resonance()
			for(var/obj/machinery/siphon/resonator/res in src.resonators)
				total_draw += 150 * res.intensity
				src.extract_ticks += res.intensity

			src.extract_ticks++
			for(var/datum/siphon_mineral/M in src.can_extract)
				LAGCHECK(LAG_LOW)
				if(src.extract_ticks >= M.tick_req) //enough mining progress to check
					if(M.x_torque != null) //check if difference between spec and actual is within tolerance
						var/xtcheck = abs(src.x_torque - M.x_torque)
						if(xtcheck > M.sens_window) continue
					if(M.y_torque != null)
						var/ytcheck = abs(src.y_torque - M.y_torque)
						if(ytcheck > M.sens_window) continue
					if(M.shear != null)
						var/shearcheck = abs(src.shear - M.shear)
						if(shearcheck > M.sens_window) continue
					src.extract_ticks = 0
					var/atom/movable/yielder = new M.product()
					yielder.set_loc(src.get_output_location())
					break

			playsound(src.loc, 'sound/machines/interdictor_operate.ogg', 10, 0)
		power_usage = total_draw
		..()

	attackby(obj/item/W, mob/user)
		if(ispulsingtool(W) && src.mode != "high")
			src.calibrate_resonance()
			boutput(user,"LATERAL RESONANCE: [src.x_torque]")
			boutput(user,"VERTICAL RESONANCE: [src.y_torque]")
			boutput(user,"SHEAR VALUE: [src.shear]")
		else if(iswrenchingtool(W))
			var/diditwork = src.toggle_drill()
			if(diditwork)
				boutput(user,"You manually toggle the siphon's lift mechanism.")
			else
				if(src.mode == "active") boutput(user,"The siphon's lift mechanism can't be toggled while it's operational.")


	attack_hand(mob/user)
		var/diditwork = src.toggle_operating()
		if(diditwork)
			boutput(user,"You touch the siphon's activation panel.")
		else
			boutput(user,"The siphon's activation panel isn't active.")

	MouseDrop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the siphon's output target.</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>The siphon is too far away from the target.</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target.</span>")
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable crate as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set the siphon to output to [over_object].</span>")

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable cart as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set the siphon to output to [over_object].</span>")

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, "<span class='notice'>You set the siphon to output on top of [O].</span>")

		else if (istype(over_object,/turf/simulated/floor/) || istype(over_object,/turf/unsimulated/floor/))
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set the siphon to output to [over_object].</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	proc/get_output_location(var/atom/A,var/ejection = 0)
		if (!src.output_target)
			return src.loc

		if (get_dist(src.output_target,src) > 1)
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

	proc/changemode(var/newmode)
		src.mode = newmode
		switch(newmode)
			if("low")
				playsound(src, "sound/machines/click.ogg", 40, 1)
			if("active")
				playsound(src, "sound/machines/heater_on.ogg", 50, 1)
			if("high")
				playsound(src, "sound/machines/pc_process.ogg", 30, 0)
		src.update_fx()

	proc/toggle_drill()
		. = TRUE
		if(src.toggling) return FALSE
		if(src.mode == "high")
			src.engage_drill()
		else
			src.disengage_drill()

	proc/toggle_operating()
		. = TRUE
		if(src.toggling || src.mode == "high") return FALSE
		if(src.mode == "low")
			src.changemode("active")
		else
			src.changemode("low")

	proc/engage_drill()
		if(src.toggling || src.mode != "high" || !src.powered()) return
		src.toggling = TRUE
		playsound(src, "sound/machines/click.ogg", 40, 1)
		src.icon_state = "drilldrop"
		SPAWN_DBG(2 SECONDS)
			for (var/obj/machinery/siphon/resonator/res in orange(4))
				var/xadj = res.x - src.x
				var/yadj = res.y - src.y
				if(abs(xadj) > 4 || abs(yadj) > 4) continue //this is apparently necessary?
				src.resonators += res
				res.x_torque = sign(xadj) * 2 ** (4 - abs(xadj))
				res.y_torque = sign(yadj) * 2 ** (4 - abs(yadj))
				res.engage_lock()
			SPAWN_DBG(5 DECI SECONDS)
				src.changemode("low")
				src.toggling = FALSE

	proc/disengage_drill()
		if(src.toggling || src.mode == "high") return
		src.extract_ticks = 0
		src.toggling = TRUE
		src.changemode("high")
		var/stagger = 0.2 //desync the disengagement a bit
		for (var/obj/machinery/siphon/resonator/res in src.resonators)
			stagger = stagger + rand(1,2) * 0.3
			res.disengage_lock(stagger)
		src.resonators.Cut()
		SPAWN_DBG(1 SECOND)
			src.icon_state = "drillraise"
			SPAWN_DBG(3 SECONDS)
				src.toggling = FALSE

	proc/calibrate_resonance()
		src.x_torque = 0
		src.y_torque = 0
		var/xt_absolute //total absolute x torque in this pass, used for shear calculation
		var/yt_absolute //total absolute y torque in this pass, used for shear calculation

		for (var/obj/machinery/siphon/resonator/res in src.resonators)
			var/x_torqueup = res.x_torque * res.intensity
			src.x_torque += x_torqueup
			xt_absolute += abs(x_torqueup)
			var/y_torqueup = res.y_torque * res.intensity
			src.y_torque += y_torqueup
			yt_absolute += abs(y_torqueup)

		src.shear = (xt_absolute - abs(src.x_torque)) + (yt_absolute - abs(src.y_torque))

	proc/update_fx()
		if(src.mode != "high")
			var/image/beamline = SafeGetOverlayImage("beamline", 'icons/obj/machines/neodrill_32x64.dmi', "drill-active")
			beamline.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(beamline, "beamline", 0, 1)
			var/imdriller = 0
			if(src.mode == "active") imdriller = 1
			var/image/beam = SafeGetOverlayImage("B E A M", 'icons/obj/machines/neodrill_32x64.dmi', "drill-beam-[imdriller]")
			beam.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(beam, "B E A M", 0, 1)
		else
			ClearAllOverlays()

/obj/machinery/siphon/resonator
	name = "siphon resonator"
	desc = "Field-emitting device used to stabilize and guide a harmonic siphon. You know this because it says so on the label."
	icon = 'icons/obj/machines/neodrill_32x32.dmi'
	icon_state = "resonator"
	density = 1

	///true when resonator is maglocked (can be configured, cannot move)
	var/maglocked = FALSE
	///true when manually secured with wrench (affects anchoring)
	var/wrenched = FALSE
	///intensity scalar from 0 to 4, increasing power draw and resonance strength
	var/intensity = 1
	///baseline X torque value, set when the resonator is anchored by the central siphon
	var/x_torque = 0
	///baseline Y torque value, set when the resonator is anchored by the central siphon
	var/y_torque = 0
	///glowy light, should vary in intensity based on resonator power level
	var/datum/light/light

	New()
		light = new /datum/light/point
		light.attach(src)
		light.set_color(1,0.8,0.55)
		light.set_brightness(0.6)
		..()

	attackby(obj/item/W, mob/user)
		if(iswrenchingtool(W))
			if(!wrenched)
				src.wrenched = TRUE
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
				boutput(user, "You secure the auxiliary reinforcing bolts to the floor.")
				src.anchored = 1
				src.desc = "Field-emitting device used to stabilize and guide a harmonic siphon. It's been manually secured to the floor."
				return
			else if(!maglocked && wrenched)
				src.wrenched = FALSE
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
				boutput(user, "You undo the auxiliary reinforcing bolts.")
				src.anchored = 0
				src.desc = "Field-emitting device used to stabilize and guide a harmonic siphon. You know this because it says so on the label."
				return
			else
				boutput(user,"The auxiliary reinforcing bolts appear to be locked in place.")
				return
		else if(ispulsingtool(W))
			var/scalex = input(usr,"Adjust Intensity","Accepts values 0 through 4","1") as num
			scalex = clamp(scalex,0,4)
			src.intensity = scalex
			src.update_fx()

	examine()
		. = ..()
		if(maglocked)
			var/xto = src.x_torque * src.intensity
			var/yto = src.y_torque * src.intensity
			. += "<br>A small indicator shows it's providing [xto] lateral and [yto] vertical resonant torque."

	proc/engage_lock()
		src.anchored = 1
		src.maglocked = 1
		src.update_fx()

	proc/disengage_lock(var/delayer)
		if(delayer)
			SPAWN_DBG(delayer)
				src.maglocked = 0
				if(!wrenched)
					src.anchored = 0
				src.update_fx()
		else
			src.maglocked = 0
			if(!wrenched)
				src.anchored = 0
			src.update_fx()

	proc/update_fx()
		if(src.maglocked)
			var/image/resactive = SafeGetOverlayImage("locked", 'icons/obj/machines/neodrill_32x32.dmi', "res-active")
			resactive.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(resactive, "locked", 0, 1)
			src.light.set_brightness(0.15 * src.intensity)
			src.light.enable()
			var/image/intens = SafeGetOverlayImage("intensity", 'icons/obj/machines/neodrill_32x32.dmi', "res-charge-[src.intensity]")
			intens.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(intens, "intensity", 0, 1)
		else
			src.light.disable()
			ClearAllOverlays()
