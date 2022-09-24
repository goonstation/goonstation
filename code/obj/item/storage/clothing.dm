
/* ============================== */
/* ---------- Clothing ---------- */
/* ============================== */

/obj/item/storage/box/clothing
	icon_state = "clothing"

/obj/item/storage/box/clothing/captain
	name = "\improper Captain's clothing"
	spawn_contents = list(/obj/item/clothing/under/rank/captain,
	/obj/item/clothing/under/rank/captain/dress,
	/obj/item/clothing/head/fancy/captain,
	/obj/item/clothing/under/rank/captain/fancy,
	/obj/item/clothing/under/suit/captain,
	/obj/item/clothing/under/suit/captain/dress,
	/obj/item/clothing/suit/wintercoat/command)

/obj/item/storage/box/clothing/hos
	name = "\improper Head of Security's clothing"
	spawn_contents = list(/obj/item/clothing/under/rank/head_of_security,
	/obj/item/clothing/under/rank/head_of_security/dress,
	/obj/item/clothing/under/suit/hos,
	/obj/item/clothing/under/suit/hos/dress,
	/obj/item/clothing/under/rank/head_of_security/fancy,
	/obj/item/clothing/suit/wintercoat/command)

/obj/item/storage/box/clothing/hop
	name = "\improper Head of Personnel's clothing"
	spawn_contents = list(/obj/item/clothing/under/rank/head_of_personnel,
	/obj/item/clothing/under/rank/head_of_personnel/dress,
	/obj/item/clothing/under/suit/hop,
	/obj/item/clothing/under/suit/hop/dress,
	/obj/item/clothing/head/fancy/rank,
	/obj/item/clothing/under/rank/head_of_personnel/fancy,
	/obj/item/clothing/suit/wintercoat/command)

/obj/item/storage/box/clothing/research_director
	name = "\improper Research Director's clothing"
	spawn_contents = list(/obj/item/clothing/under/rank/research_director,
	/obj/item/clothing/under/rank/research_director/dress,
	/obj/item/clothing/suit/labcoat,
	/obj/item/clothing/head/fancy/rank,
	/obj/item/clothing/under/rank/research_director/fancy,
	/obj/item/clothing/suit/wintercoat/command)

/obj/item/storage/box/clothing/medical_director
	name = "\improper Medical Director's clothing"
	spawn_contents = list(/obj/item/clothing/under/rank/medical_director,
	/obj/item/clothing/under/rank/medical_director/dress,
	/obj/item/clothing/suit/labcoat/medical_director,
	/obj/item/clothing/head/fancy/rank,
	/obj/item/clothing/under/rank/medical_director/fancy,
	/obj/item/clothing/suit/wintercoat/command)

/obj/item/storage/box/clothing/chief_engineer
	name = "\improper Chief Engineer's clothing"
	spawn_contents = list(/obj/item/clothing/under/rank/chief_engineer,
	/obj/item/clothing/under/rank/chief_engineer/dress,
	/obj/item/clothing/head/fancy/rank,
	/obj/item/clothing/under/rank/chief_engineer/fancy,
	/obj/item/clothing/suit/wintercoat/command)

// Civilian Equipment

/obj/item/storage/box/clothing/janitor
	name = "\improper Janitor's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/janitor,\
	/obj/item/clothing/shoes/brown,\
	/obj/item/device/radio/headset/civilian,\
	/obj/item/device/pda2/janitor)

/obj/item/storage/box/clothing/botanist
	name = "\improper Botanist's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/hydroponics,\
	/obj/item/clothing/shoes/brown,\
	/obj/item/device/radio/headset/civilian,\
	/obj/item/device/pda2/botanist,\
	/obj/item/clothing/gloves/black)

/obj/item/storage/box/clothing/rancher
	name = "\improper Rancher's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/rancher,\
	/obj/item/clothing/shoes/westboot/brown/rancher,\
	/obj/item/device/radio/headset/civilian,\
	/obj/item/device/pda2/botanist,\
	/obj/item/clothing/gloves/black)

/obj/item/storage/box/clothing/chef
	name = "\improper Chef's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/chef,\
	/obj/item/clothing/shoes/chef,\
	/obj/item/clothing/head/chefhat,\
	/obj/item/clothing/suit/chef,\
	/obj/item/device/radio/headset/civilian,\
	/obj/item/device/pda2/chef)

/obj/item/storage/box/clothing/souschef
	name = "\improper Sous-Chef's equipment"
	spawn_contents = list(/obj/item/clothing/under/misc/souschef,\
	/obj/item/clothing/shoes/chef,\
	/obj/item/clothing/head/souschefhat,\
	/obj/item/clothing/suit/apron,\
	/obj/item/device/radio/headset/civilian,\
	/obj/item/device/pda2/chef)

