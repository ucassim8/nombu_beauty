import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(NombuBeautyApp());
}

class NombuBeautyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOMBU Beauty',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Color(0xFFFDE6EB),
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Hair Services', 'icon': Icons.content_cut},
    {'name': 'Hair Laundry', 'icon': Icons.local_laundry_service},
    {'name': 'Makeup', 'icon': Icons.brush},
    {'name': 'Admin Dashboard', 'icon': Icons.admin_panel_settings},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NOMBU Beauty'),
        backgroundColor: Colors.pink.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                if (category['name'] == 'Admin Dashboard') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminDashboard()));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ServiceScreen(category: category['name'])));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade100, Colors.pink.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade200.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'], size: 50, color: Colors.pink.shade800),
                    SizedBox(height: 12),
                    Text(category['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade700)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ServiceScreen extends StatefulWidget {
  final String category;
  ServiceScreen({required this.category});

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final Map<String, List<Map<String, dynamic>>> services = {
    'Hair Services': [
      {'name': 'Basic instal', 'price': 200},
      {'name': 'Instal + styling', 'price': 280},
      {'name': 'Sew-in instal', 'price': 300},
      {'name': 'Instal + curling', 'price': 400},
      {'name': 'Frontal ponytail', 'price': 350},
    ],
    'Hair Laundry': [
      {'name': 'Wig wash', 'price': 150},
      {'name': 'Plugging', 'price': 80},
      {'name': 'Wig customisation (tint)', 'price': 180},
      {'name': 'Bleaching + plugging', 'price': 220},
    ],
    'Makeup': [
      {'name': 'Natural look', 'price': 300},
      {'name': 'Soft glam', 'price': 400},
      {'name': 'Soft glam (lashes)', 'price': 450},
      {'name': 'Full glam', 'price': 500},
      {'name': 'Full glam (lashes)', 'price': 550},
    ],
  };

  String? selectedService;
  String? selectedLocation;
  String? selectedPayment;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final List<String> locations = ['Pretoria', 'Limpopo'];
  final Map<String, List<String>> locationOptions = {
    'Pretoria': ['Montana', 'Hamanskraal'],
    'Limpopo': ['Polokwane'],
  };

  final List<String> paymentOptions = ['Card', 'Cash', 'E-wallet'];

  Future<void> submitBooking() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedService == null ||
        selectedLocation == null ||
        selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    final booking = {
      'name': nameController.text,
      'phone': phoneController.text,
      'service': selectedService,
      'location': selectedLocation,
      'payment': selectedPayment,
    };

    final prefs = await SharedPreferences.getInstance();
    final List<String> bookings =
        prefs.getStringList('bookings') ?? <String>[];
    bookings.add(jsonEncode(booking));
    await prefs.setStringList('bookings', bookings);

    final message =
        "Hi, I'd like to request a booking.\n\nName: ${nameController.text}\nService: $selectedService\nLocation: $selectedLocation\nPayment: $selectedPayment";
    final url = Uri.parse("https://wa.me/${phoneController.text}?text=${Uri.encodeFull(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryServices = services[widget.category] ?? [];
    final availableLocations = selectedLocation == null
        ? locations
        : locationOptions[selectedLocation!] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.category), backgroundColor: Colors.pink.shade400),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone number'),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedService,
              items: categoryServices
                  .map((s) => DropdownMenuItem(
                      value: s['name'],
                      child: Text('${s['name']} - R${s['price']}')))
                  .toList(),
              onChanged: (val) => setState(() => selectedService = val),
              decoration: InputDecoration(labelText: 'Service'),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedLocation,
              items: (selectedLocation == null
                      ? locations
                      : locationOptions[selectedLocation!] ?? [])
                  .map((loc) =>
                      DropdownMenuItem(value: loc, child: Text(loc)))
                  .toList(),
              onChanged: (val) => setState(() => selectedLocation = val),
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedPayment,
              items: paymentOptions
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => selectedPayment = val),
              decoration: InputDecoration(labelText: 'Payment method'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitBooking,
              child: Text('Send Booking Request via WhatsApp'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400),
            )
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _passwordController = TextEditingController();
  bool _authenticated = false;
  List<Map<String, dynamic>> bookingRequests = [];

  Future<void> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList('bookings') ?? [];
    setState(() {
      bookingRequests =
          stored.map((b) => jsonDecode(b) as Map<String, dynamic>).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return Scaffold(
        appBar: AppBar(title: Text('Admin Login'), backgroundColor: Colors.pink.shade400),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Enter password'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text == 'admin123') {
                  setState(() {
                    _authenticated = true;
                  });
                }
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400),
            )
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard'), backgroundColor: Colors.pink.shade400),
      body: bookingRequests.isEmpty
          ? Center(child: Text('No bookings yet'))
          : ListView.builder(
              itemCount: bookingRequests.length,
              itemBuilder: (context, index) {
                final req = bookingRequests[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('${req['name']} - ${req['service']}'),
                    subtitle: Text('Location: ${req['location']}\nPayment: ${req['payment']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            final url = Uri.parse(
                                'https://wa.me/${req['phone']}?text=${Uri.encodeFull("Hi ${req['name']}, your booking for ${req['service']} has been accepted.")}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            final url = Uri.parse(
                                'https://wa.me/${req['phone']}?text=${Uri.encodeFull("Hi ${req['name']}, unfortunately your booking for ${req['service']} has been declined.")}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
