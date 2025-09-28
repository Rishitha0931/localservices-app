import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Local Services',
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
  }
}
// ✅ Global Data
String customerName = '';
String customerAge = '';
String customerLocation = '';
bool isVendorLoggedIn = false;
List<Map<String, String>> vendors = [];
List<Map<String, String>> recentlyViewedVendors = [];

/// ✅ 1. FIRST PAGE
class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'VR Local',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  promoBox('PROMO-1'),
                  const SizedBox(width: 20),
                  promoBox('PROMO-2'),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WelcomeOptionsPage()));
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal[800]),
                child: const Text('Next'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget promoBox(String label) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white70, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

/// ✅ 2. WELCOME OPTIONS PAGE
class WelcomeOptionsPage extends StatelessWidget {
  const WelcomeOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('WELCOME!!',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                const Text('Are you a Vendor?'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpPage()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[600],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text('SIGN UP',
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
                const SizedBox(height: 30),
                const Text('Are you a Customer?'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CustomerInfoPage()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[600],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text('START',
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ 3. CUSTOMER INFO PAGE
class CustomerInfoPage extends StatefulWidget {
  const CustomerInfoPage({super.key});

  @override
  State<CustomerInfoPage> createState() => _CustomerInfoPageState();
}

class _CustomerInfoPageState extends State<CustomerInfoPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  void saveInfo() {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    customerName = nameController.text;
    customerAge = ageController.text;
    customerLocation = locationController.text;

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const CategoriesPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Enter Your Info'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 15),
          TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number),
          const SizedBox(height: 15),
          TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location')),
          const SizedBox(height: 30),
          ElevatedButton(
              onPressed: saveInfo,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Continue'))
        ]),
      ),
    );
  }
}

/// ✅ 4. CATEGORIES PAGE
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  final List<String> categories = const [
    'Laundry',
    'Ironing',
    'Handmade Gifts',
    'Music Class',
    'Mehendi',
    'Beauty & Wellness',
    'Photography',
    'Electricians',
    'Mechanics',
    'Cleaning Services',
    'Baking',
    'Gardening',
    'Computer Repair',
    'Packing & Moving',
    'Delivery Services',
    'Yoga & Fitness',
    'Tutor',
    'Dance Class',
    'Karate',
    'Tailor'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CATEGORIES'),
        backgroundColor: Colors.teal,
        actions: [
          isVendorLoggedIn
              ? IconButton(
                  icon: const Icon(Icons.business_center),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VendorDashboardPage()));
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CustomerDashboardPage()));
                  },
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VendorListPage(category: categories[index])));
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal, width: 1)),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Text(categories[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ✅ 5. VENDOR DASHBOARD WITH EDIT OPTION
class VendorDashboardPage extends StatelessWidget {
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoriesPage()),
                  (route) => false);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: vendors.isEmpty
            ? const Text('No vendor details found.')
            : ListView.builder(
                itemCount: vendors.length,
                itemBuilder: (context, index) {
                  var vendor = vendors[index];
                  return Card(
                    child: ListTile(
                      title: Text(vendor['name'] ?? ''),
                      subtitle: Text('Service: ${vendor['service']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditVendorPage(
                                    index: index, vendor: vendor)),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// ✅ 6. EDIT VENDOR PAGE
class EditVendorPage extends StatefulWidget {
  final int index;
  final Map<String, String> vendor;

  const EditVendorPage({super.key, required this.index, required this.vendor});

  @override
  State<EditVendorPage> createState() => _EditVendorPageState();
}

class _EditVendorPageState extends State<EditVendorPage> {
  late TextEditingController nameController;
  late TextEditingController areaController;
  late TextEditingController addressController;
  late TextEditingController priceController;
  late TextEditingController availableDaysController;
  late TextEditingController timingController;
  late TextEditingController specialTimingController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.vendor['name']);
    areaController = TextEditingController(text: widget.vendor['area']);
    addressController = TextEditingController(text: widget.vendor['address']);
    priceController = TextEditingController(text: widget.vendor['price']);
    availableDaysController =
        TextEditingController(text: widget.vendor['availableDays']);
    timingController = TextEditingController(text: widget.vendor['timing']);
    specialTimingController =
        TextEditingController(text: widget.vendor['specialTiming']);
  }

  void saveChanges() {
    vendors[widget.index] = {
      'name': nameController.text,
      'service': widget.vendor['service'] ?? '',
      'area': areaController.text,
      'address': addressController.text,
      'price': priceController.text,
      'availableDays': availableDaysController.text,
      'timing': timingController.text,
      'specialTiming': specialTimingController.text,
      'rating': widget.vendor['rating'] ?? '4.5',
      'reviews': widget.vendor['reviews'] ?? '50'
    };

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Vendor details updated')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Edit Vendor Details'),
          backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Business Name')),
          const SizedBox(height: 10),
          TextField(
              controller: areaController,
              decoration: const InputDecoration(labelText: 'Area')),
          const SizedBox(height: 10),
          TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Full Address')),
          const SizedBox(height: 10),
          TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price Range'),
              keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          TextField(
              controller: availableDaysController,
              decoration: const InputDecoration(labelText: 'Available Days')),
          const SizedBox(height: 10),
          TextField(
              controller: timingController,
              decoration: const InputDecoration(labelText: 'General Timing')),
          const SizedBox(height: 10),
          TextField(
              controller: specialTimingController,
              decoration: const InputDecoration(labelText: 'Special Timing')),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: saveChanges,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Save Changes')),
        ]),
      ),
    );
  }
}

