class ProductDataModel {
  final String id;
  final String skuCode;
  String description;
  final int length;
  final int width;
  final int height;
  int weight;
  int price;
  final dynamic basePrice;
  List<String> color;
  List<String> size;
  String brand;
  final dynamic taxTypeCode;
  final dynamic gstTaxTypeCode;
  final String hsnCode;
  String categoryName;
  final String categoryCode;
  final String productPageUrl;
  String imageUrl;
  final List<dynamic> tags;
  final List<CustomFieldValue> customFieldValues;
  final dynamic inventorySnapshots;
  final bool expirable;
  final bool enabled;
  final dynamic shelfLife;
  final String skuType;
  final dynamic itemDetailFieldDtoList;

  ProductDataModel({
    required this.id,
    required this.skuCode,
    required this.description,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    required this.price,
    required this.basePrice,
    required this.color,
    required this.size,
    required this.brand,
    required this.taxTypeCode,
    required this.gstTaxTypeCode,
    required this.hsnCode,
    required this.categoryName,
    required this.categoryCode,
    required this.productPageUrl,
    required this.imageUrl,
    required this.tags,
    required this.customFieldValues,
    required this.inventorySnapshots,
    required this.expirable,
    required this.enabled,
    required this.shelfLife,
    required this.skuType,
    required this.itemDetailFieldDtoList,
  });

  factory ProductDataModel.fromJson(Map<String, dynamic> json) => ProductDataModel(
    id: json["id"].toString(),
    skuCode: json["skuCode"] ?? "",
    description: json["description"] ?? "",
    length: json["length"] ?? 0,
    width: json["width"] ?? 0,
    height: json["height"] ?? 0,
    weight: json["weight"] ?? 0,
    price: json["price"] ?? 0,
    basePrice: json["basePrice"],
    color: json["color"] != null ? List<String>.from(json["color"].where((x) => x != null).map((x) => x.toString())) : [],
    size: json["size"] != null ? List<String>.from(json["size"].where((x) => x != null).map((x) => x.toString())) : [],
    brand: json["brand"] ?? "",
    taxTypeCode: json["taxTypeCode"],
    gstTaxTypeCode: json["gstTaxTypeCode"],
    hsnCode: json["hsnCode"] ?? "",
    categoryName: json["categoryName"] ?? "",
    categoryCode: json["categoryCode"] ?? "",
    productPageUrl: json["productPageUrl"] ?? "",
    imageUrl: json["imageUrl"] ?? "",
    tags: json["tags"] != null ? List<dynamic>.from(json["tags"].where((x) => x != null).map((x) => x)) : [],
    customFieldValues: json["customFieldValues"] != null ? List<CustomFieldValue>.from(json["customFieldValues"].where((x) => x != null).map((x) => CustomFieldValue.fromJson(x))) : [],
    inventorySnapshots: json["inventorySnapshots"],
    expirable: json["expirable"] ?? false,
    enabled: json["enabled"] ?? true,
    shelfLife: json["shelfLife"],
    skuType: json["skuType"] ?? "",
    itemDetailFieldDtoList: json["itemDetailFieldDTOList"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "skuCode": skuCode,
    "description": description,
    "length": length,
    "width": width,
    "height": height,
    "weight": weight,
    "price": price,
    "basePrice": basePrice,
    "color": List<dynamic>.from(color.map((x) => x)),
    "size": List<dynamic>.from(size.map((x) => x)),
    "brand": brand,
    "taxTypeCode": taxTypeCode,
    "gstTaxTypeCode": gstTaxTypeCode,
    "hsnCode": hsnCode,
    "categoryName": categoryName,
    "categoryCode": categoryCode,
    "productPageUrl": productPageUrl,
    "imageUrl": imageUrl,
    "tags": List<dynamic>.from(tags.map((x) => x)),
    "customFieldValues": List<dynamic>.from(customFieldValues.map((x) => x.toJson())),
    "inventorySnapshots": inventorySnapshots,
    "expirable": expirable,
    "enabled": enabled,
    "shelfLife": shelfLife,
    "skuType": skuType,
    "itemDetailFieldDTOList": itemDetailFieldDtoList,
  };
}

class CustomFieldValue {
  final dynamic fieldName;
  final dynamic fieldValue;
  final dynamic valueType;
  final dynamic displayName;
  final bool required;
  final dynamic possibleValues;

  CustomFieldValue({
    required this.fieldName,
    required this.fieldValue,
    required this.valueType,
    required this.displayName,
    required this.required,
    required this.possibleValues,
  });

  factory CustomFieldValue.fromJson(Map<String, dynamic> json) => CustomFieldValue(
    fieldName: json["fieldName"],
    fieldValue: json["fieldValue"],
    valueType: json["valueType"],
    displayName: json["displayName"],
    required: json["required"] ?? false,
    possibleValues: json["possibleValues"],
  );

  Map<String, dynamic> toJson() => {
    "fieldName": fieldName,
    "fieldValue": fieldValue,
    "valueType": valueType,
    "displayName": displayName,
    "required": required,
    "possibleValues": possibleValues,
  };
}
