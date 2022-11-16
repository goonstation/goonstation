// Component defines for atoms.


// ---- atom signals ----

	// ---- generic ----

	/// when an atom changes dir (olddir, newdir)
	#define COMSIG_ATOM_DIR_CHANGED "atom_dir_changed"
	/// when an atom is collided by a projectile (/obj/projectile)
	#define COMSIG_ATOM_HITBY_PROJ "atom_hitby_proj"
	/// when an atom is hit by a thrown thing (hit_target, thrown_atom, /datum/thrown_thing)
	#define COMSIG_ATOM_HITBY_THROWN "atom_hitby_thrown"
	/// when an atom is examined (/mob/examiner, /list/lines), append to lines for more description
	#define COMSIG_ATOM_EXAMINE "atom_examine"
	/// when something happens that should trigger an icon update. Or something.
	#define COMSIG_UPDATE_ICON "atom_update_icon"
	/// when something triggers Crossed by entering this atom's turf (/atom/movable)
	#define COMSIG_ATOM_CROSSED "atom_crossed"
	/// When something calls UpdateIcon, before the icon is updated
	#define COMSIG_ATOM_PRE_UPDATE_ICON "atom_before_update_icon"
	/// When something calls UpdateIcon, after the icon is updated
	#define COMSIG_ATOM_POST_UPDATE_ICON "atom_after_update_icon"
	/// When reagents change
	#define COMSIG_ATOM_REAGENT_CHANGE "atm_reag"
	/// When an atom is dragged onto something (usr, over_object, src_location, over_location, src_control, over_control, params)
	#define COMSIG_ATOM_MOUSEDROP "atom_mousedrop"
	/// When something is dragged onto an atom (object, usr, src_location, over_location, over_control, params)
	#define COMSIG_ATOM_MOUSEDROP_T "atom_mousedrop_t"
	/// When the atom is a source of an explosion (object, args_to_explode_at)
	#define COMSIG_ATOM_EXPLODE "atom_explode"
	/// When the atom somewhere (possibly nested deep) in contents is a source of an explosion (object, args_to_explode_at)
	#define COMSIG_ATOM_EXPLODE_INSIDE "atom_explode_inside"
	/// When the atom reflects a projectile
	#define COMSIG_ATOM_PROJECTILE_REFLECTED "atom_reflect_projectile"
	/// When something enters the contents of this atom (i.e. Entered())
	#define COMSIG_ATOM_ENTERED "atom_entered"
	/// When this atom is analyzed with a device analyzer (item, user)
	#define COMSIG_ATOM_ANALYZE "atom_analyze"
	/// Attacking with an item in-hand (item, attacker, params, is_special)
	#define COMSIG_ATTACKBY "attackby"
	/// Attacking without an item in-hand (attacker)
	#define COMSIG_ATTACKHAND "attackhand"
	/// when an atom changes its opacity (thing, previous_opacity)
	#define COMSIG_ATOM_SET_OPACITY "atom_set_opacity"

	// ---- minimap ----

	/// When an atom requires to create minimap markers for all minimaps.
	#define COMSIG_CREATE_MINIMAP_MARKERS "create_minimap_markers"
	/// When an atom requires to create a single minimap marker a specific minimap.
	#define COMSIG_NEW_MINIMAP_MARKER "new_minimap_marker"
	/// When an atom requires to remove minimap markers for all minimaps.
	#define COMSIG_REMOVE_MINIMAP_MARKERS "remove_minimap_markers"

