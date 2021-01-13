/// e
#define eulers 2.7182818284
/// π
#define pi 3.14159265

/// Gets the ceiling (maps x to the least integer greater than or equal to x)
#define ceil(x) (-round(-(x)))

/// ceil, with second argument being the multiple to use for rounding
#define ceil2(x,y) (-round(-x / y) * y)

#define nround(x) (((x % 1) >= 0.5)? round(x) : ceil(x))

/// Returns the sign of the given number (1 or -1)
#define sign(x) ((x) != 0 ? (x) / abs(x) : 0)

/// cotangent
#define cot(x) (cos(x) / sin(x))

/// Takes a probability 'x' (0-100) and returns the probability (0-100) of seeing at least 1 success were you to test 'x' 'mult' times.
/// Used for lag-compensating prob rolls.
#define percentmult(x, mult) (100 * (1 - ((1 - (clamp((x), 0, 100) / 100))**mult)))

//#define angledifference(x,y) ((((y) - (x) + 180) % 360 - 180) + (((((y) - (x) + 180) % 360 - 180) < -180) ? 360 : 0))
//this is hecka ugly, so im just leaving the proc in

/// difference in degrees between two angles in degrees
/proc/angledifference(a1,a2)
	.= ( a2 - a1 + 180 ) % 360 - 180
	if (. < -180)
		.+= 360

/// isnum() returns TRUE for NaN. Also, NaN != NaN. Checkmate, BYOND.
#define isnan(x) ( (x) != (x) )

/// Returns true if the number is infinity or -infinity
#define isinf(x) (isnum((x)) && (((x) == text2num("inf")) || ((x) == text2num("-inf"))))

/// NaN isn't a number, damn it. Infinity is a problem too.
#define isnum_safe(x) ( isnum((x)) && !isnan((x)) && !isinf((x)) ) //By ike709
