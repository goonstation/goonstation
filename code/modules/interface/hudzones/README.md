# HUDZones

HUDZones are a new way to manage HUD elements on a mob's screen.
They're a rectangular region on a screen that registered elements will automatically position themselves in as you add more.

This allows for wrapping around functionality, for example if you have hud elements that aren't always visible.

If you are developing a new zone, it's recommended to take hud_layout_guide.png and color it in as you go.
This makes it easier to see where things are in relation to each other.

**It's important to keep in mind that coordinates are relative to the bottom left, with the corner being 1,1.**

## **Only supports elements that are 32px/'1' height (variable width is fine).**

**Currently, only widescreen is supported.**

## Example

```dm
/mob/living/critter/small_animal/pig/feral_hog/vorbis/New(loc)
	. = ..()
	// Create a hud zone
	var/list/zone_coords = list(x_low = 1, y_low = 1, x_high = 2, y_high = 5) // Lower left
	var/datum/hud_zone/new_zone = src.hud.add_hud_zone(zone_coords, "vorbis_abilities")

	// Create hud elements to add to the zone
	var/atom/movable/screen/hud/volume = new
	volume.icon = 'icons/mob/hud_robot.dmi'
	volume.icon_state = "charge1"

	var/atom/movable/screen/hud/scream_meter = new
	scream_meter.icon = 'icons/ui/context32x16.dmi'
	scream_meter.icon_state = "bg1"

	// Register the hud elements with the zone
	new_zone.register_element(new/datum/hud_element(volume), "volume")
	new_zone.register_element(new/datum/hud_element(scream_meter, width = 2), "scream_meter")
```
