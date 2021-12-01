ABSTRACT_TYPE(/obj/machinery/siphon)
/obj/machinery/siphon
	var/frequency = FREQ_HARMONIC_SIPHON
	var/net_id

	///shortened name for networked control
	var/netname = "ERROR"

	New()
		src.net_id = generate_net_id(src)
		..()

	disposing()
		..()

	receive_signal(datum/signal/signal)
		if(status & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		if(signal.transmission_method != TRANSMISSION_RADIO)
			return

		var/sender = signal.data["sender"]
		if((signal.data["address_1"] in list(src.net_id, "poll")) && sender)
			var/datum/signal/reply = new
			reply.data["address_1"] = sender
			reply.data["command"] = "poll_reply"
			reply.data["device"] = src.netname
			reply.data["netid"] = src.net_id
			var/readouts = src.build_readouts(reply)
			if(readouts) reply.data["devdat"] = readouts //see associated proc
			SPAWN_DBG(0.5 SECONDS)
				src.post_signal(src, reply)
			return

		return

	///constructs a list of readouts specific to the device, to be automatically interpreted; should return a list
	proc/build_readouts()
		/*
		var/list/devdat = list()
		devdat["Intensity"] = src.intensity
		devdat["Lateral Resonance"] = src.x_torque
		devdat["Vertical Resonance"] = src.y_torque
		return devdat
		*/

	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src
		signal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, freq)





//section: main siphon

/obj/machinery/siphon/core
	name = "harmonic siphon"
	desc = "An egregiously complicated device purpose-built for turning magic space rocks into unmagic useful rocks."
	icon = 'icons/obj/machines/neodrill_32x64.dmi'
	icon_state = "drill-high"
	density = 1
	anchored = 1
	layer = 4
	power_usage = 200
	netname = "SIPHON"
	///overlay for beam because can't animate otherwise apparently
	var/obj/overlay/beamlight

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

	///total intensity of all connected resonators; increases power draw and production progress per tick
	var/resofactor = 0

	New()
		..()
		src.beamlight = new /obj/overlay/siphonbeam()
		src.vis_contents += beamlight
		for(var/mineral in concrete_typesof(/datum/siphon_mineral))
			src.can_extract += new mineral

	disposing()
		qdel(src.beamlight)
		..()

	process(var/mult)
		if (status & NOPOWER)
			return
		total_draw = 200
		if(src.mode == "active")
			src.calibrate_resonance()
			total_draw += 150 * src.resofactor
			src.extract_ticks += src.resofactor

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
					src.extract_ticks -= M.tick_req
					var/atom/movable/yielder = new M.product()
					yielder.set_loc(src.get_output_location())
					break

			playsound(src.loc, 'sound/machines/siphon_run.ogg', 30, 0)
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
				playsound(src, "sound/machines/siphon_activate.ogg", 40, 0)
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
				res.torque_init(xadj,yadj)
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

	///iterates over all currently connected resonators to get their cumulative effect on drilling
	proc/calibrate_resonance()
		src.x_torque = 0
		src.y_torque = 0
		src.resofactor = 0
		var/xt_absolute //total absolute x torque in this pass, used for shear calculation
		var/yt_absolute //total absolute y torque in this pass, used for shear calculation
		var/shear_adjust = 0 //rolling counter for special shear adjustments from individual resonators

		for (var/obj/machinery/siphon/resonator/res in src.resonators)
			src.resofactor += res.intensity
			var/x_torqueup = res.x_torque * res.intensity
			src.x_torque += x_torqueup
			xt_absolute += abs(x_torqueup)
			var/y_torqueup = res.y_torque * res.intensity
			src.y_torque += y_torqueup
			yt_absolute += abs(y_torqueup)
			if(res.shearmod) shear_adjust += res.shearmod * res.intensity

		src.shear = max(0,(xt_absolute - abs(src.x_torque)) + (yt_absolute - abs(src.y_torque)) + shear_adjust)

	proc/update_fx()
		if(src.mode != "high")
			var/image/beamline = SafeGetOverlayImage("beamline", 'icons/obj/machines/neodrill_32x64.dmi', "drill-active")
			beamline.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(beamline, "beamline", 0, 1)
			var/imdriller = 0
			if(src.mode == "active") imdriller = 1
			src.beamlight.icon_state = "drill-beam-[imdriller]"
		else
			src.beamlight.icon_state = "drill-beam-0"
			ClearAllOverlays()

	build_readouts()
		var/list/devdat = list()
		devdat["Total Intensity"] = src.resofactor
		devdat["Lateral Resonance"] = src.x_torque
		devdat["Vertical Resonance"] = src.y_torque
		devdat["Shear Value"] = src.shear
		return devdat

