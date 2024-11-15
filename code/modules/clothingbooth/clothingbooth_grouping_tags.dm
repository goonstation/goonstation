/* ----------------------- Seasonal ---------------------- */
ABSTRACT_TYPE(/datum/clothingbooth_grouping_tag/season)
/datum/clothingbooth_grouping_tag/season
	display_order = 1

/datum/clothingbooth_grouping_tag/season/summer
	name = "Summer"
	color = "#ff8fa5"

/datum/clothingbooth_grouping_tag/season/autumn
	name = "Autumn"
	color = "#ffa600"

/datum/clothingbooth_grouping_tag/season/winter
	name = "Winter"
	color = "#ade6e7"

/datum/clothingbooth_grouping_tag/season/spring
	name = "Spring"
	color = "#b9e78d"

/datum/clothingbooth_grouping_tag/season/spacemas
	name = "Spacemas"
	color = "#49db3c"

/datum/clothingbooth_grouping_tag/season/halloween
	name = "Halloween"
	color = "#f8861c"

/* ----------------------- Formality --------------------- */
ABSTRACT_TYPE(/datum/clothingbooth_grouping_tag/formality)
/datum/clothingbooth_grouping_tag/formality
	display_order = 2

/datum/clothingbooth_grouping_tag/formality/formal
	name = "Formal"

/datum/clothingbooth_grouping_tag/formality/casual
	name = "Casual"

/datum/clothingbooth_grouping_tag/formality/costume
	name = "Costume"

/* ---------------------- Collections -------------------- */
ABSTRACT_TYPE(/datum/clothingbooth_grouping_tag/group_set)
/datum/clothingbooth_grouping_tag/group_set
	display_order = 3

/datum/clothingbooth_grouping_tag/group_set/diner
	name = "Diner"

/datum/clothingbooth_grouping_tag/group_set/masquerade
	name = "Masquerade"

/datum/clothingbooth_grouping_tag/group_set/western
	name = "Western"
