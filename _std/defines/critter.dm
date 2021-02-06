#define OBJ_CRITTER_OPENS_DOORS_NONE 0
#define OBJ_CRITTER_OPENS_DOORS_PUBLIC 1
#define OBJ_CRITTER_OPENS_DOORS_ANY 2

/// Allowed buddy hat iconstates
#define BUDDY_HATS list("detective","hoscap","hardhat","hosberet","ntberet","chef","souschef","captain","centcom","centcom-red","tophat","ptophat","mjhat","plunger","cakehat0","cakehat1","butt","santa","yellow","blue","red","green","black","white","psyche","wizard","wizardred","wizardpurple","witch","obcrown","macrown","safari","dolan","viking","mailcap","bikercap","paper","apprentice","chavcap","policehelm","captain-fancy","rank-fancy","mime_beret","mime_bowler")

// Critter families
#define BUG 1

// Critter hold/bag reactions
/// Is okay with being held, won't struggle until you mess with it
#define HOLD_RESPONSE_CHILL 1
/// Doesn't like being held, will struggle and try to escape
#define HOLD_RESPONSE_DISLIKE 2
/// Hates being held, will struggle and attack the holder, and will attack anyone for a while after escaping
#define HOLD_RESPONSE_VIOLENT 3
/// Is okay with being in a bag, won't struggle until you mess with it
#define BAG_RESPONSE_CHILL 1
/// Doesn't like being in a bag, will struggle and try to escape, and mess with things in the bag
#define BAG_RESPONSE_DISLIKE 2
/// Hates being in a bad, will struggle and try to escape, mess with things in the bad, and will attack anyone for a while after escaping
#define BAG_RESPONSE_VIOLENT 3
/// ObjCritter pickupability flags
/// ObjCritter can't be picked up
#define GRABBABLE_NEVER 0
/// ObjCritter needs lizard arms to pick up
#define GRABBABLE_LIZARD (1<<0)
/// ObjCritter must not be angry at someone to be picked up
#define GRABBABLE_NOT_WHILE_ANGRY (1<<1)
/// ObjCritter must not be angry *at the grabber* to be picked up
#define GRABBABLE_NOT_WHILE_ANGRY_AT_GRABBER (1<<2)

// What level of grab is needed to pick up this MobCritter
/// Never mind, mob can't be picked up
#define MOBCRITTER_GRAB_NEVER 0
/// Simple grab
#define MOBCRITTER_GRAB_PASSIVE 1
/// Aggressive grab
#define MOBCRITTER_GRAB_AGGRESSIVE 2
/// Neck grab
#define MOBCRITTER_GRAB_NECK 3
/// Kill grab
#define MOBCRITTER_GRAB_KILL 4
