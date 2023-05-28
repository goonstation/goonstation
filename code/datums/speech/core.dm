
var/global/datum/speech_manager/SpeechManager = new()

/// Global manager for speech systems. Used for module lookup, language lookup,
/datum/speech_manager

	VAR_PRIVATE/list/accent_cache = list()
	VAR_PRIVATE/list/modifier_cache = list()
	VAR_PRIVATE/list/output_cache = list()
	VAR_PRIVATE/list/input_cache = list()
	VAR_PRIVATE/list/listen_mod_cache = list()

	VAR_PRIVATE/list/language_cache = list()

	/// List of channel listeners to everyone that has requested to hear messages, keys are channels
	VAR_PRIVATE/list/list/datum/listen_module/input/listeners = list()

	New()
		. = ..()
		//Populate module cache
		for (var/T in concrete_typesof(/datum/speech_module/accent))
			var/typeinfo/datum/speech_module/accent/acc_info = get_type_typeinfo(T)
			if(accent_cache[acc_info.id])
				CRASH("Non unique accent found: [acc_info.id]. These MUST be unique.")
			accent_cache[acc_info.id] = T

		for (var/T in concrete_typesof(/datum/speech_module/modifier))
			var/typeinfo/datum/speech_module/modifier/mod_info = get_type_typeinfo(T)
			if(modifier_cache[mod_info.id])
				CRASH("Non unique modifier found: [mod_info.id]. These MUST be unique.")
			modifier_cache[mod_info.id] = T

		for (var/T in concrete_typesof(/datum/speech_module/output))
			var/typeinfo/datum/speech_module/output/out_info = get_type_typeinfo(T)
			if(output_cache[out_info.id])
				CRASH("Non unique output found: [out_info.id]. These MUST be unique.")
			output_cache[out_info.id] = T

		for (var/T in concrete_typesof(/datum/listen_module/input))
			var/typeinfo/datum/listen_module/input/in_info = get_type_typeinfo(T)
			if(input_cache[in_info.id])
				CRASH("Non unique input found: [in_info.id]. These MUST be unique.")
			input_cache[in_info.id] = T

		for (var/T in concrete_typesof(/datum/listen_module/modifier))
			var/typeinfo/datum/listen_module/modifier/mod_info = get_type_typeinfo(T)
			if(listen_mod_cache[mod_info.id])
				CRASH("Non unique listen modifer found: [mod_info.id]. These MUST be unique.")
			listen_mod_cache[mod_info.id] = T

		//Populate language cache - these are singletons, but the modules aren't
		for (var/T in typesof(/datum/language))
			var/datum/language/L = new T()
			language_cache[L.id] = L

	/// Returns a unique instance of the speech module requested, or runtimes on bad id
	proc/GetAccentInstance(var/accent_id)
		var/result = src.accent_cache[accent_id]
		if(result)
			return new result()
		else
			CRASH("Invalid accent lookup: [accent_id]")

	/// Returns a unique instance of the speech module requested, or runtimes on bad id
	proc/GetModifierInstance(var/mod_id)
		var/result = src.modifier_cache[mod_id]
		if(result)
			return new result()
		else
			CRASH("Invalid modifier lookup: [mod_id]")

	/// Returns a unique instance of the speech module requested, or runtimes on bad id
	proc/GetOutputInstance(var/output_id)
		var/result = src.output_cache[output_id]
		if(result)
			return new result()
		else
			CRASH("Invalid output lookup: [output_id]")

	/// Returns a unique instance of the input module requested, or runtimes on bad id
	proc/GetInputInstance(var/input_id, var/datum/listen_module_tree/parent)
		var/result = src.input_cache[input_id]
		if(result)
			return new result(parent)
		else
			CRASH("Invalid input lookup: [input_id]")

	/// Returns a unique instance of the listen module requested, or runtimes on bad id
	proc/GetListenModifierInstance(var/mod_id)
		var/result = src.listen_mod_cache[mod_id]
		if(result)
			return new result()
		else
			CRASH("Invalid listen modifier lookup: [mod_id]")

	/// Returns the global instance of the language datum corresponding to the id given, or runtimes on bad language id.
	proc/GetLanguageInstance(var/lang_id)
		var/datum/language/result = src.language_cache[lang_id]
		if(istype(result))
			return result
		else
			CRASH("Invalid language lookup: [lang_id]")

	/// Pass a message from an output module to the listeners on that channel
	proc/PassToListeners(var/datum/say_message/message, var/channel as text)
		var/list/listener_list = src.listeners[channel]
		if(!length(listener_list)) //nobody on this channel
			return
		for(var/datum/listen_module/input/heard in listener_list)
			if(QDELETED(heard)) //clear out deld listeners
				src.listeners[channel] -= heard
			else
				heard.process(message)
		qdel(message)

	/// Register a listener for hearing messages on a channel
	proc/RegisterInput(var/datum/listen_module/input/registree)
		if(!src.listeners[registree.channel])
			src.listeners[registree.channel] = list()
		src.listeners[registree.channel] += registree


	/// Unregister a listener so it no longer receieves messages
	proc/UnregisterInput(var/datum/listen_module/input/registered)
		if(!src.listeners[registered.channel])
			return
		src.listeners[registered.channel] -= registered

