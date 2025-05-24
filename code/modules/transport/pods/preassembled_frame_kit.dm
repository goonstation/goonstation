ABSTRACT_TYPE(/obj/item/preassembled_frame_box)
/obj/item/preassembled_frame_box
	desc = "You can hear an awful lot of junk rattling around in this box."
	help_message = "Use the frame kit in a pod bay to begin construction, for which you'll need a wrench, a welder, a screwdriver and some pod armor from a manufacturer."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	var/frame_type

	attack_self(mob/user as mob)
		boutput(user, SPAN_NOTICE("You dump out the box of parts onto the floor."))
		var/obj/O = new frame_type( get_turf(user) )
		logTheThing(LOG_STATION, user, "builds [O] in [get_area(user)] ([log_loc(user)])")
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		O.forensic_holder = src.forensic_holder
		qdel(src)

/obj/item/preassembled_frame_box/putt
	name = "Preassembled MiniPutt Frame Kit"
	frame_type = /obj/structure/preassembeled_vehicleframe/puttframe

/obj/item/preassembled_frame_box/sub
	name = "Preassembled Minisub Frame Kit"
	frame_type = /obj/structure/preassembeled_vehicleframe/subframe

/obj/item/preassembled_frame_box/pod
	name = "Preassembled Pod Frame Kit"
	frame_type = /obj/structure/preassembeled_vehicleframe/podframe

	attack_self(mob/user as mob)
		// lets assume everything is ok so we can stop checking at the first sign of trouble
		var/canbuild = TRUE

		// buffers whee
		var/list/checkturfs = block(get_turf(user), locate(user.x + 1, user.y + 1, user.z))
		var/turf/T
		var/atom/A

		// check the 2x2 square that the finished pod will occupy
		for(T in checkturfs)
			if (istype(T, /turf/space))
				continue
			if (!T.allows_vehicles || T.density)
				canbuild = FALSE
				boutput(user, SPAN_ALERT("You can't build a pod here! It'd get stuck."))
				break
			for (A in T)
				if (A == user)
					continue
				if (A.density)
					canbuild = FALSE
					boutput(user, SPAN_ALERT("You can't build a pod here! [A] is in the way."))
					break
			if (!canbuild)
				break

		if (canbuild)
			..()

#define BUILD_STEP_PLACED 0
#define BUILD_STEP_WRENCH_1 1
#define BUILD_STEP_WELD_1 2
#define BUILD_STEP_SCREW_1 3
#define BUILD_STEP_ARMOR 4
#define BUILD_STEP_WRENCH_2 5
#define BUILD_STEP_WELD_2 6

ABSTRACT_TYPE(/obj/structure/preassembeled_vehicleframe)
/obj/structure/preassembeled_vehicleframe
	var/stage = BUILD_STEP_PLACED
	var/obj/item/podarmor/armor_type = null
	var/box_type = null
	var/vehicle_name = null
	var/vehicle_type = null
	anchored = ANCHORED
	density = TRUE
	HELP_MESSAGE_OVERRIDE("Use a <b>wrench</b> to secure the parts together.")
	var/step_build_time = 10 SECONDS //per each 7 steps

/obj/structure/preassembeled_vehicleframe/puttframe
	name = "Preassembled MiniPutt Frame"
	desc = "A MiniPutt ship under construction."
	icon = 'icons/obj/ship.dmi'
	icon_state = "parts"
	box_type = /obj/item/preassembled_frame_box/putt
	vehicle_name = "MiniPutt"

/obj/structure/preassembeled_vehicleframe/subframe
	name = "Preassembled Minisub Frame"
	desc = "A minisub under construction."
	icon = 'icons/obj/machines/8dirvehicles.dmi'
	icon_state = "parts"
	box_type = /obj/item/preassembled_frame_box/sub
	vehicle_name = "Minisub"

/obj/structure/preassembeled_vehicleframe/podframe
	name = "Preassembled Pod Frame"
	desc = "A vehicle pod under construction."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "parts"
	bound_width = 64
	bound_height = 64
	box_type = /obj/item/preassembled_frame_box/pod
	vehicle_name = "Pod"

/*-----------------------------*/
/* Construction                */
/*-----------------------------*/

