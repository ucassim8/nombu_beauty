import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; 
import 'firebase_options.dart'; 

// ignore: avoid_web_libraries_in_flutter
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
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400, 
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Accept & Continue', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------------- SPLASH SCREEN -------------------------
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
                Image.asset('assets/logo.jpg', width: 140, height: 140),
                const SizedBox(height: 16),
                Text('NOMBU Beauty', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink.shade800)),
                const Text('Where Beauty Meets Perfection 🌸', 
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.pink)),
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
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(20), 
                  border: Border.all(color: Colors.pink.shade100, width: 2), 
                  boxShadow: [BoxShadow(color: Colors.pink.shade200.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(category['icon'], size: 42, color: Colors.pink.shade400),
                  const SizedBox(height: 10),
                  Text(category['name'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink.shade900)),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ------------------------- SERVICE SCREEN -------------------------
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

  void triggerWhatsApp() {
    if (selectedService == null || clientName == null || phoneNumber == null || selectedProvince == null || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields!')));
      return;
    }

    int finalPrice = selectedPrice ?? 0;
    String afterHoursNote = "";
    int currentHour = DateTime.now().hour;

    if (currentHour >= 18 || currentHour < 6) {
      finalPrice += 50;
      afterHoursNote = "\n⚠️ After-Hours Fee: R50 Included";
    }

    String message = 'Hello NOMBU Beauty 🌸\n\nBooking Request:\nName: $clientName\nPhone: $phoneNumber\nService: $selectedService\nLocation: $selectedLocation, $selectedProvince\nTotal Price: R$finalPrice$afterHoursNote';
    final String webUrl = "https://api.whatsapp.com/send?phone=27672412217&text=${Uri.encodeComponent(message)}";
    
    if (kIsWeb) js.context.callMethod('open', [webUrl, '_blank']);
    else launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);

    FirebaseFirestore.instance.collection('bookings').add({
      'clientName': clientName,
      'service': selectedService,
      'phoneNumber': phoneNumber,
      'location': '$selectedLocation, $selectedProvince',
      'price': finalPrice,
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
          TextField(decoration: InputDecoration(labelText: 'Your Name', labelStyle: TextStyle(color: Colors.pink.shade300)), onChanged: (val) => clientName = val),
          TextField(decoration: InputDecoration(labelText: 'WhatsApp Number', labelStyle: TextStyle(color: Colors.pink.shade300)), onChanged: (val) => phoneNumber = val),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Province', labelStyle: TextStyle(color: Colors.pink.shade300)),
            items: ['Pretoria', 'Limpopo'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => selectedProvince = val),
          ),
          TextField(decoration: InputDecoration(labelText: 'City/Suburb', labelStyle: TextStyle(color: Colors.pink.shade300)), onChanged: (val) => selectedLocation = val),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Service', labelStyle: TextStyle(color: Colors.pink.shade300)),
            items: services[widget.category]!.map((e) => DropdownMenuItem(value: e['name'] as String, child: Text("${e['name']} (R${e['price']})"))).toList(),
            onChanged: (val) {
              setState(() {
                selectedService = val;
                selectedPrice = services[widget.category]!.firstWhere((element) => element['name'] == val)['price'] as int;
              });
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: triggerWhatsApp,
            child: const Text('Send via WhatsApp', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    );
  }
}

// ------------------------- ADMIN DASHBOARD -------------------------
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _auth = false;
  final TextEditingController _pass = TextEditingController();

  void sendPaymentRequest(String clientPhone, String clientName) {
    String msg = "Hi $clientName, your NOMBU Beauty booking is APPROVED! 🌸\n\nTo secure your slot, please pay the R100 deposit to:\nBank: [Your Bank]\nAcc: [Your Account]\nRef: $clientName\n\nPlease send POP. Thank you!";
    final String url = "https://api.whatsapp.com/send?phone=$clientPhone&text=${Uri.encodeComponent(msg)}";
    if (kIsWeb) js.context.callMethod('open', [url, '_blank']);
    else launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth) {
      return Scaffold(
        body: Center(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_person, size: 60, color: Colors.pink),
            const SizedBox(height: 10),
            TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () { if (_pass.text == '2478') setState(() => _auth = true); }, child: const Text('Login'))
          ]),
        )),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: Colors.pink.shade400),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(children: snapshot.data!.docs.map((doc) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(doc['clientName'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${doc['service']} - ${doc['status']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () {
                    doc.reference.update({'status': 'Approved'});
                    sendPaymentRequest(doc['phoneNumber'], doc['clientName']);
                  }),
                  IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => doc.reference.update({'status': 'Declined'})),
                ],
              ),
            ),
          )).toList());
        },
      ),
    );
  }
}
