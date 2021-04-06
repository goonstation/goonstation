
/mob/living/silicon/ai/process_move()
	if(has_feet)
		return ..()
	return FALSE

/mob/living/silicon/ai/keys_changed(keys, changed)
	if(has_feet)
		return ..()

	if (changed & (KEY_EXAMINE|KEY_BOLT|KEY_OPEN|KEY_SHOCK))
		src.update_cursor()

	if (keys & changed & (KEY_FORWARD|KEY_BACKWARD|KEY_LEFT|KEY_RIGHT))
		src.tracker.cease_track()
		src.eye_view()
