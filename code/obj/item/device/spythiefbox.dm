/obj/item/device/spybox // the box spy thieves start with to choose their item
	name = "Box"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "box"
	desc = "A box that can hold a number of small items. There appears to be a button on it"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"


	attack_self()
		var/list/L = list("Spy Camera", "Scuttlebot")
		var/result = tgui_input_list(usr, "Choose a device", "Transforming box...", L)

		if(result == null) // runtime be gone!
			return
		if(result == "Spy Camera")
			var/spycamera = new /obj/item/camera/spy(get_turf(src))
			usr.put_in_hand_or_drop(spycamera)
		if(result == "Scuttlebot")
			var/scuttlebot = new /obj/item/clothing/head/det_hat/folded_scuttlebot(get_turf(src))
			usr.put_in_hand_or_drop(scuttlebot)
		boutput(usr, "<span class='notice'>The box transforms into a [result]!</span>")
		qdel(src)