/obj/structure/preassembeled_vehicleframe/attackby(obj/item/I, mob/living/user)
	var/datum/action/bar/icon/callback/action_bar

	if (I)
		var/duration = src.step_build_time
		if (user?.traitHolder?.hasTrait("training_engineer") || istype(ticker?.mode, /datum/game_mode/pod_wars))
			duration /= 2
		action_bar = new /datum/action/bar/icon/callback(user, src, duration, \
			/obj/structure/preassembeled_vehicleframe/proc/step_wrench_1, \
			list(user), I.icon, I.icon_state, null, null)
		action_bar.maximum_range = 2

	switch(src.stage)
		if(BUILD_STEP_PLACED)
			if (iswrenchingtool(I))
				user.visible_message("[user] begins securing the frame...")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				action_bar.proc_path = /obj/structure/preassembeled_vehicleframe/proc/step_wrench_1
				action_bar.end_message = "[user] finishes wrenching the frame parts together."
				actions.start(action_bar, user)
			else
				boutput(user, "You need a wrench to secure the parts together.")

		if(BUILD_STEP_WRENCH_1)
			if (isweldingtool(I))
				if(!I:try_weld(user, 1))
					return
				user.visible_message("[user] begins welding the joints of the frame...")
				action_bar.proc_path = /obj/structure/preassembeled_vehicleframe/proc/step_weld_1
				action_bar.end_message = "[user] welds the joints of the frame together."
				actions.start(action_bar, user)
			else
				boutput(user, "You need a welder to weld the joints together.")

		if(BUILD_STEP_WELD_1)
			if (isscrewingtool(I))
				user.visible_message("[user] begins screwing down the frame's circuit boards and its engine...")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				action_bar.proc_path = /obj/structure/preassembeled_vehicleframe/proc/step_screw_1
				action_bar.end_message = "[user] finishes screwing the the frame's circuit boards and its engine."
				actions.start(action_bar, user)
			else
				boutput(user, "You need a screwdriver to screw the circuit boards and the engine together.")


		if(BUILD_STEP_SCREW_1)
			if(istype(I, /obj/item/podarmor))
				var/obj/item/podarmor/armor = I
				if(!armor.vehicle_types["[src.type]"])
					boutput(user, "That type of armor is not compatible with this frame.")
					return
				user.visible_message("[user] begins installing the [I]...")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				action_bar.proc_path = /obj/structure/preassembeled_vehicleframe/proc/step_armor
				action_bar.proc_args = list(user, armor)
				action_bar.end_message = "[user] loosely attaches the light armor plating."
				actions.start(action_bar, user)
			else
				boutput(user, "You need some pod armor to put on.")

		if(BUILD_STEP_ARMOR)
			if (iswrenchingtool(I))
				user.visible_message("[user] begins securing the pod's thrusters and control system...")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				action_bar.proc_path = /obj/structure/preassembeled_vehicleframe/proc/step_wrench_2
				action_bar.end_message = "[user] secures the pod's thrusters and control system."
				actions.start(action_bar, user)
			else
				boutput(user, "You need a wrench to secure the pod's thrusters and control system.")

		if(BUILD_STEP_WRENCH_2)
			if (isweldingtool(I))
				if(!I:try_weld(user, 1))
					return
				user.visible_message("[user] begins welding the exterior...")
				action_bar.proc_path = /obj/structure/preassembeled_vehicleframe/proc/step_weld_2
				action_bar.end_message = "[user] welds the seams of the outer skin to make it air-tight."
				actions.start(action_bar, user)
			else
				boutput(user, "You need a welder to weld the exterior.")

		if(BUILD_STEP_WELD_2)
			if (isscrewingtool(I))
				user.visible_message("[user] begins screwing the pod's maintenance panels shut...")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				action_bar.proc_path = /obj/structure/preassembeled_vehicleframe/proc/step_screw_2
				action_bar.end_message = "With the cockpit and exterior indicators secured, the control system automatically starts up."
				actions.start(action_bar, user)
			else
				boutput(user, "You need a screwdriver to close the maintenance panels.")

/obj/structure/preassembeled_vehicleframe/attack_hand(mob/user)
	. = ..()
	//Let's call attackby with no item to get the step advice
	Attackby(null, user)

