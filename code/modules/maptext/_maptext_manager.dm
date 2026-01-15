/// The maptext manager of this `atom`, responsible for displaying maptext over this atom to clients.
/atom/var/atom/movable/maptext_manager/maptext_manager

/atom/disposing()
	qdel(src.maptext_manager)

	. = ..()


/**
 *	Maptext manager `/atom/movable`s govern displaying maptext over single parent atom. To this end, they track the outermost movable
 *	of the parent atom, and relocate to the outermost loc if possible. To display maptext to a client, the list of maptext holders
 *	indexed by their associated clients is queried for the maptext holder associated with that client, and instructed to add a line.
 */
/atom/movable/maptext_manager
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | TILE_BOUND | PIXEL_SCALE
	mouse_opacity = 0

	/// The atom that this maptext manager belongs to.
	var/atom/parent = null
	/// Whether this maptext manager is registered to the `XSIG_OUTERMOST_MOVABLE_CHANGED` complex signal.
	var/registered = FALSE
	/// A list of maptext holders belonging to this maptext manager, indexed by their associated clients.
	var/list/atom/movable/maptext_holder/maptext_holders_by_client = null

/atom/movable/maptext_manager/New(atom/parent)
	. = ..()

	src.parent = parent
	src.maptext_holders_by_client = list()

	src.set_loc(null)

/atom/movable/maptext_manager/disposing()
	for (var/client/client as anything in src.maptext_holders_by_client)
		qdel(src.maptext_holders_by_client[client])

	src.notify_empty()
	src.parent.maptext_manager = null
	src.parent = null
	src.maptext_holders_by_client = null

	. = ..()

/// Adds a line of maptext to the maptext holder associated with the specified client, displaying the maptext over the parent atom.
/atom/movable/maptext_manager/proc/add_maptext(client/client, image/maptext/text)
	if (client.preferences.flying_chat_hidden && text.respect_maptext_preferences)
		return

	src.maptext_holders_by_client[client] ||= new /atom/movable/maptext_holder(src, client)
	src.maptext_holders_by_client[client].add_line(text)

/// Notifies this maptext manager that the maptext holder of the specified client is empty. If all maptext holders are empty, the `XSIG_OUTERMOST_MOVABLE_CHANGED` complex signal is unregistered.
/atom/movable/maptext_manager/proc/notify_empty(client/client)
	if (client)
		qdel(src.maptext_holders_by_client[client])

	if (length(src.maptext_holders_by_client) || !src.registered)
		return

	src.vis_locs = null
	UnregisterSignal(src.parent, XSIG_OUTERMOST_MOVABLE_CHANGED)
	src.registered = FALSE

/// Notifies this maptext manager that a maptext holder is nonempty, requiring it to register the `XSIG_OUTERMOST_MOVABLE_CHANGED` complex signal if not already done so.
/atom/movable/maptext_manager/proc/notify_nonempty()
	if (src.registered)
		return

	if (!ismovable(src.parent))
		src.update_outermost_movable(null, null, src.parent)
		return

	src.update_outermost_movable(null, null, global.outermost_movable(src.parent))
	RegisterSignal(src.parent, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(update_outermost_movable))
	src.registered = TRUE

/// Update the loc of this maptext manager to specified new outermost movable. Used with `XSIG_OUTERMOST_MOVABLE_CHANGED`.
/atom/movable/maptext_manager/proc/update_outermost_movable(datum/component/component, atom/movable/old_outermost, atom/movable/new_outermost)
	src.vis_locs = null

	// Use a turf for the maptext holder if the outermost in a disposal pipe or other such underfloor things.
	if ((new_outermost.level == UNDERFLOOR) && (new_outermost.invisibility == INVIS_ALWAYS))
		new_outermost = new_outermost.loc

	new_outermost.vis_contents += src
	src.pixel_x = new_outermost.maptext_manager_x
	src.pixel_y = new_outermost.maptext_manager_y
