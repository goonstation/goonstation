// Anything you can't really sort under anything else, mostly casual wear
ABSTRACT_TYPE(/obj/item/clothing/under/misc)
/obj/item/clothing/under/misc
	name = "under misc parent"
	desc = "This is weird! Report this to a coder!"
	icon = 'icons/obj/clothing/jumpsuits/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuits/hand_js_misc.dmi'

/obj/item/clothing/under/misc/vice
	name = "vice officer's suit"
	desc = "This thing reeks of weed."
	icon_state = "viceW"
	item_state = "viceW"

	New()
		..()
		if(prob(50))
			src.icon_state = "viceG"
			src.item_state = "viceG"

/obj/item/clothing/under/misc/atmospheric_technician
	name = "atmospheric technician's jumpsuit"
	desc = "This jumpsuit is comprised of 4% cotton, 96% burn marks."
	icon_state = "atmos"
	item_state = "atmos"

/obj/item/clothing/under/misc/souschef
	name = "sous-chef's uniform"
	desc = "The uniform of an assistant to the Chef. Maybe as translator."
	icon_state = "souschef"
	item_state = "souschef"

/obj/item/clothing/under/misc/itamae
	name = "itamae uniform"
	desc = "A coat and apron worn commonly worn by Japanese Chefs, waiting to be ruined with the blood you'll inevitably cover it in."
	icon_state = "itamae"
	item_state = "itamae"

/obj/item/clothing/under/misc/hydroponics
	name = "senior botanist's jumpsuit"
	desc = "Anyone wearing this has probably grown a LOT of weed in their time."
	icon_state = "hydro-senior"
	item_state = "hydro-senior"

/obj/item/clothing/under/misc/chaplain
	name = "priest's robe"
	desc = "A catholic robe."
	icon_state = "catholic"
	item_state = "catholic"

/obj/item/clothing/under/misc/chaplain/rabbi
	name = "rabbi's jacket"
	desc = "A kosher piece of attire."
	icon_state = "rabbi"
	item_state = "rabbi"

/obj/item/clothing/under/misc/chaplain/muslim
	name = "imam's robe"
	desc = "It radiates the glory of Allah."
	icon_state = "muslim"
	item_state = "muslim"

/obj/item/clothing/under/misc/chaplain/buddhist
	name = "buddhist robe"
	desc = "That's a pretty sweet robe there."
	icon_state = "buddhist"
	item_state = "buddhist"

/obj/item/clothing/under/misc/chaplain/rasta
	name = "rastafarian's shirt"
	desc = "It's red, yellow and green. The colors of the Ethiopian national flag."
	icon_state = "rasta"
	item_state = "rasta"

/obj/item/clothing/under/misc/chaplain/siropa_robe
	name = "siropa robe"
	desc = "Moderation in all things. Truth, equality, freedom, justice, and karma."
	icon_state = "siropa"
	item_state = "siropa"

/obj/item/clothing/under/misc/chaplain/atheist
	name = "atheist's sweater"
	desc = "A sweater and slacks that defy God."
	icon_state = "atheist"
	item_state = "atheist"

/obj/item/clothing/under/misc/mail
	name = "postmaster's jumpsuit"
	desc = "The crisp threads of a postmaster."
	icon_state = "mail"
	item_state = "mail"

	april_fools
		icon_state = "mail-alt"
		item_state = "mail-alt"

	syndicate
		april_fools  // This pathing is weird and I hate it
			icon_state = "mail-alt"
			item_state = "mail-alt"

/obj/item/clothing/under/misc/lawyer
	name = "lawyer's suit"
	desc = "A rather objectionable piece of clothing."
	icon_state = "lawyerBl"
	item_state = "lawyerBl"

	black
		icon_state = "lawyerB"
		item_state = "lawyerB"

	red
		icon_state = "lawyerR"
		item_state = "lawyerR"

/obj/item/clothing/under/misc/barber
	name = "barber's uniform"
	desc = "The classic attire of a barber."
	icon_state = "barber"
	item_state = "barber"

