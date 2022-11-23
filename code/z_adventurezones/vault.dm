// nerd_trap_door vault

// map blueprints
/obj/item/paper/blueprint
	name = "Blueprint"
	desc = "A blueprint showing detailed plans regarding the construction of a space station."
	icon_state = "blueprint"
	item_state = "sheet"

	mushroom
		name = "Mushroom Station Blueprint"
		desc = "A blueprint showing detailed plans regarding the construction of a plump, bulbous space station."

	donut2
		name = "Donut 2 Blueprint"
		desc = "A blueprint showing detailed plans regarding the construction of a circular space station."

	cog1
		name = "Cogmap 1 Blueprint"
		desc = "A blueprint showing detailed plans regarding the construction of a flagship space station."

	cog2
		name = "Cogmap 2 Blueprint"
		desc = "A blueprint showing detailed plans regarding the construction of a vast, modern space station."

	destiny
		name = "NSS Destiny Blueprint"
		desc = "A blueprint showing detailed plans regarding the construction of a compact space ship."

	clarion
		name = "NSS Clarion Blueprint"
		desc = "A blueprint showing detailed plans regarding the construction of a robust space ship."

	horizon
		name = "NSS Horizon Blueprint"
		desc = "A blueprint showing detailed plans regarding the construction of an extremely long space ship. Why is it so long?!?"

	sealab
		name = "Messy Blueprint"
		desc = "A blueprint showing detailed plans regarding the construction of some kind of structure. The page is too ink-stained to comprehend."

	chart

		pasiphae
			name = "damaged chart"
			sizex = 533
			sizey = 450
			desc = "Some sort of complex chart. It's strangely degraded, as though the ink boiled out of the paper, and you can't make much out - how was this damaged?"
			New()
				..()
				info = "<html><body><style>img {width: 100%; height: auto;}></style><img src='[resource("images/charts/damaged_report.png")]'></body></html>"

		system
			name = "Atlas Survey Mission chart X0"
			desc = "A chart of nearby moons and Nanotrasen assets around . Not to scale."
			sizex = 1033
			sizey = 724

			New()
				..()
				pixel_x = rand(-8, 8)
				pixel_y = rand(-8, 8)
				info = "<html><body style='margin:0px'><img src='[resource("images/charts/AtlasSurvey_PlasmaGiant.png")]'></body></html>"

			examine()
				return ..()

			attackby()
				return



/obj/decal/vault/gold_nerd_statue
	name = "Gold Statue of Daniella Yae Amaryllis"
	desc = "A very fancy statue of somebody who probably caused a very fancy explosion"
	opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/misc/Readstuff.dmi'
	icon_state = "goldnerd"

/obj/decal/vault/dead_syndie
	name = "corpse"
	desc = "This guy is wearing syndicate gear. What are they doing here?"
	opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/misc/Readstuff.dmi'
	icon_state = "deadsyndie"