// ---- atom/movable signals ----

	// ---- generic ----

	/// when an AM moves on the map (thing, previous_loc, direction)
	#define COMSIG_MOVABLE_MOVED "mov_moved"
	/// when a movable is about to move, return true to prevent (thing, new_loc, direction)
	#define COMSIG_MOVABLE_BLOCK_MOVE "mov_block_moved"
	/// when an AM changes its loc (thing, previous_loc)
	#define COMSIG_MOVABLE_SET_LOC "mov_set_loc"
	/// when an AM ends throw (thing, /datum/thrown_thing)
	#define COMSIG_MOVABLE_THROW_END "mov_throw_end"
	/// when an AM receives a packet (datum/signal/signal, receive_method, receive_param / range, connection_id)
	#define COMSIG_MOVABLE_RECEIVE_PACKET "mov_receive_packet"
	/// send this signal to send a radio packet (datum/signal/signal, receive_param / range, frequency), if frequency is null all registered frequencies are used
	#define COMSIG_MOVABLE_POST_RADIO_PACKET "mov_post_radio_packet"
	/// when an atom hits something when being thrown (thrown_atom, hit_target, /datum/thrown_thing)
	#define COMSIG_MOVABLE_HIT_THROWN "mov_hit_thrown"

	// ---- complex ----

	/// when the outermost movable in the .loc chain changes (thing, old_outermost_movable, new_outermost_movable)
	#define XSIG_OUTERMOST_MOVABLE_CHANGED list(/datum/component/complexsignal/outermost_movable, "mov_outermost_changed")
	/// when the z-level of a movable changes (works in nested contents) (thing, old_z_level, new_z_level)
	#define XSIG_MOVABLE_Z_CHANGED list(/datum/component/complexsignal/outermost_movable, "mov_z-level_changed")

// ---- turf signals ----
	// when an atom inside the turfs contents changes opacity (turf, previous_opacity, thing)
	#define COMSIG_TURF_CONTENTS_SET_OPACITY "turf_contents_set_opacity"
	// when an atom inside the turfs contents changes opacity, but only called when it would actually do a meaningful change (turf, previous_opacity, thing)
	#define COMSIG_TURF_CONTENTS_SET_OPACITY_SMART "turf_contents_set_opacity_smart"

// ---- obj signals ----

// ---- obj/critter signals ----

	// When an obj/critter dies
	#define COMSIG_OBJ_CRITTER_DEATH "obj_critter_death"

// ---- obj/storage signals ----

	/// When the storage closes
	#define COMSIG_OBJ_STORAGE_CLOSED "storage_closed"

// ---- obj/projectile signals ----

	/// After a projectile makes a valid hit on an atom (after immunity/other early returns, before other effects)
	#define COMSIG_OBJ_PROJ_COLLIDE "proj_collide_atom"

// ---- item signals ----

	//	---- generic ----

	/// When an item is equipped (user, slot)
	#define COMSIG_ITEM_EQUIPPED "itm_equip"
	/// When an item is unequipped (user)
	#define COMSIG_ITEM_UNEQUIPPED "itm_unequip"
	/// When an item is picked up (user)
	#define COMSIG_ITEM_PICKUP "itm_pickup"
	/// When an item is picked dropped (user)
	#define COMSIG_ITEM_DROPPED "itm_drop"
	/// When an item is used to attack a mob
	#define COMSIG_ITEM_ATTACK_POST "itm_atk_post"
	/// Just before an item is eaten (eater,item)
	#define COMSIG_ITEM_CONSUMED_PRE "itm_atk_consumed_pre"
	/// When an item is eaten (eater,item)
	#define COMSIG_ITEM_CONSUMED "itm_atk_consumed"
	/// After an item's been eaten, but there's still some left (eater,item)
	#define COMSIG_ITEM_CONSUMED_PARTIAL "itm_atk_consumed_partial"
	/// After we've consumed an item (eater,item)
	#define COMSIG_ITEM_CONSUMED_ALL "itm_atk_consumed_all"
	/// Called before an attackby that uses this item (target, user)
	#define COMSIG_ITEM_ATTACKBY_PRE "itm_atkby_pre"
	/// When an item is used to attack a mob before it actually hurts the mob
	#define COMSIG_ITEM_ATTACK_PRE "itm_atk_pre"
	/// When an item is used in-hand
	#define COMSIG_ITEM_ATTACK_SELF "itm_atk_self"
	/// When an item is swapped to [does not include being picked up/taken out of bags/etc] (user)
	#define COMSIG_ITEM_SWAP_TO "itm_swap_to"
	/// When an item is swapped away from [does not include being picked up/taken out of bags/etc] (user)
	#define COMSIG_ITEM_SWAP_AWAY "itm_swap_away"
	/// After an item's itemspecial is used (user)
	#define COMSIG_ITEM_SPECIAL_POST "itm_special_post"
	/// When items process ticks on an item
	#define COMSIG_ITEM_PROCESS "itm_process"
	/// After attacking any atom (not just mob) with this item (item, atom/target, mob/user, reach, params)
	#define COMSIG_ITEM_AFTERATTACK "itm_afterattack"

	// ---- bomb assembly signals ----

	/// Triggers on the start of signalling the opening of an assembly bomb
	#define COMSIG_ITEM_BOMB_SIGNAL_START "bomb_signal_start"
	/// Triggers when an assembly bomb's signalling is cancelled
	#define COMSIG_ITEM_BOMB_SIGNAL_CANCEL "bomb_signal_cancel"

	// ---- implant signals ----

	/// When implanted
	#define COMSIG_ITEM_IMPLANT_IMPLANTED "implant_implanted"
	/// When removed
	#define COMSIG_ITEM_IMPLANT_REMOVED "implant_removed"


