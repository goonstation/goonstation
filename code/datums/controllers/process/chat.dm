var/global/datum/controller/process/chat/chat

/datum/controller/process/chat
	/// Client keys to send messages to
	var/list/queued_messages_key

	setup()
		name = "Chat"
		schedule_interval = 0 SECONDS
		LAZYLISTINIT(src.queued_messages_key)
		global.chat = src

	doWork()
		for (var/key as anything in src.queued_messages_key)
			var/client/target = key
			var/payload = src.queued_messages_key[key]
			src.queued_messages_key -= key
			if (target)
				target.tgui_panel?.window.send_message("chat/message", payload)
				for(var/message in payload)
					target << message_to_html(message)

	proc/queue_message(target, message)
		if (islist(target))
			for (var/thing as anything in target)
				var/client/client = CLIENT_FROM_VAR(thing)
				if (client)
					LAZYLISTADD(src.queued_messages_key[client], list(message))

		var/client/client = CLIENT_FROM_VAR(target)
		if (client)
			LAZYLISTADD(src.queued_messages_key[client], list(message))
