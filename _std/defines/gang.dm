
#define GANG_TAG_INFLUENCE 15 // radius of influence around gang tags tiles


#define GANG_TAG_MINIMUM_RANGE 8  //minimum range between two gang tags

//shorthands for range calcs
#define GANG_TAG_INFLUENCE_SQUARED GANG_TAG_INFLUENCE*GANG_TAG_INFLUENCE
#define GANG_TAG_MINIMUM_RANGE_SQUARED GANG_TAG_MINIMUM_RANGE*GANG_TAG_MINIMUM_RANGE

#define CASH_DIVISOR 200 //cash per point
#define CLIENT_IMAGE_GROUP_GANGS "client_image_group_gang"

#define GANG_TAG_SCAN_RATE 10 //delay between each scan for gang tags, in deciseconds
#define GANG_TAG_SCORE_INTERVAL 60 //how often gang tags score (and allow the same person to 'see' it again), in seconds
#define GANG_TAG_POINTS_PER_VIEWER 5 //How many points a tag gives for each person that's seen it in a minute


#define JANKTANK2_DESIRED_HEALTH_PCT 0.15