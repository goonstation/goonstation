/datum/mechanicsMessage
	var/signal = "1"
	var/list/nodes = list()
	var/datum/computer/file/data_file

/datum/mechanicsMessage/proc/addNode(/obj/O)
	nodes.Add(O)

/datum/mechanicsMessage/proc/hasNode(/obj/O)
	return nodes.Find(O)

/datum/mechanicsMessage/proc/isTrue() //Thanks for not having bools , byond.
	if(istext(signal))
		if(lowertext(signal) == "true" || lowertext(signal) == "1" || lowertext(signal) == "one") return 1
	else if (isnum(signal))
		if(signal == 1) return 1
	return 0

/datum/component/mechanics_holder
	var/list/connected_outgoing = list()
	var/list/connected_incoming = list()
	var/list/inputs = list()

	var/outputSignal = "1" //MarkNstein needs attention: candidate for removal? check how deafult singals are set
	var/triggerSignal = "1"

	var/filtered = 0
	var/list/outgoing_filters = list()
	var/exact_match = 0
	
	var/list/configs = list()

/datum/component/mechanics_holder/Initialize(can_manualy_set_signal = 0)
	configs.Add(list("Disconnect All"))
	if(can_manualy_set_signal)
		configs.Add(list("Set Send-Signal"))
	..()    //MarkNstein needs attention: make use of this for non-MechComp things. Like settings configs? Inputs?

/datum/component/mechanics_holder/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_MECHCOMP_ADD_INPUT), .proc/addInput)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RECEIVE_MSG), .proc/fireInput)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_TRANSMIT_MSG), .proc/fireOutgoing)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RM_INCOMING), .proc/removeIncoming)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RM_OUTGOING), .proc/removeOutgoing)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RM_ALL_CONNECTIONS), .proc/WipeConnections)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_SET_FILTER_TRUE), .proc/setFilterTrue)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_SET_FILTERS), .proc/set_filters)    //MarkNstein needs attention
	RegisterSignal(parent, list(COMSIG_MECHCOMP_GET_OUTGOING), .proc/getOutgoing)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_LINK), .proc/link)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_ADD_CONFIG), .proc/addConfig)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL), .proc/allow_manual_singal_setting)
	RegisterSignal(parent, list(COMSIG_ATTACKBY), .proc/attackby)    //MarkNstein needs attention
	return  //No need to ..()

