/proc/angledifference(a1,a2) //difference in degrees between two angles in degrees
	.= ( a2 - a1 + 180 ) % 360 - 180
	if (. < -180)
		.+= 360

/proc/sign(x) //Should get bonus points for being the most compact code in the world!
	return x!=0?x/abs(x):0

//This returns the tangent reciprocal of x, for use with East and West straights.
/proc/tanR(x)
	return (cos(x)/sin(x))
