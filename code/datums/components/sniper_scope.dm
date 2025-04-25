/// SNIPER SCOPE COMPONENT - when sprint is toggled, overlay a reticle on the screen and movement keys move the screen
TYPEINFO(/datum/component/holdertargeting/sniper_scope)
	initialization_args = list(
		ARG_INFO("speed", DATA_INPUT_NUM, "Scope movement per tick (in pixels)", 12),
		ARG_INFO("max_range", DATA_INPUT_NUM, "Maximum range of scope (in pixels, 0 for infinite)", 3200),
		ARG_INFO("scope_overlay", DATA_INPUT_TYPE, "Type of the scope overlay", /datum/overlayComposition/sniper_scope),
		ARG_INFO("scope_sound", DATA_INPUT_TEXT, "Sound to play when raising scope", 'sound/weapons/scope.ogg'),
	)

/datum/component/holdertargeting/sniper_scope
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	mobtype = /mob/living
	var/enabled = FALSE
	var/always_on = FALSE
	var/scoped = FALSE
	var/datum/overlayComposition/scope_overlay
	var/scope_sound
	var/datum/movement_controller/sniper_scope/movement_controller

	Initialize(speed = 12, max_range = 3200, datum/overlayComposition/scope_overlay, scope_sound)
		if(..() == COMPONENT_INCOMPATIBLE || !isitem(parent))
			return COMPONENT_INCOMPATIBLE
		else
			var/obj/item/I = parent
			src.scope_overlay = scope_overlay
			src.scope_sound = scope_sound
			create_movement_controller(speed, max_range)
			RegisterSignal(I, COMSIG_ITEM_SWAP_TO, PROC_REF(init_scope_mode))
			RegisterSignal(I, COMSIG_ITEM_SWAP_AWAY, PROC_REF(end_scope_mode))
			RegisterSignal(I, COMSIG_SCOPE_ENABLED, PROC_REF(enable_scope))
			if(ismob(I.loc))
				on_pickup(null, I.loc)

	on_pickup(datum/source, mob/user)
		. = ..()
		if(user.equipped() == parent && enabled)
			init_scope_mode(source, user)

	on_dropped(datum/source, mob/user)
		end_scope_mode(source, user)
		if (!always_on)
			src.enabled = FALSE
		. = ..()
	always_on
		enabled = TRUE
		always_on = TRUE

/datum/component/holdertargeting/sniper_scope/proc/enable_scope(datum/source, mob/user, enabled)
	if(!enabled && src.enabled)
		end_scope_mode(source, user)
	else
		if(enabled && !src.enabled )
			init_scope_mode(source, user)
	src.enabled = enabled
/datum/component/holdertargeting/sniper_scope/proc/create_movement_controller(speed, max_range)
	src.movement_controller = new/datum/movement_controller/sniper_scope(speed, max_range)

/datum/component/holdertargeting/sniper_scope/proc/init_scope_mode(datum/source, mob/user) // they are holding the gun
	RegisterSignal(user, COMSIG_MOB_SPRINT, PROC_REF(toggle_scope))

/datum/component/holdertargeting/sniper_scope/proc/end_scope_mode(datum/source, mob/user) // they are no longer holding the gun
	UnregisterSignal(user, COMSIG_MOB_SPRINT)
	src.stop_sniping(user)

/datum/component/holdertargeting/sniper_scope/proc/toggle_scope(mob/user)
	if(scoped)
		src.stop_sniping(user)
	else
		src.begin_sniping(user)
	scoped = !scoped

/datum/component/holdertargeting/sniper_scope/proc/begin_sniping(mob/user)
	user.override_movement_controller = src.movement_controller
	src.movement_controller.start()
	user.keys_changed(0,0xFFFF)
	SEND_SIGNAL(parent, COMSIG_SCOPE_TOGGLED, TRUE)
	if(src.scope_overlay)
		if(!user.hasOverlayComposition(src.scope_overlay))
			user.addOverlayComposition(src.scope_overlay)
			user.updateOverlaysClient(user.client)
	if(src.scope_sound)
		playsound(user, src.scope_sound, 50, TRUE)

/datum/component/holdertargeting/sniper_scope/proc/stop_sniping(mob/user)
	user.override_movement_controller = null
	src.movement_controller.stop()
	SEND_SIGNAL(parent, COMSIG_SCOPE_TOGGLED, FALSE, user)
	user.keys_changed(0,0xFFFF)
	if (user.client)
		user.client.pixel_x = 0
		user.client.pixel_y = 0
	if(src.scope_overlay)
		user.removeOverlayComposition(src.scope_overlay)
		user.updateOverlaysClient(user.client)

/datum/component/holdertargeting/sniper_scope/light
	create_movement_controller(speed, max_range)
		src.movement_controller = new/datum/movement_controller/sniper_scope/light(speed, max_range)
