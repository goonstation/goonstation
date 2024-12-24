#define GANG_MAX_MEMBERS 3

/// How long the leader must cryo before gang members can take their role
#define GANG_CRYO_LOCKOUT 7.5 MINUTES

/// How long into the shift gang leadership is transferable, in the case of the leader's suicide/death.
// Note: this makes a member REPLACE the dead leader. The leader remains a member.
#define GANG_LEADER_SOFT_DEATH_TIME 20 MINUTES
/// If a gang locker exists, how long to wait before picing a new leader
// This is for the use case where the leader has done the bare minimum.
#define GANG_LEADER_SOFT_DEATH_DELAY 5 MINUTES

// -------------------------
// GANG ECONOMY
// -------------------------
// Every gang tag can provide anywhere between 0-6 * GANG_TAG_POINTS_PER_HEAT per GANG_TAG_SCORE_INTERVAL.
// You can therefore estimate how many points a gang might have using this, A VERY successful gang may see mostly level 4 tags.
//
// Giving a gang 2 more spray bottles will therefore mean 2 more level 3~4 tags,
// about 3.5*GANG_TAG_POINTS_PER_HEAT points every GANG_TAG_SCORE_INTERVAL
// Use this to figure if something is too valuable/expensive!
//
// MATH FOR NERDS:
// https:// www.desmos.com/calculator/p9uv6debrp
// This works out to roughly:
// Having the hottest tag gets level '5'
// Having 63% of the top heat is level '4'
// Having 40% of the top heat is level '3'
// Having 25% of the top heat is level '2'
// Having 10% of the top heat is level '1'
// Having less than 10% is level '0'

/// Amount of points a gang member starts with
#define GANG_STARTING_POINTS 1500

/// number of spray bottles gangs start with in their locker, excluding the 2 in the recruitment briefcase
#define GANG_STARTING_SPRAYPAINT 10
/// time in seconds between gangs gaining spray bottles
#define GANG_SPRAYPAINT_REGEN 30 MINUTES
/// number of spray paints that are granted in this interval
#define GANG_SPRAYPAINT_REGEN_QUANTITY 5
/// time to tag on an unclaimed tile
#define GANG_SPRAYPAINT_TAG_TIME 3 SECONDS
/// time to spray over an existing gang member's tag
#define GANG_SPRAYPAINT_TAG_REPLACE_TIME 15 SECONDS
/// score granted immediately on finishing a tag
#define GANG_SPRAYPAINT_INSTANT_SCORE 50

/// Drug points:

/// /// Each drug is worth GANG_DRUG_BONUS_MULT * their value until this many units are provided
#define GANG_DRUG_BONUS_CAP 300
/// How many weed leaves provide a points bonus
#define GANG_WEED_LIMIT 200 //gang weed
/// Each drug then has this much market behind it after GANG_DRUG_BONUS_CAP is used up.
#define GANG_DRUG_LIMIT 300
/// The multiplier for drugs that a gang has handed in less than GANG_DRUG_BONUS_CAP units of
#define GANG_DRUG_BONUS_MULT 3

#define GANG_DRUG_SCORE_BATHSALTS  3
#define GANG_DRUG_SCORE_MORPHINE  1
#define GANG_DRUG_SCORE_CRANK 1
#define GANG_DRUG_SCORE_LSD 0.5
#define GANG_DRUG_SCORE_LSBEE 2
#define GANG_DRUG_SCORE_THC 0.25
#define GANG_DRUG_SCORE_SPACEDRUGS  0.1
#define GANG_DRUG_SCORE_PSILOCYBIN 0.5
#define GANG_DRUG_SCORE_KROKODIL 3
#define GANG_DRUG_SCORE_CATDRUGS 1
#define GANG_DRUG_SCORE_METH 1.5


/// what % of max HP a janktank revives people at
#define JANKTANK2_DESIRED_HEALTH_PCT 0.15
/// How long the JankTank must be prepared while using it on a gang member
#define JANKTANK2_CHANNEL_TIME 5 SECONDS
/// How long the janktank 2 sits in the corpse before revival - where it may be removed.
#define JANKTANK2_PAUSE_TIME 5 SECONDS


// GAMEMODE DEFINES
#ifdef RP_MODE
#define GANG_CRATE_INITIAL_DROP  30 MINUTES //!  when the first gang crate drops on RP
#define GANG_CRATE_DROP_FREQUENCY 40 MINUTES //! how often gang crates are dropped on RP
#else
#define GANG_CRATE_INITIAL_DROP  15 MINUTES //!  when the first gang crate drops on classic
#define GANG_CRATE_DROP_FREQUENCY 20 MINUTES //! how often gang crates are dropped on classic
#endif


#ifdef RP_MODE
#define GANG_LOOT_INITIAL_DROP 15 MINUTES //! when the first vandalism objectives are assigned on RP
#define GANG_LOOT_DROP_FREQUENCY 30 MINUTES //! how often vandalism objectives are assigned on RP
#else
#define GANG_LOOT_INITIAL_DROP 8 MINUTES //! when the first vandalism objectives are assigned on classic
#define GANG_LOOT_DROP_FREQUENCY 20 MINUTES //! how often vandalism objectives are assigned on classic
#endif
#define GANG_LOOT_DROP_VOLUME_PER_GANG 2 //! how many duffel bags spawn, per gang



