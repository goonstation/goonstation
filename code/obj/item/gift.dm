// GIFTS

/obj/item/wrapping_paper
	name = "wrapping paper"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "wrap_paper-r"
	item_state = "wrap_paper"
	uses_multiple_icon_states = 1
	amount = 20
	desc = "Used for wrapping gifts. It's got a neat design!"
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	tooltip_flags = REBUILD_DIST
	var/style = "r"

	New()
		..()
		src.style = rand(1,8)
		src.icon_state = "wrap_paper-[src.style]"

/obj/item/wrapping_paper/xmas
	desc = "This wrapping paper is especially festive."

	New()
		..()
		src.style = pick("r", "rs", "g", "gs")
		src.icon_state = "wrap_paper-[src.style]"

/obj/item/wrapping_paper/attackby(obj/item/W, mob/user)
	if(W.cant_drop || W.cant_self_remove)
		return
	if (!( locate(/obj/table, src.loc) ))
		boutput(user, "<span class='notice'>You MUST put the paper on a table!</span>")
		return
	if (W.w_class < W_CLASS_BULKY)
		if ((istool(user.l_hand, TOOL_CUTTING | TOOL_SNIPPING) && user.l_hand != W) || (istool(user.r_hand, TOOL_CUTTING | TOOL_SNIPPING) && user.r_hand != W))
			if(istype(W, /obj/item/c_tube) && user.client)
				var user_choice = input(user, "Do what to the cardboard tube?", "Cardboard tube") in list("Cancel", "Wrap", "Create Hat")
				if(user_choice == "Cancel")
					return
				if(!(user_choice == "Wrap"))
					var/a_used = 2 ** (src.w_class - 1)
					if (src.amount < a_used)
						boutput(user, "<span class='notice'>You need more paper!</span>")
						return
					src.amount -= a_used
					tooltip_rebuild = 1
					user.drop_item()
					qdel(W)
					var/obj/item/clothing/head/apprentice/A = new /obj/item/clothing/head/apprentice(src.loc)
					A.add_fingerprint(user)
					user.put_in_hand_or_drop(A)
					if (src.amount <= 0)
						user.u_equip(src)
						var/obj/item/c_tube/C = new /obj/item/c_tube(src.loc)
						user.put_in_hand_or_drop(C)
						qdel(src)
					return
			if(istype(W, /obj/item/phone_handset/))
				boutput(user, "<span class='notice'>You can't wrap that, it has a cord attached!</span>")
				return
			var/a_used = 2 ** (src.w_class - 1)
			if (src.amount < a_used)
				boutput(user, "<span class='notice'>You need more paper!</span>")
				return
			else
				src.amount -= a_used
				tooltip_rebuild = 1
				user.drop_item()
				var/obj/item/gift/G = new /obj/item/gift(src.loc)
				G.size = W.w_class
				G.w_class = G.size + 1
				G.icon_state = "gift[clamp(G.size, 1, 3)]-[src.style]"
				G.gift = W
				W.set_loc(G)
				G.add_fingerprint(user)
				W.add_fingerprint(user)
				src.add_fingerprint(user)
				modify_christmas_cheer(1)
				user.put_in_hand_or_drop(G)
			if (src.amount <= 0)
				user.u_equip(src)
				var/obj/item/c_tube/C = new /obj/item/c_tube(src.loc)
				user.put_in_hand_or_drop(C)
				qdel(src)
				return
		else
			boutput(user, "<span class='notice'>You need something to cut [src] with!</span>")
	else
		boutput(user, "<span class='notice'>The object is FAR too large!</span>")
	return

/obj/item/wrapping_paper/get_desc(dist)
	if (dist > 2)
		return
	. += "There is about [src.amount] square units of paper left!"

/obj/item/wrapping_paper/attack(mob/target, mob/user)
	if (!ishuman(target))
		return
	if (isdead(target))
		if (src.amount > 2)
			var/obj/spresent/present = new /obj/spresent (target.loc)
			present.icon_state = "strange-[src.style]"
			src.amount -= 2
			tooltip_rebuild = 1

			target.set_loc(present)
		else
			boutput(user, "<span class='notice'>You need more paper.</span>")
	else
		boutput(user, "They're moving around too much.")

/obj/item/gift
	desc = "For me!?"
	name = "gift"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift2-p"
	item_state = "gift"
	var/size = 3
	var/obj/item/gift = null
	w_class = W_CLASS_BULKY
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0

