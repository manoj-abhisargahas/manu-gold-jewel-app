

// 🏛️ Block 1: Imports and Data Architecture (Ornament Model)
//This defines the structural blueprint for your data objects, including your new parameters: 
//purity carats and BIS certification tags.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const JewelShopApp());
}

class JewelShopApp extends StatelessWidget {
  const JewelShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manu Gold Jewel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(255, 187, 71, 1),
          primary: const Color.fromRGBO(57, 31, 31, 1),
          secondary: const Color.fromRGBO(255, 187, 71, 1),
          surface: Color.fromRGBO(255, 249, 233, 1),
        ),
        useMaterial3: true,
      ),
      home: const MainCatalogScreen(),
    );
  }
}

// 💎 Data Blueprint for every Jewelry item
class Ornament {
  final String name;
  final double weightInGrams;
  final bool isSilver;
  final int purityCarat;      // 👈 Added: 18, 22, or 24
  final String customTag;     // 👈 Added: e.g., "BIS 916 Hallmarked", "BIS Certified"
  final int daysToMake;
  final String imagePlaceholder;

  Ornament({
    required this.name,
    required this.weightInGrams,
    required this.isSilver,
    required this.purityCarat,
    required this.customTag,
    required this.daysToMake,
    required this.imagePlaceholder,
  });
}


// 🏛️ Block 2: Main Screen Widget and Local State Variables
// This initializes your core dynamic states (similar to React's useState). 
// It also houses your sample catalog matching the items.
class MainCatalogScreen extends StatefulWidget {
  const MainCatalogScreen({super.key});

  @override
  State<MainCatalogScreen> createState() => _MainCatalogScreenState();
}

class _MainCatalogScreenState extends State<MainCatalogScreen> {
  // 🔑 API Key Field (Insert your free goldapi.io key here)
  final String apiKey = "YOUR_FREE_GOLDAPI_IO_KEY";

  // 📈 App State Variables (Local defaults for Nellore market baselines)
  double baseGoldRate24k = 7800.0; 
  double baseSilverRate = 105.0;   
  bool isLoadingRates = false;
  String searchQuery = "";
  String selectedCategory = "All Ornaments";

  // 🧾 Showroom Constants
  final double laborCostPerGram = 450.0; 
  final double gstPercentage = 3.0; 

  final List<String> categories = [
    "All Ornaments", "Maang Tikka", "Nose Ring", "Ear Rings", "Jhumka", 
    "Kan Chain", "Sui Dhaga", "Choker", "Raani Haar", "Mangalsutra", 
    "Bangles", "Kada", "Anklets", "Toe Rings", "Silver Jewel"
  ];

  // 📋 Catalog Data Packaged with Purity and BIS Tags
  final List<Ornament> fullCatalog = [
    Ornament(name: "Traditional Maang Tikka", weightInGrams: 8.5, isSilver: false, purityCarat: 22, customTag: "BIS 916 Hallmarked", daysToMake: 5, imagePlaceholder: ""),
    Ornament(name: "Bridal Nose Ring", weightInGrams: 4.2, isSilver: false, purityCarat: 22, customTag: "BIS 916 Hallmarked", daysToMake: 3, imagePlaceholder: ""),
    Ornament(name: "Sleek Diamond Studs", weightInGrams: 5.0, isSilver: false, purityCarat: 18, customTag: "BIS 750 Certified", daysToMake: 4, imagePlaceholder: ""),
    Ornament(name: "Antique Gold Jhumka", weightInGrams: 14.5, isSilver: false, purityCarat: 22, customTag: "BIS 916 Hallmarked", daysToMake: 7, imagePlaceholder: ""),
    Ornament(name: "Lightweight Sui Dhaga", weightInGrams: 3.5, isSilver: false, purityCarat: 18, customTag: "BIS 750 Certified", daysToMake: 3, imagePlaceholder: ""),
    Ornament(name: "Royal Kundan Choker", weightInGrams: 45.0, isSilver: false, purityCarat: 22, customTag: "BIS 916 Hallmarked", daysToMake: 14, imagePlaceholder: ""),
    Ornament(name: "Grand Raani Haar", weightInGrams: 85.0, isSilver: false, purityCarat: 22, customTag: "BIS 916 Hallmarked", daysToMake: 21, imagePlaceholder: ""),
    Ornament(name: "Traditional Bangles Set", weightInGrams: 28.0, isSilver: false, purityCarat: 22, customTag: "BIS 916 Hallmarked", daysToMake: 8, imagePlaceholder: ""),
    Ornament(name: "Silver Bridal Anklets", weightInGrams: 60.0, isSilver: true, purityCarat: 0, customTag: "BIS Certified Silver", daysToMake: 5, imagePlaceholder: ""),
    Ornament(name: "Fancy Toe Rings", weightInGrams: 6.5, isSilver: true, purityCarat: 0, customTag: "925 Sterling Silver", daysToMake: 2, imagePlaceholder: ""),
  ];