/obj/item/storage/box/clothing/bartender
	name = "\improper Bartender's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/bartender,\
	/obj/item/clothing/shoes/black,\
	/obj/item/device/radio/headset/civilian,\
	/obj/item/device/pda2/bartender)

/obj/item/storage/box/clothing/waiter
	name = "\improper Waiter's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/bartender,\
	/obj/item/clothing/shoes/black,\
	/obj/item/clothing/suit/wcoat,\
	/obj/item/device/radio/headset/civilian,\
	/obj/item/device/pda2/bartender)

/obj/item/storage/box/clothing/chaplain
	name = "\improper Chaplain's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/chaplain,\
	/obj/item/clothing/shoes/black,\
	/obj/item/device/radio/headset/civilian,\
	/obj/item/device/pda2/chaplain)

// Security Equipment

/obj/item/storage/box/clothing/security
	name = "\improper Security Officer's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/security,\
	/obj/item/clothing/shoes/swat,\
	/obj/item/device/radio/headset/security,\
	/obj/item/device/pda2/security)

/obj/item/storage/box/clothing/detective
	name = "\improper Detective's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/det,\
	/obj/item/clothing/shoes/detective,\
	/obj/item/clothing/suit/det_suit,\
	/obj/item/clothing/gloves/black,\
	/obj/item/clothing/head/det_hat,\
	/obj/item/device/radio/headset/security,\
	/obj/item/device/pda2/forensic)

// Medical Equipment

/obj/item/storage/box/clothing/medical
	name = "\improper Medical Doctor's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/medical,\
	/obj/item/clothing/shoes/red,\
	/obj/item/clothing/suit/labcoat,\
	/obj/item/device/radio/headset/medical,\
	/obj/item/device/pda2/medical)

/obj/item/storage/box/clothing/geneticist
	name = "\improper Geneticist's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/geneticist,\
	/obj/item/clothing/shoes/white,\
	/obj/item/clothing/suit/labcoat/genetics,\
	/obj/item/clothing/suit/wintercoat/genetics,\
	/obj/item/device/radio/headset/medical,\
	/obj/item/device/pda2/genetics)

/obj/item/storage/box/clothing/roboticist
	name = "\improper Roboticist's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/roboticist,\
	/obj/item/clothing/shoes/black,\
	/obj/item/clothing/suit/labcoat/robotics,\
	/obj/item/device/radio/headset/medical,\
	/obj/item/device/pda2/medical/robotics,\
	/obj/item/clothing/gloves/latex)

// Research Equipment

/obj/item/storage/box/clothing/research
	name = "\improper Researcher's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/scientist,\
	/obj/item/clothing/shoes/white,\
	/obj/item/clothing/suit/labcoat,\
	/obj/item/device/radio/headset/research,\
	/obj/item/device/pda2/toxins)

// Engineering Equipment

/obj/item/storage/box/clothing/mechanic
	name = "\improper Mechanic's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/mechanic,\
	/obj/item/clothing/shoes/black,\
	/obj/item/device/radio/headset/mechanic,\
	/obj/item/device/pda2/mechanic,\
	/obj/item/clothing/under/rank/orangeoveralls/yellow)

/obj/item/storage/box/clothing/engineer
	name = "\improper Engineer's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/engineer,\
	/obj/item/clothing/shoes/orange,\
	/obj/item/device/radio/headset/engineer,\
	/obj/item/device/pda2/engine,\
	/obj/item/clothing/under/rank/orangeoveralls)

/obj/item/storage/box/clothing/miner
	name = "\improper Miner's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/overalls,\
	/obj/item/clothing/shoes/orange,\
	/obj/item/clothing/gloves/black,\
	/obj/item/device/radio/headset/miner,\
	/obj/item/device/pda2/mining)

/obj/item/storage/box/clothing/qm
	name = "\improper Quartermaster's equipment"
	spawn_contents = list(/obj/item/clothing/under/rank/cargo,\
	/obj/item/clothing/shoes/black,\
	/obj/item/clothing/gloves/black,\
	/obj/item/device/radio/headset/shipping,\
	/obj/item/device/pda2/quartermaster)

/obj/item/storage/box/clothing/wedding_dress
	name = "wedding dress set"
	desc = "A box that contains everything* you need to walk down that isle!<br><small><i>*Ring and fiancé(e) not included.</i></small>"
	spawn_contents = list(/obj/item/clothing/under/gimmick/wedding_dress,
	/obj/item/clothing/head/veil,
	/obj/item/clothing/shoes/heels)

