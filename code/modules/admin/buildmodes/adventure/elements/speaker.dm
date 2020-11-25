/datum/puzzlewizard/speaker
	name = "AB CREATE: Speaker"
	var/speaker_name
	var/speaker_type
	var/speaker_anchored = 1
	var/color_rgb = ""
	var/message

	initialize()
		speaker_name = input("Speaker name", "Speaker name", "speaker") as text
		speaker_type = input("Speaker type", "Speaker type", "headset") in list("headset", "intercom", "radio", "radiohorn", "invisible")
		if (speaker_type != "invisible")
			var/anchstr = input("Is the speaker anchored (unabled to be pulled)?", "Anchored", "yes") in list("yes", "no")
			speaker_anchored = (anchstr == "yes") ? 1 : 0
			color_rgb = input("Color", "Color", "#ffffff") as color
		message = input("Speaker message", "Speaker message") as text
		boutput(usr, "<span class='notice'>Left click to place speaker, right click to simulate message. Ctrl+click anywhere to finish.</span>")

	build_click(var/mob/user, var/datum/buildmode_holder/holder, var/list/pa, var/atom/object)
		if (pa.Find("left"))
			var/turf/T = get_turf(object)
			if (pa.Find("ctrl"))
				finished = 1
				return
			if (T)
				var/obj/adventurepuzzle/triggerable/speaker/speaker = new /obj/adventurepuzzle/triggerable/speaker(T)
				speaker.name = speaker_name
				speaker.speaker_type = speaker_type
				speaker.icon_state = "speaker_[speaker_type]"
				speaker.set_dir(holder.dir)
				speaker.anchored = speaker_anchored
				speaker.message = message
				if (speaker_type == "invisible")
					speaker.invisibility = 20
				else
					SPAWN_DBG(1 SECOND)
						speaker.color = color_rgb
		else if (pa.Find("right"))
			if (istype(object, /obj/adventurepuzzle/triggerable/speaker))
				object:speak()

/obj/adventurepuzzle/triggerable/speaker
	name = "speaker"
	desc = "A strange device that emits sound, truly the future."
	anchored = 1
	var/speaker_type
	var/message

	var/static/list/triggeracts = list("Do nothing" = "nop", "Speak message" = "speak")

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("speak")
				src.speak()
			else
				return

	proc/speak()
		for (var/mob/O in all_hearers(5, src.loc))
			O.show_message("<span class='game say bold'><span class='name'>[name]</span> says, <span class='message'>\"[message]\"</span></span>", 2)
		return

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].message"] << message
		F["[path].speaker_type"] << speaker_type

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].message"] >> message
		F["[path].speaker_type"] >> speaker_type
		if (speaker_type == "invisible")
			src.invisibility = 20
