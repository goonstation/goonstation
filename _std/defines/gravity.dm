/// Minimum g-force to grant partial traction
#define GFORCE_TRACTION_PARTIAL 0.2
/// Minimum g-force to grant full traction
#define GFORCE_TRACTION_FULL 0.8

/// AM has no traction
#define TRACTION_NONE 0
/// AM has partial friction - mob force-moved until it settles
#define TRACTION_PARTIAL 1
/// AM has full traction - mob not forced moved
#define TRACTION_FULL 2

// mob gravity thresholds; arbitrary, allow for people to handle some minor gravity variance
/// minimum gravity for people to act as normal
#define GRAVITY_MOB_REGULAR_THRESHOLD 0.8
/// minimum gravity after which people feel heavier than normal
#define GRAVITY_MOB_HIGH_THRESHOLD 1.2
/// gravity after this level is considered extreme, with additional effects
#define GRAVITY_MOB_EXTREME_THRESHOLD 2.4

// For consistent tooltips between HUD types
#define GRAVITY_DESC_NONE "You feel floaty, but that's OK."
#define GRAVITY_DESC_LOW "You feel lighter than usual."
#define GRAVITY_DESC_NORMAL "You feel like you're on Earth."
#define GRAVITY_DESC_HIGH "You feel heavier than usual."
#define GRAVITY_DESC_EXTREME "You feel extremely heavy."

// event subtypes
#define GRAVITY_EVENT_DISRUPT "disrupt"
#define GRAVITY_EVENT_CHANGE "change"

/// Time between the player starting the change and the change starting
#define TETHER_BEGIN_DELAY (30 SECONDS)
/// Time after the change is complete before another change can be started
#define TETHER_CHANGE_COOLDOWN (30 SECONDS)
/// Time the disturbance timer lasts when triggered
#define TETHER_DISTURBANCE_TIMER (60 SECONDS)

// battery level charging states
#define TETHER_CHARGE_IDLE 0
#define TETHER_CHARGE_DRAINING 1
#define TETHER_CHARGE_CHARGING 2

// battery charge level thresholds
#define TETHER_BATTERY_CHARGE_LOW 0
#define TETHER_BATTERY_CHARGE_MEDIUM 30
#define TETHER_BATTERY_CHARGE_HIGH 60
#define TETHER_BATTERY_CHARGE_FULL 95

// maintenance panel door states
#define TETHER_DOOR_OPEN 1
#define TETHER_DOOR_CLOSED 2
#define TETHER_DOOR_WELDED 3
#define TETHER_DOOR_MISSING 4

// wire panel behind the battery
#define TETHER_WIRES_INTACT 1
#define TETHER_WIRES_BURNED 2
#define TETHER_WIRES_CUT 3

// max gforce intensity levels
#define TETHER_INTENSITY_MAX_DEFAULT 2
#define TETHER_INTENSITY_MAX_EMAG 4

// processing / ready to change
#define TETHER_PROCESSING_STABLE 0
#define TETHER_PROCESSING_PENDING 1
#define TETHER_PROCESSING_COOLDOWN 2
