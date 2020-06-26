/datum/mechanicsMessage
	var/signal = "1"
	var/list/nodes = list()
	var/datum/computer/file/data_file

	proc/addNode(/datum/component/mechanics_holder/H)
		nodes.Add(H)

	proc/removeNode(/datum/component/mechanics_holder/H)
		nodes.Remove(H)

	proc/hasNode(/datum/component/mechanics_holder/H)
		return nodes.Find(H)

	proc/isTrue() //Thanks for not having bools , byond.
		if(istext(signal))
			if(lowertext(signal) == "true" || lowertext(signal) == "1" || lowertext(signal) == "one") return 1
		else if (isnum(signal))
			if(signal == 1) return 1
		return 0

/datum/component/mechanics_holder
	var/atom/master = null
	var/list/connected_outgoing = list()
	var/list/connected_incoming = list()
	var/list/inputs = list()

	var/outputSignal = "1"
	var/triggerSignal = "1"

	var/filtered = 0
	var/list/outgoing_filters = list()
	var/exact_match = 0

/datum/component/mechanics_holder/Initialize(var/master, var/filtered = 0)
	src.master = master
	src.filtered = filtered
	RegisterSignal(parent, list(COMSIG_MECHCOMP_ADD_INPUT), .proc/addInput)    //MarkNstein needs attention
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RECEIVE_MSG), .proc/fireInput)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_TRANSMIT_MSG), .proc/fireOutgoing)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RM_INCOMING), .proc/removeIncoming)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RM_OUTGOING), .proc/removeOutgoing)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RM_ALL_CONNECTIONS), .proc/WipeConnections)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_CONNECT), .proc/dropConnect)    //MarkNstein needs attention

/datum/component/mechanics_holder/disposing()
	wipeIncoming()
	wipeOutgoing()
	master = null
	..()

//Delete all connections. (Often caused by "Disconnect All" user command.)
/datum/component/mechanics_holder/proc/WipeConnections()
	wipeIncoming()
	wipeOutgoing()
	return

//Adds an input "slot" to the holder /w a proc mapping.
/datum/component/mechanics_holder/proc/addInput(var/name, var/toCall)
	if(name in inputs) inputs.Remove(name)
	inputs.Add(name)
	inputs[name] = toCall
	return

//Fire given input by names with the message as argument.
/datum/component/mechanics_holder/proc/fireInput(var/name, var/datum/mechanicsMessage/msg)
	if(!(name in inputs)) return
	var/path = inputs[name]
	SPAWN_DBG(1 DECI SECOND) call(master, path)(msg)
	return

//Fire an outgoing connection with given value. Try to re-use incoming messages for outgoing signals whenever possible!
//This reduces load AND preserves the node list which prevents infinite loops.
/datum/component/mechanics_holder/proc/fireOutgoing(var/datum/mechanicsMessage/msg)
	//If we're already in the node list we will not send the signal on.
	if(!msg.hasNode(src))
		msg.addNode(src)
	else
		return 0

	var/fired = 0
	for(var/atom/M in connected_outgoing)
		//	if(M.mechanics)
		//		if (filtered && outgoing_filters[M] && !allowFiltered(msg.signal, outgoing_filters[M]))
		//			continue
		//		M.mechanics.fireInput(connected_outgoing[M], cloneMessage(msg))
		//		fired = 1
		if (filtered && outgoing_filters[M] && !allowFiltered(msg.signal, outgoing_filters[M]))
			continue
		SEND_SIGNAL(M, COMSIG_MECHCOMP_RECEIVE_MSG, cloneMessage(msg))
		fired = 1
	return fired

/datum/component/mechanics_holder/proc/allowFiltered(var/signal, var/list/filters)
	for (var/filter in filters)
		var/text_found = findtext(signal, filter)
		if (exact_match)
			text_found = text_found && (length(signal) == length(filter))
		if (text_found)
			return 1
	return 0

//Used to copy a message because we don't want to pass a single message to multiple components which might end up modifying it both at the same time.
/datum/component/mechanics_holder/proc/cloneMessage(var/datum/mechanicsMessage/msg)
	var/datum/mechanicsMessage/msg2 = newSignal(msg.signal, msg.data_file?.copy_file())
	msg2.nodes = msg.nodes.Copy()
	return msg2

