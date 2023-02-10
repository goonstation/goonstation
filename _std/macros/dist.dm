
/// Returns distance of two objects in tiles like get_dist but being inside another object doesn't break it and being on a different z-level returns INFINITY
#define GET_DIST(A, B) (get_step(A, 0)?.z == get_step(B, 0)?.z ? max(abs(get_step(A, 0)?.x - get_step(B, 0)?.x), abs(get_step(A, 0)?.y - get_step(B, 0)?.y)) : INFINITY)
/// Returns 0 if A and B are on adjacent turfs, through any amount of nested objs/mobs. Otherwise returns bounds_dist.
#define BOUNDS_DIST(A, B) ((GET_DIST(A, B) <= 1 ? 0 : max(0, bounds_dist(A, B))))
/// Returns if A is in range of B given range
#define IN_RANGE(A, B, range) (GET_DIST(A, B) <= range)
/// Returns the manhattan distance between two turfs or movable objects
#define GET_MANHATTAN_DIST(A, B) (get_step(A, 0)?.z == get_step(B, 0)?.z ? abs(get_step(A, 0).x - get_step(B, 0).x) + abs(get_step(A, 0).y - get_step(B, 0).y) : INFINITY)
/// Returns the squared euclidean distance between two turfs or movable objects
/// This is helpful in cases where the exact distance is not needed, so you can avoid the sqrt
#define GET_SQUARED_EUCLIDEAN_DIST(A, B) (get_step(A, 0)?.z == get_step(B, 0)?.z ? (get_step(A, 0).x - get_step(B, 0).x)**2 + (get_step(A, 0).y - get_step(B, 0).y)**2 : INFINITY)
/// Returns the euclidean distance between two turfs or movable objects
#define GET_EUCLIDEAN_DIST(A, B) sqrt(GET_SQUARED_EUCLIDEAN_DIST(A, B))
/// Returns if A is in range of B given range using the euclidean metric
#define IN_EUCLIDEAN_RANGE(A, B, range) (GET_SQUARED_EUCLIDEAN_DIST(A, B) <= (range) * (range))
