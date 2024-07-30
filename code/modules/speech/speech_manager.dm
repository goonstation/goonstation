var/global/datum/speech_manager/SpeechManager = new()

/**
 *	Global manager for speech systems. Used for module lookup, language lookup, and the handling of prefix and sayflag message
 *	modifier processing.
 */
/datum/speech_manager
	/// An associative list of cached modifier speech module types, indexed by their ID.
	VAR_PRIVATE/list/speech_modifier_cache
	/// An associative list of cached output speech module types, indexed by their ID.
	VAR_PRIVATE/list/output_cache
	/// An associative list of cached input listen module types, indexed by their ID.
	VAR_PRIVATE/list/input_cache
	/// An associative list of cached modifier listen module types, indexed by their ID.
	VAR_PRIVATE/list/listen_modifier_cache

	/// An associative list of cached shared input format module datum singletons, indexed by their ID.
	VAR_PRIVATE/list/datum/shared_input_format_module/shared_input_format_cache
	/// An associative list of cached say channel datum singletons, indexed by their channel.
	VAR_PRIVATE/list/datum/say_channel/say_channel_cache
	/// An associative list of cached language datum singletons, indexed by their ID.
	VAR_PRIVATE/list/datum/language/language_cache
	/// An associative list of cached say prefix datum singletons, indexed by their ID.
	VAR_PRIVATE/list/datum/say_prefix/prefix_cache

	/// An associative list of cached preprocessing message modifier datum singletons, indexed by their bitflag.
	VAR_PRIVATE/list/datum/message_modifier/preprocessing/preprocessing_message_modifier_cache
	/// The combined bitflag of each individual preprocessing message modifier instance.
	VAR_PRIVATE/combined_preprocessing_message_modifier_bitflag

	/// An associative list of cached postprocessing message modifier datum singletons, indexed by their bitflag.
	VAR_PRIVATE/list/datum/message_modifier/postprocessing/postprocessing_message_modifier_cache
	/// The combined bitflag of each individual postprocessing message modifier instance.
	VAR_PRIVATE/combined_postprocessing_message_modifier_bitflag

/datum/speech_manager/New()
	. = ..()

	// Populate the module caches.
	src.output_cache = list()
	for (var/datum/speech_module/output/T as anything in concrete_typesof(/datum/speech_module/output))
		var/module_id = initial(T.id)
		if (src.output_cache[module_id])
			CRASH("Non unique output found: [module_id]. These MUST be unique.")
		src.output_cache[module_id] = T

	src.speech_modifier_cache = list()
	for (var/datum/speech_module/modifier/T as anything in concrete_typesof(/datum/speech_module/modifier))
		var/module_id = initial(T.id)
		if (src.speech_modifier_cache[module_id])
			CRASH("Non unique modifier found: [module_id]. These MUST be unique.")
		src.speech_modifier_cache[module_id] = T

	src.input_cache = list()
	for (var/datum/listen_module/input/T as anything in concrete_typesof(/datum/listen_module/input))
		var/module_id = initial(T.id)
		if (src.input_cache[module_id])
			CRASH("Non unique input found: [module_id]. These MUST be unique.")
		src.input_cache[module_id] = T

	src.listen_modifier_cache = list()
	for (var/datum/listen_module/modifier/T as anything in concrete_typesof(/datum/listen_module/modifier))
		var/module_id = initial(T.id)
		if (src.listen_modifier_cache[module_id])
			CRASH("Non unique listen modifer found: [module_id]. These MUST be unique.")
		src.listen_modifier_cache[module_id] = T

	// Populate the shared input format module cache.
	src.shared_input_format_cache = list()
	for (var/T in concrete_typesof(/datum/shared_input_format_module))
		var/datum/shared_input_format_module/module = new T()
		src.shared_input_format_cache[module.id] = module

	// Populate the shared input format module cache.
	src.say_channel_cache = list()
	for (var/T in concrete_typesof(/datum/say_channel))
		var/datum/say_channel/channel = new T()
		src.say_channel_cache[channel.channel_id] = channel

	// Populate the language cache.
	src.language_cache = list()
	for (var/T in concrete_typesof(/datum/language))
		var/datum/language/language = new T()
		src.language_cache[language.id] = language

	// Populate the prefix cache.
	src.prefix_cache = list()
	for (var/T in concrete_typesof(/datum/say_prefix))
		var/datum/say_prefix/prefix = new T()
		if (islist(prefix.id))
			for (var/id in prefix.id)
				src.prefix_cache[id] = prefix
		else
			src.prefix_cache[prefix.id] = prefix

	// Populate the preprocessing message modifier cache.
	src.preprocessing_message_modifier_cache = list()
	for (var/T in concrete_typesof(/datum/message_modifier/preprocessing))
		var/datum/message_modifier/preprocessing/modifier = new T()
		src.preprocessing_message_modifier_cache["[modifier.sayflag]"] = modifier
		src.combined_preprocessing_message_modifier_bitflag |= modifier.sayflag

	sortList(src.preprocessing_message_modifier_cache, GLOBAL_PROC_REF(cmp_message_modifier), TRUE)

	// Populate the postprocessing message modifier cache.
	src.postprocessing_message_modifier_cache = list()
	for (var/T in concrete_typesof(/datum/message_modifier/postprocessing))
		var/datum/message_modifier/postprocessing/modifier = new T()
		src.postprocessing_message_modifier_cache["[modifier.sayflag]"] = modifier
		src.combined_postprocessing_message_modifier_bitflag |= modifier.sayflag

	sortList(src.postprocessing_message_modifier_cache, GLOBAL_PROC_REF(cmp_message_modifier), TRUE)

