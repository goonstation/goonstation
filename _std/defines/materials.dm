//material statistic property identifier flags
///ID for the electrical conductivity stat
#define MATERIAL_PROPERTY_ELECTRICAL (1<<0)
///ID for the thermal conductivity stat
#define MATERIAL_PROPERTY_THERMAL (1<<1)
///ID for the hardness stat
#define MATERIAL_PROPERTY_HARDNESS (1<<2)
///ID for the density stat
#define MATERIAL_PROPERTY_DENSITY (1<<3)
///ID for the chemical reactivity stat
#define MATERIAL_PROPERTY_CHEMICAL (1<<4)
///ID for the radioactivity stat
#define MATERIAL_PROPERTY_RADIOACTIVE (1<<5)
///ID for the neutron radioactivity stat
#define MATERIAL_PROPERTY_N_RADIOACTIVE (1<<6)

//material boolean property flags
/// Does it burn?
#define MATERIAL_FLAG_FLAMMABLE (1<<0)
/// Is it highly reflective?
#define MATERIAL_FLAG_REFLECTIVE (1<<1)
/// Does it come from a living thing?
#define MATERIAL_FLAG_BIOLOGICAL (1<<2)
/// Could a living thing eat it?
#define MATERIAL_FLAG_EDIBLE (1<<3)
/// Is it related to ghosts or spirits?
#define MATERIAL_FLAG_GHOSTLY (1<<4)

/// Global static list of rarity color associations
var/global/static/list/RARITY_COLOR = list("#9d9d9d", "#ffffff", "#1eff00", "#0070dd", "#a335ee", "#ff8000", "#ff0000")

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