/obj/item/storage/box/clothing/wedding_tuxedo
	name = "tuxedo set"
	desc = "A box that contains everything* you need to walk down that isle!<br><small><i>*Ring and fiancé(e) not included.</i></small>"
	spawn_contents = list(/obj/item/clothing/suit/tuxedo_jacket,
	/obj/item/clothing/under/rank/bartender/tuxedo,
	/obj/item/clothing/shoes/dress_shoes)

/obj/item/storage/box/clothing/witchfinder
	name = "\improper Witchfinder's equipment"
	spawn_contents = list(/obj/item/clothing/under/gimmick/witchfinder,\
	/obj/item/clothing/suit/witchfinder,\
	/obj/item/clothing/head/witchfinder,\
	/obj/item/clothing/shoes/witchfinder)

/* ============================== */
/* ---------- Costumes ---------- */
/* ============================== */

/obj/item/storage/box/costume
	icon_state = "costume"
	in_list_or_max = TRUE
	can_hold = list(/obj/item/clothing/under)

/obj/item/storage/box/costume/clown
	name = "clown costume"
	icon_state = "clown"
	desc = "A box that contains a clown costume."
	spawn_contents = list(/obj/item/clothing/mask/clown_hat,
	/obj/item/clothing/under/misc/clown,
	/obj/item/clothing/shoes/clown_shoes,
	/obj/item/storage/fanny/funny,
	/obj/item/card/id/clown,
	/obj/item/device/pda2/clown)

/obj/item/storage/box/costume/clown/recycled
	name = "recycled clown costume"
	desc = "A box that contains a clown costume. One clumsy former owner."
	spawn_contents = list(
		/obj/item/clothing/mask/clown_hat,
		/obj/item/clothing/under/misc/clown,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/storage/fanny/funny/mini,
		/obj/item/card/id/clown,
		/obj/item/device/pda2/clown,
	)

/obj/item/storage/box/costume/mime
	name = "mime costume"
	icon_state = "mime"
	item_state = "box-mime"
	desc = "There's a mime trapped in this box! Wait... no it's just a bunch of mime clothes."
	spawn_contents = list(
		/obj/item/clothing/head/mime_bowler,
		/obj/item/clothing/mask/mime,
		/obj/item/clothing/gloves/latex,
		/obj/item/clothing/under/misc/mime/alt,
		/obj/item/clothing/suit/scarf,
		/obj/item/clothing/shoes/black,
	)

/obj/item/storage/box/costume/mime/alt //people can have either the normal clothes or the other clothes
	spawn_contents = list(
		/obj/item/clothing/head/mime_beret,
		/obj/item/clothing/mask/mime,
		/obj/item/clothing/gloves/latex,
		/obj/item/clothing/under/misc/mime,
		/obj/item/clothing/suit/suspenders,
		/obj/item/clothing/shoes/black,
	)

/obj/item/storage/box/costume/jester
	name = "jester costume"
	desc = "A box that contains a jester's outfit"
	spawn_contents = list(
		/obj/item/clothing/head/jester,
		/obj/item/clothing/mask/jester,
		/obj/item/clothing/under/gimmick/jester,
		/obj/item/clothing/shoes/jester,
	)

/obj/item/storage/box/costume/robuddy
	name = "guardbuddy costume"
	spawn_contents = list(/obj/item/clothing/suit/robuddy)

/obj/item/storage/box/costume/bee
	name = "bee costume"
	spawn_contents = list(/obj/item/clothing/suit/bee)

/obj/item/storage/box/costume/monkey
	name = "monkey costume"
	spawn_contents = list(/obj/item/clothing/suit/monkey,
	/obj/item/reagent_containers/food/snacks/plant/banana)

/obj/item/storage/box/costume/crap
	icon_state = "costume-crap"
	desc = "'Another great costume brought to you by Spook*Corp!'"

/obj/item/storage/box/costume/crap/waltwhite
	name = "meth scientist costume"
	spawn_contents = list(/obj/item/clothing/mask/waltwhite)

	make_my_stuff()
		..()
		var/obj/item/clothing/under/color/orange/jump = new /obj/item/clothing/under/color/orange(src)
		jump.name = "meth scientist uniform"
		jump.desc = "What? This clearly isn't a repurposed prison uniform, we promise."

/obj/item/storage/box/costume/crap/spiderman
	name = "red alien costume"

	make_my_stuff()
		..()
		var/obj/item/clothing/mask/cmask = new /obj/item/clothing/mask/spiderman(src)
		cmask.name = "red alien mask"
		cmask.desc = "The material of this mask can probably scrape off your face. 'Spook*Corp Costumes' on embedded on the side of it."

		var/obj/item/clothing/under/sunder = new /obj/item/clothing/under/gimmick/spiderman(src)
		sunder.name = "red alien suit"
		sunder.desc = "Just looking at this thing makes you feel itchy! 'Spook*Corp Costumes' is embedded on the side of it."

