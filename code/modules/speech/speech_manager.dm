var/global/datum/speech_manager/SpeechManager = new()

/**
 *	Global manager for speech systems. Used for module lookup, language lookup, and sayflag message modifier processing.
 */
/datum/speech_manager
	/// An associative list of cached speech output module types, indexed by their ID.
	var/list/speech_output_cache
	/// An associative list of cached speech modifier module types, indexed by their ID.
	var/list/speech_modifier_cache
	/// An associative list of cached speech prefix module types, indexed by their ID.
	var/list/speech_prefix_cache
	/// An associative list of cached listen input module types, indexed by their ID.
	var/list/listen_input_cache
	/// An associative list of cached listen modifier module types, indexed by their ID.
	var/list/listen_modifier_cache
	/// An associative list of cached listen effect module types, indexed by their ID.
	var/list/listen_effect_cache
	/// An associative list of cached listen control module types, indexed by their ID.
	var/list/listen_control_cache
	/// An associative list of cached language datum singletons, indexed by their ID.
	var/list/datum/language/language_cache

	/// An associative list of cached shared input format module datum singletons, indexed by their ID.
	VAR_PRIVATE/list/datum/shared_input_format_module/shared_input_format_cache
	/// An associative list of cached say channel datum singletons, indexed by their channel.
	var/list/datum/say_channel/say_channel_cache
	/// An associative list of cached speech prefix module IDs, indexed by their prefix ID or IDs.
	VAR_PRIVATE/list/prefix_id_cache

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
	src.speech_output_cache = list()
	for (var/datum/speech_module/output/T as anything in concrete_typesof(/datum/speech_module/output))
		var/module_id = T::id
		if (src.speech_output_cache[module_id])
			CRASH("Non unique speech output found: [module_id]. These MUST be unique.")
		src.speech_output_cache[module_id] = T

	src.speech_modifier_cache = list()
	for (var/datum/speech_module/modifier/T as anything in concrete_typesof(/datum/speech_module/modifier))
		var/module_id = T::id
		if (src.speech_modifier_cache[module_id])
			CRASH("Non unique speech modifier found: [module_id]. These MUST be unique.")
		src.speech_modifier_cache[module_id] = T

	src.speech_prefix_cache = list()
	src.prefix_id_cache = list()
	for (var/datum/speech_module/prefix/T as anything in concrete_typesof(/datum/speech_module/prefix))
		var/module_id = T::id
		if (src.speech_prefix_cache[module_id])
			CRASH("Non unique speech prefix found: [module_id]. These MUST be unique.")
		src.speech_prefix_cache[module_id] = T
		src.prefix_id_cache[T::prefix_id] = module_id

	src.listen_input_cache = list()
	for (var/datum/listen_module/input/T as anything in concrete_typesof(/datum/listen_module/input))
		var/module_id = T::id
		if (src.listen_input_cache[module_id])
			CRASH("Non unique listen input found: [module_id]. These MUST be unique.")
		src.listen_input_cache[module_id] = T

	src.listen_modifier_cache = list()
	for (var/datum/listen_module/modifier/T as anything in concrete_typesof(/datum/listen_module/modifier))
		var/module_id = T::id
		if (src.listen_modifier_cache[module_id])
			CRASH("Non unique listen modifier found: [module_id]. These MUST be unique.")
		src.listen_modifier_cache[module_id] = T

	src.listen_effect_cache = list()
	for (var/datum/listen_module/effect/T as anything in concrete_typesof(/datum/listen_module/effect))
		var/module_id = T::id
		if (src.listen_effect_cache[module_id])
			CRASH("Non unique listen effect found: [module_id]. These MUST be unique.")
		src.listen_effect_cache[module_id] = T

	src.listen_control_cache = list()
	for (var/datum/listen_module/control/T as anything in concrete_typesof(/datum/listen_module/control))
		var/module_id = T::id
		if (src.listen_control_cache[module_id])
			CRASH("Non unique listen control found: [module_id]. These MUST be unique.")
		src.listen_control_cache[module_id] = T

	// Populate the language cache.
	src.language_cache = list()
	for (var/T in concrete_typesof(/datum/language))
		var/datum/language/language = new T()
		src.language_cache[language.id] = language

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

/// Returns a unique instance of the speech output module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetOutputInstance(output_id, list/arguments)
	RETURN_TYPE(/datum/speech_module/output)
	var/result = src.speech_output_cache[output_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid speech output lookup: [output_id]")

/// Returns a unique instance of the speech modifier module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetSpeechModifierInstance(modifier_id, list/arguments)
	RETURN_TYPE(/datum/speech_module/modifier)
	var/result = src.speech_modifier_cache[modifier_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid speech modifier lookup: [modifier_id]")

/// Returns a unique instance of the speech prefix module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetSpeechPrefixInstance(prefix_id, list/arguments)
	RETURN_TYPE(/datum/speech_module/prefix)
	var/result = src.speech_prefix_cache[prefix_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid speech prefix lookup: [prefix_id]")

/// Returns the longest prefix ID that corresponds to a prefix module from a specified prefix ID.
/datum/speech_manager/proc/TruncatePrefix(prefix_id)
	var/original_prefix = prefix_id
	var/module_id

	// Attempt to locate a speech prefix module ID that matches the prefix ID, with each iteration using a shorter prefix ID.
	// This results in a prefix ID of ":3a" returning the module ID for ":3". Equally, ":g" -> ":", ";nonsense" -> ";", etc.
	while (length(prefix_id))
		module_id = src.prefix_id_cache[prefix_id]

		if (module_id)
			// If a speech prefix module is located, add its ID to the prefix cache as a shortcut for the initial prefix ID used.
			if (!src.prefix_id_cache[original_prefix])
				src.prefix_id_cache[original_prefix] = module_id

			break

		prefix_id = copytext(prefix_id, 1, length(prefix_id))

	return prefix_id

/// Returns a unique instance of the listen input module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetInputInstance(input_id, list/arguments)
	RETURN_TYPE(/datum/listen_module/input)
	var/result = src.listen_input_cache[input_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid listen input lookup: [input_id]")

/// Returns a unique instance of the listen modifier module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetListenModifierInstance(modifier_id, list/arguments)
	RETURN_TYPE(/datum/listen_module/modifier)
	var/result = src.listen_modifier_cache[modifier_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid listen modifier lookup: [modifier_id]")

/// Returns a unique instance of the listen effect module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetListenEffectInstance(effect_id, list/arguments)
	RETURN_TYPE(/datum/listen_module/effect)
	var/result = src.listen_effect_cache[effect_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid listen effect lookup: [effect_id]")

/// Returns a unique instance of the listen control module requested, or runtimes on bad ID.
/datum/speech_manager/proc/GetListenControlInstance(control_id, list/arguments)
	RETURN_TYPE(/datum/listen_module/control)
	var/result = src.listen_control_cache[control_id]
	if (result)
		return new result(arglist(arguments))
	else
		CRASH("Invalid listen control lookup: [control_id]")

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