/obj/overlay/siphonbeam
	icon = 'icons/obj/machines/neodrill_32x64.dmi'
	icon_state = "drill-beam-0"
	plane = PLANE_OVERLAY_EFFECTS






//section: resonators

/obj/machinery/siphon/resonator
	name = "\improper Type-AX siphon resonator"
	desc = "Field-emitting device used to amplify and direct a harmonic siphon. You know this because it says so on the label."
	icon = 'icons/obj/machines/neodrill_32x32.dmi'
	icon_state = "resonator"
	density = 1
	netname = "RES_AX"

	///affix for overlay icon states, permits cleaner subtyping
	var/resclass = "res"

	///true when resonator is maglocked (can be configured, cannot move)
	var/maglocked = FALSE
	///true when manually secured with wrench (affects anchoring)
	var/wrenched = FALSE
	///intensity scalar from 0 to max (4 for base model), increasing power draw and resonance strength
	var/intensity = 1
	///maximum intensity that can be provided by the resonator
	var/max_intensity = 4
	///baseline X torque value, set when the resonator is anchored by the central siphon
	var/x_torque = 0
	///baseline Y torque value, set when the resonator is anchored by the central siphon
	var/y_torque = 0
	///modifier to total shear value AFTER regular shear calculation; can change dynamically as long as it's set before calibrate_resonance
	var/shearmod = 0
	///glowy light, should vary in intensity based on resonator power level
	var/datum/light/light
	///formatted coordinates for reporting to central console
	var/formatted_coords = ""

	//descriptions for wrenching
	var/regular_desc = "Field-emitting device used to amplify and direct a harmonic siphon. You know this because it says so on the label."
	var/wrenched_desc = "Field-emitting device used to amplify and direct a harmonic siphon. It's been manually secured to the floor."

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
				src.desc = src.wrenched_desc
				return
			else if(!maglocked && wrenched)
				src.wrenched = FALSE
				playsound(src.loc, "sound/items/Ratchet.ogg", 75, 1)
				boutput(user, "You undo the auxiliary reinforcing bolts.")
				src.anchored = 0
				src.desc = src.regular_desc
				return
			else
				boutput(user,"The auxiliary reinforcing bolts appear to be locked in place.")
				return
		else if(ispulsingtool(W))
			var/scalex = input(usr,"Accepts values 0 through [src.max_intensity]","Adjust Intensity","1") as num
			scalex = clamp(scalex,0,src.max_intensity)
			src.intensity = scalex
			src.update_fx()

	examine()
		. = ..()
		if(maglocked && src.x_torque)
			var/xto = src.x_torque * src.intensity
			var/yto = src.y_torque * src.intensity
			. += "<br>A small indicator shows it's providing [xto] lateral and [yto] vertical resonant torque."

	//called by siphon to set up the resonator's coordinate reporting and strength values for its initialized position
	proc/initialize(var/xadj,var/yadj)
		var/horizontal_identifier
		switch(xadj) //this is wack but you can't key-value by numbers so there
			if(-4) horizontal_identifier = "A"
			if(-3) horizontal_identifier = "B"
			if(-2) horizontal_identifier = "C"
			if(-1) horizontal_identifier = "D"
			if(0) horizontal_identifier = "E"
			if(1) horizontal_identifier = "F"
			if(2) horizontal_identifier = "G"
			if(3) horizontal_identifier = "H"
			if(4) horizontal_identifier = "I"
		var/vertical_identifier = yadj + 4
		src.formatted_coords = "[horizontal_identifier][vertical_identifier]"
		src.torque_init(xadj,yadj)

	//initializes torque and shear values after prompted, determining what effect the resonator has on siphoning
	//x_torque, y_torque and shearmod values set here will be multiplied by the resonator's intensity
	proc/torque_init(var/xadj,var/yadj)
		//base torque is 1 at maximum range, and increases by powers of two with proximity, up to a max of 8 at point blank
		//torques don't take each other into account deliberately, allowing for the same horizontal torque at any vertical position or vice versa
		src.x_torque = sign(xadj) * 2 ** (4 - abs(xadj))
		src.y_torque = sign(yadj) * 2 ** (4 - abs(yadj))

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
			var/image/resactive = SafeGetOverlayImage("locked", 'icons/obj/machines/neodrill_32x32.dmi', "[src.resclass]-active")
			resactive.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(resactive, "locked", 0, 1)
			if(src.intensity > 0)
				src.light.set_brightness(0.15 * src.intensity)
				src.light.enable()
			else
				src.light.disable()
			var/image/intens = SafeGetOverlayImage("intensity", 'icons/obj/machines/neodrill_32x32.dmi', "[src.resclass]-charge-[src.intensity]")
			intens.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(intens, "intensity", 0, 1)
		else
			src.light.disable()
			ClearAllOverlays()

	build_readouts()
		var/list/devdat = list()
		devdat["Intensity"] = src.intensity
		devdat["Lateral Resonance"] = src.x_torque * src.intensity
		devdat["Vertical Resonance"] = src.y_torque * src.intensity
		return devdat


