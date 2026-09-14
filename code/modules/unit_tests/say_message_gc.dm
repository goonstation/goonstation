/obj/say_message_gc
	name = "say message GC test fixture"

/datum/unit_test/say_message_gc_without_listener/Run()
	var/obj/speaker = src.allocate(/obj/say_message_gc)
	var/datum/weakref/say_message_ref = src.say_and_release_message(speaker)

	TEST_ASSERT(isnull(say_message_ref.deref()), "say_message without listeners did not GC")

/datum/unit_test/say_message_gc_without_listener/proc/say_and_release_message(obj/speaker)
	RETURN_TYPE(/datum/weakref)
	var/datum/say_message/message = speaker.say("say_message GC test")
	return get_weakref(message)

/datum/unit_test/say_message_flush_registration_cleanup/Run()
	var/obj/speaker = src.allocate(/obj/say_message_gc)
	var/obj/listener = src.allocate(/obj/say_message_gc)
	var/datum/listen_module_tree/listen_tree = listener.ensure_listen_tree()
	listen_tree.AddListenInput(LISTEN_INPUT_OUTLOUD)
	listen_tree.enable()

	var/datum/weakref/say_message_ref = src.say_to_listener_and_release_message(speaker, listener)

	TEST_ASSERT(isnull(say_message_ref.deref()), "say_message with listeners did not GC")

/datum/unit_test/say_message_flush_registration_cleanup/proc/say_to_listener_and_release_message(obj/speaker, obj/listener)
	RETURN_TYPE(/datum/weakref)
	var/datum/say_message/message = speaker.say("flush registration cleanup test", atom_listeners_override = list(listener))
	return get_weakref(message)
