enum TimelineCleanupScript {
    static let source = #"""
    function applyTimeline(root, settings, hide) {
      if (settings.hideRecommendedUsers) {
        const labels = new Set(['who to follow', 'you might like', '추천 팔로우', '추천 계정', '팔로우 추천', 'おすすめユーザー']);
        root.querySelectorAll('aside[aria-label], section[aria-label]').forEach(section => {
          const label = (section.getAttribute('aria-label') || '').trim().toLowerCase();
          if (labels.has(label) && !section.querySelector('article[data-testid="tweet"]') && section.querySelector('[data-testid="UserCell"]')) {
            hide(section);
          }
        });
      }
      if (settings.hideViewCount) {
        root.querySelectorAll('article[data-testid="tweet"] [role="group"]').forEach(group => {
          group.querySelectorAll('a[href]').forEach(link => {
            try {
              const url = new URL(link.getAttribute('href'), location.origin);
              if (['x.com', 'www.x.com', 'twitter.com', 'www.twitter.com'].includes(url.hostname) &&
                  /^\/[A-Za-z0-9_]+\/status\/\d+\/analytics\/?$/.test(url.pathname)) hide(link);
            } catch (_) { /* Leave unfamiliar UI visible. */ }
          });
        });
      }
    }
    """#
}
