/obj/say_message_gc
	name = "say message GC test fixture"

/datum/unit_test/regression/say_message_gc/Run()
	var/obj/speaker = src.allocate(/obj/say_message_gc)
	var/obj/listener = src.allocate(/obj/say_message_gc)
	var/datum/listen_module_tree/listen_tree = listener.ensure_listen_tree()
	listen_tree.AddListenInput(LISTEN_INPUT_OUTLOUD)
	listen_tree.enable()

	var/datum/weakref/signal_recipient_ref = src.say_to_listener_and_release_message(speaker, listener)

	TEST_ASSERT(isnull(signal_recipient_ref.deref()), "say_message family with listeners did not GC")

/datum/unit_test/regression/say_message_gc/proc/say_to_listener_and_release_message(obj/speaker, obj/listener)
	RETURN_TYPE(/datum/weakref)
	var/datum/say_message/message = speaker.say("flush registration cleanup test", atom_listeners_override = list(listener))
	return get_weakref(message.signal_recipient)