/// Message base class - once something has been passed to say(), it becomes this. Any and all metadata about the message should be stored here
/datum/say_message
	var/prefix = ""
	var/orig_message = ""
	var/atom/speaker = null
	var/datum/language/language = null
	var/content = ""
	var/say_verb = "says"
	var/flags = 0

	/// Create a new message datum with associated metadata, parsing and sanitization.
	New(var/message as text, var/atom/speaker, var/language_id = "english")
		. = ..()
		src.orig_message = message
		src.speaker = speaker
		src.language = global.SpeechManager.GetLanguageInstance(language_id)

		/// first, grab the prefix if there is one
		var/cutpos = 1
		if ((length(message) >= 2) && (copytext(message,1,2) == ":"))
			cutpos = findtext(message, " ", 1)
			src.prefix = copytext(message, 1, cutpos) //get the prefix as :<prefix><first_space> - note prefix will be empty if the message only contains a radio prefix

		src.content = copytext(message, cutpos, MAX_MESSAGE_LEN) //content now contains the message without the radio prefix
		src.content = make_safe_for_chat(src.content)

	proc/make_safe_for_chat(var/message as text)
		return message //TODO

	disposing()
		. = ..()
		src.speaker = null
		src.language = null

/// The tree containing speech modules for the parent atom. All input goes through here.
/// Admittedly "tree" is a bit of a stretch, since only the outputs can branch, but :shrug:
/datum/speech_module_tree
	var/list/datum/speech_module/accent/accents
	var/list/datum/speech_module/modifier/speech_modifiers
	var/list/datum/speech_module/output/output_modules

	New(var/list/accents = list(), var/list/modifiers = list(), var/list/outputs = list())
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
		//TODO Sort modules

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

	disposing()
		. = ..()
		for(var/datum/speech_module/acc in src.accents)
			qdel(acc)
		for(var/datum/speech_module/mod in src.speech_modifiers)
			qdel(mod)
		for(var/datum/speech_module/out in src.output_modules)
			qdel(out)
		qdel(src.accents)
		qdel(src.speech_modifiers)
		qdel(src.output_modules)