  @override
  void initState() {
    super.initState();
    fetchLiveRates(); // Lifecycle trigger on component mount
  }


  // 📦 Block 3: The Logic Functions (API & Purity Calculations)
  // These functions handle the operational data pipeline.
  //The pricing formula dynamically shifts rates based on whether an item is Silver, 18K Gold, or 22K Gold.
  // 🌐 Live API Data Stream 
  Future<void> fetchLiveRates() async {
    if (apiKey == "YOUR_FREE_GOLDAPI_IO_KEY") return;
    setState(() => isLoadingRates = true);
    
    final Map<String, String> headers = {
      "x-access-token": apiKey,
      "Content-Type": "application/json"
    };

    try {
      final goldRes = await http.get(Uri.parse('https://goldapi.io'), headers: headers);
      final silverRes = await http.get(Uri.parse('https://goldapi.io'), headers: headers);

      if (goldRes.statusCode == 200 && silverRes.statusCode == 200) {
        double goldOunceInr = (jsonDecode(goldRes.body)['price'] as num).toDouble();
        double silverOunceInr = (jsonDecode(silverRes.body)['price'] as num).toDouble();

        setState(() {
          // Calculate 24K base rate per gram globally (+15% customs/import fees)
          baseGoldRate24k = (goldOunceInr / 31.1035) * 1.15;
          baseSilverRate = (silverOunceInr / 31.1035) * 1.15;
        });
      }
    } catch (e) {
      debugPrint("API Error, utilizing local marketplace defaults: $e");
    } finally {
      setState(() => isLoadingRates = false);
    }
  }

  // 🧮 Pricing Engine: Math switches dynamically based on Carat purity parameters
  double calculateFinalPrice(Ornament item) {
    double itemGramRate = 0.0;

    if (item.isSilver) {
      itemGramRate = baseSilverRate;
    } else {
      // Calculate dynamic price based on specific carat: (24K Rate * (Carat / 24))
      itemGramRate = baseGoldRate24k * (item.purityCarat / 24.0);
    }

    double materialCost = itemGramRate * item.weightInGrams;
    double laborCost = laborCostPerGram * item.weightInGrams;
    double subTotal = materialCost + laborCost;
    double gstAmount = (subTotal * gstPercentage) / 100;

    return subTotal + gstAmount;
  }


