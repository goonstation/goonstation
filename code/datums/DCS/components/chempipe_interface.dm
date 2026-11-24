TYPEINFO(/datum/component/fluid_pipe_interface)
	initialization_args = list(
		ARG_INFO("proc_on_connect", DATA_INPUT_REF, "The proc reference that will be called AFTER the component replaced a port with a connecting_node"),
		ARG_INFO("proc_on_disconnect", DATA_INPUT_REF, "The proc reference that will be called BEFORE the component replaces connecting_node with a port"),
		ARG_INFO("proc_on_process", DATA_INPUT_REF, "The proc reference that will be called when the chemical node processes"),
		ARG_INFO("scan_on_creation", DATA_INPUT_BOOL, "Should this object try to find a port upon creation/building from frame?"),
	)

///This component is intended for 1-tile sized objects to be able to be easily connected by placing a fluid pipe port on their tile.
///This component will replace the fluid port with a unary node that and will relay signals between the machine in question and the port
///This component will take care that the node gets replaced with a fluid port again whenever it's parent gets moved, destroyed or when this component is removed.

/datum/component/fluid_pipe_interface
	dupe_mode = COMPONENT_DUPE_UNIQUE // we don't want a new component initiallizing over the old one to delete an already existing fluid pipe node
	/// This the fluid node that will replace the build interface
	var/obj/machinery/fluid_machinery/unary/node/connecting_node = null
	/// This stores the underlay under the machine
	var/image/node_underlay = null
	/// This stores the turf this component is scanning for a fluid port
	var/turf/scanned_turf = null
	///The Procref that will get called after the node replaced a port
	var/on_connect_proc = null
	///The Procref that will get called before the node gets replaced by a port
	var/on_disconnect_proc = null
	///The Procref that will get called when the node processes
	var/on_process_proc = null
	///if set to TRUE (by default), this object will scan for a input pipe upon being created
	var/should_scan_on_creation = TRUE



