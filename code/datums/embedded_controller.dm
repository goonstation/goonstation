datum/computer/file/embedded_program
	var/list/memory = list()
	var/state
	var/obj/machinery/embedded_controller/master

	proc
		post_signal(datum/signal/signal, comm_line)
			master?.post_signal(signal, comm_line)
			//else
			//	qdel(signal)

		receive_user_command(command)

		receive_signal(datum/signal/signal, receive_method, receive_param)
			return null

		process()
			return 0


datum/computer/file/embedded_program/access_controller
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag

	state = ACCESS_STATE_LOCKED
	var/target_state = ACCESS_STATE_LOCKED

	receive_signal(datum/signal/signal, receive_method, receive_param)
		var/receive_tag = signal.data["tag"]
		if(!receive_tag) return

		if(receive_tag==exterior_door_tag)
			if(signal.data["door_status"] == "closed")
				if(signal.data["lock_status"] == "locked")
					memory["exterior_status"] = "locked"
				else
					memory["exterior_status"] = "closed"
			else
				memory["exterior_status"] = "open"

		else if(receive_tag==interior_door_tag)
			if(signal.data["door_status"] == "closed")
				if(signal.data["lock_status"] == "locked")
					memory["interior_status"] = "locked"
				else
					memory["interior_status"] = "closed"
			else
				memory["interior_status"] = "open"

		else if(receive_tag==id_tag)
			switch(signal.data["command"])
				if("cycle_interior")
					target_state = ACCESS_STATE_INTERNAL
				if("cycle_exterior")
					target_state = ACCESS_STATE_EXTERNAL
				if("cycle")
					if(state < ACCESS_STATE_LOCKED)
						target_state = ACCESS_STATE_EXTERNAL
					else
						target_state = ACCESS_STATE_INTERNAL

	receive_user_command(command)
		switch(command)
			if("cycle_closed")
				target_state = ACCESS_STATE_LOCKED
			if("cycle_exterior")
				target_state = ACCESS_STATE_EXTERNAL
			if("cycle_interior")
				target_state = ACCESS_STATE_INTERNAL

	process()
		switch(state)
			if(ACCESS_STATE_INTERNAL) // state -1
				if(target_state > state)
					if(memory["interior_status"] == "locked")
						state = ACCESS_STATE_LOCKED
					else
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = interior_door_tag
						if(memory["interior_status"] == "closed")
							signal.data["command"] = "lock"
						else
							signal.data["command"] = "secure_close"
						post_signal(signal)

			if(ACCESS_STATE_LOCKED)
				if(target_state < state)
					if(memory["exterior_status"] != "locked")
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = exterior_door_tag
						if(memory["exterior_status"] == "closed")
							signal.data["command"] = "lock"
						else
							signal.data["command"] = "secure_close"
						post_signal(signal)
					else
						if(memory["interior_status"] == "closed" || memory["interior_status"] == "open")
							state = ACCESS_STATE_INTERNAL
						else
							var/datum/signal/signal = get_free_signal()
							signal.data["tag"] = interior_door_tag
							signal.data["command"] = "unlock"
							post_signal(signal)
				else if(target_state > state)
					if(memory["interior_status"] != "locked")
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = interior_door_tag
						if(memory["interior_status"] == "closed")
							signal.data["command"] = "lock"
						else
							signal.data["command"] = "secure_close"
						post_signal(signal)
					else
						if(memory["exterior_status"] == "closed" || memory["exterior_status"] == "open")
							state = ACCESS_STATE_EXTERNAL
						else
							var/datum/signal/signal = get_free_signal()
							signal.data["tag"] = exterior_door_tag
							signal.data["command"] = "unlock"
							post_signal(signal)
				else
					if(memory["interior_status"] != "locked")
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = interior_door_tag
						if(memory["interior_status"] == "closed")
							signal.data["command"] = "lock"
						else
							signal.data["command"] = "secure_close"
						post_signal(signal)
					else if(memory["exterior_status"] != "locked")
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = exterior_door_tag
						if(memory["exterior_status"] == "closed")
							signal.data["command"] = "lock"
						else
							signal.data["command"] = "secure_close"
						post_signal(signal)

			if(ACCESS_STATE_EXTERNAL) //state 1
				if(target_state < state)
					if(memory["exterior_status"] == "locked")
						state = ACCESS_STATE_LOCKED
					else
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = exterior_door_tag
						if(memory["exterior_status"] == "closed")
							signal.data["command"] = "lock"
						else
							signal.data["command"] = "secure_close"
						post_signal(signal)


		return 1