//ALWAYS use this to create new messages!!!
/datum/component/mechanics_holder/proc/newSignal(var/sig, var/datum/computer/file/data_file=null)
	var/datum/mechanicsMessage/ret = new/datum/mechanicsMessage
	ret.signal = sig
	ret.data_file = data_file
	return ret

//Delete all incoming connections
/datum/component/mechanics_holder/proc/wipeIncoming()
	for(var/atom/M in connected_incoming)
		// if(M.mechanics)
		//     M.mechanics.connected_outgoing.Remove(master)
		//     if (M.mechanics.outgoing_filters.Find(master)) M.mechanics.outgoing_filters.Remove(master)
		SEND_SIGNAL(M, COMSIG_MECHCOMP_RM_OUTGOING, master)
		connected_incoming.Remove(M)
	return

//Delete all outgoing connections.
/datum/component/mechanics_holder/proc/wipeOutgoing()
	for(var/atom/M in connected_outgoing)
		// if(M.mechanics) M.mechanics.connected_incoming.Remove(master)
		SEND_SIGNAL(M, COMSIG_MECHCOMP_RM_INCOMING, master)
		connected_outgoing.Remove(M)
	outgoing_filters.Cut()
	return

//Remove a device from our list of transitting devices.
/datum/component/mechanics_holder/proc/removeIncoming(var/atom/M)
	connected_incoming.Remove(M)
	return

//Remove a device from our list of receiving devices.
/datum/component/mechanics_holder/proc/removeOutgoing(var/atom/M)
	connected_outgoing.Remove(M)
	outgoing_filters.Remove(M)
	return

//Called when a component is dragged onto another one.
/datum/component/mechanics_holder/proc/dropConnect(obj/O, null, var/src_location, var/control_orig, var/control_new, var/params)//MarkNstein needs attention
	if(!O || O == master || !O.mechanics) return //ZeWaka: Fix for null.mechanics //MarkNstein needs attention

	var/typesel = input(usr, "Use [master] as:", "Connection Type") in list("Trigger", "Receiver", "*CANCEL*")
	switch(typesel)
		if("Trigger")
			SEND_SIGNAL(O, COMSIG_MECHCOMP_LINK, parent) //MarkNstein needs attention
		if("Receiver")
			link(O) //What do you want, an invitation? No signal needed!
		if("*CANCEL*")
			return
	return

//We are in the scope of the receiver-component, our argument is the trigger
//This feels weird/backwards, but it results in fewer SEND_SIGNALS & var/lists
/datum/component/mechanics_holder/proc/link(obj/trigger)
	var/obj/receiver = parent
	if(trigger in connected_outgoing)
		boutput(usr, "<span class='alert'>Can not create a direct loop between 2 components.</span>")
		return
	if(!inputs.len)
		boutput(usr, "<span class='alert'>[receiver.name] has no input slots. Can not connect [trigger.name] as Trigger.</span>")
		return
	
	var/list/trg_outgoing
	SEND_SIGNAL(trigger, COMSIG_MECHCOMP_GET_OUTGOING, trg_outgoing) //MarkNstein needs attention
	var/selected_input = input(usr, "Select \"[receiver.name]\" Input", "Input Selection") in inputs + "*CANCEL*"
	if(selected_input == "*CANCEL*") return

	trg_outgoing.Add(receiver)
	trg_outgoing[receiver] = selected_input
	connected_incoming.Add(trigger)
	boutput(usr, "<span class='success'>You connect the [trigger.name] to the [receiver.name].</span>")
	logTheThing("station", usr, null, "connects a <b>[trigger.name]</b> to a <b>[receiver.name]</b>.")
	SEND_SIGNAL(trigger, COMSIG_MECHCOMP_SET_FILTERS, receiver) //MarkNstein needs attention
	return

//We are in the scope of the trigger-component
/datum/component/mechanics_holder/proc/set_filters(obj/receiver)
	if (filtered)
		var/filter = input(usr, "Add filters for this connection? (Comma-delimited list. Leave blank to pass all messages.)", "Intput Filters") as text
		if (length(filter))
			if (!outgoing_filters[receiver]) outgoing_filters[receiver] = list()
			outgoing_filters.Add(receiver)
			outgoing_filters[receiver] = splittext(filter, ",")
			boutput(usr, "<span class='success'>Only passing messages that [exact_match ? "match" : "contain"] [filter] to the [receiver.name]</span>")
		else
			boutput(usr, "<span class='success'>Passing all messages to the [receiver.name]</span>")
	return

