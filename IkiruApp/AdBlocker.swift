import WebKit

enum AdBlocker {

    // MARK: - Apply content blocking rules from bundled JSON
    static func apply(to config: WKWebViewConfiguration, completion: @escaping () -> Void) {
        guard let url = Bundle.main.url(forResource: "blockerList", withExtension: "json"),
              let jsonString = try? String(contentsOf: url, encoding: .utf8) else {
            completion()
            return
        }

        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "IkiruAdBlocker",
            encodedContentRuleList: jsonString
        ) { ruleList, error in
            if let ruleList = ruleList {
                config.userContentController.add(ruleList)
            }
            DispatchQueue.main.async { completion() }
        }
    }

    // MARK: - CSS to hide common ad elements
    static let cssHideScript: String = """
    (function() {
        var style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = `
            /* Generic ad containers */
            .ads, .ad, .advertisement, .ad-wrapper, .ad-container,
            .ad-banner, .ad-block, .ad-slot, .adsbygoogle,
            .banner-ads, .banner-ad, .ad-unit, .ad-area,
            .advert, .adverts, .advertise, .advertising,
            .sponsor, .sponsored, .sponsored-content,
            .promo, .promotion, .promotions,
            #ads, #ad, #advertisement, #ad-container,
            #ad-wrapper, #ad-banner, #banner-ad,
            #sponsor, #sponsored, #promo,
            [id^="google_ads"], [class^="google_ads"],
            [id*="advert"], [class*="advert"],
            [id*="_ad_"], [class*="_ad_"],
            [data-ad], [data-ads], [data-adunit],
            /* Google AdSense */
            ins.adsbygoogle,
            /* Common popup/overlay ads */
            .popup-ad, .popunder, .interstitial,
            .overlay-ad, .modal-ad,
            /* Floating ads */
            .floating-ad, .sticky-ad, .fixed-ad,
            /* Video ads */
            .video-ad, .preroll, .midroll,
            /* Social/native ads */
            .native-ad, .native-ads,
            [class*="taboola"], [id*="taboola"],
            [class*="outbrain"], [id*="outbrain"],
            [class*="mgid"], [id*="mgid"],
            [class*="criteo"], [id*="criteo"],
            [class*="revcontent"], [id*="revcontent"] {
                display: none !important;
                visibility: hidden !important;
                height: 0 !important;
                width: 0 !important;
                overflow: hidden !important;
            }
        `;
        document.head.appendChild(style);
    })();
    """
}
