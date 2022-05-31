// Spread flags. Determines what slots are taken into account during a permeability scan.
#define SPREAD_FACE 1
#define SPREAD_BODY 2
#define SPREAD_HANDS 4
#define SPREAD_AIR 8

#define COOLDOWN_MULTIPLIER 1

#define INFECT_NONE 0
#define INFECT_TOUCH 1
#define INFECT_AREA 3

#define REAGENT_CURE_THRESHOLD 10


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


// --SYMPTOM THREAT--
// All symptoms are catagorized with a threat value to describe the scope of their impact.
// Benign symptoms are negative. Malign symptoms are positive.
// THREAT_BENETYPE4: Benign symptoms that are powerful enough to bring people back from the dead or some equivalent.
// THREAT_BENETYPE3: This symptom has competitive properties.
// THREAT_BENETYPE2: This symptom provides significant health benefits to infected individuals.
// THREAT_BENETYPE1: This symptom provides marginal benefits to infected individuals.
// THREAT_NEUTRAL: The symptom causes no impactful harm or good to infected individuals.
// THREAT_TYPE1: This symptom causes barely noticable, nonfatal harm to infected individuals. Should not affect gameplay mechanically.
// THREAT_TYPE2: This symptom causes noticable, but nonfatal harm to infected individuals. Should not significantly impede gameplay.
// THREAT_TYPE3: This symptom causes significant, but nonfatal harm to infected individuals. May damage the player or impede mechanical gameplay.
// THREAT_TYPE4: This symptom causes severe and potentially fatal harm to infected individuals. Critting from full should take at least 5 minutes unattended. Short stuns are OK.
// THREAT_TYPE5: This symptom is extremely dangerous and will certainly cause fatal harm to infected individuals.
//Anything that causes incapacitation goes HERE. Critting should take at least 3 minutes. Instant death and adjacent go here.
// Type 5 symptoms may be reserved for Emag/nukeops.

#define THREAT_BENETYPE4 -4
#define THREAT_BENETYPE3 -3
#define THREAT_BENETYPE2 -2
#define THREAT_BENETYPE1 -1
#define THREAT_NEUTRAL 0
#define THREAT_TYPE1 1
#define THREAT_TYPE2 2
#define THREAT_TYPE3 3
#define THREAT_TYPE4 4
#define THREAT_TYPE5 5
