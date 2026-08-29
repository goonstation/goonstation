//Reserved Area Ambience sound channels
#define SOUNDCHANNEL_LOOPING 990
#define SOUNDCHANNEL_FX_1 991
#define SOUNDCHANNEL_FX_2 992

#define TOO_QUIET 0.9 //experimentally found to be 0.6 - raised due to lag, I don't care if it's super quiet because there's already shitloads of other sounds playing
#define SPACE_ATTEN_MIN 0.5
#define EARLY_RETURN_IF_QUIET(v) if (v < TOO_QUIET) return
#define EARLY_CONTINUE_IF_QUIET(v) if (v < TOO_QUIET) continue

#define SOURCE_ATTEN(A) do {\
	if (A <= SPACE_ATTEN_MIN){\
		vol *= SPACE_ATTEN_MIN;\
		extrarange = clamp(-MAX_SOUND_RANGE + MAX_SPACED_RANGE + extrarange, -32,-20);\
		spaced_source = 1;\
	}\
	else{\
		vol *= A\
	}\
} while(FALSE)

#define LISTENER_ATTEN(A) do {\
	if (A <= SPACE_ATTEN_MIN){\
		if (!spaced_source && dist >= MAX_SPACED_RANGE){\
			ourvolume = 0;\
		}\
		else{\
			spaced_env = 1;\
			ourvolume = clamp(ourvolume + 95, 25,200);\
		}\
	}\
	else{\
		ourvolume *= A\
	}\
} while(FALSE)

#define MAX_SPACED_RANGE 6 //diff range for when youre in a vaccuum
#define CLIENT_IGNORES_SOUND(C) (C?.ignore_sound_flags && ((ignore_flag && C.ignore_sound_flags & ignore_flag) || C.ignore_sound_flags & SOUND_ALL))

#define SOUNDIN_ID (istype(soundin, /sound) ? soundin:file : (islist(soundin) ? ref(soundin) : soundin))

/// First reserved BYOND channel for managed positional sounds.
#define SOUNDCHANNEL_MANAGED_POSITIONAL_LOW 901
/// Last reserved BYOND channel for managed positional sounds.
#define SOUNDCHANNEL_MANAGED_POSITIONAL_HIGH 989
/// Process scheduler cadence for managed positional sound updates.
#define MANAGED_POSITIONAL_SOUND_PROCESS_INTERVAL 1 DECI SECOND
/// Default maximum interval between managed positional sound updates.
#define MANAGED_POSITIONAL_SOUND_DEFAULT_UPDATE_INTERVAL 1 DECI SECOND
/// Minimum allowed interval between managed positional sound updates.
#define MANAGED_POSITIONAL_SOUND_MIN_UPDATE_INTERVAL 1 DECI SECOND
/// Shape scalar for managed positional distance falloff. Matches the legacy playsound() curve without changing playsound().
#define MANAGED_POSITIONAL_SOUND_FALLOFF_SHAPE 1.0542
/// Normalized distance where managed positional falloff drops most sharply.
#define MANAGED_POSITIONAL_SOUND_FALLOFF_MIDPOINT 0.18
/// Exponent for managed positional distance falloff.
#define MANAGED_POSITIONAL_SOUND_FALLOFF_EXPONENT -1.7
/// Fraction of a managed positional sound's range used to fade emitter blend weight near the edge.
#define MANAGED_POSITIONAL_SOUND_BLEND_EDGE_FRACTION 0.15
/// Minimum edge-fade width, in tiles, for managed positional sound emitter blending.
#define MANAGED_POSITIONAL_SOUND_BLEND_MIN_EDGE_WIDTH 3
/// Left/right intent scale for multi-emitter sounds, reducing perceived loudness differences caused by hard stereo pan.
/// Centered positional audio is perceptually louder than hard-panned audio, so grouped emitters use a narrower stereo field to mitigate.
#define MANAGED_POSITIONAL_SOUND_MULTI_EMITTER_PAN_SCALE 0.5
/// Explicit sound.pan units per tile of managed positional left/right intent. This is an output scale, not an adjacent-tile delta cap.
#define MANAGED_POSITIONAL_SOUND_EXPLICIT_PAN_PER_TILE 15
/// Maximum absolute explicit sound.pan sent by managed positional sounds.
#define MANAGED_POSITIONAL_SOUND_MAX_EXPLICIT_PAN 80

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
#define VOLUME_CHANNEL_INSTRUMENTS 7
#define VOLUME_CHANNEL_FARTS 8

var/global/list/audio_channel_name_to_id = list(
	"master" = VOLUME_CHANNEL_MASTER,
	"game" = VOLUME_CHANNEL_GAME,
	"ambient" = VOLUME_CHANNEL_AMBIENT,
	"radio" = VOLUME_CHANNEL_RADIO,
	"admin" = VOLUME_CHANNEL_ADMIN,
	"emote" = VOLUME_CHANNEL_EMOTE,
	"mentorpm" = VOLUME_CHANNEL_MENTORPM,
	"instruments" = VOLUME_CHANNEL_INSTRUMENTS,
	"farts" = VOLUME_CHANNEL_FARTS,
)

//Area Ambience
#define AMBIENCE_LOOPING 1
#define AMBIENCE_FX_1 2
#define AMBIENCE_FX_2 3

//playsound flags
#define SOUND_IGNORE_SPACE (1<<0)
#define SOUND_SKIP_OBSERVERS (1<<1) //! Only applies to local playsound(s)
#define SOUND_IGNORE_DEAF (1<<2) //! No you can't ignore admin PMs because you lost your auditory headset
#define SOUND_DO_LOS (1<<3) //makes any opaque object totally occlude the sound, use sparingly and only for "sneaky" sounds

#define MAX_SOUND_RANGE max_sound_range
#define MAX_SOUND_RANGE_NORMAL 33
#define MAX_SOUND_RANGE_OVERLOADED 23

/// the world gets split into a K-by-K grid and each tick each sound can only be played once in each big tile of this grid
#define SOUND_LIMITER_GRID_SIZE 3

///how loud are dectalk bots
#define BOTTALK_VOLUME 33
