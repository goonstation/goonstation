// Mail Groups (by Department)
// These have buttons to contact them in the messaging app on the PDA.
// Apart from Party Line, they cannot be joined or left.
#define MGD_PARTY "Party Line" //Is the clown the head of the Party department?
#define MGD_COMMAND "command"
#define MGD_SECURITY "security"
#define MGD_MEDBAY "medbay"
#define MGD_MEDRESEACH "medresearch"
#define MGD_SCIENCE "science"
#define MGD_CARGO "cargo"
#define MGD_STATIONREPAIR "stationrepair"
#define MGD_BOTANY "botany"
#define MGD_KITCHEN "kitchen"
#define MGD_SPIRITUALAFFAIRS "spiritualaffairs"
#define MGD_MINING "mining"

// Mail Groups (Other)
// These cannot be joined or left.
#define MGO_STAFF "staff"
#define MGO_AI "ai"
#define MGO_SILICON "silicon"
#define MGO_JANITOR "janitor"
#define MGO_ENGINEER "engineer"

// Mail Groups (Alerts)
// These cannot be joined, and no PDAs start in them.
// However, they can be muted.

#define MGA_MAIL "Snail Mail Alert"
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

// Job categories
#define JOB_SPECIAL "special"
#define JOB_COMMAND "command"
#define JOB_SECURITY "security"
#define JOB_RESEARCH "research"
#define JOB_MEDICAL "medical"
#define JOB_ENGINEERING "engineering"
#define JOB_CIVILIAN "civilian"
#define JOB_CREATED "created"

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
