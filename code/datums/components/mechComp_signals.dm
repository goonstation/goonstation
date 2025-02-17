#define DC_ALL "Disconnect All"
#define LIST_CONNECTIONS "List Connections"
#define CONNECT_COMP "Connect Component"
#define SET_SEND "Set Send-Signal"
#define TOGGLE_MATCH "Toggle Exact Match"
#define MECHFAILSTRING "You must be holding a Multitool to change Connections or Options."

#define _MECHCOMP_VALIDATE_RESPONSE_GOOD 0
#define _MECHCOMP_VALIDATE_RESPONSE_BAD 1
#define _MECHCOMP_VALIDATE_RESPONSE_HALT 2
#define _MECHCOMP_VALIDATE_RESPONSE_HALT_AFTER 3

#define MAX_OUTGOING_PER_TICK 25

/datum/mechanicsMessage
	var/signal = "1"
	var/list/nodes = list()
	var/datum/computer/file/data_file

/datum/mechanicsMessage/proc/addNode(var/atom/A)
	nodes.Add(A)

/datum/mechanicsMessage/proc/hasNode(var/atom/A)
	return (A in nodes)

/datum/mechanicsMessage/proc/isTrue() //Thanks for not having bools , byond.
	if(istext(signal))
		if(lowertext(signal) == "true" || lowertext(signal) == "1" || lowertext(signal) == "one") return 1
	else if (isnum(signal))
		if(signal == 1) return 1
	return 0
/*
* Component for handling MechComp-signals
* Add this component to any object if you'd like it to send and or receive MechComp-messages (often called signals)
* There are are three "setup" COMSIGs you may want, and a few transmission COMSIGs.
*
*      ------  SETUP COMSIGS  ------
* COMSIG_MECHCOMP_ADD_INPUT, display_name, proc_name
*    Registers a custom input for your device. When connecting devices, the user can select "display_name" as an input.
*    Your device will need an associated proc/proc_name that handles receiving messages.
*    If your device is purely a sensor, it does not need any inputs.
*
* COMSIG_MECHCOMP_ADD_CONFIG, display_name, proc_name
*    Registers a custom configuration for your device. It is similar to  COMSIG_MECHCOMP_ADD_INPUT.
*
* COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL
*    Adds the "Set Send-Signal" config-option to your device.
*    Use this with COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG detailed below
*
* COMSIG_MECHCOMP_RM_ALL_CONNECTIONS
*    Removes all MechComp connections to and from the device.
*    This is the "Disconnect All" config-option, but you may want to call it after certain events,
*    such as unwelding a sensor-pipe in a loafer, or deconstructing a vending machine.
*    As a game-balance rule: devices should break connections when they move / are picked up.
*
*
*      ------  TRANSMISSION COMSIGS  ------
* A note on MechComp messages:
//Please try to always re-use incoming signals for your outgoing signals.
//Just modify the message of the incoming signal and send it along.
//This is important because each message keeps track of which nodes it traveled trough.
//It's through that list that we can prevent infinite loops. Or at least try to.
//(People can probably still create infinite loops somehow. They always manage)
*
* COMSIG_MECHCOMP_TRANSMIT_SIGNAL, signal_data, file
*    Creates a new message containing the signal_data and optional file. Fires this message to all connected outputs.
*    Use this for sensors and other devices that can create messages without having received one.
*
* COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, reusable_msg
*    Transmits the stored signal from COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL.
*    If a reusable_msg is passed in, it will be reused, otherwise a fresh message will be created.
*
* COMSIG_MECHCOMP_TRANSMIT_MSG, msg
*    Transmits the msg to all connected outputs. Does not modify the signal of msg.
*/

/datum/component/mechanics_holder
	/// associative list of atoms to the input they're registered to
	/// list[atom] = "name of input"
	var/list/connected_outgoing
	/// simple list of atoms that are connected (no inputs)
	/// list[] = [atom, atom, ...]
	var/list/connected_incoming
	var/list/inputs
	var/list/configs
	///Associative list of atoms to the pair of line images drawn from us to them (there are two so it renders when either end is rendered)
	var/list/lines

	var/defaultSignal = "1"

	var/activation_count = 0
	var/current_tick = 0

