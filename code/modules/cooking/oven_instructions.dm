/// recipe instructions are the machine-specific portions of a recipe. They might include cooking times, or special interactions such as
/// forcing breakage
ABSTRACT_TYPE(/datum/recipe_instructions)
/datum/recipe_instructions

	proc/get_id()
		return null

ABSTRACT_TYPE(/datum/recipe_instructions/oven_instructions)
/datum/recipe_instructions/oven_instructions
	var/cookbonus = 10 // how much cooking it needs to get a healing bonus

	get_id()
		return "oven"

/// The instructions used by the oven if no other appropriate instructions exist in the recipe
/datum/recipe_instructions/oven_instructions/default
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/spicychickensandwich

/datum/recipe_instructions/oven_instructions/chickensandwich

/datum/recipe_instructions/oven_instructions/burger/cheeseburger
	cookbonus = 13

/datum/recipe_instructions/oven_instructions/burger/cheeseburger/monkey
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/burger/wcheeseburger
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/burger/luauburger
	cookbonus = 15

/datum/recipe_instructions/oven_instructions/burger/coconutburger
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/burger/tikiburger
	cookbonus = 18

/datum/recipe_instructions/oven_instructions/burger/buttburger
	cookbonus = 15

/datum/recipe_instructions/oven_instructions/burger/heartburger
	cookbonus = 13

/datum/recipe_instructions/oven_instructions/burger/brainburger
	cookbonus = 13

/datum/recipe_instructions/oven_instructions/burger/roburger
	cookbonus = 13

/datum/recipe_instructions/oven_instructions/burger/cheeseborger
	cookbonus = 13

/datum/recipe_instructions/oven_instructions/burger/baconburger
	cookbonus = 13

/datum/recipe_instructions/oven_instructions/burger/baconator
	cookbonus = 13

/datum/recipe_instructions/oven_instructions/burger/butterburger
	cookbonus = 15

/datum/recipe_instructions/oven_instructions/burger/aburgination
	cookbonus = 6 // still mostly raw, since we don't kill it

/datum/recipe_instructions/oven_instructions/burger/monster
	cookbonus = 20

/datum/recipe_instructions/oven_instructions/swede_mball
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/donkpocket
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/donkpocket2
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/donut
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/bagel
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/crumpet //another good idea for this is to cook a trumpet
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/ice_cream_cone
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/nougat
	cookbonus = 5

/datum/recipe_instructions/oven_instructions/candy_cane
	cookbonus = 5

/datum/recipe_instructions/oven_instructions/waffles
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/spaghetti_p
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/spaghetti_t
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/spaghetti_s
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/spaghetti_m
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/lasagna
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/alfredo
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/chickenparm
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/chickenalfredo
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/spaghetti_pg
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/cornbread
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/bread
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/brain_bread
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/toast_bread
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/toast
	cookbonus = 5

ABSTRACT_TYPE(/datum/recipe_instructions/oven_instructions/sandwich)
/datum/recipe_instructions/oven_instructions/sandwich
	cookbonus = 7

/datum/recipe_instructions/oven_instructions/sandwich
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/sandwich/meatball
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/sandwich/egg
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/sandwich/bahnmi
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/sandwich/custom
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pizza_custom
	cookbonus = 18

/datum/recipe_instructions/oven_instructions/cheesetoast
	cookbonus = 5

/datum/recipe_instructions/oven_instructions/bacontoast
	cookbonus = 5

/datum/recipe_instructions/oven_instructions/eggtoast
	cookbonus = 5

/datum/recipe_instructions/oven_instructions/breakfast
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/taco_shell
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/eggnog
	cookbonus = 3

/datum/recipe_instructions/oven_instructions/baguette
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/garlicbread
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/garlicbread_ch
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/painauchocolat
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/croissant
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/danish_apple
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/danish_cherry
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/danish_blueb
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/danish_weed
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/danish_cheese
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/fairybread
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/cinnamonbun
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/chocolate_cherry
	cookbonus = 3

/datum/recipe_instructions/oven_instructions/stroopwafel
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cookie
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cookie_iron
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cookie_chocolate_chip
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cookie_oatmeal
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cookie_bacon
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cookie_jaffa
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cookie_spooky
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cookie_butter
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cookie_peanut
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/moon_pie
	cookbonus = 5

/datum/recipe_instructions/oven_instructions/moon_pie_chocolate
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/onionchips
	cookbonus = 15

