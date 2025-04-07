/*
TODO:

Contributing:
- Authors: Mr. Moriarty, Amylizzle, LeahTheTech, ZeWaka, Glowbold, DisturbHerb, Romayne, & Skeletonman0
- If you make a PR to the say rework branch, feel free to add your name to the above list.
- Please make an effort to adhere to the set out code style, primarily the following:
	Absolute pathing,
	Thorough documentation,
	The use of `src` and `global` when accessing applicable variables.

Old Code To Remove:
- Check span defines in `chat_output.dm`. Some may now be unused.

Unfixable:
- Living mobs that are dead can no longer send and receive messages to and from deadchat. This is a limitation of death/revive code.

Follow-Up PRs:
- Admin panel for enabling/disabling say channels. OOC/LOOC/Deadchat are currently done through procs:
	- `toggledeadchat()` / `toggle_deadchat_allowed()`
	- `toggleooc()` / `toggle_ooc_allowed()`
	- `togglelooc()` / `toggle_looc_allowed()`
- Removal of `/obj/item/device/radio/var/broadcasting` from maps.
- Removal of `/obj/machinery/computer/announcement/var/voice_name` from maps.

*/


TYPEINFO(/atom)
	// Default Listen Modules:
	/// The listen controls that this atom *starts* with. It will not be updated nor used again after initialisation.
	var/list/start_listen_controls = null
	/// The listen effects that this atom *starts* with. It will not be updated nor used again after initialisation.
	var/list/start_listen_effects = null
	/// The listen modifiers that this atom *starts* with. It will not be updated nor used again after initialisation.
	var/list/start_listen_modifiers = null
	/// The listen inputs that this atom *starts* with. It will not be updated nor used again after initialisation.
	var/list/start_listen_inputs = null
	/// The listen languages that this atom *starts* with. It will not be updated nor used again after initialisation. Note that this is the languages that the atom understands when heard.
	var/list/start_listen_languages = list(LANGUAGE_ALL)

	// Default Speech Modules:
	/// The speech prefixes that this atom *starts* with. It will not be updated nor used again after initialisation.
	var/list/start_speech_prefixes = null
	/// The speech modifiers that this atom *starts* with. It will not be updated nor used again after initialisation.
	var/list/start_speech_modifiers = null
	/// The speech outputs that this atom *starts* with. It will not be updated nor used again after initialisation.
	var/list/start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN)


/atom
	// Module Trees:
	/// This atom's listen module tree. May be null if no input modules are registered.
	var/datum/listen_module_tree/listen_tree = null
	/// This atom's speech module tree. Lazy loaded on the first `say()` call.
	var/datum/speech_module_tree/speech_tree = null

	// Listen Variables:
	/// Whether objects inside of this atom should be able to hear messages that could be heard by this atom.
	var/open_to_sound = FALSE

	// Speech Output Variables:
	/// The default channel that this atom will attempt to send unprefixed say messages to.
	var/default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	/// The default output language for say messages to be sent in.
	var/say_language = LANGUAGE_ENGLISH

	// Speech Verb Variables:
	/// The default say verb for standard spoken phrases. Also acts as a fallback verb if contextual verbs are `null`. Accepts both text and lists
	var/speech_verb_say = "says"
	/// The default say verb for spoken phrases ending in a question mark. Accepts both text and lists
	var/speech_verb_ask = null
	/// The default say verb for spoken phrases ending in an exclaimation mark. Accepts both text and lists
	var/speech_verb_exclaim = null
	/// The default say verb for stammered phrases. Accepts both text and lists
	var/speech_verb_stammer = null
	/// The default say verb for gasped phrases. Accepts both text and lists
	var/speech_verb_gasp = null

	// Voice Variables:
	/// The set of vocal sounds that this atom should use. See the `sounds_speak` global list.
	var/voice_type = null
	/// If set, will override `voice_type` and play the specified sound when this atom speaks.
	var/voice_sound_override = null
	/// The pitch of this atom's voice.
	var/voice_pitch = null
	/// The world time that this atom last played a voice sound effect.
	var/last_voice_sound = 0

	// Speech Bubble Variables:
	/// Whether this atom should display a speech bubble after speaking.
	var/use_speech_bubble = FALSE
	/// The shared speech bubble appearance.
	var/static/mutable_appearance/speech_bubble = global.living_speech_bubble
	/// The default speech bubble for standard spoken phrases. Also acts as a fallback icon if contextual icons are `null`.
	var/speech_bubble_icon_say = "speech"
	/// The default speech bubble for spoken phrases ending in a question mark.
	var/speech_bubble_icon_ask = "?"
	/// The default speech bubble for spoken phrases ending in an exclaimation mark.
	var/speech_bubble_icon_exclaim = "!"
	/// The default speech bubble for sung phrases.
	var/speech_bubble_icon_sing = "note"
	/// The default speech bubble for sung phrases that were either sung loudly or poorly.
	var/speech_bubble_icon_sing_bad = "notebad"