/obj/item/gift/attack_self(mob/user as mob)
	if(!src.gift)
		boutput(user, "<span class='notice'>The gift was empty!</span>")
		qdel(src)
		return

	user.u_equip(src)
	user.put_in_hand_or_drop(src.gift)
	if(istype(src.gift, /obj/item/mousetrap))
		var/obj/item/mousetrap/MT = src.gift
		if(MT.armed)
			modify_christmas_cheer(-4)
			MT.triggered(user, user.hand ? "l_hand" : "r_hand")


	modify_christmas_cheer(2)
	qdel(src)
	return

/obj/item/a_gift
	name = "gift"
	desc = "I wonder what's inside!?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift2-b"
	item_state = "gift"
	pressure_resistance = 70
	var/random_icons = 1
	var/list/giftpaths = null

	New()
		..()
		if (src.random_icons)
			src.icon_state = "[(prob(1) && prob(1)) ? "strange" : "gift[rand(1,3)]"]-[pick("r", "rs", "g", "gs")]"

	dangerous
		giftpaths = list(/obj/item/device/flash,
						/obj/item/gun/energy/taser_gun,
						/obj/item/sword,
						/obj/item/axe,
						/obj/item/knife/butcher,
						/obj/item/old_grenade/light_gimmick,
						/obj/item/storage/belt/wrestling)

	festive
		EPHEMERAL_XMAS
		icon_state = "gift2-g"
		attack_self(mob/M as mob)
			if (!islist(giftpaths) || !length(giftpaths))
				src.giftpaths = generic_gift_paths + xmas_gift_paths
			..()

	easter
		name = "easter egg"
		icon_state = "easter_egg"
		random_icons = 0
		attack_self(mob/M as mob)
			if (!islist(giftpaths) || !length(giftpaths))
				src.giftpaths = generic_gift_paths
			..()

	easter/dangerous
		attack_self(mob/M as mob)
			if (!islist(giftpaths) || !length(giftpaths))
				src.giftpaths = generic_gift_paths + questionable_generic_gift_paths
			..()

/obj/item/a_gift/attack_self(mob/M as mob)
	if (!islist(giftpaths) || !length(giftpaths))
		boutput(M, "<span class='notice'>[src] was empty!</span>")
		qdel(src)
		return

	var/prizepath = pick(giftpaths)
	var/obj/item/prize = new prizepath
	if (!istype(prize) && prize)
		prize.set_loc(get_turf(M))
		qdel(src)
		return

	M.u_equip(src)
	M.put_in_hand_or_drop(prize)
	modify_christmas_cheer(2)
	qdel(src)

/obj/item/a_gift/ex_act()
	qdel(src)
	return

/obj/spresent // bandaid fix for presents having no icon or name other than "spresent"
	name = "present"
	desc = "What could it be?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "strange-r"

/obj/spresent/relaymove(mob/user as mob)
	if (user.stat)
		return
	boutput(user, "<span class='notice'>You can't move.</span>")

/obj/spresent/attackby(obj/item/W, mob/user)

	if (!issnippingtool(W))
		boutput(user, "<span class='notice'>I need a snipping tool for that.</span>")
		return

	boutput(user, "<span class='notice'>You cut open the present.</span>")

	for(var/mob/M in src) //Should only be one but whatever.
		M.set_loc(src.loc)

	qdel(src)

