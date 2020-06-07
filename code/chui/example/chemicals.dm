
chui/window/chem
	var/global/list/CHEMS = list( "Aluminium", "Bromine", "Copper", "Sugar", "Water" )
	var/list/chems = list()
	name = "Chemical Dispenser"
	New()
		..()
	OnClick( var/client/who, var/id )
		if( !(id in CHEMS))
			return//??
		if( isnull( chems[ id ] ) )
			chems[ id ] = 0
		chems[ id ] += 10
		CallJSFunction( "addChem", list( id ) )
	OnTopic( usr.client, href, href_list[] )
		switch( href_list[ "action" ] )
			if( "remove" )
				chems[href_list[ "chem" ]] = null
				CallJSFunction( "removeChem", list( href_list[ "chem" ] ) )
	proc/getChems()
		var/ret = "Chem(trails):<div id='chemlist'>"
		for( var/chem in chems )
			if( !isnull(chems[ chem ]) )
				world << chem
				ret += "<div id = '[chem]-div'><b>" + chem + " <i>(<span id='[chem]-count'>[chems[chem]]</span>)</i></b> - <a href='?src=\ref[src]&action=remove&chem=" + chem + "'>Remove</a></div>"
		return "[ret]</div><hr/>"

	GetBody()
		var/generated = getChems()
		for( var/i = 1, i <= CHEMS.len, i++ )
			generated += theme.generateButton( CHEMS[i], CHEMS[i] ) + "<br/>"

		return {"
		<script type='text/javascript'>
			function addChem( name ){

				var el = document.getElementById( name + "-div" );
				if( el ){
					$( "#" + name + "-count" ).html( Number( $( "#" + name + "-count" ).html() ) + 10 );
				}else{
					var el = $( "<div id = '" + name + "-div'><b>" + name + " <i>(<span id='" + name + "-count'>10</span>)</i></b> - <a href='?src=" + chui.window + "&action=remove&chem=" + name + "'>Remove</a></div>" );
					$( "#chemlist" ).append( el );
					el.hide().fadeIn();
				}

			}
			function removeChem( name ){
				$( "#" + name + "-div" ).fadeOut(300, function(){ $(this).remove(); });
			}
		</script>"} + generated

var/global/chui/window/chem/chems

world/New()
	.=..()
	chems = new

client/verb/chemicals()
	set name = "Chem Dispenser"
	set category = "chui"
	if( chems.IsSubscribed( src ) )
		chems.Unsubscribe( src )
	else
		chems.Subscribe( src )
