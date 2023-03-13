TYPEINFO(/datum/component/train)
	initialization_args = list(
		ARG_INFO("cart", DATA_INPUT_REFPICKER, "The thing to link to this object.", null)
	)

/datum/component/train
	var/atom/movable/cart = null

/datum/component/train/Initialize(var/atom/movable/cart)
	..()
	if (!istype(cart) || !istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.cart = cart

/datum/component/train/RegisterWithParent()
	RegisterSignal(src.parent, COMSIG_MOVABLE_MOVED, .proc/on_parent_move)
	RegisterSignal(src.cart, COMSIG_MOVABLE_BLOCK_MOVE, .proc/on_cart_move)

/datum/component/train/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(src.cart, COMSIG_MOVABLE_BLOCK_MOVE)

/datum/component/train/proc/on_parent_move(atom/movable/thing, previous_loc, direction)
	if (thing.loc != previous_loc)
		cart.Move(previous_loc)

/datum/component/train/proc/on_cart_move(atom/movable/thing, new_loc, direction)
	if (BOUNDS_DIST(new_loc, src.parent))
		return TRUE
