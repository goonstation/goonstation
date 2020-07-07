#define DC_ALL "Disconnect All"
#define SET_SEND "Set Send-Signal"
#define TOGGLE_MATCH "Toggle Exact Match"
#define MECHFAILSTRING "You must be holding a Multitool to change Connections or Options."

//Closest thing I can think of that emulates an "interface"
//COMSIG_MECHCOMP_ENABLE_SPECIAL_FILTERING relies on the parent implementing these functions
//See  /obj/item/mechanics/dispatchcomp  for an example
#define MECHCOMP_SET_FILTER_FUNC mechComp_set_filter
#define MECHCOMP_RM_FILTER_FUNC mechComp_rm_filter
#define MECHCOMP_RUN_FILTER_FUNC mechComp_run_filter

/datum/mechanicsMessage
	var/signal = "1"
	var/list/nodes = list()
	var/datum/computer/file/data_file

/datum/mechanicsMessage/proc/addNode(var/obj/O)
	nodes.Add(O)

/datum/mechanicsMessage/proc/hasNode(var/obj/O)
	return nodes.Find(O)

/datum/mechanicsMessage/proc/isTrue() //Thanks for not having bools , byond.
	if(istext(signal))
		if(lowertext(signal) == "true" || lowertext(signal) == "1" || lowertext(signal) == "one") return 1
	else if (isnum(signal))
		if(signal == 1) return 1
	return 0

/datum/component/mechanics_holder
	var/list/connected_outgoing
	var/list/connected_incoming
	var/list/inputs
	var/list/configs

	var/defaultSignal = "1"
	
	var/specialFiltering = 0

/datum/component/mechanics_holder/Initialize(can_manualy_set_signal = 0, specially_filters_outputs = 0)
	src.connected_outgoing = list()
	src.connected_incoming = list()
	src.inputs = list()
	src.configs = list()

	src.configs.Add(list(DC_ALL))
	if(can_manualy_set_signal)
		allowManualSingalSetting()
	if(specially_filters_outputs)
		enableSpecialFiltering()
	..()    //MarkNstein needs attention: make use of this for non-MechComp things. Like settings configs? Inputs?

/datum/component/mechanics_holder/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_MECHCOMP_ADD_INPUT), .proc/addInput)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RECEIVE_MSG), .proc/fireInput)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_TRANSMIT_SIGNAL), .proc/fireOutSignal)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_TRANSMIT_MSG), .proc/fireOutgoing)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG), .proc/fireDefault) //Only use this when also using COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RM_INCOMING), .proc/removeIncoming)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RM_OUTGOING), .proc/removeOutgoing)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_RM_ALL_CONNECTIONS), .proc/WipeConnections)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_GET_OUTGOING), .proc/getOutgoing)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_DROPCONNECT), .proc/dropConnect)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_LINK), .proc/link_devices)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_ENABLE_SPECIAL_FILTERING), .proc/enableSpecialFiltering) //See defines at the top of the document
	RegisterSignal(parent, list(COMSIG_MECHCOMP_ADD_CONFIG), .proc/addConfig)
	RegisterSignal(parent, list(COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL), .proc/allowManualSingalSetting) //Only use this when also using COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG
	RegisterSignal(parent, list(COMSIG_ATTACKBY), .proc/attackby)    //MarkNstein needs attention
	RegisterSignal(parent, list(COMSIG_MECHCOMP_COMPATIBLE), .proc/compatible)//Better that checking GetComponent()?
	return  //No need to ..()

/datum/component/mechanics_holder/UnregisterFromParent()
	var/list/signals = list(\
	COMSIG_MECHCOMP_ADD_INPUT,\
	COMSIG_MECHCOMP_RECEIVE_MSG,\
	COMSIG_MECHCOMP_TRANSMIT_SIGNAL,\
	COMSIG_MECHCOMP_TRANSMIT_MSG,\
	COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,\
	COMSIG_MECHCOMP_RM_INCOMING,\
	COMSIG_MECHCOMP_RM_OUTGOING,\
	COMSIG_MECHCOMP_RM_ALL_CONNECTIONS,\
	COMSIG_MECHCOMP_GET_OUTGOING,\
	COMSIG_MECHCOMP_DROPCONNECT,\
	COMSIG_MECHCOMP_LINK,\
	COMSIG_MECHCOMP_ENABLE_SPECIAL_FILTERING,\
	COMSIG_MECHCOMP_ADD_CONFIG,\
	COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL,\
	COMSIG_ATTACKBY)
	UnregisterSignal(parent, signals)
	WipeConnections()
	src.configs.Cut()
	src.inputs.Cut()
	return  //No need to ..()

