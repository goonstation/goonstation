// Inbound signals from other phones
#define COMSIG_PHONE_INBOUND_CONNECTION "phone_inbound_connection"
#define COMSIG_PHONE_INBOUND_SPEECH "phone_inbound_speech"
#define COMSIG_PHONE_INBOUND_SOUND "phone_inbound_sound"
#define COMSIG_PHONE_INBOUND_VAPE "phone_inbound_vape"
#define COMSIG_PHONE_INBOUND_VOLTRON "phone_inbound_voltron"
#define COMSIG_PHONE_INBOUND_DISCONNECTION "phone_inbound_disconnection"

// Outbound signals we intend to send to other phones
#define COMSIG_PHONE_OUTBOUND_CONNECTION "phone_outbound_connection"
#define COMSIG_PHONE_OUTBOUND_SPEECH "phone_outbound_speech"
#define COMSIG_PHONE_OUTBOUND_SOUND "phone_outbound_sound"
#define COMSIG_PHONE_OUTBOUND_VAPE "phone_outbound_vape"
#define COMSIG_PHONE_OUTBOUND_VOLTRON "phone_outbound_voltron"
#define COMSIG_PHONE_OUTBOUND_DISCONNECTION "phone_outbound_disconnection"

// Various control signals
#define COMSIG_PHONE_SPEAKER_ENABLE "phone_speaker_enable"
#define COMSIG_PHONE_SPEAKER_DISABLE "phone_speaker_disable"
#define COMSIG_PHONE_MICROPHONE_ENABLE "phone_microphone_enable"
#define COMSIG_PHONE_MICROPHONE_DISABLE "phone_microphone_disable"
#define COMSIG_PHONE_RING_START "phone_ring_start"
#define COMSIG_PHONE_RING_STOP "phone_ring_stop"
#define COMSIG_PHONE_ANSWER "phone_answer"
#define COMSIG_PHONE_HANGUP "phone_hangup"
#define COMSIG_PHONE_RING_TICK "phone_ring_tick"
#define COMSIG_PHONE_UI_CLOSE "phone_ui_close"
// Return either as TRUE to block the connection
#define COMSIG_PHONE_INBOUND_CONNECTION_CHECK "phone_inbound_connection_check"
#define COMSIG_PHONE_OUTBOUND_CONNECTION_CHECK "phone_outbound_connection_check"

// Variables/indexes for PHONE.directory
#define PHONE_NAME "name"
#define PHONE_CATEGORY "category"
#define PHONE_COLOR "color"
#define PHONE_CAN_Z "can_z"
#define PHONE_UNLISTED "unlisted"
#define PHONE_NETWORKS "networks"
#define PHONE_Z_LEVEL "z_level"
#define PHONE_PARENT "parent"

// User inputs
#define COMSIG_PHONE_SPEECH_TREE_INPUT "phone_speech_tree_input"
#define COMSIG_PHONE_ATTEMPT_VOLTRON "phone_attempt_voltron"
#define COMSIG_PHONE_ATTEMPT_VAPE "phone_attempt_vape"
#define COMSIG_PHONE_EMAG "phone_emag"
#define COMSIG_PHONE_UI_INTERACT "phone_ui_interact"

// Informational signals
#define COMSIG_PHONE_GET_Z "phone_get_z" // REMOVE
#define COMSIG_PHONE_CHECK_CONNECTED "phone_check_connected"
#define COMSIG_PHONE_RETRIEVE_PREFIX "phone_retrieve_prefix"
#define COMSIG_PHONE_INFO_UPDATED "phone_info_updated"
#define COMSIG_PHONE_GET_PHONEBOOK "phone_get_phonebook"
#define COMSIG_PHONE_GET_NAME "phone_get_name"

// Return signals/bitfields. Not always used, blame Nex for his inconsistency
// 2<<0 (1) reserved for simple boolean returns
#define PHONE_FAILED (2<<1)
#define PHONE_ACCEPTED (2<<2)

// Phone network bitflags. You may safely add a new one if you need it. Until we reach 32 of them, anyways.
#define PHONE_NET_STATION (2<<0)
#define PHONE_NET_SECURITY (2<<1) // currently unused, intended for ankle monitors
