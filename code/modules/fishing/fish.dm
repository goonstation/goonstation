//file for da fish
//TODO: refactor types of fish. add fish "qualities" which influence sell values?? but who do you sell fish to?? idk.

/obj/item/fish
	throwforce = 3
	force = 5
	icon = 'icons/obj/foodNdrink/food_fish.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "fish"
	w_class = W_CLASS_NORMAL
	flags = ONBELT
	/// what type of item do we get when butchering the fish
	var/fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)

	attack(mob/M as mob, mob/user as mob)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> swings \the [src] and hits [himself_or_herself(user)] in the face!.</span>")
			user.changeStatus("weakened", 2 * src.force SECONDS)
			JOB_XP(user, "Clown", 1)
			return
		else
			playsound(src.loc, pick('sound/impact_sounds/Slimy_Hit_1.ogg', 'sound/impact_sounds/Slimy_Hit_2.ogg'), 50, 1, -1)
			user.visible_message("<span class='alert'><b>[user] slaps [M] with \the [src]!</b>.</span>")

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/kitchen/utensil/knife))
			if(fillet_type)
				var/obj/fillet = new fillet_type(src.loc)
				user.put_in_hand_or_drop(fillet)
				boutput(user, "<span class='notice'>You skin and gut \the [src] using your knife.</span>")
				qdel(src)
				return
		..()
		return

/obj/item/fish/salmon
	name = "salmon"
	desc = "A commercial saltwater fish prized for its flavor."
	icon_state = "salmon"
	inhand_color = "#E3747E"
	fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/salmon

/obj/item/fish/carp
		name = "carp"
		desc = "A common run-of-the-mill carp."
		icon_state = "carp"
		inhand_color = "#BBCA8A"

/obj/item/fish/bass
		name = "largemouth bass"
		desc = "A freshwater fish native to North America."
		icon_state = "bass"
		inhand_color = "#64B19C"
		fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/white

/obj/item/fish/herring
		name = "herring"
		desc = "A small ocean fish that swims in schools."
		icon_state = "herring"
		inhand_color = "#90B6CA"

/obj/item/fish/red_herring
		name = "peculiarly coloured clupea pallasi"
		desc = "What is this? Why is this here? WHAT IS THE PURPOSE OF THIS?"
		icon_state = "red_herring"
		inhand_color = "#DC5A5A"

/obj/item/fish/mahimahi
		name = "Mahi-mahi"
		desc = "Also known as a dolphinfish, this tropical fish is prized for its quality and size. When first taken out of the water, they change colors."
		icon_state = "mahimahi"
		inhand_color = "#A6B967"
		fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/white
