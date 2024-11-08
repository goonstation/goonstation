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
		Chub
		Eel
		Dace
		Minnow
		Pike
		Arapaima
		Rosefin Shiner
		Catfish
		Tiger Oscar

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
		Sardine
		Barracuda
		Sailfish
	Unimplemented:
		Blue Marlin
		Red Snapper
		Ocean Sunfish
		Swordfish

Aquarium saltwater fish:
	Implemented:
		Clownfish
		Damselfish
		Green Chromis
		Cardinalfish
		Royal Gramma
		Bicolor Angelfish
		Blue Tang
		Firefish
		Yellow Tang
		Mandarin Fish
		Lionfish
		Betta

Alien/mutant/other fish:
	Implemented:
		Meat mutant
		Eye fish
		Void fish
		Sun fish
		Blobfish
		Lava fish
		Molten fish
		Golden fish
		Ling fish
		Tree fish
	Unimplemented:
		Blood fish
*/

// These catagories aren't used currently.
#define FISH_CATEGORY_FRESHWATER "freshwater"
#define FISH_CATEGORY_OCEAN "ocean"
#define FISH_CATEGORY_AQUARIUM "aquarium"

ABSTRACT_TYPE(/obj/item/reagent_containers/food/fish)
/obj/item/reagent_containers/food/fish
	icon = 'icons/obj/foodNdrink/food_fish.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "fish"
	w_class = W_CLASS_NORMAL
	hitsound = null // handled in attack() below
	c_flags = ONBELT
	attack_verbs = "slaps"
	initial_volume = 50
	edible = 0
	doants = 0
	custom_food = FALSE
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet
	slice_amount = 1
	slice_suffix = "fillet"
	food_color = "#F4B4BC"
	/// What kind of fish is this? (See defines above)
	var/category = null
	// How many points is this fish worth in the upload terminal?
	rarity = ITEM_RARITY_COMMON
	// If this is set to true, the fish cannot be turned in for points
	var/fishing_upload_blacklisted = FALSE

/obj/item/reagent_containers/food/fish/New()
	..()
	src.setItemSpecial(/datum/item_special/swipe)
	src.make_reagents()

/obj/item/reagent_containers/food/fish/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if(user?.bioHolder.HasEffect("clumsy") && prob(50))
		user.changeStatus("knockdown", 2 * src.force SECONDS)
		JOB_XP(user, "Clown", 1)
		..(user, user) // bonk
	else
		..()
		src.slapsound()

/obj/item/reagent_containers/food/fish/proc/slapsound()
	playsound(src.loc, pick('sound/impact_sounds/Slimy_Hit_1.ogg', 'sound/impact_sounds/Slimy_Hit_2.ogg'), 50, 1, -1)


/obj/item/reagent_containers/food/fish/HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
	src.fishing_upload_blacklisted = TRUE
	src.desc += " The quality of this organical grown fish sadly doesn't compare to one catched in the wild."
	HYPadd_harvest_reagents(src,origin_plant,passed_genes,quality_status)
	return src

/obj/item/reagent_containers/food/fish/proc/make_reagents()
	src.reagents.add_reagent("fishoil", 20)
	return


// Freshwater fish

/obj/item/reagent_containers/food/fish/bass
	name = "largemouth bass"
	desc = "A fighty freshwater fish, a good catch for a beginner angler."
	icon_state = "bass"
	inhand_color = "#398f3d"
	food_color = "#FFECB7"
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet/white
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/salmon
	name = "salmon"
	desc = "A commercial saltwater fish prized for its flavor for over five thousand years."
	icon_state = "salmon"
	inhand_color = "#E3747E"
	food_color = "#F29866"
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet/salmon
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/carp
	name = "carp"
	desc = "The queen of rivers. A very popular game fish, though not as revered in the USA."
	icon_state = "carp"
	inhand_color = "#BBCA8A"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/rainbow_trout
	name = "rainbow trout"
	desc = "A highly-regarded game fish with a vivid red stripe along it."
	icon_state = "trout"
	inhand_color = "#4a6169"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/goldfish
	name = "goldfish"
	desc = "A commonly kept indoor aquarium fish. More clever than you might expect."
	icon_state = "goldfish"
	inhand_color = "#f3a807"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/chub
	name = "chub"
	desc = "The sea chub, also known as the rudderfish or the pilot fish. Wait which one is this?"
	icon_state = "chub"
	inhand_color = "#3dc414"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/eel
	name = "eel"
	desc = "When the jaws open wide and there's more jaws inside, that's a Moray!"
	icon_state = "eel"
	inhand_color = "#1e2030"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/dace
	name = "dace"
	desc = "A surface-dwelling fish related to the carp. Became established after escaping from being used as a bait fish."
	icon_state = "dace"
	inhand_color = "#d1c40d"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/minnow
	name = "minnow"
	desc = "One of the most common bait fish, looks like this one got away! Until you caught it."
	icon_state = "minnow"
	inhand_color = "#b1c3dd"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/pike
	name = "pike"
	desc = "Named after the long and pointy weapon of war, the pike features in the Finnish Kalevala, where it's jawbone is turned in to a magical kantele."
	icon = 'icons/obj/foodNdrink/food_fish_48x32.dmi'
	icon_state = "pike"
	inhand_color = "#24d10d"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_RARE

