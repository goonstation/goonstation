// Spread flags. Determines what slots are taken into account during a permeability scan.
#define SPREAD_FACE 1
#define SPREAD_BODY 2
#define SPREAD_HANDS 4
#define SPREAD_AIR 8


#define COOLDOWN_MULTIPLIER 1

#define INFECT_NONE 0
#define INFECT_TOUCH 1
#define INFECT_AREA 3
#define INFECT_AREA_LARGE 5

// --SYMPTOM RARITIES--
// All symptom contains a rarity value. Use these constants to describe their rarity.
// For malevolent symptoms:
// RARITY_VERY_COMMON: The symptoms are barely noticable. Should not affect gameplay significantly or infect in a large area.
// RARITY_COMMON: The symptoms are noticeable, and may cause occasional inconveniences. May infect in a large area (instead).
// RARITY_UNCOMMON: The symptoms may do occasional damage or longer stuns.
// RARITY_RARE: The symptoms have a ramp in stages from relatively mundane to rather deadly.
// RARITY_VERY_RARE: You are fucked.
// For benevolent symptoms:
// RARITY_VERY_COMMON: As for malevolents, except in the positive direction obviously.
// RARITY_COMMON: The symptom may heal slightly or give an insignificant boost to any statistic.
// RARITY_UNCOMMON: Commonly symptoms which may give you an upper hand in a fight.
// RARITY_RARE: Power-healing and heavy offense/defense symptoms. May contain downsides.
// RARITY_VERY_RARE: God complex with actual godlike powers, traitor items infused in body. Should contain flipsides.
// And for all:
// RARITY_ABSTRACT: Used strictly for categorization. ABSTRACT symptoms will never appear.
//                  ie. if lingual is a symptom category with multiple subsymptoms (for easy mutex), it should be abstract.
#define RARITY_VERY_COMMON 1
#define RARITY_COMMON 2
#define RARITY_UNCOMMON 3
#define RARITY_RARE 4
#define RARITY_VERY_RARE 5
#define RARITY_ABSTRACT 0
