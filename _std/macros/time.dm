/// replacement for world.timeofday that shouldn't break around midnight, please use this
#define TIME ((world.timeofday - server_start_time + 24 HOURS) % (24 HOURS))

/// gets the hour (1-24) of the day it is
#define TimeOfHour world.timeofday % 36000
