const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { JSDOM } = require('jsdom');
const YAML = require('yaml');
const root = path.resolve(__dirname, '../..');
const read = name => fs.readFileSync(path.join(root, 'Sources/WebEnhancements', name + '.swift'), 'utf8');
const raw = name => {
  const match = read(name).match(/#"""\r?\n([\s\S]*?)\r?\n\s*"""#/);
  assert.ok(match, name + ' raw Swift literal exists');
  return match[1];
};
const defaults = { enableEnhancements: true, hidePromotedPosts: true, hidePromotedTrends: true,
  hideRecommendedUsers: true, hideViewCount: true, postFontPercent: 130 };
function source(settings = defaults) {
  const swift = read('WebScript');
  const template = swift.match(/return """\r?\n([\s\S]*?)\r?\n\s*"""/)[1];
  return template.replace('\\(json)', JSON.stringify(settings))
    .replace('\\(AdBlockScript.source)', raw('AdBlockScript'))
    .replace('\\(TimelineCleanupScript.source)', raw('TimelineCleanupScript'))
    .replace('\\(AppearanceScript.source)', raw('AppearanceScript'))
    .replace('\\(runtime)', raw('WebScript'));
}
const fixture = `
<article data-testid="tweet" id="ad"><span data-testid="promotedIndicator">Promoted</span><div data-testid="tweetText">Paid post</div></article>
<article data-testid="tweet" id="organic"><div data-testid="tweetText" style="font-size:20px" id="body">Promoted products are a topic</div>
 <div role="group"><a href="/alice/status/123/analytics" id="views">100 Views</a><a href="/alice/status/123" id="replies">Replies</a><a href="https://evil.example/alice/status/123/analytics" id="external">External</a></div></article>
<article data-testid="tweet" id="bodyOnly"><div data-testid="tweetText">Ad</div></article>
<div data-testid="trend" id="trend"><span>프로모션</span></div>
<div data-testid="trend" id="normalTrend"><span>Today's news</span></div>
<aside aria-label="Who to follow" id="recommended"><div data-testid="UserCell">Alice</div></aside>
<section aria-label="Who to follow" id="feed"><article data-testid="tweet">Post</article><div data-testid="UserCell">Author</div></section>
<div id="unrelated" style="font-size:12px">Navigation</div>`;
function page(url = 'https://x.com/home') { return new JSDOM(fixture, { url, runScripts: 'outside-only', pretendToBeVisual: true }); }
const isHidden = (dom, id) => dom.window.document.getElementById(id).getAttribute('data-piko-hidden') === 'true';
const wait = ms => new Promise(resolve => setTimeout(resolve, ms));

test('generated JavaScript parses and XcodeGen YAML has unique keys and real paths', () => {
  new vm.Script(source());
  const spec = YAML.parse(fs.readFileSync(path.join(root, 'project.yml'), 'utf8'), { uniqueKeys: true });
  assert.equal(spec.targets.PikoIOS.platform, 'iOS');
  for (const entry of spec.targets.PikoIOS.sources) assert.ok(fs.existsSync(path.join(root, entry.path)));
  assert.ok(fs.existsSync(path.join(root, spec.targets.PikoIOS.settings.base.INFOPLIST_FILE)));
});
test('hides identified ads, trends, recommendations and scoped analytics only', () => {
  const dom = page();
  try {
    dom.window.eval(source());
    for (const id of ['ad', 'trend', 'recommended', 'views']) assert.ok(isHidden(dom, id), id);
    for (const id of ['organic', 'bodyOnly', 'normalTrend', 'feed', 'replies', 'external']) assert.ok(!isHidden(dom, id), id);
    assert.equal(dom.window.document.getElementById('body').style.fontSize, '26px');
    assert.equal(dom.window.document.getElementById('unrelated').style.fontSize, '12px');
  } finally { dom.window.close(); }
});
test('reinjecting or disabling restores original styles and hidden elements without compounding', () => {
  const dom = page();
  try {
    dom.window.eval(source());
    dom.window.eval(source());
    assert.equal(dom.window.document.getElementById('body').style.fontSize, '26px');
    dom.window.eval(source({ ...defaults, enableEnhancements: false }));
    assert.equal(dom.window.document.querySelectorAll('[data-piko-hidden]').length, 0);
    assert.equal(dom.window.document.getElementById('body').style.fontSize, '20px');
    assert.equal(dom.window.document.querySelectorAll('style').length, 0);
  } finally { dom.window.close(); }
});
test('feature toggles are independent', () => {
  const dom = page();
  try {
    dom.window.eval(source({ ...defaults, hidePromotedPosts: false, hideViewCount: false }));
    assert.ok(!isHidden(dom, 'ad'));
    assert.ok(!isHidden(dom, 'views'));
    assert.ok(isHidden(dom, 'trend'));
  } finally { dom.window.close(); }
});
test('placement layout requires a promotion label outside body and author', () => {
  const dom = page();
  try {
    dom.window.document.body.insertAdjacentHTML('beforeend', `
      <div data-testid="placementTracking"><article data-testid="tweet" id="placementAd"><span>Ad</span><div data-testid="tweetText">Hello</div></article></div>
      <div data-testid="placementTracking"><article data-testid="tweet" id="placementOrganic"><div data-testid="tweetText"><span>Ad</span></div><div data-testid="User-Name"><span>Ad</span></div></article></div>`);
    dom.window.eval(source());
    assert.ok(isHidden(dom, 'placementAd'));
    assert.ok(!isHidden(dom, 'placementOrganic'));
  } finally { dom.window.close(); }
});
test('rejects lookalike hosts and insecure origins', () => {
  for (const url of ['https://x.com.evil.example/', 'https://evilx.com/', 'https://faketwitter.com/', 'http://x.com/', 'https://x.com:8443/']) {
    const dom = page(url);
    try {
      dom.window.eval(source());
      assert.equal(dom.window.document.querySelectorAll('[data-piko-hidden]').length, 0);
      assert.equal(dom.window.__pikoCleanup, undefined);
    } finally { dom.window.close(); }
  }
});
test('enhancements survive X-owned subdomain redirects', () => {
  for (const url of ['https://mobile.x.com/home', 'https://foo.x.com/test', 'https://mobile.twitter.com/home']) {
    const dom = page(url);
    try {
      dom.window.eval(source());
      assert.ok(isHidden(dom, 'ad'));
      assert.ok(isHidden(dom, 'views'));
      assert.equal(dom.window.document.getElementById('body').style.fontSize, '26px');
    } finally { dom.window.close(); }
  }
});
test('dynamic insertions and recycled content update; observer settles', async () => {
  const dom = page();
  try {
    let scans = 0;
    const original = dom.window.document.querySelectorAll.bind(dom.window.document);
    dom.window.document.querySelectorAll = (...args) => { scans++; return original(...args); };
    dom.window.eval(source());
    const ad = dom.window.document.createElement('article');
    ad.id = 'dynamic'; ad.setAttribute('data-testid', 'tweet');
    ad.innerHTML = '<span data-testid="promotedLabel">광고</span>';
    dom.window.document.body.appendChild(ad);
    await wait(260);
    assert.ok(isHidden(dom, 'dynamic'));
    ad.innerHTML = '<div data-testid="tweetText">Regular post</div>';
    await wait(260);
    assert.ok(!isHidden(dom, 'dynamic'));
    const stable = scans;
    await wait(260);
    assert.equal(scans, stable, 'own modifications must not trigger endless scans');
  } finally { dom.window.close(); }
});
test('font clamps to range and reset restores existing priority', () => {
  const dom = page();
  try {
    const body = dom.window.document.getElementById('body');
    body.style.setProperty('font-size', '20px', 'important');
    dom.window.eval(source({ ...defaults, postFontPercent: 1000 }));
    assert.equal(body.style.fontSize, '32px');
    dom.window.eval(source({ ...defaults, postFontPercent: 1 }));
    assert.equal(body.style.fontSize, '16px');
    dom.window.__pikoCleanup();
    assert.equal(body.style.fontSize, '20px');
    assert.equal(body.style.getPropertyPriority('font-size'), 'important');
  } finally { dom.window.close(); }
});
test('unsupported selectors fail open and other features continue', () => {
  const dom = page();
  try {
    const original = dom.window.document.querySelectorAll.bind(dom.window.document);
    dom.window.document.querySelectorAll = selector => {
      if (selector === 'article[data-testid="tweet"]') throw new Error('Selector changed');
      return original(selector);
    };
    dom.window.eval(source());
    assert.ok(!isHidden(dom, 'ad'));
    assert.ok(isHidden(dom, 'views'));
    assert.equal(dom.window.document.getElementById('body').style.fontSize, '26px');
  } finally { dom.window.close(); }
});
