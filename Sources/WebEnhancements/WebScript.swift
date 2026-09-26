import Foundation

enum WebScript {
    static func source(preferences: PikoPreferences) -> String {
        guard let data = try? JSONEncoder().encode(preferences),
              let json = String(data: data, encoding: .utf8) else { return "" }
        return """
        (() => {
        'use strict';
        const isXHost = host => ['x.com', 'twitter.com'].some(base => host === base || host.endsWith('.' + base));
        if (location.protocol !== 'https:' || !isXHost(location.hostname) || (location.port && location.port !== '443')) return;
        if (globalThis.__pikoCleanup) globalThis.__pikoCleanup();
        const settings = \(json);
        \(AdBlockScript.source)
        \(TimelineCleanupScript.source)
        \(AppearanceScript.source)
        \(runtime)
        })();
        """
    }

    static let runtime = #"""
    const hidden = new Set();
    const resized = new Map();
    let timer = null;
    let observer = null;
    let stopped = false;
    let style = null;
    function restore() {
      hidden.forEach(node => node.removeAttribute('data-piko-hidden'));
      hidden.clear();
      resized.forEach((original, node) => {
        if (original.value) node.style.setProperty('font-size', original.value, original.priority);
        else node.style.removeProperty('font-size');
      });
      resized.clear();
    }
    function hide(node) {
      node.setAttribute('data-piko-hidden', 'true');
      hidden.add(node);
    }
    function scan() {
      timer = null;
      if (stopped) return;
      observer.disconnect();
      try {
        restore();
        // An SPA may replace its head; reattach our stylesheet when necessary.
        if (!style.isConnected) (document.head || document.documentElement).appendChild(style);
        for (const operation of [
          () => applyAds(document, settings, hide),
          () => applyTimeline(document, settings, hide),
          () => applyAppearance(document, settings, resized)
        ]) {
          try { operation(); } catch (_) { /* Each feature fails independently. */ }
        }
      } finally {
        if (!stopped) observer.observe(document.documentElement, {
          childList: true, subtree: true, characterData: true, attributes: true,
          attributeFilter: ['href', 'aria-label', 'data-testid', 'style', 'class']
        });
      }
    }
    function schedule() {
      // Coalesce mutation bursts, but do not starve on a continuously changing feed.
      if (!stopped && timer === null) timer = setTimeout(scan, 180);
    }
    globalThis.__pikoCleanup = () => {
      stopped = true;
      if (timer !== null) clearTimeout(timer);
      if (observer) observer.disconnect();
      restore();
      if (style) style.remove();
      window.removeEventListener('resize', schedule);
      window.removeEventListener('pagehide', onPageHide);
      window.removeEventListener('pageshow', onPageShow);
    };
    function onPageHide() {
      if (observer) observer.disconnect();
      if (timer !== null) clearTimeout(timer);
      timer = null;
    }
    function onPageShow() { schedule(); }
    if (!settings.enableEnhancements) return;
    style = document.createElement('style');
    style.textContent = '[data-piko-hidden="true"] { display: none !important; }';
    (document.head || document.documentElement).appendChild(style);
    observer = new MutationObserver(schedule);
    window.addEventListener('resize', schedule);
    window.addEventListener('pagehide', onPageHide);
    window.addEventListener('pageshow', onPageShow);
    scan();
    """#
}
