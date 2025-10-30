/*
 * DOM-manipulation utility functions, to better handle common DOM element tasks.
 */

var domUtil = (function (document) {
  /**
   * Type that is supported by domUtil to append to elements.
   * @typedef {DocumentFragment|Element|Text|string|DomUtil~Appendable[]} DomUtil~Appendable
   */

  /**
   * @param {Element} element Element to append children to.
   * @param {DomUtil~Appendable} [children] Children to append.
   * @param {DomUtil~Appendable[]} [appendedChildren] Children already appended (to avoid circular references).
   * @return {Element} Original element.
   */
  function appendChildren(element, children, appendedChildren) {
    var child;
    var childIndex;
    if (typeof children !== 'undefined' && children !== null) {
      if (typeof children === 'string') {
        element.appendChild(createTextNode(children));
      } else {
        // ensure not already appended via e.g. circular reference
        appendedChildren = appendedChildren || [];
        if (!appendedChildren.includes(children)) {
          appendedChildren.push(children);
          if (Array.isArray(children)) {
            for (childIndex = 0; childIndex < children.length; childIndex++) {
              child = children[childIndex];
              appendChildren(element, child, appendedChildren);
            }
          } else {
            // assume it is something that can be appended (e.g. Element)
            element.appendChild(children);
          }
        }
      }
    }
    return element;
  }

  /**
   * @param {object} params
   * @param {object} [params.attributes]
   * @param {DomUtil~Appendable} [params.children]
   * @param {string} [params.className]
   * @param {string} [params.tagName]
   * @return {Element}
   */
  function createElement(params) {
    var attributeKey;
    var attributeKeys;
    var attributeKeyIndex;
    var attributes = params.attributes;
    var children = params.children;
    var className = params.className;
    var tagName = params.tagName;
    var element = document.createElement(tagName);
    appendChildren(element, children);
    if (className) {
      element.className = className;
    }
    if (typeof attributes !== 'undefined') {
      attributeKeys = Object.keys(attributes);
      for (
        attributeKeyIndex = 0;
        attributeKeyIndex < attributeKeys.length;
        attributeKeyIndex++
      ) {
        attributeKey = attributeKeys[attributeKeyIndex];
        element.setAttribute(attributeKey, attributes[attributeKey]);
      }
    }
    return element;
  }

  /**
   * @param {string} text Text to put within TextNode
   * @return {Text}
   */
  function createTextNode(text) {
    return document.createTextNode(text);
  }

  return {
    appendChildren: appendChildren,
    createElement: createElement,
    createTextNode: createTextNode,
  };
})(document);
