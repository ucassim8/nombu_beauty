import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; 
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

// ------------------------- BOOKING POLICIES (RESTORED) -------------------------
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
                  '''All appointments must be booked in advance through website/call or in person.
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
@NOMBU BEAUTY''',
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

// ------------------------- SPLASH SCREEN (RESTORED) -------------------------
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------- HOME SCREEN (RESTORED) -------------------------
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
      appBar: AppBar(title: const Text('NOMBU Beauty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.pink.shade400),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16),
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                if (category['name'] == 'Admin Dashboard') Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
                else Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceScreen(category: category['name'])));
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

// ------------------------- SERVICE SCREEN (RESTORED WITH CALCULATOR) -------------------------
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
  int? selectedPrice;
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

  int calculateTotal() {
    int base = selectedPrice ?? 0;
    return selectedTime.hour >= 18 ? base + 100 : base;
  }

  void showReviewAndSend() {
    if (selectedService == null || clientName == null || phoneNumber == null || selectedProvince == null || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields!')));
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Review Booking"),
        content: Text("Name: $clientName\nService: $selectedService\nTime: ${selectedTime.format(context)}\nTotal: R${calculateTotal()}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Edit")),
          ElevatedButton(onPressed: triggerWhatsApp, child: const Text("Confirm & Send")),
        ],
      ),
    );
  }

  void triggerWhatsApp() {
    Navigator.pop(context);
    String message = 'Hello NOMBU Beauty 🌸\nName: $clientName\nService: $selectedService\nLocation: $selectedLocation, $selectedProvince\nTime: ${selectedTime.format(context)}\nTotal: R${calculateTotal()}';
    final String webUrl = "https://api.whatsapp.com/send?phone=27672412217&text=${Uri.encodeComponent(message)}";
    
    if (kIsWeb) js.context.callMethod('open', [webUrl, '_blank']);
    else launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);

    FirebaseFirestore.instance.collection('bookings').add({
      'clientName': clientName,
      'service': selectedService,
      'phoneNumber': phoneNumber,
      'location': '$selectedLocation, $selectedProvince',
      'price': 'R${calculateTotal()}',
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
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Province'),
            items: ['Pretoria', 'Limpopo'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => selectedProvince = val),
          ),
          TextField(decoration: const InputDecoration(labelText: 'City/Suburb'), onChanged: (val) => selectedLocation = val),
          ListTile(
            title: Text("Preferred Time: ${selectedTime.format(context)}"),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
              if (picked != null) setState(() => selectedTime = picked);
            },
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Service'),
            items: services[widget.category]!.map((e) => DropdownMenuItem(value: e['name'] as String, child: Text("${e['name']} (R${e['price']})"))).toList(),
            onChanged: (val) {
              setState(() {
                selectedService = val;
                selectedPrice = services[widget.category]!.firstWhere((element) => element['name'] == val)['price'] as int;
              });
            },
          ),
          const SizedBox(height: 30),
          Text("Estimated Total: R${calculateTotal()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink)),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, minimumSize: const Size(double.infinity, 50)),
            onPressed: showReviewAndSend,
            child: const Text('Review & Send via WhatsApp', style: TextStyle(color: Colors.white)),
          )
        ]),
      ),
    );
  }
}

// ------------------------- ADMIN DASHBOARD (RESTORED & FIXED) -------------------------
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _auth = false;
  String search = "";
  final TextEditingController _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!_auth) {
      return Scaffold(
        body: Center(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            ElevatedButton(onPressed: () { if (_pass.text == '2478') setState(() => _auth = true); }, child: const Text('Login'))
          ]),
        )),
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
                hintText: "Search Client Name", 
                fillColor: Colors.white, 
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => search = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs.where((d) => d['clientName'].toString().toLowerCase().contains(search)).toList();
          
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              var d = docs[i];
              return ListTile(
                title: Text(d['clientName']),
                subtitle: Text("${d['service']} - ${d['status']}\n${d['location']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => d.reference.update({'status': 'Approved'})),
                    IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => d.reference.update({'status': 'Declined'})),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