/atom/New()
	if (length(src.get_typeinfo().start_listen_inputs))
		src.ensure_listen_tree()

	. = ..()

/atom/disposing()
	QDEL_NULL(src.listen_tree)
	QDEL_NULL(src.speech_tree)

	. = ..()

/// Returns this atom's listen module tree. If this atom does not possess a listen module tree, instantiates one.
/atom/proc/ensure_listen_tree()
	RETURN_TYPE(/datum/listen_module_tree)
	var/typeinfo/atom/typeinfo = src.get_typeinfo()
	src.listen_tree ||= new(src, typeinfo.start_listen_inputs, typeinfo.start_listen_modifiers, typeinfo.start_listen_effects, typeinfo.start_listen_controls, typeinfo.start_listen_languages)
	return src.listen_tree

/// Returns this atom's speech module tree. If this atom does not possess a speech module tree, instantiates one.
/atom/proc/ensure_speech_tree()
	RETURN_TYPE(/datum/speech_module_tree)
	var/typeinfo/atom/typeinfo = src.get_typeinfo()
	src.speech_tree ||= new(src, typeinfo.start_speech_outputs, typeinfo.start_speech_modifiers, typeinfo.start_speech_prefixes)
	return src.speech_tree

/**
 *	The primary entry point for all say code; messages sent will be mutated by the speech tree, passed to a say channel, disseminated to listeners, mutated by listen trees, then finally heard by recipients.
 *	- `message`: The plain text that should be used as the content of the say message datum.
 *	- `flags`: The flags that should be applied to the say message datum, which determine how it should be formatted and displayed. See `_std/defines/speech_defines/sayflags.dm`.
 *	- `message_params`: Use this to override the default variables of the say message datum. Use explitly only where a speech module would not be appropriate.
 *	- `atom_listeners_override`: In lieu of being sent over a say channel, messages will instead attempt to be passed to the listen trees of these atoms directly.
 */
/atom/proc/say(message as text, flags = 0, list/message_params = null, list/atom/atom_listeners_override = null)
	RETURN_TYPE(/datum/say_message)
	SHOULD_NOT_OVERRIDE(TRUE)

	if (dd_hasprefix(message, "*"))
		src.emote(copytext(message, 2), TRUE)
		return

	src.ensure_speech_tree()
	var/datum/say_message/said = new(message, src, flags, message_params, atom_listeners_override)
	if (QDELETED(said) || !length(said.content))
		return

	SEND_SIGNAL(src, COMSIG_ATOM_SAY, said)
	SEND_GLOBAL_SIGNAL(COMSIG_ATOM_SAY, said)

	return src.speech_tree.process(said)

/// A stub proc to facilitate `say()` passing on messages prefixed with "*".
/atom/proc/emote(act, voluntary = FALSE, atom/target)
	set waitfor = FALSE
	SHOULD_CALL_PARENT(TRUE)
	return FALSE

/// Displays an atom's speech bubble overlay, then removes it after a short delay.
/atom/proc/show_speech_bubble(image/override_image)
	src.AddOverlays(override_image || src.speech_bubble, "speech_bubble")
	OVERRIDE_COOLDOWN(src, "speech_bubble", 1.4 SECONDS)

	SPAWN(1.5 SECONDS)
		if (!GET_COOLDOWN(src, "speech_bubble"))
			src.ClearSpecificOverlays("speech_bubble")