/datum/listen_module_tree
	var/list/datum/listen_module/modifier/listen_modifiers
	var/list/datum/listen_module/input/input_modules
	var/atom/parent

	New(var/atom/parent, var/list/inputs = list(), var/list/modifiers = list())
		. = ..()
		src.listen_modifiers = list()
		src.input_modules = list()
		src.parent = parent

		for(var/mod_id in modifiers)
			src.listen_modifiers += global.SpeechManager.GetListenModifierInstance(mod_id)
		for(var/in_id in inputs)
			src.input_modules += global.SpeechManager.GetInputInstance(in_id, src)

		//TODO module sort

	/// No return value is expected here
	proc/process(var/datum/say_message/message)
		if(!istype(message))
			CRASH("A non say_message thing was passed to a listen_module_tree. This should never happen.")

		for(var/datum/listen_module/module in src.listen_modifiers)
			message = module.process(message)
			if(message == null)
				return //the module consumed the message, so process it no further

		boutput(src.parent, "[message.speaker] [message.say_verb] [message.content]") //finally we are done

	disposing()
		. = ..()
		for(var/datum/listen_module/input/inp in src.input_modules)
			qdel(inp)
		for(var/datum/listen_module/mod in src.listen_modifiers)
			qdel(mod)
		qdel(src.listen_modifiers)
		qdel(src.input_modules)
		src.parent = null

TYPEINFO(/datum/speech_module)
	var/id = "abstract_base"
ABSTRACT_TYPE(/datum/speech_module)
/// Base class for speech_modules - subclass this to create a modifier for messages
/datum/speech_module
	/// ID string for cache lookups. This is what your module is called, and it *MUST* be unique
	var/id = "abstract_base"
	/// How far up the tree this module should go. High values get processed before low values.
	var/priority = 0
	/// Return null to prevent the message being processed further, or a /datum/say_message
	proc/process(var/datum/say_message/message)
		return message

TYPEINFO(/datum/speech_module/accent)
	id = "accent_base"
ABSTRACT_TYPE(/datum/speech_module/accent)
/datum/speech_module/accent
	id = "accent_base"

TYPEINFO(/datum/speech_module/modifier)
	id = "modifier_base"
ABSTRACT_TYPE(/datum/speech_module/modifier)
/datum/speech_module/modifier
	id = "modifier_base"

TYPEINFO(/datum/speech_module/output)
	id = "output_base"
ABSTRACT_TYPE(/datum/speech_module/output)
/datum/speech_module/output
	id = "output_base"
	var/channel = "none"

	process(datum/say_message/message)
		global.SpeechManager.PassToListeners(message, channel)


TYPEINFO(/datum/listen_module)
	var/id = "abstract_base"
ABSTRACT_TYPE(/datum/listen_module)
/datum/listen_module
	/// ID string for cache lookups. This is what your module is called, and it *MUST* be unique
	var/id = "abstract_base"
	/// How far up the tree this module should go. High values get processed before low values.
	var/priority = 0
	/// Return null to prevent the message being processed further, or a /datum/say_message
	proc/process(var/datum/say_message/message)
		return message

TYPEINFO(/datum/listen_module/input)
	id = "input_base"
ABSTRACT_TYPE(/datum/listen_module/input)
/datum/listen_module/input
	/// ID string for cache lookups. This is what your module is called, and it *MUST* be unique
	id = "input_base"
	/// Channel this listen module listens on
	var/channel = "none"

	VAR_PRIVATE/datum/listen_module_tree/parent_tree

	New(var/datum/listen_module_tree/parent, var/channel_override = null)
		. = ..()
		if(!istype(parent))
			CRASH("Tried to instantiate a listen input without a parent listen tree. You can't do that!")
		src.parent_tree = parent
		if(istext(channel_override))
			src.channel = channel_override
		global.SpeechManager.RegisterInput(src)

	/// Return early to prevent the message being processed, or call ..() to pass it down the listen tree
	process(var/datum/say_message/message)
		src.parent_tree.process(message)

	disposing()
		. = ..()
		global.SpeechManager.UnregisterInput(src)
		src.parent_tree = null

	/// Change the channel this listener is on and re-register
	proc/ChangeChannel(var/new_channel)
		global.SpeechManager.UnregisterInput(src)
		src.channel = new_channel
		global.SpeechManager.RegisterInput(src)

TYPEINFO(/datum/listen_module/modifier)
	id = "modifier_base"
ABSTRACT_TYPE(/datum/listen_module/modifier)
/datum/listen_module/modifier
	id = "modifier_base"