/datum/component/mechanics_holder/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MECHCOMP_ADD_INPUT)
	UnregisterSignal(parent, COMSIG_MECHCOMP_RECEIVE_MSG)
	UnregisterSignal(parent, COMSIG_MECHCOMP_TRANSMIT_MSG)
	UnregisterSignal(parent, COMSIG_MECHCOMP_RM_INCOMING)
	UnregisterSignal(parent, COMSIG_MECHCOMP_RM_OUTGOING)
	UnregisterSignal(parent, COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
	UnregisterSignal(parent, COMSIG_MECHCOMP_SET_FILTER_TRUE)
	UnregisterSignal(parent, COMSIG_MECHCOMP_SET_FILTERS)
	UnregisterSignal(parent, COMSIG_MECHCOMP_GET_OUTGOING)
	UnregisterSignal(parent, COMSIG_MECHCOMP_LINK)
	UnregisterSignal(parent, COMSIG_MECHCOMP_ADD_CONFIG)
	UnregisterSignal(parent, COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
	UnregisterSignal(parent, COMSIG_ATTACKBY)    
	WipeConnections()
	configs.Cut()
	inputs.Cut()
	return  //No need to ..()

//Delete all connections. (Often caused by "Disconnect All" user command, and unwrenching MechComp devices.)
/datum/component/mechanics_holder/proc/WipeConnections()
	for(var/obj/O in connected_incoming)
		SEND_SIGNAL(O, COMSIG_MECHCOMP_RM_OUTGOING, parent)
	for(var/obj/O in connected_outgoing)
		SEND_SIGNAL(O, COMSIG_MECHCOMP_RM_INCOMING, parent)
	connected_incoming.Cut()
	connected_outgoing.Cut()
	outgoing_filters.Cut()
	return

//Remove a device from our list of transitting devices.
/datum/component/mechanics_holder/proc/removeIncoming(var/obj/O)
	connected_incoming.Remove(O)
	return

//Remove a device from our list of receiving devices.
/datum/component/mechanics_holder/proc/removeOutgoing(var/obj/O)
	connected_outgoing.Remove(O)
	outgoing_filters.Remove(O)
	return

//Give the caller a copied list of our outgoing connections.
/datum/component/mechanics_holder/proc/getOutgoing(var/list/outout)
	outout = connected_outgoing.Copy()
	return

//Well well well, look at you; you can filter your outputs — how special.
/datum/component/mechanics_holder/proc/setFilterTrue()
	filtered = 1
	return

//Adds an input "slot" to the holder w/ a proc mapping.
/datum/component/mechanics_holder/proc/addInput(var/name, var/toCall)
	if(name in inputs) inputs.Remove(name)
	inputs.Add(name)
	inputs[name] = toCall
	return

//Fire given input by names with the message as argument.
/datum/component/mechanics_holder/proc/fireInput(var/name, var/datum/mechanicsMessage/msg)
	if(!(name in inputs)) return
	var/path = inputs[name]
	SPAWN_DBG(1 DECI SECOND) call(parent, path)(msg)
	return

//Fire an outgoing connection with given value. Try to re-use incoming messages for outgoing signals whenever possible!
//This reduces load AND preserves the node list which prevents infinite loops.
/datum/component/mechanics_holder/proc/fireOutgoing(var/datum/mechanicsMessage/msg)
	//If we're already in the node list we will not send the signal on.
	if(!msg.hasNode(parent)) //MarkNstein Needs attentin: src
		msg.addNode(parent)
	else
		return 0

	var/fired = 0
	for(var/obj/O in connected_outgoing)
		if (filtered && outgoing_filters[O] && !allowFiltered(msg.signal, outgoing_filters[O]))
			continue  //MarkNstein Needs attentin: this just seems wrong???
		SEND_SIGNAL(O, COMSIG_MECHCOMP_RECEIVE_MSG, cloneMessage(msg))
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

//Called when a component is dragged onto another one.
/datum/component/mechanics_holder/proc/dropConnect(obj/O, mob/user)//MarkNstein needs attention
	if(!O || O == parent || !O.mechanics) return //ZeWaka: Fix for null.mechanics //MarkNstein needs attention

	var/typesel = input(user, "Use [parent] as:", "Connection Type") in list("Trigger", "Receiver", "*CANCEL*")
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
/datum/component/mechanics_holder/proc/link(obj/trigger, mob/user)
	var/obj/receiver = parent
	if(trigger in connected_outgoing)
		boutput(user, "<span class='alert'>Can not create a direct loop between 2 components.</span>")
		return
	if(!inputs.len)
		boutput(user, "<span class='alert'>[receiver.name] has no input slots. Can not connect [trigger.name] as Trigger.</span>")
		return
	
	var/list/trg_outgoing
	SEND_SIGNAL(trigger, COMSIG_MECHCOMP_GET_OUTGOING, trg_outgoing) //MarkNstein needs attention
	var/selected_input = input(user, "Select \"[receiver.name]\" Input", "Input Selection") in inputs + "*CANCEL*"
	if(selected_input == "*CANCEL*") return

	trg_outgoing.Add(receiver)
	trg_outgoing[receiver] = selected_input
	connected_incoming.Add(trigger)
	boutput(user, "<span class='success'>You connect the [trigger.name] to the [receiver.name].</span>")
	logTheThing("station", user, null, "connects a <b>[trigger.name]</b> to a <b>[receiver.name]</b>.")
	SEND_SIGNAL(trigger, COMSIG_MECHCOMP_SET_FILTERS, receiver, user) //MarkNstein needs attention
	return

//We are in the scope of the trigger-component
/datum/component/mechanics_holder/proc/set_filters(obj/receiver, mob/user)
	if (filtered)
		var/filter = input(user, "Add filters for this connection? (Comma-delimited list. Leave blank to pass all messages.)", "Intput Filters") as text
		if (length(filter))
			if (!outgoing_filters[receiver]) outgoing_filters[receiver] = list()
			outgoing_filters.Add(receiver)
			outgoing_filters[receiver] = splittext(filter, ",")
			boutput(user, "<span class='success'>Only passing messages that [exact_match ? "match" : "contain"] [filter] to the [receiver.name]</span>")
		else
			boutput(user, "<span class='success'>Passing all messages to the [receiver.name]</span>")
	return

//Adds a config to the holder w/ a proc mapping.
/datum/component/mechanics_holder/proc/addConfig(var/name, var/toCall)
	if(name in configs) configs.Remove(name)
	configs.Add(name)
	configs[name] = toCall
	return

/datum/component/mechanics_holder/proc/allow_manual_singal_setting() 
	if(!(list("Set Send-Signal") in configs))
		configs.Add(list("Set Send-Signal"))
	return
	
//If it's a multi-tool, let the user configure the device.
/datum/component/mechanics_holder/proc/attackby(obj/item/W as obj, mob/user)
	if(!ispulsingtool(W) || !isliving(user) || user.stat)
		return 0
	if(configs.len)
		var/selected_config = input("Select a config to modify!", "Config", null) as null|anything in configs
		if(selected_config && (user in range(1,parent)))
			switch(selected_config)
				if("Set Send-Signal")
					var/inp = input(user,"Please enter Signal:","Signal setting","1") as text
					inp = trim(adminscrub(inp), 1)
					if(length(inp))
						outputSignal = inp
						boutput(user, "Signal set to [inp]")
						if(istype(parent,/obj/item))
							var/obj/item/I = parent
							I.tooltip_rebuild = 1
					return COMSIG_ATTACKBY_COMPLETE
				if("Disconnect All")
					WipeConnections()
					boutput(user, "<span class='notice'>You disconnect [src].</span>")
					return COMSIG_ATTACKBY_COMPLETE
				if("Toggle Exact Match")
					exact_match = !exact_match
					boutput(user, "Exact match mode now [exact_match ? "on" : "off"]")
					if(istype(parent,/obj/item))
						var/obj/item/I = parent
						I.tooltip_rebuild = 1
					return COMSIG_ATTACKBY_COMPLETE
			//must be a custom config specific to the device
			var/path = configs[selected_config]
			SPAWN_DBG(1 DECI SECOND) call(parent, path)()
	return 0



