/// Whether this message can be replayed through the specified relay type.
#define CAN_RELAY_MESSAGE(message, relay_flag) (message.can_relay && !(message.relay_flags & relay_flag))
/// Flags a message as having been retransmitted through a relay of the specified type.
#define FORMAT_MESSAGE_FOR_RELAY(message, relay_flag) \
	message.relay_flags |= relay_flag; \
	message.flags &= ~SAYFLAG_SPOKEN_BY_PLAYER; \
	message.id = "\ref[message]";


//------------ Relay Types ------------//
#define SAY_RELAY_MICROPHONE (1 << 0)
#define SAY_RELAY_PHONE (1 << 1)
#define SAY_RELAY_RADIO (1 << 2)
