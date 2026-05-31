/*
 * TEXT HIGHLIGHTING
 */

//Actually turns the highlight term match into appropriate html
function createHighlightMarkup() {
  var extra = '';
  if (opts.highlightColor) {
    extra += ' style="background-color: ' + opts.highlightColor + '"';
  }
  return '<span class="highlight"' + extra + '></span>';
}

// Get all child text nodes that match a regex pattern
function getTextNodes(elem, pattern) {
  var result = $([]);
  $(elem)
    .contents()
    .each(function (idx, child) {
      if (
        child.nodeType === 3 &&
        /\S/.test(child.nodeValue) &&
        child.nodeValue.search(pattern) !== -1
      ) {
        result = result.add(child);
      } else {
        result = result.add(getTextNodes(child, pattern));
      }
    });
  return result;
}

// Highlight all text terms matching the registered regex patterns
function highlightTerms(el) {
  var pattern = new RegExp('(' + opts.highlightTerms.join('|') + ')', 'gi');
  var nodes = getTextNodes(el, pattern);

  nodes.each(function (idx, node) {
    var $node = $(node);
    var content = $node.text();
    var parent = $node.parent();
    var pre = $(node.previousSibling);
    $node.remove();
    content.split(pattern).forEach(function (chunk) {
      // Get our highlighted span/text node
      var toInsert = null;
      if (pattern.test(chunk)) {
        var tmpElem = $(createHighlightMarkup());
        tmpElem.text(chunk);
        toInsert = tmpElem;
      } else {
        toInsert = document.createTextNode(chunk);
      }

      // Insert back into our element
      if (pre.length == 0) {
        var result = parent.prepend(toInsert);
        pre = $(result[0].firstChild);
      } else {
        pre.after(toInsert);
        pre = $(pre[0].nextSibling);
      }
    });
  });
}