datum/computer/file/embedded_program/airlock_controller
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag
	var/airpump_tag
	var/sensor_tag
	var/sanitize_external

	state = AIRLOCK_STATE_CLOSED
	var/target_state = AIRLOCK_STATE_CLOSED
	var/sensor_pressure = null

	receive_signal(datum/signal/signal, receive_method, receive_param)
		var/receive_tag = signal.data["tag"]
		if(!receive_tag) return

		if(receive_tag==sensor_tag)
			if(signal.data["pressure"])
				sensor_pressure = text2num(signal.data["pressure"])

		else if(receive_tag==exterior_door_tag)
			memory["exterior_status"] = signal.data["door_status"]

		else if(receive_tag==interior_door_tag)
			memory["interior_status"] = signal.data["door_status"]

		else if(receive_tag==airpump_tag)
			if(signal.data["power"]=="on")
				memory["pump_status"] = signal.data["direction"]
			else
				memory["pump_status"] = "off"

		else if(receive_tag==id_tag)
			switch(signal.data["command"])
				if("cycle")
					if(state < AIRLOCK_STATE_CLOSED)
						target_state = AIRLOCK_STATE_OUTOPEN
					else
						target_state = AIRLOCK_STATE_INOPEN

	receive_user_command(command)
		switch(command)
			if("cycle_closed")
				target_state = AIRLOCK_STATE_CLOSED
			if("cycle_exterior")
				target_state = AIRLOCK_STATE_OUTOPEN
			if("cycle_interior")
				target_state = AIRLOCK_STATE_INOPEN
			if("abort")
				target_state = AIRLOCK_STATE_CLOSED

	process()
		switch(state)
			if(AIRLOCK_STATE_INOPEN) // state -2
				if(target_state > state)
					if(memory["interior_status"] == "closed")
						state = AIRLOCK_STATE_CLOSED
					else
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = interior_door_tag
						signal.data["command"] = "secure_close"
						post_signal(signal)
				else
					if(memory["pump_status"] != "off")
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = airpump_tag
						signal.data["command"] = "power_off"
						post_signal(signal)

			if(AIRLOCK_STATE_PRESSURIZE)
				if(target_state < state)
					if(sensor_pressure >= ONE_ATMOSPHERE*0.95)
						if(memory["interior_status"] == "open")
							state = AIRLOCK_STATE_INOPEN
						else
							var/datum/signal/signal = get_free_signal()
							signal.data["tag"] = interior_door_tag
							signal.data["command"] = "secure_open"
							post_signal(signal)
					else
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = airpump_tag
						if(memory["pump_status"] == "siphon")
							signal.data["command"] = "stabalize"
						else if(memory["pump_status"] != "release")
							signal.data["command"] = "power_on"
						post_signal(signal)
				else if(target_state > state)
					state = AIRLOCK_STATE_CLOSED

			if(AIRLOCK_STATE_CLOSED)
				if(target_state > state)
					if(memory["interior_status"] == "closed")
						state = AIRLOCK_STATE_DEPRESSURIZE
					else
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = interior_door_tag
						signal.data["command"] = "secure_close"
						post_signal(signal)
				else if(target_state < state)
					if(memory["exterior_status"] == "closed")
						state = AIRLOCK_STATE_PRESSURIZE
					else
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = exterior_door_tag
						signal.data["command"] = "secure_close"
						post_signal(signal)

				else
					if(memory["pump_status"] != "off")
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = airpump_tag
						signal.data["command"] = "power_off"
						post_signal(signal)

			if(AIRLOCK_STATE_DEPRESSURIZE)
				var/target_pressure = ONE_ATMOSPHERE*0.05
				if(sanitize_external)
					target_pressure = ONE_ATMOSPHERE*0.01

				if(sensor_pressure <= target_pressure)
					if(target_state > state)
						if(memory["exterior_status"] == "open")
							state = AIRLOCK_STATE_OUTOPEN
						else
							var/datum/signal/signal = get_free_signal()
							signal.data["tag"] = exterior_door_tag
							signal.data["command"] = "secure_open"
							post_signal(signal)
					else if(target_state < state)
						state = AIRLOCK_STATE_CLOSED
				else if((target_state < state) && !sanitize_external)
					state = AIRLOCK_STATE_CLOSED
				else
					var/datum/signal/signal = get_free_signal()
					signal.transmission_method = 1 //radio signal
					signal.data["tag"] = airpump_tag
					if(memory["pump_status"] == "release")
						signal.data["command"] = "purge"
					else if(memory["pump_status"] != "siphon")
						signal.data["command"] = "power_on"
					post_signal(signal)

			if(AIRLOCK_STATE_OUTOPEN) //state 2
				if(target_state < state)
					if(memory["exterior_status"] == "closed")
						if(sanitize_external)
							state = AIRLOCK_STATE_DEPRESSURIZE
						else
							state = AIRLOCK_STATE_CLOSED
					else
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = exterior_door_tag
						signal.data["command"] = "secure_close"
						post_signal(signal)
				else
					if(memory["pump_status"] != "off")
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = airpump_tag
						signal.data["command"] = "power_off"
						post_signal(signal)

		memory["sensor_pressure"] = sensor_pressure
		memory["processing"] = state != target_state
		sensor_pressure = null

		return 1


