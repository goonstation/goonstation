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
	name = "circuit board"
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
	name = "circuit board (security cameras)"
	computertype = /obj/machinery/computer/security
/obj/item/circuitboard/security_tv
	name = "circuit board (security television)"
	computertype = /obj/machinery/computer/security/wooden_tv
/obj/item/circuitboard/small_tv
	name = "circuit board (television)"
	computertype = /obj/machinery/computer/security/wooden_tv/small
/obj/item/circuitboard/communications
	name = "circuit board (communications)"
	computertype = /obj/machinery/computer/communications
/obj/item/circuitboard/card
	name = "circuit board (ID computer)"
	computertype = /obj/machinery/computer/card
/obj/item/circuitboard/teleporter
	name = "circuit board (teleporter)"
	computertype = /obj/machinery/computer/teleporter
/obj/item/circuitboard/secure_data
	name = "circuit board (secure data)"
	computertype = /obj/machinery/computer/secure_data
/obj/item/circuitboard/atmospheresiphonswitch
	name = "circuit board (atmosphere siphon control)"
	computertype = /obj/machinery/computer/atmosphere/siphonswitch
/obj/item/circuitboard/air_management
	name = "circuit board (atmospheric monitor)"
	computertype = /obj/machinery/computer/general_air_control
/obj/item/circuitboard/injector_control
	name = "circuit board (injector control)"
	computertype = /obj/machinery/computer/general_air_control/fuel_injection
/obj/item/circuitboard/general_alert
	name = "circuit board (general alert)"
	computertype = /obj/machinery/computer/general_alert
/obj/item/circuitboard/pod
	name = "circuit board (massdriver control)"
	computertype = /obj/machinery/computer/pod
/obj/item/circuitboard/atm
	name = "circuit board (ATM)"
	computertype = /obj/machinery/computer/ATM
/obj/item/circuitboard/robotics
	name = "circuit board (robotics control)"
	computertype = /obj/machinery/computer/robotics
/obj/item/circuitboard/robot_module_rewriter
	name = "circuit board (cyborg module rewriter)"
	computertype = /obj/machinery/computer/robot_module_rewriter
/obj/item/circuitboard/cloning
	name = "circuit board (cloning)"
	computertype = /obj/machinery/computer/cloning
/obj/item/circuitboard/genetics
	name = "circuit board (genetics)"
	computertype = /obj/machinery/computer/genetics
/obj/item/circuitboard/tetris
	name = "circuit board (Robustris Pro)"
	computertype = /obj/machinery/computer/tetris
/obj/item/circuitboard/arcade
	name = "circuit board (arcade)"
	computertype = /obj/machinery/computer/arcade
/obj/item/circuitboard/solar_control
	name = "circuit board (solar control)"
	computertype = /obj/machinery/computer/solar_control
/obj/item/circuitboard/powermonitor
	name = "circuit board (power monitoring computer)"
	computertype = /obj/machinery/computer/power_monitor
/obj/item/circuitboard/powermonitor_smes
	name = "circuit board (engine monitoring computer)"
	computertype = /obj/machinery/computer/power_monitor/smes
/obj/item/circuitboard/olddoor
	name = "circuit board (DoorMex)"
	computertype = /obj/machinery/computer/pod/old
/obj/item/circuitboard/syndicatedoor
	name = "circuit board (ProComp Executive)"
	computertype = /obj/machinery/computer/pod/old/syndicate
/obj/item/circuitboard/swfdoor
	name = "circuit board (Magix)"
	computertype = /obj/machinery/computer/pod/old/swf
/obj/item/circuitboard/barcode
	name = "circuit board (general barcode computer)"
	computertype = /obj/machinery/computer/barcode
/obj/item/circuitboard/barcode_qm
	name = "circuit board (QM barcode computer)"
	computertype = /obj/machinery/computer/barcode/qm
/obj/item/circuitboard/operating
	name = "circuit board (operating computer)"
	computertype = /obj/machinery/computer/operating
/obj/item/circuitboard/qmorder
	name = "circuit board (supply request console)"
	computertype = /obj/machinery/computer/ordercomp
/obj/item/circuitboard/qmsupply
	name = "circuit board (quartermaster's console)"
	computertype = /obj/machinery/computer/supplycomp
/obj/item/circuitboard/stockexchange
	name = "circuit board (stock exchange)"
	computertype = /obj/machinery/computer/stockexchange
/obj/item/circuitboard/transception
	name = "circuit board (transception interlink)"
	computertype = /obj/machinery/computer/transception
/obj/item/circuitboard/mining_magnet
	name = "circuit board (mining magnet computer)"
	computertype = /obj/machinery/computer/magnet
/obj/item/circuitboard/telescope
	name = "circuit board (quantum telescope)"
	computertype = /obj/machinery/computer/telescope

