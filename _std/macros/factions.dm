//Faction bitmasks, for setting what teams mobs/critters are on. Barebones atm.

/// Faction which is not targeted by default
#define FACTION_NEUTRAL			(1<<0)
/// Generic faction for groups you don't want killing eachother
#define FACTION_GENERIC			(1<<1)
/// Wraith critters and summons
#define FACTION_WRAITH			(1<<2)
/// Maneaters, Tomatoes, Wasps, Plasmaspores and Botanists
#define FACTION_BOTANY			(1<<3)
/// Trench and Ocean mobs
#define FACTION_AQUATIC			(1<<4)
/// Robots and Drones
#define FACTION_SYNDICATE		(1<<5)
/// NT persons of interest and assets
#define FACTION_NANOTRASEN		(1<<6)
/// Wizard & summons
#define FACTION_WIZARD			(1<<7)
/// Sponge capsule spawns
#define FACTION_SPONGE			(1<<8)
/// Ice moon critters
#define FACTION_ICEMOON			(1<<9)
/// Clowns and other clown like entities
#define FACTION_CLOWN			(1<<10)
/// Void stuff / disaster portal / old robots
#define FACTION_DERELICT		(1<<11)

/// Returns TRUE if ourguy is enemies with otherguy FALSE otherwise
proc/faction_check(var/mob/ourguy, var/mob/otherguy, var/attack_neutral)
	if (ourguy.faction & otherguy.faction) // Same faction
		return FALSE
	if ((otherguy.faction & FACTION_NEUTRAL) && !attack_neutral) // If neutral and we don't want to attack them, don't attack
		return FALSE
	return TRUE // No faction / Differing faction / attacking neutral
