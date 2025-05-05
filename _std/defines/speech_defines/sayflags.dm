//------------ Message Modifier Flags ------------//
/// This message should be formatted as an admin message. Message modifier flag.
#define SAYFLAG_ADMIN_MESSAGE (1 << 0)
/// This message should be displayed with quotation marks. Message modifier flag.
#define SAYFLAG_HAS_QUOTATION_MARKS (1 << 1)
/// This message should be displayed without a say verb. Message modifier flag.
#define SAYFLAG_NO_SAY_VERB (1 << 2)
/// This message should be sung. Message modifier flag.
#define SAYFLAG_SINGING (1 << 3)
/// This message should be whispered. Message modifier flag.
#define SAYFLAG_WHISPER (1 << 4)


//------------ Ordinary Sayflags ------------//
/// This message has been sung, loudly.
#define SAYFLAG_LOUD_SINGING (1 << 5)
/// This message has been sung, softly.
#define SAYFLAG_SOFT_SINGING (1 << 6)
/// This message has been sung, poorly.
#define SAYFLAG_BAD_SINGING (1 << 7)
/// This message should not receive maptext.
#define SAYFLAG_NO_MAPTEXT (1 << 8)
/// This message should not be whispered if the speaker is out of breath.
#define SAYFLAG_IGNORE_STAMINA (1 << 9)
/// This message should not be displayed with location text if it is inside of something.
#define SAYFLAG_IGNORE_POSITION (1 << 10)
/// This message should not remove HTML tags from its content. Do not apply this to any message where a player may control the input, lest you permit HTML injection.
#define SAYFLAG_IGNORE_HTML (1 << 11)
/// This message was spoken by a player controlled mob through the player's input.
#define SAYFLAG_SPOKEN_BY_PLAYER (1 << 12)
/// This message should not be sent to delimited channels' global channels.
#define SAYFLAG_DELIMITED_CHANNEL_ONLY (1 << 13)
/// This message has had its prefix processed by a speech module tree.
#define SAYFLAG_PREFIX_PROCESSED (1 << 14)
/// This message should not be passed to an output module.
#define SAYFLAG_DO_NOT_OUTPUT (1 << 15)
/// This message should not be passed to a tree's message importing trees.
#define SAYFLAG_DO_NOT_PASS_TO_IMPORTING_TREES (1 << 16)