/obj/item/reagent_containers/food/fish/arapaima
	name = "arapaima"
	desc = "One of the largest freshwater fish as well as one of the oldest, with fossils for this species dating back 23 million years."
	icon = 'icons/obj/foodNdrink/food_fish_48x32.dmi'
	icon_state = "arapaima"
	inhand_color = "#9c5525"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_RARE

/obj/item/reagent_containers/food/fish/rosefin_shiner
	name = "rosefin shiner"
	desc = "A native to Virginia and Carolina, this fish likes clear freshwater pools and creeks. Take me home, rosefin shiner!"
	icon_state = "rosefin_shiner"
	inhand_color = "#2963b4"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/catfish
	name = "catfish"
	desc = "Found the whole world over, the humble catfish typically presents with their trademark whiskers, called barbels."
	icon_state = "catfish"
	inhand_color = "#503f29"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/tiger_oscar
	name = "tiger oscar"
	desc = "Popular in both aquariums and kitchens, this fish was accidentally misclassified in 1831. Don't make that mistake again!"
	icon_state = "tiger_oscar"
	inhand_color = "#2e1306"
	category = FISH_CATEGORY_FRESHWATER
	rarity = ITEM_RARITY_UNCOMMON

// Ocean saltwater fish

/obj/item/reagent_containers/food/fish/herring
	name = "herring"
	desc = "The silver darling. A small ocean fish that swims in schools."
	icon_state = "herring"
	inhand_color = "#90B6CA"
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_COMMON


/obj/item/reagent_containers/food/fish/red_herring
	name = "peculiarly coloured clupea pallasi"
	desc = "What is this? Why is this here? WHAT IS THE PURPOSE OF THIS?"
	icon_state = "red_herring"
	inhand_color = "#DC5A5A"
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_LEGENDARY

/obj/item/reagent_containers/food/fish/tuna
	name = "bluefin tuna"
	desc = "Formerly known as the tunny. Delicious but sadly overfished."
	icon_state = "tuna"
	inhand_color = "#3123f8"
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/cod
	name = "atlantic cod"
	desc = "The keystone of fish & chips. Enjoyed since 800 AD."
	icon_state = "cod"
	inhand_color = "#87d1db"
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/pufferfish
	name = "pufferfish"
	desc = "Adorable. Quite poisonous."
	icon_state = "pufferfish"
	inhand_color = "#8d754e"
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet/pufferfish
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_UNCOMMON

	New()
		global.processing_items += src
		return ..()

	disposing()
		global.processing_items -= src
		. = ..()

	process() // the part where the puffed up fish hurts you
		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if (src.spikes_protected(H, src))
				return
			boutput(H, SPAN_ALERT("YOWCH! You prick yourself on [src]'s spikes! Maybe you should've used gloves..."))
			random_brute_damage(H, 3)
			H.setStatusMin("stunned", 2 SECONDS)
			take_bleeding_damage(H, null, 3, DAMAGE_STAB)

	make_reagents()
		..() //it still contains fish oil
		src.reagents.add_reagent("tetrodotoxin",20) // REALLY don't eat raw pufferfish

	onSlice(var/mob/user) // Don't eat pufferfish the staff assistant made
		if (user.traitHolder?.hasTrait("training_chef"))
			user.visible_message(SPAN_NOTICE("<b>[user]</b> carefully separates the toxic parts out of the [src]."))

			var/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/pufferfish_liver/liver =\
			new /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/pufferfish_liver(src.loc)
			if (src.reagents?.total_volume > 0)
				src.reagents.trans_to(liver, src.reagents.total_volume)
		else
			if (prob(25)) // Don't try doing it if you don't know what you're doing
				boutput(user, SPAN_NOTICE("You prick yourself trying to cut [src], and feel a bit numb."))
				src.reagents.trans_to(user, 5)
			else if (prob(30)) // 30% of 75%(slightly more than 22%) chance of still being safe to eat
				src.reagents.remove_reagent("tetrodotoxin",src.reagents.get_reagent_amount("tetrodotoxin"))


	proc/spikes_protected(mob/living/carbon/human/H, obj/fish)
		if(H.gloves)
			return TRUE
		if(H.traitHolder?.hasTrait("training_chef"))
			return TRUE

		if (H.l_hand == fish)
			if (istype(H.limbs.l_arm,/obj/item/parts/robot_parts))
				return TRUE
		else if (H.r_hand == fish)
			if (istype(H.limbs.r_arm,/obj/item/parts/robot_parts))
				return TRUE
		else
			return TRUE //no pokey if not holdy :salute:


