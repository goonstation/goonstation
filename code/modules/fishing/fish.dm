//file for da fish
//TODO: refactor types of fish. add fish "qualities" which influence sell values?? but who do you sell fish to?? idk.

/*
Fish lists:

 Freshwater fish:
	Implemented:
		Large-mouth black bass
		Salmon
		Crucian Carp
		Rainbow trout
		Goldfish
	Unimplemented:
		Chub
		Eel
		Dace
		Minnow
		Pike

Ocean saltwater fish:
	Implemented:
		Herring
		Red herring
		Bluefun tuna
		Cod
		Flounder
		Coelacanth
		Mahi-mahi
		Shrimp
	Unimplemented:
		Blue Marlin
		Red Snapper
		Ocean Sunfish
		Sardine
		Swordfish

Aquarium saltwater fish:
	Implemented:
		Clownfish
		Damselfish
		Green Chromis
		Cardinalfish
		Royal Gramma
	Unimplemented:
		Bicolor Angelfish
		Blue Tang
		Firefish
		Yellow Tang
		Mandarin Fish

Alien/mutant/other fish:
	Implemented:
		Meat mutant
		Blood fish
		Eye fish
		Void fish
		Sun fish
		Lava fish
		Blobfish
		Whale?
*/
// These catagories aren't used currently.
#define FISH_CATEGORY_FRESHWATER "freshwater"
#define FISH_CATEGORY_OCEAN "ocean"
#define FISH_CATEGORY_AQUARIUM "aquarium"

// Values used by upload terminal and fishing vendor to determine how many points the fish is worth.
#define FISH_RARITY_COMMON 1
#define FISH_RARITY_UNCOMMON 2
#define FISH_RARITY_RARE 3
#define FISH_RARITY_EPIC 4
#define FISH_RARITY_LEGENDARY 5

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
	// How many points is this fish worth in the upload terminal?
	var/value = FISH_RARITY_COMMON

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
	desc = "A fighty freshwater fish, a good catch for a beginner angler."
	icon_state = "bass"
	inhand_color = "#398f3d"
	fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/white
	category = FISH_CATEGORY_FRESHWATER
	value  = FISH_RARITY_COMMON

/obj/item/fish/salmon
	name = "salmon"
	desc = "A commercial saltwater fish prized for its flavor for over five thousand years."
	icon_state = "salmon"
	inhand_color = "#E3747E"
	fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/salmon
	category = FISH_CATEGORY_FRESHWATER
	value  = FISH_RARITY_COMMON

/obj/item/fish/carp
	name = "carp"
	desc = "The queen of rivers. A very popular game fish, though not as revered in the USA."
	icon_state = "carp"
	inhand_color = "#BBCA8A"
	category = FISH_CATEGORY_FRESHWATER
	value  = FISH_RARITY_COMMON

/obj/item/fish/rainbow_trout
	name = "rainbow trout"
	desc = "A highly-regarded game fish with a vivid red stripe along it."
	icon_state = "trout"
	inhand_color = "#4a6169"
	category = FISH_CATEGORY_FRESHWATER
	value  = FISH_RARITY_UNCOMMON

/obj/item/fish/goldfish
	name = "goldfish"
	desc = "A commonly kept indoor aquarium fish. More clever than you might expect."
	icon_state = "goldfish"
	inhand_color = "#f3a807"
	category = FISH_CATEGORY_FRESHWATER
	value  = FISH_RARITY_COMMON

// Ocean saltwater fish

/obj/item/fish/herring
	name = "herring"
	desc = "The silver darling. A small ocean fish that swims in schools."
	icon_state = "herring"
	inhand_color = "#90B6CA"
	category = FISH_CATEGORY_OCEAN
	value  = FISH_RARITY_COMMON


/obj/item/fish/red_herring
	name = "peculiarly coloured clupea pallasi"
	desc = "What is this? Why is this here? WHAT IS THE PURPOSE OF THIS?"
	icon_state = "red_herring"
	inhand_color = "#DC5A5A"
	category = FISH_CATEGORY_OCEAN
	value = FISH_RARITY_LEGENDARY

/obj/item/fish/tuna
	name = "bluefin tuna"
	desc = "Formerly known as the tunny. Delicious but sadly overfished."
	icon_state = "bass_old"
	inhand_color = "#3123f8"
	category = FISH_CATEGORY_OCEAN
	value  = FISH_RARITY_UNCOMMON

/obj/item/fish/cod
	name = "atlantic cod"
	desc = "The keystone of fish & chips. Enjoyed since 800 AD."
	icon_state = "bass_old"
	inhand_color = "#87d1db"
	category = FISH_CATEGORY_OCEAN
	value  = FISH_RARITY_COMMON

