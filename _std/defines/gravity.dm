
/// Minimum gravity to grant partial traction
#define TRACTION_GFORCE_PARTIAL 0.2
/// Minimum gravity to grant full traction
#define TRACTION_GFORCE_FULL 0.8

/// AM has no traction
#define TRACTION_NONE 0
/// AM has partial friction - mob force-moved until
#define TRACTION_PARTIAL 1
/// AM has full traction - mob not forced moved
#define TRACTION_FULL 2

// mob gravity thresholds
// arbitrary thresholds, allow for people to handle some minor gravity variance

/// minimum gravity for people to act as normal
#define GRAVITY_MOB_REGULAR_THRESHOLD 0.8
/// minimum gravity after which people feel heavier than normal
#define GRAVITY_MOB_HIGH_THRESHOLD 1.2
/// gravity after this level is considered extreme, with additional penalties to users
#define GRAVITY_MOB_EXTREME_THRESHOLD 2.4

#define GRAVITY_EFFECT_NONE 0
#define GRAVITY_EFFECT_LOW 1
#define GRAVITY_EFFECT_NORMAL 2
#define GRAVITY_EFFECT_HIGH 3
#define GRAVITY_EFFECT_EXTREME 4

#define GRAVITY_DESC_NONE "You feel floaty, but that's OK."
#define GRAVITY_DESC_LOW "You feel lighter than usual."
#define GRAVITY_DESC_NORMAL "You feel like you're on Earth."
#define GRAVITY_DESC_HIGH "You feel heavier than usual."
#define GRAVITY_DESC_EXTREME "You feel extremely heavy."
// gravity tethers

// balance defines
/// How much cable coil it takes to repair the tether wiring
#define TETHER_WIRE_REPAIR_CABLE_COST 5
/// How many rods to repair the tether tamper grate
#define TETHER_TAMPER_REPAIR_ROD_COST 5

// state tracking defines

// battery level charging states
#define TETHER_CHARGE_IDLE 0
#define TETHER_CHARGE_DRAINING 1
#define TETHER_CHARGE_CHARGING 2

// maintenance panel door states
#define TETHER_DOOR_OPEN 1
#define TETHER_DOOR_CLOSED 2
#define TETHER_DOOR_WELDED 3
#define TETHER_DOOR_MISSING 4

// wire panel behind the battery
#define TETHER_WIRES_INTACT 1
#define TETHER_WIRES_BURNED 2
#define TETHER_WIRES_CUT 3

#define TETHER_INTENSITY_MAX_DEFAULT 1.5
#define TETHER_INTENSITY_MAX_EMAG 4
