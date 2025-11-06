var/global/atom/movable/minimap_ui_handler/observer_minimap/observer_minimap_ui
/atom/movable/minimap_ui_handler/observer_minimap/ui_state(mob/user)
	return max(tgui_admin_state.can_use_topic(src, user), tgui_observer_state.can_use_topic(src, user))
/atom/movable/minimap_ui_handler/observer_minimap/ui_status(mob/user)
	return max(tgui_admin_state.can_use_topic(src, user), tgui_observer_state.can_use_topic(src, user))
