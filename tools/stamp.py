#!/usr/bin/env python3
"""Stamps the pages' links to the site's own scripts and stylesheets with a hash of each file
(src="js/live.js?v=1a2b3c4d"), so a browser never mixes a new page with an old script: GitHub
Pages lets each file be cached for 10 minutes on its own, and a new index.html with last
version's js/live.js had the iterations pearl doing nothing. Run before committing; it says
what it changed."""
import hashlib, pathlib, re, sys

root = pathlib.Path(__file__).resolve().parent.parent
link = re.compile(r'((?:src|href)=")((?:\.\./)*)((?:js/[\w.-]+\.js)|(?:[\w-]+\.css))(?:\?v=[0-9a-f]+)?(")')

def stamp(page):
    text = page.read_text()
    def sub(m):
        f = (page.parent / m.group(2) / m.group(3)).resolve()
        if not f.is_file():
            return m.group(0)
        v = hashlib.sha1(f.read_bytes()).hexdigest()[:8]
        return m.group(1) + m.group(2) + m.group(3) + '?v=' + v + m.group(4)
    new = link.sub(sub, text)
    if new != text:
        page.write_text(new)
        print('stamped', page.relative_to(root))

for page in sorted(root.rglob('*.html')):
    if 'node_modules' not in page.parts:
        stamp(page)
