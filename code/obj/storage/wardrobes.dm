
/obj/storage/closet/dresser
	name = "dresser"
	desc = "It's got room for all your fanciest or shabbiest outfits!"
	icon_state = "dresser"
	icon_closed = "dresser"
	icon_opened = "dresser-open"
	soundproofing = 10
	open_sound = 'sound/misc/coffin_open.ogg'
	close_sound = 'sound/misc/coffin_close.ogg'
	var/trick = 0 //enjoy some gimmicky bullfuckery
	var/id = null
	weld_image_offset_X = -6
	weld_image_offset_Y = 2
	mat_appearances_to_ignore = list("wood")

/obj/storage/closet/wardrobe
	name = "wardrobe"
	desc = "It's a wardrobe closet! This one can be opened AND closed. Comes prestocked with some changes of clothes."
	soundproofing = 10

/* ==================== */
/* ----- Standard ----- */
/* ==================== */

/obj/storage/closet/wardrobe/pride
	name = "pride wardrobe"
	desc = "A label on it reads: In order to improve workplace efficiency, employees are encouraged to spend no more than 5 minutes in the closet at a time."
	icon_state = "gay"
	icon_closed = "gay"
	spawn_contents = list(/obj/item/clothing/under/pride = 2,
	/obj/item/clothing/under/pride/ace = 2,
	/obj/item/clothing/under/pride/aro = 2,
	/obj/item/clothing/under/pride/bi = 2,
	/obj/item/clothing/under/pride/inter = 2,
	/obj/item/clothing/under/pride/pan = 2,
	/obj/item/clothing/under/pride/poly = 2,
	/obj/item/clothing/under/pride/nb = 2,
	/obj/item/clothing/under/pride/lesb = 2,
	/obj/item/clothing/under/pride/gaymasc = 2,
	/obj/item/clothing/under/pride/trans = 2)

/obj/storage/closet/wardrobe/black
	name = "black wardrobe"
	icon_state = "black"
	icon_closed = "black"
	spawn_contents = list(/obj/item/clothing/under/color = 4,
	/obj/item/clothing/shoes/black = 4,
	/obj/item/clothing/head/black = 2)

/obj/storage/closet/wardrobe/grey
	name = "grey wardrobe"
	icon_state = "grey"
	icon_closed = "grey"
	spawn_contents = list(/obj/item/clothing/under/color/grey = 4,
	/obj/item/clothing/shoes/black = 5)

/obj/storage/closet/wardrobe/white
	name = "white wardrobe"
	icon_state = "white"
	icon_closed = "white"
	spawn_contents = list(/obj/item/clothing/under/color/white = 4,
	/obj/item/clothing/shoes/brown = 4,
	/obj/item/clothing/head/white  = 2)

/obj/storage/closet/wardrobe/pink
	name = "pink wardrobe"
	icon_state = "pink"
	icon_closed = "pink"
	spawn_contents = list(/obj/item/clothing/under/color/pink = 4,
	/obj/item/clothing/shoes/brown = 4)

/obj/storage/closet/wardrobe/red
	name = "red wardrobe"
	icon_state = "red"
	icon_closed = "red"
	spawn_contents = list(/obj/item/clothing/under/color/red = 4,
	/obj/item/clothing/shoes/brown = 4,
	/obj/item/clothing/head/red = 2)

/obj/storage/closet/wardrobe/orange
	name = "orange wardrobe"
	icon_state = "orange"
	icon_closed = "orange"
	spawn_contents = list(/obj/item/clothing/under/color/orange = 4,
	/obj/item/clothing/under/misc = 3,
	/obj/item/clothing/shoes/orange = 4)

/obj/storage/closet/wardrobe/yellow
	name = "yellow wardrobe"
	icon_state = "yellow"
	icon_closed = "yellow"
	spawn_contents = list(/obj/item/clothing/under/color/yellow = 4,
	/obj/item/clothing/shoes/orange = 4,
	/obj/item/clothing/head/yellow = 2)

