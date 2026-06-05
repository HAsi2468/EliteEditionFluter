class ProductListDataModel {
  final List<Product> product;
  final Meta meta;

  ProductListDataModel({
    required this.product,
    required this.meta,
  });

  factory ProductListDataModel.fromJson(Map<String, dynamic> json) =>
      ProductListDataModel(
        product:
            List<Product>.from(json["data"].map((x) => Product.fromJson(x))),
        meta: Meta.fromJson(json["meta"]),
      );
}

class Product {
  final String itemSkuCode;
  final String id;
  final String facility;
  final String category;
  final String itemTypeColor;
  String itemTypeBrand;
  final String itemTypeSize;
  final String mrp;
  final String totalPrice;
  final String discount;
  final String shippingAddressCity;
  final String shippingAddressState;
  final String shippingAddressPincode;
  final dynamic itemSKUCodeCount;
  final String saleOrderStatus;
  final DateTime orderDate;
  String productImage;
  String skuName;

  Product({
    required this.itemSkuCode,
    required this.id,
    required this.facility,
    required this.category,
    required this.itemTypeColor,
    required this.itemTypeBrand,
    required this.itemTypeSize,
    required this.mrp,
    required this.totalPrice,
    required this.discount,
    required this.shippingAddressCity,
    required this.shippingAddressState,
    required this.itemSKUCodeCount,
    required this.shippingAddressPincode,
    required this.orderDate,
    required this.saleOrderStatus,
    required this.productImage,
    required this.skuName,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        itemSkuCode: json["itemSKUCode"],
        id: json["id"].toString(),
        facility: json["facility"],
        category: json["category"],
        itemTypeColor: json["itemTypeColor"],
        itemTypeBrand: json["itemTypeBrand"],
        itemTypeSize: json["itemTypeSize"],
        mrp: json["mrp"],
        totalPrice: json["totalPrice"],
        discount: json["discount"],
        shippingAddressCity: json["shippingAddressCity"],
        shippingAddressState: json["shippingAddressState"],
        shippingAddressPincode: json["shippingAddressPincode"],
        orderDate: DateTime.parse(json["orderDate"]),
        productImage: json["productImage"] ?? "",
        saleOrderStatus: json["saleOrderStatus"] ?? "",
        itemSKUCodeCount: json["itemSKUCodeCount"],
        skuName: json["skuName"] ?? "",
      );
}

class Meta {
  final String currentPage;
  final String pageSize;

  Meta({
    required this.currentPage,
    required this.pageSize,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        currentPage: json["currentPage"].toString(),
        pageSize: json["pageSize"].toString(),
      );
}
