//http://www.byond.com/forum/?post=2081875
//CANT NULL OUT THE NAME OR IT WONT OVERRIDE. SET TO ??? AND SOMEHOW DISABLE THE EXAMINE VERB IF THEY CANT SEE IT?
/atom/var/image/hiddenImage = null
/atom/var/list/hiddenFrom = null

/atom/proc/hideFrom(var/client/C)
	if(C == null) return

	if(src.hiddenImage == null)
		var/image/I = image('icons/effects/effects.dmi', src, "nothing")
		I.name = "???"
		I.override = 1
		src.hiddenImage = I

	if(hiddenFrom == null)
		hiddenFrom = list()

	hiddenFrom.Add(C)
	C.images += src.hiddenImage
	return

/atom/proc/showTo(var/client/C)
	if(C == null) return

	//These both would be bad. It would mean someone was trying to show something that was never hidden.
	if(src.hiddenImage == null)
		return
	if(hiddenFrom == null)
		return

	hiddenFrom.Remove(C)
	C.images -= src.hiddenImage
	return

/*
//DO NOT COMMIT ME WITHOUT COMMENTING ME OUT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
/atom
	verb/hidea()
		set src in view()
		src.hideFrom(usr.client)
		return
	verb/showa()
		set src in view()
		src.showTo(usr.client)
		return
//DONT DO IT//
*/
