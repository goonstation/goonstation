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
#define COMSIG_PHONE_SPEECH_TREE_INPUT "phone_speech_tree_input"

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
#define COMSIG_PHONE_INBOUND_CONNECTION_OBJECTION_CHECK "phone_inbound_connection_objection_check"
#define COMSIG_PHONE_OUTBOUND_CONNECTION_OBJECTION_CHECK "phone_outbound_connection_objection_check"
#define COMSIG_PHONE_UI_INTERACT "phone_ui_interact"
#define COMSIG_PHONE_UI_CLOSE "phone_ui_close"
#define COMSIG_PHONE_SET_INFO "phone_set_info"
#define COMSIG_PHONE_SET_UNLISTED "phone_set_unlisted"
#define COMSIG_PHONE_SET_CAN_Z "phone_set_can_z"

// Informational signals
#define COMSIG_PHONE_CHECK_Z "phone_check_Z"
#define COMSIG_PHONE_CHECK_CONNECTED "phone_check_connected"
#define COMSIG_PHONE_RETRIEVE_PREFIX "phone_retrieve_prefix"
#define COMSIG_PHONE_INFO_UPDATED "phone_info_updated"

// misc
#define COMSIG_PHONE_ATTEMPT_VOLTRON "phone_attempt_voltron"
#define COMSIG_PHONE_ATTEMPT_VAPE "phone_attempt_vape"
#define COMSIG_PHONE_EMAG "phone_emag"


// Return signals/bitfields. Not always used, blame Nex for his inconsistency
// 2<<0 (1) reserved for simple boolean returns
#define PHONE_FAILED (2<<1)
#define PHONE_REJECTED (2<<2)
#define PHONE_ACCEPTED (2<<3)