/// ✅ 7. CUSTOMER DASHBOARD
class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  final TextEditingController nameController =
      TextEditingController(text: customerName);
  final TextEditingController ageController =
      TextEditingController(text: customerAge);
  final TextEditingController locationController =
      TextEditingController(text: customerLocation);

  void saveEdits() {
    setState(() {
      customerName = nameController.text;
      customerAge = ageController.text;
      customerLocation = locationController.text;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile Updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoriesPage()),
                  (route) => false);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 10),
          TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age')),
          const SizedBox(height: 10),
          TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location')),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: saveEdits,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Save Changes')),
          const SizedBox(height: 30),
          const Text('Recently Viewed Vendors:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: recentlyViewedVendors.isEmpty
                ? const Text('No vendors viewed yet.')
                : ListView.builder(
                    itemCount: recentlyViewedVendors.length,
                    itemBuilder: (context, index) {
                      var vendor = recentlyViewedVendors[index];
                      return ListTile(
                        title: Text(vendor['name'] ?? ''),
                        subtitle: Text(vendor['service'] ?? ''),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

/// ✅ 8. VENDOR LIST PAGE
class VendorListPage extends StatelessWidget {
  final String category;
  const VendorListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredVendors =
        vendors.where((v) => v['service'] == category).toList();

    return Scaffold(
      appBar: AppBar(
          title: Text('Vendors - $category'), backgroundColor: Colors.teal),
      body: filteredVendors.isEmpty
          ? const Center(child: Text('No vendors available'))
          : ListView.builder(
              itemCount: filteredVendors.length,
              itemBuilder: (context, index) {
                var vendor = filteredVendors[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(vendor['name'] ?? ''),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Area: ${vendor['area']}'),
                          Text('Price: ${vendor['price']} onwards'),
                          Text(
                              'Rating: ${vendor['rating']} ⭐ (${vendor['reviews']} reviews)'),
                        ]),
                    onTap: () {
                      if (!recentlyViewedVendors.contains(vendor)) {
                        recentlyViewedVendors.add(vendor);
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  VendorProfilePage(vendor: vendor)));
                    },
                  ),
                );
              },
            ),
    );
  }
}

/// ✅ 9. VENDOR PROFILE PAGE
class VendorProfilePage extends StatelessWidget {
  final Map<String, String> vendor;
  const VendorProfilePage({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Profile'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(
              child: CircleAvatar(
                  radius: 40, child: Icon(Icons.person, size: 40))),
          const SizedBox(height: 20),
          Text('Vendor Name: ${vendor['name']}',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Service: ${vendor['service']}'),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LocationAvailabilityPage(vendor: vendor)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Location & Availability'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RatingsReviewsPage(vendor: vendor)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Ratings & Reviews'),
            ),
          ])
        ]),
      ),
    );
  }
}

/// ✅ 10. LOCATION AVAILABILITY PAGE
class LocationAvailabilityPage extends StatelessWidget {
  final Map<String, String> vendor;
  const LocationAvailabilityPage({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Location & Availability'),
          backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Area: ${vendor['area'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text('Full Address: ${vendor['address'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Text('Available Days: ${vendor['availableDays'] ?? 'N/A'}'),
          const SizedBox(height: 10),
          Text('General Timing: ${vendor['timing'] ?? 'N/A'}'),
          const SizedBox(height: 10),
          Text('Special Timing: ${vendor['specialTiming'] ?? 'N/A'}'),
        ]),
      ),
    );
  }
}

/// ✅ 11. RATINGS & REVIEWS PAGE
class RatingsReviewsPage extends StatelessWidget {
  final Map<String, String> vendor;
  const RatingsReviewsPage({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Ratings & Reviews'), backgroundColor: Colors.teal),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Rating: ${vendor['rating']} ⭐',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Reviews: ${vendor['reviews']}',
              style: const TextStyle(fontSize: 18)),
        ]),
      ),
    );
  }
}

/// ✅ 12. SIGN-UP PAGE FOR VENDOR
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController availableDaysController = TextEditingController();
  final TextEditingController timingController = TextEditingController();
  final TextEditingController specialTimingController = TextEditingController();

  void registerVendor() {
    if (nameController.text.isEmpty || serviceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all mandatory fields')));
      return;
    }

    vendors.add({
      'name': nameController.text,
      'service': serviceController.text,
      'area': areaController.text,
      'address': addressController.text,
      'price': priceController.text,
      'availableDays': availableDaysController.text,
      'timing': timingController.text,
      'specialTiming': specialTimingController.text,
      'rating': '4.5',
      'reviews': '50'
    });

    isVendorLoggedIn = true;

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor Registered Successfully')));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CategoriesPage()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Vendor Sign Up'), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Business Name')),
          const SizedBox(height: 10),
          TextField(
              controller: serviceController,
              decoration: const InputDecoration(labelText: 'Service Offered')),
          const SizedBox(height: 10),
          TextField(
              controller: areaController,
              decoration: const InputDecoration(labelText: 'Area')),
          const SizedBox(height: 10),
          TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Full Address')),
          const SizedBox(height: 10),
          TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price Range'),
              keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          TextField(
              controller: availableDaysController,
              decoration: const InputDecoration(labelText: 'Available Days')),
          const SizedBox(height: 10),
          TextField(
              controller: timingController,
              decoration: const InputDecoration(labelText: 'General Timing')),
          const SizedBox(height: 10),
          TextField(
              controller: specialTimingController,
              decoration: const InputDecoration(labelText: 'Special Timing')),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: registerVendor,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Register')),
        ]),
      ),
    );
  }
}
