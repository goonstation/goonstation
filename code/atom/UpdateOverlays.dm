/*
!! IMPORTANT NOTE !!

If this is used to handle overlays on an atom then all overlay updates on that atom *MUST* be carried out through this proc.
Failure to do so will cause the list the proc uses to keep track of the overlays to desynchronize with the actual overlays, leading to runtime errors and strange behaviour.
(Ex. Removing the head of a human instead of the glasses they are wearing)

!! UNIMPORTANT NOTE !!

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Usage:	UpdateOverlays(var/image/I, var/key, var/force=0, var/retain_cache = 0)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Handles updating existing overlays, removing existing overlays and adding new overlays

I				=	image that you want to add to the atom's overlays (null to clear)
key				=	which "slot" do you want the image to go in
force			=	Don't care if there is an existing image with the same details, update anyway. Can be useful if the image to be added is a composite with several overlays of its own.
retain_cache	=	Does not clear the overlay entry at the same time as clearing the overlay - this retains the image in a retrievable form

Returns 1 on updating an overlay, 0 otherwise

------------------------------------------------------
//Ex.

var/atom/A = new
var/image/ass = image('butt.dmi', "posterior")

A.UpdateOverlays(ass, "hat") 		//Puts the 'ass' image in the slot defined as "hat"
A.UpdateOverlays(ass, "hat") 		//This will check the existing overlay in the "hat" slot and reject the update
ass.icon_state = "hindquarters" 	//Icon state change
A.UpdateOverlays(ass, "hat") 		//This will detect the change and update the overlay accordingly

A.UpdateOverlays(null, "hat")		 //Removes the overlay assigned to the "hat" slot, along with the cached image
//Alt.
A.UpdateOverlays(null, "hat",0,1) 	//Removes the overlay in the "hat" slot, but retains the cached image for retrieval with GetOverlayImage

-------------------------------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Usage:	ClearAllOverlays(var/retain_cache=0)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes all overlays on an atom

retain_cache	=	Does not clear the overlay entry at the same time as clearing the overlay - this retains the image in a retrievable form

Returns 1 if overlays were cleared, null otherwise
------------------------------------------------------
//Ex.

var/atom/A = new
A.ClearOverlays() 	//Removes all overlays on A
A.ClearOverlays(1) //Removes all overlays on A but retains the cached images
------------------------------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Usage:	GetOverlayImage(var/key)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Gets the image stored in cache for the specified overlay slot

key		=	The slot in which the desired image is stored

Returns the specified image, if one exists, null otherwise
------------------------------------------------------
//Ex.
//We have an atom A, having an overlay named "hat"
var/image/I = A.GetOverlayImage("hat") 	//Retrieve the cached image in the hat slot
if(!I) I = image('file', "chapeau") 	//Not in-scope, but as GetOverlayImage can return null it's good practice to ensure you got an image before doing things to the returned value
I.icon_state = "chapeau"				//Change the icon state of it
A.UpdateOverlays(I, "hat")				//Update the overlay with the changes
------------------------------------------------------


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Usage:	SafeGetOverlayImage(var/key, var/image_file as file, var/icon_state as text, var/layer as num|null)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Gets the image stored in cache for the specified overlay slot and sets it's icon_state to the desired one, or creates a new one from the image_file and icon_state

key			=	The slot in which the desired image is stored
image_file	=	The file to create the new image
icon_state	=	The desired icon_state
layer		=	The layer the image should be in

Returns the specified image with modifications according to the input, if one exists, otherwise it creates a new one and returns that
------------------------------------------------------
//Ex.
//We have an atom A, that may or may not have an overlay named "hat"
var/image/I = A.GetOverlayImage("hat", 'obj/item/hats.dmi', "ushanka")
//Retrieve the cached image in the hat slot and sets the icon_state to ushanka or creates a new one using image('obj/item/hats.dmi', "ushanka")
------------------------------------------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Usage:	ClearSpecificOverlays(var/retain_cache=0)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Takes a parameter list of overlay keys, then clears the target overlays. If the first parameter is a number it is used to set the cache.

retain_cache	=	Does not clear the overlay entry at the same time as clearing the overlay - this retains the image in a retrievable form (optional)

Returns a tally of the cleared overlays

------------------------------------------------------
//Ex.

ClearSpecificOverlays("key0", "key1", "key2") 		//Clears the overlays in slots key0, key1 and key2. Does not retain cached images.
ClearSpecificOverlays(0, "key0", "key1", "key2") 	//Same as above
ClearSpecificOverlays(1, "key0", "key1", "key2") 	//Same as above but retains cached images

------------------------------------------------------

*/

