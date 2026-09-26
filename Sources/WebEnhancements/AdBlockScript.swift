enum AdBlockScript {
    static let source = #"""
    function applyAds(root, settings, hide) {
      const labels = new Set(['promoted', 'ad', 'sponsored', '프로모션', '광고', 'プロモーション']);
      if (settings.hidePromotedPosts) {
        root.querySelectorAll('article[data-testid="tweet"]').forEach(article => {
          // Never classify a post merely because its body contains the word "Ad".
          const markers = article.querySelectorAll(
            '[data-testid="promotedIndicator"], [data-testid="promotedLabel"], [data-testid="advertiser_label"]'
          );
          if ([...markers].some(marker => labels.has((marker.textContent || marker.getAttribute('aria-label') || '').trim().toLowerCase()))) {
            hide(article);
          }
        });
        // A second layout uses an advertising placement wrapper without a marker test ID.
        root.querySelectorAll('[data-testid="placementTracking"]').forEach(placement => {
          const article = placement.querySelector('article[data-testid="tweet"]');
          if (!article) return;
          const label = [...placement.querySelectorAll('span')].some(span =>
            !span.closest('[data-testid="tweetText"], [data-testid="User-Name"], [role="group"], [data-testid="quoteTweet"]') &&
            labels.has((span.textContent || '').trim().toLowerCase()));
          if (label) hide(article);
        });
      }
      if (settings.hidePromotedTrends) {
        root.querySelectorAll('[data-testid="trend"]').forEach(trend => {
          const markers = trend.querySelectorAll('span, [data-testid="promotedIndicator"]');
          if ([...markers].some(marker => labels.has((marker.textContent || '').trim().toLowerCase()))) {
            hide(trend);
          }
        });
      }
    }
    """#
}
