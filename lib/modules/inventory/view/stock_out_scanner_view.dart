import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:elite_edition/modules/inventory/controller/inventory_controller.dart';
import 'package:elite_edition/shared_widget/app_snacks.dart';

class StockOutScannerView extends StatefulWidget {
  const StockOutScannerView({Key? key}) : super(key: key);

  @override
  State<StockOutScannerView> createState() => _StockOutScannerViewState();
}

class _StockOutScannerViewState extends State<StockOutScannerView> {
  final MobileScannerController cameraController = MobileScannerController();
  final InventoryController controller = Get.find();
  
  String? selectedParty;
  
  // local storage for scanned items
  // Format: [{skuCode: '123', qty: 1}, ...]
  List<Map<String, dynamic>> scannedItems = [];

  bool isSaving = false;
  
  // Debounce for scanning
  DateTime? lastScanTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Stock Out Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.camera_front),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // 1. Party Selection Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Party First',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                value: selectedParty,
                icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.black87),
                items: controller.newPartiesList.map((party) {
                  return DropdownMenuItem(
                    value: party.name,
                    child: Text(party.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedParty = val;
                  });
                },
              ),
            ),
          ),
          
          // 2. Small Scanner Area
          Container(
            height: 250,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  final String code = barcodes.first.rawValue!;
                  
                  // Simple debounce
                  if (lastScanTime == null || DateTime.now().difference(lastScanTime!).inSeconds > 1) {
                    lastScanTime = DateTime.now();
                    _handleScan(code);
                  }
                }
              },
            ),
          ),
          
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Scanned Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            ),
          ),
          const SizedBox(height: 8),
          
          // 3. List of Scanned Items
          Expanded(
            child: scannedItems.isEmpty 
              ? Center(
                  child: Text("No items scanned yet.", 
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16)
                  )
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: scannedItems.length,
                  itemBuilder: (context, index) {
                    final item = scannedItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_rounded, color: Colors.green.shade600, size: 20),
                        ),
                        title: Text("SKU: ${item['skuCode']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text("Quantity: ${item['qty']}", style: TextStyle(color: Colors.grey.shade600)),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_rounded, color: Colors.red.shade400, size: 20),
                                splashRadius: 20,
                                onPressed: () {
                                  setState(() {
                                    if (item['qty'] > 1) {
                                      item['qty']--;
                                    } else {
                                      scannedItems.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text("${item['qty']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              IconButton(
                                icon: Icon(Icons.add_rounded, color: Colors.green.shade600, size: 20),
                                splashRadius: 20,
                                onPressed: () {
                                  setState(() {
                                    item['qty']++;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ),
                    );
                  },
                ),
          ),
          
          // 4. Action Area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF1F2937), // AppColor.primary800 match
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: isSaving ? null : _saveAll,
              child: isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("Save All (${scannedItems.length} unique SKUs)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  void _handleScan(String sku) {
    if (selectedParty == null) {
      AppSnacks.errorSnack(message: "Please select a Party before scanning.");
      return;
    }
    
    setState(() {
      int idx = scannedItems.indexWhere((element) => element['skuCode'] == sku);
      if (idx >= 0) {
        scannedItems[idx]['qty'] += 1;
      } else {
        scannedItems.add({'skuCode': sku, 'qty': 1});
      }
    });
    
    // Optional: show a quick snackbar when adding
    AppSnacks.successSnack(message: "Added $sku (Total: ${scannedItems.firstWhere((e) => e['skuCode'] == sku)['qty']})");
  }

  Future<void> _saveAll() async {
    if (scannedItems.isEmpty) {
      AppSnacks.errorSnack(message: "No items to save.");
      return;
    }
    if (selectedParty == null) {
      AppSnacks.errorSnack(message: "Please select Party.");
      return;
    }

    setState(() {
      isSaving = true;
    });

    bool allSuccess = true;
    int successCount = 0;
    
    for (var item in scannedItems) {
      bool success = await controller.submitStockOut(
        item['skuCode'], 
        selectedParty!,
        qtyOut: item['qty']
      );
      if (success) {
        successCount++;
      } else {
        allSuccess = false;
      }
    }

    setState(() {
      isSaving = false;
    });

    if (allSuccess) {
      AppSnacks.successSnack(message: "Successfully saved $successCount items!");
      Navigator.of(context).pop();
    } else {
      AppSnacks.errorSnack(message: "Saved $successCount items, but some failed. Check for insufficient stock.");
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
