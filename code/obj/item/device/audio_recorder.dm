// in types.dm
#define TR_CAT_AUDIO_TRACKING_OBJS "audio_tracking"



/obj/item/device/audio_recorder
	name = "audio recorder"
	desc = "A fairly spartan recording device."
	icon_state = "recorder"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	mats = null

	var/recording = FALSE
	var/list
	var/action_id = 0

	New()
		..()

	proc/start_playing()


	proc/start_recording()
		src.recording = TRUE
		START_TRACKING_CAT(TR_CAT_AUDIO_TRACKING_OBJS)

	proc/stop_recording()
		src.recording = FALSE
		STOP_TRACKING_CAT(TR_CAT_AUDIO_TRACKING_OBJS)

	proc/hear_sound()


	disposing()
		if(src.recording)
			src.stop_recording()
		..()
