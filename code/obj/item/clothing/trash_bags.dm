
/obj/item/clothing/under/trash_bag
	name = "trash bag"
	desc = "A flimsy bag for filling with things that are no longer wanted."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	icon_state = "trashbag-f"
	uses_multiple_icon_states = 1
	item_state = ""
	w_class = W_CLASS_TINY
	rand_pos = 1
	flags = FPRINT | TABLEPASS | NOSPLASH
	tooltip_flags = REBUILD_DIST
	body_parts_covered = TORSO
	var/base_state = "trashbag"

	New()
		..()
		src.create_storage(/datum/storage/no_hud, prevent_holding = list(/obj/item/clothing/under/trash_bag), max_wclass = W_CLASS_NORMAL, slots = 20,
			params = list("use_inventory_counter" = TRUE, "variable_weight" = TRUE, "max_weight" = 20))

	equipped(mob/user)
		..()
		for (var/i = 1 to round(length(src.storage.get_contents()) / 3))
			src.remove_random_item(user)

	attackby(obj/item/W, mob/user)
		..()
		if (prob(33))
			return
		if (!(W in src.storage.get_contents()))
			return
		var/mob/living/carbon/human/H = src.loc
		if (istype(H) && H.w_uniform == src)
			src.remove_random_item(H)

	attack_hand(mob/user)
		..()
		if (prob(33))
			return
		var/mob/living/carbon/human/H = src.loc
		if (istype(H) && H.w_uniform == src)
			src.remove_random_item(H)

	update_icon(mob/user)
		if (!src.storage || !length(src.storage.get_contents()))
			src.icon_state = initial(src.icon_state)
			src.item_state = ""

		else if (length(src.storage.get_contents()))
			src.icon_state = src.base_state
			src.item_state = src.base_state

		if (ismob(user))
			user.update_inhands()

	get_desc(dist)
		..()
		if (dist > 2)
			return
		if (src.storage.is_full())
			. += "It's totally full."
		else
			. += "There's still some room to hold something."

	proc/remove_random_item(mob/user)
		if (!length(src.storage.get_contents()))
			return
		var/obj/item/I = pick(src.storage.get_contents())
		src.storage.transfer_stored_item(I, get_turf(src))
		if (user)
			user.visible_message("\An [I] falls out of [user]'s [src.name]!", "<span class='alert'>\An [I] falls out of your [src.name]!</span>")
		else
			src.loc.visible_message("\An [I] falls out of [src]!")

/obj/item/clothing/under/trash_bag/biohazard
	name = "hazardous waste bag"
	desc = "A flimsy bag for filling with things that are no longer wanted and are also covered in blood or puke or other gross biohazards. It's not any sturdier than a normal trash bag, though, so be careful with the needles!"
	icon_state = "biobag-f"
	base_state = "biobag"
