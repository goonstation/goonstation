#define eulers 2.7182818284
#define pi 3.14159265

//#define nround(x, n) round(x, 10 ** n)
//#define floor(x) round(x)
//#define ceiling(x) -round(-x)

#define ceil(x) (-round(-(x)))
#define nround(x) (((x % 1) >= 0.5)? round(x) : ceil(x))
#define sign(x) ((x) != 0 ? (x) / abs(x) : 0)
#define tanR(x) (cos(x) / sin(x))
#define percentmult(x, mult) (100 * (1 - ((1 - (clamp((x), 0, 100) / 100))**mult)))

//#define angledifference(x,y) ((((y) - (x) + 180) % 360 - 180) + (((((y) - (x) + 180) % 360 - 180) < -180) ? 360 : 0))
//this is hecka ugly, so im just leaving the proc in

/proc/angledifference(a1,a2) //difference in degrees between two angles in degrees
	.= ( a2 - a1 + 180 ) % 360 - 180
	if (. < -180)
		.+= 360
