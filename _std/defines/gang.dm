#define GANG_LEADER_REVIVES 1 //number of times a gang leader may respawn (naked) in their locker, backup in case the meta becomes 'rush down the leaders'

#define GANG_MAX_MEMBERS 1

// number of spray bottles gangs start with in their locker, excluding the ones in the recruitment briefcase
#define GANG_STARTING_SPRAYPAINT 2
//time in seconds between gangs gaining spray bottles
#define GANG_SPRAYPAINT_REGEN 600
//number of spray paints that are granted in this interval
#define GANG_SPRAYPAINT_REGEN_QUANTITY 2

//what % of max HP a janktank revives people at
#define JANKTANK2_DESIRED_HEALTH_PCT 0.15




//LAUNDERING DEFINES
#define GANG_LAUNDER_DELAY 3 //how often gangs launder the money in their locker, in seconds
#define GANG_LAUNDER_RATE 100 //how much cash gets turned into points every elapsed GANG_LAUNDER_DELAY,
#define GANG_LAUNDER_CAP 20000 //how much cash can be in a locker at any given time?
#define CASH_DIVISOR 25 //How much cash is required for 1 gang point?



//STREET CRED (respawn) PURCHASE DEFINES:
#define GANG_NEW_MEMBER_COST 1000 		//Cost of buying a new gang member from the locker
#define GANG_NEW_MEMBER_COST_GAIN 200 	//How much buying a new gang member increases the price

#define GANG_REVIVE_COST 700 		//Cost of buying a revival syringe (JankTank II) from the locker
#define GANG_REVIVE_COST_GAIN 0 	//How much buying a revival syringe increases its' price


//CRATE DROP DEFINES
#define GANG_CRATE_SCORE 500 //how many points gang crates grant to each member, when opened
#define GANG_CRATE_LOCK_TIME 5 //how long gang crates stay locked to the floor, in seconds


//GANG TAG DEFINES:
//Gang tags scan once every GANG_TAG_SCAN_RATE.
//If they see a player, they will remember them until the next GANG_TAG_SCORE_INTERVAL.
//Once the next GANG_TAG_SCORE_INTERVAL has elapsed, all memorised players provide heat, then are forgotten.

//how often gang tags search for nearby people, in deciseconds
#define GANG_TAG_SCAN_RATE 10
//how often tags calculate their heat & score, in seconds
#define GANG_TAG_SCORE_INTERVAL 15
//How many points a tag gives for each heat rating it has
#define GANG_TAG_POINTS_PER_HEAT 1
//How much heat gang retain every score interval
//Higher means gang tags stay hot for longer
//If popular gang tags are staying too hot for too long after players leave, consider setting it lower.
#define GANG_TAG_HEAT_DECAY_MUL 0.7

//MATH FOR NERDS:
//https://www.desmos.com/calculator/p9uv6debrp
//The original math for heat level is as follows, (located in the gangtag's 'apply_score' in gangwar.dm):
// TAG HEAT LEVEL = log(10,10*X)*5
// Where X is the % of how hot said tag is, compared to the hottest tag
//This roughly translates to:
//Having the hottest tag gets level '5'
//Having 63% of the top heat is level '4'
//Having 40% of the top heat is level '3'
//Having 25% of the top heat is level '2'
//Having 10% of the top heat is level '1'
//Having less than 10% is level '0'


//WHAT THIS MEANS:
//Every gang tag can provide anywhere between 0-6 * GANG_TAG_POINTS_PER_HEAT per GANG_TAG_SCORE_INTERVAL.
//You can therefore estimate how many points a gang might have using this, A VERY successful gang may see mostly level 4~5 tags

//Giving a gang 2 more spray bottles will therefore mean 2 more level ~4 tags. Or 4*GANG_TAG_POINTS_PER_HEAT points every GANG_TAG_SCORE_INTERVAL
//Use this to figure if your item is too expensive!



//GANG TAG SIZES:

//GANG_TAG_INFLUENCE   		= radius of influence around gang tags tiles
//GANG_TAG_SIGHT_RANGE 	= minimum range between two gang tags, and how far a gang tag can see
//keep in mind, smaller maps will still have fewer players & less gangs

#define GANG_TAG_INFLUENCE_LOCKER 4
#define GANG_TAG_SIGHT_RANGE_LOCKER 1

//overriding gang tag sizes, 15-8 seems fair for most highpop maps
#ifdef MAP_OVERRIDE_COGMAP2
	#define GANG_TAG_INFLUENCE 15
	#define GANG_TAG_SIGHT_RANGE 8

//small maps
#elif defined(MAP_OVERRIDE_ATLAS)
	#define GANG_TAG_INFLUENCE 8
	#define GANG_TAG_SIGHT_RANGE 4


#else
	#define GANG_TAG_INFLUENCE 12
	#define GANG_TAG_SIGHT_RANGE 6
#endif

//shorthands for range calcs
#define GANG_TAG_INFLUENCE_SQUARED GANG_TAG_INFLUENCE*GANG_TAG_INFLUENCE
#define GANG_TAG_SIGHT_RANGE_SQUARED GANG_TAG_SIGHT_RANGE*GANG_TAG_SIGHT_RANGE

#define CLIENT_IMAGE_GROUP_GANGS "client_image_group_gang"