//Delete all connections. (Often caused by DC_ALL user command, and unwrenching MechComp devices.)
/datum/component/mechanics_holder/proc/WipeConnections()
	for(var/obj/O in src.connected_incoming)
		SEND_SIGNAL(O, COMSIG_MECHCOMP_RM_OUTGOING, parent)
	for(var/obj/O in src.connected_outgoing)
		SEND_SIGNAL(O, COMSIG_MECHCOMP_RM_INCOMING, parent)
	src.connected_incoming.Cut()
	src.connected_outgoing.Cut()
	return

//Remove a device from our list of transitting devices.
/datum/component/mechanics_holder/proc/removeIncoming(var/comsig_target, var/obj/O)
	src.connected_incoming.Remove(O)
	return

//Remove a device from our list of receiving devices.
/datum/component/mechanics_holder/proc/removeOutgoing(var/comsig_target, var/obj/O)
	src.connected_outgoing.Remove(O)
	if(specialFiltering)
		parent:MECHCOMP_RM_FILTER_FUNC(O)
	return

//Give the caller a copied list of our outgoing connections.
/datum/component/mechanics_holder/proc/getOutgoing(var/comsig_target, var/list/outout)
	outout[1] = src.connected_outgoing
	return

//Allow special filtering to happen on ourgoing transmissions - potentially setup with each new link_devicesage.
/datum/component/mechanics_holder/proc/enableSpecialFiltering()
	//Well well well, look at you; you can filter your outputs — how special.
	specialFiltering = 1
	return

//Fire the stored default signal.
/datum/component/mechanics_holder/proc/fireDefault(var/comsig_target, var/datum/mechanicsMessage/msg = null)
	if(isnull(msg))
		msg = newSignal(defaultSignal, null)
	else
		msg.signal = defaultSignal
	fireOutgoing(null, msg)
	return

//Fire a message with a simple signal (no file). Expected to be called from signal "sources" (first nodes)
/datum/component/mechanics_holder/proc/fireOutSignal(var/comsig_target, var/signal, var/datum/computer/file/data_file=null)
	fireOutgoing(null, newSignal(signal, data_file))
	return

//Adds an input "slot" to the holder w/ a proc mapping.
/datum/component/mechanics_holder/proc/addInput(var/comsig_target, var/name, var/toCall)
	if(name in src.inputs) src.inputs.Remove(name)
	src.inputs.Add(name)
	src.inputs[name] = toCall
	return

//Fire given input by names with the message as argument.
/datum/component/mechanics_holder/proc/fireInput(var/comsig_target, var/name, var/datum/mechanicsMessage/msg)
	if(!(name in src.inputs)) return
	var/path = src.inputs[name]
	SPAWN_DBG(1 DECI SECOND) call(parent, path)(msg)
	return

//Fire an outgoing connection with given value. Try to re-use incoming messages for outgoing signals whenever possible!
//This reduces load AND preserves the node list which prevents infinite loops.
/datum/component/mechanics_holder/proc/fireOutgoing(var/comsig_target, var/datum/mechanicsMessage/msg)
	//If we're already in the node list we will not send the signal on.
	if(msg.hasNode(parent))
		return 0
	msg.addNode(parent)

	var/fired = 0
	for(var/obj/O in src.connected_outgoing)
		if(specialFiltering)
			if(!parent:MECHCOMP_RUN_FILTER_FUNC(msg.signal))
				continue 
		SEND_SIGNAL(O, COMSIG_MECHCOMP_RECEIVE_MSG, src.connected_outgoing[O], cloneMessage(msg))
		fired = 1
	return fired

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
/datum/component/mechanics_holder/proc/dropConnect(var/comsig_target, obj/O, mob/user)//MarkNstein needs attention
	if(!O || O == parent || user.stat || !isliving(user) || (SEND_SIGNAL(O,COMSIG_MECHCOMP_COMPATIBLE) != 1))  //ZeWaka: Fix for null.mechanics //MarkNstein needs attention
		return

	if (!user.find_tool_in_hand(TOOL_PULSING))
		boutput(user, "<span class='alert'>[MECHFAILSTRING]</span>")
		return

	var/typesel = input(user, "Use [parent] as:", "Connection Type") in list("Trigger", "Receiver", "*CANCEL*")
	switch(typesel)
		if("Trigger")
			SEND_SIGNAL(O, COMSIG_MECHCOMP_LINK, parent, user) //MarkNstein needs attention
		if("Receiver")
			link_devices(null, O, user) //What do you want, an invitation? No signal needed!
		if("*CANCEL*")
			return
	return