/obj/item/clothing/under/misc/syndicate
	name = "tactical turtleneck"
	desc = "Non-descript, slightly suspicious civilian clothing."
	icon_state = "syndicate"
	item_state = "syndicate"
	team_num = TEAM_SYNDICATE
	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, SPAN_ALERT("The jumpsuit <b>explodes</b> as you reach out to grab it!"))
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif

/obj/item/clothing/under/misc/turds
	name = "NT combat uniform"
	desc = "A Nanotrasen security jumpsuit."
	icon_state = "turdsuit"
	item_state = "turdsuit"
	team_num = TEAM_NANOTRASEN
	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, SPAN_ALERT("The jumpsuit <b>explodes</b> as you reach out to grab it!"))
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif

/obj/item/clothing/under/misc/prisoner
	name = "prisoner's jumpsuit"
	desc = "Busted."
	icon_state = "prisoner"
	item_state = "prisoner"

/obj/item/clothing/under/misc/tourist
	name = "hawaiian shirt"
	desc = "How gauche."
	icon_state = "tourist"
	item_state = "tourist"

	max_payne
		icon_state = "hawaiian"
		item_state = "hawaiian"

/obj/item/clothing/under/misc/clownfancy
    name = "clown suit"
	desc = "You are likely taking your life into your own hands by wearing this."
	icon_state = "clown-fancy"
	item_state = "clown-fancy"

    New()
		..()
		AddComponent(/datum/component/clown_disbelief_item)

/obj/item/clothing/under/misc/NT
	name = "nanotrasen jumpsuit"
	desc = "Corporate higher-ups get some pretty comfy jumpsuits."
	icon_state = "nt"
	item_state = "nt"

// Scrubs
/obj/item/clothing/under/gimmick/scrub
	name = "medical scrubs"
	desc = "A combination of comfort and utility intended to make removing every last organ someone has and selling them to a space robot much more official looking."
	icon_state = "scrub-w"
	item_state = "white"

	teal
		icon_state = "scrub-t"
		item_state = "aqua"

	maroon
		icon_state = "scrub-m"
		item_state = "darkred"

	blue
		icon_state = "scrub-n"
		item_state = "darkblue"

	purple
		icon_state = "scrub-v"
		item_state = "lightpurple"

	orange
		icon_state = "scrub-o"
		item_state = "orange"

	pink
		icon_state = "scrub-pk"
		item_state = "pink"

	flower
		name = "flower scrubs"
		desc = "Man, these scrubs look pretty nice."
		icon_state = "scrub-f"
		item_state = "lightblue"

/obj/item/clothing/under/gimmick/patient_gown
	name = "gown"
	desc = "A light cloth gown that ties in the back, given to medical patients when undergoing examinations or medical operations."
	icon = 'icons/obj/clothing/jumpsuits/item_js_misc.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuits/hand_js.dmi'
	icon_state = "patient"
	item_state = "lightblue"

/obj/item/clothing/under/misc/serpico
	name = "poncho and shirt"
	desc = "A perfect ensemble for sunny weather."
	icon_state = "serpico"
	item_state = "serpico"

/obj/item/clothing/under/misc/yoga
	name = "\improper T-shirt and yoga pants"
	desc = "A big, comfy T-shirt and some yoga pants that will turn heads."
	icon_state = "yoga"
	item_state = "yoga"

/obj/item/clothing/under/misc/yoga/red
	name = "red T-shirt and yoga pants"
	icon_state = "yoga-r"
	item_state = "yoga-r"

/obj/item/clothing/under/misc/yoga/communist // I dunno, the dude made these sprites and I guess it doesn't hurt to use them? :v
	name = "\improper Red T-shirt and yoga pants"
	icon_state = "yoga-c"
	item_state = "yoga-c"

/obj/item/clothing/under/misc/bandshirt
    var/disturbed = 0
    name = "band shirt"
    desc = "Woah, these guys stopped touring in '37. Vintage!"
    icon_state = "bandshirt"
    item_state = "bandshirt"

