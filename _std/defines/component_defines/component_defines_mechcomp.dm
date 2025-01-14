// Mechcomp signals. Nothin more, nothing less.


// ---- Content signals - Use these in you MechComp compatible devices ----

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
/// Create a new signal like above with a tagged mechcomp signal
#define COMSIG_MECHCOMP_TRANSMIT_SIGNAL_TAGGED "mechcomp_transmit_signal_tagged"
/// Passing a message to all connected mechcomp devices for handling
#define COMSIG_MECHCOMP_TRANSMIT_MSG "mechcomp_transmit_message"
/// Passing the stored message to all connected mechcomp devices for handling
#define COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG "mechcomp_transmit_default_message"

// ---- Dispatch signals - Niche signals - You probably don't want to use these. ----

/// Add a filtered connection, getting user input on the filter
#define _COMSIG_MECHCOMP_DISPATCH_ADD_FILTER "_mechcomp_dispatch_add_filter"
/// Remove a filtered connection
#define _COMSIG_MECHCOMP_DISPATCH_RM_OUTGOING "_mechcomp_dispatch_remove_filter"
/// Test a signal to be sent to a connection
#define _COMSIG_MECHCOMP_DISPATCH_VALIDATE "_mechcomp_dispatch_run_filter"

// ---- Internal signals - DO NOT USE THESE ----

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