datum/computer/file/embedded_program/department_controller
	var/id_tag
	var/door_tag

	state = ACCESS_STATE_LOCKED
	var/target_state = ACCESS_STATE_EXTERNAL

	receive_signal(datum/signal/signal, receive_method, receive_param)
		var/receive_tag = signal.data["tag"]
		if(!receive_tag) return

		if(receive_tag==door_tag)
			if(signal.data["door_status"] == "closed")
				if(signal.data["lock_status"] == "locked")
					memory["door_status"] = "locked"
				else
					memory["door_status"] = "closed"
			else
				memory["door_status"] = "open"

	receive_user_command(command)
		switch(command)
			if("lock")
				target_state = ACCESS_STATE_LOCKED
			if("unlock")
				target_state = ACCESS_STATE_EXTERNAL

	process()
		switch(state)
			if(ACCESS_STATE_LOCKED)
				if(target_state > state)
					if(memory["door_status"] == "closed" || memory["door_status"] == "open")
						state = ACCESS_STATE_EXTERNAL
						return 1
					else
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = door_tag
						signal.data["command"] = "secure_open"
						post_signal(signal)
				else
					if(memory["door_status"] != "locked")
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = door_tag
						if(memory["door_status"] == "closed")
							signal.data["command"] = "lock"
						else
							signal.data["command"] = "secure_close"
						post_signal(signal)


			if(ACCESS_STATE_EXTERNAL) //state 1
				if(target_state < state)
					if(memory["door_status"] == "locked")
						state = ACCESS_STATE_LOCKED
						return 1
					else
						var/datum/signal/signal = get_free_signal()
						signal.data["tag"] = door_tag
						if(memory["door_status"] == "closed")
							signal.data["command"] = "lock"
						else
							signal.data["command"] = "secure_close"
						post_signal(signal)


		return 0



