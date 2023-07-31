ABSTRACT_TYPE(/obj/item/preassembled_frame_box)
/obj/item/preassembled_frame_box
	desc = "You can hear an awful lot of junk rattling around in this box."
	help_message = "Use the frame kit in a pod bay to begin construction, for which you'll need a wrench, a welder, a screwdriver and some pod armor from a manufacturer."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	var/frame_type

	attack_self(mob/user as mob)
		boutput(user, "<span class='notice'>You dump out the box of parts onto the floor.</span>")
		var/obj/O = new frame_type( get_turf(user) )
		logTheThing(LOG_STATION, user, "builds [O] in [get_area(user)] ([log_loc(user)])")
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		qdel(src)

/obj/item/preassembled_frame_box/putt
	name = "Preasembled MiniPutt Frame Kit"
	frame_type = /obj/structure/preassembeled_vehicleframe/puttframe

/obj/item/preassembled_frame_box/sub
	name = "Preasembled Minisub Frame Kit"
	frame_type = /obj/structure/preassembeled_vehicleframe/subframe

/obj/item/preassembled_frame_box/pod
	name = "Preasembled Pod Frame Kit"
	frame_type = /obj/structure/preassembeled_vehicleframe/podframe

	attack_self(mob/user as mob)
		// lets assume everything is ok so we can stop checking at the first sign of trouble
		var/canbuild = 1

		// buffers whee
		var/list/checkturfs = block(get_turf(user),locate(user.x+1,user.y+1,user.z))
		var/turf/T
		var/atom/A

		// check the 2x2 square that the finished pod will occupy
		for(T in checkturfs)
			if (istype(T, /turf/space))
				continue
			if (!T.allows_vehicles || T.density)
				canbuild = 0
				boutput(user, "<span class='alert'>You can't build a pod here! It'd get stuck.</span>")
				break
			for (A in T)
				if (A == user)
					continue
				if (A.density)
					canbuild = 0
					boutput(user, "<span class='alert'>You can't build a pod here! [A] is in the way.</span>")
					break
			if (!canbuild)
				break

		if (canbuild)
			..()

ABSTRACT_TYPE(/obj/structure/preassembeled_vehicleframe)
/obj/structure/preassembeled_vehicleframe
	var/stage = 0
	var/obj/item/podarmor/armor_type = null
	var/box_type = null
	var/vehicle_name = null
	var/vehicle_type = null
	anchored = ANCHORED
	density = 1
	help_message = "Use a wrench to secure the parts together."
	var/step_build_time = 10 SECONDS //per each 7 steps

/obj/structure/preassembeled_vehicleframe/puttframe
	name = "Preassembeled MiniPutt Frame"
	desc = "A MiniPutt ship under construction."
	icon = 'icons/obj/ship.dmi'
	icon_state = "parts"
	box_type = /obj/item/preassembled_frame_box/putt
	vehicle_name = "MiniPutt"

/obj/structure/preassembeled_vehicleframe/subframe
	name = "Preassembeled Minisub Frame"
	desc = "A minisub under construction."
	icon = 'icons/obj/machines/8dirvehicles.dmi'
	icon_state = "parts"
	box_type = /obj/item/preassembled_frame_box/sub
	vehicle_name = "Minisub"

/obj/structure/preassembeled_vehicleframe/podframe
	name = "Preassembeled Pod Frame"
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

