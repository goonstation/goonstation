// PDA Mail Groups
// Dedicated PDA channels to groups of the crew
// Apart from Party Line, they cannot be joined or left.
#define MSG_PARTY_LINE "Party Line" // Is the clown the head of the Party department?

// Department-based groups
#define MGD_COMMAND "command" //! Command Department
#define MGD_SECURITY "security" //! Security Department
#define MGD_MEDICAL "medical" //! Medical Department
#define MGD_SCIENCE "science" //! Science Department
#define MGD_ENGINEERING "engineering" //! Engineering Department

// Team groups
#define MGT_CATERING "catering" //! kitchen + bar
#define MGT_HYDROPONICS "hydroponics" //! botany + ranch
#define MGT_REPAIR "repair" //! engineering + janitor
#define MGT_SILICON "silicon" //! ai + cyborg

// Job-based groups
#define MGJ_AI "ai"
#define MGJ_CARGO "cargo" //! quartermaster
#define MGJ_GENETICS "genetics"
#define MGJ_JANITOR "janitor"
#define MGJ_MINING "mining"
#define MGJ_ROBOTICS "robotics"
#define MGJ_SPIRITUAL "spiritual" //! chaplain

// Message Alert Topics
// Topics group together automated messages from station systems
// They allow users ignore some noisy topics without muting groups
#define MSG_TOPIC_RADIO "Radio Update" //! Radio station songs
#define MSG_TOPIC_DELIVERY "Delivery Notice" //TODO: belt routing and mulebot //! Mail and cargo pad Delivery
#define MSG_TOPIC_CHECKPOINT "Checkpoint Alert" //! Security Checkpoints
#define MSG_TOPIC_ARREST "Arrest Alert" //! Arrests
#define MSG_TOPIC_TRACKING "Tracking Alert" //! Tracker alerts
#define MSG_TOPIC_DEATH "Death Alert" //! Death Alert (RIP)
#define MSG_TOPIC_CRITICAL "Near-Death Alert" //! Critical Health Alert
#define MSG_TOPIC_CLONER "Cloner Alert" //! Cloner alerts
#define MSG_TOPIC_ENGINE "Engine Alert" //! Engine-specific alerts, not engineering
#define MSG_TOPIC_RKIT "Device Scan" //! rkit
#define MSG_TOPIC_SALES "Sales Notice" //! Selling stuff
#define MSG_TOPIC_SHIPPING "Shipping Notice" //! Shipments from market
#define MSG_TOPIC_REQUEST "Crew Request" //! Requests from other crew
#define MSG_TOPIC_CRISIS "Crisis Alert" //! Crisis alerts
