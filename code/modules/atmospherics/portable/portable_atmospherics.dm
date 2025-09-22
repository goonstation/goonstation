/obj/machinery/portable_atmospherics
	name = "atmoalter"
	var/datum/gas_mixture/air_contents = null

	var/obj/machinery/atmospherics/unary/portables_connector/connected_port
	var/obj/item/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/maximum_pressure = 90*ONE_ATMOSPHERE

	var/init_connected = 0

	var/contained = 0

	onMaterialChanged()
		..()
		if(istype(src.material))
			// Roughly tweaked to be equal to steel (hard = 15 density = 30) = 90,
			// which I assume these are generally made out of
			// Mauxite is 15 / 50, so slightly better.
			// I went with hardness here just because I figure if it's hard it doesn't break all that well.
			// Probably could be adjusted, but this gives decent results, I guess. Eh.
			maximum_pressure = max((src.material.getProperty("hard") * 4 + src.material.getProperty("density")) * ONE_ATMOSPHERE, ONE_ATMOSPHERE * 2)
		return

	New()
		..()

		air_contents = new /datum/gas_mixture

		air_contents.volume = volume
		air_contents.temperature = T20C

		if(init_connected)
			var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector) in loc
			if(possible_port)
				connect(possible_port)

		return 1

	process()
		if(contained) return
		if(!connected_port) //only react when pipe_network wont it do it for you
			//Allow for reactions
			air_contents?.react() //ZeWaka: Fix for null.react()

	disposing()
		disconnect()
		if (air_contents)
			qdel(air_contents)
			air_contents = null

		..()

	get_desc()
		. = " It is labeled to have a volume of [src.volume] litres."

	proc
		connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
			//Make sure not already connected to something else
			if(connected_port || !new_port || new_port.connected_device)
				return 0

			//Make sure are close enough for a valid connection
			if(new_port.loc != loc)
				return 0

			add_fingerprint(usr)

			//Perform the connection
			connected_port = new_port
			connected_port.connected_device = src

			anchored = ANCHORED //Prevent movement

			//Actually enforce the air sharing
			var/datum/pipe_network/network = connected_port.return_network(src)
			if(network && !network.gases.Find(air_contents))
				network.gases += air_contents

			return 1

		can_connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
			//Make sure not already connected to something else
			if(connected_port || !new_port || new_port.connected_device)
				return 0

			//Make sure are close enough for a valid connection
			if(new_port.loc != loc)
				return 0
			return 1

		disconnect()
			if(!connected_port)
				return 0

			var/datum/pipe_network/network = connected_port.return_network(src)
			network?.gases -= air_contents

			anchored = UNANCHORED

			connected_port.connected_device = null
			connected_port = null

			return 1

/obj/machinery/portable_atmospherics/proc/eject_tank()
	if(holding)
		holding.set_loc(loc)
		usr.put_in_hand_or_eject(holding) // try to eject it into the users hand, if we can
		holding = null
		UpdateIcon()
	return

/obj/machinery/portable_atmospherics/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/tank))
		if(!src.holding)
			boutput(user, SPAN_NOTICE("You attach the [W.name] to the the [src.name]"))
			user.drop_item()
			W.set_loc(src)
			src.holding = W
			UpdateIcon()
			tgui_process.update_uis(src) //update UI immediately

	else if (iswrenchingtool(W))
		if ((istype(src, /obj/machinery/portable_atmospherics/canister))) //No messing with anchored canbombs. -ZeWaka
			var/obj/machinery/portable_atmospherics/canister/C = src
			if (!isnull(C.det))
				boutput(user, SPAN_ALERT("The detonating mechanism blocks you from modifying the anchors on the [src.name] with a wrench."))
				return
		if(connected_port)
			actions.start(new /datum/action/bar/icon/canister_tool_use(user, src, W, CANISTER_DISCONNECT), user)
			return
		else
			actions.start(new /datum/action/bar/icon/canister_tool_use(user, src, W, CANISTER_CONNECT), user)
			return
	else if (isweldingtool(W))
		if (src.destroyed)
			actions.start(new /datum/action/bar/icon/canister_tool_use(user, src, W, CANISTER_DISASSEMBLE, 2 SECONDS), user)
	return

