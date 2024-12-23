//handheld device for manual calibration of siphon systems
TYPEINFO(/obj/item/device/calibrator)
	mats = list("crystal" = 1,
				"conductive" = 1)
/obj/item/device/calibrator
	name = "harmonic systems calibrator"
	icon_state = "calibrator"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	force = 5.0
	w_class = W_CLASS_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "A small handheld device specially built for calibration and readout of harmonic siphon systems."
	m_amt = 50
	g_amt = 20



//now the main event

//values to differentiate types of condition in which net updates are built
//setup indicates a batched build that shouldn't update ui individually
//regular indicates an individual build, i.e. for a single resonator changing, that should prompt an update
#define SIGBUILD_SETUP 1
#define SIGBUILD_REGULAR 2

ABSTRACT_TYPE(/obj/machinery/siphon)
/obj/machinery/siphon
	var/frequency = FREQ_HARMONIC_SIPHON
	var/net_id

	///shortened name for networked control
	var/netname = "ERROR"

	New()
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, src.frequency)
		..()

	disposing()
		..()

	receive_signal(datum/signal/signal)
		if(status & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		var/sender = signal.data["sender"]

		if((signal.data["address_1"] in list(src.net_id, "probe")) && sender)
			src.build_net_update(signal,null,sender)
			return

		return

	///prepares an update for the siphon control console; placed in a discrete proc so subtypes can handle input commands before signal post
	proc/build_net_update(var/datum/signal/signal,var/sigvalue,var/replyto)
		//sigvalue is used for control over update triggering, see define comments
		var/datum/signal/reply = new
		if(replyto)
			reply.data["address_1"] = replyto
		reply.data["command"] = "devdat" //short for device data
		reply.data["device"] = src.netname
		reply.data["netid"] = src.net_id
		if(sigvalue == SIGBUILD_REGULAR) //give update to control console
			reply.data["REFRESH_UI"] = TRUE
		var/readouts = src.build_readouts(reply)
		if(readouts) reply.data["devdat"] = readouts //see associated proc
		SPAWN(0.3 SECONDS)
			src.post_signal(reply)
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

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, 20, freq)





//section: main siphon

