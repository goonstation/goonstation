(function (window, document, $) {
	var annunciatorHolder = {
			dnaLoaded: false,
			slotExposed: false,
			slotSample: false,
			//Functions
			setSlotExposed: function (exp) {
				var annSlot = $("#annSlotExp");
				if(exp && !annunciatorHolder.slotExposed) {
					annSlot.addClass("a-yellow-on");
				} else if (annunciatorHolder.slotExposed) {
					annSlot.removeClass("a-yellow-on");
				}
				annunciatorHolder.slotExposed = exp;
			},
			setSlotSample: function (smp) {
				var annSlot = $("#annSlotSample");
				if(smp && !annunciatorHolder.slotSample) {
					annSlot.addClass("a-green-on");
				} else if (annunciatorHolder.slotSample) {
					annSlot.removeClass("a-green-on");
				}
				annunciatorHolder.slotSample = smp;
			},

			setLoadAnn: function (loaded) {

				setAnnunciator("#annDNALoad", loaded);
				setAnnunciator("#annDNANoLoad", !loaded);
				setAnnunciator("#annDNASplice", (loadedDna && loadedDna.isSplicing))
				annunciatorHolder.dnaLoaded = loaded;
			}
		};

		/* GENERAL VARS */
		var viewPage = "",
				loadedDna = null,
				exposedSlot = 0,
				src = "123456",
				remoteHandlers = {},
				bSuppressXmit = false,
				actPage = 0;
		/*
		var dummyData = {handleManipCallback:['{"success":true,"newSeq":"0001FFF000AAAA03000C000751878||189FFF|0B3|DEADBEEF0"}',
																		'{"success":true,"newSeq":"0001FFF0FFAA1A03000C000751878||189FFF|0B3|DEADBEEF0"}'],
									handleAnalysisTestCallback: ['{"valid":true, "stable":1, "trans":-1, "seqs":["124", "ABC", "DEF", "FED", "CBA"], "conf":[80, 60, 40, 20, 0], "pred":25.1234568, "buttons":"DEADBEEF0"}',
																				'{"valid":true, "stable":1, "trans":1, "seqs":["246", "ABC", "DEF"], "conf":[80, 60, 40], "pred":50, "buttons":"CAFEBABE1"}'],
									handleSplicePredCallback: ['{"pred":1}', '{"pred":2}', '{"pred":4}'],

									handleSpliceCompletionCallback: ['{"success":1, "newSeq":"0001000F00AAAA03000C000751878||189FFF|0B3|DEADBEEF0"}', '{"success":0, "newseq":""}']


																		};
		*/

	function setRef(ref) {
		src = ref;
		xmit({ackref:1});
	}
	window.setRef = setRef;

	function initializeUI () {
		/*BIND MAIN MENU BUTTON LISTENER*/
		$("#mainMenu > .button").on("click", function() {
			if($(this).hasClass("button-disabled")) {return;}

			handleMainMenuClick(this.id);
		});
		/*BIND SLOT CONTROL BUTTON LISTENER*/
		$("#btnCloseSlot, #btnEjectSample").click( function(){handlePushButtonClick(this, handleExposeButtons);});

		/*BIND DNA ANALYSIS CONTROL LISTENERS*/
		$("#btnClrAnalysisCurr, #btnAnalysisLoad, #btnAnalysisDoTest").click(function() {handlePushButtonClick(this, handleGeneralAnalysisButtonClick);});

		$(".display-known").click(function () {handlePushButtonClick(this, displayKnown);});

		/*BIND MANIPULATOR CONTROL BUTTON LISTENER*/
		$("#manipHolder .button").on("click", function(){ handlePushButtonClick(this, handleManipulatorButton);});

		/*BIND SPLICING CONTROL BUTTON LISTENER*/
		$("#spliceButtons .button").click(function() {handlePushButtonClick(this, handleSpliceCommenceButtonClick);});
		$(".btn-seq-off").click(function() {handlePushButtonClick(this, handleSpliceTargetOffsetClick);});
		$("#spliceActions .button").click(function() {handlePushButtonClick(this, handleSpliceActionClick);});
		$("#btnSpliceFinish").click(function() {handlePushButtonClick(this, handleSpliceFinishClick);});

		$("#btnSpliceFinish").click(function() {handlePushButtonClick(this, handleSpliceFinishClick);});

		$(".helpTextItem").mouseenter(function() {displayHelpText(this);});
		$(".helpTextItem").mouseleave(function() {clearHelpText();});


		/* INITIALIZATION STUFF*/
		setActivePage(0);
		createDnaSlots(3);
		createSplicingDnaSlots(3);
		updateAnalysisControlElements();
		updateSpliceCommenceButtons();
		updateMainMenuButtons();
		//debug_createData();
		updateLoadedDependents();
		//debug_createDNAbuttons();
	}

	function clearHelpText()
	{
		$("#manipHelp").html("");
		$("#analyzerHelp").html("");
	}

	function displayHelpText(element)
	{
		switch(element.id)
		{
			case "helpAdvSpeed":
				$("#manipHelp").html("Advance Speed determines how quickly your pathogen will advance through its stages.");
				break;
			case "helpSupThreshold":
				$("#manipHelp").html("Suppression Threshold determines how hard your pathogen is to suppress. Higher values will require more of the suppressant chem or higher external suppression factors.");
				break;
			case "helpSpread":
				$("#manipHelp").html("Spread determines how easily your pathogen will spread. How this expresses itself depends on the symptoms, for instance, a symptom that spreads via pathogen clouds might make clouds more often, while a symptom that spreads on hugs might have a higher chance per hug.");
				break;
			case "helpStages":
				$("#manipHelp").html("This determines how many stages your pathogen can go through. This largely depends on the microbody, though rarely a pathogen can mutate to have less or more stages. This ranges from 1-5. At higher stages a pathogen's symptoms will generally have stronger effects. Different microbody types also trigger their symptoms at different rates depending on the stage.");
				break;
			case "helpSymptomaticity":
				$("#manipHelp").html("If this is 0 your pathogen will not trigger its symptoms.");
				break;
			case "helpSupCode":
				$("#manipHelp").html("This code determines what the pathogen is supressed by. If you see two pathogens with the same code, you know that they will have the same suppressant.");
				break;
			case "helpCapacity":
				$("#manipHelp").html("This determines how many symptom segments you can splice onto a pathogen without it collapsing. For instance, a tier 5 symptom would cost 5 capacity, since it is made of 5 segments.");
				break;
			case "helpMaxStats":
				$("#manipHelp").html("This determines the total amount of points that can be spread among the various stats like Advance Rate, Suppression Threshold, and Spread.");
				break;
			case "btnClrAnalysisCurr":
				$("#analyzerHelp").html("Clear the currently assembled sequence of segments in Current Analysis");
				break;
			case "annStableLb":
			case "annStableYes":
			case "annStableNo":
				$("#analyzerHelp").html("Shows if the last tested sequence of segments is stable. If it is stable, that means that it is a valid symptom that you can use in a pathogen!");
				break;
			case "annTransLb":
			case "annTransYes":
			case "annTransNo":
				$("#analyzerHelp").html("Shows if the last tested sequence of segments is transient. If it is transient, that means that there is at least one valid symptom that starts with this sequence, but you will need to add more segments at the end to find it!");
				break;
			case "transTypesGood":
				$("#analyzerHelp").html("If the last analyzed sequence of segments was transient, this shows you how many of the symptoms that start with it are considered beneficial to humans.");
				break;
			case "transTypesBad":
				$("#analyzerHelp").html("If the last analyzed sequence of segments was transient, this shows you how many of the symptoms that start with it are considered harmful to humans.");
				break;
			case "stableType":
				$("#analyzerHelp").html("If the last analyzed sequence of segments was stable, this shows you if it was a symptom that is considered beneficial or harmful to humans.");
				break;
			case "btnAnalysisLoad":
				$("#analyzerHelp").html("This will destroy your currently loaded pathogen and give you its symptom segments to use for building sequences and analyzing them. Probably do not do this if you do not have a backup of your pathogen!");
				break;
			case "btnAnalysisDoTest":
				$("#analyzerHelp").html("Test the currently assembled sequence of segments to find out if it is stable and/or transient. If it turns out to be stable, you will keep it and can experiment further, but if not those segments will be lost.");
				break;
			case "knownAnalyzer":
				$("#analyzerHelp").html("Shows a list of sequences of segments you have already tried and whether or not they were stable and/or transient.");
				break;
		}
	}

	function setActivePage(page) {
		$(".dataPage").hide();
		var id = "";
		switch (page) {
			case 1: //Loader
				viewPage = "#dpLoadSave";
				 id="btnLoadSave";
				break;
			case 2: //Load / Save DNA
				viewPage = "#dpManip";
				id="btnManip";
				break;
			case 3: //Splicing DNA selection
				viewPage = "#dpSplice1";
				id="btnSplice";
				break;
			case 4://Splice in progress
				viewPage = "#dpSplice2";
				id="btnSplice";
				break;
			case 5: //Tester
				viewPage = "#dpTester";
				 id="btnTester";
				break;
			default: //Welcome
				viewPage = "#dpWelcome";
				id="btnRetMain";
		}
		if(page < 1 || page > 5) {
			page = 0;
		}
		if(page != 4) {
			xmit({setstate:1,newstate:page});
		}
		actPage=page;
		$("#mainMenu > .button").removeClass("button-selected");
		$("#" + id).addClass("button-selected");
		$(viewPage).show();
	}

	//Worker functions

	/*
	MANIPULATION
	*/
	/* VARS */
	var mutationData = new mutationHolder(),
		manipBusy = false;

	/* WORKERS */

	function mutationHolder(adv, sth, spr) {

		if (adv === undefined) {
			this.adv = 0;
		} else {
			this.adv = adv;
		}

		if (sth === undefined) {
			this.sth = 0;
		} else {
			this.sth = sth;
		}

		if (spr === undefined) {
			this.spr = 0;
		} else {
			this.spr = spr;
		}
	}

	function doManipulation(task) {
		if(typeof(task) !== 'string') {
			return;
		}
		manipBusy = true;
		var taskList = task.split("=");
		if (taskList.length !== 2) {
			//Malformed task
			return;
		}
		updateManipReady();
		var out = {manip:taskList[0],dir:taskList[1]};
		xmit(out, "handleManipCallback");
	}

	/* HANDLERS */
	function handleManipulatorButton(clicked) {
		doManipulation( $(clicked).attr("data-tsk"));

	}

	function handleManipCallback(data) {
		//'{"success":0,"newSeq":"0001000F00000003000C000751878||189|0B3|240|B3A"}']
		if (data != null) {
			manipBusy=false;
			var mutInfo = data.mutInfo;
			setAnnunciator("#aMutAck", data.success);
			setAnnunciator("#aMutNack", !data.success);
			if (!data.success) {
				loadedDna = null;
			}
			if(data.success && data.newseq) {
				loadedDna.seq = data.newseq;
			}
			updateLoadedDependents(false, true);
			updateManipReady();
		}
	}
	remoteHandlers.handleManipCallback = handleManipCallback;

	function parseDnaStringToManip(sDNA) {
		var dat = [], i, mutObj = new mutationHolder();
		if (typeof(sDNA) === 'string' && sDNA.length > 24) {
			var s;
			for ( i = 4; i < 24; i+=4) {
				s = sDNA.substr(i, 4);
				dat.push(hex2signedint(s));
			}

			i = 0;
			for (var k in mutObj) {
				mutObj[k] = dat[i++];
			}
		}
		return mutObj;
	}

	function hex2signedint(hex) {
		var a = parseInt(hex, 16),
				bytes = hex.replace('0x','').length,
				msb = 1 << ((bytes * 4) -1);
		if ((a & msb) > 0 ) {
			a -= (msb << 1) - 1
		}
		return a;
	}

	function safeSetMutationData(bExternal) {
		if(bExternal === undefined) {bExternal=false;}
		var dat;
		if(loadedDna) {
			dat = parseDnaStringToManip(loadedDna.seq);
		} else {
			dat = new mutationHolder();
		}
		updateManipList(bExternal, dat);
	}

	/* UPDATERS */
	function updateManipList(bExternal, newData) {
		if(bExternal === undefined) {bExternal=false;}
		if(newData===undefined) {newData=null;}
		//Clear update info on the manipulation list
		$("#manipHolder .text-field").removeClass("tf-c-red");

		var data = newData ? newData : mutationData;
		for(var k in data) {
			var t = $("#txt" + k.charAt(0).toUpperCase() + k.slice(1,3));
			if(t.hasClass("text-field")) {
				t.text(data[k]);
				if(bExternal && data[k] !== mutationData[k]) {
					safeAddClass(t, "tf-c-red");
				}
			}
			if(newData && mutationData.hasOwnProperty(k)) {
				mutationData[k] = data[k];
			}
		}
	}

	function updateManipReady() {
		var bReady = true;
		manipBusy = manipBusy && bReady; //Can't be busy if it's not ready.
		setButtonEnabled("#manipHolder .button", bReady);
		bReady = bReady && !manipBusy;	//Can't be ready if it's busy
	}


	/*
	ANALYSIS
	*/

	/* VARS */
	var curSeq = [], prevSeq = [],
	iStable = 0, iTrans = 0, iStableType = "", iTransGood = "", iTransBad = "";

	/* WORKERS */
	function seqEntry(seq, certainty) {
		this.seq = seq;
		if(certainty != null) {
			this.certainty = Math.min(100, Math.max(certainty*100, 0));
		} else {
			this.certainty = null;
		}
		this.getColour = function () {
			var hexComp = function(c) {
				c = Math.round(c).toString(16);
				return c.length === 1 ? '0' + c : c;
			},
			r = 255 * (100 - this.certainty) / 100;
			g = 255 * this.certainty / 100;
			return '#' + hexComp(r) + hexComp(g) + '00';
		};
	}

	function displayKnown() {
		xmit({showknown:1});
	}

	function addSequence(seq, ind) {
		if(curSeq.length >= 5) {
			return;
		}
		curSeq.push(new seqEntry(seq));
		updateAnalyzerSequence("#currAnalysis", curSeq);
		updateAnalysisControlElements();
		if(ind !== 'undefined' && ind >= 0) {
			xmit({analysisappend:ind});
		}
	}

	function clearAnalysisBuffer(skipTransmit) {
		if(curSeq.length > 0) {
			curSeq = [];
			updateAnalyzerSequence("#currAnalysis", null);
			updateAnalysisControlElements();
			if(!skipTransmit) { xmit({analysisclear:1}); }

		}
	}

	function doAnalysisTest() {
		var s = "";
		for(var i = 0; i < curSeq.length; i++) {
			s += curSeq[i].seq;
		}
		var d = {};
		d.analysisdo = s;
		xmit(d, "handleAnalysisTestCallback");
	}

	function doAnalysisLoad() {
		if(!loadedDna) {return;}
		var buttons = [];
		var dnaSequence = loadedDna.seq;
		dnaSequence = dnaSequence.slice(dnaSequence.search(/[\w\d]{3}\|\|/));
		dnaSequence = dnaSequence.replace(/\|/g, "");

		for(var i = 0; i < dnaSequence.length; i+=3) {
			buttons.push(dnaSequence.slice(i, i+3));
		}
		loadedDna = null;
		xmit({analysisdestroy:1})
		updateAnalysisButtons(buttons);
		updateLoadedDependents();
	}

	/* HANDLERS */

	function handleAnalysisComponentClick(clicked) {
		if(curSeq.length >= 5) {
			return;
		}
		var seq = $(clicked).text();
		var ind = $(clicked).index();
		$(clicked).remove();
		addSequence(seq, ind);

	}

	function handleGeneralAnalysisButtonClick(clicked) {
		var id = clicked.id;
		switch (id) {
			case "btnAnaDispKno":
				displayKnown();
				break;
			case "btnClrAnalysisCurr":
				clearAnalysisBuffer();
				break;
			case "btnAnalysisLoad":
				doAnalysisLoad();
				break;

			case "btnAnalysisDoTest":
				doAnalysisTest();
				break;
		}
	}

	function handleAnalysisTestCallback(data) {
		/*
		Expected response:
		{valid:true/false,
			stable:1,0,-1,
			trans,1,0,-1,
			seqs:["123", "456" ...]
			conf:[25, 100 ...],
			pred:25.24561
			buttons:"DEADBEEF0 ..."}
		*/
		setAnnunciator("#annErrNack", !data.valid);

		if(data.valid) {
			prevSeq = [];
			iStable = data.stable;
			iTrans = data.trans;
			iStableType = data.stableType;
			iTransGood = data.transGood;
			iTransBad = data.transBad;
			var s = data.seqs, c = data.conf;

			if(s.length === c.length) {
				var minLen = Math.min(s.length, 5);
				for (var i = 0; i < minLen; i++) {
					prevSeq.push(new seqEntry(s[i], c[i]));
				}
			} else {
				for (var i = 0; i < s.length; i++) {
					prevSeq.push(new seqEntry(s[i]));
				}
			}
			if(iStable < 0 && !data.noclear) { clearAnalysisBuffer(true); }


			updateAnalyzerSequence("#prevAnalysis", prevSeq);
			//updateAnalysisButtonsFromString(data.buttons);
			updateAnalysisControlElements();

		} else {
			clearAnalysisBuffer(true);
			xmit({analysisupdate:1}); //Should be handled via regular analysis screen update handler
		}

		//Process data, set annunciators.
		/*
		Send entire current buffer to server. It will validate this.
		If it's valid:
		Set annunciators stable / transient. Update previous analysis with data.
		If not stable clear current analysis.
		If invalid:
		Set NACK annunciator.
		Clear current analysis buffer
		Update testing buffer
		Optional: gib user (f u href butte)

		*/
	}
	remoteHandlers.handleAnalysisTestCallback = handleAnalysisTestCallback;

	/* UPDATERS */
	function updateAnalyzerSequence(id, newList) {
		$(id + " .text-field").text("");
		if(newList) {
			for(var i = 0; i < newList.length; i++) {
				var s = newList[i],
				c = null,
				t = s.seq;

				if(s.certainty !== null) {
					c = s.getColour();
					t = "<span style='color:" + c +";'>" + t + "</span>"
				}
				$(id + i).html(t);
			}
		}
	}

	function updateAnalysisResult(id, newResult) {
		$(id + " .text-field").text("");
		$(id).html("<span>" + newResult + "</span>");
		if($(id).hasClass("a-green-on"))
		{
			$(id).removeClass("a-green-on");
		}
		else if($(id).hasClass("a-red-on"))
		{
			$(id).removeClass("a-red-on");
		}
		if(newResult == "Good") {
			safeAddClass(id, "a-green-on");
		} else if(newResult == "Bad")
		{
			safeAddClass(id, "a-red-on");
		}
		return 0;
	}

	function updateAnalysisControlElements() {
		setAnnunciator("#annStableYes", iStable == 1);
		setAnnunciator("#annStableNo", iStable == -1);

		setAnnunciator("#annTransYes", iTrans == 1);
		setAnnunciator("#annTransNo", iTrans == -1);

		updateAnalysisResult("#stableType", iStableType);
		updateAnalysisResult("#transTypesGood", iTransGood);
		updateAnalysisResult("#transTypesBad", iTransBad);


		var invalid = !loadedDna || loadedDna.isSplicing;
		setAnnunciator("#annErrSample", invalid);
		setButtonEnabled("#btnAnalysisLoad", !invalid)

		invalid = curSeq.length >= 5;
		setAnnunciator("#annErrBuffer", invalid);
		setButtonEnabled("#analyzeComponents .button", !invalid);

		invalid = curSeq.length === 0;
		setAnnunciator("#annErrData", invalid);
		setButtonEnabled("#btnAnalysisDoTest", !invalid);
	}

	function updateAnalysisButtonsFromString(s) {
		var bList = [];

		for(var i = 0; i < s.length; i+=3) {
			bList.push(s.slice(i, i+3));
		}
		updateAnalysisButtons(bList);
	}

	function updateAnalysisButtons(buttonList) {
		var holder = $("#analyzeComponents");
		holder.empty();
		if(typeof(buttonList) === "object") {
			for(var i = 0; i < buttonList.length; i++) {
				$("<div>", {
					'class': 'button btn-tinyish',
					id: 'anaComp' + i
				}).appendTo(holder).text(buttonList[i]);
			}
			//Bind our listener
			$("#analyzeComponents .button").click( function() {handlePushButtonClick(this, handleAnalysisComponentClick);});
		}
	}

	/*
	DNA LOAD / SAVE
	*/

	/* VARS */
	var dnaSlots = [],
		dnaDetails = [];

	/* WORKERS */
	function doLoadDna(slot) {
		var index = slot-1, //0-based
		dna = dnaDetails[index],
		slotObj = dnaSlots[index];
		if(loadedDna === null && dna.seq)  {
			xmit({load:slot});
			loadedDna = dna;
			dnaDetails[index] = new dnaSlotInfo();
			updateLoadedDependents();
		}
		doExposeSlot(0);
	}

	function doSaveDna(slot) {
		var index = slot-1, //0-based
			dna = loadedDna,
			target = dnaDetails[index];

		if(loadedDna && !target.seq)  {
			xmit({save:slot});
			dnaDetails[index] = loadedDna;
			loadedDna = null;
			updateLoadedDependents();
			updateDnaSlot(slot);
		}
	}

	function doExchangeDna(slot) {
		var index = slot -1,
				lDna = loadedDna,
				tDna = dnaDetails[index];
				temp = lDna;
				if(lDna && tDna.seq) {
					xmit({exchange:slot});
					loadedDna = tDna;
					dnaDetails[index] = temp;
				}
				updateLoadedDependents(true);
				updateDnaSlot(slot);
				doExposeSlot(0);
	}

	function loadHelp(slot) {
		var dna = dnaDetails[slot -1].seq;
			if(loadedDna && dna) {
				doExchangeDna(slot);
			}
			else if(loadedDna)
			{
				doSaveDna(slot);
			}
			else if(dna)
			{
				doLoadDna(slot);
			}
	}

	function doClearDna(slot) {
		xmit({remove:slot});
		dnaDetails[slot-1] = new dnaSlotInfo();
		updateDnaSlot(slot);
	}

	function doExposeSlot(slot, bSuppressXmit) {
		if(bSuppressXmit === undefined) {bSuppressXmit = false;}
		var oldSlot = exposedSlot;
		exposedSlot = slot;
		if (oldSlot > 0) {
			dnaDetails[oldSlot-1].exposed = 0;
			updateDnaSlot(oldSlot);
		}
		var output;
		if(slot > 0) {
			dnaDetails[slot-1].exposed = 1;
			updateDnaSlot(slot);
			output = {expose:slot};
		} else {
			output = {lock:1};
		}
		if(!bSuppressXmit && oldSlot != exposedSlot) {
			xmit(output);
		}
		updateExposedIndicator();
		updateManipReady();
		updateSpliceCommenceButtons();
	}

	function createDnaSlots(num) {
		dnaSlots = [];
		$("#dnaSlotHolder").empty();
		var finalObj = null;
		var tempObj = null;

		for (var i = 1; i <= num; i++) {
			//Main div
			finalObj = $("<div>", {
						id: "dnaSlot" + i,
						'class':'dna-slot',
						'data-id': i
					});
			//Container to hold values
			tempObj = $("<div></div>", {
									'class':'noborder'
									}).appendTo(finalObj);
			$("<div>", {
				id: 'btnDnaXchg' + i,
				'class':'button btn-small',
			}).appendTo(tempObj).text("LOAD");
			$("<div>", {
				id: 'btnDnaClear' + i,
				'class':'button btn-small',
			}).appendTo(tempObj).text("DISCARD");
			$("<div>", {
				id: 'btnDnaEject' + i,
				'class':'button btn-small',
			}).appendTo(tempObj).text("EJECT");

			$("<div>", {
				id: 'btnSpliceSource' + i,
				'class':'button btn-small',
			}).appendTo(tempObj).text("SPLICE");
			//new tempObj for the next row
			tempObj = $("<div></div>", {
									'class':'noborder'
									}).appendTo(finalObj);
			$("<div>", {id: 'dnaSequence' + i, 'class':"text-field tf-long"}).appendTo(tempObj);

			//Append finalObj to the holder
			finalObj.appendTo("#dnaSlotHolder");
			dnaSlots.push(finalObj);
		}

		//Attach our event handler
		$(".dna-slot .button").on("click", function() {
			var number = $(this).closest('.dna-slot').attr('data-id');
			handleDNAClick(number, this.id, this);
		});
	}

	function dnaSlotInfo(seq, pathogenName, pathogenType, isSplicing) {
		if(seq === undefined) {
			this.seq = null;
		}else {
			this.seq = seq;
		}

		if(pathogenName === undefined) {
			this.pathogenName = null;
		}else {
			this.pathogenName = pathogenName;
		}

		if(pathogenType === undefined) {
			this.pathogenType = null;
		} else {
			this.pathogenType = pathogenType;
		}

		if(isSplicing === undefined) {
			this.isSplicing = null;
		} else {
			this.isSplicing = isSplicing;
		}
	}

	/* HANDLERS  */
	function handleDNAClick(slot, id, clicked) {
		if(!handlePushButtonClick(clicked)) {return;}

		var detClick = id.slice(0, id.length - slot.toString().length);
		switch(detClick) {
			case "btnDnaXchg":
				loadHelp(slot);
				break;
			case "btnDnaClear":
				doClearDna(slot);
				break;
			case "btnDnaEject":
				doExposeSlot(slot);
				doEjectSample();
				doExposeSlot(0);
				break;
			case "btnSpliceSource":
				setSpliceSource(slot);
				doExposeSlot(0);
				beginSplice();
				break;
		}
	}

	/* UPDATERS */

	function updateLoadedSection(cancGlobalUpdate) {
		if (loadedDna) {
			$("#txtPName").text(loadedDna.pathogenName);
			$("#txtPType").text(loadedDna.pathogenType);
			$("#txtPSeq").text(loadedDna.seq);
			$("#txtStag").text(loadedDna.pathogenStages);
			$("#txtSymp").text(loadedDna.pathogenSymptomaticity);
			$("#txtSupCode").text(loadedDna.pathogenSupCode);
			$("#txtCap").text(loadedDna.pathogenCap==-1?"∞":loadedDna.pathogenCap);
			$("#txtMaxStats").text(loadedDna.pathogenMaxStats);
		} else {
			$("#txtPName").text("");
			$("#txtPType").text("");
			$("#txtPSeq").text("");
			$("#txtStag").text("");
			$("#txtSymp").text("");
			$("#txtSupCode").text("");
			$("#txtCap").text("");
			$("#txtMaxStats").text("");
		}
		annunciatorHolder.setLoadAnn(loadedDna);
		if(!cancGlobalUpdate) {
			updateAllDnaSlots();
		}
	}

	function updateAllDnaSlots() {
		for(var i = 1; i <= dnaSlots.length; i++) {
			updateDnaSlot(i);
		}
	}

	function updateDnaSlot(slot) {
		var t = dnaSlots[slot-1],
				dna = dnaDetails[slot - 1];
		if (dna == null)
			dna = dnaDetails[slot - 1] = new dnaSlotInfo();
		if(dna.seq == null) {
			setAnnunciator("#annDnaEmp" + slot, true);
			$("#dnaSequence" + slot).text("");
			setButtonEnabled("#btnDnaClear" + slot, false);
		} else {
			setAnnunciator("#annDnaEmp" + slot, false);
			$("#dnaSequence" + slot).text(dna.seq);
			setButtonEnabled("#btnDnaClear" + slot, true);
		}

		if( dna.seq !== null || (loadedDna && !loadedDna.isSplicing)) {
			setButtonEnabled("#btnDnaXchg" + slot, true);
		} else {
			setButtonEnabled("#btnDnaXchg" + slot, false);
		}
		if( !(loadedDna && loadedDna.isSplicing) ) {
			if(slot == exposedSlot ) {
				setAnnunciator("#annDnaExp" + slot, true);
				setButtonEnabled("#btnDnaSlotExpose" + slot, false);
				updateExposedIndicator();
			} else {
				setAnnunciator("#annDnaExp" + slot, false);
				setButtonEnabled("#btnDnaSlotExpose" + slot, true);
			}
		} else {
			setButtonEnabled("#btnDnaSlotExpose" + slot, false);
		}
		updateSpliceSlot(slot); //Tied in with the load / save functionality
	}



	/*
	SPLICING
	*/

	$.fn.draggablePointer = function () {
		//Function makes a left or right pointer element movable
		var $this = this;
		var ns = 'draggable_' + (Math.random() + '').replace('.', '');
		var mm = 'mousemove.' + ns;
		var mu = 'mouseup.' + ns;
		var $w = $(window);
		var left = -Number.MAX_VALUE;
		var right = Number.MAX_VALUE;
		var $prev = $this.prev();
		var $next = $this.next();
		var $parent = $this.parent();
		var leftScroll = $parent.offset().left + 50;
		var rightScroll = $parent.offset().left + $parent.outerWidth() - 50;
		var maxScroll = $parent[0].scrollWidth - $parent[0].clientWidth;
		var autoScrolling = false;
		var scrollDir = 'left';

		function autoScrollParent(leftOrRight, cursorPos, cont) {
			if ((!autoScrolling || cont) && leftOrRight === scrollDir) {
				autoScrolling = true;
				//Scroll left or right 15px every 50ms
				$parent.animate({ scrollLeft: '+=' + (leftOrRight === 'left' ? '-' : '') + '15px' },
								50,
								function () {
									//After scrolling, update pointer position and
									//continue scrolling if we're still on the edge
									updateCurrent();
									moveLeft(cursorPos);
									moveRight(cursorPos);
									if (autoScrolling) {
										autoScrollParent(leftOrRight, cursorPos, true);
									}
								});
			}
		}

		function setPrev($elem) {
			//Set left value and update $prev for the given $elem
			if ($elem.length) {
				if ($elem.prev(".left-ptr").length) {
					left = -Number.MAX_VALUE;
				} else {
					left = $elem.offset().left + $elem.width() / 2;
					$prev = $elem;
				}
			} else {
				left = -Number.MAX_VALUE;
			}
		}

		function setNext($elem) {
			//Set right value and update $next for the given $elem
			if ($elem.length) {
				if ($elem.next(".right-ptr").length) {
					right = Number.MAX_VALUE;
				} else {
					right = $elem.offset().left + $elem.width() / 2;
					$next = $elem;
				}
			} else {
				right = Number.MAX_VALUE;
			}
		}

		function updateCurrent() {
			setPrev($this.prev());
			setNext($this.next());
		}

		function moveLeft(cursorPos) {
			//Given a cursor x positition, loops through all previous elements
			//to find which one the cursor is inbetween, then moves the currently selected
			//element to that position
			var move = false;
			while (cursorPos < left) {
				setPrev($prev.prev());
				move = true;
			}
			if (move) {
				$this.insertBefore(left === -Number.MAX_VALUE ? $prev : $prev.next());
				setNext($this.next());
			}
		}

		function moveRight(cursorPos) {
			var move = false;
			while (cursorPos > right) {
				setNext($next.next());
				move = true;
			}
			if (move) {
				$this.insertAfter(right === Number.MAX_VALUE ? $next : $next.prev());
				setPrev($this.prev());
			}
		}

		$this.mousedown(function (ev) {
			ev.preventDefault();
			$("body").addClass("dragging");
			updateCurrent();
			$w.on(mm, function (ev) {
				ev.preventDefault();
				ev.stopPropagation();
				//If cursor near either edge and there's room to scroll, scroll that way
				if ($parent.scrollLeft() > 0 && ev.pageX < leftScroll) {
					scrollDir = 'left';
					autoScrollParent(scrollDir, ev.pageX);
				} else if ($parent.scrollLeft() < maxScroll && ev.pageX > rightScroll) {
					scrollDir = 'right';
					autoScrollParent(scrollDir, ev.pageX);
				} else {
					//Otherwise move the pointer and stop scrolling
					moveLeft(ev.pageX);
					moveRight(ev.pageX);
					autoScrolling = false;
				}
			});
			$w.on(mu, function () {
				$("body").removeClass("dragging");
				autoScrolling = false;
				$w.off(mm + ' ' + mu);
				handlePointerFinishSort($this);
			});
		});
		return this;
	};

	/* VARS */
	var spliceSourceDna = null,
		selectedSpliceSource = 0;
	/* WORKERS */

	function createSplicingDnaSlots(num) {
		$("#spliceSlots").empty()
		for (var i = 1; i <= num; i++) {

			var finalObj = $("<div></div>", {
				id: "spliceSlot" + i,
				'class': 'dna-slot',
				'data-id': i
				}).appendTo("#spliceSlots");

			//ROW OF ANNUNCIATORS + BUTTONS

			//SEQUENCE LISTING
			var tempObj = $("<div></div>", {
				'class':'noborder'
			}).appendTo(finalObj);
			$("<div></div>", {
				id:'txtSpliceSeq' +i,
				'class':'text-field tf-long'
				}).appendTo(tempObj);
			tempObj = $("<div></div>", {
				'class':'noborder'
			}).appendTo(finalObj);
			//Splice button
			/*
			$("<div></div>", {
				id:'btnSpliceSource' + i,
				'class':'button btn-small'
			}).appendTo(tempObj).text("SPLICE");
			*/
		}
		//Bind listeners
		$("#spliceSlots .button").click(function() {handlePushButtonClick(this, handleSpliceSelectionClick);});
	}

	function setSpliceSource(slot) {
		var lastSlot = selectedSpliceSource;
		selectedSpliceSource = slot;
		if (lastSlot > 0) {
			updateSpliceSlot(lastSlot);
		}
		if (selectedSpliceSource > 0) {
			updateSpliceSlot(selectedSpliceSource);
		}
		if(slot === 0) {
			xmit({cancel:1});
		} else {
			xmit({splice:slot});
		}
		updateSpliceCommenceButtons();
	}

	function beginSplice() {
		//Validate UI state
		var dna = dnaDetails[selectedSpliceSource-1];
		if(exposedSlot > 0 || dna.seq == null || !loadedDna) { return; }
		//Clear source DNA
		spliceSourceDna = dna;
		dnaDetails[selectedSpliceSource-1] = new dnaSlotInfo();
		//Set DNA status
		selectedSpliceSource=0;
		loadedDna.isSplicing = true;

		xmit({beginsplice:1});
		updateLoadedDependents();
		setActivePage(4);
		updateMainMenuButtons();
	}

	function cancelSplice() {
		setSpliceSource(0);
	}


	function parseDna(jqTarget, dnaData) {
		var t = $(jqTarget); //t = #txtSpliceTarget, #txtSpliceSource
		t.empty();
		if(typeof (dnaData) !== 'string') {return;}

		//Setup to create sequence to add
		var before_str = "<span class=\"sequence\">";
		var after_str = "</span>";
		var sequences = [];

		//Add all the dna sequence html strings to the sequence array
		var i = 0;
		while (i < dnaData.length) {
			var s = "";
			if(dnaData[i] === '|') {
				s = '|';
				i += 1;
			} else if(i + 3 <= dnaData.length) {
				s = dnaData.slice(i,i+3);
				i += 3;
			}
			sequences.push(before_str + s + after_str);
		}
		//Create two pointers and add them (position will be moved later)
		sequences.push('<span class="left-ptr"></span>');
		sequences.push('<span class="right-ptr"></span>');
		//Append the HTML to the target
		t.append(sequences.join(""));
		//Bind handlers
		$(".sequence", t).click(function () {handleSpliceSequenceClick(this);});
		$(".left-ptr, .right-ptr", t).each(function () {$(this).draggablePointer();});
	}

	function shiftSelectedSpliceSeq(jqT, dir) {
		//Get previous pointer indices
		var lptr_index = $(".left-ptr", jqT).index();
		var rptr_index = $(".right-ptr", jqT).index() - 2;
		//shift based on direction
		dir = dir / Math.abs(dir);
		//lptr_index += dir;
		rptr_index += dir;
		//Select sequence based on new indices
		sendSelectionUpdate(lptr_index, rptr_index, jqT.attr("id") === "spliceTargetField");
	}

	function doSpliceAction(dir) {
		//dir === 0 remove
		//dir === 1 add after
		//dir === -1 add before
		Math.min(Math.max(parseInt(dir), -1), 1); // -1 <= dir <= 1
		var s = $("#txtSpliceSource").children(".sequence.splice-selected"); //All selected source DNA sequences
		var t = $("#txtSpliceTarget").children(".sequence.splice-selected"); //All selected target DNA sequences
		//Variable that we will send to pathogen machine to do the splicing
		var splice = { splicemod: 1 };
		splice.direction = dir;
		splice.s_index = s.first().index() - 1; //-1 is adjustment for preceding pointer
		splice.t_index = dir > 0 ? t.last().index() - 1 : t.first().index() - 1; //If we're adding after, insert at the last target element
		splice.s_len = s.length;
		splice.t_len = t.length;
		xmit(splice, "setUIState");
	}

	function finishSplice() {
		xmit({splicefinish:1}, "handleSpliceCompletionCallback")
	}

	function updateSelectedSequences(lptr_index, rptr_index, jqT) {
		//Udate selections for a DNA sequence container based on the pointer indices
		var entries = $(".sequence", jqT);
		if (lptr_index >= 0 && rptr_index >= 0 && lptr_index < entries.length && rptr_index < entries.length && lptr_index <= rptr_index) {
			entries.removeClass("splice-selected"); //Deselect all selected elements
			//Get the sequences in between the selected indices
			var sel_entries = entries.slice(lptr_index, rptr_index + 1);
			//Select them
			sel_entries.addClass("splice-selected");
			//Updates the pointer positions based on their indices
			var left_ptr = $(".left-ptr", jqT).detach();
			var right_ptr = $(".right-ptr", jqT).detach();
			// Get object element
			var left_seq = jqT.children().get(lptr_index);
			var right_seq = jqT.children().get(rptr_index);
			// Insert pointers in correct positions
			left_ptr.insertBefore(left_seq);
			right_ptr.insertAfter(right_seq);
		}
		updateSpliceControls();
	}

	function sendSelectionUpdate(lptr_index, rptr_index, isTarget) {
		var d = { splicesel: 1 };
		d.lptr_index = lptr_index;
		d.rptr_index = rptr_index;
		if (isTarget) { d.target = 1; }
		xmit(d);
	}

	/* HANDLERS */
	function handleSpliceSelectionClick(clicked) {
		var slot = $(clicked).closest(".dna-slot").attr("data-id");
		if (slot == null) return;
		var id = clicked.id.slice(0, clicked.id.length - slot.toString().length);
		switch(id)  {
			case "btnSpliceSource":
				setSpliceSource(slot);
				doExposeSlot(0);
				beginSplice();
				break;
		}
	}

	function handleSpliceCommenceButtonClick(clicked) {
		switch (clicked.id) {
			case "btnSpliceBegin":
				beginSplice();
				break;
			case "btnSpliceCancel":
				cancelSplice();
				break;
		}
	}

	function handleSpliceSequenceClick(clicked) {
		//Takes in a .sequence and makes it the only one selected
		//get the target sequence index taking into account the pointer positions
		var index = $(clicked).index() - $(clicked).prevAll(".left-ptr, .right-ptr").length;
		sendSelectionUpdate(index, index, $(clicked).parent().attr("id") === "txtSpliceTarget");
	}

	function handlePointerFinishSort(jqT) {
		//Called whenever user is done dragging a pointer.
		//Updates selection based on where they stopped.
		var lptr_index = 0;
		var rptr_index = 0;
		if (jqT.is(".left-ptr")) {
			lptr_index = jqT.index();
			rptr_index = jqT.siblings(".right-ptr").index() - 2;
		}
		else {
			lptr_index = jqT.siblings(".left-ptr").index();
			rptr_index = jqT.index() - 2;
		}
		sendSelectionUpdate(lptr_index, rptr_index, jqT.parent().attr("id") === "txtSpliceTarget");
	}

	function handleSpliceTargetOffsetClick(clicked) {
		var t = $(clicked).closest(".splice-sequence"),
		d = $(clicked).attr("dir");
		shiftSelectedSpliceSeq(t, d);
	}

	function handleSpliceActionClick(clicked) {
		var d = $(clicked).attr("dir");
		doSpliceAction(d);
	}

	function handleSpliceFinishClick(clicked) {
		finishSplice();
	}


	function setSplicePred(pred) {
		/*Expects
		{pred:0,1,2,4 //Bitflags for SUCCESS, UNKNOWN and FAIL
		}
		*/
		setAnnunciator("#annPredSuccess", pred & 1);
		setAnnunciator("#annPredUnk", pred & 2);
		setAnnunciator("#annPredFail", pred & 4);
	}

	function handleSpliceCompletionCallback(data) {
		/*Expects
		{success:0,1 //If the splicing succeeded or not.
		newseq:"00011512452..." //The newly created DNA sequence
		}
		*/
		setAnnunciator("#annSpliceSuccess", data.success);
		setAnnunciator("#annSpliceFail", !data.success);

		if(data.success) {
			loadedDna.seq = data.newseq;
			loadedDna.isSplicing=false;
		} else {
			loadedDna = null;
		}
		//Clear source slot
		dnaDetails[selectedSpliceSource - 1] = new dnaSlotInfo();
		selectedSpliceSource = 0;
		setActivePage(1); //Go back to splice selection page when finished
		updateLoadedDependents();
		updateMainMenuButtons();

	}
	remoteHandlers.handleSpliceCompletionCallback = handleSpliceCompletionCallback;
	/* UPDATERS */
	function updateSpliceSlot(slot) {
		var dna = dnaDetails[slot -1];
		if (dna == null) {
			dna = dnaDetails[slot - 1] = new dnaSlotInfo();
		}
		//Annunciators

		if (dna.seq == null) {
			$("#txtSpliceSeq" + slot).text("");
			if(selectedSpliceSource == slot) {
				selectedSpliceSource=0;
			}
		} else {
			$("#txtSpliceSeq" + slot).text(dna.seq);
		}
		setAnnunciator("#annSpliceSource" + slot, slot == selectedSpliceSource);

		//BUTTONS
		setButtonEnabled("#btnSpliceLoad" + slot, dna.seq != null);
		setButtonEnabled("#btnSpliceSource" + slot, slot !== selectedSpliceSource && dna.seq != null);

	}

	function updateSpliceCommenceButtons() {
		var a = exposedSlot > 0,
				b = selectedSpliceSource > 0 && dnaDetails[selectedSpliceSource-1].seq != null,
				c = loadedDna != null;

		setAnnunciator("#annSpliceStatExp", a);
		setAnnunciator("#annSpliceStatSource", b);
		setAnnunciator("#annSpliceStatTarget", c);

		setButtonEnabled("#btnSpliceBegin", !a && b && c);
	}

	function updateSpliceControls() {
		var bValidSplice = loadedDna != null && loadedDna.isSplicing;
		//FINISH
		setButtonEnabled("#btnSpliceFinish", bValidSplice);
		//TARGET
		setButtonEnabled("#spliceTargetField .button", bValidSplice && $("#txtSpliceTarget .sequence").length > 1);
		setAnnunciator("#annSpliceTargetEmpty",  $("#txtSpliceTarget .sequence").length <= 0);

		//SOURCE
		setButtonEnabled("#spliceSourceField .button",  bValidSplice && $("#txtSpliceSource .sequence").length > 1);
		setAnnunciator("#annSpliceSourceEmpty",  $("#txtSpliceSource .sequence").length <= 0);

		//BUTTONS
		setButtonEnabled("#spliceActions .button[dir!='0']",  bValidSplice && $("#txtSpliceSource .splice-selected").length > 0);
		setButtonEnabled("#spliceActions .button[dir='0']",  bValidSplice && $("#txtSpliceTarget .splice-selected").length > 0);

	}

	function updateCompleteSpliceData(target, source) {
		//Update Splicing Source menu items
		parseDna("#txtSpliceTarget", target);
		parseDna("#txtSpliceSource", source);
		setAnnunciator("#spliceFinalButtons > .annunciator", false);
		setAnnunciator("#annPredSuccess", true);
	}

	/*
	GENERAL
	*/

	/* UI STATE UPDATER */
	function setUIState(data) {
		bSuppressXmit = true;
		//Which page was used last
		if(data.hasOwnProperty("actPage")) {
			setActivePage(data.actPage);
		}
		//Which DNA sequence is currently loaded
		if(data.hasOwnProperty("loadedDna")) {
			loadedDna = data.loadedDna;
			updateLoadedDependents(cancGlobalUpdate=true);
		}
		//The DNA slots themselves
		if(data.hasOwnProperty("dnaDetails") && typeof(data.dnaDetails) === 'object') {
			for(var i = 0; i < data.dnaDetails.length; i++) {
				var d = data.dnaDetails[i];
				if (!d) { d = new dnaSlotInfo();}
				dnaDetails[i] = d;
				updateDnaSlot(i+1);
			}
		}

		//If a slot is exposed
		if(data.hasOwnProperty("exposed")) {
			doExposeSlot(data.exposed, true);
		}

		//Splicing
		if(data.hasOwnProperty("splice")) {
			var s = data.splice;

			//{"source":'dna string', "sRaw":0, "target":'dna-string', "tRaw":1, "selected":0, "pred":(0,1,2,4)}

			if(s.hasOwnProperty("source") || s.hasOwnProperty("target")) {
				var source = null;
				if(s.source) {
					source = s.source;
				}
				var target = null;
				if(s.target) {
					target = s.target;
				}

				updateCompleteSpliceData(target, source);
			}
			if(s.hasOwnProperty("selected")) {
				setSpliceSource(s.selected);
			}

			if(s.hasOwnProperty("pred")) {
				setSplicePred(s.pred);
			}
			if(s.hasOwnProperty("selSource")) {
				var indices = s.selSource;
				//Index-1 because BYOND is 1-indexed
				updateSelectedSequences(indices.lptr_index - 1, indices.rptr_index - 1, $("#txtSpliceSource"));
			}
			if(s.hasOwnProperty("selTarget")) {
				var indices = s.selTarget;
				updateSelectedSequences(indices.lptr_index - 1, indices.rptr_index - 1, $("#txtSpliceTarget"));
			}
		}

		if (data.hasOwnProperty("analysis")) {
			var a = data.analysis;
			if(a.hasOwnProperty("curr")) {
				clearAnalysisBuffer(true);
				for(var i = 0; i < a.curr.length && i < 15; i+=3) {
					addSequence(a.curr.slice(i, i+3));
				}
			}
			if(a.hasOwnProperty("predeffect")) {
				$(".txtPredEffect").text((Math.round(a.predeffect * 100) / 100.0) + ' %'); //lol fuck you js
			}
			if(a.hasOwnProperty("buttons"))
				updateAnalysisButtonsFromString(a.buttons);
			if(a.hasOwnProperty("prev")) {
				a.prev.noclear = true;
				handleAnalysisTestCallback(a.prev);

			}
			updateAnalysisControlElements();
		}
		bSuppressXmit = false;
	}

	/* DATA TRANSMISSION */
	function xmit(data, callbackHandler) {
		if(bSuppressXmit || !typeof(data) == 'object' ) {
			return;
		}
		var params = [];
		for(var k in data) {
			params.push(encodeURI(k) + "=" + encodeURI(data[k]));
		}

		var target = "?src=" + src + ";" + params.join(";");
		window.location = target;
	}

	/* DATA RECEIPT */

	function receiveData(handler, data) {
		setAnnunciator("#annSynch", false);
		if(remoteHandlers[handler]) {
				data = JSON.parse(data);
				remoteHandlers[handler](data);
			}
	}

	/*WORKERS*/
	function doEjectSample() {
		if(exposedSlot > 0) {
			xmit({eject:1});
			dnaDetails[exposedSlot-1] = new dnaSlotInfo();
			updateDnaSlot(exposedSlot);
			updateExposedIndicator();
		}
	}

	function updateLoadedDependents(cancGlobalUpdate, externalManip ) {
		if(cancGlobalUpdate === undefined) { cancGlobalUpdate = false;}
		if(externalManip === undefined) {externalManip=false;}
		updateLoadedSection(cancGlobalUpdate);
		safeSetMutationData(externalManip);
		updateManipReady();
		updateAnalysisControlElements();
		updateSpliceCommenceButtons();
		updateMainMenuButtons();
	}

	/* HANDLERS */
	function handleMainMenuClick(id) {
		if($("#" + id).hasClass("button-disabled")) {return;}

		if(!isSplicing()) {	//Not splicing, everything's fine + dandy with the world.
			switch(id) {
				case "btnManip":
					setActivePage(2);
					break;
				case "btnSplice":
					setActivePage(3);
					break;
				case "btnTester":
					setActivePage(5);
					break;
				case "btnLoadSave":
					setActivePage(1);
					break;
				case "btnRetMain":
					setActivePage(0);
			}
		}
	}

	function handleExposeButtons(clicked) {
		switch (clicked.id) {
			case "btnCloseSlot":
				doExposeSlot(0);
				break;
			case "btnEjectSample":
				doExposeSlot(0);
				doEjectSample();
				doExposeSlot(0);
				break;
		}
	}

	function handlePushButtonClick(clicked, handler) {
		if($(clicked).hasClass("button-disabled")) {return 0;}
		$(clicked).addClass("button-selected");
		setTimeout(function() {$(clicked).removeClass("button-selected");}, 50);
		if(handler) {
			handler(clicked);
		}
		return 1;

	}

	/* UPDATERS */

	function updateExposedIndicator() {
		var expDna = dnaDetails[exposedSlot -1];
		if(exposedSlot > 0) {
			setAnnunciator("#annSlotExp", true);
			setButtonEnabled("#btnCloseSlot", true);
			$("#txtExpSlot").text(exposedSlot.toString());

		} else {
			setAnnunciator("#annSlotExp", false);
			setButtonEnabled("#btnCloseSlot", false);
			$("#txtExpSlot").text("0");
		}

		if(!expDna || expDna.seq === null) {
			setAnnunciator("#annSlotSample", false);
			setButtonEnabled("#btnEjectSample", false);
		} else {
			setAnnunciator("#annSlotSample", true);
			setButtonEnabled("#btnEjectSample", true);
		}
	}

	function updateMainMenuButtons() {
		if (!isSplicing()) {
			setButtonEnabled("#mainMenu > .button", true);
		}	else {
			setButtonEnabled("#mainMenu > .button", false);
			setActivePage(4);
			$("#mainMenu > .button").removeClass("button-selected");
			setButtonEnabled("#btnSplice", true)
			$("#btnSplice").addClass("button-selected");
		}
	}

	/*
	HELPERS
	*/
	function safeAddClass(ident, className) {
		if(!$(ident).hasClass(className)) {
			$(ident).addClass(className);
		}
	}

	function isSplicing() {
		return (loadedDna && loadedDna.isSplicing);
	}
	/* CONTROL SETTERS */
	function setAnnunciator(jqSel, bActive) {
		//Sets the state of an annunciator in a sane fashion
		var ann = $(jqSel);
		if(!ann.hasClass("annunciator")) {
			return 1;
		}
		var color = "red";
		if(ann.hasClass("a-green")) {
			color = "green";
		} else if (ann.hasClass("a-yellow")) {
			color = "yellow";
		}

		if(bActive) {
			safeAddClass(ann, "a-" + color + "-on");
		} else {
			ann.removeClass("a-" + color + "-on");
		}
		return 0;
	}

	function setButtonEnabled(jqSel, bEnable) {
		var btn = $(jqSel);
		if(!btn.hasClass("button")) {
			return 1;
		}
		if(bEnable) {
			btn.removeClass("button-disabled");
		} else {
			safeAddClass(btn, "button-disabled");
		}
	};
	remoteHandlers.setUIState = setUIState;
	/*
	DEBUG
	*/
	function debug_createData() {

		var dataObject = {src:'AB12CD', actPage:3, exposed:2,
			loadedDna:{seq:"00020006FFFDFFF60000FFF53142E||FCB055|6A86A8|0F4CC6CC6", pathogenName:"TEST", pathogenType:"gmcell", isSplicing:1},
			dnaDetails:[
				{seq:"00020006000500000000FFFB3142E||055", pathogenName:"ABC2", pathogenType:"bacteria", isSplicing:0},
				null,
				{seq:"00040003FFED0005FFF3FFEF51B8E||FCB", pathogenName:"ABC3", pathogenType:"parasite", isSplicing:0}
				],
			splice: {
				source:"123|ABC||321|CBAFED",
				sRaw:0,
				target:"ABC345DEF|ADE||DDA|DDF",
				tRaw:0,
				selected:0,
			},
			analysis: {
				curr:["ABC", "DEF", "123", "456"],
				prev:{
					valid:1,
					trans:1,
					stable:-1,
					seqs:["ABC", "DEF", "123", "456"],
					conf:[100, 75, 34, 15],
					pred:25,
					buttons:"FFFEEEDDDCCCAAA999888777666555444333222111000"
				}

			}
		};
		setUIState(dataObject);
	}

	function debug_createDNAbuttons() {
		var L = []
		for(var i = 0; i < 50; i++) {
			var s = Math.round(4096 * Math.random());
			s = '00' + s.toString(16);
			s = s.slice(s.length - 3);
			L.push(s.toUpperCase());
		}
		updateAnalysisButtons(L);
	}

	function debug_getCallbackDummyData( callbackHandler ) {
		var d = dummyData[callbackHandler];
		var r = null;
		if(typeof(d) === 'object') {
			var maxLen = d.length -1;
			r = d[Math.round(maxLen * Math.random())];
		}
		return r;
	}

	window.receiveData = receiveData;

	$(document).ready(initializeUI);
})(window, document, jQuery);