/obj/item/reagent_containers/food/fish/flounder
	name = "flounder"
	desc = "A flatfish found at the bottom of oceans around the world. It's got it's eyes on you!"
	icon_state = "flounder"
	inhand_color = "#5c471b"
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/coelacanth
	name = "coelacanth"
	desc = "Lazarus had nothing on you. We thought you went to the celestial zoo. The lungfish calls you brother and I guess that we should too."
	icon_state = "coelacanth"
	inhand_color = "#81878a"
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_RARE

/obj/item/reagent_containers/food/fish/mahimahi
	name = "Mahi-mahi"
	desc = "Also known as a dolphinfish, this tropical fish is prized for its quality and size. When first taken out of the water, they change colors."
	icon_state = "mahimahi"
	inhand_color = "#A6B967"
	food_color = "#FFECB7"
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet/white
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/shrimp
	name = "shrimp"
	desc = "Shrimple as that."
	icon_state = "shrimp"
	inhand_color = "#db82db"
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/shrimp
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/sardine
	name = "sardine"
	desc = "At home in a can. Good grilled, pickled or smoked. The sardine isn't a fan of this however."
	icon_state = "sardine"
	inhand_color = "#618fe4"
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/barracuda
	name = "barracuda"
	desc = "You gonna burn, burn, burn, burn, burn to the wick. Ooh, barracuda, oh, yeah."
	icon = 'icons/obj/foodNdrink/food_fish_48x32.dmi'
	icon_state = "barracuda"
	inhand_color = "#25669c"
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_RARE

/obj/item/reagent_containers/food/fish/sailfish
	name = "sailfish"
	desc = "A fearsome looking predator with a ferocious temper. Looks like you were up for the challenge!"
	icon = 'icons/obj/foodNdrink/food_fish_48x32.dmi'
	icon_state = "sailfish"
	inhand_color = "#25419c"
	category = FISH_CATEGORY_OCEAN
	rarity = ITEM_RARITY_EPIC

// Aquarium fish

/obj/item/reagent_containers/food/fish/clownfish
	name = "clownfish"
	desc = "A pop-culturally significant orange fish that lives in a symbiotic relationship with an anemone."
	icon_state = "clownfish"
	inhand_color = "#ff6601"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/damselfish
	name = "damselfish"
	desc = "A small pretty fish native to tropical coral reefs and your local aquarium."
	icon_state = "damselfish"
	inhand_color = "#ff6601"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/green_chromis
	name = "green chromis"
	desc = "Beautiful iridescent apple-green. Wait a second, isn't this a damselfish?"
	icon_state = "green_chromis"
	inhand_color = "#3af121"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/cardinalfish
	name = "cardinalfish"
	desc = "A nocturnal ray-finned fish enjoyed for being small, peaceful and colourful."
	icon_state = "cardinalfish"
	inhand_color = "#b2b427"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/royal_gramma
	name = "royal gramma"
	desc = "A pretty pink and yellow common to aquariums. Peaceful and friendly."
	icon_state = "royal_gramma"
	inhand_color = "#9a05f0"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/bc_angelfish
	name = "bicolor angelfish"
	desc = "It's like two fish in one! Apparently they don't get along with other fish though, at least they have each other."
	icon_state = "bc_angel"
	inhand_color = "#3005f0"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/blue_tang
	name = "blue tang"
	desc = "One of the most common and popular marine aquarium fish in the world, for reasons now lost to time."
	icon_state = "blue_tang"
	inhand_color = "#3005f0"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/firefish
	name = "firefish"
	desc = "Someone set this one on fire! Just kidding, we have fun here."
	icon_state = "firefish"
	inhand_color = "#f06305"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_UNCOMMON