/obj/machinery/siphon/core
	name = "harmonic siphon"
	desc = "An egregiously complicated device purpose-built for turning a really big underground magic rock into unmagic useful rocks."
	icon = 'icons/obj/machines/neodrill_32x64.dmi'
	icon_state = "drill-high"
	density = 1
	anchored = ANCHORED
	layer = 4
	power_usage = 200
	bound_height = 64
	netname = "SIPHON"
	var/sound/sound_unload = sound('sound/items/Deconstruct.ogg')

	//overlays for beam and siphoning
	var/obj/overlay/beamlight
	var/obj/overlay/drawlight
	///paired control console for non-manual operation
	var/obj/machinery/siphon_lever/paired_lever

	///sum of baseline draw from siphon and current draw from paired resonators
	var/total_draw
	///possible modes: high (raised and inactive), low (drill is set over hole, resonators lock in place), active (drilling)
	var/mode = "high"
	///true while toggling between high and low
	var/toggling = FALSE
	///how much the siphon can hold in its internal reservoir before it has to be unloaded
	var/max_held_items = 20
	///list of paired resonators, built when drill enters active position
	var/list/resonators = list()
	///list of possible siphon targets for the siphon
	var/list/can_extract = list()
	///progress in extraction, incremented each process by total intensity of resonators; consumption varies by material. also known as EEU
	var/extract_ticks = 0
	///extract tick overload state, set during process; if tick consumption is missing or insufficient, tick buildup causes blowouts
	var/extract_overloaded = FALSE
	///where extracted minerals are sent
	var/output_target = null

	//resonance parameters for mineral extraction
	var/x_torque = 0
	var/y_torque = 0
	var/shear = 0

	///total intensity of all connected resonators; increases power draw and production progress per tick
	var/resofactor = 0

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.mode != "active")
			return 0
		var/mob/living/L = user
		if (!istype(L))
			return 0
		L.visible_message(SPAN_ALERT("<b>[L] shoves their head into [src]'s beam, ripping it off in the matter stream! Holy shit!</b>"))
		playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 75)
		L.organHolder.drop_organ("head",src) //you've met a terrible fate
		return 1

	New()
		..()
		src.beamlight = new /obj/overlay/siphonglow()
		src.vis_contents += beamlight
		src.drawlight = new /obj/overlay/siphonglow()
		src.vis_contents += drawlight
		for(var/mineral in concrete_typesof(/datum/siphon_mineral))
			src.can_extract += new mineral

	ex_act(severity)
		if(severity > 1.0)
			return
		..()

	disposing()
		for (var/obj/machinery/siphon/resonator/res in src.resonators)
			LAGCHECK(LAG_LOW)
			res.paired_core = null
			res.disengage_lock()
		src.resonators.Cut()
		src.clear_siphon_console()
		qdel(src.beamlight)
		..()

	examine()
		. = ..()
		var/quant = length(src.contents)
		if(quant > 0)
			. += " It's holding [quant] units of material."

	process(var/mult)
		if (status & NOPOWER)
			return
		total_draw = 200
		if(src.mode == "active")
			total_draw += 800 * src.resofactor
			src.extract_ticks += src.resofactor

			///If no extraction occurs, high shear values can result in hazardous effects
			var/extract_progressed = FALSE

			for(var/datum/siphon_mineral/M in src.can_extract)
				LAGCHECK(LAG_LOW)
				if(M.shear != null) //check shear against spec; happens early to avoid blowouts in high-shear targets
					var/shearcheck = abs(src.shear - M.shear)
					if(shearcheck > M.sens_window) continue
				if(M.x_torque != null) //check x torque against mineral's requirement, if there is one
					var/xtcheck = abs(src.x_torque - M.x_torque)
					if(xtcheck > M.sens_window) continue
				if(M.y_torque != null) // check y torque against mineral's requirement, if there is one
					var/ytcheck = abs(src.y_torque - M.y_torque)
					if(ytcheck > M.sens_window) continue
				extract_progressed = TRUE
				if(src.extract_ticks >= M.tick_req)
					while(src.extract_ticks >= M.tick_req && length(src.contents) < src.max_held_items)
						src.extract_ticks -= M.tick_req
						var/atom/movable/yielder = new M.product()
						if(istype(yielder,/obj/item)) //items go into internal reservoir
							src.contents += yielder
							src.update_storage_bar()
						else //pulled out something that isn't an item... what could it be?
							yielder.set_loc(get_turf(src))

					//non-shear failures
					//option 1 - more extraction ticks left over after conversion than you'd need for the target material
					//option 2 - running resonators with the panel open is a bad idea
					if(src.extract_ticks > M.tick_req)
						if(src.extract_overloaded == FALSE) //warn if newly overloaded
							src.visible_message(SPAN_ALERT("<B>[src]</B> emits an excess accumulated EEU warning."))
						playsound(src, 'sound/machines/pod_alarm.ogg', 30, TRUE)
						src.extract_overloaded = TRUE
					else
						src.extract_overloaded = FALSE

					for (var/obj/machinery/siphon/resonator/res in src.resonators)
						if((src.extract_overloaded || res.panelopen) && prob(30))
							src.extract_ticks = 0
							res.shear_overload()
					break

			if(!extract_progressed)
				switch(src.shear)
					if(64 to 127)
						var/chancefactor = round(shear/6)
						if(prob(chancefactor))
							var/obj/machinery/siphon/resonator/RSO = pick(src.resonators)
							RSO.shear_overload()
					if(128 to 256)
						var/chancefactor = min(round(shear/8),33)
						if(prob(chancefactor))
							var/obj/uh_oh = new /obj/vortex(src.loc)
							uh_oh.x += rand(-3,3)
							uh_oh.y += rand(-3,3)
						if(prob(chancefactor*3))
							var/obj/machinery/siphon/resonator/RSO = pick(src.resonators)
							if(prob(chancefactor))
								RSO.shear_overload(TRUE)
							else
								RSO.shear_overload()
					if(257 to INFINITY)
						var/chancefactor = min(round(shear/5),100)
						for(var/i = 0, i < 3, i++)
							if(prob(chancefactor))
								var/obj/uh_oh = new /obj/vortex(src.loc)
								uh_oh.x += rand(-4,4)
								uh_oh.y += rand(-4,4)
						var/obj/machinery/siphon/resonator/RSO = pick(src.resonators)
						if(prob(chancefactor))
							RSO.shear_overload(TRUE)
						else
							RSO.shear_overload()
			else
				SPAWN(0.1 SECONDS)
					flick("drill-extract",src.drawlight)

			playsound(src.loc, 'sound/machines/siphon_run.ogg', 50, !extract_progressed) //noise warbles if no progress occurred

			if(length(src.contents) >= src.max_held_items)
				src.changemode("low")
				if(src.paired_lever != null) paired_lever.vis_setpanel(0)
				src.visible_message("<B>[src]</B> shuts down. Its internal storage is full.")

		power_usage = total_draw
		..()

	proc/eats_spicy_goodness_dies_instantly(var/catastrophic = FALSE) //DEBUG DEBUG DEBUG
		for (var/obj/machinery/siphon/resonator/res in src.resonators)
			res.shear_overload(catastrophic)

	power_change()
		if(powered())
			status &= ~NOPOWER
		else
			status |= NOPOWER
			if(src.mode == "active")
				src.toggling = TRUE
				src.changemode("low")
				if(src.paired_lever != null) paired_lever.vis_setpanel(0)
				SPAWN(0.5 SECONDS) //retoggle delay
					if(src.mode != "high") src.toggling = FALSE
		src.update_fx()
		src.update_storage_bar()

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/device/calibrator) && src.mode != "high")
			src.calibrate_resonance()
			boutput(user,"LATERAL RESONANCE: [src.x_torque]")
			boutput(user,"VERTICAL RESONANCE: [src.y_torque]")
			boutput(user,"SHEAR VALUE: [src.shear]")
			return
		else if(iswrenchingtool(W))
			var/diditwork = src.toggle_drill()
			if(diditwork)
				boutput(user,"You manually toggle the siphon's lift mechanism.")
			else
				if(src.mode == "active") boutput(user,"The siphon's lift mechanism can't be toggled while it's operational.")
			return

	attack_hand(mob/user,var/bot_input)
		var/diditwork = src.toggle_operating()
		if(diditwork)
			boutput(user,"You [bot_input ? "interface with" : "touch"] the siphon's activation panel.")
		else
			boutput(user,"The siphon's activation panel doesn't respond to your [bot_input ? "signal" : "touch"].")

	attack_ai(mob/user)
		return attack_hand(user,TRUE)

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, SPAN_ALERT("Only living mobs are able to set the siphon's output target."))
			return

		if(!in_interact_range(over_object,src))
			boutput(usr, SPAN_ALERT("The siphon is too far away from the target."))
			return

		if(!in_interact_range(over_object,usr))
			boutput(usr, SPAN_ALERT("You are too far away from the target."))
			return

		if(src.mode == "active")
			boutput(usr, SPAN_ALERT("You can't unload the siphon while it's running."))
			return

		if (istype(over_object,/obj/storage/crate/) || istype(over_object,/obj/storage/cart) || istype(over_object,/obj/storage/closet))
			var/offload_count = 0
			for (var/obj/item/I in src.contents)
				I.set_loc(over_object)
				offload_count++
			playsound(src, sound_unload, 40, TRUE)
			usr.visible_message(SPAN_NOTICE("[usr] uses [src]'s automatic ore offloader on [over_object]."), SPAN_NOTICE("You load [offload_count] materials into [over_object] from [src]."))
			src.update_storage_bar()

		if (istype(over_object,/obj/item/satchel/mining))
			var/obj/item/satchel/mining/satchel = over_object
			usr.visible_message(SPAN_NOTICE("[usr] begins unloading ore into [satchel]."))
			if (length(satchel.contents) < satchel.maxitems)
				var/staystill = usr.loc
				var/interval = 0
				for (var/obj/item/I in src.contents)
					if (satchel.check_valid_content(I))
						I.set_loc(satchel)
						I.add_fingerprint(usr)
						playsound(src, sound_unload, 30, TRUE)
					if (!(interval++ % 4))
						satchel.UpdateIcon()
						src.update_storage_bar()
					sleep(0.1 SECONDS)
					if (usr.loc != staystill) break
					if (length(satchel.contents) >= satchel.maxitems)
						boutput(usr, SPAN_NOTICE("\The [satchel] is now full!"))
						break
				var/incomplete = 1 //you're not done filling
				if(length(satchel.contents) == satchel.maxitems || !length(src.contents)) incomplete = 0
				boutput(usr, SPAN_NOTICE("You [incomplete ? "stop" : "finish"] filling \the [satchel]."))
				satchel.UpdateIcon()
				satchel.tooltip_rebuild = 1
				src.update_storage_bar()
			else
				boutput(usr, SPAN_NOTICE("\The [satchel] doesn't have any room to accept materials."))

		else if (istype(over_object, /turf/))
			usr.visible_message(SPAN_NOTICE("[usr] begins unloading ore from [src]."))
			var/staystill = usr.loc
			var/interval = 0
			for (var/obj/item/I in src.contents)
				I.set_loc(over_object)
				I.add_fingerprint(usr)
				if (!(interval++ % 4))
					src.update_storage_bar()
				playsound(src, sound_unload, 30, TRUE)
				sleep(0.1 SECONDS)
				if (usr.loc != staystill) break
			boutput(usr, SPAN_NOTICE("You [length(src.contents) ? "stop" : "finish"] unloading ore from [src]."))
			src.update_storage_bar()

		else ..()

	proc/changemode(var/newmode)
		src.mode = newmode
		switch(newmode)
			if("low")
				playsound(src, 'sound/machines/click.ogg', 40, TRUE)
			if("active")
				playsound(src, 'sound/machines/siphon_activate.ogg', 60, FALSE)
			if("high")
				playsound(src, 'sound/machines/pc_process.ogg', 30, FALSE)
		src.update_fx()

	proc/toggle_drill(var/remote_activation)
		. = TRUE
		if(src.toggling || !powered()) return FALSE
		if(src.mode == "high")
			src.engage_drill()
			if(src.paired_lever != null && !remote_activation) paired_lever.vis_setlever(1)
		else
			src.disengage_drill()
			if(src.paired_lever != null && !remote_activation)
				paired_lever.vis_setlever(0)
				paired_lever.vis_setpanel(0)

	proc/toggle_operating(var/remote_activation)
		. = TRUE
		if(src.toggling || src.mode == "high") return FALSE
		if(src.mode == "low" && length(src.contents) < src.max_held_items)
			src.changemode("active")
			if(src.paired_lever != null && !remote_activation) paired_lever.vis_setpanel(1)
			src.toggling = TRUE //retoggle delay
			SPAWN(0.5 SECONDS)
				if(src.mode != "high") src.toggling = FALSE
		else
			src.changemode("low")
			if(src.paired_lever != null && !remote_activation) paired_lever.vis_setpanel(0)
			src.toggling = TRUE //retoggle delay
			SPAWN(0.5 SECONDS)
				if(src.mode != "high") src.toggling = FALSE

	proc/engage_drill()
		if(src.toggling || src.mode != "high" || !src.powered()) return
		src.toggling = TRUE
		playsound(src, 'sound/machines/click.ogg', 40, TRUE)
		src.icon_state = "drill-low"
		flick("drilldrop",src)
		SPAWN(2 SECONDS)
			for (var/obj/machinery/siphon/resonator/res in orange(4,src))
				if (res.status & BROKEN) continue
				var/turf/T = get_turf(res)
				if (ON_COOLDOWN(T, "resonator_anti_stack", 1 DECI SECOND)) continue
				var/xadj = res.x - src.x
				var/yadj = res.y - src.y
				if(abs(xadj) > 4 || abs(yadj) > 4) continue //this is apparently necessary?
				src.resonators += res
				res.paired_core = src
				res.reso_init(xadj,yadj)
				res.engage_lock()
			SPAWN(5 DECI SECONDS)
				src.build_net_update(null,SIGBUILD_REGULAR) //resonance calibration happening in here via build readouts
				src.changemode("low")
				src.toggling = FALSE

	proc/disengage_drill()
		if(src.toggling || src.mode == "high") return
		src.extract_ticks = 0
		src.toggling = TRUE
		src.changemode("high")
		var/stagger = 0.2 //desync the disengagement a bit
		for (var/obj/machinery/siphon/resonator/res in src.resonators)
			LAGCHECK(LAG_LOW)
			res.paired_core = null
			stagger = stagger + rand(1,2) * 0.3
			res.disengage_lock(stagger)
		src.resonators.Cut()
		src.clear_siphon_console()
		SPAWN(1 SECOND)
			src.icon_state = "drill-high"
			flick("drillraise",src)
			SPAWN(3 SECONDS)
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
		if(powered() && src.mode != "high")
			var/image/beamline = SafeGetOverlayImage("beamline", 'icons/obj/machines/neodrill_32x64.dmi', "drill-active")
			beamline.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(beamline, "beamline", 0, 1)
			var/imdriller = 0
			if(src.mode == "active") imdriller = 1
			src.beamlight.icon_state = "drill-beam-[imdriller]"
		else
			src.beamlight.icon_state = "drill-beam-0"
			ClearSpecificOverlays(null,"beamline")

	proc/update_storage_bar()
		if(powered())
			var/storatio = round((length(src.contents) / src.max_held_items) * 5)
			if(storatio == 0 && length(src.contents)) storatio = 1 //show immediate storage progress for tactile feedback
			var/image/storebar = SafeGetOverlayImage("storage", 'icons/obj/machines/neodrill_32x64.dmi', "drill-storage-[storatio]")
			storebar.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(storebar, "storage", 0, 1)
		else
			ClearSpecificOverlays(null,"storage")

	build_readouts()
		src.calibrate_resonance()
		var/list/devdat = list()
		devdat["Total Intensity"] = src.resofactor
		devdat["Lateral Resonance"] = src.x_torque
		devdat["Vertical Resonance"] = src.y_torque
		devdat["Shear Value"] = src.shear
		return devdat

	proc/clear_siphon_console()
		var/datum/signal/reply = new
		reply.data["command"] = "deinit"
		reply.data["device"] = src.netname
		reply.data["netid"] = src.net_id
		src.post_signal(reply)
		return