TYPEINFO(/datum/component/mechanics_holder)
	initialization_args = list()

/datum/component/mechanics_holder/Initialize()
	src.connected_outgoing = list()
	src.connected_incoming = list()
	src.inputs = list()
	src.configs = list()
	src.lines = list()

	src.configs.Add(list(DC_ALL, CONNECT_COMP, LIST_CONNECTIONS))
	..()

/datum/component/mechanics_holder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MECHCOMP_ADD_INPUT, PROC_REF(addInput))
	RegisterSignal(parent, _COMSIG_MECHCOMP_RECEIVE_MSG, PROC_REF(fireInput))
	RegisterSignal(parent, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, PROC_REF(fireOutSignal))
	RegisterSignal(parent, COMSIG_MECHCOMP_TRANSMIT_MSG, PROC_REF(fireOutgoing))
	RegisterSignal(parent, COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, PROC_REF(fireDefault)) //Only use this when also using COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL
	RegisterSignal(parent, _COMSIG_MECHCOMP_RM_INCOMING, PROC_REF(removeIncoming))
	RegisterSignal(parent, _COMSIG_MECHCOMP_RM_OUTGOING, PROC_REF(removeOutgoing))
	RegisterSignal(parent, COMSIG_MECHCOMP_RM_ALL_CONNECTIONS, PROC_REF(WipeConnections))
	RegisterSignal(parent, _COMSIG_MECHCOMP_GET_OUTGOING, PROC_REF(getOutgoing))
	RegisterSignal(parent, _COMSIG_MECHCOMP_GET_INCOMING, PROC_REF(getIncoming))
	RegisterSignal(parent, _COMSIG_MECHCOMP_DROPCONNECT, PROC_REF(dropConnect))
	RegisterSignal(parent, _COMSIG_MECHCOMP_LINK, PROC_REF(link_devices))
	RegisterSignal(parent, COMSIG_MECHCOMP_ADD_CONFIG, PROC_REF(addConfig))
	RegisterSignal(parent, COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL, PROC_REF(allowManualSingalSetting)) //Only use this when also using COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(attackby))
	RegisterSignal(parent, _COMSIG_MECHCOMP_COMPATIBLE, PROC_REF(compatible))//Better that checking GetComponent()?
	return  //No need to ..()

