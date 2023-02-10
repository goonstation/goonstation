/*
    Excuse the dust, i'm just a little bab' in webstuff.

    #define TAG_ORE 1
    #define TAG_WRECKAGE 2
    #define TAG_PLANET 4
    #define TAG_ANOMALY 8
    #define TAG_SPACE 16
    #define TAG_NPC 32
    #define TAG_TELEPORT_LOC 64
    #define TAG_CRUISER_LOC 128
    #define TAG_MAGNET_LOC 256
*/

var tags = {TAG_ORE:1,TAG_WRECKAGE:2,TAG_PLANET:4,TAG_ANOMALY:8,TAG_SPACE:16,TAG_NPC:32,TAG_TELEPORT_LOC:64,TAG_CRUISER_LOC:128,TAG_MAGNET_LOC:256};

var marks = [];
var events = [];
var pins = [];

var canvas = document.getElementById("canvasOverlay");
var context = canvas.getContext("2d");
var image = document.getElementById('imageSource');
var map = document.getElementById('mapSource');
var buttonsDiv = document.getElementById('divButtons');

var glitchProps = { lastGlitch : Date.now(), glitching : false, glitchCount : 0 , glitchFrame : 1, glitchLength : 40, glitchCooldown : 1000};
var cooldownProps = {lastUse : 0, cooldown : 2500, barOpacity : 0, barOpacityMax : 0.3, barFadeSpeed : 0.015};
var pings = [];
var timerDelay = 33; //= 30fps , 1000ms / 33 = 30fps
var ref;

window.addEventListener("resize", resizeCanvas);
canvas.addEventListener("click", clickMap);
canvas.addEventListener("contextmenu", clearMap);
timer = setInterval(update, timerDelay);

var setRef = function setRef(theRef)
{
    ref = theRef;
};

function callByond(action, data)
{
    var newLoc = '?src=' + ref + '&jscall=' + action + '&' + data.join('&');
    window.location = newLoc;
}

function clearMap(ev)
{
    if(ev != null)
	    ev.preventDefault();
	marks=[];
};

function clearEvents()
{
    events = [];
    buttonsDiv.innerHTML = "";
}

function showFooterMsg(msg)
{
    document.getElementById("footer").innerText = msg;
}

function rebuildEventList()
{
    for (var x = events.length - 1; x >= 0; x--)
    {
        var curr = events[x];
        var newHtml = "";
        newHtml += "<a class='telescopeButton " + (curr.discovered ? "discovered":"undiscovered") + " " + (curr.tracking ? "underline":"") + "' href='#' onclick='buttonClick(\""+ curr.reference +"\");return false;'>" + curr.name + "</a>";
        // document.getElementById("footer").innerText = Date.now() + " - " + curr.tracking + " - " + newHtml;
        if(curr.type & tags.TAG_ORE) newHtml += "<div class='tooltip'><i class='icon-star-empty'></i><span class='tooltiptext'>Ore</span></div>";
        if(curr.type & tags.TAG_WRECKAGE) newHtml +=  "<div class='tooltip'><i class='icon-gear'></i><span class='tooltiptext'>Wreckage</span></div>";
        if(curr.type & tags.TAG_PLANET) newHtml += "<div class='tooltip'><i class='icon-globe'></i><span class='tooltiptext'>Planet</span></div>";
        if(curr.type & tags.TAG_ANOMALY) newHtml += "<div class='tooltip'><i class='icon-question'></i><span class='tooltiptext'>Anomaly</span></div>";
        if(curr.type & tags.TAG_SPACE) newHtml += "<div class='tooltip'><i class='icon-circle-blank'></i><span class='tooltiptext'>Space</span></div>";
        if(curr.type & tags.TAG_NPC) newHtml += "<div class='tooltip'><i class='icon-comment-alt'></i><span class='tooltiptext'>Person</span></div>";
        if(curr.type & tags.TAG_TELEPORT_LOC) newHtml += "<div class='tooltip'><i class='icon-anchor'></i><span class='tooltiptext'>Teleporter</span></div>";
        if(curr.type & tags.TAG_CRUISER_LOC) newHtml += "<div class='tooltip'><i class='icon-rocket'></i><span class='tooltiptext'>Cruiser</span></div>";
        if(curr.type & tags.TAG_MAGNET_LOC) newHtml += "<div class='tooltip'><i class='icon-magnet'></i><span class='tooltiptext'>Magnet</span></div>";
        newHtml += "<br>"
        buttonsDiv.innerHTML = buttonsDiv.innerHTML + newHtml;
    }
}

