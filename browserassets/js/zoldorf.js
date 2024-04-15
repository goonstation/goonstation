var itemlist = json
//var json = '[{"name": "Item 2", "path": "/obj/item/test2", "cost": "100"},{"name": "Item 1", "path": "/obj/item/test1", "cost": "25%"},{"name": "Item 3", "path": "/obj/item/test3", "cost": "75%"},{"name": "Item 4", "path": "/obj/item/test4", "cost": "300"}]'
//var itemlist = JSON.parse(raw)

var soulitems = []
var credititems = []
var CREDITS = creditplaceholder
var lastclicked
var waitforresponse = 0

String.prototype.includes = function (str) {
  var returnValue = false;

  if (this.indexOf(str) !== -1) {
    returnValue = true;
  }

  return returnValue;
}

function byond() {
    url = "?src=" + srcRef;
    currentIsKey = true;
    for(var i = 0; i < arguments.length; i++) {
        if(currentIsKey)
            url += ";";
        else
            url += "=";
        url += arguments[i];
        currentIsKey = !currentIsKey;
    }
    console.log(url);
    const Http = new XMLHttpRequest();
    Http.open("GET", url);
    Http.send();
}

function updatecredits(com,name,path,c,stock){
	if(com == "add"){
		CREDITS += parseInt(c);
	}else if(com == "rem"){
		if(!(c.toString().includes("%"))){
			CREDITS -= parseInt(c);
		}
		if(lastclicked.dataset.stock != "i"){
			lastclicked.dataset.stock = (parseInt(lastclicked.dataset.stock)-1).toString();
			if(lastclicked.tagName == "A") {
				if(parseInt(lastclicked.dataset.stock)==0){
					lastclicked.textContent = "--Out of Stock--";
				}
				var pricetag = lastclicked.parentElement.getElementsByTagName("P")
				pricetag[0].dataset.stock = lastclicked.dataset.stock.toString();
			}else if(lastclicked.tagName == "P") {
				var maintag = lastclicked.parentElement.getElementsByTagName("A")
				maintag[0].dataset.stock = lastclicked.dataset.stock.toString();
			}
		}
		
	}else if(com == "update"){
		if(!(c.toString().includes("%"))){
			CREDITS = parseInt(c);
		}
		if(stock != null) {
			var elementlist = document.getElementsByTagName("A")
			for(var i = 0;i<elementlist.length;i++){
				var elm = elementlist[i]
				if(/*(elm.textContent != null) && (elm.textContent == name) &&*/ (elm.dataset.path != null) && (elm.dataset.path == path)) {
					elm.dataset.stock = stock.toString();
					if(parseInt(elm.dataset.stock) == 0){
						elm.textContent = "--Out of Stock--";
					}
					var pricetag = elm.parentElement.getElementsByTagName("P")
					pricetag[0].dataset.stock = stock.toString();
				}
			}
		}
	}
	document.getElementById("creditreturn").textContent = "Return Credits: "+CREDITS.toString();
	waitforresponse = 0
}

function serverconfirm(com,cost){
	if(com == "return"){
		updatecredits("update",null,null,0);
		//waitforresponse = 0
	}else if(com == "spawn"){
		updatecredits("rem",null,null,cost,null);
		//waitforresponse = 0
	}
}

var boop = function(e){
	e.preventDefault();
	/*if(waitforresponse == 1){
		return;
	}*/
	waitforresponse = 1
	lastclicked = e.srcElement
	if(e.srcElement.id == "creditreturn") {
		byond("command","return","credits",CREDITS);
	}else{
		var path = e.srcElement.dataset.path
		var cost = e.srcElement.dataset.cost
		var stock = e.srcElement.dataset.stock
		if(cost.includes("%")){
			byond("command","soulspawn","path",path,"cost",cost,"stock",stock);
		}else if(cost <= CREDITS){
			byond("command","spawn","path",path,"cost",cost,"stock",stock);
		}
	}
}

window.onload = function(e) {
	//initialize items
	//loop through list and separate the items into a soul and credit lists
	for(var i = 0; i < itemlist.length; i++) {
		if(itemlist[i].cost.includes("%")) {
			soulitems.push(itemlist[i]);
		}else{
			credititems.push(itemlist[i]);
		}
	}
	
	//initialize soul items
	var soulitemdiv = document.getElementById("soulitems")
	var whichc = 1
	for(var i = 0; i < soulitems.length; i++) {
		var div = document.createElement("div")
		var linkchild = document.createElement("a")
		var cost = document.createElement("p")
		if(whichc == 1) {
			div.className = "link sitemcolor1";
			cost.className = "soulcolor1";
			whichc = 2;
		}else{
			div.className = "link sitemcolor2";
			cost.className = "soulcolor2";
			whichc = 1;
		}
		if(parseInt(soulitems[i].stock)==0){
			linkchild.textContent = "--Out of Stock--";
		}else{
			linkchild.textContent = soulitems[i].name;
		}
		linkchild.dataset.path = soulitems[i].path;
		linkchild.dataset.cost = soulitems[i].cost;
		linkchild.onclick = boop;
		cost.textContent = soulitems[i].cost;
		cost.dataset.path = soulitems[i].path;
		cost.dataset.cost = soulitems[i].cost;
		cost.onclick = boop;
		if(soulitems[i].stock != null){
			linkchild.dataset.stock = soulitems[i].stock;
			cost.dataset.stock = soulitems[i].stock;
		}
		div.appendChild(linkchild);
		div.appendChild(cost);
		soulitemdiv.appendChild(div);
	}
	
	//initialize credit items
	whichc = 1
	var credititemdiv = document.getElementById("credititems")
	var whichc = 1
	for(var i = 0; i < credititems.length; i++) {
		var div = document.createElement("div")
		var linkchild = document.createElement("a")
		var cost = document.createElement("p")
		if(whichc == 1) {
			div.className = "link citemcolor1";
			cost.className = "creditcolor1";
			whichc = 2;
		}else{
			div.className = "link citemcolor2";
			cost.className = "creditcolor2";
			whichc = 1;
		}
		if(parseInt(credititems[i].stock)==0){
			linkchild.textContent = "--Out of Stock--"
		}else{
			linkchild.textContent = credititems[i].name;
		}
		linkchild.dataset.path = credititems[i].path;
		linkchild.dataset.cost = credititems[i].cost;
		linkchild.onclick = boop;
		cost.textContent = credititems[i].cost + "c";
		cost.dataset.path = credititems[i].path;
		cost.dataset.cost = credititems[i].cost;
		cost.onclick = boop;
		if(credititems[i].stock != null){
			linkchild.dataset.stock = credititems[i].stock;
			cost.dataset.stock = credititems[i].stock;
		}
		div.appendChild(linkchild);
		div.appendChild(cost);
		credititemdiv.appendChild(div);
	}
	
	//initialize credit return
	var creditreturn = document.getElementById("creditreturn")
	creditreturn.textContent = "Return Credits: "+CREDITS.toString();
	creditreturn.onclick = boop;
}

window.onbeforeunload = windowclose;
function windowclose(){
   byond("command","close");
}