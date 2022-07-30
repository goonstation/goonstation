/datum/adventure_submode/emitter
	name = "Invisible Light Emitter"
	var/r = 0
	var/g = 0
	var/b = 0
	var/l = 5

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (ctrl && istype(object, /obj/adventurepuzzle/triggerable/light))
			object:toggle()
			return
		var/obj/adventurepuzzle/triggerable/light/L = new(get_turf(object))
		L.on_brig = l
		L.on_cred = r
		L.on_cgreen = g
		L.on_cblue = b
		L.light.set_color(r,g,b)
		L.light.set_brightness(l)
		L.on()
		L.set_dir(holder.dir)
		L.onVarChanged("dir", SOUTH, L.dir)
		blink(L.loc)
		L.setup_light()

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (istype(object, /obj/adventurepuzzle/triggerable/light))
			blink(get_turf(object))
			qdel(object)

	selected()
		var/kind = input(usr, "What color of light?", "Light color", "#ffffff") as color
		r = hex2num(copytext(kind, 2, 4)) / 255
		g = hex2num(copytext(kind, 4, 6)) / 255
		b = hex2num(copytext(kind, 6, 8)) / 255
		l = input(usr, "Luminosity?", "Luminosity", 1) as num
		boutput(usr, "<span class='notice'>Now placing light emitters ([r],[g],[b]:[l]) in single spawn mode. Ctrl+click to toggle light on/off state.</span>")

	settings(var/ctrl, var/alt, var/shift)
		selected()
