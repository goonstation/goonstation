/atom/movable/screen/hud/pod/read_only/healthbars
	icon = null
	var/atom/movable/screen/healthbar/health/health_bar = null
	var/atom/movable/screen/healthbar/fuel/fuel_bar = null

/atom/movable/screen/hud/pod/read_only/healthbars/New()
	. = ..()

	src.health_bar = new(src)
	src.health_bar.pixel_y = 8
	src.health_bar.vis_flags |= VIS_INHERIT_ID
	src.vis_contents += src.health_bar

	src.fuel_bar = new(src)
	src.fuel_bar.pixel_y = -8
	src.fuel_bar.vis_flags |= VIS_INHERIT_ID
	src.vis_contents += src.fuel_bar


/atom/movable/screen/healthbar
	var/atom/movable/screen/hud/pod/read_only/healthbars/parent = null
	var/bar_name = null
	var/bar_length = 3

	var/atom/movable/screen/health_overlay = null
	var/atom/movable/screen/shield_overlay = null

/atom/movable/screen/healthbar/New(atom/movable/screen/hud/pod/read_only/healthbars/parent)
	. = ..()

	src.parent = parent

	var/atom/movable/screen/bar_icon = new /atom/movable/screen()
	bar_icon.icon = 'icons/ui/vehicle16x16.dmi'
	bar_icon.icon_state = src.bar_name
	bar_icon.pixel_x = -20
	bar_icon.pixel_y = 8
	bar_icon.vis_flags |= VIS_INHERIT_ID
	src.vis_contents += bar_icon

	for (var/i in 1 to src.bar_length)
		var/atom/movable/screen/S = new /atom/movable/screen()
		S.name = src.bar_name
		S.icon = 'icons/obj/colosseum.dmi'
		S.pixel_x = 32 * (i - 1)

		if (i == 1)
			S.icon_state = "health_bar_left"

		else if (i == src.bar_length)
			S.icon_state = "health_bar_right"

		else
			S.icon_state = "health_bar_center"

		S.vis_flags |= VIS_INHERIT_ID
		src.vis_contents += S

	src.health_overlay = new /atom/movable/screen()
	src.health_overlay.icon = 'icons/obj/colosseum.dmi'
	src.health_overlay.icon_state = "health"
	src.health_overlay.vis_flags |= VIS_INHERIT_ID
	src.vis_contents += src.health_overlay

	src.shield_overlay = new /atom/movable/screen()
	src.shield_overlay.icon = 'icons/obj/colosseum.dmi'
	src.shield_overlay.icon_state = "health"
	src.shield_overlay.vis_flags |= VIS_INHERIT_ID
	src.vis_contents += src.shield_overlay

	src.update_health_overlays(50, 100, 0, 0)

/atom/movable/screen/healthbar/proc/update_health_overlays(health_value, health_max, shield_value, shield_max)
	var/text_colour = null
	if ((health_value / health_max) > 0.5)
		text_colour = "#000000"
	else
		text_colour = "#d9e8f2"

	src.update_bar_overlay(src.health_overlay, health_value, health_max, r_empty = 204, g_full = 204, text_colour = text_colour)
	src.update_bar_overlay(src.shield_overlay, shield_value, shield_max, g_empty = 255, b_empty = 255, g_full = 102, b_full = 102)

/atom/movable/screen/healthbar/proc/update_bar_overlay(atom/movable/screen/bar_overlay, value, max_value, r_empty = 0, g_empty = 0, b_empty = 0, r_full = 0, g_full = 0, b_full = 0, text_colour)
	var/normalised_length = 0
	var/scaled_length = 0
	var/full_offset = 32 * (src.bar_length - 1)

	if (value && max_value)
		normalised_length = value / max_value
		scaled_length = normalised_length * src.bar_length

		// Slightly rescale the bar so that the two pixels at either side aren't covered by it.
		scaled_length *= ((32 * src.bar_length) - 2) / (32 * src.bar_length)
		bar_overlay.pixel_x = -1

	bar_overlay.transform = matrix(scaled_length, 0, full_offset - (16 * (scaled_length - 1)), 0, 1, 0)
	bar_overlay.color = rgb(
		lerp(r_empty, r_full, normalised_length),
		lerp(g_empty, g_full, normalised_length),
		lerp(b_empty, b_full, normalised_length),
	)

	if (!text_colour)
		return

	var/image/hundreds = null
	var/image/tens = null
	var/image/units = null

	if (value < 0)
		tens = image('icons/obj/colosseum.dmi', "INF")

	else
		value = clamp(value, 0, 999)

		if (value >= 100)
			hundreds = image('icons/obj/colosseum.dmi', "[round(value / 100)]")
			hundreds.appearance_flags |= RESET_COLOR | RESET_TRANSFORM
			hundreds.color = text_colour
			hundreds.pixel_x = full_offset - 8

		if (value >= 10)
			tens = image('icons/obj/colosseum.dmi', "[round((value / 10) % 10)]")
			tens.appearance_flags |= RESET_COLOR | RESET_TRANSFORM
			tens.color = text_colour
			tens.pixel_x = full_offset

		units = image('icons/obj/colosseum.dmi', "[round(value % 10)]")
		units.appearance_flags |= RESET_COLOR | RESET_TRANSFORM
		units.color = text_colour
		units.pixel_x = full_offset + 8

	bar_overlay.UpdateOverlays(hundreds, "hundreds")
	bar_overlay.UpdateOverlays(tens, "tens")
	bar_overlay.UpdateOverlays(units, "units")


/atom/movable/screen/healthbar/health
	bar_name = "health"


/atom/movable/screen/healthbar/fuel
	bar_name = "fuel"