/// Returns a unique instance of the output speech module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetOutputInstance(output_id, list/arguments)
	RETURN_TYPE(/datum/speech_module/output)
	var/result = src.output_cache[output_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid output lookup: [output_id]")

/// Returns a unique instance of the modifier speech module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetSpeechModifierInstance(modifier_id, list/arguments)
	RETURN_TYPE(/datum/speech_module/modifier)
	var/result = src.speech_modifier_cache[modifier_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid modifier lookup: [modifier_id]")

/// Returns a unique instance of the input listen module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetInputInstance(input_id, list/arguments)
	RETURN_TYPE(/datum/listen_module/input)
	var/result = src.input_cache[input_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid input lookup: [input_id]")

/// Returns a unique instance of the modifier listen module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetListenModifierInstance(modifier_id, list/arguments)
	RETURN_TYPE(/datum/listen_module/modifier)
	var/result = src.listen_modifier_cache[modifier_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid listen modifier lookup: [modifier_id]")

/// Returns the global instance of the shared input module datum corresponding to the ID given. Does not runtime of bad ID.
/datum/speech_manager/proc/GetSharedInputFormatModuleInstance(module_id)
	RETURN_TYPE(/datum/shared_input_format_module)
	return src.shared_input_format_cache[module_id]

/// Returns the global instance of the say channel datum requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetSayChannelInstance(channel_id)
	RETURN_TYPE(/datum/say_channel)
	var/datum/say_channel/result = src.say_channel_cache[channel_id]
	if (istype(result))
		return result
	else
		CRASH("Invalid say channel lookup: [channel_id]")

/// Returns the global instance of the language datum requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetLanguageInstance(lang_id)
	RETURN_TYPE(/datum/language)
	var/datum/language/result = src.language_cache[lang_id]
	if (istype(result))
		return result
	else
		CRASH("Invalid language lookup: [lang_id]")

/// Apply the processing effects of the applicable say prefix datum to a message.
/datum/speech_manager/proc/ProcessMessagePrefix(datum/say_message/message, datum/speech_module_tree/say_tree)
	if (!message.prefix || (message.flags & SAYFLAG_PREFIX_PROCESSED))
		return

	var/prefix_id = message.prefix
	var/datum/say_prefix/prefix_datum

	// Attempt to locate a say prefix datum that matches the prefix ID, with each iteration using a shorter ID.
	// This results in a prefix of ":3a" returning the datum for ":3". Equally, ":g" -> ":", ";nonsense" -> ";", etc.
	while (length(prefix_id))
		prefix_datum = src.prefix_cache[prefix_id]

		if (prefix_datum)
			// If a say prefix datum is located, add it to the prefix cache as a shortcut for the initial ID used.
			if (!src.prefix_cache[message.prefix])
				src.prefix_cache[message.prefix] = prefix_datum

			// Exit the loop is a say prefix datum is found and is compatible with the message.
			if (prefix_datum.is_compatible_with(message, say_tree))
				break

		prefix_datum = null
		prefix_id = copytext(prefix_id, 1, length(prefix_id))

	if (!prefix_datum)
		return

	// Process the message.
	message.flags |= SAYFLAG_PREFIX_PROCESSED
	prefix_datum.process(message, say_tree)
	message.flags |= SAYFLAG_WHISPER

/// Apply the processing effects of any applicable preprocessing message modifier datums to a message.
/datum/speech_manager/proc/ApplyMessageModifierPreprocessing(datum/say_message/message)
	var/message_modifier_flags = src.combined_preprocessing_message_modifier_bitflag & message.flags
	if (!message_modifier_flags)
		return

	for (var/flag as anything in src.preprocessing_message_modifier_cache)
		if (!(text2num(flag) & message_modifier_flags))
			continue

		var/datum/message_modifier/modifier = src.preprocessing_message_modifier_cache[flag]
		modifier.process(message)
		message_modifier_flags &= message.flags

/// Apply the formatting effects of any applicable postprocessing message modifier datums to a message.
/datum/speech_manager/proc/ApplyMessageModifierPostprocessing(datum/say_message/message)
	var/message_modifier_flags = src.combined_postprocessing_message_modifier_bitflag & message.flags
	if (!message_modifier_flags)
		return

	for (var/flag as anything in src.postprocessing_message_modifier_cache)
		if (!(text2num(flag) & message_modifier_flags))
			continue

		var/datum/message_modifier/modifier = src.postprocessing_message_modifier_cache[flag]
		modifier.process(message)
		message_modifier_flags &= message.flags


/// Compare the priority of two message modifiers. If the priority is the same, compare them based on their sayflags.
/proc/cmp_message_modifier(datum/message_modifier/a, datum/message_modifier/b)
	. = b.priority - a.priority
	. ||= b.sayflag - a.sayflag