/datum/component/fluid_pipe_interface/Initialize(var/connect_proc, var/disconnect_proc, var/process_proc, var/scan_on_creation = TRUE)
	. = ..()
	if(!src.parent || !isatom(src.parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/new_parent = src.parent
	src.on_connect_proc = connect_proc
	src.on_disconnect_proc = disconnect_proc
	src.on_process_proc = process_proc
	src.should_scan_on_creation = scan_on_creation
	//maybe we are stuck somewhere like e.g. a frame, so we need to account for that
	if(isturf(new_parent.loc))
		src.scanned_turf = get_turf(new_parent.loc)


/datum/component/fluid_pipe_interface/RegisterWithParent()
	. = ..()
	var/atom/affected_parent = src.parent
	RegisterHelpMessageHandler(affected_parent, PROC_REF(get_help_msg))
	RegisterSignal(affected_parent, COMSIG_MACHINERY_HAS_REMOVEABLE_FLUID_NODE, PROC_REF(check_fluid_node))
	RegisterSignal(affected_parent, COMSIG_MACHINERY_CAN_RECEIVE_FLUID_NODE, PROC_REF(check_can_receive))
	RegisterSignal(affected_parent, COMSIG_MACHINERY_REMOVE_FLUID_NODE, PROC_REF(on_HPD_removal))
	if(src.scanned_turf)
		RegisterSignal(src.scanned_turf, COMSIG_TURF_FLUID_PORT_CREATED, PROC_REF(on_fluid_port_created))
	if(ismovable(src.parent))
		RegisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC, PROC_REF(on_parent_move))
	if(src.should_scan_on_creation)
		RegisterSignal(src.parent, COMSIG_BUILD_FROM_FRAME, PROC_REF(rescan_for_port))
		src.rescan_for_port()


/datum/component/fluid_pipe_interface/UnregisterFromParent()
	. = ..()
	var/atom/affected_parent = src.parent
	UnregisterHelpMessageHandler(affected_parent)
	UnregisterSignal(affected_parent, COMSIG_MOVABLE_SET_LOC)
	UnregisterSignal(affected_parent, COMSIG_MACHINERY_HAS_REMOVEABLE_FLUID_NODE)
	UnregisterSignal(affected_parent, COMSIG_MACHINERY_CAN_RECEIVE_FLUID_NODE)
	UnregisterSignal(affected_parent, COMSIG_MACHINERY_REMOVE_FLUID_NODE)
	if(src.scanned_turf)
		UnregisterSignal(src.scanned_turf, COMSIG_TURF_FLUID_PORT_CREATED)
		src.scanned_turf = null
	//when we get unregistered from our parent, we can't keep the fluid node in us.
	src.recreate_port(src.scanned_turf)
	QDEL_NULL(src.node_underlay)

/// This Proc pings on the scanned tile for a fluid port and tries to replace it
/// Use this manually if you have should_scan_on_creation set to false and need to machine to grab a port
/datum/component/fluid_pipe_interface/proc/rescan_for_port()
	if(!src.scanned_turf)
		return
	// we require this list so we can grab our object from the signal call
	var/list/scan_list = list()
	SEND_SIGNAL(src.scanned_turf, COMSIG_TURF_FLUID_PORT_PING, scan_list)
	if(length(scan_list) > 0)
		// it should only be a single port here, but in case someone dev'ed in more, we just pick a random one
		return src.replace_port(pick(scan_list))


/// ----------------------- Signal-related Procs -----------------------

/datum/component/fluid_pipe_interface/proc/on_node_init(var/affected_node)
	//we give this node an internal reagent storage so we can transfer directly into the network.
	src.connecting_node.reagents = src.connecting_node.network?.reagents || new /datum/reagents(0)

/datum/component/fluid_pipe_interface/proc/on_HPD_removal(var/affected_parent, var/obj/used_HPD)
	return src.remove_fluid_node()

/datum/component/fluid_pipe_interface/proc/check_can_receive(var/affected_parent, var/obj/used_HPD)
	if(!src.connecting_node)
		return TRUE

/datum/component/fluid_pipe_interface/proc/check_fluid_node(var/affected_parent, var/obj/used_HPD)
	if(src.connecting_node)
		return TRUE

/datum/component/fluid_pipe_interface/proc/on_fluid_port_created(var/affected_turf, var/obj/machinery/fluid_machinery/unary/input/new_fluid_port)
	// we got a port played on our tile, let's try to grab it
	return src.replace_port(new_fluid_port)

/datum/component/fluid_pipe_interface/proc/get_help_msg(atom/movable/viewed_parent, mob/viewer, list/lines)
	if(src.connecting_node)
		lines += "[viewed_parent] can be disconnected from the fluid network by using a HPD's remove-mode on it."
	else
		lines += "[viewed_parent] can be connected to a fluid network by placing a fluid port under it."

/datum/component/fluid_pipe_interface/proc/on_parent_move(var/affected_parent, var/previous_location)
	var/atom/moved_parent = src.parent
	if(src.connecting_node && previous_location != moved_parent.loc)
		// if we changed our location and we had a connected node, we need to remove the location
		src.recreate_port(get_turf(previous_location))
		if(src.scanned_turf)
			UnregisterSignal(src.scanned_turf, COMSIG_TURF_FLUID_PORT_CREATED)
			src.scanned_turf = null
		if(isturf(moved_parent.loc))
			src.scanned_turf = moved_parent.loc
			RegisterSignal(src.scanned_turf, COMSIG_TURF_FLUID_PORT_CREATED, PROC_REF(on_fluid_port_created))

/datum/component/fluid_pipe_interface/proc/on_node_process(var/obj/machinery/fluid_machinery/unary/node/processing_node, var/mult)
	if(!src.on_process_proc)
		return
	//we just return the proc we need to call on our parent
	return call(src.parent, src.on_process_proc)(src.parent, src.connecting_node, mult)

/// ----------------------- -----------------------

/// This proc removes the internal unary fluid node
/datum/component/fluid_pipe_interface/proc/remove_fluid_node(var/turf/new_port_destination)
	if(!src.connecting_node)
		return
	if(src.on_disconnect_proc)
		call(src.parent, src.on_disconnect_proc)(src.parent, src.connecting_node, new_port_destination)
	UnregisterSignal(src.connecting_node, COMSIG_MACHINERY_PROCESS)
	UnregisterSignal(src.connecting_node, COMSIG_FLUID_PIPE_ON_INIT)
	if(istype(src.connecting_node.reagents, /datum/reagents/flow_network))
		// we need to specifically check for the flow network subtype here, because we ports and these nodes share the same datum
		// if we don't drop the reference, we delete the whole fluid networks reagent datum
		src.connecting_node.reagents = null
	QDEL_NULL(src.connecting_node)
	src.update_overlay()
	return TRUE

/// This proc removes the internal unary fluid node and places a fluid port at port_destination, if an internal fluid node exists, removing the old one
/// Returns TRUE if the fluid port was set sucessfully
/datum/component/fluid_pipe_interface/proc/recreate_port(var/turf/port_destination)
	if(!src.connecting_node)
		return
	var/port_direction = src.connecting_node.dir
	src.remove_fluid_node(port_destination)
	if(port_destination && !src.parent.qdeled && !src.parent.disposed)
		//after we removed the old fluid node, we can place a fluid port at the new direction
		//the preloader is needed because else we aren't able to set a direction within new()
		new /dmm_suite/preloader(port_destination, list("dir" = port_direction))
		var/obj/machinery/fluid_machinery/unary/input/new_port = new /obj/machinery/fluid_machinery/unary/input(port_destination)
		new_port.initialize()
		return TRUE


/// This proc replaces a given port with an internal unary fluid node
/// This proc returns TRUE if the port in question was sucessfully replaced
/datum/component/fluid_pipe_interface/proc/replace_port(var/obj/machinery/fluid_machinery/unary/input/port_to_replace)
	if(!istype(port_to_replace) || src.connecting_node || port_to_replace.disposed || port_to_replace.qdeled)
		return
	//we save the location so we can set the new node to that location once we removed the port
	var/port_direction = port_to_replace.dir
	port_to_replace.onDestroy()
	//the preloader is needed because else we aren't able to set a direction within new()
	new /dmm_suite/preloader(get_turf(src.parent), list("dir" = port_direction))
	src.connecting_node = new /obj/machinery/fluid_machinery/unary/node (get_turf(src.parent))
	//we need to register the signal before initializing the fluid machine, so we connect to the fluid network properly
	RegisterSignal(src.connecting_node, COMSIG_FLUID_PIPE_ON_INIT, PROC_REF(on_node_init))
	src.connecting_node.initialize()
	if(src.on_connect_proc)
		call(src.parent, src.on_connect_proc)(src.parent, src.connecting_node)
	if(src.on_process_proc)
		RegisterSignal(src.connecting_node, COMSIG_MACHINERY_PROCESS, PROC_REF(on_node_process))
	src.update_overlay()
	return TRUE

/datum/component/fluid_pipe_interface/proc/update_overlay()
	var/atom/affected_parent = src.parent
	if(!src.connecting_node)
		if(src.node_underlay)
			// our node got removed, so we don't have an overlay anymore
			affected_parent.underlays -= src.node_underlay
			QDEL_NULL(src.node_underlay)
		return
	if(!src.node_underlay)
		src.node_underlay = image(icon = 'icons/obj/fluidpipes/fluid_machines.dmi',loc = src.parent,icon_state = "port", dir = src.connecting_node.dir)
	if(!(src.node_underlay in affected_parent.overlays))
		affected_parent.underlays += src.node_underlay


