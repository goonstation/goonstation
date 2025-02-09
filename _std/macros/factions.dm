//Faction bitmasks, for setting what teams mobs/critters are on. Barebones atm.

/// Faction which is not targeted by default
#define FACTION_NEUTRAL			"neutral"
/// Generic faction for groups you don't want killing eachother
#define FACTION_GENERIC			"generic"
/// Wraith critters and summons
#define FACTION_WRAITH			"wraith"
/// Maneaters, Tomatoes, Wasps, Plasmaspores and Botanists
#define FACTION_BOTANY			"botany"
/// Trench and Ocean mobs
#define FACTION_AQUATIC			"aquatic"
/// Robots and Drones
#define FACTION_SYNDICATE		"syndicate"
/// NT persons of interest and assets
#define FACTION_NANOTRASEN		"nanotrasen"
/// Wizard & summons
#define FACTION_WIZARD			"wizard"
/// Sponge capsule spawns
#define FACTION_SPONGE			"sponge"
/// Ice moon critters
#define FACTION_ICEMOON			"ice_moon"
/// Clowns and other clown like entities
#define FACTION_CLOWN			"clown"
/// Void stuff / disaster portal / old robots
#define FACTION_DERELICT		"derelict"
/// Space Ants
#define FACTION_FERMID			"fermid"
/// Gauntlet-spawned
#define FACTION_GUANTLET		"gauntlet"
/// Mercenaries
#define FACTION_MERCENARY		"mercenary"

/// Returns TRUE if ourguy is enemies with otherguy FALSE otherwise
proc/faction_check(mob/ourguy, mob/otherguy, attack_neutral)
	if (length(ourguy.faction & otherguy.faction)) // Same faction
		return FALSE
	if ((FACTION_NEUTRAL in otherguy.faction) && !attack_neutral) // If neutral and we don't want to attack them, don't attack
		return FALSE
	return TRUE // No faction / Differing faction / attacking neutral
