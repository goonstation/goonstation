/obj/say_message_gc
	name = "say message GC test fixture"

/datum/unit_test/say_message_gc/Run()
	var/obj/speaker = src.allocate(/obj/say_message_gc)
	var/datum/weakref/say_message_ref = src.say_and_release_message(speaker)

	TEST_ASSERT(isnull(say_message_ref.deref()), "say_message did not GC after say()")

/datum/unit_test/say_message_gc/proc/say_and_release_message(obj/speaker)
	RETURN_TYPE(/datum/weakref)
	var/datum/say_message/message = speaker.say("say_message GC test")
	return get_weakref(message)
