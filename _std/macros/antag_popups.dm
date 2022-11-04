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
	<a href='?src=\ref[src];action=traitoromni'>Omnitraitor</a> |
	<a href='?src=\ref[src];action=traitorgeneric'>Generic</a> |
	<a href='?src=\ref[src];action=sleeper'>Sleeper agent</a>
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
	<a href='?src=\ref[src];action=nukeop-commander'>Nuke Op Commander</a> |
	<a href='?src=\ref[src];action=nukeop-gunbot'>Nuke Op Gunbot</a> |
	<a href='?src=\ref[src];action=revhead'>Rev Head</a> |
	<a href='?src=\ref[src];action=revved'>Revved</a> |
	<a href='?src=\ref[src];action=derevved'>De-Revved</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Spy/Conspiracy</b>
	<a href='?src=\ref[src];action=spy'>Spy</a> |
	<a href='?src=\ref[src];action=spythief'>Spy Thief</a> |
	<a href='?src=\ref[src];action=conspiracy'>Conspiracy</a> |
	<a href='?src=\ref[src];action=gang_member'>Gang Member</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Vampire/Changeling</b>
	<a href='?src=\ref[src];action=vampire'>Vampire</a> |
	<a href='?src=\ref[src];action=vampthrall'>Vamp Thrall</a> |
	<a href='?src=\ref[src];action=vampzombie'>Vamp Zombie</a> |
	<br><a href='?src=\ref[src];action=changeling'>Changeling</a> |
	<a href='?src=\ref[src];action=changeling_absorbed'>Changeling victim</a> |
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
	<a href='?src=\ref[src];action=plaguerat'>Plague rat</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Ghost roles</b>
	<a href='?src=\ref[src];action=ghostdrone'>Ghostdrone</a> |
	<a href='?src=\ref[src];action=ghostcritter'>Ghostcritter</a> |
	<a href='?src=\ref[src];action=ghostcritter_antag'>Antag ghostcritter</a> |
	<a href='?src=\ref[src];action=ghostcritter_mentor'>Mentor ghostcritter</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Misc</b>
	<a href='?src=\ref[src];action=rogueborgremoved'>Rogue Borg Removed</a> |
	<a href='?src=\ref[src];action=antagremoved'>Antag Removed</a> |
	<a href='?src=\ref[src];action=soulsteel'>Soulsteel Posession</a> |
	<a href='?src=\ref[src];action=mindwipe'>Cloner Mindwipe</a> |
	<a href='?src=\ref[src];action=slasher_possession'>Slasher Possession</a> |
	<a href='?src=\ref[src];action=souldorf'>Souldorf</a>
