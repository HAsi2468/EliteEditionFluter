class ReportDataModel {
  final String itemSkuCode;
  final String salesCount;
  final int sellableAmount;
  final int avgRate;
  final double avgAmt;
  final dynamic orderDate;
  dynamic skuName;
  dynamic productImage;
  dynamic brand;
  final dynamic cr;
  final dynamic rto;

  ReportDataModel({
    required this.itemSkuCode,
    required this.salesCount,
    required this.sellableAmount,
    required this.avgRate,
    required this.avgAmt,
    required this.orderDate,
    required this.productImage,
    required this.skuName,
    this.brand,
    required this.cr,
    required this.rto,
  });

  factory ReportDataModel.fromJson(Map<String, dynamic> json) => ReportDataModel(
    itemSkuCode: (json["itemSKUCode"] ?? "").toString(),
    salesCount: (json["salesCount"] ?? "").toString(),
    sellableAmount: json["sellableAmount"] ?? 0,
    avgRate: json["avgRate"] ?? 0,
    avgAmt: (json["avgAmt"] ?? 0).toDouble(),
    orderDate: json["orderDate"],
    skuName: json["skuName"],
    productImage: json["productImage"],
    brand: json["brand"] ?? json["itemTypeBrand"] ?? "",
    cr: json["cr"],
    rto: json["rto"],
  );

}