/obj/machinery/portable_atmospherics/return_air(direct = FALSE)
	return air_contents

/datum/action/bar/icon/canister_tool_use
	duration = 1 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/tools/weldingtool.dmi'
	icon_state = "weldingtool-on"
	var/obj/machinery/portable_atmospherics/canister/C
	var/mob/ownerMob
	var/obj/item/tool
	var/obj/machinery/atmospherics/unary/portables_connector/possible_port
	var/interaction = CANISTER_DISASSEMBLE

	New(The_Owner, The_Can, var/obj/item/The_Tool, The_Interaction, The_Duration, The_Port)
		..()
		if (The_Can)
			C = The_Can
		if (The_Owner)
			owner = The_Owner
			ownerMob = The_Owner
		if (The_Tool)
			tool = The_Tool
			icon = The_Tool.icon
			icon_state = The_Tool.icon_state
		if (The_Duration)
			duration = The_Duration
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)
		if (The_Interaction)
			interaction = The_Interaction
		if (iswrenchingtool(tool))
			possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector) in C.loc

	onUpdate()
		..()
		if (tool == null || C == null || owner == null || BOUNDS_DIST(owner, C) > 0 || (interaction == CANISTER_CONNECT && !possible_port))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (BOUNDS_DIST(ownerMob, C) > 0 || C == null || ownerMob == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!tool)
			interrupt(INTERRUPT_ALWAYS)
			logTheThing(LOG_DEBUG, src, "tried to interact with [C] at [log_loc(C)] using a null tool... somehow.")
			return
		switch (interaction)
			if (CANISTER_DISASSEMBLE)
				if (isweldingtool(tool) && tool:welding)
					playsound(C, 'sound/items/Welder.ogg', 50, TRUE)
					ownerMob.visible_message(SPAN_NOTICE("[owner] begins to disassemble \the [C]."))
				else
					ownerMob.show_message(SPAN_ALERT("You have to turn the welding tool on."))
					interrupt(INTERRUPT_ALWAYS)
					return
			if (CANISTER_CONNECT)
				if(C.can_connect(possible_port))
					playsound(C, 'sound/items/Ratchet.ogg', 50, TRUE)
					ownerMob.visible_message(SPAN_NOTICE("[owner] begins connecting \the [C] to the port."))
				else
					ownerMob.visible_message(SPAN_ALERT("[owner] failed to connect to the port."))
					interrupt(INTERRUPT_ALWAYS)
					return
			if (CANISTER_DISCONNECT)
				playsound(C, 'sound/items/Ratchet.ogg', 50, TRUE)
				ownerMob.visible_message(SPAN_NOTICE("[owner] begins disconnecting \the [C] from the port."))

	onEnd()
		..()
		switch (interaction)
			if (CANISTER_DISASSEMBLE)
				ownerMob.visible_message(SPAN_NOTICE("[owner] disassembles \the [C]."))
				logTheThing(LOG_STATION, ownerMob, "disassembles \the [C] at [log_loc(C)].")
				var/obj/item/I = new /obj/item/sheet(get_turf(C))
				if (C.material)
					I.setMaterial(C.material)
				else
					var/datum/material/M = getMaterial("steel")
					I.setMaterial(M)
				qdel(C)
			if (CANISTER_CONNECT)
				ownerMob.visible_message(SPAN_NOTICE("[owner] connects \the [C] to the port."))
				C.connect(possible_port)
				playsound(C, 'sound/items/Deconstruct.ogg', 50, TRUE)
				tgui_process.update_uis(C)
				logTheThing(LOG_STATION, owner, "has connected \the [C] [log_atmos(C)] to the port at [log_loc(C)].")
			if (CANISTER_DISCONNECT)
				ownerMob.visible_message(SPAN_NOTICE("[owner] disconnects \the [C] from the port."))
				C.disconnect()
				playsound(C, 'sound/items/Deconstruct.ogg', 50, TRUE)
				logTheThing(LOG_STATION, owner, "has disconnected \the [C] [log_atmos(C)] from the port at [log_loc(C)].")
				tgui_process.update_uis(C)