//stabilizing resonator, provides purely reduction to shear based on lowest torque value
/obj/machinery/siphon/resonator/stabilizer
	name = "\improper Type-SM siphon resonator"
	desc = "Field-emitting device used to mitigate resonant shear in a harmonic siphon."
	icon_state = "stabilizer"
	density = 1
	regular_desc = "Field-emitting device used to mitigate resonant shear in a harmonic siphon."
	wrenched_desc = "Field-emitting device used to mitigate resonant shear in a harmonic siphon. It's been manually secured to the floor."
	max_intensity = 3
	resclass = "stab"
	netname = "RES_SM"

	torque_init(var/xadj,var/yadj)
		//base shear mitigation ramps from 8>1 (powers of two again!) with decreasing proximity, based simply on radial rings
		src.shearmod = -min(2 ** (4 - abs(xadj)),2 ** (4 - abs(yadj)))

	build_readouts()
		var/list/devdat = list()
		devdat["Intensity"] = src.intensity
		devdat["Shear Modifier"] = src.shearmod * src.intensity
		return devdat




//section: secondary consoles

//control for siphon and associated resonators
//can poll siphon and resonators for information, and control resonator operation; siphon itself could have a big lever console?
/obj/machinery/computer/siphon_control
	name = "Harmonic Siphon Control"
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "engine1"
	req_access = list(access_mining)
	object_flags = CAN_REPROGRAM_ACCESS
	var/temp = null

	light_r = 0.8
	light_g = 1
	light_b = 1

	New()
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, FREQ_HARMONIC_SIPHON)

//database to look up requirements for extraction, including in some cases a recommendation for parameters
/obj/machinery/computer/siphon_db
	name = "Resonance Calibration Database"
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "qmreq1"
	object_flags = CAN_REPROGRAM_ACCESS
	var/temp = null

	light_r = 0.8
	light_g = 1
	light_b = 1
