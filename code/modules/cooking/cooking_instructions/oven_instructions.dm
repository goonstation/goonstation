ABSTRACT_TYPE(/datum/recipe_instructions/oven)
/datum/recipe_instructions/oven
	var/cookbonus = 10 // how much cooking it needs to get a healing bonus

	get_id()
		return RECIPE_ID_OVEN

/// The instructions used by the oven if no other appropriate instructions exist in the recipe
/datum/recipe_instructions/oven/default
	cookbonus = 10

/datum/recipe_instructions/oven/spicychickensandwich

/datum/recipe_instructions/oven/chickensandwich

/datum/recipe_instructions/oven/burger/cheeseburger
	cookbonus = 13

/datum/recipe_instructions/oven/burger/cheeseburger/monkey
	cookbonus = 10

/datum/recipe_instructions/oven/burger/wcheeseburger
	cookbonus = 14

/datum/recipe_instructions/oven/burger/luauburger
	cookbonus = 15

/datum/recipe_instructions/oven/burger/coconutburger
	cookbonus = 10

/datum/recipe_instructions/oven/burger/tikiburger
	cookbonus = 18

/datum/recipe_instructions/oven/burger/buttburger
	cookbonus = 15

/datum/recipe_instructions/oven/burger/heartburger
	cookbonus = 13

/datum/recipe_instructions/oven/burger/brainburger
	cookbonus = 13

/datum/recipe_instructions/oven/burger/roburger
	cookbonus = 13

/datum/recipe_instructions/oven/burger/cheeseborger
	cookbonus = 13

/datum/recipe_instructions/oven/burger/baconburger
	cookbonus = 13

/datum/recipe_instructions/oven/burger/baconator
	cookbonus = 13

/datum/recipe_instructions/oven/burger/butterburger
	cookbonus = 15

/datum/recipe_instructions/oven/burger/aburgination
	cookbonus = 6 // still mostly raw, since we don't kill it

/datum/recipe_instructions/oven/burger/monster
	cookbonus = 20

/datum/recipe_instructions/oven/swede_mball
	cookbonus = 10

/datum/recipe_instructions/oven/donkpocket
	cookbonus = 10

/datum/recipe_instructions/oven/donkpocket2
	cookbonus = 10

/datum/recipe_instructions/oven/donut
	cookbonus = 6

/datum/recipe_instructions/oven/bagel
	cookbonus = 6

/datum/recipe_instructions/oven/crumpet //another good idea for this is to cook a trumpet
	cookbonus = 6

/datum/recipe_instructions/oven/ice_cream_cone
	cookbonus = 6

/datum/recipe_instructions/oven/nougat
	cookbonus = 5

/datum/recipe_instructions/oven/candy_cane
	cookbonus = 5

/datum/recipe_instructions/oven/waffles
	cookbonus = 10

/datum/recipe_instructions/oven/spaghetti_p
	cookbonus = 16

/datum/recipe_instructions/oven/spaghetti_t
	cookbonus = 16

/datum/recipe_instructions/oven/spaghetti_s
	cookbonus = 16

/datum/recipe_instructions/oven/spaghetti_m
	cookbonus = 16

/datum/recipe_instructions/oven/lasagna
	cookbonus = 16

/datum/recipe_instructions/oven/alfredo
	cookbonus = 16

/datum/recipe_instructions/oven/chickenparm
	cookbonus = 16

/datum/recipe_instructions/oven/chickenalfredo
	cookbonus = 16

/datum/recipe_instructions/oven/spaghetti_pg
	cookbonus = 16

/datum/recipe_instructions/oven/cornbread
	cookbonus = 6

/datum/recipe_instructions/oven/bread
	cookbonus = 8

/datum/recipe_instructions/oven/brain_bread
	cookbonus = 4

/datum/recipe_instructions/oven/toast_bread
	cookbonus = 6

/datum/recipe_instructions/oven/toast
	cookbonus = 5