//We are in the scope of the receiver-component, our argument is the trigger
//This feels weird/backwards, but it results in fewer SEND_SIGNALS & var/lists
/datum/component/mechanics_holder/proc/link_devices(var/comsig_target, obj/trigger, mob/user)
	var/obj/receiver = parent
	if(trigger in src.connected_outgoing)
		boutput(user, "<span class='alert'>Can not create a direct loop between 2 components.</span>")
		return
	if(!src.inputs.len)
		boutput(user, "<span class='alert'>[receiver.name] has no input slots. Can not connect [trigger.name] as Trigger.</span>")
		return
	
	var/outgoing_wrapper[1] //A list of size 1, to store the address of the list we want
	SEND_SIGNAL(trigger, COMSIG_MECHCOMP_GET_OUTGOING, outgoing_wrapper) //MarkNstein needs attention
	var/list/trg_outgoing = outgoing_wrapper[1]
	var/selected_input = input(user, "Select \"[receiver.name]\" Input", "Input Selection") in inputs + "*CANCEL*"
	if(selected_input == "*CANCEL*") return

	trg_outgoing.Add(receiver)
	trg_outgoing[receiver] = selected_input
	src.connected_incoming.Add(trigger)
	boutput(user, "<span class='success'>You connect the [trigger.name] to the [receiver.name].</span>")
	logTheThing("station", user, null, "connects a <b>[trigger.name]</b> to a <b>[receiver.name]</b>.")
	if(specialFiltering)
		parent:MECHCOMP_SET_FILTER_FUNC(receiver, user)
	return

//Adds a config to the holder w/ a proc mapping.
/datum/component/mechanics_holder/proc/addConfig(var/comsig_target, var/name, var/toCall)
	if(name in src.configs) src.configs.Remove(name)
	src.configs.Add(name)
	src.configs[name] = toCall
	return

/datum/component/mechanics_holder/proc/allowManualSingalSetting() 
	if(!(list(SET_SEND) in src.configs))
		src.configs.Add(list(SET_SEND))
	return
	
//If it's a multi-tool, let the user configure the device.
/datum/component/mechanics_holder/proc/attackby(var/comsig_target, obj/item/W as obj, mob/user)
	if(!ispulsingtool(W) || !isliving(user) || user.stat)
		return 0
	if(length(src.configs))	
		var/selected_config = input("Select a config to modify!", "Config", null) as null|anything in src.configs
		if(selected_config && in_range(parent, user))
			switch(selected_config)
				if(SET_SEND)
					var/inp = input(user,"Please enter Signal:","Signal setting","1") as text
					if(!in_range(parent, user) || user.stat)
						return 0
					inp = trim(adminscrub(inp), 1)
					if(length(inp))
						defaultSignal = inp
						boutput(user, "Signal set to [inp]")
					return COMSIGBIT_ATTACKBY_COMPLETE
				if(DC_ALL)
					WipeConnections()
					boutput(user, "<span class='notice'>You disconnect [src].</span>")
					return COMSIGBIT_ATTACKBY_COMPLETE
				else
					//must be a custom config specific to the device, so let the device handle it
					var/path = src.configs[selected_config]
					return call(parent, path)(W, user)
	return 0

//If it's a multi-tool, let the user configure the device.
/datum/component/mechanics_holder/proc/compatible()
	return 1


#undef DC_ALL
#undef SET_SEND
#undef TOGGLE_MATCH