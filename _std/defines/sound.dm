//Reserved Area Ambience sound channels
#define SOUNDCHANNEL_LOOPING 123
#define SOUNDCHANNEL_FX_1 124
#define SOUNDCHANNEL_FX_2 125
#define SOUNDCHANNEL_RADIO 1013
#define SOUNDCHANNEL_ADMIN_LOW 1014 // lower end of the range of admin channels
#define SOUNDCHANNEL_ADMIN_HIGH 1024 // upper end

var/global/admin_sound_channel = SOUNDCHANNEL_ADMIN_LOW // current admin channel

//sound mute
#define SOUND_NONE 0
#define SOUND_SPEECH 1
#define SOUND_BLAH 2
#define SOUND_ALL 4
#define SOUND_VOX 8

//volume channel defines
#define VOLUME_CHANNEL_MASTER 0
#define VOLUME_CHANNEL_GAME 1
#define VOLUME_CHANNEL_AMBIENT 2
#define VOLUME_CHANNEL_RADIO 3
#define VOLUME_CHANNEL_ADMIN 4
#define VOLUME_CHANNEL_EMOTE 5
#define VOLUME_CHANNEL_MENTORPM 6

var/global/list/audio_channel_name_to_id = list(
	"master" = VOLUME_CHANNEL_MASTER,
	"game" = VOLUME_CHANNEL_GAME,
	"ambient" = VOLUME_CHANNEL_AMBIENT,
	"radio" = VOLUME_CHANNEL_RADIO,
	"admin" = VOLUME_CHANNEL_ADMIN,
	"emote" = VOLUME_CHANNEL_EMOTE,
	"mentorpm" = VOLUME_CHANNEL_MENTORPM
)

//Area Ambience
#define AMBIENCE_LOOPING 1
#define AMBIENCE_FX_1 2
#define AMBIENCE_FX_2 3

//playsound flags
#define SOUND_IGNORE_SPACE (1<<0)

#define MAX_SOUND_RANGE max_sound_range
#define MAX_SOUND_RANGE_NORMAL 33
#define MAX_SOUND_RANGE_OVERLOADED 23

/// the world gets split into a K-by-K grid and each tick each sound can only be played once in each big tile of this grid
#define SOUND_LIMITER_GRID_SIZE 3