obj/machinery/embedded_controller
	var/datum/computer/file/embedded_program/program

	name = "Embedded Controller"
	density = 0
	anchored = ANCHORED

	var/on = 1

	attack_hand(mob/user)
		user.Browse(return_text(), "window=computer")
		src.add_dialog(user)
		onclose(user, "computer")

	disposing()
		if (program)
			program.master = null
			program.memory = null
			program.dispose()
			program = null

		..()

	proc/return_text()

	proc/post_signal(datum/signal/signal, comm_line)
		return 0

	receive_signal(datum/signal/signal, receive_method, receive_param)
		if(!signal || signal.encryption) return

		if(program)
			return program.receive_signal(signal, receive_method, receive_param)

	Topic(href, href_list)
		if(..())
			return 0

		program?.receive_user_command(href_list["command"])

		src.add_dialog(usr)

	process()
		program?.process()

		UpdateIcon()
		src.updateDialog()
		..()

	radio
		var/frequency

		New()
			..()
			MAKE_SENDER_RADIO_PACKET_COMPONENT(null, frequency)

		post_signal(datum/signal/signal)
			return SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)


obj/machinery/embedded_controller/radio/access_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_standby"

	name = "Access Console"
	density = 0

	frequency = FREQ_AIRLOCK_CONTROL

	// Setup parameters only
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag

	initialize()
		..()

		var/datum/computer/file/embedded_program/access_controller/new_prog = new

		new_prog.id_tag = id_tag
		new_prog.exterior_door_tag = exterior_door_tag
		new_prog.interior_door_tag = interior_door_tag

		new_prog.master = src
		program = new_prog

	update_icon()
		if(on && program)
			if(program.memory["processing"])
				icon_state = "access_control_process"
			else
				icon_state = "access_control_standby"
		else
			icon_state = "access_control_off"


	return_text()
		var/state_options = null

		var/state = 0
		var/exterior_status = "----"
		var/interior_status = "----"
		if(program)
			state = program.state
			exterior_status = program.memory["exterior_status"]
			interior_status = program.memory["interior_status"]

		switch(state)
			if(ACCESS_STATE_INTERNAL)
				state_options = {"<A href='?src=\ref[src];command=cycle_closed'>Lock Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_exterior'>Cycle to Exterior Airlock</A><BR>"}
			if(ACCESS_STATE_LOCKED)
				state_options = {"<A href='?src=\ref[src];command=cycle_interior'>Unlock Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_exterior'>Unlock Exterior Airlock</A><BR>"}
			if(ACCESS_STATE_EXTERNAL)
				state_options = {"<A href='?src=\ref[src];command=cycle_interior'>Cycle to Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_closed'>Lock Exterior Airlock</A><BR>"}

		var/output = {"<B>Access Control Console</B><HR>
[state_options]<HR>
<B>Exterior Door: </B> [exterior_status]<BR>
<B>Interior Door: </B> [interior_status]<BR>"}

		return output


obj/machinery/embedded_controller/radio/airlock_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"

	name = "Airlock Console"
	density = 0

	frequency = FREQ_AIRLOCK_CONTROL

	// Setup parameters only
	var/id_tag
	var/exterior_door_tag
	var/interior_door_tag
	var/airpump_tag
	var/sensor_tag
	var/sanitize_external

	initialize()
		..()

		var/datum/computer/file/embedded_program/airlock_controller/new_prog = new

		new_prog.id_tag = id_tag
		new_prog.exterior_door_tag = exterior_door_tag
		new_prog.interior_door_tag = interior_door_tag
		new_prog.airpump_tag = airpump_tag
		new_prog.sensor_tag = sensor_tag
		new_prog.sanitize_external = sanitize_external

		new_prog.master = src
		program = new_prog

	update_icon()
		if(on && program)
			if(program.memory["processing"])
				icon_state = "airlock_control_process"
			else
				icon_state = "airlock_control_standby"
		else
			icon_state = "airlock_control_off"


	return_text()
		var/state_options = null

		var/state = 0
		var/sensor_pressure = "----"
		var/exterior_status = "----"
		var/interior_status = "----"
		var/pump_status = "----"
		if(program)
			state = program.state
			sensor_pressure = program.memory["sensor_pressure"]
			exterior_status = program.memory["exterior_status"]
			interior_status = program.memory["interior_status"]
			pump_status = program.memory["pump_status"]

		switch(state)
			if(AIRLOCK_STATE_INOPEN)
				state_options = {"<A href='?src=\ref[src];command=cycle_closed'>Close Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_exterior'>Cycle to Exterior Airlock</A><BR>"}
			if(AIRLOCK_STATE_PRESSURIZE)
				state_options = "<A href='?src=\ref[src];command=abort'>Abort Cycling</A><BR>"
			if(AIRLOCK_STATE_CLOSED)
				state_options = {"<A href='?src=\ref[src];command=cycle_interior'>Open Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_exterior'>Open Exterior Airlock</A><BR>"}
			if(AIRLOCK_STATE_DEPRESSURIZE)
				state_options = "<A href='?src=\ref[src];command=abort'>Abort Cycling</A><BR>"
			if(AIRLOCK_STATE_OUTOPEN)
				state_options = {"<A href='?src=\ref[src];command=cycle_interior'>Cycle to Interior Airlock</A><BR>
<A href='?src=\ref[src];command=cycle_closed'>Close Exterior Airlock</A><BR>"}

		var/output = {"<B>Airlock Control Console</B><HR>
[state_options]<HR>
<B>Chamber Pressure:</B> [sensor_pressure] kPa<BR>
<B>Exterior Door: </B> [exterior_status]<BR>
<B>Interior Door: </B> [interior_status]<BR>
<B>Control Pump: </B> [pump_status]<BR>"}

		return output


obj/machinery/embedded_controller/radio/department_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_standby"

	name = "Access Console"
	density = 0

	frequency = FREQ_AIRLOCK_CONTROL

	// Setup parameters only
	var/id_tag
	var/door_tag
	var/locked = 1

	initialize()
		..()

		var/datum/computer/file/embedded_program/department_controller/new_prog = new

		new_prog.id_tag = id_tag
		new_prog.door_tag = door_tag

		new_prog.master = src
		program = new_prog

	update_icon()
		if(!(status & NOPOWER) && program)
			if(program.memory["processing"])
				icon_state = "access_control_process"
			else
				icon_state = "access_control_standby"
		else
			icon_state = "access_control_off"

	Topic(href, href_list)
		if (src.locked && !can_access_remotely(usr))
			return

		program?.receive_user_command(href_list["command"])

		src.add_dialog(usr)

	process()
		if(status & NOPOWER)
			return
		if(program)
			var/update = program.process()
			if (update)
				src.updateDialog()

		UpdateIcon()

	attackby(var/obj/item/I, mob/user)
		if (istype(I, /obj/item/device/pda2) && I:ID_card)
			I = I:ID_card
		if(istype(I, /obj/item/card/id))
			if (src.allowed(user))
				user.visible_message("[user] [src.locked ? "unlocks" : "locks"] the access panel.","You [src.locked ? "unlock" : "lock"] the access panel.")
				src.locked = !src.locked
			else
				boutput(user, "<span class='alert'>Access denied.</span>")
		else
			..()

		return

	attack_ai(mob/user)
		return attack_hand(user)

	attack_hand(mob/user)
		if (src.status & NOPOWER)
			return

		src.add_dialog(user)

		var/state_options = null

		var/state = 0
		var/door_status = "----"
		if(program)
			state = program.state
			door_status = program.memory["door_status"]

		switch(state)
			if(ACCESS_STATE_LOCKED)
				state_options = "<A href='?src=\ref[src];command=unlock'>Unseal Airlocks</A>"
			if(ACCESS_STATE_EXTERNAL)
				state_options = "<A href='?src=\ref[src];command=lock'>Seal Airlocks</A>"

		var/output = "<B>Department Airlock Control Console</B><HR>"
		if (src.locked && !issilicon(user))
			output += "<center><b>Console Locked</b><br><i>Please swipe ID</i></center>"
		else
			output += "[state_options]<hr><b>Airlock Status: </b> [door_status]"

		user.Browse(output, "window=dcontroller;size=245x302")
		onclose(user, "dcontroller")

