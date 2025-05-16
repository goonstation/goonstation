/**
	* If used inside a type definition, defines an "ephemeral" subtype which overrides New() to remove itself without calling parents.
	* A secondary [EPHEMERAL_SHOWN][EPHEMERAL_SHOWN] define exists, which also defines an "ephemeral" subtype but one that doesn't override anything.
	* Example use-case:
	* An EPHEMERAL_XMAS define, which depending on whether it's christmas is #ifdef-ined at compile time to be either EPHEMERAL_SHOWN or EPHEMERAL_HIDDEN.
	* Placing that EPHEMERAL_XMAS define in a type's definition will define an "ephemeral" subtype for it that will either do nothing or remove itself respectively.
	*/
#define EPHEMERAL_HIDDEN \
	ephemeral { \
		New() { \
			SHOULD_CALL_PARENT(FALSE); \
			src.loc = null; \
		} \
	}

/**
	* Generates an "ephemeral" subtype which doesn't override anything.
	* See [EPHEMERAL_HIDDEN][EPHEMERAL_HIDDEN] define's documentation for its purpose.
	*/
#define EPHEMERAL_SHOWN \
	ephemeral