/obj/item/storage/box/costume/crap/wonka
	name = "victorian confectionery factory owner costume"
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/candy/chocolate)

	make_my_stuff()
		..()
		var/obj/item/clothing/head/chat = new /obj/item/clothing/head/that/purple(src)
		chat.name = "victorian confectionery factory owner hat"
		chat.desc = "This hat really feels like something you shouldn't be putting near your brain! 'Spook*Corp Costumes' on embedded on the side of it."

		var/obj/item/clothing/under/sunder = new /obj/item/clothing/under/suit/purple(src)
		sunder.name = "victorian confectionery factory owner suit"
		sunder.desc = "Just looking at this thing makes you feel itchy! 'Spook*Corp Costumes' is embedded on the side of it."

		var/obj/item/acane = new /obj/item/crowbar(src)
		acane.name = "cane"
		acane.desc = "Totally a cane."

/obj/item/storage/box/costume/light_borg
	name = "light cyborg costume"
	spawn_contents = list(/obj/item/clothing/suit/gimmick/light_borg)

/obj/item/storage/box/costume/utena
	name = "revolutionary costume set"
	spawn_contents = list(/obj/item/clothing/under/gimmick/utena,
	/obj/item/clothing/under/gimmick/anthy,
	/obj/item/clothing/shoes/utenashoes)

	make_my_stuff()
		..()
		var/obj/item/e_g_g = new /obj/item/reagent_containers/food/snacks/ingredient/egg(src)
		e_g_g.name = "e g g"
		e_g_g.desc = "Smash the world's shell!"

/obj/item/storage/box/costume/werewolf
	name = "werewolf costume set"
	spawn_contents = list(/obj/item/clothing/suit/gimmick/werewolf,
	/obj/item/clothing/head/werewolf)

/obj/item/storage/box/costume/werewolf/odd
	desc = "Huh, the contents look a little bit odd."

	make_my_stuff()
		var/my_color = random_color()
		var/obj/item/clothing/suit/S = new /obj/item/clothing/suit/gimmick/werewolf/odd(src)
		S.color = my_color
		var/obj/item/clothing/head/H = new /obj/item/clothing/head/werewolf/odd(src)
		H.color = my_color

/obj/item/storage/box/costume/vampire
	name = "vampire costume set"
	desc = "Blah blah blah."
	spawn_contents = list(/obj/item/clothing/under/gimmick/vampire,
	/obj/item/clothing/suit/gimmick/vampire)

/obj/item/storage/box/costume/abomination
	name = "abomination costume set"
	spawn_contents = list(/obj/item/clothing/suit/gimmick/abomination,
	/obj/item/clothing/head/abomination)

/obj/item/storage/box/costume/eighties
	name = "eighties costume set"
	spawn_contents = list(/obj/item/clothing/under/gimmick/eightiesmens,
	/obj/item/clothing/under/gimmick/eightieswomens)

/obj/item/storage/box/costume/roller_disco
	name = "roller disco costume set"
	spawn_contents = list(/obj/item/clothing/under/gimmick/rollerdisco,
	/obj/item/clothing/shoes/rollerskates)

/obj/item/storage/box/costume/hotdog
	name = "hotdog costume set"
	spawn_contents = list(/obj/item/clothing/suit/gimmick/hotdog,
	/obj/item/reagent_containers/food/snacks/hotdog)

/obj/item/storage/box/costume/scifi
	name = "sci-fi garb set"
	spawn_contents = list(/obj/item/clothing/under/gimmick/cwfashion,
	/obj/item/clothing/under/gimmick/ftuniform,
	/obj/item/clothing/shoes/cwboots,
	/obj/item/clothing/head/cwhat,
	/obj/item/clothing/head/fthat,
	/obj/item/clothing/gloves/handcomp,
	/obj/item/clothing/glasses/ftscanplate)

/obj/item/storage/box/costume/purpwitch
	name = "purple witch costume set"
	desc = "They won't give you any real magic, but you always have the magic of Imagination."
	spawn_contents = list(/obj/item/clothing/head/witchhat_purple,
	/obj/item/clothing/shoes/witchboots,
	/obj/item/clothing/suit/witchcape_purple,
	/obj/item/device/light/glowstick/purple)

/obj/item/storage/box/costume/mintwitch
	name = "mint witch costume set"
	desc = "They won't give you any real magic, but you always have the magic of Imagination."
	spawn_contents = list(/obj/item/clothing/head/witchhat_mint,
	/obj/item/clothing/shoes/witchboots,
	/obj/item/clothing/suit/witchcape_mint,
	/obj/item/device/light/glowstick/cyan)

