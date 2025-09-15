///Singleton that handles antag popups, use get_singleton
/datum/antagPopups
	var/html

	proc/generateHTML()
		if (html)
			html = ""

		html += {"
<title>Special Role Popup Viewer</title>
<style>
	a {text-decoration:none}
	.antagType {padding:5px; margin-bottom:8px; border:1px solid black}
	.antagType .title {display:block; color:white; background:black; padding: 2px 5px; margin: -5px -5px 2px -5px}
</style>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Traitor</b>
	<a href='byond://?src=\ref[src];action=[ROLE_TRAITOR]'>Traitor</a> |
	<a href='byond://?src=\ref[src];action=traitorhard'>Hard Mode</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_OMNITRAITOR]'>Omnitraitor</a> |
	<a href='byond://?src=\ref[src];action=traitorgeneric'>Generic</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_SLEEPER_AGENT]'>Sleeper agent</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Mindhack</b>
	<a href='byond://?src=\ref[src];action=[ROLE_MINDHACK]'>Implanted</a> |
	<a href='byond://?src=\ref[src];action=mindhackdeath'>Death</a> |
	<a href='byond://?src=\ref[src];action=mindhackoverride'>Overriden</a> |
	<a href='byond://?src=\ref[src];action=mindhackexpired'>Expired</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Wizard</b>
	<a href='byond://?src=\ref[src];action=[ROLE_WIZARD]'>Wizard</a> |
	<a href='byond://?src=\ref[src];action=adminwizard'>Custom Wizard</a> |
	<a href='byond://?src=\ref[src];action=polymorph'>Polymorph</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Nuke/Rev</b>
	<a href='byond://?src=\ref[src];action=[ROLE_NUKEOP]'>Nuke Op</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_NUKEOP_COMMANDER]'>Nuke Op Commander</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_NUKEOP_GUNBOT]'>Nuke Op Gunbot</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_HEAD_REVOLUTIONARY]'>Rev Head</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_REVOLUTIONARY]'>Revved</a> |
	<a href='byond://?src=\ref[src];action=derevved'>De-Revved</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Spy/Conspiracy</b>
	<a href='byond://?src=\ref[src];action=spy'>Spy</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_SPY_THIEF]'>Spy Thief</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_CONSPIRATOR]'>Conspiracy</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_GANG_LEADER]'>Gang Leader</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_GANG_MEMBER]'>Gang Member</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Vampire/Changeling</b>
	<a href='byond://?src=\ref[src];action=[ROLE_VAMPIRE]'>Vampire</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_VAMPTHRALL]'>Vamp Thrall</a> |
	<br>
	<a href='byond://?src=\ref[src];action=[ROLE_CHANGELING]'>Changeling</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_CHANGELING_HIVEMIND_MEMBER]'>Changeling victim</a> |
	<a href='byond://?src=\ref[src];action=changeling_leave'>Leaving Hivemind</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_HANDSPIDER]'>Handspider</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_EYESPIDER]'>Eyespider</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_LEGWORM]'>Legworm</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_BUTTCRAB]'>Buttcrab</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Flock</b>
	<a href='byond://?src=\ref[src];action=[ROLE_FLOCKTRACE]'>Flocktrace</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_FLOCKMIND]'>Flockmind</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Other Antags</b>
	<a href='byond://?src=\ref[src];action=[ROLE_GRINCH]'>Grinch</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_HUNTER]'>Hunter</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_WEREWOLF]'>Werewolf</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_WRESTLER]'>Wrestler</a> |
	<a href='byond://?src=\ref[src];action=battle'>Battle Royale</a> |
	<a href='byond://?src=\ref[src];action=martian'>Martian</a> |
	<a href='byond://?src=\ref[src];action=kudzu'>Kudzu Person</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_SLASHER]'>The Slasher</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_SALVAGER]'>Salvagers</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_ARCFIEND]'>Arcfiend Person</a> |
	<a href='byond://?src=\ref[src];action=plaguebringer'>Plaguebringer wraith</a> |
	<a href='byond://?src=\ref[src];action=harbinger'>Harbinger wraith</a> |
	<a href='byond://?src=\ref[src];action=trickster'>Trickster wraith</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_PLAGUE_RAT]'>Plague rat</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_ZOMBIE]'>Zombie</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_PHOENIX]'>Space Phoenix</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Ghost roles</b>
	<a href='byond://?src=\ref[src];action=ghostdrone'>Ghostdrone</a> |
	<a href='byond://?src=\ref[src];action=ghostcritter'>Ghostcritter</a> |
	<a href='byond://?src=\ref[src];action=ghostcritter_antag'>Antag ghostcritter</a> |
	<a href='byond://?src=\ref[src];action=ghostcritter_mentor'>Mentor ghostcritter</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Misc</b>
	<a href='byond://?src=\ref[src];action=[ROLE_SYNDICATE_ROBOT]'>Rogue Borg</a> |
	<a href='byond://?src=\ref[src];action=rogueborgremoved'>Rogue Borg Removed</a> |
	<a href='byond://?src=\ref[src];action=antagremoved'>Antag Removed</a> |
	<a href='byond://?src=\ref[src];action=soulsteel'>Soulsteel Posession</a> |
	<a href='byond://?src=\ref[src];action=mindwipe'>Cloner Mindwipe</a> |
	<a href='byond://?src=\ref[src];action=slasher_possession'>Slasher Possession</a> |
	<a href='byond://?src=\ref[src];action=football'>Football</a> |
	<a href='byond://?src=\ref[src];action=podwars'>Podwars</a> |
	<a href='byond://?src=\ref[src];action=[ROLE_FLOOR_GOBLIN]'>Floor goblin</a>
</div>
"}

		return 1

	proc/showPanel()
		if (!html)
			if (!generateHTML())
				alert("Unable to generate the admin antag popup panel! Something's gone wacky!")
				return

		usr.Browse(html, "window=adminAntagPopups;size=600x400")

	Topic(href, href_list)
		if (href_list["action"])
			usr.show_antag_popup(href_list["action"], FALSE)

	//show antag popup to a mob
	proc/show_popup(mob/M, var/popup_name)
		set waitfor = FALSE
		tgui_alert(M, content_window = popup_name, do_wait = FALSE)

/mob
	///Stores the name of the last antag popup shown to the mob

	var/last_antag_popup = null
	/*Show antag popup with to a mob
	* @param popup_name the name of the popup to match to the correct macro
	* @param set_last_popup whether to modify the mob's last_antag_popup entry (used for the admin display)
	*/
	proc/show_antag_popup(var/popup_name, var/set_last_popup = TRUE)
		#ifndef NO_ANTAG_POPUPS_I_DONT_CARE
		if (set_last_popup)
			src.last_antag_popup = popup_name
		get_singleton(/datum/antagPopups).show_popup(src, popup_name)
		#endif

	verb/reopen_antag_popup()
		set name = "Special role popup"
		if (src.last_antag_popup)
			src.show_antag_popup(src.last_antag_popup, FALSE)
