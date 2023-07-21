#define GANG_STARTING_SPRAYPAINT 3 // number of spray bottles gangs start with, excluding the 2 in the recruitment briefcase
#define GANG_SPRAYPAINT_REGEN 300 //time in seconds between gangs gaining another spray bottle


#define GANG_NEW_MEMBER_COST 300 		//Cost of buying a new gang member from the locker
#define GANG_NEW_MEMBER_COST_GAIN 200 	//How much buying a new gang member increases the price

#define GANG_REVIVE_COST 1500 		//Cost of buying a revival syringe (JankTank II) from the locker
#define GANG_REVIVE_COST_GAIN 0 	//How much buying a revival syringe increases its' price


#define CASH_DIVISOR 200 //cash per point
#define CLIENT_IMAGE_GROUP_GANGS "client_image_group_gang"

#define GANG_TAG_SCAN_RATE 10 //delay between each scan for gang tags, in deciseconds
#define GANG_TAG_SCORE_INTERVAL 15 //how often gang tags score (and forget who they've seen), in seconds
#define GANG_TAG_POINTS_PER_HEAT 5 //How many points a tag gives for each heat rating it hits


#define JANKTANK2_DESIRED_HEALTH_PCT 0.15



//gang tags scale in influence size based on map, just so.
//keep in mind, smaller maps will still have fewer gangs

//GANG_TAG_INFLUENCE   		= radius of influence around gang tags tiles
//GANG_TAG_SIGHT_RANGE 	= minimum range between two gang tags, and how far a gang  tag can see

#define GANG_TAG_INFLUENCE_LOCKER 4
#define GANG_TAG_SIGHT_RANGE_LOCKER 1

//larger maps, might not work?
#ifdef MAP_OVERRIDE_COGMAP2
	#define GANG_TAG_INFLUENCE 15
	#define GANG_TAG_SIGHT_RANGE 8

//small maps
#elif defined(MAP_OVERRIDE_ATLAS)
	#define GANG_TAG_INFLUENCE 7
	#define GANG_TAG_SIGHT_RANGE 4


#else
	#define GANG_TAG_INFLUENCE 15
	#define GANG_TAG_SIGHT_RANGE 8
#endif

//shorthands for range calcs
#define GANG_TAG_INFLUENCE_SQUARED GANG_TAG_INFLUENCE*GANG_TAG_INFLUENCE
#define GANG_TAG_SIGHT_RANGE_SQUARED GANG_TAG_SIGHT_RANGE*GANG_TAG_SIGHT_RANGE