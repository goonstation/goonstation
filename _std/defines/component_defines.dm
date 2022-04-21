/// Used to trigger signals and call procs registered for that signal
/// The datum hosting the signal is automaticaly added as the first argument
/// Returns a bitfield gathered from all registered procs
/// Arguments given here are packaged in a list and given to _SendSignal
#define SEND_SIGNAL(target, sigtype, arguments...) ( !target?.comp_lookup || !target.comp_lookup[sigtype] ? 0 : target._SendSignal(sigtype, list(target, ##arguments)) )

#define SEND_COMPLEX_SIGNAL(target, sigtype, arguments...) SEND_SIGNAL(target, sigtype[2], ##arguments)

#define GLOBAL_SIGNAL global_signal_holder // dummy datum that exclusively exists to hold onto global signals

/**
	* `target` to use for signals that are global and not tied to a single datum.
	*
	* Note that this does NOT work with SEND_SIGNAL because of preprocessor weirdness.
	* Use SEND_GLOBAL_SIGNAL instead.
	*/
#define SEND_GLOBAL_SIGNAL(sigtype, arguments...) ( !global_signal_holder.comp_lookup || !global_signal_holder.comp_lookup[sigtype] ? 0 : global_signal_holder._SendSignal(sigtype, list(global_signal_holder, ##arguments)) )

/// A wrapper for _AddComponent that allows us to pretend we're using normal named arguments
#define AddComponent(arguments...) _AddComponent(list(##arguments))

/// A wrapper for _LoadComponent that allows us to pretend we're using normal named arguments
#define LoadComponent(arguments...) _LoadComponent(list(##arguments))

/// Checks if a signal is "complex", i.e. it is handled by adding a special component and registering may have side effects and overhead
#define IS_COMPLEX_SIGNAL(x) (length(x) == 2 && ispath(x[1], /datum/component/complexsignal))

/**
	* Return this from `/datum/component/Initialize` or `datum/component/OnTransfer` to have the component be deleted if it's applied to an incorrect type.
	*
	* `parent` must not be modified if this is to be returned.
	* This will be noted in the runtime logs.
	*/

#define COMPONENT_INCOMPATIBLE 1
/// Returned in PostTransfer to prevent transfer, similar to `COMPONENT_INCOMPATIBLE`
#define COMPONENT_NOTRANSFER 2


