#define reset_anchored(M) do{\
if(istype(M, /mob/living/carbon/human)){\
	var/mob/living/carbon/human/HumToDeanchor = M;\
	if(HumToDeanchor.shoes?.magnetic || HumToDeanchor.mutantrace?.anchor_to_floor){\
		HumToDeanchor.anchored = 1;}\
	else{\
		HumToDeanchor.anchored = 0}}\
else{\
	M.anchored = 0;}}\
while(FALSE)

/// Moves thing A from inside thing B to thing B's turf, iff thing A is inside thing B
#define MOVE_OUT_TO_TURF_SAFE (mover, loc) if (mover in loc) mover.set_loc(get_turf(loc))
