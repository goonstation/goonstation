var/const/BLOCK_LAYER = 10 // TODO layer what the fuck is this shit

proc/get_dir2(var/atom/toObj, var/atom/fromObj)
	if(fromObj.x > toObj.x && fromObj.y > toObj.y)
		return NORTHEAST
	else if(fromObj.x > toObj.x && fromObj.y == toObj.y)
		return EAST
	else if(fromObj.x > toObj.x && fromObj.y < toObj.y)
		return SOUTHEAST
	else if(fromObj.x == toObj.x && fromObj.y > toObj.y)
		return NORTH
	else if(fromObj.x == toObj.x && fromObj.y < toObj.y)
		return SOUTH
	else if(fromObj.x < toObj.x && fromObj.y > toObj.y)
		return NORTHWEST
	else if(fromObj.x < toObj.x && fromObj.y < toObj.y)
		return SOUTHWEST
	else if(fromObj.x < toObj.x && fromObj.y == toObj.y)
		return WEST
/*
obj/onewaymirror
	icon = 'icons/obj/window.dmi'
	icon_state = "onewaymirror"
	density = 1
	opacity = 0
	anchored = 1
	name = "One-way Mirror"
	desc = "Nifty!"
	layer = 11

mob/Move()
        . = ..()
        if(client && .) client.UpdateViewFilter()

turf
    var/image/viewblock

    New()
        ..()
        viewblock = image('icons/misc/old_or_unused.dmi',src,"black",BLOCK_LAYER)

client
    var/list
        ViewFilter = list()
        SeenTurfs = list()

    New()
        ..()
        SeenTurfs = list()

    proc/UpdateViewFilter()
        var
            Image
            list
                newimages = list()
                v = view(world.view,mob)
                onewaylist = list()

        for(var/obj/onewaymirror/M in v)
            if(M.dir & get_dir2(M,mob))
                M.opacity = 1
                onewaylist += M

        if(onewaylist.len)
            var/list/List = v - view(world.view,mob)
            for(var/turf/T in List)
                src << T.viewblock
                newimages += T.viewblock

            for(var/obj/onewaymirror/M in onewaylist)
                M.opacity = 0

        for(Image in ViewFilter-newimages)
            images -= Image
        ViewFilter = newimages
*/
