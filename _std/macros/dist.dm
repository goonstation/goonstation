/// Returns the manhattan distance between two turfs or movable objects
#define GET_MANHATTAN_DIST(A, B) ((!(A) || !(B)) ? 0 : abs((A).x - (B).x) + abs((A).y - (B).y))
/// Returns if A is in range of B given range
#define IN_RANGE(A, B, range) (get_dist(A, B) <= (range) && get_step(A, 0).z == get_step(B, 0).z)
