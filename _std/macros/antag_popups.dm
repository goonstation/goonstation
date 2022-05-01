///Singleton that handles antag popups, use get_singleton
/datum/antagPopups
	var/html

	proc/generateHTML()
		if (html)
			html = ""

		html += {"
<title>Antag Popup Viewer</title>
<style>
	a {text-decoration:none}
	.antagType {padding:5px; margin-bottom:8px; border:1px solid black}
	.antagType .title {display:block; color:white; background:black; padding: 2px 5px; margin: -5px -5px 2px -5px}
</style>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Traitor</b>
	<a href='?src=\ref[src];action=traitorradio'>Radio Uplink</a> |
	<a href='?src=\ref[src];action=traitorpda'>PDA Uplink</a> |
	<a href='?src=\ref[src];action=traitorhard'>Hard Mode</a> |
	<a href='?src=\ref[src];action=traitoromni'>Omnitraitor</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Mindslave</b>
	<a href='?src=\ref[src];action=mindslave'>Implanted</a> |
	<a href='?src=\ref[src];action=mindslavedeath'>Death</a> |
	<a href='?src=\ref[src];action=mindslaveoverride'>Overriden</a> |
	<a href='?src=\ref[src];action=mindslaveexpired'>Expired</a>
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
	<a href='?src=\ref[src];action=handspider'>Handspider</a> |
	<a href='?src=\ref[src];action=eyespider'>Eye/Butt Spider</a> |
	<a href='?src=\ref[src];action=legworm'>Legworm</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Other Antags</b>
	<a href='?src=\ref[src];action=grinch'>Grinch</a> |
	<a href='?src=\ref[src];action=hunter'>Hunter</a> |
	<a href='?src=\ref[src];action=werewolf'>Werewolf</a> |
	<a href='?src=\ref[src];action=wrestler'>Wrestler</a> |
	<a href='?src=\ref[src];action=battle'>Battle Royale</a> |
	<a href='?src=\ref[src];action=martian'>Martian</a> |
	<a href='?src=\ref[src];action=kudzu'>Kudzu Person</a> |
	<a href='?src=\ref[src];action=slasher'>The Slasher</a>
	<a href='?src=\ref[src];action=arcfiend'>Arcfiend Person</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Misc</b>
	<a href='?src=\ref[src];action=rogueborgremoved'>Rogue Borg Removed</a> |
	<a href='?src=\ref[src];action=antagremoved'>Antag Removed</a> |
	<a href='?src=\ref[src];action=soulsteel'>Soulsteel Posession</a> |
	<a href='?src=\ref[src];action=mindwipe'>Cloner Mindwipe</a> |
	<a href='?src=\ref[src];action=slasher_possession'>Slasher Possession</a>
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
		var/mob/M
		if (ismob(usr))
			M = usr
			if (M.client.holder.level < 0)
				alert("UM, EXCUSE ME??  YOU AREN'T AN ADMIN, GET DOWN FROM THERE!")
				M << csound("sound/voice/farts/poo2.ogg")
				return
		else
			alert("How the hell are you not a mob?! I can't show the panel to you, you don't exist!")
			return
		if (href_list["action"])
			M.show_antag_popup(href_list["action"], FALSE)
		if (href_list["wiki"])
			searchWiki(M, href_list["wiki"])

	//show antag popup to a mob
	proc/show_popup(mob/M, var/popup_name)
		var/window_title = "Antagonist Tips"
		var/filename = null
		switch(popup_name)
			// traitor
			if ("traitorradio")
				filename = "html/traitorTips/traitorradiouplinkTips.html"
			if ("traitorpda")
				filename = "html/traitorTips/traitorTips.html"
			if ("traitorhard")
				filename = "html/traitorTips/traitorhardTips.html"
			if ("traitoromni")
				filename = "html/traitorTips/omniTips.html"

			// mindslave
			if ("mindslave")
				filename = "html/mindslave/implanted.html"
			if ("mindslavedeath")
				filename = "html/mindslave/death.html"
			if ("mindslaveoverride")
				filename = "html/mindslave/override.html"
			if ("mindslaveexpired")
				filename = "html/mindslave/expire.html"

			// wizard
			if ("wizard")
				filename = "html/traitorTips/wizardTips.html"
			if ("adminwizard")
				filename = "html/traitorTips/wizardcustomTips.html"
			if ("polymorph")
				window_title = "Polymorphed!"
				filename = "html/polymorph.html"

			// nuke/rev
			if ("nukeop")
				filename = "html/traitorTips/nukeopTips.html"
			if ("nukeop-commander")
				filename = "html/traitorTips/nukeopcommanderTips.html"
			if ("nukeop-gunbot")
				filename = "html/traitorTips/nukeopgunbotTips.html"
			if ("revhead")
				filename = "html/traitorTips/revTips.html"
			if ("revved")
				filename = "html/traitorTips/revAdded.html"
			if ("derevved")
				filename = "html/traitorTips/revRemoved.html"

			// spy/conspiracy
			if ("spy")
				filename = "html/traitorTips/spyTips.html"
			if ("spythief")
				filename = "html/traitorTips/spy_theft_Tips.html"
			if ("conspiracy")
				filename = "html/traitorTips/conspiracyTips.html"

			// gangers
			if ("gang_member")
				filename = "html/traitorTips/gang_member_added.html"

			// vamp/changeling
			if ("vampire")
				filename = "html/traitorTips/vampireTips.html"
			if ("vampthrall")
				filename = "html/traitorTips/vampiricthrallTips.html"
			if ("changeling")
				filename = "html/traitorTips/changelingTips.html"
			if ("handspider")
				filename = "html/mindslave/handspider.html"
			if ("eyespider")
				filename = "html/mindslave/eyespider.html"
			if ("legworm")
				filename = "html/mindslave/legworm.html"

			// other antags
			if ("grinch")
				filename = "html/traitorTips/grinchTips.html"
			if ("hunter")
				filename = "html/traitorTips/hunterTips.html"
			if ("werewolf")
				filename = "html/traitorTips/werewolfTips.html"
			if ("wrestler")
				filename = "html/traitorTips/wrestlerTips.html"
			if ("battle")
				filename = "html/traitorTips/battleTips.html"
			if ("martian")
				filename = "html/traitorTips/martianInfiltrator.html"
			if ("kudzu")
				filename = "html/traitorTips/kudzu.html"
			if ("slasher")
				filename = "html/traitorTips/slasherTips.html"
			if ("arcfiend")
				filename = "html/traitorTips/arcfiendTips.html"
			if ("football")
				filename = "html/traitorTips/football.html"
			if ("podwars")
				filename = "html/traitorTips/pod_wars.html"
			if ("zombie")
				filename = "html/traitorTips/zombieTips.html"

			// misc
			if ("rogueborgremoved")
				filename = "html/traitorTips/roguerobotRemoved.html"
			if ("antagremoved")
				filename = "html/traitorTips/antagRemoved.html"
			if ("soulsteel")
				window_title = "Posession!"
				filename = "html/soulsteel.html"
			if ("slasher_possession")
				window_title = "Posession!"
				filename = "html/slasher_possession.html"
			if ("mindwipe")
				window_title = "Mindwiped!"
				filename = "html/mindwipe.html"

		if (!filename)
			return
		var/html = grabResource(filename)
		html = replacetext(html, "{ref}", "\ref[get_singleton(/datum/antagPopups)]")
		M.Browse(html, "window=antagTips;size=700x450;title=[window_title]")


/client/proc/cmd_admin_antag_popups()
	set name = "View Antag Popups"
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
		set name = "Open antag popup"
		if (src.last_antag_popup)
			src.show_antag_popup(src.last_antag_popup, FALSE)
