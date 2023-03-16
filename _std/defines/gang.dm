not #define GANG_STARTING_SPRAYPAINT 5 // number of spray bottles gangs start with
#define GANG_SPRAYPAINT_REGEN 300 //time in seconds between gangs gaining another spray bottle


#define CASH_DIVISOR 200 //cash per point
#define CLIENT_IMAGE_GROUP_GANGS "client_image_group_gang"

#define GANG_TAG_SCAN_RATE 10 //delay between each scan for gang tags, in deciseconds
#define GANG_TAG_SCORE_INTERVAL 60 //how often gang tags score (and allow the same person to 'see' it again), in seconds
#define GANG_TAG_POINTS_PER_VIEWER 5 //How many points a tag gives for each person that's seen it in a minute


#define JANKTANK2_DESIRED_HEALTH_PCT 0.15



//gang tags scale in influence size based on map.
//this should hopefully keep the number of points gangs get -relatively- consistent
//as small maps will have fewer players (but they will see )
//keep in mind, smaller maps will still have fewer gangs

//GANG_TAG_INFLUENCE   		= radius of influence around gang tags tiles
//GANG_TAG_MINIMUM_RANGE 	= minimum range between two gang tags



//larger maps
#ifdef MAP_OVERRIDE_COGMAP2
#define GANG_TAG_INFLUENCE 15
#define GANG_TAG_MINIMUM_RANGE 8

//small maps
#elif defined(MAP_OVERRIDE_ATLAS)
#define GANG_TAG_INFLUENCE 9
#define GANG_TAG_MINIMUM_RANGE 4


#else
#define GANG_TAG_INFLUENCE 15
#define GANG_TAG_MINIMUM_RANGE 8
#endif

//shorthands for range calcs
#define GANG_TAG_INFLUENCE_SQUARED GANG_TAG_INFLUENCE*GANG_TAG_INFLUENCE
#define GANG_TAG_MINIMUM_RANGE_SQUARED GANG_TAG_MINIMUM_RANGE*GANG_TAG_MINIMUM_RANGE