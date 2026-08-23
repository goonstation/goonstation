/*
 * Copyright (C) 2025 Mr. Moriarty
 *
 * Originally contributed to the 35 Below Project
 * Made available under the terms of the CC BY-NC-SA 3.0
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/datum/ambient_lighting_controller
	var/client/owner
	var/previous_z_level

/datum/ambient_lighting_controller/New(client/owner)
	. = ..()

	src.owner = owner
	src.RegisterSignal(src.owner, COMSIG_CLIENT_LOGIN, PROC_REF(register_signals))
	src.RegisterSignal(src.owner, COMSIG_CLIENT_LOGOUT, PROC_REF(unregister_signals))
	src.register_signals(src.owner, src.owner.mob)

/datum/ambient_lighting_controller/disposing()
	src.unregister_signals(src.owner, src.owner.mob)
	src.UnregisterSignal(src.owner, COMSIG_CLIENT_LOGIN)
	src.UnregisterSignal(src.owner, COMSIG_CLIENT_LOGOUT)

	src.remove_ambient_lighting(map_settings.z_level_ambient_lighting["[src.previous_z_level]"])
	src.owner = null

	. = ..()

/datum/ambient_lighting_controller/proc/get_ambient_lighting_for_z_level(zlevel)
	var/controller_id = map_settings.z_level_ambient_lighting["[zlevel]"]
	if(controller_id)
		. = daynight_controllers[controller_id].ambient_screen

/datum/ambient_lighting_controller/proc/update_z_level_ambient_lighting(datum/component/component, old_z_level, new_z_level)
	if (new_z_level == src.previous_z_level)
		return

	src.remove_ambient_lighting(src.get_ambient_lighting_for_z_level(src.previous_z_level))
	src.add_ambient_lighting(src.get_ambient_lighting_for_z_level(new_z_level))

	src.previous_z_level = new_z_level

/datum/ambient_lighting_controller/proc/add_ambient_lighting(atom/movable/screen/ambient_lighting/ambient_lighting)
	if (!ambient_lighting)
		return

	src.owner.screen += ambient_lighting

/datum/ambient_lighting_controller/proc/remove_ambient_lighting(atom/movable/screen/ambient_lighting/ambient_lighting)
	if (!ambient_lighting)
		return

	src.owner.screen -= ambient_lighting

/datum/ambient_lighting_controller/proc/register_signals(client/C, mob/M)
	src.RegisterSignal(M, XSIG_MOVABLE_Z_CHANGED, PROC_REF(update_z_level_ambient_lighting))

	var/atom/movable/outermost_movable = global.outermost_movable(M)
	src.update_z_level_ambient_lighting(null, null, outermost_movable.z)

/datum/ambient_lighting_controller/proc/unregister_signals(client/C, mob/M)
	if (!M.GetComponent(/datum/component/complexsignal/outermost_movable))
		return

	src.UnregisterSignal(M, XSIG_MOVABLE_Z_CHANGED)





/client/var/datum/ambient_lighting_controller/ambient_lighting_controller

/client/New()
	. = ..()

	// Add the ambient lighting plane to the client's screen.
	src.screen += src.add_plane(new /atom/movable/screen/plane_parent(PLANE_AMBIENT_LIGHTING, appearance_flags = TILE_BOUND, mouse_opacity = 0, name = "*ambient_lighting_plane", is_screen = 1))

	// Apply applicable alpha filters to the plane, so to block out parallax occluded (roofed) turfs and unseen areas.
	var/atom/movable/screen/plane_parent/ambient_lighting_plane = src.get_plane(PLANE_AMBIENT_LIGHTING)

	var/atom/movable/screen/plane_parent/occlusion_plane = src.get_plane(PLANE_FOREGROUND_PARALLAX_OCCLUSION)
	ambient_lighting_plane.add_filter("occlusion_plane", 1, alpha_mask_filter(render_source = occlusion_plane.render_target, flags = MASK_INVERSE))

	var/atom/movable/screen/plane_parent/blackness_plane = src.get_plane(PLANE_BLACKNESS)
	ambient_lighting_plane.add_filter("blackness_plane", 1, alpha_mask_filter(render_source = blackness_plane.render_target, flags = MASK_INVERSE))

	// The master plane display renders the ambient lighting plane to the ordinary lighting plane.
	var/atom/movable/screen/plane_display/master/master_plane_display = new()
	master_plane_display.plane = PLANE_LIGHTING
	master_plane_display.layer = LIGHTING_LAYER_BASE
	master_plane_display.blend_mode = BLEND_ADD
	master_plane_display.request_keep_together()

	src.screen += master_plane_display

	var/atom/movable/screen/plane_display/plane_display = new(ambient_lighting_plane)
	plane_display.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	master_plane_display.vis_contents += plane_display

	// Create the ambient lighting controller.
	src.ambient_lighting_controller = new(src)

/client/Del()
	qdel(src.ambient_lighting_controller)
	. = ..()
