client/verb/hotkeys()
	set name = "Hotkeys"
	src.Browse( {"<ul style='list-style-type:disc'>
		<h3>Common Keys</h3>
			<li><b>F1:</b> Adminhelp</li>
			<li><b>F2:</b> Quick screenshot</li>
			<li><b>Ctrl+F2:</b> Save screenshot</li>
			<li><b>F3:</b> Mentorhelp</li>
			<li><b>Alt:</b> Examine object clicked on</li>
			<li><b>Ctrl:</b> Pull or release object clicked on</li>
			<li><b>Space:</b> Toggles throw mode on when held down, toggles off when released</li>
			<li><b>Alt+C:</b> OOC</li>
			<li><b>TAB:</b> Bring focus to the input bar</li>
			<li><b>G:</b> Bring focus to, and clear, the input bar</li>
			<li><b>Esc:</b> Bring focus to the main game window and clear the input bar</li>
			<li><b>Enter (While the input bar is selected and empty):</b> Bring focus to the main game window and clear the input bar</li>
		<p>
		<h3>WASD Mode Specific Keys</h3>
			<li><b>W:</b> Up</li>
			<li><b>A:</b> Left</li>
			<li><b>S:</b> Down</li>
			<li><b>D:</b> Right</li>
			<li><b>T:</b> Talk</li>
			<li><b>Y:</b> Talk into radio headset</li>
			<li><b>E:</b> Switch active hand</li>
			<li><b>C:</b> Use item in active hand</li>
			<li><b>Q:</b> Drop item from active hand</li>
			<li><b>V:</b> Equip item in active hand, if possible</li>
			<li><b>1:</b> Help intent</li>
			<li><b>2:</b> Disarm intent</li>
			<li><b>3:</b> Grab intent</li>
			<li><b>4:</b> Harm intent</li>
			<li><b>R:</b> Flip</li>
			<li><b>F:</b> Fart</li>
			<li><b>Z:</b> Resist</li>
		<p>
		<h3>Arrow Keys Mode Specific Keys</h3>
			<li><b>PgUp:</b> Switch active hand</li>
			<li><b>PgDown:</b> Use item in active hand</li>
			<li><b>Home:</b> Drop item from active hand</li>
		<p>
		<h3>Cyborg WASD Mode Specific Keys</h3>
			<li><b>1:</b> First tool slot</li>
			<li><b>2:</b> Second tool slot</li>
			<li><b>3:</b> Third tool slot</li>
			<li><b>4:</b> Deselect tool</li>
		<p>
		<h3>Emotes</h3>
			<li><b>Ctrl+A:</b> Salute</li>
			<li><b>Ctrl+B:</b> Burp</li>
			<li><b>Ctrl+D:</b> Dance</li>
			<li><b>Ctrl+E:</b> Eyebrow</li>
			<li><b>Ctrl+F:</b> Fart</li>
			<li><b>Ctrl+G:</b> Gasp</li>
			<li><b>Ctrl+H:</b> Raisehand</li>
			<li><b>Ctrl+L:</b> Laugh</li>
			<li><b>Ctrl+N:</b> Nod</li>
			<li><b>Ctrl+Q:</b> Wave</li>
			<li><b>Ctrl+R:</b> Flip</li>
			<li><b>Ctrl+S:</b> Scream</li>
			<li><b>Ctrl+W:</b> Wink</li>
			<li><b>Ctrl+Y:</b> Yawn</li>
			<li><b>Ctrl+Z:</b> Snap</li>
		<h3>Admin</h3>
			<li><b>~:</b> Open common admin atom verbs</li>
	</ul>"}, "window=hotkeys;title=Hotkeys" )
	//src.Browse('browserassets/html/admin/hotkeys.html', "window=help")
	return
