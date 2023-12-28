#define GANG_MAX_MEMBERS 1

// number of spray bottles gangs start with in their locker, excluding the 2 in the recruitment briefcase
#define GANG_STARTING_SPRAYPAINT 0
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



//STREET CRED PURCHASE DEFINES:
#define GANG_NEW_MEMBER_COST 500 		//Cost of buying a new gang member from the locker
#define GANG_NEW_MEMBER_COST_GAIN 500 	//How much buying a new gang member increases the price

#define GANG_REVIVE_COST 500 		//Cost of buying a revival syringe (JankTank II) from the locker
#define GANG_REVIVE_COST_GAIN 350 	//How much buying a revival syringe increases its' price


//CRATE DROP DEFINES
#define GANG_CRATE_SCORE 500 //how many points gang crates grant to each member, when opened
#define GANG_CRATE_LOCK_TIME 300 //how long gang crates stay locked to the floor, in seconds


//GANG TAG DEFINES:
//Gang tags scan once every GANG_TAG_SCAN_RATE.
//If they see a player, they will remember them until the next GANG_TAG_SCORE_INTERVAL.
//Once the next GANG_TAG_SCORE_INTERVAL has elapsed, all memorised players provide heat, then are forgotten.

//how often gang tags search for nearby people, in deciseconds
#define GANG_TAG_SCAN_RATE 10
//how often tags calculate their heat & score, in seconds
#define GANG_TAG_SCORE_INTERVAL 15
//How many points a tag gives for each heat rating it has
#define GANG_TAG_POINTS_PER_HEAT 3
//How much heat gang tags retain every score interval
//Higher means gang tags stay hot for longer
//If popular gang tags are staying too hot for too long after players leave, consider setting it lower.
#define GANG_TAG_HEAT_DECAY_MUL 0.9

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
//You can therefore estimate how many points a gang might have using this, A VERY successful gang may see mostly level 4 tags

//Giving a gang 2 more spray bottles will therefore mean 2 more level 3~4 tags - 3.5*GANG_TAG_POINTS_PER_HEAT points every GANG_TAG_SCORE_INTERVAL
//With the default settings (scanrate 10, interval 15, points per heat 3), gangs will get roughly
//Use this to figure if your item is too expensive!



//GANG TAG SIZES:

//GANG_TAG_INFLUENCE   		= Radius of the circle that tags claim
//GANG_TAG_SIGHT_RANGE 	= Radius of the circle that gang tags can see inside (can't be sprayed inside)
//keep in mind, smaller maps will still have fewer players & less gangs

#define GANG_TAG_INFLUENCE_LOCKER 4
#define GANG_TAG_SIGHT_RANGE_LOCKER 0

//overriding gang tag sizes, 15-8 seems fair for most highpop maps
#ifdef MAP_OVERRIDE_COGMAP2
	#define GANG_TAG_INFLUENCE 15
	#define GANG_TAG_SIGHT_RANGE 8

//small maps
#elif defined(MAP_OVERRIDE_ATLAS)
	#define GANG_TAG_INFLUENCE 10
	#define GANG_TAG_SIGHT_RANGE 6


#else
	#define GANG_TAG_INFLUENCE 12
	#define GANG_TAG_SIGHT_RANGE 6
#endif

//shorthands for range calcs
#define GANG_TAG_INFLUENCE_SQUARED GANG_TAG_INFLUENCE*GANG_TAG_INFLUENCE
#define GANG_TAG_SIGHT_RANGE_SQUARED GANG_TAG_SIGHT_RANGE*GANG_TAG_SIGHT_RANGE

#define CLIENT_IMAGE_GROUP_GANGS "client_image_group_gang"
