//#define CLAMP(V, MN, MX) max(MN, min(MX, V))
#define CLAMP(V, MN, MX) ((V<MN) ? MN : (V>MX) ? MX : V)

/proc/atan2(x, y)
	if(!x && !y) return 0
	.= y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))

/proc/angledifference(a1,a2) //difference in degrees between two angles in degrees
	.= ( a2 - a1 + 180 ) % 360 - 180
	if (. < -180)
		.+= 360

/proc/sign(x) //Should get bonus points for being the most compact code in the world!
	return x!=0?x/abs(x):0
#if DM_BUILD < 1490
/proc/clamp(var/number, var/min, var/max)
	return max(min(number, max), min)
//moved out of Railgun.dm into a slightly more applicable math.dm
/proc/arctan(x)
  var/y=arcsin(x/sqrt(1+x*x))
  return y
//This returns the tangent of x, for use with North and South straights.
/proc/tan(x)
	return (sin(x)/cos(x))
#endif
//This returns the tangent reciprocal of x, for use with East and West straights.
/proc/tanR(x)
	return (cos(x)/sin(x))
