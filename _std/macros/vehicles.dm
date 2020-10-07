//used for pods

#define BOARD_DIST_ALLOWED(M,V) ( ((V.bound_width > world.icon_size || V.bound_height > world.icon_size) && (M.x > V.x || M.y > V.y) && (get_dist(M, V) <= 2) ) || (get_dist(M, V) <= 1) )
