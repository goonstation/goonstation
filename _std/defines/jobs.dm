// Mail Groups (by Department/Team)
// PDA Type determines which of these groups they recieve messages for
// Apart from Party Line, they cannot be joined or left.
#define MGD_PARTY "Party Line" //Is the clown the head of the Party department?
#define MGD_COMMAND "command"
#define MGD_SECURITY "security"
#define MGD_MEDICAL "medical"
#define MGD_RESEARCH "research"
#define MGD_ENGINEER "engineer"
#define MGD_SUPPLY "supply"
#define MGD_CIVILIAN "civilian"
#define MGD_SILICON "silicon"

#define MGT_ROBOTICS "robotics"
#define MGT_GENETICS "genetics"
#define MGT_CARGO "cargo"
#define MGT_MINING "mining"
#define MGT_CATERING "catering" // chef/bartender
#define MGT_HYDROPONICS "hydroponics" // botany/rancher
#define MGT_JANITOR "janitor"
#define MGT_SPIRITUALAFFAIRS "spiritualaffairs" // chaplain (and X-hunters)
#define MGT_AI "ai" // AIs. Plural. Because robotics got bored.

// Mail Groups (Alerts)
// These cannot be joined, but can be muted.
#define MGA_MAIL "Delivery Alert"
#define MGA_CHECKPOINT "Checkpoint Alert"
#define MGA_ARREST "Arrest Alert"
#define MGA_DEATH "Death Alert"
#define MGA_MEDCRIT "Near-Death Alert"
#define MGA_CLONER "Cloner Alert"
#define MGA_ENGINE "Engine Alert"
#define MGA_RKIT "Mechanic Alert"
#define MGA_SALES "Sales Alert"
#define MGA_SHIPPING "Shipping Alert"
#define MGA_CARGOREQUEST "Cargo Request"
#define MGA_CRISIS "Crisis Alert"
#define MGA_RADIO "Radio Alert"
#define MGA_TRACKING "Tracking Alert"
#define MGA_SYNDICATE "Syndicate Alert"

// Job "department" categories
#define JOB_COMMAND "command"
#define JOB_SECURITY "security"
#define JOB_RESEARCH "research"
#define JOB_MEDICAL "medical"
#define JOB_ENGINEERING "engineering"
#define JOB_CIVILIAN "civilian"
#define JOB_SPECIAL "special"
#define JOB_CREATED "created"
#define JOB_NANOTRASEN "nanotrasen"
#define JOB_SYNDICATE "syndicate"
#define JOB_HALLOWEEN "halloween"
#define JOB_RANDOM "random"
#define JOB_DAILY "daily"

// Job categories
#define STAPLE_JOBS (1<<0)
#define SPECIAL_JOBS (1<<1)
#define HIDDEN_JOBS (1<<2)

// Job round requirements
#define ROUNDS_MIN_CAPTAIN 30 // captains should know what they're doing (they won't)
#define ROUNDS_MIN_SECURITY 30 // higher barrier of entry than before but now with a trainee job to get into the rythym of things to compensate
#define ROUNDS_MIN_DETECTIVE 15 // half of sec, please stop shooting people with lethals
#define ROUNDS_MIN_SECASS 5

// Job round maximum (for newbees)
#define ROUNDS_MAX_RESASS 75
#define ROUNDS_MAX_MEDASS 75
#define ROUNDS_MAX_TECHASS 75

// World announcement orders
// Order in which the "John is the Captain!" world messages show up when multiple heads join at the same time (mainly roundstart)
#define ANNOUNCE_ORDER_CAPTAIN 5
#define ANNOUNCE_ORDER_HOP 4
#define ANNOUNCE_ORDER_HOS 3
#define ANNOUNCE_ORDER_HEADS 2
#define ANNOUNCE_ORDER_LAST 1
#define ANNOUNCE_ORDER_NEVER 0