/obj/storage/closet/wardrobe/green
	name = "green wardrobe"
	icon_state = "green"
	icon_closed = "green"
	spawn_contents = list(/obj/item/clothing/under/color/green = 4,
	/obj/item/clothing/shoes/black = 4,
	/obj/item/clothing/head/green = 2)

/obj/storage/closet/wardrobe/blue
	name = "blue wardrobe"
	icon_state = "blue"
	icon_closed = "blue"
	spawn_contents = list(/obj/item/clothing/under/color/blue = 4,
	/obj/item/clothing/shoes/brown = 4,
	/obj/item/clothing/head/blue = 2)

/obj/storage/closet/wardrobe/mixed
	name = "mixed wardrobe"
	icon_state = "mixed"
	icon_closed = "mixed"
	spawn_contents = list(/obj/item/clothing/under/color/blue = 2,
	/obj/item/clothing/under/color/pink = 2,
	/obj/item/clothing/shoes/brown = 4,
	/obj/item/clothing/head/blue,
	/obj/item/clothing/head/red)

/* =================== */
/* ----- Special ----- */
/* =================== */
/obj/storage/closet/wardrobe/specialty_janitor // adhara stuff
	name = "janitor wardrobe"
	desc = "It's a closet! This one can be opened AND closed. Comes with specialty janitor's clothing."
	icon_state = "mixed"
	icon_closed = "mixed"
	spawn_contents = list(/obj/item/clothing/under/rank/janitor = 1,
	/obj/item/clothing/suit/bio_suit/janitor = 1,
	/obj/item/clothing/head/bio_hood/janitor = 1,
	/obj/item/clothing/mask/gas = 1,
	/obj/item/clothing/gloves/long = 1,
	/obj/item/clothing/shoes/galoshes/torn = 1,
	/obj/item/device/light/flashlight = 1)


/obj/storage/closet/wardrobe/black/chaplain
	name = "\improper Chaplain wardrobe"
	spawn_contents = list(/obj/item/clothing/under/rank/chaplain,
	/obj/item/clothing/under/misc/chaplain/atheist,
	/obj/item/clothing/under/misc/chaplain,
	/obj/item/clothing/under/misc/chaplain/rabbi,
	// drsingh is still not a real sihk
	/obj/item/clothing/under/misc/chaplain/siropa_robe,
	/obj/item/clothing/under/misc/chaplain/buddhist,
	/obj/item/clothing/under/misc/chaplain/muslim,
	/obj/item/clothing/suit/adeptus,
	/obj/item/clothing/head/rabbihat,
	/obj/item/clothing/head/formal_turban,
	/obj/item/clothing/head/turban,
	/obj/item/clothing/shoes/black,
	/obj/item/clothing/under/misc/chaplain/nun,
	/obj/item/clothing/head/nunhood,
	/obj/item/clothing/shoes/sandal)

/obj/storage/closet/wardrobe/black/formalwear
	name = "formalwear closet"
	desc = "It's a closet! This one can be opened AND closed. Comes with formal clothes"
	spawn_contents = list(/obj/item/clothing/under/gimmick/maid,
	/obj/item/clothing/head/maid,
	/obj/item/clothing/under/gimmick/butler,
	/obj/item/clothing/head/that = 2,
	/obj/item/clothing/under/rank/bartender = 2,
	/obj/item/clothing/suit/wcoat = 2,
	/obj/item/clothing/shoes/black = 2)

/obj/storage/closet/wardrobe/yellow/engineering
	name = "\improper Engineering wardrobe"
	spawn_contents = list(/obj/item/clothing/under/rank/engineer = 4,
	/obj/item/clothing/shoes/orange = 4)

/obj/storage/closet/wardrobe/red/security_gimmick
	name = "\improper Security wardrobe"
	spawn_contents = list(/obj/item/clothing/shoes/brown = 4,
	/obj/item/clothing/under/color/red,
	/obj/item/clothing/under/gimmick/police,
	/obj/item/clothing/under/misc/dirty_vest,
	/obj/item/clothing/under/misc/tourist,
	/obj/item/clothing/under/misc/tourist/max_payne,
	/obj/item/clothing/under/misc/serpico,
	/obj/item/clothing/gloves/fingerless,
	/obj/item/clothing/head/serpico,
	/obj/item/clothing/head/red,
	/obj/item/clothing/head/flatcap,
	/obj/item/clothing/head/policecap,
	/obj/item/clothing/head/helmet/bobby,
	/obj/item/clothing/head/helmet/siren = 2)

