ABSTRACT_TYPE(/datum/recipe_instructions/cooking/oven)
/datum/recipe_instructions/cooking/oven
	var/cookbonus = 10 // how much cooking it needs to get a healing bonus

	get_id()
		return RECIPE_ID_OVEN

/// The instructions used by the oven if no other appropriate instructions exist in the recipe
/datum/recipe_instructions/cooking/oven/default
	cookbonus = 10


/datum/recipe_instructions/cooking/oven/burger/burger_meat
	cookbonus = 10
	useshumanmeat = TRUE //this is a bit hacky, but it shouldn't affect anything when cooking any of the non-human recipes

/datum/recipe_instructions/cooking/oven/burger/cheeseburger
	cookbonus = 13

/datum/recipe_instructions/cooking/oven/burger/cheeseburger/monkey
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/burger/wcheeseburger
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/burger/luauburger
	cookbonus = 15

/datum/recipe_instructions/cooking/oven/burger/coconutburger
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/burger/tikiburger
	cookbonus = 18

/datum/recipe_instructions/cooking/oven/burger/buttburger
	cookbonus = 15

/datum/recipe_instructions/cooking/oven/burger/heartburger
	cookbonus = 13

/datum/recipe_instructions/cooking/oven/burger/brainburger
	cookbonus = 13

/datum/recipe_instructions/cooking/oven/burger/roburger
	cookbonus = 13

/datum/recipe_instructions/cooking/oven/burger/cheeseborger
	cookbonus = 13

/datum/recipe_instructions/cooking/oven/burger/baconburger
	cookbonus = 13

/datum/recipe_instructions/cooking/oven/burger/baconator
	cookbonus = 13

/datum/recipe_instructions/cooking/oven/burger/butterburger
	cookbonus = 15

/datum/recipe_instructions/cooking/oven/burger/aburgination
	cookbonus = 6 // still mostly raw, since we don't kill it

/datum/recipe_instructions/cooking/oven/burger/monster
	cookbonus = 20

/datum/recipe_instructions/cooking/oven/swede_mball
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/donkpocket
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/donkpocket2
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/donut
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/bagel
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/crumpet //another good idea for this is to cook a trumpet
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/ice_cream_cone
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/nougat
	cookbonus = 5

/datum/recipe_instructions/cooking/oven/candy_cane
	cookbonus = 5

/datum/recipe_instructions/cooking/oven/waffles
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/spaghetti_p
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/spaghetti_t
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/spaghetti_s
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/spaghetti_m
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/lasagna
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/alfredo
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/chickenparm
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/chickenalfredo
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/spaghetti_pg
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/cornbread
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/bread
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/brain_bread
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/toast_bread
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/toast
	cookbonus = 5

/datum/recipe_instructions/cooking/oven/sandwich
	cookbonus = 7

/datum/recipe_instructions/cooking/oven/sandwich/human
	useshumanmeat = TRUE
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/sandwich/meatball
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/sandwich/egg
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/sandwich/bahnmi
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/sandwich/custom
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pizza_custom
	cookbonus = 18

/datum/recipe_instructions/cooking/oven/cheesetoast
	cookbonus = 5

/datum/recipe_instructions/cooking/oven/bacontoast
	cookbonus = 5

/datum/recipe_instructions/cooking/oven/eggtoast
	cookbonus = 5

/datum/recipe_instructions/cooking/oven/breakfast
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/taco_shell
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/eggnog
	cookbonus = 3

/datum/recipe_instructions/cooking/oven/baguette
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/garlicbread
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/garlicbread_ch
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/painauchocolat
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/croissant
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/danish_apple
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/danish_cherry
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/danish_blueb
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/danish_weed
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/danish_cheese
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/fairybread
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/cinnamonbun
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/chocolate_cherry
	cookbonus = 3

/datum/recipe_instructions/cooking/oven/stroopwafel
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cookie
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cookie_iron
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cookie_chocolate_chip
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cookie_oatmeal
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cookie_bacon
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cookie_jaffa
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cookie_spooky
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cookie_butter
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cookie_peanut
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/moon_pie
	cookbonus = 5

/datum/recipe_instructions/cooking/oven/moon_pie_chocolate
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/onionchips
	cookbonus = 15

