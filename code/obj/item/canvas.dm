// Canvases/paintings.
// Feature idea stolen from bee.
//
//   PROGRAMMING TOTALLY ORIGINAL
//     UNAUTHORIZED DUPLICATION
//            PROHIBITED


// most of the initial values are cribbed from paper.
// this is like paper but it isn't. i don't want to inherit all the baggage paper has
// like folding, hats, etc. just some of the stuff it has for ease of use's sake.

/obj/item/canvas
	name = "canvas"
	desc = "A fairly big canvas for wowing the station with your artistic talent. Coming soon: Saving!"

	icon = null
	icon_state = null

	var/icon/base = null
	var/icon/art = null
	var/canvas_width = 28
	var/canvas_height = 22
	var/bottom = 0
	var/left = 0
	var/list/artists = list()

	uses_multiple_icon_states = 1
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"

	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 15
	layer = OBJ_LAYER

	burn_point = 220
	burn_output = 900
	burn_possible = 2
	health = 10

	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0


	New()
		..()

		base = icon('icons/obj/canvas.dmi', icon_state = "[canvas_width]x[canvas_height]_base")
		art = icon('icons/obj/canvas.dmi', icon_state = "[canvas_width]x[canvas_height]_blank")

		underlays += base
		icon = art

		left = round((32 - canvas_width) / 2)
		bottom = round((32 - canvas_height) / 2)

	examine(mob/user)
		. = ..()
		icon = art
		pop_open_a_browser_box(user)


	attackby(obj/item/W as obj, mob/user as mob)
		if (!W || !user)
			return

		if (istype(W, /obj/item/paint_can))
			// flood-fill the entire image
			// TODO: This should be a proc so you can use the can on the canvas,
			// or click the canvas with the paint can
			var/obj/item/paint_can/P = W
			art.DrawBox(P.paint_color, left + 1, bottom + 1, left + canvas_width, bottom + canvas_height)
			icon = art

			// tracks how many things someone's drawn on it.
			// so you can tell if scrimblo made a cool scene and then dogshit2000 put obscenities on top or whatever.
			artists[ckey(usr.ckey)]++

			playsound(src, "sound/impact_sounds/Slimy_Splat_1.ogg", 40, 1)
			user.visible_message("[user] paints over \the [src] with \the [W].", "You paint over \the [src] with \the [W].")
			logTheThing("station", user, null, "coated [src] in paint: [log_loc(src)]: canvas{\ref[src], -1, -1, [P.paint_color]}")

			// send the damn icon and gently nudge the page into refreshing it
			send_the_damn_icon(usr)
			return


	Topic(href, href_list)
		// stolen from /obj/item/engibox. sorry, tgui.

		if (usr.stat || usr.restrained()) return
		if (!in_interact_range(src, usr)) return

		// check for writing implement...
		// in active hand ...
		var/obj/item/active_item = usr.equipped()

		if (!istype(active_item, /obj/item/pen))
			// you need something to draw with you dope
			boutput(usr, "You need something to draw with!")
			return

		var/obj/item/pen/P = active_item
		var/dot_color = P.font_color


		if (!href_list["x"] || !href_list["y"])
			CRASH("something broke. [json_encode(href_list)]")

		var/x = text2num(href_list["x"]) + 1
		var/y = text2num(href_list["y"]) - 1
		y = 31 - y	// byond is upside down relative to reality

		if (x <= left || y <= bottom || x > (left + canvas_width) || y > (bottom + canvas_height))
			// YOU CAN'T DRAW OFF THE DANG CANVAS LIKE WHAT ARE YOU GONNA PUT THE INK ON
			// THE AIR????
			// FUCK YOU
			return
		art.DrawBox(dot_color, x, y)
		icon = art

		// tracks how many things someone's drawn on it.
		// so you can tell if scrimblo made a cool scene and then dogshit2000 put obscenities on top or whatever.
		artists[ckey(usr.ckey)]++
		logTheThing("station", usr, null, "draws on [src]: [log_loc(src)]: canvas{\ref[src], [x], [y], [dot_color]}")



		// send the damn icon and gently nudge the page into refreshing it
		send_the_damn_icon(usr)
		usr << output("canvas-\ref[src].png", "canvas.browser:updateImage")

	proc/send_the_damn_icon(mob/user)
		user << browse_rsc(base, "canvas-\ref[src]-base.png")
		user << browse_rsc(art, "canvas-\ref[src].png")

	proc/pop_open_a_browser_box(mob/user)
		send_the_damn_icon(user)
		var/mult = 16

		var/dat = {"
<!doctype html>
<html>
<head><meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="pragma" content="no-cache">
<style>
	body {
		background: #666; /* hail satin */
		color: white;
		font-family: Tahoma, sans-serif;
		}
	#container {
		position: relative;
		margin: 2em;
		}
	#inner {
		position: relative;
		width: [32 * mult]px;
		height: [32 * mult]px;
		margin: auto;
		}
	#cursor {
		width: [mult]px;
		height: [mult]px;
		border: 1px solid black;
		position: absolute;
		left: -9001;
		z-index: 99999;
		margin-left: -1px;
		margin-top: -1px;
		}
	img {
		image-rendering: crisp-edges;
		image-rendering: pixelated;
		-ms-interpolation-mode:nearest-neighbor;
		}
	#canvas, #back {
		display: block;
		position: absolute;
		top: 0;
		left: 0;
		rigth: [32 * mult]px;
		bottom: [32 * mult]px;
		width: [32 * mult]px;
		height: [32 * mult]px;
		}
	#back {
		z-index: -1;
		background-color: #977;
		opacity: 0.7;
		}
	#canvas {
		z-index: 1;
		}
</style>
</head>
<body>
<div id="container">
	<div id="inner">
		<img id="back" src="canvas-\ref[src]-base.png">
		<img id="canvas" src="canvas-\ref[src].png" title="snarky comment here">
		<div id="cursor"></div>
	</div>
</div>
<iframe src="about:blank" id="ehjax" style="position: absolute; left: -1000px; width: 1px; height: 1px; display: none;"></iframe>
<script type="text/javascript">
	var canvas = document.getElementById("canvas");
	var cursor = document.getElementById("cursor");
	var ehjax = document.getElementById("ehjax");
	var x = 0
	var y = 0

	cursor.addEventListener("click", function(e) {
		var url = "byond://?\ref[src];x="+ x +";y="+ y;
		ehjax.src = url
	})

	canvas.addEventListener("click", function(e) {
		var url = "byond://?\ref[src];x="+ x +";y="+ y;
		ehjax.src = url
	})
	canvas.addEventListener("mousemove", function(e) {
		var ox = e.offsetX;
		var oy = e.offsetY;
		x = Math.floor(ox / [mult]);
		y = Math.floor(oy / [mult]);
		cursor.style.left = (x * [mult]) + "px"
		cursor.style.top = (y * [mult]) + "px"
	});

	canvasURL = canvas.src
	// this should be requesting from the client's byond instance,
	// not anything server-side, so we can do whatever
	function updateImage(file) {
		canvasURL = file;
		canvas.src = canvasURL + "?" + Math.random() * 999999;
	}
	setInterval(function() {
		canvas.src = canvasURL + "?" + Math.random() * 999999;
	}, 200);

</script>


		"}

		user << browse(dat, "window=canvas;size=900x680")

// the intro at the start of this file is a joke:
// https://www.youtube.com/watch?v=wpNxzJk7xUc#t=42s
// ...and is not to be taken seriously, or as any definition
// of copyright/license or otherwise.
// I didn't look at anything about how bee's worked except
// seeing the ui, sort of.