/obj/structure/preassembeled_vehicleframe/attackby(obj/item/W, mob/living/user)
	switch(stage)
		if(0)
			if (iswrenchingtool(W))
				user.visible_message("[user] begins securing the frame...")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, step_build_time, /obj/structure/preassembeled_vehicleframe/proc/step_wrench_1, list(user), \
			 		W.icon, W.icon_state, "[user] finishes wrenching the frame parts together.", null)
			else
				boutput(user, "You need a wrench to secure the parts together.")

		if(1)
			if (isweldingtool(W))
				if(!W:try_weld(user, 1))
					return
				user.visible_message("[user] begins welding the joints of the frame...")
				SETUP_GENERIC_ACTIONBAR(user, src, step_build_time, /obj/structure/preassembeled_vehicleframe/proc/step_weld_1, list(user), \
			 		W.icon, W.icon_state, "[user] welds the joints of the frame together.", null)
			else
				boutput(user, "You need a welder to weld the joints together.")

		if(2)
			if (isscrewingtool(W))
				user.visible_message("[user] begins screwing down the frame's circuit boards and it's engine...")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, step_build_time, /obj/structure/preassembeled_vehicleframe/proc/step_screw_1, list(user), \
			 		W.icon, W.icon_state, "[user] finishes screwing the the frame's circuit boards and it's engine.", null)
			else
				boutput(user, "You need a screwdriver to screw the circuit boards and the engine together.")


		if(3)
			if(istype(W, /obj/item/podarmor))
				var/obj/item/podarmor/armor = W
				if(!armor.vehicle_types["[src.type]"])
					boutput(user, "That type of armor is not compatible with this frame.")
					return
				user.visible_message("[user] begins installing the [W]...")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, step_build_time, /obj/structure/preassembeled_vehicleframe/proc/step_armor, list(user, armor), \
			 		W.icon, W.icon_state, "[user] loosely attaches the light armor plating.", null)
			else
				boutput(user, "You need some pod armor to put on.")

		if(4)
			if (iswrenchingtool(W))
				user.visible_message("[user] begins securing the pod's thrusters and control system...")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, step_build_time, /obj/structure/preassembeled_vehicleframe/proc/step_wrench_2, list(user), \
			 		W.icon, W.icon_state, "[user] secures the pod's thrusters and control system.", null)
			else
				boutput(user, "You need a wrench to secure the pod's thrusters and control system.")

		if(5)
			if (isweldingtool(W))
				if(!W:try_weld(user, 1))
					return
				user.visible_message("[user] begins welding the exterior...")
				SETUP_GENERIC_ACTIONBAR(user, src, step_build_time, /obj/structure/preassembeled_vehicleframe/proc/step_weld_2, list(user), \
			 		W.icon, W.icon_state, "[user] welds the seams of the outer skin to make it air-tight.", null)
			else
				boutput(user, "You need a welder to weld the exterior.")

		if(6)
			if (isscrewingtool(W))
				user.visible_message("[user] begins screwing the pod's maintenance panels shut...")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, step_build_time, /obj/structure/preassembeled_vehicleframe/proc/step_screw_2, list(user), \
			 		W.icon, W.icon_state, "With the cockpit and exterior indicators secured, the control system automatically starts up.", null)
			else
				boutput(user, "You need a screwdriver to close the maintenance panels.")

/obj/structure/preassembeled_vehicleframe/proc/step_wrench_1(var/mob/user)
	src.overlays += image(src.icon, "[pick("frame1", "frame2")]")
	stage = 1
	help_message = "Use a welder to weld the joints together."

/obj/structure/preassembeled_vehicleframe/proc/step_weld_1(var/mob/user)
	src.overlays -= image(src.icon, "frame1")
	src.overlays -= image(src.icon, "frame2")
	icon_state = "frame"
	stage = 2
	help_message = "Use a screwdriver to screw the circuit boards and the engine together."

/obj/structure/preassembeled_vehicleframe/proc/step_screw_1(var/mob/user)
	src.overlays += image(src.icon, "wires")
	src.overlays += image(src.icon, "circuits")
	stage = 3
	help_message = "Use any kind of pod armor from a manufacturer."

/obj/structure/preassembeled_vehicleframe/proc/step_armor(var/mob/user, var/obj/item/podarmor/armor)
	user.u_equip(armor)
	qdel(armor)
	src.overlays += image(src.icon, armor.overlay_state)
	stage = 4
	help_message = "Use a wrench to secure the pod's thrusters and control system."
	armor_type = armor.type
	src.vehicle_type = armor.vehicle_types["[src.type]"]
	if(istype(armor, /obj/item/podarmor/armor_custom))
		src.setMaterial(armor.material)

/obj/structure/preassembeled_vehicleframe/proc/step_wrench_2(var/mob/user)
	src.overlays += image(src.icon, "thrust")
	src.overlays += image(src.icon, "control")
	stage = 5
	help_message = "Use a welder to weld the exterior."

/obj/structure/preassembeled_vehicleframe/proc/step_weld_2(var/mob/user)
	src.overlays += image(src.icon, "covers")
	stage = 6
	help_message = "Use a screwdriver to close the maintenance panels."

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

	boutput(usr, "Deconstructing frame...")

	var/timer = (5 * stage + 30) DECI SECONDS

	SETUP_GENERIC_ACTIONBAR(usr, src, timer, /obj/structure/preassembeled_vehicleframe/proc/deconstruct_done, list(usr), \
		null, null, "[usr] deconstructed the [src].", null)

/obj/structure/preassembeled_vehicleframe/proc/deconstruct_done(var/mob/user)
	var/obj/O
	if (stage >= 4)
		O = new src.armor_type( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		if (istype(O,/obj/item/podarmor/armor_custom))
			O.setMaterial(src.material)
			src.removeMaterial()

	O = new src.box_type( get_turf(src) )
	logTheThing(LOG_STATION, usr, "deconstructs [src] in [get_area(usr)] ([log_loc(usr)])")
	O.fingerprints = src.fingerprints
	O.fingerprints_full = src.fingerprints_full
	qdel(src)