#define P_INDEX 1
#define P_IMAGE 2
#define P_ISTATE 3
#define P_ILEN P_ISTATE // maximum index

/atom/var/list/overlay_refs = null

/atom/proc/UpdateOverlays(var/image/I, var/key, var/force=0, var/retain_cache = 0)
	if(!key)
		CRASH("UpdateOverlays called without a key.")
	if (!src.overlay_refs)
		src.overlay_refs = list()

	var/list/prev_data
	//List to store info about the last state of the icon
	prev_data = overlay_refs[key]
	if(!prev_data && I) //Ok, we don't have previous data, but we will add an overlay
		prev_data = new /list(P_ILEN)
	else if(!prev_data) //We don't have data and we won't add an overlay
		return 0

	var/hash = I ? "\ref[I.appearance]" : null
	var/image/prev_overlay = prev_data[P_IMAGE] //overlay_refs[key]
	if(!force && (prev_overlay == I) && hash == prev_data[P_ISTATE] ) //If it's the same image as the other one and the appearances match then do not update
		return 0

	var/index = prev_data[P_INDEX]
	if(index > 0) //There is an existing overlay in place in this slot, remove it
		if(index <= src.overlays.len)
			src.overlays.Cut(index, index+1) //Fuck yoooou byond (this gotta be by index or it'll fail if the same thing's in overlays several times)
		else
			stack_trace("Overlays on [src.type] were modified by non-UpdateOverlays method. Ref: \ref[src]")

		prev_data[P_INDEX] = 0
		for(var/ikey in overlay_refs) //Because we're storing the position of each overlay in the list we need to shift our indices down to stay synched
			var/list/L = overlay_refs[ikey]
			if(L?.len > 0 && L[P_INDEX] >= index) L[P_INDEX]--

	if(I)
		src.overlays += I
		index = length(src.overlays)
		prev_data[P_INDEX] = index

		prev_data[P_IMAGE] = I
		prev_data[P_ISTATE] = "\ref[I.appearance]"

		overlay_refs[key] = prev_data
	else
		if(retain_cache) //Keep the cached image available?
			prev_data[P_INDEX] = 0	//Clear the index
			prev_data[P_ISTATE] = 0	//Clear the ref
		else
			overlay_refs -= key
	return 1

/atom/proc/ClearAllOverlays(retain_cache = FALSE) //Some men just want to watch the world burn
	if(length(src.overlays))
		if (!src.overlay_refs)
			src.overlay_refs = list()
		src.overlays.Cut()
		if(retain_cache)
			for(var/key in src.overlay_refs)
				var/list/pd = overlay_refs[key]
				pd[P_INDEX] = 0
				pd[P_ISTATE] = 0
				overlay_refs[key] = pd
		else
			src.overlay_refs.Cut()
		return 1

/atom/proc/ClearSpecificOverlays(var/retain_cache=0)
	var/tally = 0
	var/keep_cache = isnum(retain_cache) && retain_cache //Maybe someone forgets to include this argument and goes straight for the list, let's handle that case
	for(var/key in args)
		if(istext(key)) //The retain_cache value will be here as well, so skip it
			tally += src.UpdateOverlays(null, key, 0, keep_cache)
	return tally


/atom/proc/GetOverlayImage(var/key)
	RETURN_TYPE(/image)
	if (!src.overlay_refs)
		src.overlay_refs = list()
	//Never rely on this proc returning an image.
	var/list/ov_data = overlay_refs[key]

	if(ov_data)
		. = ov_data[P_IMAGE]
	else
		. = null

/atom/proc/SafeGetOverlayImage(var/key, var/image_file as file, var/icon_state as text, var/layer as num|null, var/pixel_x as num|null, var/pixel_y as num|null)
	var/image/I = GetOverlayImage(key)
	if(!I)
		I = image(image_file, icon_state, layer, pixel_x = pixel_x, pixel_y = pixel_y)
	else
		//Ok, apparently modifying anything pertaining to the image appearance causes a hubbub, thanks byand
		if(I.icon != image_file)
			I.icon = image_file

		if(icon_state != I.icon_state)
			I.icon_state = icon_state

		if(layer && layer != I.layer)
			I.layer = layer
		if(pixel_x && pixel_x != I.pixel_x)
			I.pixel_x = pixel_x
		if(pixel_y && pixel_y != I.pixel_y)
			I.pixel_y = pixel_y
	return I


#undef P_INDEX
#undef P_IMAGE
#undef P_ISTATE
#undef P_ILEN
