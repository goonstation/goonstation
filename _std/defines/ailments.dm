// ailment cure bitflags

/// ailment is incurable
#define CURE_INCURABLE   (1<<0)
/// ailment cure is unknown. same as incurable. just no known cures
#define CURE_UNKNOWN (1<<1)
/// ailment may cure itself as time passes
#define CURE_TIME (1<<2)
/// ailment cure is electric shock
#define CURE_ELEC_SHOCK (1<<3)
/// ailment cure is antibiotics
#define CURE_ANTIBIOTICS (1<<4)
/// ailment cure is some form of surgery
#define CURE_SURGERY (1<<5)
/// ailment cure is by sleeping
#define CURE_SLEEP (1<<6)
/// ailment cure is by removal of heart
#define CURE_HEART_TRANSPLANT (1<<7)
/// ailment cure is determined by the ailment
#define CURE_CUSTOM (1<<8)
