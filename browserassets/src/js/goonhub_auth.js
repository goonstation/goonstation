(function () {
  const authPlace = document.getElementById('auth-place');
  const dpr = window.devicePixelRatio;
  document.documentElement.style.setProperty('--dpr', dpr);

  function positionExternal() {
    const box = authPlace.getBoundingClientRect();
    window.location =
      'byond://winset?id=mainwindow.authexternal;size=' +
      box.width * dpr +
      'x' +
      box.height * dpr +
      ';pos=' +
      box.left * dpr +
      ',' +
      box.top * dpr;
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      positionExternal();
    });
  } else {
    positionExternal();
  }

  window.addEventListener('resize', positionExternal);

  window.onTimeout = function () {
    document.body.classList.add('timedout');
    window.location =
      'byond://winset?id=mainwindow.authexternal;is-visible=false';
  };

  // Countdown slider
  const countdownLabel = document.getElementById('countdown-label');
  const countdownFill = document.getElementById('countdown-slider-fill');
  let start = Date.now();
  let end = start + window.GH_TIMEOUT * 1000;
  const warnAt = window.GH_TIMEOUT * 0.2 * 1000;

  function lerpColor(a, b, t) {
    // a, b: [r,g,b], t: 0-1
    return [
      Math.round(a[0] + (b[0] - a[0]) * t),
      Math.round(a[1] + (b[1] - a[1]) * t),
      Math.round(a[2] + (b[2] - a[2]) * t),
    ];
  }

  function rgbToStr(rgb, o = 1) {
    return `rgba(${rgb[0]},${rgb[1]},${rgb[2]},${o})`;
  }

  function getSliderColor(frac) {
    // frac: 1 = green, 0.5 = orange, 0 = red
    if (frac > 0.5) {
      // Green to Orange
      const t = (1 - frac) * 2;
      return lerpColor([63, 174, 63], [255, 209, 37], t); // #3fae3f to #ffd125
    } else {
      // Orange to Red
      const t = 1 - frac * 2;
      return lerpColor([255, 209, 37], [220, 50, 47], t); // #ffd125 to #dc322f
    }
  }

  function updateCountdown() {
    const now = Date.now();
    const msLeft = Math.max(0, end - now);
    const secLeft = Math.ceil(msLeft / 1000);
    const frac = msLeft / (window.GH_TIMEOUT * 1000);
    countdownFill.style.width = frac * 100 + '%';
    const color = getSliderColor(frac);
    countdownFill.style.background = rgbToStr(color);

    if (msLeft <= warnAt) {
      countdownLabel.textContent = `${secLeft} seconds remaining`;
      countdownLabel.style.background = rgbToStr(color, 0.3);
      countdownLabel.style.borderColor = rgbToStr(color, 0.6);
      countdownLabel.classList.add('is-active');
    }

    if (msLeft > 0) {
      requestAnimationFrame(updateCountdown);
    } else {
      countdownFill.style.width = '0%';
      countdownFill.style.background = rgbToStr([220, 50, 47]);
      countdownLabel.textContent = 'Time expired';
    }
  }

  updateCountdown();
})();
