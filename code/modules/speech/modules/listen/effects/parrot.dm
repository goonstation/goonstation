/datum/listen_module/effect/parrot
	id = LISTEN_EFFECT_PARROT

/datum/listen_module/effect/parrot/process(datum/say_message/message)
	var/obj/critter/parrot/parrot = src.parent_tree.listener_parent
	if (!istype(parrot) || !parrot.alive || parrot.sleeping || !parrot.text)
		return

	var/boost = 0
	if ((message.flags & SAYFLAG_SINGING) && ismob(message.speaker))
		if (message.flags & (SAYFLAG_LOUD_SINGING | SAYFLAG_BAD_SINGING))
			SPAWN(0.3 SECONDS)
				if (BOUNDS_DIST(parrot, message.speaker) == 0)
					parrot.CritterAttack(message.speaker)
				else
					FLICK("[parrot.species]-flaploop", parrot)

		else
			SPAWN(rand(4, 10))
				parrot.chatter(TRUE)

		boost = parrot.signing_learn_boost

	if (prob(parrot.learn_words_chance + boost))
		parrot.learn_stuff(message.content)

	if (prob(parrot.learn_phrase_chance + boost))
		parrot.learn_stuff(message.content, TRUE)