/datum/recipe_instructions/oven/sandwich
	cookbonus = 7

/datum/recipe_instructions/oven/sandwich
	cookbonus = 10

/datum/recipe_instructions/oven/sandwich/meatball
	cookbonus = 12

/datum/recipe_instructions/oven/sandwich/egg
	cookbonus = 10

/datum/recipe_instructions/oven/sandwich/bahnmi
	cookbonus = 12

/datum/recipe_instructions/oven/sandwich/custom
	cookbonus = 12

/datum/recipe_instructions/oven/pizza_custom
	cookbonus = 18

/datum/recipe_instructions/oven/cheesetoast
	cookbonus = 5

/datum/recipe_instructions/oven/bacontoast
	cookbonus = 5

/datum/recipe_instructions/oven/eggtoast
	cookbonus = 5

/datum/recipe_instructions/oven/breakfast
	cookbonus = 16

/datum/recipe_instructions/oven/taco_shell
	cookbonus = 6

/datum/recipe_instructions/oven/eggnog
	cookbonus = 3

/datum/recipe_instructions/oven/baguette
	cookbonus = 8

/datum/recipe_instructions/oven/garlicbread
	cookbonus = 6

/datum/recipe_instructions/oven/garlicbread_ch
	cookbonus = 6

/datum/recipe_instructions/oven/painauchocolat
	cookbonus = 12

/datum/recipe_instructions/oven/croissant
	cookbonus = 12

/datum/recipe_instructions/oven/danish_apple
	cookbonus = 12

/datum/recipe_instructions/oven/danish_cherry
	cookbonus = 12

/datum/recipe_instructions/oven/danish_blueb
	cookbonus = 12

/datum/recipe_instructions/oven/danish_weed
	cookbonus = 12

/datum/recipe_instructions/oven/danish_cheese
	cookbonus = 12

/datum/recipe_instructions/oven/fairybread
	cookbonus = 8

/datum/recipe_instructions/oven/cinnamonbun
	cookbonus = 12

/datum/recipe_instructions/oven/chocolate_cherry
	cookbonus = 3

/datum/recipe_instructions/oven/stroopwafel
	cookbonus = 4

/datum/recipe_instructions/oven/cookie
	cookbonus = 4

/datum/recipe_instructions/oven/cookie_iron
	cookbonus = 4

/datum/recipe_instructions/oven/cookie_chocolate_chip
	cookbonus = 4

/datum/recipe_instructions/oven/cookie_oatmeal
	cookbonus = 4

/datum/recipe_instructions/oven/cookie_bacon
	cookbonus = 4

/datum/recipe_instructions/oven/cookie_jaffa
	cookbonus = 4

/datum/recipe_instructions/oven/cookie_spooky
	cookbonus = 4

/datum/recipe_instructions/oven/cookie_butter
	cookbonus = 4

/datum/recipe_instructions/oven/cookie_peanut
	cookbonus = 4

/datum/recipe_instructions/oven/moon_pie
	cookbonus = 5

/datum/recipe_instructions/oven/moon_pie_chocolate
	cookbonus = 6

/datum/recipe_instructions/oven/onionchips
	cookbonus = 15

/datum/recipe_instructions/oven/fries
	cookbonus = 7

/datum/recipe_instructions/oven/chilifries
	cookbonus = 3

/datum/recipe_instructions/oven/chilifries_alt //Secondary recipe for chili cheese fries
	cookbonus = 7

/datum/recipe_instructions/oven/poutine
	cookbonus = 3

/datum/recipe_instructions/oven/poutine_alt
	cookbonus = 7

/datum/recipe_instructions/oven/bakedpotato
	cookbonus = 16

/datum/recipe_instructions/oven/hotdog
	cookbonus = 6

/datum/recipe_instructions/oven/cook_meat //Very jank, will need future work.
	cookbonus = 10

/datum/recipe_instructions/oven/steak_ling
	cookbonus = 12 // tough meat

