/// Nothing Displayed
#define STATUS_DISPLAY_BLANK	0
/// Shuttle ETA/ETD/ETC timer
#define STATUS_DISPLAY_SHUTTLE	1
/// Custom text message
#define STATUS_DISPLAY_MESSAGE	2
/// Alert image
#define STATUS_DISPLAY_PICTURE	3
/// Shipping Market timer
#define STATUS_DISPLAY_MARKET	4
/// Zeta station self-destruct
#define STATUS_DISPLAY_SELFDES	5
/// Mining score (unimplemented)
#define STATUS_DISPLAY_ROCKBOX	6
/// Nuclear Operatives Nuke timer
#define STATUS_DISPLAY_NUCLEAR	7

/// Default status display message, dependent on type
#define STATUS_DISPLAY_PACKET_MODE_DISPLAY_DEFAULT "default"

/// Blank/NT Logo
#define STATUS_DISPLAY_PACKET_MODE_DISPLAY_BLANK "blank"

/// Shuttle ETA/ETD/ETC timer
#define STATUS_DISPLAY_PACKET_MODE_DISPLAY_SHUTTLE "shuttle"

/// Custom Text Message
#define STATUS_DISPLAY_PACKET_MODE_MESSAGE "message"
#define STATUS_DISPLAY_PACKET_MESSAGE_TEXT_1 "setmsg1"
#define STATUS_DISPLAY_PACKET_MESSAGE_TEXT_2 "setmsg2"

/// Shipping Market timer
#define STATUS_DISPLAY_PACKET_MODE_DISPLAY_MARKET "market"

/// Selectable images
#define STATUS_DISPLAY_PACKET_MODE_DISPLAY_ALERT "alert"
#define STATUS_DISPLAY_PACKET_ALERT_REDALERT "redalert"
#define STATUS_DISPLAY_PACKET_ALERT_LOCKDOWN "lockdown"
#define STATUS_DISPLAY_PACKET_ALERT_BIOHAZ "biohazard"

/// Zeta station self destruct
#define STATUS_DISPLAY_PACKET_MODE_DISPLAY_SELFDES "destruct"
/// Nuclear Operatives mode nuclear bomb timer
#define STATUS_DISPLAY_PACKET_MODE_DISPLAY_NUCLEAR "nuclear"
