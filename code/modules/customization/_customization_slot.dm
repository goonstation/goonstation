/// `/datum/customization_slot`
/// Holds all the customization information.
ABSTRACT_TYPE(/datum/customization_slot)
/datum/customization_slot
	var/slot_type = CUSTOMIZATION::SLOT::HAIR

	/// The color that gets used for determining your colors
	var/color = "#101010"
	/// The color that was set by the player's preferences
	var/color_original = "#101010"
	/// The hair style / detail thing that gets displayed on your spaceperson
	var/datum/customization_style/style = new /datum/customization_style/hair/short/short
	/// The hair style / detail thing that was set by the player in their settings
	var/datum/customization_style/style_original = new /datum/customization_style/none
	/// The Y offset to display this image
	var/offset_y = 0

ABSTRACT_TYPE(/datum/customization_slot/hair)
/datum/customization_slot/hair
	slot_type = CUSTOMIZATION::SLOT::HAIR

/datum/customization_slot/hair/bottom
	style =  new /datum/customization_style/hair/short/short

/datum/customization_slot/hair/middle
	style =  new /datum/customization_style/none

/datum/customization_slot/hair/top
	style =  new /datum/customization_style/none
