/// Returns the area of a passed atom
#define get_area(x) (isarea(x) ? x : get_step(x, 0)?.loc)

/// Returns true if this area is considered part of arrivals. Otherwise false.
#define IS_ARRIVALS(x) (istype(x, /area/shuttle/arrival/station) || istype(x, /area/station/crewquarters/cryotron) || istype(x, /area/station/hallway/secondary/oshan_arrivals))
