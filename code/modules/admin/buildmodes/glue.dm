//TODO: see if I can get pixel coords from the click in here. somehow. would be prettier
/datum/buildmode/glue
	name = "Glue"
	desc = {"**************************************************************<br>
Right Click on obj/mob	  	  	   	   - Select single thing to glue (empties to-glue list)<br>
Ctrl + Right Click on obj/mob		   - Add thing to to-glue list<br>
Left Click on turf/obj/mob 			   - Glue all things in list to turf/obj/mob<br>
Right Click on Buildmode Button 	   - Select time before falling off, in seconds (default is -1, infinite duration)<br>
Ctrl + Right Click on Buildmode Button - Set time for people to pull the glued thing off, in seconds (default is 5 seconds, -1 is infinite duration)<br>
**************************************************************"}
	icon_state = "glue"
	var/stick_timer = -1 //seconds
	var/remove_timer = 5 //seconds
	var/list/atom/movable/to_glue = list() //heh. to-glue list. heh

	click_mode_right(ctrl, alt, shift)
		if (ctrl)
			src.remove_timer = input("How long should it take to remove the glued object, in seconds?", "Removal Time", src.remove_timer) as num
		else
			src.stick_timer = input("How long before the glued object falls off, in seconds?", "Attachment Duration", src.stick_timer) as num

	click_left(atom/object, ctrl, alt, shift)
		if (!length(to_glue))
			boutput(usr, "<span class='alert'>Nothing to glue!</span>")
		// bypass the entire glue_ready component, straight to glueing together
		for (var/atom/movable/thing in to_glue)
			var/datum/component/comp_maybe = thing.GetComponent(/datum/component/glued)
			comp_maybe?.RemoveComponent()
			thing.AddComponent(/datum/component/glued, object, stick_timer != -1 ? max(0, stick_timer SECONDS) : null, remove_timer != -1 ? max(0, remove_timer SECONDS) : null)
		to_glue.Cut()

		update_button_text(null)

	click_right(atom/movable/object, ctrl, alt, shift)
		if (!istype(object))
			return
		if (object in to_glue)
			boutput(usr, "<span class='alert'>That's already in the to-glue list! You can't glue something twice!")
			return
		if (!ctrl) // we just want the one thing, clear everything else
			if (length(to_glue) > 5) // ok maybe we fucked up
				if (tgui_alert(usr, "Clear to-glue list?", "Just in Case", list("Yes", "No")) == "No")
					return
			to_glue.Cut()
		to_glue += object
		update_button_text(get_button_text())

	proc/get_button_text()
		var/cutoff = length(to_glue) - 4 // 4 is the max before the last line gets clipped
		. = ""
		for (var/i = length(to_glue), i > max(0, cutoff), i--) //prioritize displaying the end of the list (recent)
			. += "[to_glue[i]]<br>"

		if (cutoff > 0) // have some excess Things
			. += "+[cutoff] Not Shown"
