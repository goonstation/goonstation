/datum/component/reagent_overlay
	var/reagent_overlay_icon
	var/reagent_overlay_icon_state
	var/reagent_overlay_states
	var/reagent_overlay_scaling

TYPEINFO(/datum/component/reagent_overlay)
	initialization_args = list(
		ARG_INFO("reagent_overlay_icon", DATA_INPUT_TEXT, "The icon file that this container should for reagent overlays.", null),
		ARG_INFO("reagent_overlay_icon_state", DATA_INPUT_TEXT, "The icon state that this container should for reagent overlays.", null),
		ARG_INFO("reagent_overlay_states", DATA_INPUT_NUM, "The number of reagent overlay states that this container has.", 0),
		ARG_INFO("reagent_overlay_scaling", DATA_INPUT_TEXT, "The scaling that this container's reagent overlays should use.", RC_REAGENT_OVERLAY_SCALING_LINEAR),
	)

/datum/component/reagent_overlay/Initialize(reagent_overlay_icon, reagent_overlay_icon_state, reagent_overlay_states = 0, reagent_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_LINEAR)
	. = ..()
	if (!istype(src.parent, /atom))
		return COMPONENT_INCOMPATIBLE

	src.reagent_overlay_icon = reagent_overlay_icon
	src.reagent_overlay_icon_state = reagent_overlay_icon_state
	src.reagent_overlay_states = reagent_overlay_states
	src.reagent_overlay_scaling = reagent_overlay_scaling

	src.RegisterSignal(src.parent, COMSIG_ATOM_REAGENT_CHANGE, PROC_REF(update_reagent_overlay))
	src.update_reagent_overlay()

/datum/component/reagent_overlay/UnregisterFromParent()
	src.UnregisterSignal(src.parent, COMSIG_ATOM_REAGENT_CHANGE)
	var/atom/container = src.parent
	container.ClearSpecificOverlays("reagent_overlay")

	. = ..()

/// Updates the reagent overlay of the parent container.
/datum/component/reagent_overlay/proc/update_reagent_overlay()
	if (!src.reagent_overlay_states)
		return

	var/atom/container = src.parent
	var/reagent_state = src.get_reagent_state()

	if (reagent_state)
		var/image/reagent_image = image(src.reagent_overlay_icon, "f-[src.reagent_overlay_icon_state]-[reagent_state]")
		var/datum/color/average = container.reagents.get_average_color()
		average.a = max(average.a, RC_MINIMUM_REAGENT_ALPHA)
		reagent_image.color = average.to_rgba()
		container.AddOverlays(reagent_image, "reagent_overlay")

	else
		container.ClearSpecificOverlays("reagent_overlay")

/// Returns the numerical reagent state of the parent container.
/datum/component/reagent_overlay/proc/get_reagent_state()
	var/atom/container = src.parent
	var/datum/reagents/reagents = container.reagents

	// Show no reagent state only if the container is completely empty.
	if (reagents.total_volume <= 0)
		return 0

	// Show the last reagent state only if the container is full.
	if (reagents.total_volume >= reagents.maximum_volume)
		return src.reagent_overlay_states

	var/normalised_reagent_height = 0
	var/normalised_volume = reagents.total_volume / reagents.maximum_volume
	switch (src.reagent_overlay_scaling)
		// Volume of liquid will be directly proportional to height, so setting total volume to 1, the normalised height will be equal to the ratio.
		if (RC_REAGENT_OVERLAY_SCALING_LINEAR)
			normalised_reagent_height = normalised_volume

		// Vₛ = volume of sphere, r = radius of sphere, Vₗ = volume of liquid inside of sphere, h = height of liquid.
		// `Vₗ = ∫ π(r² - (z - r)²) dx` with lower and upper limits of 0 and h respectively gives the equation `Vₗ = πh²(r - h/3)`.
		// `Vₗ = πh²(r - h/3)` is very closely approximated by `Vₗ = -0.5Vₛ(cos(h(π / 2r)) - 1)` for 0 <= h <= 2r.
		// This permits us to efficiently solve for h without the need for the cubic formula: `h = (2r / π) * arccos(1 - 2(Vₗ / Vₛ))`
		// Setting Vₛ = 1 and normalising h to a range of 0-1 gives: `h = arccos(1 - 2Vₗ) / π`
		// Converting from radians to degrees: `h = arccos(1 - 2Vₗ) / 180`
		if (RC_REAGENT_OVERLAY_SCALING_SPHERICAL)
			normalised_reagent_height = arccos(1 - (2 * normalised_volume)) / 180

	return clamp(round(normalised_reagent_height * src.reagent_overlay_states, 1), 1, src.reagent_overlay_states - 1)
