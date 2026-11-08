//------------ Customization ------------//
/// Namespace for `/datum/customizationHolder` and `/datum/customization_style`.
CREATE_NAMESPACE(CUSTOMIZATION)

/// Customization style slots.
CREATE_NAMESPACE(CUSTOMIZATION, SLOT)

/// Customization layers.
CREATE_NAMESPACE(CUSTOMIZATION, LAYER)

// todo implement this fully to replace CUSTOMIZATION::HAIR
// CREATE_NAMESPACE(CUSTOMIZATION, TYPE)

// todo deprecate CUSTOMIZATION::HAIR
CREATE_NAMESPACE(CUSTOMIZATION, HAIR)

//------------ Hair ------------//
// Hair slot type.
ADD_TO_NAMESPACE(CUSTOMIZATION, SLOT)(var/const/HAIR = "slot__hair")

// Hair slot layers.
ADD_TO_NAMESPACE(CUSTOMIZATION, LAYER)(var/const/HAIR_BOTTOM = "layer__hair_bottom")
ADD_TO_NAMESPACE(CUSTOMIZATION, LAYER)(var/const/HAIR_MIDDLE = "layer__hair_middle")
ADD_TO_NAMESPACE(CUSTOMIZATION, LAYER)(var/const/HAIR_TOP = "layer__hair_top")

// Hair types.
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/SHORT = "type__hair_short")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/LONG = "type__hair_long")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/HAIRUP = "type__hair_hairup")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/GIMMICK = "type__hair_gimmick")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/MOUSTACHE = "type__hair_moustache")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/BEARD = "type__hair_beard")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/SIDEBURNS = "type__hair_sideburns")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/EYEBROWS = "type__hair_eyebrows")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/MAKEUP = "type__hair_makeup")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/BIOLOGICAL = "type__hair_biological")

// Hair type groups.
/// Head hair types. Can be cut with scissors.
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/list/head_hair = list(
	CUSTOMIZATION::HAIR::SHORT,
	CUSTOMIZATION::HAIR::LONG,
	CUSTOMIZATION::HAIR::HAIRUP,
	CUSTOMIZATION::HAIR::GIMMICK,
))
/// Facial hair types.
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/list/facial_hair = list(
	CUSTOMIZATION::HAIR::MOUSTACHE,
	CUSTOMIZATION::HAIR::BEARD,
	CUSTOMIZATION::HAIR::SIDEBURNS,
))
/// Facial hair types + eyebrows. Can be cut with a razor.
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/list/razor_hair = list(
	CUSTOMIZATION::HAIR::MOUSTACHE,
	CUSTOMIZATION::HAIR::BEARD,
	CUSTOMIZATION::HAIR::SIDEBURNS,
	CUSTOMIZATION::HAIR::EYEBROWS,
))

//------------ Helpers ------------//
/// Sort order for hair types. Always mirror with any new `/datum/customization_style` types.
ADD_TO_NAMESPACE(CUSTOMIZATION)(var/list/sort_order = list(
	CUSTOMIZATION::HAIR::SHORT,
	CUSTOMIZATION::HAIR::LONG,
	CUSTOMIZATION::HAIR::HAIRUP,
	CUSTOMIZATION::HAIR::GIMMICK,
	CUSTOMIZATION::HAIR::MOUSTACHE,
	CUSTOMIZATION::HAIR::BEARD,
	CUSTOMIZATION::HAIR::SIDEBURNS,
	CUSTOMIZATION::HAIR::EYEBROWS,
	CUSTOMIZATION::HAIR::MAKEUP,
	CUSTOMIZATION::HAIR::BIOLOGICAL,
))