/// Whether a client controlling this mob can make this mob speak through the use of say wrappers or commands.
/mob/var/can_use_say = TRUE

/// Compare the priority of two speech/listen modules. If the priority is the same, compare them based on their ID.
/proc/cmp_say_modules(datum/speech_module/a, datum/speech_module/b)
	. = b.priority - a.priority
	. ||= cmp_text_asc(a.id, b.id)




/client
	/// This client's auxiliary listen module tree.
	var/datum/listen_module_tree/auxiliary/listen_tree
	/// This client's auxiliary speech module tree.
	var/datum/speech_module_tree/auxiliary/speech_tree

/client/New()
	. = ..()

	src.ensure_listen_tree()
	src.ensure_speech_tree()

/// Returns this client's auxiliary listen module tree. If this client does not possess an auxiliary listen module tree, instantiates one.
/client/proc/ensure_listen_tree()
	RETURN_TYPE(/datum/listen_module_tree/auxiliary)

	if (src.listen_tree)
		return src.listen_tree

	src.listen_tree = new(null, null, null, list(LISTEN_EFFECT_DISPLAY_TO_CLIENT), null, null, src.mob.listen_tree)

	src.preferences.listen_ooc = !src.preferences.listen_ooc
	src.toggle_ooc(!src.preferences.listen_ooc)

	src.preferences.listen_looc = !src.preferences.listen_looc
	src.toggle_looc(!src.preferences.listen_looc)

	if (src.holder && !src.player_mode)
		src.holder.admin_listen_tree.update_target_listen_tree(src.listen_tree)

	return src.listen_tree

/// Returns this client's auxiliary speech module tree. If this client does not possess an auxiliary speech module tree, instantiates one.
/client/proc/ensure_speech_tree()
	RETURN_TYPE(/datum/speech_module_tree/auxiliary)

	if (src.speech_tree)
		return src.speech_tree

	src.speech_tree = new(null, list(SPEECH_OUTPUT_OOC, SPEECH_OUTPUT_LOOC), null, null, src.mob.speech_tree)
	if (src.holder && !src.player_mode)
		src.holder.admin_speech_tree.update_target_speech_tree(src.speech_tree)

	return src.speech_tree

/// Toggle hearing OOC for this client.
/client/proc/toggle_ooc(ooc_enabled)
	if (src.preferences.listen_ooc == ooc_enabled)
		return

	src.preferences.listen_ooc = ooc_enabled

	if (src.preferences.listen_ooc)
		if (src.holder && !src.player_mode)
			src.listen_tree.AddListenInput(LISTEN_INPUT_OOC_ADMIN)
		else
			src.listen_tree.AddListenInput(LISTEN_INPUT_OOC)

	else
		if (src.holder && !src.player_mode)
			src.listen_tree.RemoveListenInput(LISTEN_INPUT_OOC_ADMIN)
		else
			src.listen_tree.RemoveListenInput(LISTEN_INPUT_OOC)

/// Toggle hearing LOOC for this client.
/client/proc/toggle_looc(looc_enabled)
	if (src.preferences.listen_looc == looc_enabled)
		return

	src.preferences.listen_looc = looc_enabled

	if (src.preferences.listen_looc)
		if (src.holder && !src.player_mode)
			src.listen_tree.AddListenControl(LISTEN_CONTROL_TOGGLE_HEARING_ALL_LOOC)
		else
			src.listen_tree.AddListenInput(LISTEN_INPUT_LOOC)

	else
		if (src.holder && !src.player_mode)
			src.listen_tree.RemoveListenControl(LISTEN_CONTROL_TOGGLE_HEARING_ALL_LOOC)
		else
			src.listen_tree.RemoveListenInput(LISTEN_INPUT_LOOC)

/mob/Login()
	. = ..()

	src.ensure_listen_tree()
	src.ensure_speech_tree()

	src.client.ensure_listen_tree().update_target_listen_tree(src.listen_tree)
	src.client.ensure_speech_tree().update_target_speech_tree(src.speech_tree)
