//------------ Customization ------------//
/// Namespace for `/datum/customizationHolder` and `/datum/customization_style`.
CREATE_NAMESPACE(CUSTOMIZATION)

/// `/datum/customizationHolder` layers. E.g. bottom, middle, top hair layers.
CREATE_NAMESPACE(CUSTOMIZATION, LAYER)

/// `/datum/customizationHolder` slots. E.g. hair, underwear.
CREATE_NAMESPACE(CUSTOMIZATION, SLOT)

/// Customization style categories. E.g. short, long hair.
CREATE_NAMESPACE(CUSTOMIZATION, CATEGORY)

//------------ Hair ------------//
/// Hair slot.
ADD_TO_NAMESPACE(CUSTOMIZATION, SLOT)(var/const/HAIR = "slot-hair")

// Hair slot layers.
ADD_TO_NAMESPACE(CUSTOMIZATION, LAYER)(var/const/HAIR_BOTTOM = "layer_hair-bottom")
ADD_TO_NAMESPACE(CUSTOMIZATION, LAYER)(var/const/HAIR_MIDDLE = "layer_hair-middle")
ADD_TO_NAMESPACE(CUSTOMIZATION, LAYER)(var/const/HAIR_TOP = "layer_hair-top")

// Hair types.
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_SHORT = "cat_hair-short")
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_LONG = "cat_hair-long")
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_HAIRUP = "cat_hair-hairup")
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_GIMMICK = "cat_hair-gimmick")
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_MOUSTACHE = "cat_hair-moustache")
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_BEARD = "cat_hair-beard")
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_SIDEBURNS = "cat_hair-sideburns")
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_EYEBROWS = "cat_hair-eyebrows")
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_MAKEUP = "cat_hair-makeup")
ADD_TO_NAMESPACE(CUSTOMIZATION, CATEGORY)(var/const/HAIR_BIOLOGICAL = "cat_hair-biological")

//------------ Customization style groups ------------//
/// Head hair types. Can be cut with scissors.
ADD_TO_NAMESPACE(CUSTOMIZATION)(var/list/group__hair_head = list(
	CUSTOMIZATION::CATEGORY::HAIR_SHORT,
	CUSTOMIZATION::CATEGORY::HAIR_LONG,
	CUSTOMIZATION::CATEGORY::HAIR_HAIRUP,
	CUSTOMIZATION::CATEGORY::HAIR_GIMMICK,
))

/// Facial hair types.
ADD_TO_NAMESPACE(CUSTOMIZATION)(var/list/group__hair_facial = list(
	CUSTOMIZATION::CATEGORY::HAIR_MOUSTACHE,
	CUSTOMIZATION::CATEGORY::HAIR_BEARD,
	CUSTOMIZATION::CATEGORY::HAIR_SIDEBURNS,
))

/// Facial hair types + eyebrows. Can be cut with a razor.
ADD_TO_NAMESPACE(CUSTOMIZATION)(var/list/group__hair_razor = list(
	CUSTOMIZATION::CATEGORY::HAIR_MOUSTACHE,
	CUSTOMIZATION::CATEGORY::HAIR_BEARD,
	CUSTOMIZATION::CATEGORY::HAIR_SIDEBURNS,
	CUSTOMIZATION::CATEGORY::HAIR_EYEBROWS,
))

//------------ Helpers ------------//
/// Sort order for hair types. Always mirror with any new `/datum/customization_style` types.
ADD_TO_NAMESPACE(CUSTOMIZATION)(var/list/sort_order = list(
	CUSTOMIZATION::CATEGORY::HAIR_SHORT,
	CUSTOMIZATION::CATEGORY::HAIR_LONG,
	CUSTOMIZATION::CATEGORY::HAIR_HAIRUP,
	CUSTOMIZATION::CATEGORY::HAIR_GIMMICK,
	CUSTOMIZATION::CATEGORY::HAIR_MOUSTACHE,
	CUSTOMIZATION::CATEGORY::HAIR_BEARD,
	CUSTOMIZATION::CATEGORY::HAIR_SIDEBURNS,
	CUSTOMIZATION::CATEGORY::HAIR_EYEBROWS,
	CUSTOMIZATION::CATEGORY::HAIR_MAKEUP,
	CUSTOMIZATION::CATEGORY::HAIR_BIOLOGICAL,
))
