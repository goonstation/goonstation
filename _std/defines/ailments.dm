// ailment cure bitflags

/// ailment is incurable
#define CURE_INCURABLE   (1<<0)
/// ailment cure is unknown. same as incurable. just no known cures
#define CURE_UNKNOWN (1<<1)
/// ailment cure is determined by the ailment
#define CURE_CUSTOM (1<<2)
/// ailment cure is electric shock
#define CURE_ELEC_SHOCK (1<<3)
/// ailment cure is medicine
#define CURE_MEDICINE (1<<4)
/// ailment cure is some form of surgery
#define CURE_SURGERY (1<<5)
/// ailment cure is by sleeping
#define CURE_SLEEP (1<<6)
/// ailment cure is organ replacement
#define CURE_ORGAN_REPLACEMENT (1<<7)
/// ailment may cure itself as time passes
#define CURE_TIME (1<<8)
/// ailment cure is high body temperature
#define CURE_HIGH_TEMPERATURE (1<<9)
/// ailment cure is low body temperature
#define CURE_LOW_TEMEPRATURE (1<<10)

// ailment spread types
#define AILMENT_SPREAD_NONE 0
#define AILMENT_SPREAD_UNKNOWN 1
#define AILMENT_SPREAD_AIRBORNE 2
#define AILMENT_SPREAD_NONCONTAGIOUS 3
#define AILMENT_SPREAD_SALIVA 4

// ailment states
#define AILMENT_STATE_ACTIVE 1
#define AILMENT_STATE_REMISSIVE 2
#define AILMENT_STATE_ASYMPTOMATIC 3
#define AILMENT_STATE_DORMANT 4
#define AILMENT_STATE_ACUTE 5

// addiction severities
#define AILMENT_ADDICTION_SEVERITY_HIGH 1
#define AILMENT_ADDICTION_SEVERITY_LOW 2