/obj/item/clothing/under/misc/bandshirt/attack_hand(mob/user)
	if  ( ..() && !disturbed )
		new /obj/item/clothing/mask/cigarette/dryjoint(get_turf(user))
		boutput(user, "Something falls out of the shirt as you pick it up!")
		disturbed = 1

/obj/item/clothing/under/misc/mobster
    name = "mobster suit"
    desc = "Scream."
    icon_state = "mob1"
    item_state = "mob1"

/obj/item/clothing/under/misc/mobster/alt
    name = "mobster suit"
    desc = "She Swallows Burning Coals."
    icon_state = "mob2"
    item_state = "mob2"

// WALPVRGIS fashion

/obj/item/clothing/under/misc/sfjumpsuitbp
    name = "Black and Purple Sci-Fi Jumpsuit"
    desc = "Wear this to immediately become the ultimate hacker."
    icon_state = "scifi_jump_pb"
    item_state = "scifi_jump_pb"

/obj/item/clothing/under/misc/sfjumpsuitrb
    name = "Black and Red Sci-Fi Jumpsuit"
    desc = "Wear this to immediately become the ultimate hacker."
    icon_state = "scifi_jump_rb"
    item_state = "scifi_jump_rb"

/obj/item/clothing/under/misc/sfjumpsuitpnk
    name = "Pink and Blue Sci-Fi Jumpsuit"
    desc = "Wear this to immediately become the ultimate hacker."
    icon_state = "scifi_jump_pnk"
    item_state = "scifi_jump_pnk"

/obj/item/clothing/under/misc/sfjumpsuitbee
    name = "Bee Sci-Fi Jumpsuit"
    desc = "Wear this to immediately become the ultimate bee hacker."
    icon_state = "scifi_jump_yb"
    item_state = "scifi_jump_yb"

/obj/item/clothing/under/misc/casualjeanswb
    name = "White Shirt and Jeans"
    desc = "Look at those knee tears! You're too cool for school!"
    icon_state = "casual_jeans_wb"
    item_state = "casual_jeans_wb"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansskr
    name = "Red Skull Shirt and Jeans"
    desc = "You're not evil, just misunderstood."
    icon_state = "casual_jeans_skullr"
    item_state = "casual_jeans_skullr"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansskb
    name = "Black Skull Shirt and Jeans"
    desc = "You're not evil, just misunderstood."
    icon_state = "casual_jeans_skullb"
    item_state = "casual_jeans_skullb"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansyel
    name = "Yellow Shirt and Jeans"
    desc = "For when you want to be both a ray of sunshine, and also grunge."
    icon_state = "casual_jeans_yshirt"
    item_state = "casual_jeans_yshirt"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansacid
    name = "Skull Shirt and Acid Wash Jeans"
    desc = "It's 1993 and you're dressed to start your new grunge garage band."
    icon_state = "casual_jeans_skullbshort"
    item_state = "casual_jeans_skullbshort"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansgrey
    name = "Grey Shirt and Jeans"
    desc = "Blend into the crowd while still looking cool."
    icon_state = "casual_jeans_grey"
    item_state = "casual_jeans_grey"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeanspurp
    name = "Purple Shirt and White Jeans"
    desc = "A E S T H E T I C."
    icon_state = "casual_jeans_purp"
    item_state = "casual_jeans_purp"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeansblue
    name = "Blue Shirt and Jeans"
    desc = "You patched up the tears in this pair of jeans because your knees got cold."
    icon_state = "casual_jeans_blue"
    item_state = "casual_jeans_blue"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/casualjeanskhaki
    name = "Khaki Shirt and Jeans"
    desc = "Perfect for adventuring."
    icon_state = "casual_jeans_khaki"
    item_state = "casual_jeans_khaki"
    material_piece = /obj/item/material_piece/cloth/jean

    New()
        . = ..()
        setMaterial(getMaterial("jean"), FALSE, FALSE, TRUE)

/obj/item/clothing/under/misc/racingsuitbee
    name = "Bee Racing Jumpsuit"
    desc = "Sting like a bee... Fly like a bee..."
    icon_state = "racing_jump_yb"
    item_state = "racing_jump_yb"

