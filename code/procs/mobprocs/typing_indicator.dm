#define TYPING_OVERLAY_KEY "speech_bubble"

// Singletons for typing indicators
var/mutable_appearance/living_speech_bubble = mutable_appearance('icons/mob/mob.dmi', "speech")
var/mutable_appearance/living_typing_bubble = mutable_appearance('icons/mob/mob.dmi', "typing")
var/mutable_appearance/living_emote_typing_bubble = mutable_appearance('icons/mob/overhead_icons32x48.dmi', "emote_typing")
var/mutable_appearance/dead_typing_bubble = mutable_appearance('icons/mob/mob.dmi', "typing_of_the_dead")
/mob/proc/create_typing_indicator()
	return

/mob/proc/remove_typing_indicator()
	return

/mob/proc/create_emote_typing_indicator()
	return

/mob/proc/remove_emote_typing_indicator()
	return

/mob/proc/show_speech_bubble()
	return

/mob/Logout()
	remove_typing_indicator()
	remove_emote_typing_indicator()
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
/mob/verb/start_typing(source as text) // The source argument is currently unused
	set name = ".start_typing"
	set hidden = 1

	create_typing_indicator()

/// Hide the typing indicator. The source signifies what action the user was typing for.
/mob/verb/cancel_typing(source as text)
	set name = ".cancel_typing"
	set hidden = 1

	remove_typing_indicator()

// The same but for custom emotes.
/mob/verb/start_emote_typing(source as text)
	set name = ".start_emote_typing"
	set hidden = 1

	create_emote_typing_indicator()

/mob/verb/cancel_emote_typing(source as text)
	set name = ".cancel_emote_typing"
	set hidden = 1

	remove_emote_typing_indicator()

////Wrappers////
//Keybindings were updated to change to use these wrappers. If you ever remove this file, revert those keybind changes

/mob/verb/say_wrapper(message as text)
	set name = ".Say"
	set hidden = 1
	set instant = 1

	remove_typing_indicator()
	if(message)
		say_verb(message)

/mob/verb/whisper_wrapper(message as text)
	set name = ".Whisper"
	set hidden = 1
	set instant = 1

	remove_typing_indicator()
	if(message)
		whisper_verb(message)

/mob/verb/emote_wrapper(message as text)
	set name = ".Emote"
	set hidden = 1
	set instant = 1

	remove_emote_typing_indicator()
	if(message)
		var/emote_verb = winget(src, "emotewindow.say-input", "saved-params")
		say_verb("[emote_verb] [message]")

/mob/verb/me_wrapper(message as text)
	set name = ".Me"
	set hidden = 1
	set instant = 1

	remove_typing_indicator()
	if(message)
		me_verb(message)

// -- Human Typing Indicators -- //
/mob/living/create_typing_indicator()
	if(!src.has_typing_indicator && isalive(src) && !src.bioHolder?.HasEffect("mute") && !src.hasStatus("muted")) //Prevents sticky overlays and typing while in any state besides conscious
		src.has_typing_indicator = TRUE
		if(SEND_SIGNAL(src, COMSIG_CREATE_TYPING))
			return
		src.UpdateOverlays(living_typing_bubble, TYPING_OVERLAY_KEY)

/mob/living/remove_typing_indicator()
	if(src.has_typing_indicator)
		src.has_typing_indicator = FALSE
		if(SEND_SIGNAL(src, COMSIG_REMOVE_TYPING))
			return
		src.UpdateOverlays(null, TYPING_OVERLAY_KEY)

/mob/living/create_emote_typing_indicator()
	if(!src.has_typing_indicator && isalive(src) && !src.hasStatus("paralysis"))
		src.has_typing_indicator = TRUE
		if(SEND_SIGNAL(src, COMSIG_CREATE_TYPING))
			return
		src.UpdateOverlays(living_emote_typing_bubble, TYPING_OVERLAY_KEY)

/mob/living/remove_emote_typing_indicator()
	if(src.has_typing_indicator)
		src.has_typing_indicator = FALSE
		if(SEND_SIGNAL(src, COMSIG_REMOVE_TYPING))
			return
		src.UpdateOverlays(null, TYPING_OVERLAY_KEY)

/mob/living/show_speech_bubble(speech_bubble)
	if (!isalive(src) || src.hasStatus("paralysis"))
		return
	if(SEND_SIGNAL(src, COMSIG_SPEECH_BUBBLE, speech_bubble))
		return
	src.UpdateOverlays(speech_bubble, "speech_bubble")
	SPAWN(1.5 SECONDS)
		// This check prevents the removal of a typing indicator. Without the check, if you begin to speak again before your speech bubble disappears, your typing indicator gets deleted instead.
		if (src.has_typing_indicator == FALSE)
			src.UpdateOverlays(null, "speech_bubble")

/obj/item/organ/head/proc/create_typing_indicator()
	src.UpdateOverlays(living_typing_bubble, TYPING_OVERLAY_KEY)
	return TRUE

/obj/item/organ/head/proc/remove_typing_indicator()
	src.UpdateOverlays(null, TYPING_OVERLAY_KEY)
	return TRUE

/obj/item/organ/head/proc/speech_bubble(datum/source, speech_bubble)
	src.UpdateOverlays(speech_bubble, "speech_bubble")
	SPAWN(1.5 SECONDS)
		if (src.linked_human.has_typing_indicator == FALSE)
			src.UpdateOverlays(null, "speech_bubble")
	return TRUE

// -- Dead Typing Indicators -- //
// These are largely copied and pasted from above,
// but applied only to /mob/dead/observer,
// rather than trying to refactor the original proc and add type checks
// or whatever crud
/mob/dead/observer
	var/has_typing_indicator = FALSE
	var/static/mutable_appearance/speech_bubble = living_speech_bubble

/mob/dead/observer/create_typing_indicator()
	if(!src.has_typing_indicator) //Prevents sticky overlays
		src.has_typing_indicator = TRUE
		if(SEND_SIGNAL(src, COMSIG_CREATE_TYPING))
			return
		src.UpdateOverlays(dead_typing_bubble, TYPING_OVERLAY_KEY)

/mob/dead/observer/remove_typing_indicator()
	if(src.has_typing_indicator)
		src.has_typing_indicator = FALSE
		if(SEND_SIGNAL(src, COMSIG_REMOVE_TYPING))
			return
		src.UpdateOverlays(null, TYPING_OVERLAY_KEY)

/mob/dead/observer/show_speech_bubble(speech_bubble)
	if(SEND_SIGNAL(src, COMSIG_SPEECH_BUBBLE, speech_bubble))
		return
	src.UpdateOverlays(speech_bubble, "speech_bubble")
	SPAWN(1.5 SECONDS)
		// This check prevents the removal of a typing indicator. Without the check, if you begin to speak again before your speech bubble disappears, your typing indicator gets deleted instead.
		if (src.has_typing_indicator == FALSE)
			src.UpdateOverlays(null, "speech_bubble")

/mob/dead/observer/say_dead(var/message, wraith = 0)
	..()
	show_speech_bubble(speech_bubble)

#undef TYPING_OVERLAY_KEY
