/// Used to test the game for issues with different types of color blindness
/// WARNING ASSHOLE: Because we can only apply matrixes, and can't preform gamma correction
/// https://web.archive.org/web/20220227030606/https://ixora.io/projects/colorblindness/color-blindness-simulation-research/
/// The results of this tool aren't perfect. It's way better then nothing, but IT IS NOT A PROPER SIMULATION
/// Please do not make us look like assholes by assuming it is. Thanks.
/datum/colorblind_tester
	/// List of simulated blindness -> matrix to use
	/// Most of these matrixes are based off https://web.archive.org/web/20220227030606/https://ixora.io/projects/colorblindness/color-blindness-simulation-research/
	/// AGAIN, THESE ARE NOT PERFECT BECAUSE WE CANNOT COMPUTE GAMMA CORRECTION, AND CONVERT SRGB TO LINEAR RGB
	/// Do not assume this is absolute
	var/list/color_matrixes = list(
		"Protanopia" = list(0.56,0.43,0,0, 0.55,0.44,0,0, 0,0.24,0.75,0, 0,0,0,1, 0,0,0,0),
		"Deuteranopia" = list(0.62,0.37,0,0, 0.70,0.30,0,0, 0,0.30,0.70,0, 0,0,0,1, 0,0,0,0),
		"Tritanopia" = list(0.95,0.5,0,0, 0,0.43,0.56,0, 0,0.47,0.52,0, 0,0,0,1, 0,0,0,0),
		"Achromatopsia" = list(0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0,0,0,1, 0,0,0,0),
	)
	var/list/descriptions = list(
		"Protanopia" = "No long wavelength cones, ends up not being able to see red light. Troubles with blue/green and red/green",
		"Deuteranopia" = "No medium wavelength cones. Because the red and green parts of light nearly overlap in this space, trouble is mostly with red/green",
		"Tritanopia" = "No short wavelength cones, so trouble with blue/green and yellow/violet. Aggressively rare, and equally hard to simulate",
		"Achromatopsia" = "No cones at all, which leads to something close to monochromatic vision"
	)
	var/selected_type

/client/proc/open_colorblind_test()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Colorblind Testing"
	set desc = "Change your view to a budget version of colorblindness to test for usability"
	var/static/datum/colorblind_tester/ye_olde_tester
	ye_olde_tester ||= new
	ye_olde_tester.ui_interact(mob)

/datum/colorblind_tester/ui_state(mob/user)
	return tgui_admin_state

/datum/colorblind_tester/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ColorBlindTester")
		ui.open()

/datum/colorblind_tester/ui_data()
	var/list/data = list()
	data["details"] = descriptions
	data["selected"] = selected_type
	return data

/datum/colorblind_tester/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_matrix")
			set_selected_type(params["name"], ui.user.client)
			return TRUE
		if("clear_matrix")
			set_selected_type(null, ui.user.client)
			return TRUE

/datum/colorblind_tester/proc/set_selected_type(selected, client/user)
	if(selected == selected_type)
		return
	selected_type = selected
	var/target_color = !isnull(selected_type) ? color_matrixes[selected_type] : null
	user.color = target_color
	// Skip a few specific planes.
	var/static/list/planes_to_skip = list(
		"[PLANE_LIGHTING]", // skip lighting because it interacts wierdly.
		"[PLANE_ABOVE_LIGHTING]", // see above
		"[PLANE_AMBIENT_LIGHTING]", // see above
	)
	// go through and apply the selected color matrix to all planes that ignore client color
	// ONLY to planes that ignore client color or you get stacked effects
	for(var/plane_key in (user.plane_parents - planes_to_skip))
		var/atom/movable/screen/plane_parent/plane = user.plane_parents[plane_key]
		if(plane.appearance_flags & NO_CLIENT_COLOR)
			plane.color = target_color