var/global/list/generic_gift_paths = list(/obj/item/basketball,
	/obj/item/football,
	/obj/item/clothing/head/cakehat,
	/obj/item/clothing/mask/melons,
	/obj/item/old_grenade/spawner/banana,
	/obj/item/old_grenade/spawner/cheese_sandwich,
	/obj/item/old_grenade/spawner/banana_corndog,
	/obj/item/gimmickbomb/butt,
	/obj/item/instrument/bikehorn,
	/obj/item/instrument/bikehorn/dramatic,
	/obj/item/instrument/bikehorn/airhorn,
	/obj/item/instrument/vuvuzela,
	/obj/item/instrument/bagpipe,
	/obj/item/instrument/harmonica,
	/obj/item/instrument/fiddle,
	/obj/item/instrument/trumpet,
	/obj/item/instrument/whistle,
	/obj/item/instrument/guitar,
	/obj/item/instrument/triangle,
	/obj/item/instrument/tambourine,
	/obj/item/instrument/cowbell,
	/obj/item/horseshoe,
	/obj/item/clothing/glasses/monocle,
	/obj/item/dice/coin,
	/obj/item/dice/magic8ball,
	/obj/item/storage/dicepouch,
	/obj/item/clothing/gloves/fingerless,
	/obj/item/clothing/mask/spiderman,
	/obj/item/clothing/shoes/flippers,
	/obj/item/clothing/gloves/water_wings,
	/obj/item/inner_tube/random,
	/obj/item/clothing/head/waldohat,
	/obj/item/emeter,
	/obj/item/skull,
	/obj/item/pen/crayon/lipstick,
	/obj/item/pen/crayon/rainbow,
	/obj/item/storage/box/crayon,
	/obj/item/device/light/zippo/gold,
	/obj/item/spacecash/random/really_small,
	/obj/item/rubberduck,
	/obj/item/rubber_hammer,
	/obj/item/bang_gun,
	/obj/item/bee_egg_carton,
	/obj/item/brick,
	/obj/item/rubber_chicken,
	/obj/item/clothing/ears/earmuffs,
	/obj/item/clothing/glasses/macho,
	/obj/item/clothing/glasses/noir,
	/obj/item/clothing/glasses/sunglasses/tanning,
	/obj/item/clothing/head/cowboy,
	/obj/item/clothing/head/apprentice,
	/obj/item/clothing/head/crown,
	/obj/item/clothing/head/dramachefhat,
	/obj/item/clothing/head/XComHair,
	/obj/item/clothing/head/snake,
	/obj/item/clothing/head/bigtex,
	/obj/item/clothing/head/aviator,
	/obj/item/clothing/head/pinwheel_hat,
	/obj/item/clothing/head/frog_hat,
	/obj/item/clothing/head/hairbow/flashy,
	/obj/item/clothing/head/helmet/jetson,
	/obj/item/clothing/head/longtophat,
	/obj/item/clothing/suit/bedsheet/cape/royal,
	/obj/item/clothing/mask/moustache,
	/obj/item/clothing/mask/moustache/safe,
	/obj/item/clothing/mask/chicken,
	/obj/item/clothing/gloves/fingerless,
	/obj/item/clothing/gloves/yellow/unsulated,
	/obj/item/clothing/suit/bee,
	/obj/item/clothing/shoes/cowboy,
	/obj/item/clothing/shoes/dress_shoes,
	/obj/item/clothing/shoes/heels/red,
	/obj/item/clothing/shoes/moon,
	/obj/item/clothing/suit/armor/sneaking_suit/costume,
	/obj/item/clothing/suit/hoodie,
	/obj/item/clothing/suit/robuddy,
	/obj/item/clothing/suit/scarf,
	/obj/item/clothing/under/gimmick/rainbow,
	/obj/item/item_box/figure_capsule,
	/obj/item/item_box/assorted/stickers,
	/obj/item/paint_can/rainbow,
	/obj/item/paint_can/rainbow/plaid,
	/obj/item/storage/box/beer,
	/obj/item/storage/box/bacon_kit,
	/obj/item/storage/box/balloonbox,
	/obj/item/storage/box/nerd_kit,
	/obj/item/storage/fanny/funny,
	/obj/item/storage/firstaid/regular,
	/obj/item/storage/pill_bottle/cyberpunk,
	/obj/item/toy/sword,
	/obj/item/stg_box,
	/obj/item/clothing/suit/jacket/plastic/random_color)

var/global/list/questionable_generic_gift_paths = list(/obj/item/relic,
	/obj/item/stimpack,
	/obj/item/clothing/mask/cursedclown_hat,
	/obj/item/fireaxe,
	/obj/racing_clowncar/kart,
	/obj/item/old_grenade/moustache,
	/obj/item/clothing/head/oddjob,
	/obj/item/clothing/mask/anime,
	/obj/item/clothing/under/gimmick,
	/obj/item/clothing/suit/armor/sneaking_suit,
	/obj/item/kitchen/everyflavor_box,
	/obj/item/medical/bruise_pack/cyborg,
	/obj/item/medical/ointment/cyborg,
	/obj/item/storage/box/prosthesis_kit/eye_random,
	/obj/item/storage/box/spy_sticker_kit,
	/obj/item/reagent_containers/food/snacks/pizza/xmas,
#ifndef RP_MODE
	/obj/item/implanter/microbomb,
	/obj/item/old_grenade/light_gimmick,
	/obj/item/gun/energy/bfg,
	/obj/item/engibox/station_locked,
	/obj/item/gun/energy/tommy_gun,
	/obj/item/gun/energy/glitch_gun,
	/obj/item/instrument/trumpet/dootdoot,
	/obj/item/instrument/fiddle/satanic,
	/obj/item/gun/kinetic/beepsky,
	/obj/item/gun/kinetic/gungun,
#endif
	/obj/item/spacecash/random/small)

var/global/list/xmas_gift_paths = list(/obj/item/clothing/suit/sweater,
	/obj/item/clothing/suit/sweater/red,
	/obj/item/clothing/suit/sweater/green,
	/obj/item/reagent_containers/food/snacks/candy/candy_cane,
	/obj/item/storage/box/cookie_tin,
	/obj/item/storage/box/cookie_tin/sugar)

var/global/list/questionable_xmas_gift_paths = list(/obj/item/reagent_containers/food/snacks/pizza/xmas)
