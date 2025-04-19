//------------ Wrappers ------------//
/// A wrapper for _AddSpeechOutput that permits the usage of named arguments.
#define AddSpeechOutput(output_id, arguments...) _AddSpeechOutput(output_id, list(##arguments))
/// A wrapper for _AddSpeechModifier that permits the usage of named arguments.
#define AddSpeechModifier(modifier_id, arguments...) _AddSpeechModifier(modifier_id, list(##arguments))
/// A wrapper for _AddSpeechPrefix that permits the usage of named arguments.
#define AddSpeechPrefix(prefix_id, arguments...) _AddSpeechPrefix(prefix_id, list(##arguments))
/// A wrapper for _AddListenInput that permits the usage of named arguments.
#define AddListenInput(input_id, arguments...) _AddListenInput(input_id, list(##arguments))
/// A wrapper for _AddListenModifier that permits the usage of named arguments.
#define AddListenModifier(modifier_id, arguments...) _AddListenModifier(modifier_id, list(##arguments))
/// A wrapper for _AddListenEffect that permits the usage of named arguments.
#define AddListenEffect(effect_id, arguments...) _AddListenEffect(effect_id, list(##arguments))
/// A wrapper for _AddListenControl that permits the usage of named arguments.
#define AddListenControl(control_id, arguments...) _AddListenControl(control_id, list(##arguments))


//------------ Cooldowns ------------//
/// The minimum time between voice sound effects for a single atom. Measured in tenths of a second.
#define VOICE_SOUND_COOLDOWN 8
/// The minimum time between playing the cluwne laugh for atoms affacted by it. Measured in tenths of a second.
#define CLUWNE_NOISE_COOLDOWN 50


//------------ Message Ranges ------------//
/// The maximum distance from which standard spoken messages may be heard.
#define DEFAULT_HEARING_RANGE 7
/// The maximum distance from which whispered messages may be clearly heard.
#define WHISPER_RANGE 1
/// The maximum distance from which whispered messages may be heard, albeit distorted.
#define WHISPER_EAVESDROPPING_RANGE 2
/// The maximum distance from which LOOC messages may be heard.
#define LOOC_RANGE 8


//------------ Other ------------//
#define NO_MESSAGE null