</div>
"}

		return 1

	proc/showPanel()
		if (!html)
			if (!generateHTML())
				alert("Unable to generate the admin antag popup panel! Something's gone wacky!")
				return

		usr.Browse(html, "window=adminAntagPopups;size=600x400")

	//this is definitely not a massive security hole or anything. I think
	proc/searchWiki(mob/M, var/phrase)
		M << link("https://wiki.ss13.co/index.php?search=[phrase]")

	Topic(href, href_list)
		if (href_list["action"])
			usr.show_antag_popup(href_list["action"], FALSE)
		if (href_list["wiki"])
			searchWiki(usr, href_list["wiki"])

	//show antag popup to a mob
	proc/show_popup(mob/M, var/popup_name)
		var/window_title = "Antagonist Tips"
		var/filename = null
		switch(popup_name)
			// traitor
			if ("traitorradio")
				window_title = "Radio Traitor Tips"
				filename = "html/traitorTips/traitorradiouplinkTips.html"
			if ("traitorpda")
				window_title = "Traitor Tips"
				filename = "html/traitorTips/traitorTips.html"
			if ("traitorhard")
				window_title = "Hardmode Traitor Tips"
				filename = "html/traitorTips/traitorhardTips.html"
			if ("traitoromni")
				window_title = "Omni-Traitor Tips"
				filename = "html/traitorTips/omniTips.html"
			if ("traitorgeneric")
				window_title = "Antagonist Tips"
				filename ="html/traitorTips/traitorGenericTips.html"
			if (ROLE_SLEEPER_AGENT)
				window_title = "Sleeper Agent Tips"
				filename = "html/traitorTips/traitorsleeperTips.html"

			// mindhack
			if ("mindhack")
				window_title = "You've been mindhacked!"
				filename = "html/notice/implanted.html"
			if ("mindhackdeath")
				window_title = "Mindhack Status Removed!"
				filename = "html/notice/death.html"
			if ("mindhackoverride")
				window_title = "Mindhack Master Changed!"
				filename = "html/notice/override.html"
			if ("mindhackexpired")
				window_title = "Mindhack Implant Expired!"
				filename = "html/notice/expire.html"

			// wizard
			if ("wizard")
				window_title = "Wizarding Facts for beginning magical entities"
				filename = "html/traitorTips/wizardTips.html"
			if ("adminwizard")
				window_title = "Wizarding Theory for advanced practitioners"
				filename = "html/traitorTips/wizardcustomTips.html"
			if ("polymorph")
				window_title = "You've been polymorphed!"
				filename = "html/polymorph.html"

			// nuke/rev
			if ("nukeop")
				window_title = "Nuclear Operative Basics"
				filename = "html/traitorTips/nukeopTips.html"
			if ("nukeop-commander")
				window_title = "Nuclear Commander Basics"
				filename = "html/traitorTips/nukeopcommanderTips.html"
			if ("nukeop-gunbot")
				window_title = "Nuclear Gun-Bot Basics"
				filename = "html/traitorTips/nukeopgunbotTips.html"
			if ("revhead")
				window_title = "Revolutionary Head Goals"
				filename = "html/traitorTips/revTips.html"
			if ("revved")
				window_title = "You've been converted to the Revolution!"
				filename = "html/traitorTips/revAdded.html"
			if ("derevved")
				window_title = "You've been freed from your brainwashing!"
				filename = "html/traitorTips/revRemoved.html"

			// spy/conspiracy
			if ("spy")
				window_title = "How to Spy 101"
				filename = "html/traitorTips/spyTips.html"
			if ("spythief")
				window_title = "Spy Thief Tips"
				filename = "html/traitorTips/spy_theft_Tips.html"
			if ("conspiracy")
				window_title = "Conspiracy Guidelines"
				filename = "html/traitorTips/conspiracyTips.html"

			// gangers
			if ("gang_member")
				window_title = "You've joined a Gang!"
				filename = "html/traitorTips/gang_member_added.html"

			// vamp/changeling
			if ("vampire")
				window_title = "Vampire Tips"
				filename = "html/traitorTips/vampireTips.html"
			if ("vampthrall")
				window_title = "You've become the brainwashed thrall of a Vampire!"
				filename = "html/traitorTips/vampiricthrallTips.html"
			if ("changeling")
				window_title = "Changeling Tips"
				filename = "html/traitorTips/changelingTips.html"
			if ("changeling_absorbed")
				window_title = "You've been absorbed into the Hivemind!"
				filename = "html/notice/changelingEaten.html"
			if ("changeling_leave")
				window_title = "Leaving the Hivemind"
				filename = "html/notice/changelingLeave.html"
			if ("handspider")
				window_title = "Handspider Expectations"
				filename = "html/notice/handspider.html"
			if ("eyespider")
				window_title = "Eyespider Expectations"
				filename = "html/notice/eyespider.html"
			if ("legworm")
				window_title = "LegWorm Expectations"
				filename = "html/notice/legworm.html"
			if ("buttcrab")
				window_title = "Buttcrab Expectations"
				filename = "html/notice/buttcrab.html"

			//flock
			if("flocktrace")
				window_title = "Flocktrace tips"
				filename = "html/traitorTips/flocktraceTips.html"
			if("flockmind")
				window_title = "Flockmind Basics"
				filename = "html/traitorTips/flockmindTips.html"

			// other antags
			if ("grinch")
				window_title = "How to steal Spacemas"
				filename = "html/traitorTips/grinchTips.html"
			if ("hunter")
				window_title = "Basic Prey Hunting"
				filename = "html/traitorTips/hunterTips.html"
			if ("werewolf")
				window_title = "Werewolf Basics"
				filename = "html/traitorTips/werewolfTips.html"
			if ("wrestler")
				window_title = "How to be a Champion!"
				filename = "html/traitorTips/wrestlerTips.html"
			if ("battle")
				window_title = "Battle Royale Tips!"
				filename = "html/traitorTips/battleTips.html"
			if ("martian")
				window_title = "Being a Martian 101!"
				filename = "html/traitorTips/martianInfiltratorTips.html"
			if ("kudzu")
				window_title = "You've been absorbed into the Kudzu!"
				filename = "html/traitorTips/kudzuTips.html"
			if ("salvager")
				filename = "html/traitorTips/salvager.html"
			if ("slasher")
				window_title = "You've been made a Slasher!"
				filename = "html/traitorTips/slasherTips.html"
			if ("arcfiend")
				window_title = "Arcfiend Tips!"
				filename = "html/traitorTips/arcfiendTips.html"
			if ("plaguebringer")
				filename = "html/traitorTips/plaguebringerTips.html"
			if ("plaguerat")
				filename = "html/traitorTips/plagueratTips.html"
			if ("trickster")
				filename = "html/traitorTips/tricksterTips.html"
			if ("harbinger")
				filename = "html/traitorTips/harbingerTips.html"
			if ("football")
				window_title = "Go for the endzone!"
				filename = "html/traitorTips/footballTips.html"
			if ("podwars")
				window_title = "Fight for your team!"
				filename = "html/traitorTips/pod_warsTips.html"
			if ("zombie")
				window_title = "Zombie Basics"
				filename = "html/traitorTips/zombieTips.html"
			if ("brainslug")
				window_title = "Brainslug"
				filename = "html/traitorTips/brainslug.html"

			// ghost roles
			if ("ghostdrone")
				window_title = "Ghost Drone Expectations"
				filename = "html/ghostdrone.html"
			if ("ghostcritter")
				window_title = "Ghost Critter Expectations"
				filename = "html/ghostcritter.html"
			if ("ghostcritter_antag")
				window_title = "Ghost Critter Antagonist Tips!"
				filename = "html/ghostcritter_antag.html"
			if ("ghostcritter_mentor")
				window_title = "Mentor Mouse Tips!"
				filename = "html/ghostcritter_mentor.html"

			// misc
			if ("syndieborg")
				window_title = "Syndicate Robot Tips!"
				filename = "html/traitorTips/syndicaterobotTips.html"
			if ("rogueborgremoved")
				window_title = "Rogue Status Removed!"
				filename = "html/traitorTips/roguerobotRemoved.html"
			if ("antagremoved")
				window_title = "Antagonist Status Removed!"
				filename = "html/traitorTips/antagRemoved.html"
			if ("soulsteel")
				window_title = "Posession!"
				filename = "html/soulsteel.html"
			if ("slasher_possession")
				window_title = "Possessed by the Slasher!"
				filename = "html/slasher_possession.html"
			if ("mindwipe")
				window_title = "Mindwiped!"
				filename = "html/mindwipe.html"
			if ("zoldorf")
				filename = "html/traitorTips/zoldorfTips.htm"
			if ("souldorf")
				filename = "html/traitorTips/souldorfTips.htm"

		if (!filename)
			return
		var/html = grabResource(filename)
		html = replacetext(html, "{ref}", "\ref[get_singleton(/datum/antagPopups)]")
		M.Browse(html, "window=antagTips;size=700x450;title=[window_title]")


/client/proc/cmd_admin_antag_popups()
	set name = "View Special Role Popups"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	if (src.holder)
		get_singleton(/datum/antagPopups).showPanel()

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
