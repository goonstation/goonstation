#define EULERS_NUMBER 2.71828

proc/gaussian(var/amplitude, var/spread, var/dx, var/dy)
	return amplitude * (
							EULERS_NUMBER ** (\
								-1 * (\
									  dx ** 2 / (2 * spread ** 2)\
									+ dy ** 2 / (2 * spread ** 2)\
								)\
							)\
					   )

