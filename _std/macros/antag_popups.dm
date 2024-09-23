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
	<a href='?src=\ref[src];action=traitorradio'>Radio Uplink</a> |
	<a href='?src=\ref[src];action=traitorpda'>PDA Uplink</a> |
	<a href='?src=\ref[src];action=traitorhard'>Hard Mode</a> |
	<a href='?src=\ref[src];action=omnitraitor'>Omnitraitor</a> |
	<a href='?src=\ref[src];action=traitorgeneric'>Generic</a> |
	<a href='?src=\ref[src];action=[ROLE_SLEEPER_AGENT]'>Sleeper agent</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Mindhack</b>
	<a href='?src=\ref[src];action=mindhack'>Implanted</a> |
	<a href='?src=\ref[src];action=mindhackdeath'>Death</a> |
	<a href='?src=\ref[src];action=mindhackoverride'>Overriden</a> |
	<a href='?src=\ref[src];action=mindhackexpired'>Expired</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Wizard</b>
	<a href='?src=\ref[src];action=wizard'>Wizard</a> |
	<a href='?src=\ref[src];action=adminwizard'>Custom Wizard</a> |
	<a href='?src=\ref[src];action=polymorph'>Polymorph</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Nuke/Rev</b>
	<a href='?src=\ref[src];action=nukeop'>Nuke Op</a> |
	<a href='?src=\ref[src];action=nukeop_commander'>Nuke Op Commander</a> |
	<a href='?src=\ref[src];action=nukeop_gunbot'>Nuke Op Gunbot</a> |
	<a href='?src=\ref[src];action=[ROLE_HEAD_REVOLUTIONARY]'>Rev Head</a> |
	<a href='?src=\ref[src];action=revved'>Revved</a> |
	<a href='?src=\ref[src];action=derevved'>De-Revved</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Spy/Conspiracy</b>
	<a href='?src=\ref[src];action=spy'>Spy</a> |
	<a href='?src=\ref[src];action=spythief'>Spy Thief</a> |
	<a href='?src=\ref[src];action=conspiracy'>Conspiracy</a> |
	<a href='?src=\ref[src];action=gang_leader'>Gang Leader</a> |
	<a href='?src=\ref[src];action=gang_member'>Gang Member</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Vampire/Changeling</b>
	<a href='?src=\ref[src];action=vampire'>Vampire</a> |
	<a href='?src=\ref[src];action=vampthrall'>Vamp Thrall</a> |
	<br><a href='?src=\ref[src];action=changeling'>Changeling</a> |
	<a href='?src=\ref[src];action=changeling_absorbed'>Changeling victim</a> |
	<a href='?src=\ref[src];action=changeling_leave'>Leaving Hivemind</a> |
	<a href='?src=\ref[src];action=handspider'>Handspider</a> |
	<a href='?src=\ref[src];action=eyespider'>Eyespider</a> |
	<a href='?src=\ref[src];action=legworm'>Legworm</a> |
	<a href='?src=\ref[src];action=buttcrab'>Buttcrab</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Flock</b>
	<a href='?src=\ref[src];action=flocktrace'>Flocktrace</a> |
	<a href='?src=\ref[src];action=flockmind'>Flockmind</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Other Antags</b>
	<a href='?src=\ref[src];action=grinch'>Grinch</a> |
	<a href='?src=\ref[src];action=hunter'>Hunter</a> |
	<a href='?src=\ref[src];action=werewolf'>Werewolf</a> |
	<a href='?src=\ref[src];action=wrestler'>Wrestler</a> |
	<a href='?src=\ref[src];action=battle'>Battle Royale</a> |
	<a href='?src=\ref[src];action=martian'>Martian</a> |
	<a href='?src=\ref[src];action=kudzu'>Kudzu Person</a> |
	<a href='?src=\ref[src];action=slasher'>The Slasher</a> |
	<a href='?src=\ref[src];action=salvager'>Salvagers</a> |
	<a href='?src=\ref[src];action=arcfiend'>Arcfiend Person</a> |
	<a href='?src=\ref[src];action=plaguebringer'>Plaguebringer wraith</a> |
	<a href='?src=\ref[src];action=harbinger'>Harbinger wraith</a> |
	<a href='?src=\ref[src];action=trickster'>Trickster wraith</a> |
	<a href='?src=\ref[src];action=plaguerat'>Plague rat</a> |
	<a href='?src=\ref[src];action=zombie'>Zombie</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Ghost roles</b>
	<a href='?src=\ref[src];action=ghostdrone'>Ghostdrone</a> |
	<a href='?src=\ref[src];action=ghostcritter'>Ghostcritter</a> |
	<a href='?src=\ref[src];action=ghostcritter_antag'>Antag ghostcritter</a> |
	<a href='?src=\ref[src];action=ghostcritter_mentor'>Mentor ghostcritter</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Misc</b>
	<a href='?src=\ref[src];action=syndieborg'>Rogue Borg</a> |
	<a href='?src=\ref[src];action=rogueborgremoved'>Rogue Borg Removed</a> |
	<a href='?src=\ref[src];action=antagremoved'>Antag Removed</a> |
	<a href='?src=\ref[src];action=soulsteel'>Soulsteel Posession</a> |
	<a href='?src=\ref[src];action=mindwipe'>Cloner Mindwipe</a> |
	<a href='?src=\ref[src];action=slasher_possession'>Slasher Possession</a> |
	<a href='?src=\ref[src];action=souldorf'>Souldorf</a> |
	<a href='?src=\ref[src];action=zoldorf'>Zoldorf</a> |
	<a href='?src=\ref[src];action=football'>Football</a> |
	<a href='?src=\ref[src];action=podwars'>Podwars</a>
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
		tgui_alert(M, content_window = popup_name, do_wait = FALSE)

/mob
	///Stores the name of the last antag popup shown to the mob

	var/last_antag_popup = null
	/*Show antag popup with to a mob
	* @param popup_name the name of the popup to match to the correct macro
	* @param set_last_popup whether to modify the mob's last_antag_popup entry (used for the admin display)
	*/
	proc/show_antag_popup(var/popup_name, var/set_last_popup = TRUE)
		if (set_last_popup)
			src.last_antag_popup = popup_name
		get_singleton(/datum/antagPopups).show_popup(src, popup_name)

	verb/reopen_antag_popup()
		set name = "Special role popup"
		if (src.last_antag_popup)
			src.show_antag_popup(src.last_antag_popup, FALSE)
