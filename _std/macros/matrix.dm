/**
	* Returns a matrix representing what you get if you undo a series of transformations that happened at some point in the past.
	*
	* Relies on the fact that no one resets the matrix in the meantime and also on the fact that the transformations are reversible.
	*
	* Example:
	* ```dm
	* var/matrix/orignal = matrix(src.transform)
	* src.transform = src.Transform.Turn(180)
	* var/matrix/after = matrix(src.transform)
	* sleep(10 SECONDS) // more transformations might happen here!
	* src.transform = UNDO_TRANSFORMATION(original, after, src.transform)
	* ```
	*/
#define UNDO_TRANSFORMATION(ORIGINAL, AFTER_TRANSFORM, CURRENT) ((ORIGINAL) * (AFTER_TRANSFORM).Invert() * CURRENT)