/// arginfo handling TODO: document
#define ARG_INFO(name, type, desc, default...)\
	list(name, type, desc, ##default)

// How multiple components of the exact same type are handled in the same datum

/// old component is deleted (default)
#define COMPONENT_DUPE_HIGHLANDER		0
/// duplicates allowed
#define COMPONENT_DUPE_ALLOWED			1
/// new component is deleted
#define COMPONENT_DUPE_UNIQUE			2
/// old component is given the initialization args of the new
#define COMPONENT_DUPE_UNIQUE_PASSARGS	4
/// each component of the same type is consulted as to whether the duplicate should be allowed
#define COMPONENT_DUPE_SELECTIVE		5


// ---- global signals ----
#define COMSIG_GLOBAL_REBOOT "global_reboot"
/// When a drone dies. Y'know, the critter ones.
#define COMSIG_GLOBAL_DRONE_DEATH "global_drone_death"
/// When a cargo pad is destroyed, deconstructed, or turned off
#define COMSIG_GLOBAL_CARGO_PAD_DISABLED "global_cargo_pad_destroyed"
/// When a cargo pad is built or turned on
#define COMSIG_GLOBAL_CARGO_PAD_ENABLED "global_cargo_pad_enabled"

//  ---- datum signals ----

/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// just before a datum's disposing()
#define COMSIG_PARENT_PRE_DISPOSING "parent_pre_disposing"

// ---- atom signals ----

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
/// When something calls UpdateIcon
#define COMSIG_ATOM_PRE_UPDATE_ICON "atom_before_update_icon"
/// When something calls UpdateIcon
#define COMSIG_ATOM_POST_UPDATE_ICON "atom_after_update_icon"
/// When reagents change
#define COMSIG_ATOM_REAGENT_CHANGE "atm_reag"
/// When an atom is dragged onto something (usr, over_object, src_location, over_location, over_control, params)
#define COMSIG_ATOM_MOUSEDROP "atom_mousedrop"
/// When something is dragged onto an atom (object, usr)
#define COMSIG_ATOM_MOUSEDROP_T "atom_mousedrop_t"
/// When the atom is a source of an explosion (object, args_to_explode_at)
#define COMSIG_ATOM_EXPLODE "atom_explode"
/// When the atom somewhere (possibly nested deep) in contents is a source of an explosion (object, args_to_explode_at)
#define COMSIG_ATOM_EXPLODE_INSIDE "atom_explode_inside"
/// When something enters the contents of this atom (i.e. Entered())
#define COMSIG_ATOM_ENTERED "atom_entered"

// ---- atom/movable signals ----

/// when an AM moves (thing, previous_loc, direction)
#define COMSIG_MOVABLE_MOVED "mov_moved"
/// when a movable is about to move, return true to prevent (thing, new_loc, direction)
#define COMSIG_MOVABLE_BLOCK_MOVE "mov_block_moved"
/// when an AM moves (thing, previous_loc)
#define COMSIG_MOVABLE_SET_LOC "mov_set_loc"
/// when an AM ends throw (thing, /datum/thrown_thing)
#define COMSIG_MOVABLE_THROW_END "mov_throw_end"
/// when an AM receives a packet (datum/signal/signal, receive_method, receive_param / range, connection_id)
#define COMSIG_MOVABLE_RECEIVE_PACKET "mov_receive_packet"
/// send this signal to send a radio packet (datum/signal/signal, receive_param / range, frequency), if frequency is null all registered frequencies are used
#define COMSIG_MOVABLE_POST_RADIO_PACKET "mov_post_radio_packet"
/// when the outermost movable in the .loc chain changes (thing, old_outermost_movable, new_outermost_movable)
#define XSIG_OUTERMOST_MOVABLE_CHANGED list(/datum/component/complexsignal/outermost_movable, "mov_outermost_changed")
/// when the z-level of a movable changes (works in nested contents) (thing, old_z_level, new_z_level)
#define XSIG_MOVABLE_Z_CHANGED list(/datum/component/complexsignal/outermost_movable, "mov_z-level_changed")
/// when an atom hits something when being thrown (thrown_atom, hit_target, /datum/thrown_thing)
#define COMSIG_MOVABLE_HIT_THROWN "mov_hit_thrown"

// ---- item signals ----

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
/// Just before an item is eaten
#define COMSIG_ITEM_CONSUMED_PRE "itm_atk_consumed_pre"
/// When an item is eaten
#define COMSIG_ITEM_CONSUMED "itm_atk_consumed"
/// After an item's been eaten, but there's still some left
#define COMSIG_ITEM_CONSUMED_PARTIAL "itm_atk_consumed_partial"
/// After we've consumed an item
#define COMSIG_ITEM_CONSUMED_ALL "itm_atk_consumed_all"
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

// ---- cloaking device signal ----
/// Make cloaking devices turn off
#define COMSIG_CLOAKING_DEVICE_DEACTIVATE "cloak_deactivate"

// ---- disguiser device signal ----
/// Make disguiser devices turn off
#define COMSIG_DISGUISER_DEACTIVATE "disguiser_deactivate"

// ---- drone beacon signal ----
/// Triggers on destruction of a drone beacon
#define COMSIG_DRONE_BEACON_DESTROYED "drone_beacon_destroyed"

// ---- bomb assembly signals ----
/// Triggers on the start of signalling the opening of an assembly bomb
#define COMSIG_BOMB_SIGNAL_START "bomb_signal_start"
/// Triggers when an assembly bomb's signalling is cancelled
#define COMSIG_BOMB_SIGNAL_CANCEL "bomb_signal_cancel"

// ---- implant signals ----
/// When implanted
#define COMSIG_IMPLANT_IMPLANTED "implant_implanted"
/// When removed
#define COMSIG_IMPLANT_REMOVED "implant_removed"

// ---- tooltip signals ----

/// Append to the end of the blocking section of tooltip (list/tooltip)
#define COMSIG_TOOLTIP_BLOCKING_APPEND "tooltip_block_append"

// ---- blocking signals ----

/// After  an item block is set up
#define COMSIG_ITEM_BLOCK_BEGIN "itm_block_begin"
/// When an item block is disposed
#define COMSIG_ITEM_BLOCK_END "itm_block_end"
/// After an unarmed block is set up
#define COMSIG_UNARMED_BLOCK_BEGIN "unarmed_block_begin"
/// When an item block is created
#define COMSIG_UNARMED_BLOCK_END "unarmed_block_end"
/// When a block blocks damage at all
#define COMSIG_BLOCK_BLOCKED "blockblock"
// ---- human signals ----

// ---- mob signals ----
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

#define COMSIG_MOB_PICKUP "mob_pickup"

#define COMSIG_MOB_DROPPED "mob_drop"

/// sent when a mob throws something (target, params)
#define COMSIG_MOB_THROW_ITEM "throw_item"

/// sent when a mob throws something that lands nearby
#define COMSIG_MOB_THROW_ITEM_NEARBY "throw_item_nearby"

/// sent when a mob sets their a_intent var (mob, intent)
#define COMSIG_MOB_SET_A_INTENT "mob_set_a_intent"

/// sent when radiation status ticks on mob (stage)
#define COMSIG_MOB_GEIGER_TICK "mob_geiger"

/// When the mob vomits
#define COMSIG_MOB_VOMIT "mob_vomit"

/// on mouseup
#define COMSIG_MOUSEUP "mouseup"

/// sent when defibbed status is added to a mob
#define COMSIG_MOB_SHOCKED_DEFIB "mob_shocked"
// ---- mob/living signals ----
/// When a Life tick occurs
#define COMSIG_LIVING_LIFE_TICK "human_life_tick"
// ---- atom property signals ----
/// When invisibility of a mob gets updated (old_value)
#define COMSIG_ATOM_PROP_MOB_INVISIBILITY "atom_prop_invis"

// ---- attack_X signals ----

/// Attacking with an item in-hand (item, attacker, params, is_special)
#define COMSIG_ATTACKBY "attackby"
/// Attacking without an item in-hand (attacker)
#define COMSIG_ATTACKHAND "attackhand"


// ---- projectile signals ----

/// After a projectile makes a valid hit on an atom (after immunity/other early returns, before other effects)
#define COMSIG_PROJ_COLLIDE "proj_collide_atom"

// ---- MechComp signals - Content signals - Use these in you MechComp compatible devices ----

/// Add an input chanel for a device to send into
#define COMSIG_MECHCOMP_ADD_INPUT "mechcomp_add_input"
/// Connect two mechcomp devices together
#define COMSIG_MECHCOMP_ADD_CONFIG "mechcomp_add_config"
/// Connect two mechcomp devices together
#define COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL "mechcomp_allow_manual_sigset"
/// Remove all connected devices
#define COMSIG_MECHCOMP_RM_ALL_CONNECTIONS "mechcomp_remove_all_connections"
/// Passing the signal of a message to all connected mechcomp devices for handling (message will be instatiated by the component)
#define COMSIG_MECHCOMP_TRANSMIT_SIGNAL "mechcomp_transmit_signal"
/// Passing a message to all connected mechcomp devices for handling
#define COMSIG_MECHCOMP_TRANSMIT_MSG "mechcomp_transmit_message"
/// Passing the stored message to all connected mechcomp devices for handling
#define COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG "mechcomp_transmit_default_message"

// ---- MechComp signals - Internal signals - Do not use these ----

/// Receiving a message from a mechcomp device for handling
#define _COMSIG_MECHCOMP_RECEIVE_MSG "_mechcomp_receive_message"
/// Remove {the caller} from the list of transmitting devices
#define _COMSIG_MECHCOMP_RM_INCOMING "_mechcomp_remove_incoming"
/// Remove {the caller} from the list of receiving devices
#define _COMSIG_MECHCOMP_RM_OUTGOING "_mechcomp_remove_outgoing"
/// Return the component's outgoing connections
#define _COMSIG_MECHCOMP_GET_OUTGOING "_mechcomp_get_outgoing_connections"
/// Return the component's incoming connections
#define _COMSIG_MECHCOMP_GET_INCOMING "_mechcomp_get_incoming_connections"
/// Begin to connect two mechcomp devices together
#define _COMSIG_MECHCOMP_DROPCONNECT "_mechcomp_drop_connect"
/// Connect one MechComp compatible device as a receiver to a trigger. (This is meant to be a private method)
#define _COMSIG_MECHCOMP_LINK "_mechcomp_link_devices"
/// Returns 1
#define _COMSIG_MECHCOMP_COMPATIBLE "_mechcomp_check_compatibility"

// ---- MechComp Dispatch signals - Niche signals - You probably don't want to use these. ----
/// Add a filtered connection, getting user input on the filter
#define _COMSIG_MECHCOMP_DISPATCH_ADD_FILTER "_mechcomp_dispatch_add_filter"
/// Remove a filtered connection
#define _COMSIG_MECHCOMP_DISPATCH_RM_OUTGOING "_mechcomp_dispatch_remove_filter"
/// Test a signal to be sent to a connection
#define _COMSIG_MECHCOMP_DISPATCH_VALIDATE "_mechcomp_dispatch_run_filter"


// ---- obj/critter signals ----

// When an obj/critter dies
#define COMSIG_OBJ_CRITTER_DEATH "obj_critter_death"

// ---- fullauto UI thingy signals ----
#define COMSIG_FULLAUTO_MOUSEDOWN "fullauto_mousedown"
#define COMSIG_FULLAUTO_MOUSEDRAG "fullauto_mousedrag"
#define COMSIG_GUN_PROJECTILE_CHANGED "gun_proj_changed"

// ---- small cell component signals ----
///When the cell in a uses_cell component should be swapped out (cell, user)
#define COMSIG_CELL_SWAP "cell_swap"
///When a cell is attacked, try to initiate a cellswap on the attacking obj (cell, user)
#define COMSIG_CELL_TRY_SWAP "cell_try_swap"
/// If an item can be charged
#define COMSIG_CELL_CAN_CHARGE "cell_can_charge"
/// Charge a small-cell (amount)
#define COMSIG_CELL_CHARGE "cell_charge"
/// Use some charge from a small-cell (amount, bypass)
#define COMSIG_CELL_USE "cell_use"
/// Check if thing is a power cell
#define COMSIG_CELL_IS_CELL "cell_is_cell"
/// Get the current charge and max charge of a power cell (list(charge)), or check if charge is higher than an amount (charge), or just check if there is a cell at all (null)
#define COMSIG_CELL_CHECK_CHARGE "cell_check_charge"
/// Force an update to the cellholder's cell. Takes an atom/movable that is a powercell, a powercell component, or a list of args for the powercell to inherit
#define COMSIG_CELL_FORCE_NEW_CELL "cell_force_new"

#define CELL_CHARGEABLE 1
#define CELL_UNCHARGEABLE 2
#define CELL_INSUFFICIENT_CHARGE 4
#define CELL_SUFFICIENT_CHARGE 8
#define CELL_RETURNED_LIST 16
#define CELL_FULL 32

// ---- obj/storage signals ----

/// When the storage closes
#define COMSIG_STORAGE_CLOSED "storage_closed"

// ---- area signals ----
/// area's active var set to true (when a client enters)
#define COMSIG_AREA_ACTIVATED "area_activated"
/// area's active var set to false (when all clients leave)
#define COMSIG_AREA_DEACTIVATED "area_deactivated"

// /datum/mind signals
/// when a mind attaches to a mob (mind, mob)
#define COMSIG_MIND_ATTACH_TO_MOB "mind_attach_to_mob"
/// when a mind detaches from a mob (mind, mob)
#define COMSIG_MIND_DETACH_FROM_MOB "mind_detach_from_mob"


#define COMSIG_SUSSY_PHRASE "sussy"

// ---- Transfer system ----
/// When a movable is requested to be transfered to the output target (/atom/movable/)
#define COMSIG_TRANSFER_INCOMING "incoming_tx"
/// When the target wants to send a movable to an output (/atom/movable/)
#define COMSIG_TRANSFER_OUTGOING "outgoing_tx"
/// Return whether the target should allow receiving items from the given atom (/atom)
#define COMSIG_TRANSFER_CAN_LINK "permit_tx"

// ---- ability signals ----
/// Send item to a mob
#define COMSIG_SEND_TO_MOB "send_to_mob"