/obj/item/reagent_containers/food/fish/yellow_tang
	name = "yellow tang"
	desc = "Born around the full moon, but bright as the sun. A popular, pretty aquarium fish."
	icon_state = "yellow_tang"
	inhand_color = "#d8f005"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_COMMON

/obj/item/reagent_containers/food/fish/mandarin_fish
	name = "mandarin fish"
	desc = "Slow moving reef-dwellers, these extremely colorful fish find it hard to adapt to aquarium life."
	icon_state = "mandarin_fish"
	inhand_color = "#3005f0"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_RARE

/obj/item/reagent_containers/food/fish/lionfish
	name = "lionfish"
	desc = "With strong red and white stripes and armed with a full complement of venomous spines, you better be careful handling this one."
	icon_state = "lionfish"
	inhand_color = "#f03c05"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_RARE

/obj/item/reagent_containers/food/fish/betta
	name = "betta"
	desc = "This could be one of 73 species domesticated over 1000 years ago. Sadly used in fish-fights by less savory sorts."
	icon_state = "betta"
	inhand_color = "#f03c05"
	category = FISH_CATEGORY_AQUARIUM
	rarity = ITEM_RARITY_COMMON

// adventure zone special fish

//meatzone
/obj/item/reagent_containers/food/fish/meat_mutant
	name = "meat mutant"
	desc = "A fish? Whatver it is, it's grown accustomed to swimming in a pool of digestive acids."
	icon_state = "meat"
	inhand_color = "#af2323"
	rarity = ITEM_RARITY_RARE
	slice_product = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat
/*
/obj/item/reagent_containers/food/fish/blood_fish
	name = "blood fish"
	desc = "A viscous, gory mass of congealed blood. You're really stretching the definition of fish here."
	icon_state = "bass_old"
	inhand_color = "#af2323"
	rarity = ITEM_RARITY_RARE
*/
/obj/item/reagent_containers/food/fish/eye_mutant
	name = "eye mutant"
	desc = "Was this a fish once? It's got too many eyes on you."
	icon_state = "eyefish"
	inhand_color = "#f0f0f0"
	rarity = ITEM_RARITY_RARE
	slice_product = /obj/item/item_box/googly_eyes

/obj/item/reagent_containers/food/fish/lingfish
	name = "splashing horror"
	desc = "A writhing, flailing mass of tissue pantomiming a sick caricature of a fish. You should probably just put this one back."
	icon = 'icons/obj/foodNdrink/food_fish_48x32.dmi'
	icon_state = "lingfish"
	inhand_color = "#e08d6b"
	rarity = ITEM_RARITY_EPIC
	slice_product = /mob/living/critter/blobman/meat

//void
/obj/item/reagent_containers/food/fish/void_fish
	name = "void fish"
	desc = "This fish has swum through the timestream to witness the death of the universe. Probably doesn't fry too well."
	icon_state = "void_fish"
	inhand_color = "#8f3ed1"
	rarity = ITEM_RARITY_RARE

//code
/obj/item/reagent_containers/food/fish/code_worm
	name = "code worm"
	desc = "This unstable creature has been swimming around in this code for a long time, giving developers and its victims a massive headache."
	icon_state = "code_worm"
	inhand_color = "#32CD32"
	rarity = ITEM_RARITY_EPIC

	New()
		..()
		name = "\improper [pick("free", "gamer", "Xtreme", "funny", "ultimate", "REAL")]_[pick("cat", "puppy", "gaming", "fail", "cheat", "hax")] [pick("video", "content", "game", "images", "text", "audiobook", "podcast")].worm"
		global.processing_items += src

	disposing()
		global.processing_items -= src
		. = ..()

	make_reagents()
		..() //it still contains fish oil
		src.reagents.add_reagent("liquid_code",10)

	process()
		if (prob(30))
			src.hologram_effect(TRUE)
			SPAWN(2 SECONDS)
				src.remove_hologram_effect()
		else if (prob(40))
			animate_lag(src, magnitude = 10, loopnum = 1, steps = rand(2, 4))

