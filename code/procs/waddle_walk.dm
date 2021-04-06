// Makes mobs do a little waddle animation on walk, like south park characters

var/global/waddle_walking = 0

/proc/getMatrixFromPool(angle = 0)
	var/textangle = num2text(angle)
	var/static/matrices = list()
	if (!matrices[textangle])
		matrices[textangle] = angle ? turn(matrix(), angle) : matrix()
	return matrices[textangle]

#define WADDLE_TIME 2
/proc/makeWaddle(var/mob/H)
	set waitfor = FALSE
	var/static/list/animation_locked = list()
	if (!animation_locked[H])
		animation_locked[H] = TRUE
		var/matrix/M = H.transform
		animate(H, pixel_z = 6, time = 0)
		animate(pixel_z = 0, transform = (M * getMatrixFromPool(nextWaddle(H))), time = WADDLE_TIME)
		animate(pixel_z = 0, transform = M, time = 0)
		sleep(WADDLE_TIME)
		animation_locked[H] = FALSE
#undef WADDLE_TIME

/proc/nextWaddle(var/mob/H)
	var/static/waddles = list()
	if (!waddles[H])
		waddles[H] = -16
	else
		waddles[H] = next_in_list(waddles[H], list(-16, 16))
	return waddles[H]
