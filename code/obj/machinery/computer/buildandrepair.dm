/obj/computerframe
	density = 1
	anchored = 0
	name = "Console-frame"
	icon = 'icons/obj/computer_frame.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/circuitboard/circuit = null
	var/obj/item/cable_coil/my_cable = null

	blob_act(var/power)
		qdel(src)
//	weight = 1.0E8

/obj/item/circuitboard
	density = 0
	anchored = 0
	w_class = 2.0
	name = "Circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	var/id = null
	var/frequency = null
	var/computertype = null
	var/powernet = null
	var/list/records = null
	mats = 6

/obj/item/circuitboard/security
	name = "Circuit board (Security)"
	computertype = "/obj/machinery/computer/security"
/obj/item/circuitboard/aiupload
	name = "Circuit board (AI Upload)"
	computertype = "/obj/machinery/computer/aiupload"
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
	computertype = "/obj/machinery/power/solar_control"
/obj/item/circuitboard/powermonitor
	name = "Circuit board (Power Monitoring Computer)"
	computertype = "/obj/machinery/power/monitor"
/obj/item/circuitboard/powermonitor_smes
	name = "Circuit board (Engine Monitoring Computer)"
	computertype = "/obj/machinery/power/monitor/smes"
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
/obj/item/circuitboard/mining_magnet
	name = "Circuit board (Mining Magnet Computer)"
	computertype = "/obj/machinery/computer/magnet"

/obj/computerframe/meteorhit(obj/O as obj)
	qdel(src)

/obj/computerframe/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if (0)
			if (iswrenchingtool(P))
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if (do_after(user, 2 SECONDS))
					boutput(user, "<span class='notice'>You wrench the frame into place.</span>")
					src.anchored = 1
					src.state = 1
			if (isweldingtool(P) && P:try_weld(user,0,-1,0,1))
				if (do_after(user, 2 SECONDS))
					boutput(user, "<span class='notice'>You deconstruct the frame.</span>")
					var/obj/item/sheet/A = new /obj/item/sheet( src.loc )
					A.amount = 5
					if (src.material)
						A.setMaterial(src.material)
					else
						var/datum/material/M = getMaterial("steel")
						A.setMaterial(M)
					qdel(src)
		if (1)
			if (iswrenchingtool(P))
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if (do_after(user, 2 SECONDS))
					boutput(user, "<span class='notice'>You unfasten the frame.</span>")
					src.anchored = 0
					src.state = 0
			if (istype(P, /obj/item/circuitboard) && !circuit)
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				boutput(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
				src.icon_state = "1"
				src.circuit = P
				user.drop_item()
				P.set_loc(src)
			if (isscrewingtool(P) && circuit)
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				boutput(user, "<span class='notice'>You screw the circuit board into place.</span>")
				src.state = 2
				src.icon_state = "2"
			if (ispryingtool(P) && circuit)
				playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
				boutput(user, "<span class='notice'>You remove the circuit board.</span>")
				src.state = 1
				src.icon_state = "0"
				circuit.set_loc(src.loc)
				src.circuit = null
		if (2)
			if (isscrewingtool(P) && circuit)
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				boutput(user, "<span class='notice'>You unfasten the circuit board.</span>")
				src.state = 1
				src.icon_state = "1"
			if (istype(P, /obj/item/cable_coil))
				if (P:amount >= 5)
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
					if (do_after(user, 2 SECONDS) && P) //Wire: fix for Cannot read null.amount (&& P)
						//my_cable = P:take(5, src) // Haine: fix for Cannot execute null.set loc()
						P:use(5)
						boutput(user, "<span class='notice'>You add cables to the frame.</span>")
						src.state = 3
						src.icon_state = "3"
				else
					boutput(user, "<span class='alert'>You need at least five pieces of cable to wire the computer.</span>")

		if (3)
			if (issnippingtool(P))
				playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1)
				boutput(user, "<span class='notice'>You remove the cables.</span>")
				src.state = 2
				src.icon_state = "2"
				//my_cable.set_loc(src.loc) // Haine: fix for Cannot execute null.set loc()
				//my_cable = null
				var/obj/item/cable_coil/C = new /obj/item/cable_coil(src.loc)
				C.amount = 5

			if (istype(P, /obj/item/sheet))
				var/obj/item/sheet/S = P
				if (S.material && S.material.material_flags & MATERIAL_CRYSTAL)
					if (S.amount >= 2)
						playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
						if (do_after(user, 2 SECONDS))
							if (S) S.amount -= 2
							if (P && P.amount < 1)
								qdel(P)
							boutput(user, "<span class='notice'>You put in the glass panel.</span>")
							src.state = 4
							src.icon_state = "4"
					else
						boutput(user, "<span class='alert'>You need at least two sheets of glass to install the screen.</span>")
				else
					boutput(user, "<span class='alert'>This is the wrong kind of material. You'll need a type of glass or crystal.</span>")
		if (4)
			if (ispryingtool(P))
				playsound(src.loc, "sound/items/Crowbar.ogg", 50, 1)
				boutput(user, "<span class='notice'>You remove the glass panel.</span>")
				src.state = 3
				src.icon_state = "3"
				var/obj/item/sheet/glass/A = new /obj/item/sheet/glass( src.loc )
				A.amount = 2
			if (isscrewingtool(P))
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				boutput(user, "<span class='notice'>You connect the monitor.</span>")
				var/B = new src.circuit.computertype ( src.loc )
				if (circuit.powernet) B:powernet = circuit.powernet
				if (circuit.id) B:id = circuit.id
				if (circuit.records) B:records = circuit.records
				if (circuit.frequency) B:frequency = circuit.frequency
				logTheThing("station", user, null, "assembles [B] [log_loc(B)]")
				qdel(src)
