// Component defines which don't fit into any of the other files- maybe for interfacing with a specific component or system, maybe applied to a wide variety of specific types, maybe UI stuff.


// ---- blocking signals ----

	/// After  an item block is set up
	#define COMSIG_ITEM_BLOCK_BEGIN "itm_block_begin"
	/// When an item block is disposed
	#define COMSIG_ITEM_BLOCK_END "itm_block_end"
	/// Append to the end of the blocking section of tooltip (list/tooltip)
	#define COMSIG_ITEM_BLOCK_TOOLTIP_BLOCKING_APPEND "tooltip_block_append"
	/// After an unarmed block is set up
	#define COMSIG_UNARMED_BLOCK_BEGIN "unarmed_block_begin"
	/// When an item block is created
	#define COMSIG_UNARMED_BLOCK_END "unarmed_block_end"
	/// When a block blocks damage at all
	#define COMSIG_BLOCK_BLOCKED "blockblock"


// ---- drone beacon signal ----

	/// Triggers on destruction of a drone beacon
	#define COMSIG_DRONE_BEACON_DESTROYED "drone_beacon_destroyed"

// ---- fullauto signals ----

	/// Mouse down while shooting full auto
	#define COMSIG_FULLAUTO_MOUSEDOWN "fullauto_mousedown"
	/// Mouse down when shooting full auto
	#define COMSIG_FULLAUTO_MOUSEDRAG "fullauto_mousedrag"
	/// MouseMove over a fullauto hud object
	#define COMSIG_FULLAUTO_MOUSEMOVE "fullauto_mousemove"
	/// Gun projectile changed while in fullauto mode
	#define COMSIG_GUN_PROJECTILE_CHANGED "gun_proj_changed"

// ---- small cell stuff ----

	// ---- signals ----
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

	// ---- bitflags returned from sending COMSIG_CHECK_CELL_CHARGE
		/// Cell can be charged in a recharger
		#define CELL_CHARGEABLE 1
		/// Cell cannot be charged in a recharger
		#define CELL_UNCHARGEABLE 2
		/// Cell has insufficient charge to do the requested action
		#define CELL_INSUFFICIENT_CHARGE 4
		/// Cell has sufficient charge to do the requested action
		#define CELL_SUFFICIENT_CHARGE 8
		/// Returned an assoc list
		#define CELL_RETURNED_LIST 16
		/// Cell is fully charged
		#define CELL_FULL 32

// ---- energy shield thing ----
	/// Sent by the itemability to toggle the energyshield component
	#define COMSIG_SHIELD_TOGGLE "energy_shield_toggle"

// ---- atom property signals ----

	/// When invisibility of a mob gets updated (old_value)
	#define COMSIG_ATOM_PROP_MOB_INVISIBILITY "atom_prop_invis"


// ---- ability signals ----

	/// Send item to a mob
	#define COMSIG_SEND_TO_MOB "send_to_mob"


// ---- Transfer system ----

	/// When a movable is requested to be transfered to the output target (/atom/movable/)
	#define COMSIG_TRANSFER_INCOMING "incoming_tx"
	/// When the target wants to send a movable to an output (/atom/movable/)
	#define COMSIG_TRANSFER_OUTGOING "outgoing_tx"
	/// Return whether the target should allow receiving items from the given atom (/atom)
	#define COMSIG_TRANSFER_CAN_LINK "permit_tx"

// ---- Flockmind ----

	/// Return whether an action by a thing (/atom) that can optionally be intentional (boolean) is denied because it would harm a flock.
	#define COMSIG_FLOCK_ATTACK "flock_attack"

// ---- Dock Signals and Events ----
// Docks are categorized by the shuttle that uses them. Docks are not interchangable.
// Registered listeners recieve a signal for each shuttle state change.
// When handling the signal, the provided argument will match a dock event define.

	// ---- Dock Events ----
		/// Shuttle is about to arrive at a dock
		#define DOCK_EVENT_INCOMING "dock_incoming"

		/// Shuttle has arrived
		#define DOCK_EVENT_ARRIVED "dock_arrived"

		/// Shuttle is about to depart
		#define DOCK_EVENT_OUTGOING "dock_outgoing"

		/// Shuttle has departed
		#define DOCK_EVENT_DEPARTED "dock_departed"

	// ---- "Travelling Trader" random event docks ----
		/// The 'left' trading area on-station
		#define COMSIG_DOCK_TRADER_WEST "trader_left"

		/// The 'right' trading area on-station
		#define COMSIG_DOCK_TRADER_EAST "trader_right"

		/// The diner trading area
		#define COMSIG_DOCK_TRADER_DINER "trader_diner"



// ---- Light stuff, used by /datum/component/loctargeting/simple_light, .../sm_light, and .../medium_light ----
/// Send to a thing to enable component lights on it
#define COMSIG_LIGHT_ENABLE "enable_light"
/// Send to a thing to disable component lights on it
#define COMSIG_LIGHT_DISABLE "disable_light"
