//------------ Say Channels ------------//
#define SAY_CHANNEL_BLOB "blob"
#define SAY_CHANNEL_DEAD "deadchat"
#define SAY_CHANNEL_GHOSTLY_WHISPER "ghostly_whisper"
#define SAY_CHANNEL_EQUIPPED "equipped"
#define SAY_CHANNEL_FLOCK "flock"
#define SAY_CHANNEL_GLOBAL_FLOCK "global_flock"
#define SAY_CHANNEL_DISTORTED_FLOCK "distorted_flock"
#define SAY_CHANNEL_GHOSTDRONE "ghostdrone"
#define SAY_CHANNEL_HIVEMIND "hivemind"
#define SAY_CHANNEL_GLOBAL_HIVEMIND "global_hivemind"
#define SAY_CHANNEL_OUTLOUD "outloud"
#define SAY_CHANNEL_GLOBAL_OUTLOUD "global_outloud"
#define SAY_CHANNEL_LOOC "looc"
#define SAY_CHANNEL_GLOBAL_LOOC "global_looc"
#define SAY_CHANNEL_MARTIAN "martian"
#define SAY_CHANNEL_OOC "ooc"
#define SAY_CHANNEL_GLOBAL_RADIO "global_radio"
#define SAY_CHANNEL_SILICON "silicon"
#define SAY_CHANNEL_THRALL "thrall"
#define SAY_CHANNEL_GLOBAL_THRALL "global_thrall"
#define SAY_CHANNEL_KUDZU "kudzu"

//------------ Static Channel Prefixes ------------//
/// A list of channel prefixes that will always correspond to a specific say channel regardless of context.
var/list/static_channel_prefixes = list(
	":ooc" = SAY_CHANNEL_OOC,
	":looc" = SAY_CHANNEL_LOOC,
	":s" = SAY_CHANNEL_SILICON,
)

