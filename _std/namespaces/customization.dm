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
ADD_TO_NAMESPACE(CUSTOMIZATION, SLOT)(var/const/HAIR = "slot-hair")

// Hair slot layers.
ADD_TO_NAMESPACE(CUSTOMIZATION, LAYER)(var/const/HAIR_BOTTOM = "layer_hair-bottom")
ADD_TO_NAMESPACE(CUSTOMIZATION, LAYER)(var/const/HAIR_MIDDLE = "layer_hair-middle")
ADD_TO_NAMESPACE(CUSTOMIZATION, LAYER)(var/const/HAIR_TOP = "layer_hair-top")

// Hair types.
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/SHORT = "type_hair-short")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/LONG = "type_hair-long")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/HAIRUP = "type_hair-hairup")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/GIMMICK = "type_hair-gimmick")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/MOUSTACHE = "type_hair-moustache")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/BEARD = "type_hair-beard")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/SIDEBURNS = "type_hair-sideburns")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/EYEBROWS = "type_hair-eyebrows")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/MAKEUP = "type_hair-makeup")
ADD_TO_NAMESPACE(CUSTOMIZATION, HAIR)(var/const/BIOLOGICAL = "type_hair-biological")

//------------ Customization style groups ------------//
/// Head hair types. Can be cut with scissors.
ADD_TO_NAMESPACE(CUSTOMIZATION)(var/list/group__hair_head = list(
	CUSTOMIZATION::HAIR::SHORT,
	CUSTOMIZATION::HAIR::LONG,
	CUSTOMIZATION::HAIR::HAIRUP,
	CUSTOMIZATION::HAIR::GIMMICK,
))

/// Facial hair types.
ADD_TO_NAMESPACE(CUSTOMIZATION)(var/list/group__hair_facial = list(
	CUSTOMIZATION::HAIR::MOUSTACHE,
	CUSTOMIZATION::HAIR::BEARD,
	CUSTOMIZATION::HAIR::SIDEBURNS,
))

/// Facial hair types + eyebrows. Can be cut with a razor.
ADD_TO_NAMESPACE(CUSTOMIZATION)(var/list/group__hair_razor = list(
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
