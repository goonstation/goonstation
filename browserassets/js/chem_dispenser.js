attachErrorHandler('chemDispenser');

(function(window, document, $) {
	
	var EMPTY_SLOT_STRING = "-------";
	var user_add_amt = 10;
	var user_remove_amt = 10;
	
	function updateChemSection( data ) {
		data = $.parseJSON(data);
		var cont = $('#chem-container');
		var stat = $('#chem-stat');
		
		if(data.hasOwnProperty("stat_msg")) {
			stat.text(data.stat_msg);
		} 
		
		if (data.hasOwnProperty("chems")) {
			cont.text("");
			for (var c in data.chems) {
				var chem = data.chems[c];
				createButton('chemadd','chem' + c, chem.name,'dispensecustom=' +chem.id).appendTo(cont);
			}
		}
		
		if (data.hasOwnProperty("show_stat")) {
			if (data.show_stat == 1) {
				cont.hide();
				stat.show();
			} else {
				stat.hide();
				cont.show();
			}
		} 
	}

	window.updateChemSection = updateChemSection;
	
	function updateGroups( data ) {
		data = $.parseJSON(data);
		var cont = $('#groups').text("");
		if(data.hasOwnProperty("groups")){
			var data = data.groups;
			for (var gr in data) {
				var group = data[gr];
				var e = $('<div>', {class:'group'}).append(createButton('', 'group_dispense' + gr, group.name, 'group_dispense=' + group.ref)) //Create the dispense button
				e.append(createButton('','group_delete' + gr, 'del', 'group_delete=' + group.ref)); //Create the group delete button
				e.append($('<span>', {class:'info group-desc',  text: group.info})); //Create the group description
				cont.append(e);	
			}
		}
	}

	window.updateGroups = updateGroups;
	
	function updateBeaker( data ) {
		data = $.parseJSON( data );
		if (!data.hasOwnProperty("name")) {
			$('#glass-name').text("Beaker:");
			setButtonCaption("#eject", EMPTY_SLOT_STRING);
			$('#working-display').hide();
		} else {
			$('#working-display').show();
			$('#glass-name').text(data.name + ':        ');
			setButtonCaption("#eject", "Eject");
			
			var bc = $('#beaker-container').text("");
			if (data.hasOwnProperty("reagents")) {
				for (var c in data.reagents) {
					var r = data.reagents[c];
					bc.append(createBeakerReagent(r.name, r.id, r.quantity));
				}
			} else {
				bc.text("Beaker is empty.");
			}
		}
	}

	window.updateBeaker = updateBeaker;
	
	function updateGeneric( data ) {
		data = $.parseJSON( data);
		if (data.card !== undefined ) {
			//$('#group-container').show();
			setButtonCaption('#card',"Eject");
		} else {
			//$('#group-container').hide();
			setButtonCaption('#card', EMPTY_SLOT_STRING);
		}
		
		if (data.add_amt !== undefined ) {
			setButtonCaption('#setaddamt', "Set Dispense Amount ( +" + data.add_amt + "u )");
			user_add_amt = data.add_amt;
		}
		if (data.remove_amt !== undefined ) {
			setButtonCaption('#setremoveamt', "Set Remove Amount ( -" + data.remove_amt + "u )");
			setButtonCaption(".custom-remove", "-" + data.remove_amt);
			user_remove_amt = data.remove_amt;
		}
	}

	window.updateGeneric = updateGeneric;
	
	function createBeakerReagent(name, reagent_id, quantity) {
		var e = $('<div>', {class:"groups"});
		e.append($('<span>', {class:'info reagent-name',text:name + ' ( ' +quantity +'u )'})); //Reagent name / quantity
		e.append(createButton('','isolate'+reagent_id,"Isolate",'isolate='+reagent_id )); //Isolate button
		e.append(createButton('','removea'+reagent_id,"-All",'remove='+reagent_id )); //Remove all
		e.append(createButton('custom-remove','removec'+reagent_id,"-" + user_remove_amt,'removecustom='+reagent_id )); //Remove custom
		e.append(createButton('','remove5'+reagent_id,"-5",'remove5='+reagent_id )); //Remove 5
		e.append(createButton('','remove1'+reagent_id,"-1",'remove1='+reagent_id )); //Remove 1
		return e;
	}
	
	function createButton(sClass, sID, sName, sInfo) {
		return $('<a>', {class:'button medium ' + sClass,
								id:sID,
								"data-info":sInfo}).append('<span class="top"></span>').append(sName).append('<span class="bottom"></span>');
	}

	function setButtonCaption(button, caption) {
		$(button).html('<span class="top"></span>' + caption + '<span class="bottom"></span>');
	}

	//$(document).ready(function () {updateChemSection('{"stat_msg":"Beaker is full."}')})
	/*
	$(document).ready(function () {
		
		updateChemSection('{"chems":[{"name":"aluminium","id":"aluminium"},{"name":"barium","id":"barium"},{"name":"bromine","id":"bromine"},{"name":"carbon","id":"carbon"},{"name":"chlorine","id":"chlorine"},{"name":"chromium","id":"chromium"},{"name":"copper","id":"copper"},{"name":"fluorine","id":"fluorine"},{"name":"ethanol","id":"ethanol"},{"name":"hydrogen","id":"hydrogen"},{"name":"iodine","id":"iodine"},{"name":"iron","id":"iron"},{"name":"lithium","id":"lithium"},{"name":"magnesium","id":"magnesium"},{"name":"mercury","id":"mercury"},{"name":"nickel","id":"nickel"},{"name":"nitrogen","id":"nitrogen"},{"name":"oxygen","id":"oxygen"},{"name":"plasma","id":"plasma"},{"name":"platinum","id":"platinum"},{"name":"phosphorus","id":"phosphorus"},{"name":"potassium","id":"potassium"},{"name":"radium","id":"radium"},{"name":"silicon","id":"silicon"},{"name":"silver","id":"silver"},{"name":"sodium","id":"sodium"},{"name":"sulfur","id":"sulfur"},{"name":"sugar","id":"sugar"},{"name":"water","id":"water"}]}');
		updateGroups('[{"name":"smoke powder","ref":"[0x2100ab9d]", "info":"iron (10u), oxygen (10u), hydrogen (10u), potassium (20u), phosphorus (20u), sugar (20u)"}, \
								{"name":"smoke powder","ref":"[0x2100ab9d]", "info":"iron (10u), oxygen (10u), hydrogen (10u), potassium (20u), phosphorus (20u), sugar (20u)"}]');
		//updateBeaker("{}");
		updateBeaker('{"name":"Eeker", "reagents":[ \
			{"name":"Sodium", "id":"sodium","quantity":15}, \
			{"name":"Oxygen", "id":"oxygen","quantity":7} \
		]}');
		
		updateGeneric('{"add_amt":20,"remove_amt":15}');
		
		
		})
		*/
})(window, document, jQuery);