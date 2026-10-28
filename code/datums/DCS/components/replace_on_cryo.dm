/datum/component/replace_on_cryo
	/// Only replace this item on permanent cryos
	var/only_on_perma_cryo = FALSE
	/// Replace with this type, rather than the type of the owner of this component
	var/replacement_type_override = null

TYPEINFO(/datum/component/replace_on_cryo)
	initialization_args = list(
		ARG_INFO("only_on_perma_cryo", DATA_INPUT_BOOL, "Only replace the item when permanently cryod with?"),
		ARG_INFO("replacement_type_override", DATA_INPUT_TYPE, "Override type to ship on replacement. Will default to component owner's type if null."),
	)

/datum/component/replace_on_cryo/Initialize(only_on_perma_cryo = FALSE, replacement_type_override = null)
	if (!ismovable(src.parent))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	START_TRACKING
	src.only_on_perma_cryo = only_on_perma_cryo
	src.replacement_type_override = replacement_type_override

/datum/component/replace_on_cryo/UnregisterFromParent()
	STOP_TRACKING
	. = ..()

/datum/component/replace_on_cryo/proc/get_replacement_type()
	return src.replacement_type_override || src.parent.type