function getEventByRef(ref)
{
    for (var x = events.length - 1; x >= 0; x--)
    {
        var curr = events[x];
        if(curr.reference == ref) return curr;
    }
    return null;
}

function buttonClick(reference)
{
    var event = getEventByRef(reference);
    if(event != null)
    {
        if(event.discovered)
        {
            callByond("activate", ["id="+event.reference]);
        }
        else
        {
            if(!event.tracking)
            {
                callByond("track", ["id="+event.reference]);
                clearMap(null);
            }
        }
    }
    // document.getElementById("footer").innerText = "ClickRef: " + event.name;
}

function addEvent(name, type, discovered, tracking, reference)
{
    var ref = reference;
    events.push({name:name,type:parseInt(type),discovered:parseInt(discovered),tracking:parseInt(tracking), reference:ref})
}

function byondAddMark(x,y,dist)
{
    var pX = parseInt(x);
    var pY = parseInt(y);
    var pS = parseInt(dist);
    addMark(pX, pY, pS, 0x2e85ff, 0x000000);
}

function byondFound(x,y,size,id)
{
    clearMap(null);
    addPing(x ,y,60,"green",0.3,10);
}

function addMark(x, y, size, color, fromColor)
{
    marks.push({x: x, y: y, size: size, currentSize: 0, color: color, fromColor: fromColor, animationLength: 2000, currentStep: 0});
}

function addPing(x, y, size, color, growSpeed, width)
{
    pings.push({x:x,y:y,size:0,maxSize:size,growSpeed:growSpeed,color:color, width:width});
}

function update()
{
    for(var i = 0; i < marks.length; i++)
    {
        var curr = marks[i];
        var totalSteps = (curr.animationLength / timerDelay);
        var progress = curr.currentStep / totalSteps;
        if(curr.currentStep <= totalSteps)
        {
            var x;
            x = easeInOutCirc(curr.currentStep, 0, curr.size, totalSteps);
            curr.currentSize = x;
            curr.currentStep++;
        }else{
            curr.currentSize = curr.size; //Probably not needed. just to make sure we really end up the right value.
            //curr.currentStep = 0;
        }
    }

    if(Date.now() - glitchProps.lastGlitch >= glitchProps.glitchCooldown && glitchProps.glitching == false)
    {
        glitchProps.lastGlitch = Date.now();
        glitchProps.glitchCooldown = Math.floor(Math.random() * 10000) + 1000;
        glitchProps.glitchLength = Math.floor(Math.random() * 70) + 10;
        glitchProps.glitching = true;
    }

    redrawCanvas();
}

function getScalar()
{
    var sw = parseFloat(window.getComputedStyle(map).getPropertyValue('width'));
    var sh = parseFloat(window.getComputedStyle(map).getPropertyValue('height'));

    var x = sw / map.naturalWidth;
    var y = sh / map.naturalHeight;

    return [x, y];
}

function tryPing(x, y)
{
    callByond("ping", ["x="+x,"y="+y]);
}

function clickMap(event)
{
    var rect = event.target.getBoundingClientRect();
    var x = event.clientX - rect.left;
    var y = event.clientY - rect.top;

    var scalar = getScalar();

    if(Date.now() - cooldownProps.lastUse < cooldownProps.cooldown)
    {
        addPing(x / scalar[0],y / scalar[1],25,"#CD5C5C",1,2);
        return false;
    }
    else
    {
        cooldownProps.lastUse = Date.now();
        cooldownProps.barOpacity = cooldownProps.barOpacityMax;
        addPing(x / scalar[0],y / scalar[1],45,"white",1.5,2);
    }

    tryPing(x / scalar[0], y / scalar[1]);
}

function drawArea(context, x, y, size, color, opacity)
{
    var scalar = getScalar();
    context.globalAlpha = opacity * 0.15;
    context.lineWidth = 2 * scalar[0];
    context.strokeStyle = "white";
    context.fillStyle = color;

    context.beginPath();
    context.arc(x * scalar[0] , y * scalar[1], size * scalar[0], 0, 2 * Math.PI);
    context.fill();
    context.stroke();

    context.beginPath();
    context.closePath();
}

