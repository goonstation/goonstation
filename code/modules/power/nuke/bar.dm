/* N A M I N G  T A X O N O M Y */

datum
	nuke_name
		var/tokens[5]
		var/descriptors[5]
		var/vdescr[5]
		var/upper = 0
		var/lower = 0

		proc/get_token(var/val)
			var/incr = (src.upper - src.lower) / 5

			if(val <= incr)
				return src.tokens[1]
			else if(val <= incr * 2)
				return src.tokens[2]
			else if(val <= incr * 3)
				return src.tokens[3]
			else if(val <= incr * 4)
				return src.tokens[4]
			return src.tokens[5]

		proc/get_descr(var/val)
			var/incr = (src.upper - src.lower) / 5

			if(val <= incr)
				return src.descriptors[1]
			else if(val <= incr * 2)
				return src.descriptors[2]
			else if(val <= incr * 3)
				return src.descriptors[3]
			else if(val <= incr * 4)
				return src.descriptors[4]
			return src.descriptors[5]

		proc/get_vdescr(var/val)
			var/incr = (src.upper - src.lower) / 5

			if(val <= incr)
				return src.vdescr[1]
			else if(val <= incr * 2)
				return src.vdescr[2]
			else if(val <= incr * 3)
				return src.vdescr[3]
			else if(val <= incr * 4)
				return src.vdescr[4]
			return src.vdescr[5]

			epv
				upper = 450
				lower = 0
				tokens[1] = "pisslo"
				tokens[2] = "staleini"
				tokens[3] = "neutro"
				tokens[4] = "insana"
				tokens[5] = "kremli"

				descriptors[1] = "Black Body"
				descriptors[2] = "Hazy"
				descriptors[3] = "Glowing"
				descriptors[4] = "Degenerate Matter"
				descriptors[5] = "Quasar-like"

				vdescr[1] = "This sample isn't even radioactive, what gives?"
				vdescr[2] = "This sample is barely radiating particles, I could probably hold this safely."
				vdescr[3] = "This sample is definitely radioactive."
				vdescr[4] = "This sample is rapidly decomposing."
				vdescr[5] = "This sample is terrifying and shouldn't even exist outside of a neutron star."

			hpe
				upper = 400
				lower = 0
				tokens[1] = "nucks"
				tokens[2] = "niocreum"
				tokens[3] = "num"
				tokens[4] = "nite"
				tokens[5] = "ninium"

				descriptors[1] = "Tepid"
				descriptors[2] = "Lukewarm"
				descriptors[3] = "Sizzling"
				descriptors[4] = "Searing"
				descriptors[5] = "Plasma-inducing"

				vdescr[1] = "This sample is about as energetic as wet matches, if even that. Ugh."
				vdescr[2] = "This sample gives off a bit of heat when exposed to radiation."
				vdescr[3] = "This sample has average thermogenic properties."
				vdescr[4] = "This sample puts out an unsettlingly large amount of heat when placed near radioactive materials."
				vdescr[5] = "This sample could vaporize the ocean if placed within 10 feet of a microwave oven. I should probably be careful with this."

			absorb
				upper = 1
				lower = 0
				tokens[1] = "mono-"
				tokens[2] = "di-"
				tokens[3] = "tri-"
				tokens[4] = "tetra-"
				tokens[5] = "penta-"

				descriptors[1] = "Mirrorlike"
				descriptors[2] = "Repulsive"
				descriptors[3] = "Permeable"
				descriptors[4] = "Easily Pregnable"
				descriptors[5] = "Black Hole"

				vdescr[1] = "This sample lets everything pass through it without effect."
				vdescr[2] = "This sample captures incoming particles about as well as a sieve holds water."
				vdescr[3] = "This sample absorbs radiation roughly half the time."
				vdescr[4] = "This sample sucks up particles like a hoover."
				vdescr[5] = "This sample absorbs so much emissions we should build the reactor casing out of it."


			k_factor
				upper = 20
				lower = 1
				tokens[1] = " 69"
				tokens[2] = " 99"
				tokens[3] = " 117"
				tokens[4] = " 238"
				tokens[5] = " 333"

				descriptors[1] = "Mundanely unreactive"
				descriptors[2] = "Impotent"
				descriptors[3] = "Sensitive"
				descriptors[4] = "Uncomfortably Susceptive"
				descriptors[5] = "Weapons Grade"

				vdescr[1] = "This sample is remarkably non-volatile and unreactive."
				vdescr[2] = "This sample might be able to barely sustain a fission reaction."
				vdescr[3] = "This sample is a basic fissile material suitable for use as fuel in the reactor."
				vdescr[4] = "This sample is highly enriched and exceedingly volatile: it would be hard to control in the reactor."
				vdescr[5] = "This sample violates the Geneva Convention and possessing it is probably a crime against humanity. It is a gnat's fart away from vaporizing the whole station."



/obj/item/material_piece/nuke_bar
	name = "wtf bug show this to kremlin" /* names are auto generated */
	desc = "A bar of fissile material suitable for use in the fabrication of nuclear fuel rods."
	icon = 'icons/obj/materials.dmi'
	icon_state = "bar"
	color = null
	var/nuke_quality = -1

