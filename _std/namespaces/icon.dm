CREATE_NAMESPACE(ICON)

ADD_TO_NAMESPACE(ICON)(var/alist/states_cache = alist())
ADD_TO_NAMESPACE(ICON)(proc/get_icon_states(icon))
	if (!(icon in ICON.states_cache))
		ICON.states_cache[icon] = icon_states(icon)
	return ICON.states_cache[icon]