// Announcement Computers
/obj/item/circuitboard/announcement
	name = "circuit board (announcement computer)"
	computertype = /obj/machinery/computer/announcement

/obj/item/circuitboard/announcement/station
	name = "circuit board (station announcement computer)"
	computertype = /obj/machinery/computer/announcement/station

TYPEINFO(/obj/item/circuitboard/announcement/bridge)
	mats = 0 //no spamming arrival messages please

/obj/item/circuitboard/announcement/bridge
	name = "circuit board (bridge/arrival announcement computer)"
	computertype = /obj/machinery/computer/announcement/station/bridge

/obj/item/circuitboard/announcement/captain
	name = "circuit board (executive announcement computer)"
	computertype = /obj/machinery/computer/announcement/station/captain

/obj/item/circuitboard/announcement/security
	name = "circuit board (security announcement computer)"
	computertype = /obj/machinery/computer/announcement/station/security

/obj/item/circuitboard/announcement/research
	name = "circuit board (research announcement computer)"
	computertype = /obj/machinery/computer/announcement/station/research

/obj/item/circuitboard/announcement/medical
	name = "circuit board (medical announcement computer)"
	computertype = /obj/machinery/computer/announcement/station/medical

/obj/item/circuitboard/announcement/engineering
	name = "circuit board (engineering announcement computer)"
	computertype = /obj/machinery/computer/announcement/station/engineering

/obj/item/circuitboard/announcement/cargo
	name = "circuit board (qm announcement computer)"
	computertype = /obj/machinery/computer/announcement/station/cargo

/obj/item/circuitboard/announcement/ai
	name = "circuit board (ai announcement computer)"
	computertype = /obj/machinery/computer/announcement/station/ai

/obj/item/circuitboard/announcement/catering
	name = "circuit board (catering announcement computer)"
	computertype = /obj/machinery/computer/announcement/station/catering

/obj/item/circuitboard/announcement/syndicate
	name = "circuit board (syndicate announcement computer)"
	computertype = /obj/machinery/computer/announcement/syndicate
	is_syndicate = TRUE

TYPEINFO(/obj/item/circuitboard/announcement/clown)
	mats = null
/obj/item/circuitboard/announcement/clown
	name = "circuit board (clown announcement computer)"
	computertype = /obj/machinery/computer/announcement/clown

//--------------------------------------------------//

/obj/item/circuitboard/siphon_control
	name = "circuit board (siphon control)"
	computertype = /obj/machinery/computer/siphon_control
/obj/item/circuitboard/chem_request
	name = "circuit board (chemical request console)"
	computertype = /obj/machinery/computer/chem_requester
/obj/item/circuitboard/chem_request_receiver
	name = "circuit board (chemical request receiver)"
	computertype = /obj/machinery/computer/chem_request_receiver
/obj/item/circuitboard/sea_elevator
	name = "circuit board (sea elevator control)"
	computertype = /obj/machinery/computer/elevator/sea

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

/obj/computerframe/bullet_act(obj/projectile/P)
	. = ..()
	switch (P.proj_data.damage_type)
		if (D_KINETIC, D_PIERCING, D_SLASHING)
			if (prob(P.power))
				switch(state)
					if(STATE_UNANCHORED)
						new /obj/item/scrap(src.loc)
						qdel(src)
					if(STATE_ANCHORED)
						if (src.circuit)
							src.eject_board()
						else
							src.anchored = UNANCHORED
							src.state = STATE_UNANCHORED
					if(STATE_HAS_BOARD)
						src.eject_board()
					if(STATE_HAS_CABLES)
						var/obj/item/cable_coil/debris = new /obj/item/cable_coil(src.loc)
						debris.amount = 1
						debris.UpdateIcon()
						debris.throw_at(get_offset_target_turf(src, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2)
						src.state = STATE_HAS_BOARD
						src.icon_state = "2"
					if(STATE_HAS_GLASS)
						var/obj/item/raw_material/shard/glass/debris = new /obj/item/raw_material/shard/glass(src.loc)
						debris.throw_at(get_offset_target_turf(src, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2)
						src.state = STATE_HAS_CABLES
						src.icon_state = "3"

/obj/computerframe/proc/eject_board()
		if (!src.circuit) return
		src.circuit.set_loc(get_turf(src))
		src.circuit.throw_at(get_offset_target_turf(src, rand(5)-rand(5), rand(5)-rand(5)), rand(2,4), 2)
		src.state = STATE_ANCHORED
		src.icon_state = "0"
		src.circuit = null

#undef STATE_UNANCHORED
#undef STATE_ANCHORED
#undef STATE_HAS_BOARD
#undef STATE_HAS_CABLES
#undef STATE_HAS_GLASS
