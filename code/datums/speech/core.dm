
var/global/datum/speech_manager/SpeechManager = new()

/// Global manager for speech systems. Used for module lookup, language lookup,
/datum/speech_manager
	var/list/accent_cache = list()
	var/list/modifier_cache = list()
	var/list/output_cache = list()
	var/list/language_cache = list()

	New()
		. = ..()
		//Populate module cache
		for (var/T in concrete_typesof(/datum/speech_module/accent))
			var/datum/speech_module/accent/acc_instance = new T()
			if(accent_cache[acc_instance.id])
				CRASH("Non unique accent found: [acc_instance.id]. These MUST be unique.")
			accent_cache[acc_instance.id] = acc_instance
		for (var/T in concrete_typesof(/datum/speech_module/modifier))
			var/datum/speech_module/modifier/mod_instance = new T()
			if(modifier_cache[mod_instance.id])
				CRASH("Non unique modifier found: [mod_instance.id]. These MUST be unique.")
			modifier_cache[mod_instance.id] = mod_instance
		for (var/T in concrete_typesof(/datum/speech_module/output))
			var/datum/speech_module/output/out_instance = new T()
			if(output_cache[out_instance.id])
				CRASH("Non unique output found: [out_instance.id]. These MUST be unique.")
			output_cache[out_instance.id] = out_instance

		//Populate language cache
		for (var/T in typesof(/datum/language))
			var/datum/language/L = new T()
			language_cache[L.id] = L

	proc/GetAccentInstance(var/accent_id)
		var/datum/speech_module/accent/result = src.accent_cache[accent_id]
		if(istype(result))
			return result
		else
			CRASH("Invalid accent lookup: [accent_id]")

	proc/GetModifierInstance(var/mod_id)
		var/datum/speech_module/modifier/result = src.modifier_cache[mod_id]
		if(istype(result))
			return result
		else
			CRASH("Invalid modifier lookup: [mod_id]")

	proc/GetOutputInstance(var/output_id)
		var/datum/speech_module/output/result = src.output_cache[output_id]
		if(istype(result))
			return result
		else
			CRASH("Invalid output lookup: [output_id]")


/// Message base class - once something has been passed to say(), it becomes this. Any and all metadata about the message should be stored here
/datum/say_message
	var/prefix = ""
	var/orig_message = ""
	var/atom/speaker = null
	var/datum/language/language = null
	var/content = ""
	var/flags = 0

	/// Create a new message datum with associated metadata, parsing and sanitization.
	New(var/message as text, var/atom/speaker, var/language_id = "english")
		. = ..()
		src.orig_message = message
		src.speaker = speaker

		/// first, grab the prefix if there is one
		var/cutpos = 0
		if ((length(message) >= 2) && (copytext(message,1,2) == ":"))
			cutpos = findtext(message, " ", 1)
			src.prefix = copytext(message, 1, cutpos) //get the prefix as :<prefix><first_space> - note prefix will be empty if the message only contains a radio prefix

		src.content = copytext(message, cutpos) //content now contains the message without the radio prefix
		src.content = make_safe_for_chat(src.content)

	proc/make_safe_for_chat(var/message as text)
		return message //TODO

/// The tree containing speech modules for the parent atom. All input goes through here.
/// Admittedly "tree" is a bit of a stretch, since only the outputs can branch, but :shrug:
/datum/speech_module_tree
	var/list/datum/speech_module/accent/accents
	var/list/datum/speech_module/modifier/speech_modifiers
	var/list/datum/speech_module/output/output_modules

	New(var/list/accents = list(), var/list/modifiers = list(), var/list/outputs = list("spoken"))
		. = ..()
		src.accents = list()
		src.speech_modifiers = list()
		src.output_modules = list()

		for(var/accent_id in accents)
			src.accents += global.SpeechManager.GetAccentInstance(accent_id)
		for(var/mod_id in modifiers)
			src.speech_modifiers += global.SpeechManager.GetModifierInstance(mod_id)
		for(var/out_id in outputs)
			src.output_modules += global.SpeechManager.GetOutputInstance(out_id)


	/// No return value is expected here
	proc/process(var/datum/say_message/message)
		if(!istype(message))
			CRASH("A non say_message thing was passed to a speech_module_tree. This should never happen.")
		for(var/datum/speech_module/module in src.accents)
			message = module.process(message)
			if(message == null)
				return //the module consumed the message, so process it no further

		for(var/datum/speech_module/module in src.speech_modifiers)
			message = module.process(message)
			if(message == null)
				return //the module consumed the message, so process it no further

		for(var/datum/speech_module/module in src.output_modules)
			module.process(message) //output modules always consume the message, there is no further processing required



ABSTRACT_TYPE(/datum/speech_module)
/// Base class for speech_modules - subclass this to create a modifier for messages
/datum/speech_module
	/// ID string for cache lookups. This is what your module is called, and it *MUST* be unique
	var/id = "abstract"
	/// How far up the tree this module should go. High values get processed before low values.
	var/priority = 0
	/// Return null to prevent the message being processed further, or a /datum/say_message
	proc/process(var/datum/say_message/message)
		return message


ABSTRACT_TYPE(/datum/speech_module/accent)
/datum/speech_module/accent
	id = "accent_base"

ABSTRACT_TYPE(/datum/speech_module/modifier)
/datum/speech_module/modifier
	id = "modifier_base"

ABSTRACT_TYPE(/datum/speech_module/output)
/datum/speech_module/output
	id = "output_base"