/obj/item/clothing/under/misc/racingsuitpnk
    name = "Pink and Blue Racing Jumpsuit"
    desc = "Just because you're inside a MiniPutt, doesn't mean you can't still be fashionable."
    icon_state = "racing_jump_pnk"
    item_state = "racing_jump_pnk"

/obj/item/clothing/under/misc/racingsuitrbw
    name = "Blue and White Racing Jumpsuit"
    desc = "You feel like you should wear this while piloting a robot, instead."
    icon_state = "racing_jump_rbw"
    item_state = "racing_jump_rbw"

/obj/item/clothing/under/misc/racingsuitprp
    name = "Purple and Black Racing Jumpsuit"
    desc = "Mysterious, just like you."
    icon_state = "racing_jump_prp"
    item_state = "racing_jump_prp"

	// WALPVRGIS fashion END

/obj/item/clothing/under/misc/club
    name = "club jumpsuit"
    desc = "A suit suit. This suit's suit is a club."
    icon_state = "club"
    item_state = "club"

/obj/item/clothing/under/misc/spade
    name = "spade jumpsuit"
    desc = "A suit suit. This suit's suit is a spade."
    icon_state = "spade"
    item_state = "spade"

/obj/item/clothing/under/misc/heart
    name = "heart jumpsuit"
    desc = "A suit suit. This suit's suit is a heart. D'aww."
    icon_state = "heart"
    item_state = "heart"

/obj/item/clothing/under/misc/diamond
    name = "diamond jumpsuit"
    desc = "A suit suit. This suit's suit is a diamond."
    icon_state = "diamond"
    item_state = "diamond"

/obj/item/clothing/under/misc/flannel
    name = "flannel shirt"
    desc = "Perfect for chopping wood or drinking coffee."
    icon_state = "flannel"
    item_state = "flannel"

/obj/item/clothing/under/misc/fish
    name = "fish shirt"
    desc = "It reads, 'Fish'."
    icon_state = "fish"
    item_state = "fish"

/obj/item/clothing/under/misc/flame_purple
    name = "purple flame shirt"
    desc = "Basic fire colors are so passé."
    icon_state = "flame_purple"
    item_state = "flame_purple"

/obj/item/clothing/under/misc/flame_rainbow
    name = "rainbow flame shirt"
    desc = "Monochromatic fire colors are so démodé."
    icon_state = "flame_rainbow"
    item_state = "flame_rainbow"

/obj/item/clothing/under/misc/bubble
    name = "bubble shirt"
    desc = "Soothing bubbles for a calm shirt."
    icon_state = "bubble"
    item_state = "bubble"

/obj/item/clothing/under/misc/tech_shirt
    name = "tech shirt"
    desc = "A shirt with a fancy, vaguely sci-fi pattern on it."
    icon_state = "tech_shirt"
    item_state = "tech_shirt"

/obj/item/clothing/under/misc/chaplain/nun
	name = "nun robe"
	desc = "A long, black robe, traditonally worn by nuns. Ruler not included."
	icon_state = "nun_robe"
	item_state = "nun_robe"

//Crate Loot
/obj/item/clothing/under/misc/tiedye
    name = "tiedye shirt"
    desc = "Featuring a pretty inky pattern."
    icon_state = "tiedye"
    item_state = "tiedye"

/obj/item/clothing/under/misc/neapolitan
    name = "neapolitan shirt"
    desc = "Like the icecream, not made in Naples."
    icon_state = "neapolitan"
    item_state = "neapolitan"

/obj/item/clothing/under/misc/mint_chip
    name = "mint chip shirt"
    desc = "A shirt imbued with the color scheme of the scientifically best icecream flavor."
    icon_state = "mint_chip"
    item_state = "mint_chip"

/obj/item/clothing/under/misc/rarestroom
	name = "'I found the rarest room and all I got was this lousy t-shirt.' t-shirt"
	desc = "You did it, but for what?"
	icon_state = "rarest"
	item_state = "rarest"