/datum/recipe_instructions/oven/shrimp
	cookbonus = 4

/datum/recipe_instructions/oven/bacon
	cookbonus = 8

/datum/recipe_instructions/oven/turkey
	cookbonus = 10

/datum/recipe_instructions/oven/pie_strawberry
	cookbonus = 12

/datum/recipe_instructions/oven/pie_cherry
	cookbonus = 12

/datum/recipe_instructions/oven/pie_blueberry
	cookbonus = 12

/datum/recipe_instructions/oven/pie_raspberry
	cookbonus = 12

/datum/recipe_instructions/oven/pie_apple
	cookbonus = 12

/datum/recipe_instructions/oven/pie_lime
	cookbonus = 12

/datum/recipe_instructions/oven/pie_lemon
	cookbonus = 12

/datum/recipe_instructions/oven/pie_slurry
	cookbonus = 12

/datum/recipe_instructions/oven/pie_pumpkin
	cookbonus = 12

/datum/recipe_instructions/oven/pie_chocolate
	cookbonus = 10

/datum/recipe_instructions/oven/pie_anything/pie_cream
	cookbonus = 4

/datum/recipe_instructions/oven/pie_anything
	cookbonus = 4

/datum/recipe_instructions/oven/pie_custard
	cookbonus = 4

/datum/recipe_instructions/oven/pie_bacon
	cookbonus = 15

/datum/recipe_instructions/oven/pie_ass
	cookbonus = 15

/datum/recipe_instructions/oven/pot_pie
	cookbonus = 12

/datum/recipe_instructions/oven/pie_weed
	cookbonus = 12

/datum/recipe_instructions/oven/pie_fish
	cookbonus = 10

/datum/recipe_instructions/oven/porridge
	cookbonus = 10

/datum/recipe_instructions/oven/oatmeal
	cookbonus = 10

/datum/recipe_instructions/oven/tomsoup
	cookbonus = 8

/datum/recipe_instructions/oven/mint_chutney
	cookbonus = 14

/datum/recipe_instructions/oven/refried_beans
	cookbonus = 14

/datum/recipe_instructions/oven/chili
	cookbonus = 14

/datum/recipe_instructions/oven/queso
	cookbonus = 14

/datum/recipe_instructions/oven/superchili
	cookbonus = 16

/datum/recipe_instructions/oven/ultrachili
	cookbonus = 20

/datum/recipe_instructions/oven/salad
	cookbonus = 4

/datum/recipe_instructions/oven/creamofmushroom
	cookbonus = 8

/datum/recipe_instructions/oven/candy_apple
	cookbonus = 6

/datum/recipe_instructions/oven/cake_cream
	cookbonus = 14

/datum/recipe_instructions/oven/cake_chocolate
	cookbonus = 14

/datum/recipe_instructions/oven/cake_meat
	cookbonus = 14

/datum/recipe_instructions/oven/cake_bacon
	cookbonus = 14

/datum/recipe_instructions/oven/cake_true_bacon
	cookbonus = 14

#ifdef XMAS

/datum/recipe_instructions/oven/cake_fruit
	cookbonus = 14

#endif

/datum/recipe_instructions/oven/cake_custom
	cookbonus = 14

/datum/recipe_instructions/oven/cake_custom_item
	cookbonus = 14

/datum/recipe_instructions/oven/omelette
	cookbonus = 12

/datum/recipe_instructions/oven/pancake
	cookbonus = 10

/datum/recipe_instructions/oven/burger/sloppyjoe
	cookbonus = 12

/datum/recipe_instructions/oven/meatloaf
	cookbonus = 8

/datum/recipe_instructions/oven/cereal_box
	cookbonus = 4

/datum/recipe_instructions/oven/cereal_honey
	cookbonus = 4

/datum/recipe_instructions/oven/cereal_tanhony
	cookbonus = 4

/datum/recipe_instructions/oven/cereal_roach
	cookbonus = 4

