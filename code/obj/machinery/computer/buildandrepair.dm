#define STATE_UNANCHORED 0
#define STATE_ANCHORED 1
#define STATE_HAS_BOARD 2
#define STATE_HAS_CABLES 3
#define STATE_HAS_GLASS 4

/obj/computerframe
	density = 1
	anchored = UNANCHORED
	name = "Console-frame"
	icon = 'icons/obj/computer_frame.dmi'
	icon_state = "0"
	///State of construction of the frame, see defines above
	var/state = STATE_UNANCHORED
	var/obj/item/circuitboard/circuit = null
	var/obj/item/cable_coil/my_cable = null
	material_amt = 0.5
	HELP_MESSAGE_OVERRIDE("")

	blob_act(var/power)
		qdel(src)
//	weight = 1.0E8

ABSTRACT_TYPE(/obj/item/circuitboard)
TYPEINFO(/obj/item/circuitboard)
	mats = 6

/obj/item/circuitboard
	density = 0
	anchored = UNANCHORED
	health = 6
	w_class = W_CLASS_SMALL
	name = "Circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	var/id = null
	var/frequency = null
	var/computertype = null
	var/powernet = null
	var/list/records = null

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

/obj/item/circuitboard/security
	name = "Circuit board (Security Cameras)"
	computertype = "/obj/machinery/computer/security"
/obj/item/circuitboard/security_tv
	name = "Circuit board (Security Television)"
	computertype = "/obj/machinery/computer/security/wooden_tv"
/obj/item/circuitboard/small_tv
	name = "Circuit board (Television)"
	computertype = "/obj/machinery/computer/security/wooden_tv/small"

//obj/item/circuitboard/med_data
//	name = "Circuit board (Medical)"
//	computertype = "/obj/machinery/computer/med_data"
/obj/item/circuitboard/scan_consolenew
	name = "Circuit board (DNA Machine)"
	computertype = "/obj/machinery/scan_consolenew"
/obj/item/circuitboard/communications
	name = "Circuit board (Communications)"
	computertype = "/obj/machinery/computer/communications"
/obj/item/circuitboard/card
	name = "Circuit board (ID Computer)"
	computertype = "/obj/machinery/computer/card"
//obj/item/circuitboard/shield
//	name = "Circuit board (Shield Control)"
//	computertype = "/obj/machinery/computer/stationshield"
/obj/item/circuitboard/teleporter
	name = "Circuit board (Teleporter)"
	computertype = "/obj/machinery/computer/teleporter"
/obj/item/circuitboard/science_teleport
	name = "Circuit board (Science Teleporter)"
	computertype = "/obj/machinery/computer/science_teleport"
/obj/item/circuitboard/secure_data
	name = "Circuit board (Secure Data)"
	computertype = "/obj/machinery/computer/secure_data"
/obj/item/circuitboard/atmospherealerts
	name = "Circuit board (Atmosphere alerts)"
	computertype = "/obj/machinery/computer/atmosphere/alerts"
/obj/item/circuitboard/atmospheresiphonswitch
	name = "Circuit board (Atmosphere siphon control)"
	computertype = "/obj/machinery/computer/atmosphere/siphonswitch"
/obj/item/circuitboard/air_management
	name = "Circuit board (Atmospheric monitor)"
	computertype = "/obj/machinery/computer/general_air_control"
/obj/item/circuitboard/injector_control
	name = "Circuit board (Injector control)"
	computertype = "/obj/machinery/computer/general_air_control/fuel_injection"
/obj/item/circuitboard/general_alert
	name = "Circuit board (General Alert)"
	computertype = "/obj/machinery/computer/general_alert"
/obj/item/circuitboard/pod
	name = "Circuit board (Massdriver control)"
	computertype = "/obj/machinery/computer/pod"
/obj/item/circuitboard/atm
	name = "Circuit board (ATM)"
	computertype = "/obj/machinery/computer/ATM"
/obj/item/circuitboard/bank_data
	name = "Circuit board (Bank Records)"
	computertype = "/obj/machinery/computer/bank_data"
/obj/item/circuitboard/robotics
	name = "Circuit board (Robotics Control)"
	computertype = "/obj/machinery/computer/robotics"
/obj/item/circuitboard/robot_module_rewriter
	name = "circuit board (Cyborg Module Rewriter)"
	computertype = "/obj/machinery/computer/robot_module_rewriter"
/obj/item/circuitboard/cloning
	name = "Circuit board (Cloning)"
	computertype = "/obj/machinery/computer/cloning"
