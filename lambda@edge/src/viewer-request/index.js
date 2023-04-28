"use strict";

const authUser = "cute";
const authPass = "lovely";
const authString =
  "Basic " + Buffer.from(authUser + ":" + authPass).toString("base64");

const baseUrl = "https://cloudrun-next-app-clouddns-to-cloudfront.cliffzhao.com";
const availableLocales = ["ja", "en"];
const fallbackLocale = "ja";
const noNeedLocaleRedirectUriRegExpStrs = [
  // next.js にビルドされたやつ
  "/_next",
  // favicon
  "/favicon\\.ico",
  // `/public` の中のやつ
  "/assets",
  "/icons",
  "/manifest\\.json",
  // pwa 用のやつ
  "/sw\\.js",
  "/workbox",
  // sitemap
  "/sitemap\\.xml",
  // アプリ用の json ファイル
  "/\\.well-known",
  // sourcemap
  "\\.map",
  // next.js api
  "/api",
];

exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;

  if (headers.authorization?.[0]?.value !== authString) {
    const response = {
      status: "401",
      statusDescription: "Unauthorized",
      body: "Unauthorized",
      headers: {
        "www-authenticate": [
          {
            key: "WWW-Authenticate",
            value: "Basic",
          },
        ],
      },
    };
    callback(null, response);
    return;
  }

  /**
   * i18n SEO 対応のため、`Accept-Language` ヘッダーを見て、 `/ja` か `/en` に redirect します
   * ja が最優先の場合 `Accept-Language: ja,en;q=0.9,en-US;q=0.8` -> `/ja` へ
   * en が最優先の場合 `Accept-Language: en,ja;q=0.9,en-US;q=0.8` -> `/en` へ
   * その他が最優先の場合 `Accept-Language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7,ja;q=0.6` -> `/en` へ
   */
  const acceptLanguageHeaders = headers["accept-language"];
  const acceptLanguageHeaderValue =
    acceptLanguageHeaders?.[0]?.value ?? fallbackLocale;
  let curLocale = fallbackLocale;
  let curPos = null;
  availableLocales.forEach((locale) => {
    const pos = acceptLanguageHeaderValue.indexOf(locale);
    if (pos > -1 && (curPos == null || pos < curPos)) {
      curLocale = locale;
      curPos = pos;
    }
  });
  // uri はそもそも locale への redirect が要らないか
  const uriNoNeedLocaleRedirectRegExp = new RegExp(
    `${noNeedLocaleRedirectUriRegExpStrs.join("|")}`
  );
  // uri はすでに locale が入ってるか
  const uriLocaleIncludedRegExp = new RegExp(
    `\/(${availableLocales.join("|")})(\\W|$)`
  );
  if (
    !uriNoNeedLocaleRedirectRegExp.test(request.uri) &&
    !uriLocaleIncludedRegExp.test(request.uri)
  ) {
    const redirectResponse = {
      status: 301,
      headers: {
        location: [
          {
            key: "Location",
            value: `${baseUrl}/${curLocale}${request.uri}${
              request.querystring ? `?${request.querystring}` : ""
            }`,
          },
        ],
        "cache-control": [
          {
            key: "Cache-Control",
            value: "no-store",
          },
        ],
      },
    };
    callback(null, redirectResponse);
    return;
  }
};
