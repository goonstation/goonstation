TYPEINFO(/datum/component/train)
	initialization_args = list(
		ARG_INFO("cart", DATA_INPUT_REFPICKER, "The thing to link to this object.", null),
		ARG_INFO("glide", DATA_INPUT_BOOL, "Linked thing moves like us.", null)
	)

/datum/component/train
	var/atom/movable/cart = null
	var/match_glide = FALSE

/datum/component/train/Initialize(var/atom/movable/cart, var/glide)
	..()
	if (!istype(cart) || !istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.cart = cart
	src.match_glide = glide

/datum/component/train/RegisterWithParent()
	RegisterSignal(src.parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_move))
	RegisterSignal(src.cart, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_cart_move))

/datum/component/train/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(src.cart, COMSIG_MOVABLE_PRE_MOVE)

/datum/component/train/proc/on_parent_move(atom/movable/thing, previous_loc, direction)
	if (thing.loc != previous_loc && !QDELETED(cart))

		if(src.match_glide)
			cart.glide_size = thing.glide_size
		cart.Move(previous_loc)
		if(src.match_glide)
			cart.glide_size = thing.glide_size

/datum/component/train/proc/on_cart_move(atom/movable/thing, new_loc, direction)
	if (BOUNDS_DIST(new_loc, src.parent))
		return TRUE