/datum/recipe_instructions/oven_instructions/fries
	cookbonus = 7

/datum/recipe_instructions/oven_instructions/chilifries
	cookbonus = 3

/datum/recipe_instructions/oven_instructions/chilifries_alt //Secondary recipe for chili cheese fries
	cookbonus = 7

/datum/recipe_instructions/oven_instructions/poutine
	cookbonus = 3

/datum/recipe_instructions/oven_instructions/poutine_alt
	cookbonus = 7

/datum/recipe_instructions/oven_instructions/bakedpotato
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/hotdog
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/cook_meat //Very jank, will need future work.
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/steak_ling
	cookbonus = 12 // tough meat

/datum/recipe_instructions/oven_instructions/shrimp
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/bacon
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/turkey
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/pie_strawberry
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_cherry
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_blueberry
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_raspberry
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_apple
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_lime
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_lemon
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_slurry
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_pumpkin
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_chocolate
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/pie_anything/pie_cream
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/pie_anything
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/pie_custard
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/pie_bacon
	cookbonus = 15

/datum/recipe_instructions/oven_instructions/pie_ass
	cookbonus = 15

/datum/recipe_instructions/oven_instructions/pot_pie
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_weed
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pie_fish
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/porridge
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/oatmeal
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/tomsoup
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/mint_chutney
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/refried_beans
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/chili
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/queso
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/superchili
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/ultrachili
	cookbonus = 20

/datum/recipe_instructions/oven_instructions/salad
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/creamofmushroom
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/candy_apple
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/cake_cream
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/cake_chocolate
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/cake_meat
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/cake_bacon
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/cake_true_bacon
	cookbonus = 14

#ifdef XMAS

/datum/recipe_instructions/oven_instructions/cake_fruit
	cookbonus = 14

#endif

/datum/recipe_instructions/oven_instructions/cake_custom
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/cake_custom_item
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/omelette
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/pancake
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/burger/sloppyjoe
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/meatloaf
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/cereal_box
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cereal_honey
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cereal_tanhony
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cereal_roach
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cereal_syndie
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/cereal_flock
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/granola_bar
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/hardboiled
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/chocolate_egg
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/eggsalad
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/biscuit
	cookbonus = 4

/datum/recipe_instructions/oven_instructions/dog_biscuit
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/hardtack
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/macguffin
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/haggis
	cookbonus = 18

/datum/recipe_instructions/oven_instructions/haggass
	cookbonus = 18

/datum/recipe_instructions/oven_instructions/scotch_egg
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/rice_ball
	cookbonus = 5

/datum/recipe_instructions/oven_instructions/nigiri_roll
	cookbonus = 2

/datum/recipe_instructions/oven_instructions/sushi_roll
	cookbonus = 2

/datum/recipe_instructions/oven_instructions/riceandbeans
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/friedrice
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/omurice
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/risotto
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/tandoorichicken
	cookbonus = 18

/datum/recipe_instructions/oven_instructions/potatocurry
	cookbonus = 7

/datum/recipe_instructions/oven_instructions/coconutcurry
	cookbonus = 7

/datum/recipe_instructions/oven_instructions/chickenpineapplecurry
	cookbonus = 7

/datum/recipe_instructions/oven_instructions/ramen_bowl
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/udon_bowl
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/curry_udon_bowl
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/mapo_tofu
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/cheesewheel
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/ratatouille
	cookbonus = 6

/datum/recipe_instructions/oven_instructions/churro
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/french_toast
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/zongzi
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/beefood
	cookbonus = 22

/datum/recipe_instructions/oven_instructions/b_cupcake
	cookbonus = 22

/datum/recipe_instructions/oven_instructions/lipstick
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/melted_sugar
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/brownie_batch
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/flapjack_batch
	cookbonus = 14

/datum/recipe_instructions/oven_instructions/rice_bowl
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/egg_on_rice
	cookbonus = 10

/datum/recipe_instructions/oven_instructions/katsudon_bacon
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/katsudon_chicken
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/gyudon
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/cheese_gyudon
	cookbonus = 12

/datum/recipe_instructions/oven_instructions/miso_soup
	cookbonus = 8

/datum/recipe_instructions/oven_instructions/bibimbap
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/katsu_curry
	cookbonus = 16

/datum/recipe_instructions/oven_instructions/flan
	cookbonus = 6
