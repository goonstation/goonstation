var categories = json;
var currentrender
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

var boop = function(e){ //updated
	console.log(currentrender);
	e.preventDefault();
	if(e.srcElement.dataset.path == "yeet") {
		//initialize items
		var itemlist = document.getElementsByClassName("items")[0]
		var whichgreen = 1
		for(var i = 0; i < categories.length; i++){
			if(e.srcElement.textContent == categories[i].name) {
				if(itemlist.childElementCount != 0) {
					while(itemlist.firstChild) {
						itemlist.removeChild(itemlist.firstChild);
					}
				}
				for(var n = 0; n < categories[i].items.length; n++) {
					var catdiv = document.createElement("div")
					var linkchild = document.createElement("a")
					var pchild = document.createElement("p")
					if(whichgreen == 1) {
						catdiv.className = "link itemcolor1";
						pchild.className = "creditcolor1";
						whichgreen = 2;
					}else{
						catdiv.className = "link itemcolor2";
						pchild.className = "creditcolor2";
						whichgreen = 1;
					}
					linkchild.textContent = categories[i].items[n].name;
					linkchild.dataset.path = categories[i].items[n].path;
					linkchild.dataset.cost = categories[i].items[n].cost;
					linkchild.onclick = boop;
					catdiv.appendChild(linkchild);
					pchild.textContent = linkchild.dataset.cost+"c";
					pchild.dataset.path = categories[i].items[n].path;
					pchild.dataset.cost = categories[i].items[n].cost;
					pchild.onclick = boop;
					catdiv.appendChild(pchild);
					itemlist.appendChild(catdiv);
				}
				whichgreen = 1;
			}
		}
	}else{
		var path = e.srcElement.dataset.path
		if(currentrender == path) {
			byond("command","spawn","path",path,"cost",e.srcElement.dataset.cost);
		}else{
			currentrender = path;
			byond("command","render","path",path,"cost",e.srcElement.dataset.cost);
		}
	}
}
window.onload = function(e) {
	//initialize categories
	var categorylist = document.getElementsByClassName("categories")[0]
	var whichblue = 1
	for(var i = 0; i < categories.length; i++){
		var catdiv = document.createElement("div")
		var linkchild = document.createElement("a")
		if(whichblue == 1) {
			catdiv.className = "link catcolor1";
			whichblue = 2;
		}else{
			catdiv.className = "link catcolor2";
			whichblue = 1;
		}
		linkchild.textContent = categories[i].name;
		linkchild.dataset.path = "yeet";
		linkchild.onclick = boop;
		catdiv.appendChild(linkchild);
		categorylist.appendChild(catdiv);
	}

	function positionPreview() {
		var rect = document.getElementById("preview").getBoundingClientRect();

		window.location = ("byond://winset?id=" + previewID
			+ "&type=map"
			+ "&parent=ClothingBooth"
			+ "&pos=" + Math.floor(rect.left) + "," + Math.floor(rect.top)
			+ "&size=" + Math.floor(rect.width) + "x" + Math.floor(rect.height));
	}
	addEventListener("unload", function() {
		var xhr = new XMLHttpRequest();
		xhr.open("GET", "winset?id=ClothingBooth." + previewID + ";parent=");
		xhr.send();
	});
	addEventListener("resize", positionPreview);
	addEventListener("scroll", positionPreview);
	positionPreview();
}
