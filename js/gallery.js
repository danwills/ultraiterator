// The Pictures section, from media/media.json: a list of
//   { "type": "image" | "video", "src": "media/…", "poster": "media/….webp" (videos), "caption": "…" }
// in the order shown. Add screenshots and videos there; nothing else needs changing.
(function () {
  'use strict';
  const box = document.getElementById('gallery');
  if (!box) return;
  fetch('media/media.json').then(r => r.json()).then(items => {
    for (const it of items) {
      const fig = document.createElement('figure');
      let el;
      if (it.type === 'video') {
        el = document.createElement('video');
        el.src = it.src; el.controls = true; el.playsInline = true; el.preload = 'none'; el.loop = true;
        if (it.poster) el.poster = it.poster;
      } else {
        el = document.createElement('img');
        el.src = it.src; el.loading = 'lazy'; el.alt = it.caption || '';
      }
      fig.appendChild(el);
      if (it.caption) { const c = document.createElement('figcaption'); c.textContent = it.caption; fig.appendChild(c); }
      box.appendChild(fig);
    }
  }).catch(() => { box.closest('section').hidden = true; });
})();