/datum/recipe_instructions/cooking/oven/fries
	cookbonus = 7

/datum/recipe_instructions/cooking/oven/chilifries
	cookbonus = 3

/datum/recipe_instructions/cooking/oven/chilifries_alt //Secondary recipe for chili cheese fries
	cookbonus = 7

/datum/recipe_instructions/cooking/oven/poutine
	cookbonus = 3

/datum/recipe_instructions/cooking/oven/poutine_alt
	cookbonus = 7

/datum/recipe_instructions/cooking/oven/bakedpotato
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/hotdog
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/cook_meat
	useshumanmeat = TRUE
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/steak_ling
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/shrimp
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/bacon
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/turkey
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/pie_strawberry
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_cherry
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_blueberry
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_raspberry
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_apple
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_lime
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_lemon
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_slurry
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_pumpkin
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_chocolate
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/pie_anything/pie_cream
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/pie_anything
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/pie_custard
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/pie_bacon
	cookbonus = 15

/datum/recipe_instructions/cooking/oven/pie_ass
	cookbonus = 15

/datum/recipe_instructions/cooking/oven/pot_pie
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_weed
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pie_fish
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/porridge
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/oatmeal
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/tomsoup
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/mint_chutney
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/refried_beans
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/chili
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/queso
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/superchili
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/ultrachili
	cookbonus = 20

/datum/recipe_instructions/cooking/oven/salad
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/creamofmushroom
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/candy_apple
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/cake_cream
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/cake_chocolate
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/cake_meat
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/cake_bacon
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/cake_true_bacon
	cookbonus = 14

#ifdef XMAS

/datum/recipe_instructions/cooking/oven/cake_fruit
	cookbonus = 14

#endif

/datum/recipe_instructions/cooking/oven/cake_custom
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/cake_custom_item
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/omelette
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/pancake
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/burger/sloppyjoe
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/meatloaf
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/cereal_box
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cereal_honey
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cereal_tanhony
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cereal_roach
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cereal_syndie
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/cereal_flock
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/granola_bar
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/hardboiled
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/chocolate_egg
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/eggsalad
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/biscuit
	cookbonus = 4

/datum/recipe_instructions/cooking/oven/dog_biscuit
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/hardtack
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/macguffin
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/haggis
	cookbonus = 18

/datum/recipe_instructions/cooking/oven/haggass
	cookbonus = 18

/datum/recipe_instructions/cooking/oven/scotch_egg
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/rice_ball
	cookbonus = 5

/datum/recipe_instructions/cooking/oven/nigiri_roll
	cookbonus = 2

/datum/recipe_instructions/cooking/oven/sushi_roll
	cookbonus = 2

/datum/recipe_instructions/cooking/oven/riceandbeans
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/friedrice
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/omurice
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/risotto
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/tandoorichicken
	cookbonus = 18

/datum/recipe_instructions/cooking/oven/potatocurry
	cookbonus = 7

/datum/recipe_instructions/cooking/oven/coconutcurry
	cookbonus = 7

/datum/recipe_instructions/cooking/oven/chickenpineapplecurry
	cookbonus = 7

/datum/recipe_instructions/cooking/oven/ramen_bowl
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/udon_bowl
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/curry_udon_bowl
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/mapo_tofu
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/cheesewheel
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/ratatouille
	cookbonus = 6

/datum/recipe_instructions/cooking/oven/churro
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/french_toast
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/zongzi
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/beefood
	cookbonus = 22

/datum/recipe_instructions/cooking/oven/b_cupcake
	cookbonus = 22

/datum/recipe_instructions/cooking/oven/lipstick
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/melted_sugar
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/brownie_batch
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/flapjack_batch
	cookbonus = 14

/datum/recipe_instructions/cooking/oven/rice_bowl
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/egg_on_rice
	cookbonus = 10

/datum/recipe_instructions/cooking/oven/katsudon_bacon
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/katsudon_chicken
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/gyudon
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/cheese_gyudon
	cookbonus = 12

/datum/recipe_instructions/cooking/oven/miso_soup
	cookbonus = 8

/datum/recipe_instructions/cooking/oven/bibimbap
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/katsu_curry
	cookbonus = 16

/datum/recipe_instructions/cooking/oven/flan
	cookbonus = 6