/obj/item/fish/flounder
	name = "flounder"
	desc = "A flatfish found at the bottom of oceans around the world. It's got it's eyes on you!"
	icon_state = "bass_old"
	inhand_color = "#5c471b"
	category = FISH_CATEGORY_OCEAN
	value  = FISH_RARITY_COMMON

/obj/item/fish/coelacanth
	name = "coelacanth"
	desc = "Lazarus had nothing on you. We thought you went to the celestial zoo. The lungfish calls you brother and I guess that we should too."
	icon_state = "bass_old"
	inhand_color = "#81878a"
	category = FISH_CATEGORY_OCEAN
	value  = FISH_RARITY_RARE

/obj/item/fish/mahimahi
	name = "Mahi-mahi"
	desc = "Also known as a dolphinfish, this tropical fish is prized for its quality and size. When first taken out of the water, they change colors."
	icon_state = "mahimahi"
	inhand_color = "#A6B967"
	fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/white
	category = FISH_CATEGORY_OCEAN
	value  = FISH_RARITY_COMMON

/obj/item/fish/shrimp
	name = "shrimp"
	desc = "Shrimple as that."
	icon_state = "bass_old"
	inhand_color = "#db82db"
	category = FISH_CATEGORY_OCEAN
	value  = FISH_RARITY_UNCOMMON

// Aquarium saltwater fish

/obj/item/fish/clownfish
	name = "clownfish"
	desc = "A pop-culturarly significant orange fish that lives in a symbiotic relationship with an enemone."
	icon_state = "bass_old"
	inhand_color = "#ff6601"
	category = FISH_CATEGORY_AQUARIUM
	value  = FISH_RARITY_COMMON

/obj/item/fish/damselfish
	name = "damselfish"
	desc = "A small pretty fish native to tropical coral reefs and your local aquarium."
	icon_state = "bass_old"
	inhand_color = "#ff6601"
	category = FISH_CATEGORY_AQUARIUM
	value  = FISH_RARITY_COMMON

/obj/item/fish/green_chromis
	name = "green chromis"
	desc = "Beautiful iridescent apple-green. Wait a second, isn't this a damselfish?"
	icon_state = "bass_old"
	inhand_color = "#3af121"
	category = FISH_CATEGORY_AQUARIUM
	value  = FISH_RARITY_COMMON

/obj/item/fish/cardinalfish
	name = "cardinalfish"
	desc = "A nocturnal ray-finned fish enjoyed for being small, peaceful and colourful."
	icon_state = "bass_old"
	inhand_color = "#b2b427"
	category = FISH_CATEGORY_AQUARIUM
	value  = FISH_RARITY_UNCOMMON

/obj/item/fish/royal_gramma
	name = "royal gramma"
	desc = "todo"
	icon_state = "bass_old"
	inhand_color = "#9a05f0"
	category = FISH_CATEGORY_AQUARIUM
	value  = FISH_RARITY_UNCOMMON

// adventure zone special fish

//meatzone
/obj/item/fish/meat_mutant
	name = "meat mutant"
	desc = "A fish? Whatver it is, it's grown accustomed to swimming in a pool of digestive acids."
	icon_state = "bass_old"
	inhand_color = "#af2323"
	value  = FISH_RARITY_RARE

/obj/item/fish/blood_fish
	name = "blood fish"
	desc = "A viscous, gory mass of congealed blood. You're really stretching the definition of fish here."
	icon_state = "bass_old"
	inhand_color = "#af2323"
	value  = FISH_RARITY_RARE

/obj/item/fish/eye_mutant
	name = "eye mutant"
	desc = "Was this a fish once? It's got too many eyes on you."
	icon_state = "bass_old"
	inhand_color = "#f0f0f0"
	value  = FISH_RARITY_RARE

//void
/obj/item/fish/void_fish
	name = "void fish"
	desc = "This fish has swum through the timestream to witness the death of the universe. Probably doesn't fry too well."
	icon_state = "bass_old"
	inhand_color = "#8f3ed1"
	value  = FISH_RARITY_RARE

//solarium
/obj/item/fish/sun_fish
	name = "literal sun fish"
	desc = "Nobody will ever believe you."
	icon_state = "bass_old"
	inhand_color = "#ebde2d"
	value  = FISH_RARITY_LEGENDARY

//lava moon
/obj/item/fish/lava_fish
	name = "lava fish"
	desc = "a blazing hot catch straight from the planet's core!"
	icon_state = "bass_old"
	inhand_color = "#eb2d2d"
	value  = FISH_RARITY_RARE
//blob
/obj/item/fish/blobfish
	name = "Blobfish"
	desc = "Looking good, blobfish."
	icon_state = "bass_old"
	inhand_color = "#da8fac"
	value  = FISH_RARITY_RARE

