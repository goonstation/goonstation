/obj/item/paper/image
	/// A path to an image resource
	var/path = null
	/// Should the UI attempt to scale the image up or down? 0 = pixel perfect display.
	var/scale_dir = 0
	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ResourceImage")
			ui.open()

	ui_static_data(mob/user)
		return list(
			"title" = src.name,
			"path" = src.path,
			"scale_dir" = src.scale_dir,
			"fixed_size" = list(
				"width" = src.sizex,
				"height" = src.sizey
			)
		)

/obj/item/paper/image/xg_tapes
	name = "XIANG|GIESEL Onboarding Course"
	desc = "A cover sheet meant to accompany a set of corporate training materials."
	icon_state = "paper_burned"
	sizex = 718
	sizey = 1023
	path = "images/arts/xg_tapes.png"

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)

/obj/item/paper/image/hair_fall
	name = "hairstyle flyer"
	icon_state = "hair_fall"
	desc = "The latest frontier hairstyle fashion for fall 2053."
	sizex = 1213
	sizey = 762
	path = "images/arts/hairstyles_fall.png"

/obj/item/paper/image/postcard/mushroom
	name = "Mushroom Station postcard"
	desc = "Just four pals hangin' out havin' a good time. Looks like they're welded into the bathroom? Why?!"
	icon_state = "postcard-mushroom"
	sizex = 174
	sizey = 247
	path = "images/arts/mushroom_station.png"

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)

/obj/item/paper/image/botany_guide
	name = "Botany Field Guide"
	desc = "Some kinda informative poster. Or is it a pamphlet? Either way, it wants to teach you things. About plants."
	icon_state = "botany_guide"
	sizex = 965
	sizey = 682
	scrollbar = FALSE
	path = "images/pocket_guides/botanyguide.png"

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)

/obj/item/paper/image/ranch_guide
	name = "Ranch Field Guide"
	desc = "Some kinda informative poster. Or is it a pamphlet? Either way, it wants to teach you things. About chickens."
	icon_state = "ranch_guide"
	sizex = 1100
	sizey = 800
	scrollbar = FALSE
	path = "images/pocket_guides/ranchguide.png"
	scale_dir = -1

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)

/obj/item/paper/image/siphon_guide
	name = "Harmonic Siphon Brief"
	desc = "A very official-looking sheet full of information you may or may not be able to wrap your head around."
	icon_state = "postcard-owlery"
	sizex = 1192
	sizey = 600
	scrollbar = FALSE
	path = "images/pocket_guides/siphonguide.png"

// cogwerks - creepy picture things

/obj/item/paper/image/sstv
	name = "Printed Image"
	desc = "Fancy."
	icon_state = "paper"
	path = "images/sstv/1.png"
	scale_dir = 1
	sizex = 640
	sizey = 480

	satellite
		path = "images/sstv/2.png"
		desc = "Looks like a satellite view of a research base."

	group1
		path = "images/sstv/3.png"
		desc = "A group photo of a research team."

	group2
		path = "images/sstv/4.png"
		desc = "A group photo of a research team."

	group3
		path = "images/sstv/6.png"
		desc = "A group of scientists working in a lab."

	researcher1
		path = "images/sstv/5.png"
		desc = "A scientist handling what looks like an ice core."

	researcher2
		path = "images/sstv/9.png"
		desc = "The image is badly distorted, but it seems to be a researcher carrying a lab monkey."

	slide1
		path = "images/sstv/7.png"
		desc = "A microscopic slide. Seems to be some sort of biological cell structure."

	slide2
		path = "images/sstv/8.png"
		desc = "A dissection report of some kind of arachnid."

	slide3
		path = "images/sstv/10.png"
		desc = "A dissection report of... something. What the hell is that?"

	emerg1
		path = "images/sstv/11.png"
		desc = "A coded emergency broadcast."

	crewlog1
		path = "images/sstv/12.png"
		desc = "A blurry image of something approaching the photographer."

	crewlog2
		path = "images/sstv/13.png"
		desc = "Oh god."