/obj/structure/preassembeled_vehicleframe/proc/step_wrench_1(var/mob/user)
	src.overlays += image(src.icon, "[pick("frame1", "frame2")]")
	src.stage = BUILD_STEP_WRENCH_1
	src.help_message = "Use a welder to weld the joints together."

/obj/structure/preassembeled_vehicleframe/proc/step_weld_1(var/mob/user)
	src.overlays -= image(src.icon, "frame1")
	src.overlays -= image(src.icon, "frame2")
	src.icon_state = "frame"
	src.stage = BUILD_STEP_WELD_1
	src.help_message = "Use a <b>screwdriver</b> to screw the circuit boards and the engine together."

/obj/structure/preassembeled_vehicleframe/proc/step_screw_1(var/mob/user)
	src.overlays += image(src.icon, "wires")
	src.overlays += image(src.icon, "circuits")
	src.stage = BUILD_STEP_SCREW_1
	src.help_message = "Use any kind of pod armor from a manufacturer."

/obj/structure/preassembeled_vehicleframe/proc/step_armor(var/mob/user, var/obj/item/podarmor/armor)
	user.u_equip(armor)
	qdel(armor)
	src.overlays += image(src.icon, armor.overlay_state)
	src.stage = BUILD_STEP_ARMOR
	src.help_message = "Use a <b>wrench</b> to secure the pod's thrusters and control system."
	src.armor_type = armor.type
	src.vehicle_type = armor.vehicle_types["[src.type]"]
	if(istype(armor, /obj/item/podarmor/armor_custom))
		src.setMaterial(armor.material)

/obj/structure/preassembeled_vehicleframe/proc/step_wrench_2(var/mob/user)
	src.overlays += image(src.icon, "thrust")
	src.overlays += image(src.icon, "control")
	src.stage = BUILD_STEP_WRENCH_2
	src.help_message = "Use a <b>welding tool</b> to weld the exterior."

/obj/structure/preassembeled_vehicleframe/proc/step_weld_2(var/mob/user)
	src.overlays += image(src.icon, "covers")
	src.stage = BUILD_STEP_WELD_2
	src.help_message = "Use a <b>screwdriver</b> to close the maintenance panels."

/obj/structure/preassembeled_vehicleframe/proc/step_screw_2(var/mob/user)
	var/obj/machinery/vehicle/V = new vehicle_type( src.loc )
	if (src.armor_type == /obj/item/podarmor/armor_custom)
		V.name = src.vehicle_name
		V.setMaterial(src.material)
	logTheThing(LOG_STATION, user, "finishes building a [V] in [get_area(user)] ([log_loc(user)])")
	qdel(src)

/*-----------------------------*/
/* Deconstruction              */
/*-----------------------------*/

/obj/structure/preassembeled_vehicleframe/verb/deconstruct()
	set src in oview(1)
	set category = "Local"

	if (usr.stat)
		return

	usr.visible_message("[usr] begins deconstructing the pod frame...")

	var/timer = (5 * src.stage + 30) DECI SECONDS

	SETUP_GENERIC_ACTIONBAR(usr, src, timer, /obj/structure/preassembeled_vehicleframe/proc/deconstruct_done, list(usr), \
		null, null, "[usr] deconstructed the [src].", null)

/obj/structure/preassembeled_vehicleframe/proc/deconstruct_done(var/mob/user)
	var/obj/O
	if (src.stage >= BUILD_STEP_ARMOR)
		O = new src.armor_type( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		O.forensic_holder = src.forensic_holder
		if (istype(O,/obj/item/podarmor/armor_custom))
			O.setMaterial(src.material)
			src.removeMaterial()

	O = new src.box_type( get_turf(src) )
	logTheThing(LOG_STATION, user, "deconstructs [src] in [get_area(user)] ([log_loc(user)])")
	O.fingerprints = src.fingerprints
	O.fingerprints_full = src.fingerprints_full
	O.forensic_holder = src.forensic_holder
	qdel(src)


#undef BUILD_STEP_PLACED
#undef BUILD_STEP_WRENCH_1
#undef BUILD_STEP_WELD_1
#undef BUILD_STEP_SCREW_1
#undef BUILD_STEP_ARMOR
#undef BUILD_STEP_WRENCH_2
#undef BUILD_STEP_WELD_2
