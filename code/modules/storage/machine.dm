/// For things which are meant to be a part of a machine. No rustling, no interacting with by hand, etc. DONT!!!
/datum/storage/no_hud/machine
	sneaky = TRUE
	move_triggered = FALSE
	stack_stackables = TRUE

	add_contents_extra(obj/item/I, mob/user, visible)
		visible = FALSE

		var/obj/machinery/M = src.linked_item
		M.on_add_contents(I)

		. = ..()