function redrawCanvas()
{
    var scalar = getScalar();
    context.clearRect(0, 0, canvas.width, canvas.height);

    context.globalAlpha = 1;
    context.drawImage(map, 0, 0, canvas.width, canvas.height);

    for (var x = pings.length - 1; x >= 0; x--)
    {
        var currP = pings[x];
        var prcP = Math.min(currP.size / currP.maxSize, 1);
        context.strokeStyle = currP.color;
        context.lineWidth = currP.width * scalar[0];
        context.globalAlpha = 1 * (1 - prcP);
        context.beginPath();
        context.arc(currP.x * scalar[0] , currP.y * scalar[1], currP.size * scalar[0], 0, 2 * Math.PI);
        context.stroke();
        currP.size = Math.min(currP.size + currP.growSpeed, currP.maxSize);
        if(prcP == 1)
            pings.splice(x, 1);
    }
    context.beginPath();
    context.closePath();

    for(var i = 0; i < marks.length; i++)
    {
        var adj = ((i+1) / marks.length)
        var curr = marks[i];
        var prc = Math.min(curr.currentSize / curr.size, 1);
        drawArea(context, curr.x, curr.y, curr.currentSize, lerpColor(curr.fromColor, curr.color, prc), prc * (adj * 2));
    }

    var timeLeft = (Date.now() - cooldownProps.lastUse);
    var prcReady = Math.min(timeLeft / cooldownProps.cooldown, 1);

    context.globalAlpha = cooldownProps.barOpacity;
    context.rect(0, canvas.height - 5, canvas.width * prcReady, 5);
    context.fillStyle = lerpColor(0xff0000, 0x00ff00, prcReady);
    context.fill();

    if(prcReady == 1)
        cooldownProps.barOpacity = Math.max(cooldownProps.barOpacity - cooldownProps.barFadeSpeed, 0);

    if(glitchProps.glitching)
    {
        glitchProps.glitchCount++;
        if(glitchProps.glitchCount > glitchProps.glitchLength)
        {
            glitchProps.glitching = false;
            glitchProps.glitchCount = 0;
        }

        var progress = glitchProps.glitchCount / glitchProps.glitchLength;

        var noise = document.getElementById("noise"+glitchProps.glitchFrame);
        context.globalAlpha = 0.06 * (1 - (Math.abs(0.5 - progress) * 2));
        context.drawImage(noise, 0, 0, canvas.width, canvas.height);

        if(++glitchProps.glitchFrame == 4)
        {
            glitchProps.glitchFrame = 1;
        }
    }

    context.globalAlpha = 0.10;
    context.drawImage(image, 0, 0, canvas.width, canvas.height);
}

function resizeCanvas()
{
    var sw = parseFloat(window.getComputedStyle(map).getPropertyValue('width'));
    var sh = parseFloat(window.getComputedStyle(map).getPropertyValue('height'));

    canvas.width = sw;
    canvas.height = sh;

    redrawCanvas();
}

function lerpColor(a, b, amount) { //Not mine.
    var ar = a >> 16,
          ag = a >> 8 & 0xff,
          ab = a & 0xff,

          br = b >> 16,
          bg = b >> 8 & 0xff,
          bb = b & 0xff,

          rr = ar + amount * (br - ar),
          rg = ag + amount * (bg - ag),
          rb = ab + amount * (bb - ab);

    return '#' + ((1 << 24) + (rr << 16) + (rg << 8) + rb | 0).toString(16).slice(1);
};

// Penner's easing formulas.
function easeInOutQuad(currentIteration, startValue, changeInValue, totalIterations) {
    if ((currentIteration /= totalIterations / 2) < 1) {
      return changeInValue / 2 * currentIteration * currentIteration + startValue;
    }
    return -changeInValue / 2 * ((--currentIteration) * (currentIteration - 2) - 1) + startValue;
}

function easeInOutCubic(currentIteration, startValue, changeInValue, totalIterations) {
    if ((currentIteration /= totalIterations / 2) < 1) {
      return changeInValue / 2 * Math.pow(currentIteration, 3) + startValue;
    }
    return changeInValue / 2 * (Math.pow(currentIteration - 2, 3) + 2) + startValue;
}

  function easeInOutCirc(currentIteration, startValue, changeInValue, totalIterations) {
    if ((currentIteration /= totalIterations / 2) < 1) {
      return changeInValue / 2 * (1 - Math.sqrt(1 - currentIteration * currentIteration)) + startValue;
    }
    return changeInValue / 2 * (Math.sqrt(1 - (currentIteration -= 2) * currentIteration) + 1) + startValue;
}
