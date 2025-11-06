#define TYPING_OVERLAY_KEY "typing_indicator"
#define EMOTE_TYPING_OVERLAY_KEY "emote_typing_indicator"

// Singletons for typing indicators
var/mutable_appearance/living_speech_bubble = mutable_appearance('icons/mob/mob.dmi', "speech")
var/mutable_appearance/living_typing_bubble = mutable_appearance('icons/mob/mob.dmi', "typing")
var/mutable_appearance/living_emote_typing_bubble = mutable_appearance('icons/mob/overhead_icons32x48.dmi', "emote_typing")
var/mutable_appearance/dead_typing_bubble = mutable_appearance('icons/mob/mob.dmi', "typing_of_the_dead")

/mob/var/has_typing_indicator = FALSE

/mob/proc/create_typing_indicator()
	if (src.has_typing_indicator)
		return

	src.has_typing_indicator = TRUE

	src.ensure_speech_tree()
	src.RegisterSignal(src.speech_tree, COMSIG_SPEAKER_ORIGIN_UPDATED, PROC_REF(update_typing_indicator))
	src.speech_tree.speaker_origin.UpdateOverlays(global.living_typing_bubble, TYPING_OVERLAY_KEY)

/mob/proc/remove_typing_indicator()
	if (!src.has_typing_indicator)
		return

	src.has_typing_indicator = FALSE

	src.ensure_speech_tree()
	src.UnregisterSignal(src.speech_tree, COMSIG_SPEAKER_ORIGIN_UPDATED)
	src.speech_tree.speaker_origin.UpdateOverlays(null, TYPING_OVERLAY_KEY)

/mob/proc/update_typing_indicator(tree, atom/old_parent, atom/new_parent)
	old_parent.ClearSpecificOverlays(TYPING_OVERLAY_KEY)
	new_parent.UpdateOverlays(global.living_typing_bubble, TYPING_OVERLAY_KEY)

/mob/var/has_emote_typing_indicator = FALSE

/mob/proc/create_emote_typing_indicator()
	if (src.has_emote_typing_indicator)
		return

	src.has_emote_typing_indicator = TRUE
	src.UpdateOverlays(living_emote_typing_bubble, EMOTE_TYPING_OVERLAY_KEY)

/mob/proc/remove_emote_typing_indicator()
	if (!src.has_emote_typing_indicator)
		return

	src.has_emote_typing_indicator = FALSE
	src.UpdateOverlays(null, EMOTE_TYPING_OVERLAY_KEY)

/mob/Logout()
	src.remove_typing_indicator()
	src.remove_emote_typing_indicator()
	. = ..()

// -- Typing verbs -- //
//Those are used to show the typing indicator for the player without waiting on the client.

/*
Some information on how these work:
The keybindings for say, whisper, and me have been modified to call start_typing and immediately open the textbox clientside.
Because of this, the client doesn't have to wait for a message from the server before opening the textbox, the server
knows immediately when the user pressed the hotkey, and the clientside textbox can signal success or failure to the server.

When you press the hotkey, the .start_typing verb is called with the source ("say", "whisper", or "me") to show the typing indicator.
When you send a message from the custom window, the appropriate verb is called, .say, .whisper, or .me
If you close the window without actually sending the message, the .cancel_typing verb is called with the source.

The say/whisper/me wrappers and cancel_typing remove the typing indicator.
*/

/// Show the typing indicator. The source signifies what action the user is typing for.
/mob/verb/start_typing(source as text) // The source argument is currently unused.
	set name = ".start_typing"
	set hidden = 1

	src.create_typing_indicator()

/// Hide the typing indicator. The source signifies what action the user was typing for.
/mob/verb/cancel_typing(source as text)
	set name = ".cancel_typing"
	set hidden = 1

	src.remove_typing_indicator()

// The same but for custom emotes.
/mob/verb/start_emote_typing(source as text)
	set name = ".start_emote_typing"
	set hidden = 1

	src.create_emote_typing_indicator()

/mob/verb/cancel_emote_typing(source as text)
	set name = ".cancel_emote_typing"
	set hidden = 1

	src.remove_emote_typing_indicator()

////Wrappers////
//Keybindings were updated to change to use these wrappers. If you ever remove this file, revert those keybind changes

/mob/verb/say_wrapper(message as text)
	set name = ".Say"
	set hidden = 1
	set instant = 1

	src.remove_typing_indicator()
	if (message)
		src.say_verb(message)

/mob/verb/whisper_wrapper(message as text)
	set name = ".Whisper"
	set hidden = 1
	set instant = 1

	src.remove_typing_indicator()
	if (message)
		src.whisper_verb(message)

/mob/verb/emote_wrapper(message as text)
	set name = ".Emote"
	set hidden = 1
	set instant = 1

	src.remove_emote_typing_indicator()
	if (message)
		var/emote_verb = winget(src, "emotewindow.say-input", "saved-params")
		src.say_verb("[emote_verb] [message]")

/mob/verb/me_wrapper(message as text)
	set name = ".Me"
	set hidden = 1
	set instant = 1

	src.remove_emote_typing_indicator()
	if (message)
		src.me_verb(message)


// -- Human Typing Indicators -- //
/mob/living/create_typing_indicator()
	if (!isalive(src) || src.bioHolder?.HasEffect("mute") || src.hasStatus("muted"))
		return

	. = ..()

/mob/living/create_emote_typing_indicator()
	if (!isalive(src) || src.hasStatus("paralysis"))
		return

	. = ..()


// -- Override Target Observer Typing Indicators -- //
/mob/dead/target_observer/create_typing_indicator()
	return

/mob/dead/target_observer/remove_typing_indicator()
	return

/mob/dead/target_observer/create_emote_typing_indicator()
	return

/mob/dead/target_observer/remove_emote_typing_indicator()
	return


#undef TYPING_OVERLAY_KEY
#undef EMOTE_TYPING_OVERLAY_KEY
