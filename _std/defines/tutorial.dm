/// How long before auto-continuing for timed steps. Matches the related tutorial timer animation duration.
#define NEWBEE_TUTORIAL_TIMER_DURATION 14 SECONDS

// Marker Overlays

/// A large target marker, good for turfs
#define NEWBEE_TUTORIAL_MARKER_TARGET_GROUND "target_ground"
/// A point marker, good for items
#define NEWBEE_TUTORIAL_MARKER_TARGET_POINT "target_point"
/// Highlights an inventory slot
#define NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY "inventory"
/// Highlights the Help intent
#define NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HELP "intent_help"
/// Highlights the Disarm intent
#define NEWBEE_TUTORIAL_MARKER_HUD_INTENT_DISARM "intent_disarm"
/// Highlights the Grab intent
#define NEWBEE_TUTORIAL_MARKER_HUD_INTENT_GRAB "intent_grab"
/// Highlights the Harm intent
#define NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HARM "intent_harm"
/// Highlights the lower half of a HUD element
#define NEWBEE_TUTORIAL_MARKER_HUD_LOWER_HALF "lower_half"
/// Highlights the upper half of a HUD element
#define NEWBEE_TUTORIAL_MARKER_HUD_UPPER_HALF "upper_half"
/// Toggle ability button in HUD
#define NEWBEE_TUTORIAL_MARKER_HUD_ABILITY "ability"
/// Stats button in HUD
#define NEWBEE_TUTORIAL_MARKER_HUD_STATS "stats"

// Sidebar types

/// Empty sidebar with no content
#define NEWBEE_TUTORIAL_SIDEBAR_EMPTY "empty"
/// Movement keybinds
#define NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT "movement"
/// Item keybinds
#define NEWBEE_TUTORIAL_SIDEBAR_ITEMS "items"
/// Intent keybinds
#define NEWBEE_TUTORIAL_SIDEBAR_INTENTS "intents"
/// actions like rest and sprint
#define NEWBEE_TUTORIAL_SIDEBAR_ACTIONS "actions"
/// talking and radio
#define NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION "communication"
/// modifiers like examine and pull
#define NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS "modifiers"
/// health
#define NEWBEE_TUTORIAL_SIDEBAR_HEALTH "health"
/// meta ahelp/mhelp/looc
#define NEWBEE_TUTORIAL_SIDEBAR_META "meta"

// used for tutorial maptext, as we can't use existing browseroutput classes

#define TEXT_INTENT_HELP "<span style='color:#349E00'>Help</span>"
#define TEXT_INTENT_DISARM "<span style='color:#EAC300'>Disarm</span>"
#define TEXT_INTENT_GRAB "<span style='color:#FF6A00'>Grab</span>"
#define TEXT_INTENT_HARM "<span style='color:#B51214'>Harm</span>"

#define TEXT_HEALTH_OXY "<span style='color:#1F75D1'>Oxygen</span>"
#define TEXT_HEALTH_TOXIN "<span style='color:#138015'>Toxin</span>"
#define TEXT_HEALTH_BURN "<span style='color:#CC7A1D'>Burn</span>"
#define TEXT_HEALTH_BRUTE "<span style='color:#E60E4E'>Brute</span>"