//solarium
/obj/item/reagent_containers/food/fish/sun_fish
	name = "literal sun fish"
	desc = "Nobody will ever believe you."
	icon_state = "sun_fish"
	inhand_color = "#ebde2d"
	rarity = ITEM_RARITY_LEGENDARY
	New()
		. = ..()
		AddComponent(/datum/component/loctargeting/simple_light, 255, 110, 135, 180, TRUE)

//lava moon
/obj/item/reagent_containers/food/fish/lava_fish
	name = "lava fish"
	desc = "A blazing hot catch straight from the planet's core!"
	icon_state = "lavafish"
	inhand_color = "#eb2d2d"
	rarity = ITEM_RARITY_EPIC
	firesource = FIRESOURCE_OPEN_FLAME

	New()
		global.processing_items += src
		return ..()

	disposing()
		global.processing_items -= src
		. = ..()

	process()
		if (ismob(src.loc) && prob(60))
			src.loc.changeStatus("burning", pick(3, 5) SECONDS)

	attack(mob/target, mob/user, def_zone, is_special, params)
		. = ..()
		if (prob(50))
			playsound(target, 'sound/impact_sounds/burn_sizzle.ogg', 50, TRUE)
			target.changeStatus("burning", 2 SECONDS)

/obj/item/reagent_containers/food/fish/igneous_fish
	name = "igneous fish"
	desc = "A fish formed of cooled volcanic magma, neat! Still hot to handle though!"
	icon_state = "moltenfish"
	inhand_color = "#380c0c"
	rarity = ITEM_RARITY_RARE


//blob
/obj/item/reagent_containers/food/fish/blobfish
	name = "blobfish"
	desc = "Looking good, blobfish."
	icon_state = "blobfish"
	inhand_color = "#da8fac"
	rarity = ITEM_RARITY_RARE
	slice_product = /obj/item/material_piece/wad/blob/random

//other

TYPEINFO(/obj/item/reagent_containers/food/fish/real_goldfish)
	mat_appearances_to_ignore = list("gold")

/obj/item/reagent_containers/food/fish/real_goldfish
	name = "prosperity pilchard"
	desc = "A symbol of good fortune, this fish's shining scales are said to be extremely valuable!."
	icon_state = "goldenfish"
	inhand_color = "#f0ec08"
	rarity = ITEM_RARITY_LEGENDARY
	slice_product = /obj/item/raw_material/gold
	default_material = "gold"

TYPEINFO(/obj/item/reagent_containers/food/fish/treefish)
	mat_appearances_to_ignore = list("wood")

/obj/item/reagent_containers/food/fish/treefish
	name = "arboreal bass"
	desc = "This leafy fish's rough scales resemble coarse tree bark."
	icon = 'icons/obj/foodNdrink/food_fish_48x32.dmi'
	icon_state = "treefish"
	inhand_color = "#22c912"
	rarity = ITEM_RARITY_RARE
	slice_product = /obj/item/material_piece/organic/wood
	default_material = "wood"

	slapsound()
		playsound(src.loc, 'sound/impact_sounds/Bush_Hit.ogg', 50, 1, -1)

/obj/item/reagent_containers/food/fish/random // used by the Wholetuna Cordata plant
	New()
		..()
		SPAWN(0)
			var/fish = pick(/obj/item/reagent_containers/food/fish/salmon,/obj/item/reagent_containers/food/fish/carp,/obj/item/reagent_containers/food/fish/bass)
			new fish(get_turf(src))
			qdel(src)

/obj/item/reagent_containers/food/fish/borgfish
	name = "cyborg fish"
	desc = "This must be an experiment from a bored roboticist."
	icon_state = "borgfish"
	inhand_color = "#b6b5b5"
	slice_product = /obj/item/material_piece/steel
	default_material = "steel"
	rarity = ITEM_RARITY_RARE