/obj/overlay/siphonglow
	icon = 'icons/obj/machines/neodrill_32x64.dmi'
	icon_state = "drill-beam-0"
	plane = PLANE_OVERLAY_EFFECTS

//section: resonators

/obj/machinery/siphon/resonator
	name = "\improper Type-AX siphon resonator"
	desc = "Field-emitting device used to amplify and direct a harmonic siphon. You know this because it says so on the label."
	icon = 'icons/obj/machines/neodrill_32x32.dmi'
	icon_state = "res-closed"
	density = 1
	netname = "RES_AX"

	///affix for overlay icon states, permits cleaner subtyping
	var/resclass = "res"

	///true when resonator is maglocked (can be configured, cannot move)
	var/maglocked = FALSE
	///true when manually secured with wrench (affects anchoring)
	var/wrenched = FALSE
	///true when front panel is open (done for repairs; operating resonator while its front panel is open can end poorly)
	var/panelopen = FALSE

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
	///reference
	var/obj/machinery/siphon/core/paired_core = null

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
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				boutput(user, "You secure the auxiliary reinforcing bolts to the floor.")
				src.anchored = ANCHORED
				src.desc = src.wrenched_desc
				return
			else if(!maglocked && wrenched)
				src.wrenched = FALSE
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				boutput(user, "You undo the auxiliary reinforcing bolts.")
				src.anchored = UNANCHORED
				src.desc = src.regular_desc
				return
			else
				boutput(user,"The auxiliary reinforcing bolts appear to be locked in place.")
				return
		else if(isscrewingtool(W))
			if(src.panelopen)
				src.panelopen = FALSE
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				boutput(user, "You close the resonator's maintenance panel.")
				src.UpdateIcon()
				return
			else
				src.panelopen = TRUE
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				boutput(user, "You open the resonator's maintenance panel.")
				src.UpdateIcon()
				return
		else if(istype(W,/obj/item/cable_coil))
			if(!src.panelopen)
				boutput(user,"The service panel isn't open.")
				return
			if(HAS_FLAG(src.status,BROKEN))
				if(W.amount >= 3)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 40, 1)
					boutput(user, "You replace the resonator's damaged wiring.")
					status &= ~BROKEN
					src.UpdateIcon()
					src.update_fx()
					W.amount -= 3
					if (W.amount < 1)
						var/mob/source = user
						source.u_equip(W)
						qdel(W)
					else if(W.inventory_counter)
						W.inventory_counter.update_number(W.amount)
					return
				else
					boutput(user, "You need at least three lengths of wire to repair the damage.")
					return
			else
				boutput(user, "The internal wiring doesn't seem to need repair.")
				return
		else if(istype(W,/obj/item/device/calibrator))
			var/scalex = input(user,"Accepts values 0 through [src.max_intensity]","Adjust Intensity","1") as num
			if(BOUNDS_DIST(src, user) > 1)
				boutput(user, SPAN_NOTICE("You are too far away from [src] to calibrate it!"))
				return
			scalex = clamp(scalex,0,src.max_intensity)
			src.intensity = scalex
			src.update_fx()
			if(paired_core)
				src.build_net_update(null,SIGBUILD_REGULAR)
			return

	examine()
		. = ..()
		if(maglocked && src.x_torque)
			var/xto = src.x_torque * src.intensity
			var/yto = src.y_torque * src.intensity
			. += "<br>A small indicator shows it's providing [xto] lateral and [yto] vertical resonant torque."

	power_change()
		if(powered())
			status &= ~NOPOWER
		else
			status |= NOPOWER
			if(src.maglocked)
				if(paired_core)
					paired_core.resonators -= src
					paired_core.calibrate_resonance()
					src.paired_core = null
				src.disengage_lock(rand(1,5))

	proc/shear_overload(var/catastrophic = FALSE)
		status |= BROKEN
		if(src.maglocked)
			if(paired_core)
				paired_core.resonators -= src
				paired_core.calibrate_resonance()
				src.paired_core = null
			src.disengage_lock()
		else //disengage lock includes fx update of its own
			src.update_fx()
		if(catastrophic)
			src.visible_message(SPAN_ALERT("[src] explodes!"))
			new /obj/effects/explosion(src.loc)
			playsound(src, 'sound/effects/Explosion1.ogg', 50, TRUE)
			SPAWN(0)
				explosion_new(src, get_turf(src), 3)
				qdel(src)
		else
			var/faildesc = pick("short-circuits","malfunctions","suddenly deactivates","shorts out","shoots out sparks")
			src.visible_message(SPAN_ALERT("[src] [faildesc]!"))
			playsound(src, 'sound/effects/shielddown2.ogg', 30, TRUE)
			if(limiter.canISpawn(/obj/effects/sparks))
				var/obj/sparks = new /obj/effects/sparks
				sparks.set_loc(get_turf(src))
				SPAWN(2 SECONDS) if (sparks) qdel(sparks)
			src.UpdateIcon()

	update_icon()
		if(src.panelopen)
			var/busted = HAS_FLAG(src.status,BROKEN)
			src.icon_state = "[src.resclass]-open-[busted]"
		else
			src.icon_state = "[src.resclass]-closed"

	//called by siphon to set up the resonator's coordinate reporting and strength values for its initialized position
	proc/reso_init(var/xadj,var/yadj)
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
		SPAWN(0.1 SECONDS)
			src.build_net_update(null,SIGBUILD_SETUP)

	//initializes torque and shear values after prompted, determining what effect the resonator has on siphoning
	//x_torque, y_torque and shearmod values set here will be multiplied by the resonator's intensity
	proc/torque_init(var/xadj,var/yadj)
		//base torque is 1 at maximum range, and increases by powers of two with proximity, up to a max of 8 at point blank
		//torques don't take each other into account deliberately, allowing for the same horizontal torque at any vertical position or vice versa
		src.x_torque = sign(xadj) * 2 ** (4 - abs(xadj))
		src.y_torque = sign(yadj) * 2 ** (4 - abs(yadj))

	proc/engage_lock()
		src.anchored = ANCHORED
		src.maglocked = 1
		src.update_fx()

	proc/disengage_lock(var/delayer)
		if(delayer)
			SPAWN(delayer)
				src.maglocked = 0
				if(!wrenched)
					src.anchored = UNANCHORED
				src.update_fx()
		else
			src.maglocked = 0
			if(!wrenched)
				src.anchored = UNANCHORED
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
			if(HAS_FLAG(src.status,BROKEN))
				var/image/resbusted = SafeGetOverlayImage("locked", 'icons/obj/machines/neodrill_32x32.dmi', "[src.resclass]-error")
				resbusted.plane = PLANE_OVERLAY_EFFECTS
				UpdateOverlays(resbusted, "locked", 0, 1)

	build_net_update(datum/signal/signal,var/sigvalue)
		if(signal && signal.data["command"] == "calibrate")
			var/scalex = signal.data["intensity"]
			scalex = clamp(scalex,0,src.max_intensity)
			src.intensity = scalex
			src.update_fx()
			SPAWN(0.2 SECONDS)
				paired_core.build_net_update(null,SIGBUILD_REGULAR)
		else if(sigvalue == SIGBUILD_REGULAR)
			paired_core.build_net_update(null,SIGBUILD_REGULAR)
		..()

	build_readouts()
		var/list/devdat = list()
		devdat["Device Position"] = src.formatted_coords
		devdat["Intensity"] = src.intensity
		devdat["Maximum Intensity"] = src.max_intensity
		devdat["Lateral Resonance"] = src.x_torque * src.intensity
		devdat["Vertical Resonance"] = src.y_torque * src.intensity
		return devdat


//stabilizing resonator, provides purely reduction to shear based on lowest torque value
/obj/machinery/siphon/resonator/stabilizer
	name = "\improper Type-SM siphon resonator"
	desc = "Field-emitting device used to mitigate resonant shear in a harmonic siphon."
	icon_state = "stab-closed"
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
		devdat["Device Position"] = src.formatted_coords
		devdat["Intensity"] = src.intensity
		devdat["Maximum Intensity"] = src.max_intensity
		devdat["Shear Modifier"] = src.shearmod * src.intensity
		return devdat
