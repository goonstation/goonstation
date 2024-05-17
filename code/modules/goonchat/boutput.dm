
/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */
/* === GOON PORT CHANGES ===
 * Renamed to boutput (browseroutput)
 * Added forceScroll and group fields
 * Using goon procs and variables
 */
/**
 * global
 *
 * Circumvents the message queue and sends the message
 * to the recipient (target) as soon as possible.
 */
/proc/boutput_immediate(target, html, group, forceScroll, type, text)
	if (!target)
		return
	html = "[html]"
	text = "[text]"
	if (!text && !html)
		CRASH("boutput_immediate called without a string")
	if (target == world)
		target = global.clients
	// Having this all as args is a bit messy but it helps later on the JS side
	// Build a message
	var/message = list()
	if (type)
		message["type"] = type
	if (text)
		message["text"] = text
	if (html)
		message["html"] = html
	if (group)
		message["group"] = group
	if (forceScroll)
		message["group"] = forceScroll
	var/message_blob = TGUI_CREATE_MESSAGE("chat/message", message)
	var/message_html = message_to_html(message)
	if (islist(target))
		for (var/_target in target)
			var/client/client = CLIENT_FROM_VAR(_target)
			if (client)
				// Send to tgchat
				client.tgui_panel?.window.send_raw_message(message_blob)
				// Send to old chat
				client << message_html
		return
	var/client/client = CLIENT_FROM_VAR(target)
	if (client)
		// Send to tgchat
		client.tgui_panel?.window.send_raw_message(message_blob)
		// Send to old chat
		client << message_html

/**
 * global
 *
 * Sends the message to the recipient (target).
 *
 * Message can be HTML or plain text.
 *
 * Type uses _std/defines/chat.dm defines for faster styling. (see https://github.com/tgstation/tgstation/pull/52947 for details)
 *
 * Group is used for spam reduction by folding messages with the same group.
 *
 * Force scroll scrolls the chat to bottom when the message is sent.
 */
/proc/boutput(target, html, group, forceScroll, type, text)
	if (!global.chat || !global.chat.is_available() || global.current_state <= GAME_STATE_PREGAME)
		boutput_immediate(target, html, group, forceScroll, type, text)
		return
	if (!target)
		return
	html = "[html]"
	text = "[text]"
	if (!text && !html)
		CRASH("boutput called without a string")
	if (target == world)
		target = global.clients
	// Having this all as args is a bit messy but it helps later on the JS side
	var/message = list()
	if (type)
		message["type"] = type
	if (text)
		message["text"] = text
	if (html)
		message["html"] = html
	if (group)
		message["group"] = group
	if (forceScroll)
		message["forceScroll"] = forceScroll
	global.chat.queue_message(target, message)


/*
I spent so long on this regex I don't want to get rid of it :(

if (findtext(message, "<IMG CLASS=ICON"))
	var/regex/R = new("/<IMG CLASS=icon SRC=(\\\[.*?\\\]) ICONSTATE='(.*?)'>/\[insertIconImg($1,$2)\]/e")
	//if (R.Find(message))
	var/newtxt = R.Replace(message)
	while(newtxt)
		message = newtxt
		newtxt = R.ReplaceNext(message)

	world.log << html_encode(message)
*/
