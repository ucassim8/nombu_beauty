import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; 
import 'package:intl/intl.dart'; // Added for Date/Time formatting
import 'firebase_options.dart'; 
import 'dart:js' as js;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(NombuBeautyApp());
}

class NombuBeautyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOMBU Beauty',
      theme: ThemeData(
        primaryColor: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFDE6EB),
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: BookingPoliciesScreen(),
    );
  }
}

// ------------------------- BOOKING POLICIES -------------------------
class BookingPoliciesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Policies'), backgroundColor: Colors.pink.shade400),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
All appointments must be booked in advance through website/call or in person.
* A non-refundable deposit of R100 is required to secure your appointment.
* No Walk-ins will be accepted.

Cancellation & Rescheduling
* We require 24 hours notice for cancellation or rescheduling.
* Cancellations made within 24 hours will result in a forfeited deposit.

Late Policy
* Clients arriving more than an hour late may need to reschedule and the deposit will be forfeited.
* If we can still accommodate your appointment despite tardiness, a late fee of R50 will apply.

Refund & Satisfaction Policy
* No refunds on services. 

By booking an appointment, you agree to abide by our salon policies. Thank you for trusting us with your wig care!💗
@NOMBU BEAUTY
                  ''',
                  style: TextStyle(fontSize: 14, color: Colors.pink.shade700),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SplashScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              child: const Text('Accept & Continue', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------------- SPLASH SCREEN (Original Design) -------------------------
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.pink.shade100, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.jpg', width: 120, height: 120),
                const SizedBox(height: 16),
                Text('NOMBU Beauty', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.pink.shade800)),
                const SizedBox(height: 10),
                const Text("Where Beauty Meets Perfection", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.pink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------- HOME SCREEN -------------------------
class HomeScreen extends StatelessWidget {
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
        leading: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset('assets/logo.jpg')),
        title: const Text('NOMBU Beauty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.pink.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16),
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                if (category['name'] == 'Admin Dashboard') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceScreen(category: category['name'])));
                }
              },
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 5)]),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(category['icon'], size: 40, color: Colors.pink),
                  const SizedBox(height: 8),
                  Text(category['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ------------------------- SERVICE SCREEN (Updated with Calculator) -------------------------
class ServiceScreen extends StatefulWidget {
  final String category;
  ServiceScreen({required this.category});
  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final Map<String, List<Map<String, dynamic>>> services = {
    'Hair Services': [{'name': 'Basic instal', 'price': 200}, {'name': 'Instal + styling', 'price': 280}, {'name': 'Sew-in instal', 'price': 300}],
    'Hair Laundry': [{'name': 'Wig wash', 'price': 150}, {'name': 'Plugging', 'price': 80}],
    'Makeup': [{'name': 'Natural look', 'price': 300}, {'name': 'Soft glam', 'price': 400}],
  };

  String? selectedService, selectedProvince, selectedLocation, clientName, phoneNumber;
  int basePrice = 0;
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

  int calculateTotal() {
    return selectedTime.hour >= 18 ? basePrice + 100 : basePrice;
  }

  void showReviewPopup() {
    if (selectedService == null || clientName == null || phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill required fields!')));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Details"),
        content: Text("Service: $selectedService\nTime: ${selectedTime.format(context)}\nTotal: R${calculateTotal()}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Edit")),
          ElevatedButton(onPressed: triggerWhatsApp, child: const Text("Send")),
        ],
      ),
    );
  }

  void triggerWhatsApp() {
    Navigator.pop(context);
    String message = 'Hello NOMBU Beauty 🌸\nName: $clientName\nService: $selectedService\nTime: ${selectedTime.format(context)}\nTotal: R${calculateTotal()}';
    final String webUrl = "https://api.whatsapp.com/send?phone=27672412217&text=${Uri.encodeComponent(message)}";
    
    if (kIsWeb) js.context.callMethod('open', [webUrl, '_blank']);
    else launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);

    FirebaseFirestore.instance.collection('bookings').add({
      'clientName': clientName,
      'service': selectedService,
      'phoneNumber': phoneNumber,
      'price': 'R${calculateTotal()}',
      'time': selectedTime.format(context),
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category), backgroundColor: Colors.pink.shade400),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(decoration: const InputDecoration(labelText: 'Your Name'), onChanged: (val) => clientName = val),
          TextField(decoration: const InputDecoration(labelText: 'WhatsApp Number'), onChanged: (val) => phoneNumber = val),
          ListTile(
            title: Text("Time: ${selectedTime.format(context)}"),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
              if (picked != null) setState(() => selectedTime = picked);
            },
          ),
          DropdownButtonFormField<String>(
            items: services[widget.category]!.map((e) => DropdownMenuItem(value: e['name'] as String, child: Text("${e['name']} (R${e['price']})"))).toList(),
            onChanged: (val) {
              setState(() {
                selectedService = val;
                basePrice = services[widget.category]!.firstWhere((element) => element['name'] == val)['price'] as int;
              });
            },
          ),
          const SizedBox(height: 20),
          Text("Total: R${calculateTotal()}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: showReviewPopup, child: const Text('Review & Send')),
        ]),
      ),
    );
  }
}

// ------------------------- ADMIN DASHBOARD (Updated with Search & Earnings) -------------------------
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _auth = false;
  String searchQuery = "";
  final TextEditingController _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!_auth) {
      return Scaffold(
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          ElevatedButton(onPressed: () { if (_pass.text == '2478') setState(() => _auth = true); }, child: const Text('Login'))
        ])),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.pink.shade400,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
  hintText: "Search Name...", 
  fillColor: Colors.white, 
  filled: true, 
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none, // Keeps it clean without a thick black line
  ),
),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var docs = snapshot.data!.docs.where((d) => d['clientName'].toString().toLowerCase().contains(searchQuery)).toList();
          double totalPaid = 0;
          for (var d in docs) {
            if (d['status'] == 'Approved') totalPaid += double.tryParse(d['price'].toString().replaceAll('R', '')) ?? 0;
          }

          return Column(
            children: [
              Container(padding: const EdgeInsets.all(15), color: Colors.pink.shade700, width: double.infinity, child: Text("Approved Earnings: R$totalPaid", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(
                child: ListView(children: docs.map((doc) => ListTile(
                  title: Text(doc['clientName']),
                  subtitle: Text("${doc['service']} - ${doc['price']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {
                         // Quick status toggle or full edit dialog can go here
                         doc.reference.update({'status': 'Approved'});
                      }),
                      IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: () => launchUrl(Uri.parse("tel:${doc['phoneNumber']}"))),
                    ],
                  ),
                )).toList()),
              ),
            ],
          );
        },
      ),
    );
  }
}