/obj/item/circuitboard/genetics
	name = "Circuit board (Genetics)"
	computertype = "/obj/machinery/computer/genetics"
/obj/item/circuitboard/tetris
	name = "Circuit board (Robustris Pro)"
	computertype = "/obj/machinery/computer/tetris"
/obj/item/circuitboard/arcade
	name = "Circuit board (Arcade)"
	computertype = "/obj/machinery/computer/arcade"
/obj/item/circuitboard/turbine_control
	name = "Circuit board (Turbine control)"
	computertype = "/obj/machinery/computer/turbine_computer"
/obj/item/circuitboard/solar_control
	name = "Circuit board (Solar control)"
	computertype = "/obj/machinery/computer/solar_control"
/obj/item/circuitboard/powermonitor
	name = "Circuit board (Power Monitoring Computer)"
	computertype = "/obj/machinery/computer/power_monitor"
/obj/item/circuitboard/powermonitor_smes
	name = "Circuit board (Engine Monitoring Computer)"
	computertype = "/obj/machinery/computer/power_monitor/smes"
/obj/item/circuitboard/olddoor
	name = "Circuit board (DoorMex)"
	computertype = "/obj/machinery/computer/pod/old"
/obj/item/circuitboard/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	computertype = "/obj/machinery/computer/pod/old/syndicate"
/obj/item/circuitboard/swfdoor
	name = "Circuit board (Magix)"
	computertype = "/obj/machinery/computer/pod/old/swf"
/obj/item/circuitboard/barcode
	name = "Circuit board (General Barcode Computer)"
	computertype = "/obj/machinery/computer/barcode"
/obj/item/circuitboard/barcode_qm
	name = "Circuit board (QM Barcode Computer)"
	computertype = "/obj/machinery/computer/barcode/qm"
/obj/item/circuitboard/operating
	name = "Circuit board (Operating Computer)"
	computertype = "/obj/machinery/computer/operating"
/obj/item/circuitboard/qmorder
	name = "Circuit board (Supply Request Console)"
	computertype = "/obj/machinery/computer/ordercomp"
/obj/item/circuitboard/qmsupply
	name = "Circuit board (Quartermaster's Console)"
	computertype = "/obj/machinery/computer/supplycomp"
/obj/item/circuitboard/transception
	name = "Circuit board (Transception Interlink)"
	computertype = "/obj/machinery/computer/transception"
/obj/item/circuitboard/mining_magnet
	name = "Circuit board (Mining Magnet Computer)"
	computertype = "/obj/machinery/computer/magnet"
/obj/item/circuitboard/telescope
	name = "Circuit board (Quantum Telescope)"
	computertype = "/obj/machinery/computer/telescope"
/obj/item/circuitboard/announcement
	name = "Circuit board (Announcement Computer)"
	computertype = "/obj/machinery/computer/announcement"

/obj/computerframe/meteorhit(obj/O as obj)
	qdel(src)

