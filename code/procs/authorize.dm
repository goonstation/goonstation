/client/proc/set_mentorhelp_visibility(var/set_as = null)
	if (!isnull(set_as))
		player.see_mentor_pms = set_as
	else
		player.see_mentor_pms = !player.see_mentor_pms
	boutput(src, "<span class='ooc mentorooc'>You will [player.see_mentor_pms ? "now" : "no longer"] see Mentorhelps [player.see_mentor_pms ? "and" : "or"] show up as a Mentor.</span>")

/client/proc/toggle_mentorhelps()
	set name = "Toggle Mentorhelps"
	set category = "Special Verbs"
	set desc = "Show or hide mentorhelp messages. You will also no longer show up as a mentor in OOC and via the Who command if you disable mentorhelps."

	if (!src.is_mentor() && !src.holder)
		boutput(src, "<span class='alert'>Only mentors may use this command.</span>")
		src.verbs -= /client/proc/toggle_mentorhelps // maybe?
		return

	src.set_mentorhelp_visibility()

/*
/proc/proxy_check(address)
	if(address)
		var/result = world.Export("http://autisticpowers.info/ss13/check_ip.php?ip=[address]")
		if("STATUS" in result && lowertext(result["STATUS"]) == "200 ok")
			var/using_proxy = text2num(file2text(result["CONTENT"]))
			if(using_proxy)
				return 1
	return 0
*/
