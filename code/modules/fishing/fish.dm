//file for da fish
//TODO: refactor types of fish. add fish "qualities" which influence sell values?? but who do you sell fish to?? idk.

// Gannets new fish

/*
Fish lists:
Currently implemented: 5 (+1 joke)
	Salmon*
	Carp*
	Bass*
	Herring* & Red Herring*
	Mahi-mahi

 Freshwater fish:
	Large-mouth black bass (see bass above)
	Salmon (see salmon above)
	Crucian Carp (see carp above)
	Rainbow trout
	Goldfish

	Chub
	Eel
	Dace
	Minnow
	Pike

Ocean saltwater fish:
	Herring (see herring/red herring above)
	Bluefun tuna
	Cod
	Flounder
	Coelacanth

	Blue Marlin
	Red Snapper
	Ocean Sunfish
	Sardine
	Swordfish

Aquarium saltwater fish: Some of these are Oshan fish currently
	Clownfish
	Damselfish
	Green Chromis
	Cardinalfish
	Royal Gamma

	Bicolor Angelfish
	Blue Tang
	Firefish
	Yellow Tang
	Mandarin Fish
*/

#define FISH_CATEGORY_FRESHWATER "freshwater"
#define FISH_CATEGORY_OCEAN "ocean"
#define FISH_CATEGORY_AQUARIUM "aquarium"

/obj/item/fish
	icon = 'icons/obj/foodNdrink/food_fish.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "fish"
	w_class = W_CLASS_NORMAL
	hitsound = null // handled in attack() below
	c_flags = ONBELT
	attack_verbs = "slaps"
	/// what type of item do we get when butchering the fish
	var/fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	/// What kind of fish is this? (See defines above)
	var/category = null

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)

	attack(mob/M, mob/user)
		if(user?.bioHolder.HasEffect("clumsy") && prob(50))
			user.changeStatus("weakened", 2 * src.force SECONDS)
			JOB_XP(user, "Clown", 1)
			..(user, user) // bonk
		else
			..()
		playsound(src.loc, pick('sound/impact_sounds/Slimy_Hit_1.ogg', 'sound/impact_sounds/Slimy_Hit_2.ogg'), 50, 1, -1)

	attackby(var/obj/item/W, var/mob/user)
		if(istype(W, /obj/item/kitchen/utensil/knife))
			if(fillet_type)
				var/obj/fillet = new fillet_type(src.loc)
				user.put_in_hand_or_drop(fillet)
				boutput(user, "<span class='notice'>You skin and gut \the [src] using your knife.</span>")
				qdel(src)
				return
		..()

// Freshwater fish

/obj/item/fish/bass
		name = "largemouth bass"
		desc = "A freshwater fish native to North America."
		icon_state = "bass"
		inhand_color = "#64B19C"
		fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/white
		category = FISH_CATEGORY_FRESHWATER

/obj/item/fish/salmon
	name = "salmon"
	desc = "A commercial saltwater fish prized for its flavor."
	icon_state = "salmon"
	inhand_color = "#E3747E"
	fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/salmon
	category = FISH_CATEGORY_FRESHWATER

/obj/item/fish/carp
		name = "carp"
		desc = "A common run-of-the-mill carp."
		icon_state = "carp"
		inhand_color = "#BBCA8A"
		category = FISH_CATEGORY_FRESHWATER

/obj/item/fish/rainbow_trout
		name = "rainbow trout"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#4a6169"
		category = FISH_CATEGORY_FRESHWATER

/obj/item/fish/goldfish
		name = "goldfish"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#f3a807"
		category = FISH_CATEGORY_FRESHWATER

// Ocean saltwater fish

/obj/item/fish/herring
		name = "herring"
		desc = "A small ocean fish that swims in schools."
		icon_state = "herring"
		inhand_color = "#90B6CA"
		category = FISH_CATEGORY_OCEAN

/obj/item/fish/red_herring
		name = "peculiarly coloured clupea pallasi"
		desc = "What is this? Why is this here? WHAT IS THE PURPOSE OF THIS?"
		icon_state = "red_herring"
		inhand_color = "#DC5A5A"
		category = FISH_CATEGORY_OCEAN

/obj/item/fish/tuna
		name = "bluefun tuna"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#3123f8"
		category = FISH_CATEGORY_OCEAN

/obj/item/fish/cod
		name = "atlantic cod"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#87d1db"
		category = FISH_CATEGORY_OCEAN

/obj/item/fish/flounder
		name = "flounder"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#5c471b"
		category = FISH_CATEGORY_OCEAN

/obj/item/fish/coelacanth
		name = "coelacanth"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#81878a"
		category = FISH_CATEGORY_OCEAN

// Aquarium saltwater fish

/obj/item/fish/clownfish
		name = "clownfish"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#ff6601"
		category = FISH_CATEGORY_AQUARIUM

/obj/item/fish/damselfish
		name = "damselfish"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#ff6601"
		category = FISH_CATEGORY_AQUARIUM

/obj/item/fish/green_chromis
		name = "green chromis"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#3af121"
		category = FISH_CATEGORY_AQUARIUM

/obj/item/fish/cardinalfish
		name = "cardinalfish"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#b2b427"
		category = FISH_CATEGORY_AQUARIUM

/obj/item/fish/royal_gamma
		name = "daroyal gamma"
		desc = "todo"
		icon_state = "bass_old"
		inhand_color = "#9a05f0"
		category = FISH_CATEGORY_AQUARIUM

//Unsorted

/obj/item/fish/mahimahi
		name = "Mahi-mahi"
		desc = "Also known as a dolphinfish, this tropical fish is prized for its quality and size. When first taken out of the water, they change colors."
		icon_state = "mahimahi"
		inhand_color = "#A6B967"
		fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/white