/obj/computerframe/get_help_message(dist, mob/user)
	switch (src.state)
		if (STATE_UNANCHORED)
			return "You can use a <b>wrench</b> to anchor it."
		if (STATE_ANCHORED)
			if (!src.circuit)
				return {"
					You can insert a circuit board to start assembling a console,
					or use a <b>wrench</b> to unanchor it
				"}
			else
				return {"
					You can use a <b>screwdriver</b> to screw the circuit board in place,
					or a <b>crowbar</b> to remove it.
				"}
		if (STATE_HAS_BOARD)
			return {"
				You can add cables to continue assembly,
				or use a <b>screwdriver</b> to unscrew the circuit board.
			"}
		if (STATE_HAS_CABLES)
			return {"
				You can add glass to continue assembly,
				or use a pair of <b>wirecutters</b> to remove the cables.
			"}
		if (STATE_HAS_GLASS)
			return {"
				You can use a <b>screwdriver</b> to finish assembly,
				or a <b>crowbar</b> to remove the screen.
			"}

/obj/computerframe/attackby(obj/item/P, mob/user)
	var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(user, src, 2 SECONDS, /obj/computerframe/proc/state_actions,\
	list(P,user), P.icon, P.icon_state, null)
	switch(state)
		if (STATE_UNANCHORED)
			if (iswrenchingtool(P))
				actions.start(action_bar, user)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if (isweldingtool(P) && P:try_weld(user,0,-1,1,1))
				actions.start(action_bar, user)
		if (STATE_ANCHORED)
			if (iswrenchingtool(P))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				actions.start(action_bar, user)
			if (istype(P, /obj/item/circuitboard) && !circuit)
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You place the circuit board inside the frame."))
				src.icon_state = "1"
				src.circuit = P
				user.drop_item()
				P.set_loc(src)
			if (isscrewingtool(P) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You screw the circuit board into place."))
				src.state = STATE_HAS_BOARD
				src.icon_state = "2"
			if (ispryingtool(P) && circuit)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You remove the circuit board."))
				src.state = STATE_ANCHORED
				src.icon_state = "0"
				circuit.set_loc(src.loc)
				src.circuit = null
		if (STATE_HAS_BOARD)
			if (isscrewingtool(P) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You unfasten the circuit board."))
				src.state = STATE_ANCHORED
				src.icon_state = "1"
			if (istype(P, /obj/item/cable_coil))
				if (P.amount >= 5)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					actions.start(action_bar, user)
				else
					boutput(user, SPAN_ALERT("You need at least five pieces of cable to wire the computer."))

		if (STATE_HAS_CABLES)
			if (issnippingtool(P))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You remove the cables."))
				src.state = STATE_HAS_BOARD
				src.icon_state = "2"
				//my_cable.set_loc(src.loc) // Haine: fix for Cannot execute null.set loc()
				//my_cable = null
				var/obj/item/cable_coil/C = new /obj/item/cable_coil(src.loc)
				C.amount = 5
				C.UpdateIcon()
			if (istype(P, /obj/item/sheet))
				var/obj/item/sheet/S = P
				if (S.material && S.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					if (S.amount >= 2)
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						actions.start(action_bar, user)
					else
						boutput(user, SPAN_ALERT("You need at least two sheets of glass to install the screen."))
				else
					boutput(user, SPAN_ALERT("This is the wrong kind of material. You'll need a type of glass or crystal."))
		if (STATE_HAS_GLASS)
			if (ispryingtool(P))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You remove the glass panel."))
				src.state = STATE_HAS_CABLES
				src.icon_state = "3"
				var/obj/item/sheet/glass/A = new /obj/item/sheet/glass( src.loc )
				A.amount = 2
			if (isscrewingtool(P))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				boutput(user, SPAN_NOTICE("You connect the monitor."))
				var/obj/machinery/computer/B = new src.circuit.computertype ( src.loc )
				B.set_dir(src.dir)
				if (circuit.id)
					B.id = circuit.id
				if (circuit.records)
					B.records = circuit.records
				if (circuit.frequency)
					B.frequency = circuit.frequency
				logTheThing(LOG_STATION, user, "assembles [B] [log_loc(B)]")
				qdel(src)

/obj/computerframe/proc/state_actions(obj/item/P, mob/user)
	switch(state)
		if(STATE_UNANCHORED)
			if(user.equipped(P) && iswrenchingtool(P))
				boutput(user, SPAN_NOTICE("You wrench the frame into place."))
				src.anchored = ANCHORED
				src.state = STATE_ANCHORED
			if(user.equipped(P) && isweldingtool(P))
				boutput(user, SPAN_NOTICE("You deconstruct the frame."))
				var/obj/item/sheet/A = new /obj/item/sheet( src.loc )
				A.amount = 5
				if (src.material)
					A.setMaterial(src.material)
				else
					var/datum/material/M = getMaterial("steel")
					A.setMaterial(M)
				qdel(src)
		if(STATE_ANCHORED)
			if(user.equipped(P) && iswrenchingtool(P))
				boutput(user, SPAN_NOTICE("You unfasten the frame."))
				src.anchored = UNANCHORED
				src.state = STATE_UNANCHORED
		if(STATE_HAS_BOARD)
			if(user.equipped(P) && istype(P, /obj/item/cable_coil))
				boutput(user, SPAN_NOTICE("You add cables to the frame."))
				P.change_stack_amount(-5)
				src.state = STATE_HAS_CABLES
				src.icon_state = "3"
		if(STATE_HAS_CABLES)
			if(user.equipped(P) && istype(P, /obj/item/sheet))
				boutput(user, SPAN_NOTICE("You put in the glass panel."))
				P.change_stack_amount(-2)
				src.state = STATE_HAS_GLASS
				src.icon_state = "4"

#undef STATE_UNANCHORED
#undef STATE_ANCHORED
#undef STATE_HAS_BOARD
#undef STATE_HAS_CABLES
#undef STATE_HAS_GLASS
