/// replacement for world.timeofday that shouldn't break around midnight, please use this
#define TIME ((world.timeofday - server_start_time + 24 HOURS) % (24 HOURS))

/// gets the hour (1-24) of the day it is
#define TimeOfHour world.timeofday % 36000

//https://stackoverflow.com/questions/36389130/how-to-calculate-the-day-of-the-week-based-on-unix-time
//thank u stack overflow
#define IS_IT_FRIDAY (floor((BUILD_TIME_UNIX / 86400) + 4) % 7)
