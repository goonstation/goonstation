ABSTRACT_TYPE(/obj/machinery/siphon)

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

	//resonance parameters for mineral extraction
	var/x_torque = 0
	var/y_torque = 0
	var/shear = 0

	process(var/mult)
		if (status & NOPOWER)
			return
		total_draw = 200
		//for(var/obj/machinery/siphon/resonator/res in src.resonators)


		power_usage = total_draw
		..()

	attackby(obj/item/W, mob/user) //DEBUG DEBUG DEBUG
		if(ispulsingtool(W) && src.mode != "high")
			src.calibrate_resonance()
			boutput(user,"LATERAL RESONANCE: [src.x_torque]")
			boutput(user,"VERTICAL RESONANCE: [src.y_torque]")
			boutput(user,"SHEAR VALUE: [src.shear]")

	attack_hand(mob/user) //DEBUG DEBUG DEBUG
		src.toggle_drill()

	proc/toggle_drill()
		if(src.mode == "high")
			src.engage_drill()
		else
			src.disengage_drill()

	proc/engage_drill()
		if(src.toggling || src.mode != "high" || !src.powered()) return
		src.toggling = TRUE
		src.icon_state = "drilldrop"
		SPAWN_DBG(2 SECONDS)
			for (var/obj/machinery/siphon/resonator/res in orange(4))
				src.resonators += res
				var/xadj = res.x - src.x
				var/yadj = res.y - src.y
				res.x_torque = sign(xadj) * 2 ** (4 - abs(xadj))
				res.y_torque = sign(yadj) * 2 ** (4 - abs(yadj))
				res.engage_lock()
			SPAWN_DBG(5 DECI SECONDS)
				src.mode = "low"
				src.update_fx()
				src.toggling = FALSE

	proc/disengage_drill()
		if(src.toggling || src.mode == "high") return
		src.toggling = TRUE
		src.mode = "high"
		src.update_fx()
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
			src.x_torque += res.x_torque
			xt_absolute += abs(res.x_torque)
			src.y_torque += res.y_torque
			yt_absolute += abs(res.y_torque)

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
			. += boutput(user,"A small indicator shows it's providing [xto] lateral and [yto] vertical resonant torque.")

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