  // 📦 Block 4: Structural Framework Layout (Scaffold, Drawer, Search)
  // This is the root structural UI view block containing the hamburger sidebar menu drawer 
  //and the live filter engine search text fields.
  @override
  Widget build(BuildContext context) {
    // Computed Filtering logic
    List<Ornament> filteredItems = fullCatalog.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase());
      if (selectedCategory == "All Ornaments") return matchesSearch;
      if (selectedCategory == "Silver Jewel") return item.isSilver && matchesSearch;
      return item.name.toLowerCase().contains(selectedCategory.toLowerCase()) && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.secondary,
        title: Text('Manu Gold Jewel', style: TextStyle(fontWeight: FontWeight.w600, color: Color.fromRGBO(255, 244, 213, 1))),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.secondary),
            onPressed: fetchLiveRates,
          )
        ],
      ),
      // 🍔 Hamburger Drawer Menu Block
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              accountName: const Text("Jewel Store Catalog", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(255, 244, 213, 1))),
              accountEmail: Text("Live 24K Gold: ₹${baseGoldRate24k.toStringAsFixed(0)}/g | Silver: ₹${baseSilverRate.toStringAsFixed(0)}/g", style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.6))),
              currentAccountPicture: CircleAvatar(backgroundColor: Color.fromARGB(41, 255, 193, 7), child: Icon(Icons.store, size: 36, color: Theme.of(context).colorScheme.secondary)),
            ),
            Expanded(
              child: Container(
                // color: Theme.of(context).colorScheme.surface,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final catName = categories[index];
                    return ListTile(
                      // leading: Icon(catName == "Silver Jewel" ? Icons.blur_circular : Icons.brightness_high_outlined, color: Colors.amber),
                      tileColor: null,
                      selectedTileColor: const Color.fromRGBO(255, 224, 171, 1),
                      title: Text(catName, style: TextStyle(fontWeight: selectedCategory == catName ? FontWeight.bold : FontWeight.normal)),
                      selected: selectedCategory == catName,
                      onTap: () {
                        setState(() => selectedCategory = catName);
                        Navigator.pop(context); // Dismiss sidebar drawer
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Dynamic Market Ticker Top Banner
          Container(
            // color: const Color.fromARGB(255, 255, 226, 176),
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Live 24K Gold: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color.fromARGB(255, 92, 67, 42))),
                Text("₹${baseGoldRate24k.toStringAsFixed(2)}/g", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color.fromRGBO(187, 126, 21, 1))),
                const Spacer(),
                Text("Silver: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color.fromARGB(255, 92, 67, 42))),
                Text("₹${baseSilverRate.toStringAsFixed(2)}/g", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color.fromRGBO(187, 126, 21, 1))),
              ],
            ),
          ),
          // 🔎 Search Engine input block
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search ornaments in $selectedCategory...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Next block injects the product presentation layout view area...

          // 📦 Block 5: The Responsive Grid & Product Card Layout View
          // This completes your file (_MainCatalogScreenState trailing block). 
          //It contains your dynamic column calculator and the code layout structure for your 
          //Purity Tag / Certification Badges rendering cleanly above the name string.
          // 💎 Product Card Matrix Board
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text("No ornaments found matching layout filters."))
                : GridView.builder(
                    padding: const EdgeInsets.all(0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // 🧭 RESPONSIVE GRAPH ENGINE (NO 'const' parents)
                      crossAxisCount: MediaQuery.of(context).size.width > 900
                          ? 4 
                          : MediaQuery.of(context).size.width > 600
                              ? 3 
                              : 2, 
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 0.6, // Slightly expanded to cleanly balance the new Tag layer
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final finalPrice = calculateFinalPrice(item);

                      return Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top graphic bounding panel
                            AspectRatio(
                              aspectRatio: 1/1,
                              child: Container(
                                height: 170,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(245, 245, 245, 1),
                                  // borderRadius: BorderRadius.circular(0),
                                ),
                                // child: Center(child: Text(item.imagePlaceholder, style: const TextStyle(fontSize: 36))),
                              ),
                            ),
                            // Ornament details container like
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🏷️ BIS CERTIFIED TAG VIEW (Sits prominently above name)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.isSilver ? Colors.grey.shade200 : const Color.fromARGB(255, 252, 189, 0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.customTag,
                                        style: TextStyle(
                                          fontSize: 9, 
                                          fontWeight: FontWeight.bold, 
                                          color: item.isSilver ? Colors.grey.shade800 : const Color(0xFF8B6508),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // 1. Ornament Profile Name
                                    Text(
                                      item.name, 
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis, 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    
                                    // 2. Weight Layout Specification 
                                    Text(
                                      "Wt: ${item.weightInGrams.toStringAsFixed(2)} g (${item.isSilver ? 'Silver' : '${item.purityCarat}K Gold'})", 
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),

                                    // 3. Calculated Price with Labour & 3% GST
                                    Text(
                                      "₹${finalPrice.toStringAsFixed(0)}", 
                                      style: const TextStyle(color: Color(0xFFB8860B), fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      "(Rate + Making + 3% GST)", 
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 8, fontStyle: FontStyle.italic),
                                    ),

                                    const SizedBox(height: 4),

                                    // 4. Time Metric Parameter
                                    Row(
                                      children: [
                                        const Icon(Icons.build_circle_outlined, size: 13, color: Color.fromARGB(255, 100, 100, 100)),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${item.daysToMake} Days", 
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 100, 100, 100)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}