/obj/storage/closet/wardrobe/white/medical
	name = "\improper Medical wardrobe"
	spawn_contents = list(/obj/item/clothing/under/rank/medical = 4,
	/obj/item/clothing/shoes/red = 4,
	/obj/item/storage/box/stma_kit,
	/obj/item/clothing/suit/labcoat = 3)

/obj/storage/closet/wardrobe/white/research
	name = "\improper Research wardrobe"
	spawn_contents = list(/obj/item/clothing/under/rank/scientist = 4,
	/obj/item/clothing/shoes/white = 4,
	/obj/item/storage/box/stma_kit,
	/obj/item/clothing/suit/labcoat = 4)

/obj/storage/closet/wardrobe/white/genetics
	name = "\improper Genetics wardrobe"
	spawn_contents = list(/obj/item/clothing/under/rank/geneticist = 4,
	/obj/item/clothing/shoes/white= 4,
	/obj/item/storage/box/stma_kit,
	/obj/item/clothing/suit/labcoat = 4)

/obj/storage/closet/dresser/random
	var/list/list_jump = list(/obj/item/clothing/under/color,
	/obj/item/clothing/under/color/grey,
	/obj/item/clothing/under/color/white,
	/obj/item/clothing/under/color/darkred,
	/obj/item/clothing/under/color/red,
	/obj/item/clothing/under/color/lightred,
	/obj/item/clothing/under/color/orange,
	/obj/item/clothing/under/color/brown,
	/obj/item/clothing/under/color/lightbrown,
	/obj/item/clothing/under/color/yellow,
	/obj/item/clothing/under/color/yellowgreen,
	/obj/item/clothing/under/color/lime,
	/obj/item/clothing/under/color/green,
	/obj/item/clothing/under/color/aqua,
	/obj/item/clothing/under/color/lightblue,
	/obj/item/clothing/under/color/blue,
	/obj/item/clothing/under/color/darkblue,
	/obj/item/clothing/under/color/purple,
	/obj/item/clothing/under/color/lightpurple,
	/obj/item/clothing/under/color/magenta,
	/obj/item/clothing/under/color/pink)
	var/list/list_shoe = list(/obj/item/clothing/shoes/white,
	/obj/item/clothing/shoes/black,
	/obj/item/clothing/shoes/brown,
	/obj/item/clothing/shoes/red,
	/obj/item/clothing/shoes/orange,
	/obj/item/clothing/shoes/blue,
	/obj/item/clothing/shoes/pink)

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			for (var/i = 4, i > 0, i--)
				var/obj/item/clothing/under/color/JS = pick(src.list_jump)
				new JS(src)
				var/obj/item/clothing/shoes/SH = pick(src.list_shoe)
				new SH(src)
			return 1

/obj/storage/closet/wardrobe/wizard
	name = "magical wardrobe"
	desc = "It's totally magic. It's got all sorts of magic in it. Not a regular wardrobe at all."
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicate-open"
	spawn_contents = list(/obj/item/staff = 4,
	/obj/item/staff/crystal = 2,
	/obj/item/clothing/suit/wizrobe/necro = 2,
	/obj/item/clothing/head/wizard/necro = 2,
	/obj/item/clothing/head/wizard/witch = 2,
	/obj/item/clothing/suit/wizrobe/green = 2,
	/obj/item/clothing/head/wizard/green = 2,
	/obj/item/clothing/suit/wizrobe/purple = 2,
	/obj/item/clothing/head/wizard/purple = 2,
	/obj/item/clothing/suit/wizrobe/red = 2,
	/obj/item/clothing/head/wizard/red = 2,
	/obj/item/clothing/suit/wizrobe = 2,
	/obj/item/clothing/head/wizard = 2)
