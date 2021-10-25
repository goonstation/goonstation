/obj/item/device/lollipopmaker
	name = "Lollipop Synthesizer"
	desc = "A portable synthesizer used to make sugary treats."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "lollipop-h"

	attack_self(var/mob/user as mob)

		if(ON_COOLDOWN(src, "vend_cooldown", 10 SECONDS))
			user.show_text("It's still recharging, give it a moment. ", "red")
			
		else new /obj/item/reagent_containers/food/snacks/lollipop/fruit(get_turf(src))

/obj/item/device/lollipopmaker/md
	name = "Medical Lollipop Synthesizer"
	desc = "A portable synthesizer used to make emergency medi-pops."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "lollipop-md"

	New()
		..()
	attack_self(var/mob/user as mob)

		if(ON_COOLDOWN(src, "vend_cooldown", 20 SECONDS))
			user.show_text("It's still recharging, give it a moment. ", "red")
			
		else new /obj/item/reagent_containers/food/snacks/lollipop/random_medical(get_turf(src))
