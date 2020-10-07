#define VALUE_CURRENT 1
#define VALUE_MAX 2
#define VALUE_MIN 4

//materials

/// Crystals, Minerals
#define MATERIAL_CRYSTAL 1
/// Metals
#define MATERIAL_METAL 2
/// Cloth or cloth-like
#define MATERIAL_CLOTH 4
/// Coal, meat and whatnot.
#define MATERIAL_ORGANIC 8
/// Is energy or outputs energy.
#define MATERIAL_ENERGY 16
/// Rubber , latex etc
#define MATERIAL_RUBBER 32

/// Global static list of rarity color associations
var/global/static/list/RARITY_COLOR = list("#9d9d9d", "#ffffff", "#1eff00", "#0070dd", "#a335ee", "#ff8000", "#ff0000")
