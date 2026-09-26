enum AppearanceScript {
    static let source = #"""
    function applyAppearance(root, settings, resized) {
      const percent = Math.min(160, Math.max(80, Number(settings.postFontPercent) || 100));
      if (percent === 100) return;
      root.querySelectorAll('article[data-testid="tweet"] [data-testid="tweetText"]').forEach(text => {
        const base = parseFloat(getComputedStyle(text).fontSize);
        if (!Number.isFinite(base) || base <= 0) return;
        const original = {
          value: text.style.getPropertyValue('font-size'),
          priority: text.style.getPropertyPriority('font-size')
        };
        resized.set(text, original);
        text.style.setProperty('font-size', `${base * percent / 100}px`, 'important');
      });
    }
    """#
}
