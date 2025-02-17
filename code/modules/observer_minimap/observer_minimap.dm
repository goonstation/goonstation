/client/proc/admin_minimap()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "View Admin Minimap"
	set desc = "An admin view of the station map with player locations"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(!global.observer_minimap_ui)
		global.observer_minimap_ui = new(null, "observer_minimap", new/obj/minimap/observer_minimap, "Station Map", "ntos" )

	observer_minimap_ui.ui_interact(src.mob)

/mob/dead/observer/verb/observer_minimap()
	set name = "View Minimap"
	set category = "Ghost"

	if(!global.observer_minimap_ui)
		global.observer_minimap_ui = new(null, "observer_minimap", new/obj/minimap/observer_minimap, "Station Map", "ntos" )

	observer_minimap_ui.ui_interact(src)

/datum/targetable/ghost_observer/view_minimap
	name = "View Minimap"
	desc = "View the station minimap and crew locations, click to teleport."
	icon_state = "minimap"

	cast(atom/target)
		. = ..()
		if (holder && istype(holder.owner, /mob/dead/observer))
			var/mob/dead/observer/ghost = holder.owner
			ghost.observer_minimap()
