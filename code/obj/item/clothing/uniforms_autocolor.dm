//ISaidNo and his Amazing AutoColor Jumpsuit
/*
/obj/item/clothing/under/autocolor
	name = "black jumpsuit"
	desc = "Standard issue Nanotrasen uniforms. Easy to dye and one size fits all."
	icon_state = "plain"
	overlaid = 1
	// exceeding 200 on any of these vars tends to result in a garish mess, so yeah try not to do that
	var/base_r = 0
	var/base_g = 0
	var/base_b = 0
	var/detail_r = 0
	var/detail_g = 0
	var/detail_b = 0

	proc/autojump_updateworldicon()
		if (src.overlaid)
			var/icon/coloroverlay1 = icon("icon" = 'icons/obj/clothing/uniforms/item_js.dmi', "icon_state" = text("[]-fx1", src.icon_state))
			coloroverlay1.Blend(rgb(src.base_r, src.base_g, src.base_b), ICON_ADD)
			src.overlays += image("icon" = coloroverlay1)
			if (src.overlaid >= 2)
				var/icon/coloroverlay2 = icon("icon" = 'icons/obj/clothing/uniforms/item_js.dmi', "icon_state" = text("[]-fx2", src.icon_state))
				coloroverlay2.Blend(rgb(src.detail_r, src.detail_g, src.detail_b), ICON_ADD)
				src.overlays += image("icon" = coloroverlay2)

	New()
		..()
		src.autojump_updateworldicon()

	attack_hand(var/mob/user)
		..()
		src.autojump_updateworldicon()

	dropped(mob/user as mob)
		..()
		src.autojump_updateworldicon()

/obj/item/clothing/under/autocolor/stripe
	name = "striped jumpsuit"
	icon_state = "stripe"
	overlaid = 2

/obj/item/clothing/under/autocolor/jacket
	name = "jacket jumpsuit"
	icon_state = "qm"
	overlaid = 2

/obj/item/clothing/under/autocolor/science
	name = "laboratory jumpsuit"
	icon_state = "sci"
	overlaid = 2
	base_r = 180
	base_g = 180
	base_b = 180

/obj/item/clothing/under/autocolor/red
	name = "red jumpsuit"
	base_r = 180

/obj/item/clothing/under/autocolor/orange
	name = "orange jumpsuit"
	base_r = 180
	base_g = 80

/obj/item/clothing/under/autocolor/yellow
	name = "yellow jumpsuit"
	base_r = 180
	base_g = 180

/obj/item/clothing/under/autocolor/green
	name = "green jumpsuit"
	base_g = 180

/obj/item/clothing/under/autocolor/cyan
	name = "cyan jumpsuit"
	base_g = 180
	base_b = 180

/obj/item/clothing/under/autocolor/blue
	name = "blue jumpsuit"
	base_g = 80
	base_b = 180

/obj/item/clothing/under/autocolor/indigo
	name = "indigo jumpsuit"
	base_b = 180

/obj/item/clothing/under/autocolor/purple
	name = "purple jumpsuit"
	base_b = 180
	base_r = 80

/obj/item/clothing/under/autocolor/magenta
	name = "magenta jumpsuit"
	base_r = 180
	base_b = 180

/obj/item/clothing/under/autocolor/white
	name = "white jumpsuit"
	base_r = 180
	base_g = 180
	base_b = 180

/obj/item/clothing/under/autocolor/grey
	name = "grey jumpsuit"
	base_r = 100
	base_g = 100
	base_b = 100

/obj/item/clothing/under/autocolor/random
	name = "strange jumpsuit"
	desc = "The fuck kinda color is this?"
	New()
		base_r = rand(0,190)
		base_g = rand(0,190)
		base_b = rand(0,190)
		..()

/obj/item/clothing/under/autocolor/stripe/engineer
	name = "engineer's jumpsuit"
	base_r = 180
	base_g = 150
	detail_r = 160
	detail_g = 70

/obj/item/clothing/under/autocolor/stripe/mechanic
	name = "mechanic's jumpsuit"
	base_r = 180
	base_g = 150
	detail_b = 160
	detail_g = 70

/obj/item/clothing/under/autocolor/stripe/atmos
	name = "atmospheric technician's jumpsuit"
	base_r = 180
	base_g = 150
	detail_b = 180
	detail_g = 180

/obj/item/clothing/under/autocolor/stripe/techassist
	name = "technical assistant's jumpsuit"
	base_r = 100
	base_g = 100
	base_b = 100
	detail_r = 180
	detail_g = 150

/obj/item/clothing/under/autocolor/stripe/miner
	name = "miner's jumpsuit"
	base_r = 180
	base_g = 150

/obj/item/clothing/under/autocolor/stripe/botanist
	name = "botanist's jumpsuit"
	base_r = 140
	base_g = 70
	base_b = 40
	detail_g = 150

/obj/item/clothing/under/autocolor/stripe/random
	name = "strange jumpsuit"
	desc = "Who the hell dyed this thing? A blind clown?"
	New()
		base_r = rand(0,190)
		base_g = rand(0,190)
		base_b = rand(0,190)
		detail_r = rand(0,190)
		detail_g = rand(0,190)
		detail_b = rand(0,190)
		..()

/obj/item/clothing/under/autocolor/jacket/qm
	name = "quartermaster's jumpsuit"
	base_r = 140
	base_g = 140
	base_b = 140
	detail_r = 170
	detail_g = 120

/obj/item/clothing/under/autocolor/jacket/janitor
	name = "janitor's jumpsuit"
	base_r = 140
	base_g = 140
	base_b = 140
	detail_r = 80
	detail_b = 80

/obj/item/clothing/under/autocolor/jacket/security
	name = "security officer's jumpsuit"
	base_r = 100
	detail_r = 180

/obj/item/clothing/under/autocolor/jacket/forensics
	name = "forensic technician's jumpsuit"
	base_r = 140
	base_g = 140
	base_b = 140
	detail_r = 140

/obj/item/clothing/under/autocolor/jacket/random
	name = "strange jumpsuit"
	desc = "It's like Cthulhu took a shit on a rainbow. Jesus christ."
	New()
		base_r = rand(0,190)
		base_g = rand(0,190)
		base_b = rand(0,190)
		detail_r = rand(0,190)
		detail_g = rand(0,190)
		detail_b = rand(0,190)
		..()

/obj/item/clothing/under/autocolor/science/medic
	name = "medical doctor's jumpsuit"
	detail_r = 180

/obj/item/clothing/under/autocolor/science/genetics
	name = "geneticist's jumpsuit"
	detail_b = 160
	detail_g = 80

/obj/item/clothing/under/autocolor/science/scientist
	name = "scientist's jumpsuit"
	detail_r = 140
	detail_b = 140

/obj/item/clothing/under/autocolor/science/chemist
	name = "chemist's jumpsuit"
	detail_b = 130

/obj/item/clothing/under/autocolor/science/robotics
	name = "roboticist's jumpsuit"
	base_r = 0
	base_g = 0
	base_b = 0
	detail_r = 180

/obj/item/clothing/under/autocolor/science/medassist
	name = "medical assistant's jumpsuit"
	base_r = 100
	base_g = 100
	base_b = 100
	detail_r = 180

/obj/item/clothing/under/autocolor/science/hos
	name = "head of security's jumpsuit"
	base_r = 180
	base_g = 0
	base_b = 0
	detail_r = 180
	detail_g = 160
	detail_b = 0

/obj/item/clothing/under/autocolor/science/random
	name = "strange jumpsuit"
	desc = "Ah, the methodology of throwing random paint at a jumpsuit."
	New()
		base_r = rand(0,190)
		base_g = rand(0,190)
		base_b = rand(0,190)
		detail_r = rand(0,190)
		detail_g = rand(0,190)
		detail_b = rand(0,190)
		..()

/// END OF AUTOCOLOR JUMPSUITS
*/
