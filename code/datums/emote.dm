// heavily rewritten by cirr, with base code by somepotato
// FUCK YOUR MOODLETS AND MOODIES, WE HAVE FUCKING EMOOTS
// YEEEEAAAAAAHH

// <Somepotato>	although the caching mechanism needs to be improved
// <Somepotato>	like emote subtypes should be more specific
// <Somepotato>	and the emotes type should be a list of types
// <Somepotato>	it was just a prototype that worked and i thought was nifty

/datum/emoot

/datum/emoot/proc/process_return( var/mob/M, var/ret )
	if(istext( ret ))
		M.visible_message( "<b>[M]</b> [ret]" )
	else if(ret)
		var/list/r = ret
		if(!istype(r)) return
		var/list/rsound = r["sound"]
		if(istype(rsound))
			playsound( get_turf(M), pick(rsound), 60, 1 )
		else if(isfile(rsound))
			playsound( get_turf(M), rsound, 60, 1 )
		else if(istext(rsound) && M.vars[rsound])
			playsound( get_turf(M), M[rsound], 60, 1 )
		var/list/msg = r["message"]
		if(istype(msg))
			M.visible_message( "<b>[M]</b> [pick(msg)]" )
		else if(istext(msg))
			M.visible_message( "<b>[M]</b> [msg]" )

/datum/emoot/proc/emote( var/mob/M, var/text )
	var/space = findtext( text, " " )
	var/emoot = space ? copytext( text, 1, space - 1 ) : text
	var/argstr = space ? copytext( text, space ) : ""

	var/hc = hascall( src, "emote_[emoot]" )
	if( !hc && !src.vars["emote_[emoot]"] )
		M.show_message( "<span class='alert'>Unknown emote [emoot], try using *list for a basic list of emotes.</span>")
		return

	var/on = lowertext(argstr)
	var/tgt = null
	if( argstr )
		for(var/mob/other in oview( (M.client ? M.client.view : 7), 7 ))
			var/tn = lowertext(other.name)
			if(findtext( on, tn ) || findtext( tn, on ))
				tgt = other
				break

	if( hc )
		process_return(M, call( src, "emote_[emoot]" )( M, argstr, tgt ))
	else
		process_return( M, src["emote_[emoot]"] )

/datum/emoot/proc/emote_wave(var/mob/M, var/argstr, var/mob/T)
	if(T)
		return "waves at [T]!"
	else
		return 0


/datum/emoot/carbon

/datum/emoot/carbon/proc/emote_slap(var/mob/M, var/argstr, var/mob/T)
	if(T && BOUNDS_DIST(M, T) == 0)
		//random_brute_damage( M, 3 )
		return "slaps [T]! Rude!"
	else
		//random_brute_damage( M, 10 )
		return "slaps themself! Oh god!"


var/list/emotecache = list()
/mob/var/list/emotes = list()
/mob/New()
	if(islist( emotes ))
		if( emotecache[emotes] )
			emotes = emotecache[emotes]
		else
			emotecache[emotes] = new src.emotes
			emotes = emotecache[emotes]
