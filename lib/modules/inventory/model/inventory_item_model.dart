class InventoryItemModel {
  final String id;
  final String party;
  final String itemName;
  final String size;
  final int currentlyAvailableStock;
  final double salePrice;
  final double purchasePrice;
  final int qty;
  final String? createdDateTime;
  final String? modifiedDateTime;

  InventoryItemModel({
    required this.id,
    required this.party,
    required this.itemName,
    required this.size,
    required this.currentlyAvailableStock,
    required this.salePrice,
    required this.purchasePrice,
    required this.qty,
    this.createdDateTime,
    this.modifiedDateTime,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) => InventoryItemModel(
        id: json["id"] ?? json["_id"] ?? "",
        party: json["party"] ?? "",
        itemName: json["itemName"] ?? "",
        size: json["size"] ?? "",
        currentlyAvailableStock: json["currentlyAvailableStock"] ?? 0,
        salePrice: (json["salePrice"] ?? 0.0).toDouble(),
        purchasePrice: (json["purchasePrice"] ?? 0.0).toDouble(),
        qty: json["qty"] ?? 0,
        createdDateTime: json["created_date_time"],
        modifiedDateTime: json["modified_date_time"],
      );

  Map<String, dynamic> toJson() => {
        "party": party,
        "itemName": itemName,
        "size": size,
        "currentlyAvailableStock": currentlyAvailableStock,
        "salePrice": salePrice,
        "purchasePrice": purchasePrice,
        "qty": qty,
      };
}
