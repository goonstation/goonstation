/obj/item/device/lollipopmaker
	name = "lollipop synthesizer"
	desc = "A portable synthesizer used to make fruity treats."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "lollipop-h"

	attack_self(var/mob/user as mob)

		if(ON_COOLDOWN(src, "vend_cooldown", 10 SECONDS))
			user.show_text("It's still recharging, give it a moment.", "red")

		else
			new /obj/item/reagent_containers/food/snacks/lollipop/fruit(get_turf(src))
			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			user.visible_message("<span class='notice'>[user] dispenses a lollipop.</span>")
		return

/obj/item/device/lollipopmaker/md
		name = "NT Lollipop Synthesizer"
		desc = "It's like the green ones but the Medical Director owns this one."
		icon_state = "lollipop-hmd"
