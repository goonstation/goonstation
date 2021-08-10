/// Returns the area of a passed atom
#define get_area(x) (isarea(x) ? x : get_step(x, 0)?.loc)
