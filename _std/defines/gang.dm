#define GANG_LEADER_REVIVES 1 //number of times a gang leader may respawn (naked) in their locker

#define GANG_STARTING_SPRAYPAINT 2 // number of spray bottles gangs start with, excluding the ones in the recruitment briefcase
#define GANG_SPRAYPAINT_REGEN 600 //time in seconds between gangs gaining spray bottles
#define GANG_SPRAYPAINT_REGEN_QUANTITY 2 //number of spray paints that are granted in this interval

#define GANG_CRATE_SCORE 500 //how many points gang crates grant to each member, when opened

#define GANG_NEW_MEMBER_COST 1000 		//Cost of buying a new gang member from the locker
#define GANG_NEW_MEMBER_COST_GAIN 200 	//How much buying a new gang member increases the price

#define GANG_REVIVE_COST 700 		//Cost of buying a revival syringe (JankTank II) from the locker
#define GANG_REVIVE_COST_GAIN 0 	//How much buying a revival syringe increases its' price


#define CLIENT_IMAGE_GROUP_GANGS "client_image_group_gang"

#define GANG_LAUNDER_DELAY 3 //how often gangs launder the money in their locker, in seconds
#define GANG_LAUNDER_RATE 100 //how much cash gets turned into points every laundering tick,
#define GANG_LAUNDER_CAP 20000 //how much cash can be in a locker at any given time?
#define CASH_DIVISOR 25 //How much cash is required for 1 gang point?


#define GANG_TAG_SCAN_RATE 10 //how long gang tags wait in between looking for people, in deciseconds
#define GANG_TAG_SCORE_INTERVAL 15 //how often tags calculate their heat & score, in seconds
#define GANG_TAG_POINTS_PER_HEAT 1 //How many points a tag gives for each heat rating it has

#define GANG_CRATE_LOCK_TIME 60 //how long gang crates stay locked to the floor, in seconds


#define JANKTANK2_DESIRED_HEALTH_PCT 0.15 //what % a janktank revives people at



//GANG_TAG_INFLUENCE   		= radius of influence around gang tags tiles
//GANG_TAG_SIGHT_RANGE 	= minimum range between two gang tags, and how far a gang tag can see
//keep in mind, smaller maps will still have fewer players & therefore gangs

#define GANG_TAG_INFLUENCE_LOCKER 4
#define GANG_TAG_SIGHT_RANGE_LOCKER 1

//overriding gang tag sizes, 15-8 seems fair for most full si ze maps
#ifdef MAP_OVERRIDE_COGMAP2
	#define GANG_TAG_INFLUENCE 15
	#define GANG_TAG_SIGHT_RANGE 8

//small maps
#elif defined(MAP_OVERRIDE_ATLAS)
	#define GANG_TAG_INFLUENCE 8
	#define GANG_TAG_SIGHT_RANGE 4


#else
	#define GANG_TAG_INFLUENCE 15
	#define GANG_TAG_SIGHT_RANGE 8
#endif

//shorthands for range calcs
#define GANG_TAG_INFLUENCE_SQUARED GANG_TAG_INFLUENCE*GANG_TAG_INFLUENCE
#define GANG_TAG_SIGHT_RANGE_SQUARED GANG_TAG_SIGHT_RANGE*GANG_TAG_SIGHT_RANGE