const fs = require('fs');

let c = fs.readFileSync('lib/modules/inventory/view/inventory_view.dart', 'utf8');

const newAddPartyLogic = `
  void _showAddPartyDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Party"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Party Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await controller.addNewParty(
                  nameController.text,
                  phoneController.text,
                  addressController.text,
                );
                if (success) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showAddDeliveryPartnerDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    List<String> selectedParties = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Delivery Partner"),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Partner Name"),
                      ),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: "Phone"),
                      ),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: "Address"),
                      ),
                      const SizedBox(height: 16),
                      const Text("Select Associated Parties:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...controller.newPartiesList.map((party) {
                        return CheckboxListTile(
                          title: Text(party.name),
                          value: selectedParties.contains(party.name),
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedParties.add(party.name);
                              } else {
                                selectedParties.remove(party.name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool success = await controller.addDeliveryPartner(
                      nameController.text,
                      phoneController.text,
                      addressController.text,
                      selectedParties,
                    );
                    if (success) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
`;

// Inject before the last brace
c = c.replace(/}\s*$/, newAddPartyLogic + "\n}");

// Connect buttons
c = c.replace(/ElevatedButton\(\s*onPressed:\s*\(\)\s*{\s*\/\/\s*Quick\s*add\s*dialog\s*},\s*child:\s*const\s*Text\("Add New Party"\),\s*\)/, `ElevatedButton(onPressed: () => _showAddPartyDialog(context), child: const Text("Add New Party"),)`);

c = c.replace(/ElevatedButton\(\s*onPressed:\s*\(\)\s*{\s*\/\/\s*Quick\s*add\s*dialog\s*},\s*child:\s*const\s*Text\("Add New Partner"\),\s*\)/, `ElevatedButton(onPressed: () => _showAddDeliveryPartnerDialog(context), child: const Text("Add New Partner"),)`);

fs.writeFileSync('lib/modules/inventory/view/inventory_view.dart', c);
