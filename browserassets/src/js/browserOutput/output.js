/*
 * MESSAGE OUTPUT
 */

function handleStreakCounter($el) {
  var $streakCounter = $el.find('.streak-counter');

  if ($streakCounter.length) {
    //streak exists, increment
    var currentStreak = $streakCounter.data('count');
    currentStreak++;
    $streakCounter.text('x' + currentStreak).data('count', currentStreak);

    //grow the last entry along with the streak count
    if (currentStreak <= opts.maxStreakGrowth) {
      $el.css('font-size', 1 + currentStreak * 0.05 + 'em');
    }
  } else {
    //new streak, append
    $el
      .css('font-size', '1.1em')
      .append(
        $('<span>', { class: 'streak-counter', text: 'x2' }).data('count', 2)
      );
  }
}

// Wrap all emojis in an element so we can enforce styles
function parseEmojis(message) {
  var pattern =
    /((?:\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+)/g;
  return message.replace(pattern, '<span class="emoji">$1</span>');
}

//Send a message to the client
function output(message, group, skipNonEssential, forceScroll) {
  if (typeof message === 'undefined') {
    return;
  }
  if (typeof group === 'undefined') {
    group = '';
  }
  if (
    typeof skipNonEssential === 'string' ||
    skipNonEssential instanceof String
  ) {
    skipNonEssential = parseInt(skipNonEssential);
  }
  if (typeof forceScroll === 'string' || forceScroll instanceof String) {
    forceScroll = parseInt(forceScroll);
  }

  //Stuff we do along with appending a message
  var atBottom = false;
  if (!skipNonEssential) {
    var bodyHeight = $('body').height();
    var messagesHeight = $messages.outerHeight();
    var scrollPos = document.documentElement.scrollTop;

    //Should we snap the output to the bottom?
    if (
      bodyHeight + scrollPos >= messagesHeight - opts.scrollSnapTolerance ||
      forceScroll
    ) {
      atBottom = true;
      if ($('#newMessages').length) {
        $('#newMessages').remove();
      }
      //If not, put the new messages box in
    } else {
      if ($('#newMessages').length) {
        var messages = $('#newMessages .number').text();
        messages = parseInt(messages);
        messages++;
        $('#newMessages .number').text(messages);
        if (messages == 2) {
          $('#newMessages .messageWord').append('s');
        }
      } else {
        $messages.after(
          '<a href="#" id="newMessages"><span class="number">1</span> new <span class="messageWord">message</span> <i class="icon-double-angle-down"></i></a>'
        );
      }
    }
  }

  opts.messageCount++;

  //Pop the top message off if history limit reached
  if (
    opts.messageCount >= opts.messageLimit &&
    opts.messageLimitEnabled &&
    !skipNonEssential
  ) {
    $messages
      .children('div.entry:nth-child(-n+' + opts.messageLimit / 2 + ')')
      .remove();
    opts.messageCount -= opts.messageLimit / 2; //I guess the count should only ever equal the limit
  }

  //message is identical to the last message, do the streak counter stuff
  if (message === opts.lastMessage) {
    handleStreakCounter($lastEntry);
    opts.messageCount--;
  } else {
    var entry = null;

    //message has a group identifier, check if it matches the group of the previous message
    if (
      group &&
      $lastEntry.hasClass('hasGroup') &&
      $lastEntry.data('group') === group
    ) {
      entry = $lastEntry[0];
      var $streakCounter = $lastEntry.find('.streak-counter');
      var $streakClone = null;

      //save the streak counter before overwriting message
      if ($streakCounter.length) {
        $streakClone = $streakCounter.clone(true);
      }

      //replace the last message with the new one
      $lastEntry.html(message);

      //re-add the streak counter
      if ($streakClone) {
        $lastEntry.append($streakClone);
      }

      handleStreakCounter($lastEntry);
      opts.messageCount--; //we didn't actually add a message like we thought
    } else {
      //Actually append the message
      entry = document.createElement('div');
      entry.className = 'entry';

      if (group) {
        entry.className += ' hasGroup';
        entry.setAttribute('data-group', group);
      }

      //get classes from messages, compare if its in messageclasses, and if so, add to entry
      let addedClass = false;
      let $message = $('<span>' + message + '</span>');
      $.each(opts.messageClasses, function (key, value) {
        if (
          $message.find('.' + value).length !== 0 ||
          $message.hasClass(value)
        ) {
          entry.className += ' ' + value;
          addedClass = true;
        }
      });
      // fallback, if no class found in the classlist
      if (!addedClass) {
        entry.className += ' misc';
      }

      if (opts.msgOdd && opts.oddMsgHighlight) {
        entry.className += ' odd-highlight';
      }

      opts.msgOdd = !opts.msgOdd;

      entry.innerHTML = message;
      $lastEntry = $($messages[0].appendChild(entry));
      opts.lastMessage = message;
    }

    //Stuff we can do after the message shows can go here, in the interests of responsiveness
    if (opts.highlightTerms && opts.highlightTerms.length > 0) {
      highlightTerms(entry);
    }
  }

  //Actually do the snap
  if (atBottom && !skipNonEssential) {
    window.scrollTo(0, document.body.scrollHeight);
  }
}

//Receive a large number of messages all at once to cut down on round trips.
function outputBatch(messages) {
  var list = JSON.parse(messages);
  var bodyHeight = $('body').height();
  var messagesHeight = $messages.outerHeight();
  var scrollPos = document.documentElement.scrollTop;
  var shouldScroll =
    bodyHeight + scrollPos >= messagesHeight - opts.scrollSnapTolerance;

  for (var i = 0; i < list.length; i++) {
    output(
      list[i].message,
      list[i].group,
      i < list.length - 1,
      shouldScroll || list[i].forceScroll
    );
  }
}
