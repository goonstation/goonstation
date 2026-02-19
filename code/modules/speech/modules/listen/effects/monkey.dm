/datum/listen_module/effect/monkey
	id = LISTEN_EFFECT_MONKEY

/datum/listen_module/effect/monkey/process(datum/say_message/message)
	var/mob/living/carbon/human/npc/monkey/monkey = src.parent_tree.listener_parent
	if (!istype(monkey) || !isalive(monkey) || !ismob(message.speaker) || !(message.flags & (SAYFLAG_LOUD_SINGING | SAYFLAG_BAD_SINGING)))
		return

	if ((message.speaker == monkey) || !ishuman(message.speaker) || ismonkey(message.speaker) || !prob(50))
		return

	SPAWN(0.5 SECONDS)
		// The monkey is angered.
		if (prob(20))
			monkey.visible_message("<B>[monkey.name]</B> becomes furious at [message.speaker] for their [(message.flags & SAYFLAG_BAD_SINGING) ? "bad" : "loud"] singing!")
			monkey.say(pick(
				"Must take revenge for insult to music!",
				"I now attack you like your singing attacked my ears!",
			))

			monkey.was_harmed(message.speaker)

		// The monkey is merely irritated.
		else
			monkey.visible_message(pick(
				"<B>[monkey.name]</B> doesn't seem to like [message.speaker]'s singing",
				"<B>[monkey.name]</B> puts their hands over their ears",
			), TRUE)

			monkey.say(pick(
				"You human sing worse than a baboon!",
				"Me know gorillas with better vocal pitch than you!",
				"Monkeys ears too sensitive for this cacophony!",
				"You sound like you singing in two keys at same time!",
				"Monkey no like atonal music!",
			))

			if (prob(40) && !ON_COOLDOWN(monkey, "monkey_sing_scream", 10 SECONDS))
				monkey.emote("scream")
