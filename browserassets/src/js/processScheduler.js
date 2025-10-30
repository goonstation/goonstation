(function () {
  function setRef(theRef) {
    ref = theRef;
  }

  function jax(action, data) {
    data = data || {};
    var params = [];
    for (var k in data) {
      if (data.hasOwnProperty(k)) {
        params.push(encodeURIComponent(k) + '=' + encodeURIComponent(data[k]));
      }
    }
    // Build the URL exactly like the original code.
    var newLoc =
      'byond://?src=' + ref + ';action=' + action + ';' + params.join(';');
    window.location = newLoc;
  }

  function requestRefresh(e) {
    jax('refresh', null);
  }

  function handleRefresh(processTable) {
    // processTable is expected to be the inner HTML for the container.
    var container = document.getElementById('processTable');
    if (container) {
      container.innerHTML = processTable;
    }
    initProcessTableButtons();
    // Rebuild sticky header and reinitialize sorting after table updates.
    makeTableHeaderSticky('processTable');
    initSortableTable('processTable');
  }

  function requestKill(e) {
    var button = e.currentTarget;
    var processName = button.getAttribute('data-process-name');
    jax('kill', { name: processName });
  }

  function requestEnable(e) {
    var button = e.currentTarget;
    var processName = button.getAttribute('data-process-name');
    jax('enable', { name: processName });
  }

  function requestDisable(e) {
    var button = e.currentTarget;
    var processName = button.getAttribute('data-process-name');
    jax('disable', { name: processName });
  }

  function requestEdit(e) {
    var button = e.currentTarget;
    var processName = button.getAttribute('data-process-name');
    jax('edit', { name: processName });
  }

  function initProcessTableButtons() {
    var killButtons = document.querySelectorAll('.kill-btn');
    for (var i = 0; i < killButtons.length; i++) {
      killButtons[i].addEventListener('click', requestKill);
    }
    var enableButtons = document.querySelectorAll('.enable-btn');
    for (var j = 0; j < enableButtons.length; j++) {
      enableButtons[j].addEventListener('click', requestEnable);
    }
    var disableButtons = document.querySelectorAll('.disable-btn');
    for (var k = 0; k < disableButtons.length; k++) {
      disableButtons[k].addEventListener('click', requestDisable);
    }
    var editButtons = document.querySelectorAll('.edit-btn');
    for (var l = 0; l < editButtons.length; l++) {
      editButtons[l].addEventListener('click', requestEdit);
    }
  }

  // Helper: returns the table element inside the container with the given id.
  function getTableElement(containerId) {
    var container = document.getElementById(containerId);
    if (!container) {
      return null;
    }
    return container.querySelector('table');
  }

  // --- Sticky Header Code for IE11 ---
  function makeTableHeaderSticky(containerId) {
    var table = getTableElement(containerId);
    if (!table) {
      return;
    }
    var thead = table.querySelector('thead');
    if (!thead) {
      return;
    }

    // Remove existing sticky header if present.
    var existingSticky = document.getElementById(
      containerId + '-sticky-header'
    );
    if (existingSticky) {
      existingSticky.parentNode.removeChild(existingSticky);
    }

    // Clone the table header.
    var clonedThead = thead.cloneNode(true);
    var stickyTable = document.createElement('table');
    stickyTable.appendChild(clonedThead);
    stickyTable.setAttribute('id', containerId + '-sticky-header');
    stickyTable.style.position = 'fixed';
    stickyTable.style.top = '0';
    stickyTable.style.zIndex = '1000';
    stickyTable.style.visibility = 'hidden'; // hidden by default
    stickyTable.style.pointerEvents = 'none';
    stickyTable.style.backgroundColor = '#21272c';

    // Insert the sticky header before the container.
    var container = document.getElementById(containerId);
    container.parentNode.insertBefore(stickyTable, container);

    // Sync column widths from the original header to the sticky header.
    function syncWidths() {
      var origCells = thead.querySelectorAll('th, td');
      var cloneCells = clonedThead.querySelectorAll('th, td');
      for (var i = 0; i < origCells.length; i++) {
        var width = origCells[i].offsetWidth;
        if (cloneCells[i]) {
          cloneCells[i].style.width = width + 'px';
        }
      }
      stickyTable.style.width = table.offsetWidth + 'px';
    }

    syncWidths();
    window.addEventListener('resize', syncWidths);

    // Toggle sticky header on scroll.
    window.addEventListener('scroll', function () {
      // Minimal change: re-check if the table is available.
      var currentTable = getTableElement(containerId);
      if (!currentTable) {
        return;
      }
      var rect = currentTable.getBoundingClientRect();
      if (rect.top < 0 && rect.bottom > clonedThead.offsetHeight) {
        stickyTable.style.visibility = 'visible';
        stickyTable.style.left = rect.left + 'px'; // adjust for horizontal scroll
      } else {
        stickyTable.style.visibility = 'hidden';
      }
    });
  }

  function updateStickyHeaderState(table, containerId) {
    var stickyHeader = document.getElementById(containerId + '-sticky-header');
    if (!stickyHeader) {
      return;
    }
    var origCells = table.querySelector('thead').querySelectorAll('td');
    var cloneCells = stickyHeader.querySelector('thead').querySelectorAll('td');
    for (var i = 0; i < origCells.length && i < cloneCells.length; i++) {
      var state = origCells[i].getAttribute('data-dir');
      if (state) {
        cloneCells[i].setAttribute('data-dir', state);
      } else {
        cloneCells[i].removeAttribute('data-dir');
      }
    }
  }
  // --- End Sticky Header Code ---

  // --- Sorting Code with State Persistence ---
  function initSortableTable(containerId) {
    var table = getTableElement(containerId);
    if (!table) {
      return;
    }
    var headerContainer = table.querySelector('thead');
    if (!headerContainer) {
      return;
    }
    var headers = headerContainer.querySelectorAll('td');
    if (!headers || headers.length === 0) {
      return;
    }
    for (var i = 0; i < headers.length; i++) {
      var header = headers[i];
      // Skip non-sortable header cells.
      if (header.className.indexOf('non-sortable') !== -1) {
        continue;
      }
      header.style.cursor = 'pointer';
      header.addEventListener('click', function () {
        sortTableByColumn(table, this);
      });
    }
    // Check for saved sorting state.
    if (window.localStorage) {
      var saved = localStorage.getItem('tableSorting_' + containerId);
      if (saved) {
        var sortingState = JSON.parse(saved);
        var headerToSort = headers[sortingState.column];
        if (headerToSort) {
          sortTableByColumn(table, headerToSort, sortingState.direction);
          return; // use saved state and exit.
        }
      }
    }
    // If no saved state, default sort by the "name" column (ascending).
    var defaultIndex = -1;
    for (var i = 0; i < headers.length; i++) {
      // Ignore non-sortable headers.
      if (headers[i].className.indexOf('non-sortable') !== -1) {
        continue;
      }
      if (headers[i].textContent.trim().toLowerCase() === 'name') {
        defaultIndex = i;
        break;
      }
    }
    // If "name" column wasn't found, default to the first sortable column.
    if (defaultIndex === -1) {
      for (var i = 0; i < headers.length; i++) {
        if (headers[i].className.indexOf('non-sortable') === -1) {
          defaultIndex = i;
          break;
        }
      }
    }
    if (defaultIndex !== -1) {
      var defaultHeader = headers[defaultIndex];
      sortTableByColumn(table, defaultHeader, 'asc');
    }
  }

  function sortTableByColumn(table, header, forcedDir) {
    var cells = header.parentNode.children;
    var index = Array.prototype.indexOf.call(cells, header);
    var tbody = table.tBodies[0];
    if (!tbody) {
      return;
    }
    var rows = Array.prototype.slice.call(tbody.rows);

    var currentDir = header.getAttribute('data-dir');
    var newDir =
      forcedDir || (!currentDir || currentDir === 'desc' ? 'asc' : 'desc');
    header.setAttribute('data-dir', newDir);

    // Remove sorting attribute from other headers.
    var allHeaders = table.querySelectorAll('thead td');
    for (var i = 0; i < allHeaders.length; i++) {
      if (allHeaders[i] !== header) {
        allHeaders[i].removeAttribute('data-dir');
      }
    }

    rows.sort(function (a, b) {
      var cellA = a.cells[index].textContent.trim();
      var cellB = b.cells[index].textContent.trim();

      // Attempt numeric comparison if possible.
      var numA = parseFloat(cellA);
      var numB = parseFloat(cellB);
      if (!isNaN(numA) && !isNaN(numB)) {
        cellA = numA;
        cellB = numB;
      }
      if (cellA < cellB) {
        return newDir === 'asc' ? -1 : 1;
      }
      if (cellA > cellB) {
        return newDir === 'asc' ? 1 : -1;
      }
      return 0;
    });

    // Re-append sorted rows.
    for (var i = 0; i < rows.length; i++) {
      tbody.appendChild(rows[i]);
    }

    // Save sorting state to localStorage.
    if (window.localStorage) {
      var sortingState = { column: index, direction: newDir };
      localStorage.setItem(
        'tableSorting_' + table.parentNode.id,
        JSON.stringify(sortingState)
      );
    }
    updateStickyHeaderState(table, table.parentNode.id);
  }
  // --- End Sorting Code ---

  // Expose functions globally.
  window.setRef = setRef;
  window.handleRefresh = handleRefresh;

  // On DOM ready, bind refresh button, initialize process table buttons,
  // set up the sticky header, and make the table sortable.
  function onReady() {
    initProcessTableButtons();
    var refreshBtn = document.getElementById('btn-refresh');
    if (refreshBtn) {
      refreshBtn.addEventListener('click', requestRefresh);
    }
    makeTableHeaderSticky('processTable');
    initSortableTable('processTable');
  }

  if (
    document.readyState === 'complete' ||
    document.readyState === 'interactive'
  ) {
    onReady();
  } else {
    document.addEventListener('DOMContentLoaded', onReady);
  }
})();
