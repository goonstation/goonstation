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
/// Wood, or wood-like
#define MATERIAL_WOOD 64

/// Global static list of rarity color associations
var/global/static/list/RARITY_COLOR = list("#9d9d9d", "#ffffff", "#1eff00", "#0070dd", "#a335ee", "#ff8000", "#ff0000")

/// Material category names as displayed in fabricators
/// see match_material_pattern() for exact definitions
var/global/list/material_category_names = list(
	"ALL"   = "Any Material",
	"CON-1" = "Conductive Material",
	"CON-2" = "High Energy Conductor",
	"CRY-1" = "Crystal",
	"DEN-1" = "High Density Matter",
	"DEN-2" = "Very High Density Matter",
	"CRY-2" = "Extraordinarily Dense Crystalline Matter",
	"FAB-1" = "Fabric",
	"INS-1" = "Insulative Material",
	"INS-2" = "Highly Insulative Material",
	"MET-1" = "Metal",
	"MET-2" = "Sturdy Metal",
	"MET-3" = "Extremely Tough Metal",
	"POW-1" = "Power Source",
	"POW-2" = "Significant Power Source",
	"POW-3" = "Extreme Power Source",
	"REF-1" = "Reflective Material",
	"ORG|RUB" = "Organic or Rubber Material",
	"RUB" = "Rubber Material",
	"WOOD" = "Wood",
	"GEM-1" = "Any Gemstone"
)

#define TRIGGERS_ON_BULLET "triggersOnBullet"
#define TRIGGERS_ON_EAT "triggersOnEat"
#define TRIGGERS_ON_TEMP "triggersTemp"
#define TRIGGERS_ON_CHEM "triggersChem"
#define TRIGGERS_ON_PICKUP "triggersPickup"
#define TRIGGERS_ON_DROP "triggersDrop"
#define TRIGGERS_ON_EXPLOSION "triggersExp"
#define TRIGGERS_ON_ADD "triggersOnAdd"
#define TRIGGERS_ON_LIFE "triggersOnLife"
#define TRIGGERS_ON_ATTACK "triggersOnAttack"
#define TRIGGERS_ON_ATTACKED "triggersOnAttacked"
#define TRIGGERS_ON_ENTERED "triggersOnEntered"
#define TRIGGERS_ON_REMOVE "triggersOnRemove"
#define TRIGGERS_ON_HIT "triggersOnHit"
#define TRIGGERS_ON_BLOBHIT "triggersOnBlobHit"


/// This contains the names of the trigger lists on materials. Required for copying materials. Remember to keep this updated if you add new triggers.
var/global/list/triggerVars = list(
	TRIGGERS_ON_BULLET,
	TRIGGERS_ON_EAT,
	TRIGGERS_ON_TEMP,
	TRIGGERS_ON_CHEM,
	TRIGGERS_ON_PICKUP,
	TRIGGERS_ON_DROP,
	TRIGGERS_ON_EXPLOSION,
	TRIGGERS_ON_ADD,
	TRIGGERS_ON_LIFE,
	TRIGGERS_ON_ATTACK,
	TRIGGERS_ON_ATTACKED,
	TRIGGERS_ON_ENTERED,
	TRIGGERS_ON_REMOVE,
	TRIGGERS_ON_HIT,
	TRIGGERS_ON_BLOBHIT,
)
