/mob/living/carbon/human/proc/show_inv(mob/user as mob)
	src.inventory.ui_interact(user)

/mob/living/carbon/human/proc/update_inv()
	tgui_process.update_uis(src.inventory)

/mob/living/carbon/human/proc/is_sealed()
    if (!src.wear_suit || !src.head)
        return FALSE

    return ((src.wear_suit.c_flags & SPACEWEAR) && (src.head.c_flags & SPACEWEAR))
