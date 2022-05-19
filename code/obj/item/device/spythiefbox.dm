/obj/item/device/spytheifbox // the box spy thieves start with to choose their item
	name = "storage"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "blank_box"
	desc = "A box that can hold a number of small items. There appears to be a button on it"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"


	attack_self(var/mob/M)
		..()
		choose_item()

		var/mob/living/carbon/human/H = holder.owner



	proc/choose_item(var/mob/living/carbon/human/C)
		var/list/choices = list()
		choices += ("Camera with built-in flash")
		choices += ("Scuttlebot")

		var/choice = input("Choose which item you want: ", "Select Item", null) as null|anything in choices
		if (!choice)
			boutput(holder.owner, __blue("You leave the box alone."))
			return 1
		var/choice_index = choices.Find(choice)

