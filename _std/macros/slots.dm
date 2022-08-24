
/// Gets internal var where a slot is stored. You shouldn't need to use this ever
#define BUILD_INTERNAL_SLOT_VAR(SLOT) _slot_ ## SLOT

/// Gets the movable stored in a given slot
#define GET_SLOT(SLOT) (null || BUILD_INTERNAL_SLOT_VAR(SLOT))
// The above compiles to the same bytecode as if we removed the `null ||` but this way you can't assign to it directly like GET_SLOT(x) = y

/// Defines a slot on the current /atom/movable
#define DEFINE_SLOT(TYPE, SLOT) var ## TYPE/BUILD_INTERNAL_SLOT_VAR(SLOT)
