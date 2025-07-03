
/// Evaluates to an actual IEEE 754 infinity!
#define INFINITY 1e69

#define TICKS *world.tick_lag

// Not QUITE a SI unit, but used frequently nonetheless
#define LITERS *1

#define LITER LITERS

// SI UNIT DEFINES

//ex:  var/time = 10 SECONDS
#define SECONDS *10
#define MINUTES *(60 SECONDS)
#define HOURS *(60 MINUTES)
#define DAYS *(24 HOURS)
#define WEEKS *(7 DAYS)
#define MONTHS *(30 DAYS) //uhhhhh sure
#define YEARS *(365 DAYS) //leap years aren't real

#define SECOND SECONDS
#define MINUTE MINUTES
#define HOUR HOURS
#define DAY DAYS
#define WEEK WEEKS
#define MONTH MONTHS
#define YEAR YEARS

#define WATTS *1
#define METERS *1
#define KILOGRAMS *1
#define AMPERES *1
#define KELVIN *1
#define MOLES *1
#define CANDELAS *1
#define PASCALS *1
#define SIEVERTS *1

#define WATT WATTS
#define METER METERS
#define KILOGRAM KILOGRAMS
#define AMPERE AMPERES
#define AMP AMPERES
#define AMPS AMPERES
#define MOLE MOLES
#define CANDELA CANDELAS
#define PASCAL PASCALS
#define SIEVERT SIEVERTS

#define YOTTA *(10**24)
#define ZETTA *(10**21)
#define EXA   *(10**18)
#define PETA  *(10**15)
#define TERA  *(10**12)
#define GIGA  *(10**9)
#define MEGA  *(10**6)
#define KILO  *(10**3)
#define HECTO *(10**2)
#define DEKA  *(10**1)

#define DECI  *(10**-1)
#define CENTI *(10**-2)
#define MILLI *(10**-3)
#define MICRO *(10**-6)
#define NANO  *(10**-9)
#define PICO  *(10**-12)
#define FEMTO *(10**-15)
#define ATTO  *(10**-18)
#define ZEPTO *(10**-21)
#define YOCTO *(10**-24)
