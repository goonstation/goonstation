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


//------------ Regex ------------//
/// Characters to remove from the contents of all say message datums.
var/regex/forbidden_character_regex = regex(@"[\u2028\u202a\u202b\u202c\u202d\u202e]", "g")
/// Selects any mutable tags present in a string.
var/regex/mutable_tags_regex = regex(@"(\<\/?mutable\>)", "g")
/// Strips mutable tags from a string.
#define STRIP_MUTABLE_CONTENT_TAGS(CONTENT) global.mutable_tags_regex.Replace(CONTENT, "")
/// Selects the immutable content from a string, alongside mutable tags.
var/regex/immutable_content_regex = regex(@"<\/mutable>.*?<mutable>|<mutable>|<\/mutable>", "g")
/// Strips immutable tags and content from a string.
#define STRIP_IMMUTABLE_CONTENT(CONTENT) global.immutable_content_regex.Replace(CONTENT, "")
/// Selects all the HTML tags present in a string.
var/regex/html_tags_regex = regex(@"(\<.*?\>)", "g")
/// Ensures that all the HTML tags in a string are outside of mutable content tags.
#define MAKE_HTML_TAGS_IMMUTABLE(CONTENT) global.html_tags_regex.Replace(CONTENT, "</mutable>$0<mutable>")
/// Selects the mutable content from a string.
var/regex/mutable_content_regex = regex(@"(?<=\<mutable\>).*?(?=\<\/mutable\>)", "g")
/// Ensures that the content of a string is mutable.
#define MAKE_CONTENT_MUTABLE(CONTENT) "<mutable>[CONTENT]</mutable>"
/// Ensures that the content of a string is immutable.
#define MAKE_CONTENT_IMMUTABLE(CONTENT) "</mutable>[CONTENT]<mutable>"
/// Applies a proc to the mutable content of a say message datum in the form of a callback.
#define APPLY_CALLBACK_TO_MESSAGE_CONTENT(_MESSAGE, _CALLBACK) _MESSAGE.content = global.mutable_content_regex.ReplaceWithCallback(_MESSAGE.content, _CALLBACK)


//------------ Other ------------//
#define NO_MESSAGE null
#define NO_SAY_SOUND ""
