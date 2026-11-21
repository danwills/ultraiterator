// The full-tab view: a gallery picture opens its fractal live in the hero, filling the tab, with
// just its pearls, a back pebble and an ✕ pebble. ✕ leaves the bare fractal; Esc, Enter, Back or a
// tap brings the controls back, and Back or Esc again returns to the page where it was.
// Each is in the history (#live-<id>), so Back works and a fractal's view can be linked to.
(function () {
  'use strict';
  const canvas = document.getElementById('live');
  let scrollBefore = 0;

  function enter(id) {
    if (!document.body.classList.contains('theatre')) scrollBefore = window.scrollY;
    document.body.classList.add('theatre');
    document.body.classList.remove('bare');
    window.scrollTo(0, 0);
    if (window.UILive) UILive.show(id);
  }
  function leave() {
    if (document.fullscreenElement) document.exitFullscreen().catch(() => {});
    viaFull = false;
    if (!document.fullscreenElement) document.body.classList.remove('fullscreen');
    document.body.classList.remove('theatre', 'bare');
    window.scrollTo(0, scrollBefore);
  }

  // The fullscreen pearl: the fractal it's on, filling the tab (as a gallery pick does, carrying
  // on where it is) and the screen, where the browser can (not iPhones: the tab only, there).
  // Leaving fullscreen (the pearl, or Esc, which the browser keeps for itself) goes back to the
  // page, if the pearl brought it here.
  let viaFull = false;
  document.addEventListener('fullscreenchange', () => {
    const on = !!document.fullscreenElement;
    document.body.classList.toggle('fullscreen', on);
    if (!on && viaFull && document.body.classList.contains('theatre')) { viaFull = false; history.back(); }
  });
  window.UITheatre = {
    toggleFull() {
      if (document.fullscreenElement) { document.exitFullscreen().catch(() => {}); return; }
      if (viaFull && document.body.classList.contains('theatre')) { viaFull = false; history.back(); return; }   // (no Fullscreen API: the tab's view only)
      const id = window.UILive && UILive.current();
      if (!document.body.classList.contains('theatre') && id) { UITheatre.open(id); viaFull = true; }
      const el = document.documentElement;
      if (el.requestFullscreen) el.requestFullscreen({ navigationUI: 'hide' }).catch(() => {});
      if (!el.requestFullscreen) document.body.classList.toggle('fullscreen', viaFull);
    },
    open(id) {
      history.pushState({ ui: 'theatre', id }, '', '#live-' + id);
      enter(id);
    },
    bare() {
      history.pushState({ ui: 'bare', id: history.state && history.state.id }, '', location.hash);
      document.body.classList.add('bare');
    },
  };

  window.addEventListener('popstate', e => {
    const st = e.state && e.state.ui;
    if (st === 'theatre') { document.body.classList.remove('bare'); if (!document.body.classList.contains('theatre')) enter(e.state.id); }
    else if (st === 'bare') document.body.classList.add('theatre', 'bare');
    else leave();
  });

  document.addEventListener('keydown', e => {
    if (!document.body.classList.contains('theatre')) return;
    const bare = document.body.classList.contains('bare');
    if (e.key === 'Escape' || (e.key === 'Enter' && bare)) { e.preventDefault(); history.back(); }
  });

  // Bare: a tap (not a drag) on the fractal brings the controls back.
  let down = null;
  if (canvas) {
    canvas.addEventListener('pointerdown', e => { down = { x: e.clientX, y: e.clientY, t: performance.now() }; });
    canvas.addEventListener('pointerup', e => {
      if (!down || !document.body.classList.contains('bare')) return;
      const moved = Math.hypot(e.clientX - down.x, e.clientY - down.y), held = performance.now() - down.t;
      down = null;
      if (moved < 8 && held < 400) history.back();
    });
  }

  // Arriving at #live-<id>: the page underneath first, so Back goes to it.
  const m = location.hash.match(/^#live-([0-9a-f]+)$/);
  if (m) {
    history.replaceState(null, '', location.pathname + location.search);
    UITheatre.open(m[1]);
  }
})();
