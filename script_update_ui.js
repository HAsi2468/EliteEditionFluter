const fs = require('fs');

let c = fs.readFileSync('lib/modules/inventory/view/inventory_view.dart', 'utf8');

// 1. Add new menu items in the PopupMenuButton
const newMenuItems = `
                PopupMenuItem<String>(
                  value: 'parties',
                  child: Row(
                    children: [
                      Icon(Icons.business_outlined, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Manage Parties', style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delivery_partners',
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Manage Delivery Partners', style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'products',`;
c = c.replace(/PopupMenuItem<String>\(\s*value:\s*'products',/m, newMenuItems);

// 2. Add Stock Out Button next to Add Inventory
const stockOutButton = `
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const StockOutScannerView());
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Stock Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColor.primary900 : Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(`;
c = c.replace(/ElevatedButton\.icon\(/, stockOutButton);

// 3. Handle new menu options in onSelected
const onSelectedLogic = `
                } else if (value == 'parties') {
                  _showManageNewPartiesDialog(context);
                } else if (value == 'delivery_partners') {
                  _showManageDeliveryPartnersDialog(context);
                } else if (value == 'products') {`;
c = c.replace(/\} else if \(value == 'products'\) \{/, onSelectedLogic);

// 4. Add the import for StockOutScannerView
c = "import 'package:elite_edition/modules/inventory/view/stock_out_scanner_view.dart';\n" + c;

// 5. Replace references of Party to Vendor for the existing code
c = c.replace(/_showManagePartiesDialog/g, '_showManageVendorsDialog')
     .replace(/'Manage Parties'/g, "'Manage Vendors'")
     .replace(/"Manage Parties"/g, '"Manage Vendors"')
     .replace(/partiesList/g, 'vendorsList')
     .replace(/addParty/g, 'addVendor')
     .replace(/deleteParty/g, 'deleteVendor')
     .replace(/editParty/g, 'editVendor')
     .replace(/prefillPartyForm/g, 'prefillVendorForm')
     .replace(/newPartyNameController/g, 'newVendorNameController')
     .replace(/newPartyPhoneController/g, 'newVendorPhoneController')
     .replace(/newPartyAddressController/g, 'newVendorAddressController')
     .replace(/selectedParty/g, 'selectedVendor')
     .replace(/value == 'parties'/g, "value == 'vendors'")
     .replace(/value:\s*'parties'/g, "value: 'vendors'");

// 6. Append new dialog methods to the end of the file before the last closing brace
const newDialogs = `
  void _showManageNewPartiesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              controller.isDarkMode.value ? AppColor.backgroundDark : Colors.white,
          title: Text("Manage Parties",
              style: TextStyle(
                  color: controller.isDarkMode.value
                      ? Colors.white
                      : Colors.black)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.newPartiesList.isEmpty) {
                      return Center(
                        child: Text("No parties found",
                            style: TextStyle(
                                color: controller.isDarkMode.value
                                    ? Colors.white70
                                    : Colors.black54)),
                      );
                    }
                    return ListView.builder(
                      itemCount: controller.newPartiesList.length,
                      itemBuilder: (context, index) {
                        final party = controller.newPartiesList[index];
                        return ListTile(
                          title: Text(party.name,
                              style: TextStyle(
                                  color: controller.isDarkMode.value
                                      ? Colors.white
                                      : Colors.black)),
                          subtitle: Text(party.phone,
                              style: TextStyle(
                                  color: controller.isDarkMode.value
                                      ? Colors.white70
                                      : Colors.black54)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[400]),
                                onPressed: () {
                                  controller.deleteNewParty(party.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Quick add dialog
                  },
                  child: const Text("Add New Party"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showManageDeliveryPartnersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              controller.isDarkMode.value ? AppColor.backgroundDark : Colors.white,
          title: Text("Manage Delivery Partners",
              style: TextStyle(
                  color: controller.isDarkMode.value
                      ? Colors.white
                      : Colors.black)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.deliveryPartnersList.isEmpty) {
                      return Center(
                        child: Text("No delivery partners found",
                            style: TextStyle(
                                color: controller.isDarkMode.value
                                    ? Colors.white70
                                    : Colors.black54)),
                      );
                    }
                    return ListView.builder(
                      itemCount: controller.deliveryPartnersList.length,
                      itemBuilder: (context, index) {
                        final partner = controller.deliveryPartnersList[index];
                        return ListTile(
                          title: Text(partner.name,
                              style: TextStyle(
                                  color: controller.isDarkMode.value
                                      ? Colors.white
                                      : Colors.black)),
                          subtitle: Text(partner.phone,
                              style: TextStyle(
                                  color: controller.isDarkMode.value
                                      ? Colors.white70
                                      : Colors.black54)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[400]),
                                onPressed: () {
                                  controller.deleteDeliveryPartner(partner.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Quick add dialog
                  },
                  child: const Text("Add New Partner"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
`;

c = c.replace(/}\s*$/, newDialogs);

fs.writeFileSync('lib/modules/inventory/view/inventory_view.dart', c);
