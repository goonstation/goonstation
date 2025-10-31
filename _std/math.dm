/// e
#define eulers 2.7182818284
/// π
#define pi 3.14159265

/// ceil, with second argument being the multiple to use for rounding
#define ceil2(x,y) (-round(-x / y) * y)

/// rounds down to the nearest integer, note that the built-in round() function alwys roundsd to the lower integer
#define nround(x) ((((x) % 1) >= 0.5) ? round(x) : ceil(x))

/// decimal part of a number but always positive. Basically modulo 1 in a way
#define posfract(x) ((x) - floor(x))

/// x % y but without rounding x first (i.e. fractmodulo(5.7, 2) = 1.7), also always positive
#define fractmodulo(x, y) ((x) - (y) * floor((x) / (y)))

/// Returns the sign of the given number (1 or -1)
#define sign(x) (((x) > 0) - ((x) < 0))

/// cotangent
#define cot(x) (cos(x) / sin(x))

/// Takes a probability 'x' (0-100) and returns the probability (0-100) of seeing at least 1 success were you to test 'x' 'mult' times.
/// Used for lag-compensating prob rolls.
#define percentmult(x, mult) (100 * (1 - ((1 - (clamp((x), 0, 100) / 100))**mult)))

/// difference in degrees from angle x to angle y
#define angledifference(x,y) ((((y) - (x) + 180) % 360 - 180) + (((((y) - (x) + 180) % 360 - 180) < -180) ? 360 : 0))

/// NaN isn't a number, damn it. Infinity is a problem too.
#define isnum_safe(x) ( isnum((x)) && !isnan((x)) && !isinf((x)) ) //By ike709

/// Parses a number except for NaNs and infinities
proc/text2num_safe(x)
	. = text2num(x)
	if(isnum_safe(.))
		return
	return null

/// Similar to `text2num_safe`, but returns the original string on failure.
/proc/text2num_if_num(x)
	. = text2num(x)
	if (isnum_safe(.) && ("[.]" == x))
		return
	return x

/// rand() but for floats, returns a random floating point number between L and H
#define randfloat(L, H) ((L) + rand() * ((H) - (L)))

//bit math helpers

/**
	* provides the bit at a position (starting from 0) in a binary number
	* example: `EXTRACT_BIT(9, 1)`
	*
	* 9 in binary is `1001`
	* if i want to check the value of the 2nd bit in 9, i would use a value of 1 for position
	* this is because binary numbers start at 0 and bits are counted from right to left
	* then the << operator shifts that bit a number of bits to the left
	* in this case, it shifts it 1 bit to the left, turning 1 into 10 (in binary)
	* so what the macro looks like now (in binary) is `1001 & 0010`
	* the binary and operator (&) multiplies the values of the bits together
	* so doing `1001 & 0010` returns a value of `0000`
	* this tells us that the 2nd bit of `1001` is 0 (off)
	* if we did this with 11 (`1011`) instead, it would be `1011 & 0010`, which would return `0010`, which tells us that the 2nd bit of `1001` is 1 (on)
	*/
#define EXTRACT_BIT(number, position) (number & (1 << position))

/**
	* toggles the bit at a position (starting from 0) in a binary number
	* example: `TOGGLE_BIT(9, 1)`
	*
	* 9 in binary is `1001`
	* if i want to toggle the value of the 2nd bit in 9, i would use a value of 1 for position
	* this is because binary numbers start at 0 and bits are counted from right to left
	* then the << operator shifts that bit a number of bits to the left
	* in this case, it shifts it 1 bit to the left, turning 1 into 10 (in binary)
	* so what the macro looks like now (in binary) is `1001 ^ 0010`
	* the binary xor operator (`^`) sets a bit to 0 if the values of the bits are the same and sets a bit to 1 if the values are different
	* so doing `1001 & 0010` returns a value of `1011`
	* this just toggles the 2nd bit in the number from 0 to 1, or from 1 to 0
	* if we did this with 11 (`1011`) instead, it would be `1011 & 0010`, which would return `1001`
	*/
#define TOGGLE_BIT(number, position) (number ^ (1 << position))

/// creates a binary number that is length bits long. all bits in the number are turned on
#define CREATE_FULL_BINARY_NUM(length) ((1 << length) - 1)

/// creates a binary number that is length bits long. all bits in the number are turned off
#define CREATE_EMPTY_BINARY_NUM(length) (0)

/// Linearly interpolates a and b based on t
#define lerp(a, b, t) ((a) * (1 - (t)) + (b) * (t))

/// pseudorandom number based on x, y in range 0 to 1
/proc/fixed_random(x, y)
	. = sin(x * 12.9898 + y * 78.233) * 43758.5453
	. -= round(.)

// hyperbolic trig functions
#define sech(x) (2/((eulers**x)+(eulers**-x)+0.000001))
#define tanh(x) (((eulers**(2*x))-1)/((eulers**(2*x))+1))