/datum/recipe_instructions/oven/cereal_syndie
	cookbonus = 4

/datum/recipe_instructions/oven/cereal_flock
	cookbonus = 4

/datum/recipe_instructions/oven/granola_bar
	cookbonus = 6

/datum/recipe_instructions/oven/hardboiled
	cookbonus = 4

/datum/recipe_instructions/oven/chocolate_egg
	cookbonus = 4

/datum/recipe_instructions/oven/eggsalad
	cookbonus = 6

/datum/recipe_instructions/oven/biscuit
	cookbonus = 4

/datum/recipe_instructions/oven/dog_biscuit
	cookbonus = 6

/datum/recipe_instructions/oven/hardtack
	cookbonus = 8

/datum/recipe_instructions/oven/macguffin
	cookbonus = 8

/datum/recipe_instructions/oven/haggis
	cookbonus = 18

/datum/recipe_instructions/oven/haggass
	cookbonus = 18

/datum/recipe_instructions/oven/scotch_egg
	cookbonus = 6

/datum/recipe_instructions/oven/rice_ball
	cookbonus = 5

/datum/recipe_instructions/oven/nigiri_roll
	cookbonus = 2

/datum/recipe_instructions/oven/sushi_roll
	cookbonus = 2

/datum/recipe_instructions/oven/riceandbeans
	cookbonus = 10

/datum/recipe_instructions/oven/friedrice
	cookbonus = 10

/datum/recipe_instructions/oven/omurice
	cookbonus = 8

/datum/recipe_instructions/oven/risotto
	cookbonus = 10

/datum/recipe_instructions/oven/tandoorichicken
	cookbonus = 18

/datum/recipe_instructions/oven/potatocurry
	cookbonus = 7

/datum/recipe_instructions/oven/coconutcurry
	cookbonus = 7

/datum/recipe_instructions/oven/chickenpineapplecurry
	cookbonus = 7

/datum/recipe_instructions/oven/ramen_bowl
	cookbonus = 14

/datum/recipe_instructions/oven/udon_bowl
	cookbonus = 14

/datum/recipe_instructions/oven/curry_udon_bowl
	cookbonus = 14

/datum/recipe_instructions/oven/mapo_tofu
	cookbonus = 14

/datum/recipe_instructions/oven/cheesewheel
	cookbonus = 14

/datum/recipe_instructions/oven/ratatouille
	cookbonus = 6

/datum/recipe_instructions/oven/churro
	cookbonus = 14

/datum/recipe_instructions/oven/french_toast
	cookbonus = 10

/datum/recipe_instructions/oven/zongzi
	cookbonus = 8

/datum/recipe_instructions/oven/beefood
	cookbonus = 22

/datum/recipe_instructions/oven/b_cupcake
	cookbonus = 22

/datum/recipe_instructions/oven/lipstick
	cookbonus = 10

/datum/recipe_instructions/oven/melted_sugar
	cookbonus = 10

/datum/recipe_instructions/oven/brownie_batch
	cookbonus = 14

/datum/recipe_instructions/oven/flapjack_batch
	cookbonus = 14

/datum/recipe_instructions/oven/rice_bowl
	cookbonus = 10

/datum/recipe_instructions/oven/egg_on_rice
	cookbonus = 10

/datum/recipe_instructions/oven/katsudon_bacon
	cookbonus = 12

/datum/recipe_instructions/oven/katsudon_chicken
	cookbonus = 12

/datum/recipe_instructions/oven/gyudon
	cookbonus = 12

/datum/recipe_instructions/oven/cheese_gyudon
	cookbonus = 12

/datum/recipe_instructions/oven/miso_soup
	cookbonus = 8

/datum/recipe_instructions/oven/bibimbap
	cookbonus = 16

/datum/recipe_instructions/oven/katsu_curry
	cookbonus = 16

/datum/recipe_instructions/oven/flan
	cookbonus = 6
