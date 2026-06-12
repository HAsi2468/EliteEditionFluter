abstract class ApiUrl {
  // static const String baseUrl = "http://localhost:3001/v1";
  static const String baseUrl = "http://3.7.174.180:3001/v1";
  //static const String baseUrl = "https://elite_edition.api.rdtextiles.com/v1";
  // static const String baseUrl = "http://127.0.0.1:3001/v1";
  static const String register = "auth/register";
  static const String login = "auth/login";
  static const String product = "products/get_orders";
  static const String productDetails = "products/get_sku_details";
  static const String filter = "filters_value";
  static const String productReport = "products/report";
  static const String brandReport = "products/brandReport";
  static const String inventory = "inventory";
  static const String productList = "products/list";
  static const String vendor = "vendor";
  static const String party = "party";
  static const String stockOut = "stockOut";
  static const String productBase = "products";

  static String getFullImageUrl(String? url) {
    if (url == null || url.isEmpty || url == "null") {
      return "https://placehold.co/600x400/png?text=Elite+Edition";
    }
    if (url.startsWith("http://") || url.startsWith("https://")) {
      return url;
    }
    try {
      final baseUri = Uri.parse(baseUrl);
      final hostUrl = "${baseUri.scheme}://${baseUri.host}:${baseUri.port}";
      if (url.startsWith("/")) {
        return "$hostUrl$url";
      } else {
        return "$hostUrl/$url";
      }
    } catch (e) {
      return url;
    }
  }
}