// LAUNDERING DEFINES
#define GANG_LAUNDER_DELAY 3 SECONDS //! how often gangs launder the money in their locker, in seconds
#define GANG_LAUNDER_RATE 200 //! how much cash gets turned into points every elapsed GANG_LAUNDER_DELAY,
#define GANG_LAUNDER_CAP 20000 //! how much cash can be in a locker at any given time?
#define GANG_CASH_DIVISOR 5 //! How much cash is required for 1 gang point?



// STREET CRED PURCHASE DEFINES:
#define GANG_NEW_MEMBER_COST 500 		//! Cost of buying a new gang member from the locker
#define GANG_NEW_MEMBER_COST_MULT 2.5 	//! How much buying a new gang member increases the price

#define GANG_REVIVE_COST 750 		//! Cost of buying a revival syringe (JankTank II) from the locker
#define GANG_REVIVE_COST_MULT 1.5 	//! How much buying a revival syringe increases its' price


// CRATE DROP DEFINES
#define GANG_CRATE_SCORE 3000 //! how many points gang crates grant to each member, when opened
#define GANG_CRATE_DROP_TIME 300 SECONDS //! How long it takes for gang crates to arrive after being announced
#define GANG_CRATE_LOCK_TIME 10 SECONDS //! How long it takes for gang crates to unlock after arriving

#define GANG_LOOT_SCORE 1000 //! how many points gang duffel bags grant to each member when opened


// GANG TAG DEFINES:
// Gang tags scan once every GANG_TAG_SCAN_RATE.
// If they see a player, they will remember them until the next GANG_TAG_SCORE_INTERVAL.
// Once the next GANG_TAG_SCORE_INTERVAL has elapsed, all memorised players provide heat, then are forgotten.

/// how often gang tags search for nearby people
#define GANG_TAG_SCAN_RATE 1 SECOND
/// how often tags calculate their heat & score
#define GANG_TAG_SCORE_INTERVAL 15 SECONDS
/// How many points a tag gives for each heat rating it has
#define GANG_TAG_POINTS_PER_HEAT 1
/// How much heat gang tags retain every score interval
// Higher means gang tags stay hot for longer
// If popular gang tags are staying too hot for too long after players leave, consider setting it lower.
#define GANG_TAG_HEAT_DECAY_MUL 0.9


// GANG VANDALISM DEFINES:
// Occasionally, gangs are told to do vandalism instead of duffle bags.
// They must deface departments enough to recieve a duffle bag on their location.

/// The total vandalism 'score' required to complete the objective.
#define GANG_VANDALISM_BASE_REQUIRED_SCORE 500
/// How much graffiti is worth, per tile
#define GANG_VANDALISM_PER_GRAFFITI_TILE 15
/// How many tiles of graffiti spawns in graffiti bottles
#define GANG_VANDALISM_GRAFFITI_MAX 30
/// How many points light breaks are worth
#define GANG_VANDALISM_LIGHT_BREAK_POINTS 35
/// How many points throwing a person into a vending machine is worth
#define GANG_VANDALISM_VENDOR_KO 20
/// How many points throwing a person into a glass table
#define GANG_VANDALISM_TABLING 40
/// How many points ripped up floor tiles are worth
#define GANG_VANDALISM_FLOORTILE_POINTS 5
/// How many points each point of damage is worth, for violence
#define GANG_VANDALISM_VIOLENCE_NPC_MULTIPLIER 0.5
/// How many points each point of damage is worth, for violence
#define GANG_VANDALISM_VIOLENCE_PLAYER_MULTIPLIER 0


// GANG TAG SIZES:

/// Radius of the circle that tags claim
#define GANG_TAG_INFLUENCE_LOCKER 4
/// Radius of the circle that gang tags can see inside (can't be sprayed inside)
#define GANG_TAG_SIGHT_RANGE_LOCKER 0
// keep in mind, smaller maps will still have fewer players & less gangs

// overriding gang tag sizes, 15-8 seems fair for most highpop maps
#ifdef MAP_OVERRIDE_COGMAP2
	#define GANG_TAG_INFLUENCE 15
	#define GANG_TAG_SIGHT_RANGE 8

#elif defined(MAP_OVERRIDE_DONUT3)
	#define GANG_TAG_INFLUENCE 15
	#define GANG_TAG_SIGHT_RANGE 8
#elif defined(MAP_OVERRIDE_OZYMANDIAS) //jesus christ. this is HUGE.
	#define GANG_TAG_INFLUENCE 20
	#define GANG_TAG_SIGHT_RANGE 12
#elif defined(MAP_OVERRIDE_ATLAS)
	#define GANG_TAG_INFLUENCE 10
	#define GANG_TAG_SIGHT_RANGE 5
#else
	#define GANG_TAG_INFLUENCE 12
	#define GANG_TAG_SIGHT_RANGE 6
#endif


// code-related stuff
#define GANG_CLAIM_INVALID 0
#define GANG_CLAIM_VALID 1 /// spraying in a valid zone
#define GANG_CLAIM_TAKEOVER 2 /// spraying over another tag
// shorthands for range calcs
#define GANG_TAG_INFLUENCE_SQUARED GANG_TAG_INFLUENCE*GANG_TAG_INFLUENCE
#define GANG_TAG_SIGHT_RANGE_SQUARED GANG_TAG_SIGHT_RANGE*GANG_TAG_SIGHT_RANGE