// ---- mob signals ----

	// ---- generic ----

	/// When a client logs into a mob
	#define COMSIG_MOB_LOGIN "mob_login"
	/// When a client logs out of a mob
	#define COMSIG_MOB_LOGOUT "mob_logout"
	/// At the beginning of when an attackresults datum is being set up
	#define COMSIG_MOB_ATTACKED_PRE "attacked_pre"
	/// When a mob dies
	#define COMSIG_MOB_DEATH "mob_death"
	/// When a mob fakes death
	#define COMSIG_MOB_FAKE_DEATH "mob_fake_death"
	/// When a mob picks up an item
	#define COMSIG_MOB_PICKUP "mob_pickup"
	/// When a mob drops an item
	#define COMSIG_MOB_DROPPED "mob_drop"
	/// Just before an item is eaten (feeder,item)
	#define COMSIG_MOB_ITEM_CONSUMED_PRE "mob_itm_atk_consumed_pre"
	/// When an item is eaten (feeder,item)
	#define COMSIG_MOB_ITEM_CONSUMED "mob_itm_atk_consumed"
	/// Sent when a mob throws something (target, params)
	#define COMSIG_MOB_THROW_ITEM "throw_item"
	/// Sent when a mob throws something that lands nearby
	#define COMSIG_MOB_THROW_ITEM_NEARBY "throw_item_nearby"
	/// Sent when a mob sets their a_intent var, returning anything will cancel the intent change (mob, intent)
	#define COMSIG_MOB_SET_A_INTENT "mob_set_a_intent"
	/// Sent when radiation status ticks on mob (stage)
	#define COMSIG_MOB_GEIGER_TICK "mob_geiger"
	/// When the mob vomits
	#define COMSIG_MOB_VOMIT "mob_vomit"
	/// Sent when defibbed status is added to a mob
	#define COMSIG_MOB_SHOCKED_DEFIB "mob_shocked"
	/// Sent to mob when client lifts the mouse button
	#define COMSIG_MOB_MOUSEUP "mob_mouseup"
	/// Sent when a mob is grabbed by another mob (grab object)
	#define COMSIG_MOB_GRABBED "mob_grabbed"

	// ---- cloaking device signal ----

	/// Make cloaking devices turn off - sent to the mob
	#define COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE "cloak_deactivate"

	// ---- typing indicator signals ----

	/// Create typing indicator
	#define COMSIG_CREATE_TYPING "create_typing"
	/// Remove typing indicator
	#define COMSIG_REMOVE_TYPING "remove_typing"
	/// Speech bubble
	#define COMSIG_SPEECH_BUBBLE "speech_bubble"

	// ---- disguiser device signal ----

	/// Make disguiser devices turn off - sent to the mob
	#define COMSIG_MOB_DISGUISER_DEACTIVATE "disguiser_deactivate"

// ---- living signals ----
		// When Life() ticks (mult)
		#define COMSIG_LIVING_LIFE_TICK "mob_life_tick"

// ---- human signals ----