/datum/component/mechanics_holder/UnregisterFromParent()
	var/list/signals = list(\
	COMSIG_MECHCOMP_ADD_INPUT,\
	_COMSIG_MECHCOMP_RECEIVE_MSG,\
	COMSIG_MECHCOMP_TRANSMIT_SIGNAL,\
	COMSIG_MECHCOMP_TRANSMIT_MSG,\
	COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,\
	_COMSIG_MECHCOMP_RM_INCOMING,\
	_COMSIG_MECHCOMP_RM_OUTGOING,\
	COMSIG_MECHCOMP_RM_ALL_CONNECTIONS,\
	_COMSIG_MECHCOMP_GET_OUTGOING,\
	_COMSIG_MECHCOMP_GET_INCOMING,\
	_COMSIG_MECHCOMP_DROPCONNECT,\
	_COMSIG_MECHCOMP_LINK,\
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
	for(var/atom/A in src.connected_incoming)
		src.removeLines(A)
		SEND_SIGNAL(A, _COMSIG_MECHCOMP_RM_OUTGOING, parent)
	for(var/atom/A in src.connected_outgoing)
		SEND_SIGNAL(A, _COMSIG_MECHCOMP_RM_INCOMING, parent)
	src.connected_incoming.Cut()
	src.connected_outgoing.Cut()
	return

// List all of the incoming and outgoing connections to/from this thing
/datum/component/mechanics_holder/proc/ListConnections(mob/user)
	var/list/out = list()
	out += "<b>Connections to [bicon(parent)] [src.parent]:</b>"
	if (length(src.connected_incoming))
		out += "<br>Incoming:"
		for(var/atom/A in src.connected_incoming)
			var/pointer_container[1] //A list of size 1, to store the address of the list we want
			SEND_SIGNAL(A, _COMSIG_MECHCOMP_GET_OUTGOING, pointer_container)
			var/list/trg_outgoing = pointer_container[1]
			out += "<br>&nbsp;&nbsp;&nbsp;&nbsp;[bicon(A)] [SPAN_NOTICE(A.name)] &rarr; [SPAN_SUCCESS(trg_outgoing[parent])]"
	else
		out += "<br>No incoming connections."

	if (length(src.connected_outgoing))
		out += "<br>Outgoing:"
		for(var/atom/A in src.connected_outgoing)
			out += "<br>&nbsp;&nbsp;&nbsp;&nbsp;[bicon(A)] [SPAN_NOTICE(A.name)] &rarr; [SPAN_SUCCESS(src.connected_outgoing[A])]"
	else
		out += "<br>No outgoing connections."
	boutput(user, out.Join())
	return

/datum/component/mechanics_holder/proc/removeLines(atom/A)
	var/datum/client_image_group/image_group = get_image_group(CLIENT_IMAGE_GROUP_MECHCOMP)
	for (var/image/line as anything in src.lines[A])
		image_group.remove_image(line)
		line.loc = null
	src.lines -= A

//Remove a device from our list of transitting devices.
/datum/component/mechanics_holder/proc/removeIncoming(var/comsig_target, var/atom/A)
	src.connected_incoming.Remove(A)
	src.removeLines(A)

//Remove a device from our list of receiving devices.
/datum/component/mechanics_holder/proc/removeOutgoing(var/comsig_target, var/atom/A)
	src.connected_outgoing.Remove(A)
	SEND_SIGNAL(parent,_COMSIG_MECHCOMP_DISPATCH_RM_OUTGOING, A)
	return

//Give the caller a copied list of our outgoing connections.
/datum/component/mechanics_holder/proc/getOutgoing(var/comsig_target, var/list/outout)
	outout[1] = src.connected_outgoing
	return

//Give the caller a copied list of our incoming connections.
/datum/component/mechanics_holder/proc/getIncoming(var/comsig_target, var/list/outin)
	outin[1] = src.connected_incoming
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
	SPAWN(1 DECI SECOND) call(parent, path)(msg)
	return

//Fire an outgoing connection with given value. Try to re-use incoming messages for outgoing signals whenever possible!
//This reduces load AND preserves the node list which prevents infinite loops.
/datum/component/mechanics_holder/proc/fireOutgoing(var/comsig_target, var/datum/mechanicsMessage/msg)
	//ratelimit components
	if(current_tick == TIME)
		if(activation_count++ > MAX_OUTGOING_PER_TICK)
			return 0
	else //if it's the next tick, reset the trackers
		activation_count = 0
		current_tick = TIME

	//If we're already in the node list we will not send the signal on.
	if(msg.hasNode(parent))
		return 0
	msg.addNode(parent)

	var/fired = 0
	for(var/atom/A in src.connected_outgoing)
		//Note: a target not handling a signal returns 0.
		var/validated = SEND_SIGNAL(parent,_COMSIG_MECHCOMP_DISPATCH_VALIDATE, A, msg.signal)
		if(validated == _MECHCOMP_VALIDATE_RESPONSE_HALT) //The component wants signal processing to stop NOW
			return fired
		if(validated == _MECHCOMP_VALIDATE_RESPONSE_BAD) //The component wants this signal to be skipped
			continue
		SEND_SIGNAL(A, _COMSIG_MECHCOMP_RECEIVE_MSG, src.connected_outgoing[A], cloneMessage(msg))
		fired = 1
		if(validated == _MECHCOMP_VALIDATE_RESPONSE_HALT_AFTER) //The component wants signal processing to stop AFTER this signal
			return fired
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
/datum/component/mechanics_holder/proc/dropConnect(atom/comsig_target, atom/A, mob/user)
	if(!A || A == parent || user.stat || !isliving(user) || (SEND_SIGNAL(A,_COMSIG_MECHCOMP_COMPATIBLE) != 1))  //ZeWaka: Fix for null.mechanics
		return

	if (!user.find_tool_in_hand(TOOL_PULSING))
		boutput(user, SPAN_ALERT("[MECHFAILSTRING]"))
		return

	//Need to use comsig_target instead of parent, to access .loc
	if(A.loc != comsig_target.loc) //If these aren't sharing a container
		var/obj/item/storage/mechanics/cabinet = null
		if(istype(comsig_target, /obj/item))
			var/obj/item/I = comsig_target
			if (istype(I.stored?.linked_item, /obj/item/storage/mechanics))
				cabinet = I.stored.linked_item
		if(istype(A, /obj/item))
			var/obj/item/I = A
			if (istype(I.stored?.linked_item, /obj/item/storage/mechanics))
				cabinet = I.stored.linked_item
		if(cabinet)
			if(!cabinet.anchored)
				boutput(user,SPAN_ALERT("Cannot create connection through an unsecured component housing"))
				return

	if(GET_DIST(parent, A) > SQUARE_TILE_WIDTH)
		boutput(user, SPAN_ALERT("Components need to be within a range of 14 meters to connect."))
		return

	var/typesel = tgui_alert(user, "Use [parent] as:", "Connection Type", list("Trigger", "Receiver", "*CANCEL*"))
	switch(typesel)
		if("Trigger")
			SEND_SIGNAL(A, _COMSIG_MECHCOMP_LINK, parent, user)
		if("Receiver")
			link_devices(comsig_target, A, user) //What do you want, an invitation? No signal needed!
		if("*CANCEL*")
			return
	return

//We are in the scope of the receiver-component, our argument is the trigger
//This feels weird/backwards, but it results in fewer SEND_SIGNALS & var/lists
/datum/component/mechanics_holder/proc/link_devices(atom/comsig_target, atom/trigger, mob/user)
	var/atom/receiver = parent
	if(trigger == comsig_target)
		boutput(user, SPAN_ALERT("Can not connect a component to itself."))
		return
	if(trigger in src.connected_outgoing)
		boutput(user, SPAN_ALERT("Can not create a direct loop between 2 components."))
		return
	if(trigger.loc != comsig_target.loc)
		var/obj/item/storage/mechanics/cabinet = null
		if(istype(comsig_target, /obj/item))
			var/obj/item/I = comsig_target
			if (istype(I.stored?.linked_item, /obj/item/storage/mechanics))
				cabinet = I.stored.linked_item
		if(istype(trigger, /obj/item))
			var/obj/item/I = trigger
			if (istype(I.stored?.linked_item, /obj/item/storage/mechanics))
				cabinet = I.stored.linked_item
		if(cabinet)
			if(!cabinet.anchored)
				boutput(user,SPAN_ALERT("Cannot create connection through an unsecured component housing"))
				return
	if(!IN_RANGE(receiver, trigger, WIDE_TILE_WIDTH))
		boutput(user, SPAN_ALERT("These two components are too far apart to connect."))
		return
	var/atom/movable/moveable_target = comsig_target
	if(istype(moveable_target) && !moveable_target.anchored)
		boutput(user, SPAN_ALERT("[moveable_target] must be anchored to connect it."))
		return
	var/atom/movable/moveable_trigger = trigger
	if(istype(moveable_trigger) && !moveable_trigger.anchored)
		boutput(user, SPAN_ALERT("[moveable_trigger] must be anchored to connect it."))
		return
	if(!src.inputs.len)
		boutput(user, SPAN_ALERT("[receiver.name] has no input slots. Can not connect [trigger.name] as Trigger."))
		return

	var/pointer_container[1] //A list of size 1, to store the address of the list we want
	SEND_SIGNAL(trigger, _COMSIG_MECHCOMP_GET_OUTGOING, pointer_container)
	var/list/trg_outgoing = pointer_container[1]
	var/selected_input = tgui_input_list(user, "Select \"[receiver.name]\" Input", "Input Selection", inputs + "*CANCEL*")
	if(selected_input == "*CANCEL*")
		return

	//draw a line for meson lookers
	var/datum/lineResult/R1 = drawLineImg(get_turf(trigger), get_turf(receiver), "data", null,\
		trigger.pixel_x, trigger.pixel_y,\
		receiver.pixel_x, receiver.pixel_y,\
		getCrossed = 0, mode = LINEMODE_SIMPLE)
	var/datum/lineResult/R2 = drawLineImg(get_turf(receiver), get_turf(trigger), "data", null,\
		receiver.pixel_x, receiver.pixel_y,\
		trigger.pixel_x, trigger.pixel_y,\
		getCrossed = 0, mode = LINEMODE_SIMPLE_REVERSED)
	src.lines[trigger] = list(R1.lineImage, R2.lineImage)
	var/datum/client_image_group/image_group = get_image_group(CLIENT_IMAGE_GROUP_MECHCOMP)
	for (var/image/line as anything in src.lines[trigger])
		line.plane = PLANE_OVERLAY_EFFECTS
		line.alpha = 190
		image_group.add_image(line)

	trg_outgoing |= receiver //Let's not allow making many of the same connection.
	trg_outgoing[receiver] = selected_input
	src.connected_incoming |= trigger //Let's not allow making many of the same connection.
	boutput(user, SPAN_SUCCESS("You connect the [trigger.name] to the [receiver.name]."))
	logTheThing(LOG_STATION, user, "connects a [log_object(trigger)] [log_loc(trigger)] to a [log_object(receiver)] [log_loc(receiver)].")
	SEND_SIGNAL(trigger,_COMSIG_MECHCOMP_DISPATCH_ADD_FILTER, receiver, user)
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
		return FALSE
	// check if the multitool has a connector component - if so, we are connecting components, not configuring!
	var/datum/component/mechanics_connector/connector = W.GetComponent(/datum/component/mechanics_connector)
	if(connector)
		src.link_devices(comsig_target, connector.connectee, user)
		return TRUE
	if(istype(comsig_target, /obj/machinery/door))
		var/obj/machinery/door/hacked_door = comsig_target
		if(hacked_door.panel_open)
			return
	if(istype(comsig_target, /obj/machinery/vending))
		var/obj/machinery/vending/hacked_vendor = comsig_target
		if(hacked_vendor.panel_open)
			return
	if(length(src.configs))
		var/selected_config = tgui_input_list(user, "Select a config to modify!", "Config", src.configs)
		if (!in_interact_range(parent, user)) return TRUE
		if(selected_config)
			switch(selected_config)
				if(SET_SEND)
					var/inp = tgui_input_text(user, "Please enter Signal:", "Signal setting", defaultSignal)
					if(!in_interact_range(parent, user) || user.stat)
						return
					inp = trimtext(strip_html_tags(inp))
					if(length(inp))
						defaultSignal = inp
						boutput(user, SPAN_SUCCESS("The signal is now set to [inp]."))
				if(DC_ALL)
					WipeConnections()
					if(istype(parent, /atom))
						var/atom/AP = parent
						boutput(user, SPAN_NOTICE("You disconnect [AP.name]."))
					return TRUE
				if(CONNECT_COMP)
					W.AddComponent(/datum/component/mechanics_connector, src.parent)
					boutput(user, SPAN_NOTICE("Your [W] will now link other mechanics components to [src.parent]! Use it in hand to stop linking!"))
					return TRUE
				if(LIST_CONNECTIONS)
					ListConnections(user)
					return TRUE
				else
					//must be a custom config specific to the device, so let the device handle it
					var/path = src.configs[selected_config]
					call(parent, path)(W, user)
					return TRUE

//If it's a multi-tool, let the user configure the device.
/datum/component/mechanics_holder/proc/compatible()
	return 1


#undef DC_ALL
#undef SET_SEND
#undef TOGGLE_MATCH

/// component for pulsing tools that will connect mechcomponents the user clicks on to the specified mechcomponent
/datum/component/mechanics_connector
	/// the specific mechcomponent, this is the one we will connect the clicked component to
	var/atom/connectee

/datum/component/mechanics_connector/Initialize(var/datum/component/mechanics_holder/C)
	. = ..()
	if(!ispulsingtool(parent))
		return COMPONENT_INCOMPATIBLE
	src.connectee = C
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(stop_linking))

/// we remove ourself here, the user no longer wishes to link components via us :(
/datum/component/mechanics_connector/proc/stop_linking(var/obj/item/thing, mob/user)
	boutput(user, SPAN_NOTICE("You stop linking with the [parent]."))
	src.RemoveComponent()

/datum/component/mechanics_connector/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	. = ..()

#undef MAX_OUTGOING_PER_TICK
