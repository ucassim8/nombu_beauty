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
        primarySwatch: Colors.pink,
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
      appBar: AppBar(
        title: const Text('Booking Policies'),
        backgroundColor: Colors.pink.shade400,
        centerTitle: true,
      ),
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
* After hours (before 8 AM or after 6 PM) incur a R100 fee.

Refund & Satisfaction Policy
* No refunds on services. 

By booking an appointment, you agree to abide by our salon policies. Thank you for trusting us with your wig care!💗
@NOMBU BEAUTY
                  ''',
                  style: TextStyle(fontSize: 14, color: Colors.pink.shade700, height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => SplashScreen())),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Accept & Continue', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 20),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.pink.shade100, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.jpg', width: 130, height: 130),
                const SizedBox(height: 20),
                Text('NOMBU Beauty', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink.shade800)),
                const SizedBox(height: 8),
                Text('Your beauty, your way 🌸', style: TextStyle(fontSize: 15, color: Colors.pink.shade400, fontStyle: FontStyle.italic)),
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
        title: Row(
          children: [
            Image.asset('assets/Logonombu.jpg', width: 40, height: 40),
            const SizedBox(width: 12),
            const Text('NOMBU Beauty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.pink.shade400,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                if (category['name'] == 'Admin Dashboard') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceScreen(category: category['name'])));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.pink.shade100, Colors.pink.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.pink.shade200.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'], size: 45, color: Colors.pink.shade800),
                    const SizedBox(height: 10),
                    Text(category['name'], textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink.shade900)),
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

// ------------------------- SERVICE SCREEN (FORCED AFTER HOURS) -------------------------
class ServiceScreen extends StatefulWidget {
  final String category;
  ServiceScreen({required this.category});
  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final Map<String, List<Map<String, dynamic>>> servicesList = {
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
      {'name': 'Full glam (lashes)', 'price': 550},
    ],
  };

  final Map<String, List<String>> provinceLocations = {
    'Pretoria': ['Montana', 'Hammanskraal'],
    'Limpopo': ['Polokwane'],
  };

  String? selectedService, selectedProvince, selectedLocation, clientName, clientPhone;
  int? basePrice;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isAfterHours = false;

  int get finalPrice => (basePrice ?? 0) + (isAfterHours ? 100 : 0);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2027),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        // Logic: Force After Hours if hour is before 8 AM or from 6 PM (18:00) onwards
        if (picked.hour < 8 || picked.hour >= 18) {
          isAfterHours = true;
        } else {
          isAfterHours = false;
        }
      });
    }
  }

  void triggerWhatsApp() {
    if (selectedService == null || clientName == null || clientPhone == null ||
        selectedProvince == null || selectedLocation == null || 
        selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all fields!')));
      return;
    }

    String formattedDate = "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
    String formattedTime = selectedTime!.format(context);

    String message = 'Hello NOMBU Beauty 🌸\n\n'
        'Booking Request:\n'
        'Name: $clientName\n'
        'Phone: $clientPhone\n'
        'Service: $selectedService\n'
        'Location: $selectedLocation\n'
        'Date: $formattedDate at $formattedTime\n'
        '${isAfterHours ? "⚠️ After Hours Slot: Yes (R100 fee applied)\n" : ""}'
        'Estimated Price: R$finalPrice\n\n'
        'I will send my reference photo below. Thank you.';

    final String webUrl = "https://api.whatsapp.com/send?phone=27672412217&text=${Uri.encodeComponent(message)}";
    
    if (kIsWeb) js.context.callMethod('open', [webUrl, '_blank']);
    else launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);

    FirebaseFirestore.instance.collection('bookings').add({
      'clientName': clientName,
      'phoneNumber': clientPhone,
      'service': selectedService,
      'category': widget.category,
      'location': '$selectedLocation, $selectedProvince',
      'date': formattedDate,
      'time': formattedTime,
      'afterHours': isAfterHours,
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
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(decoration: InputDecoration(labelText: 'Your Name', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))), onChanged: (val) => clientName = val),
          const SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: 'WhatsApp Number', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))), keyboardType: TextInputType.phone, onChanged: (val) => clientPhone = val),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Select Province', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            items: provinceLocations.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (val) => setState(() { selectedProvince = val; selectedLocation = null; }),
          ),
          const SizedBox(height: 15),
          if (selectedProvince != null)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Location', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              value: selectedLocation,
              items: provinceLocations[selectedProvince]!.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (val) => setState(() => selectedLocation = val),
            ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Select Service', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            items: servicesList[widget.category]!.map((e) => DropdownMenuItem(value: e['name'] as String, child: Text("${e['name']} (R${e['price']})"))).toList(),
            onChanged: (val) {
              setState(() {
                selectedService = val;
                basePrice = servicesList[widget.category]!.firstWhere((element) => element['name'] == val)['price'] as int;
              });
            },
          ),
          const SizedBox(height: 15),
          SwitchListTile(
            title: const Text("After Hours (R100 Fee)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
            subtitle: Text(isAfterHours ? "Automatically applied for your selected time." : "Slots before 8AM or after 6PM"),
            value: isAfterHours,
            activeColor: Colors.pink,
            onChanged: null, // Forces users to accept auto-logic based on time picker
          ),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.calendar_today, color: Colors.pink), label: Text(selectedDate == null ? "Date" : "${selectedDate!.day}/${selectedDate!.month}"), onPressed: () => _selectDate(context))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.access_time, color: Colors.pink), label: Text(selectedTime == null ? "Time" : selectedTime!.format(context)), onPressed: () => _selectTime(context))),
          ]),
          const SizedBox(height: 35),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: triggerWhatsApp,
            child: Text('Book Now (R$finalPrice)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    );
  }
}

// ------------------------- ADMIN DASHBOARD (EDIT & APPROVE) -------------------------
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _auth = false;
  final TextEditingController _pass = TextEditingController();

  void _showEditDialog(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    TextEditingController serviceCtrl = TextEditingController(text: data['service']);
    TextEditingController priceCtrl = TextEditingController(text: data['price'].toString());
    TextEditingController locCtrl = TextEditingController(text: data['location']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit & Approve Booking"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: serviceCtrl, decoration: const InputDecoration(labelText: "Service")),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price (R)"), keyboardType: TextInputType.number),
            TextField(controller: locCtrl, decoration: const InputDecoration(labelText: "Location")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              doc.reference.update({'service': serviceCtrl.text, 'price': int.parse(priceCtrl.text), 'location': locCtrl.text, 'status': 'Approved'});
              
              String msg = "Hello ${data['clientName']} 🌸,\n\n"
                  "Your booking for ${serviceCtrl.text} at NOMBU Beauty has been Approved!\n\n"
                  "Booking Details:\n"
                  "📍 Location: ${locCtrl.text}\n"
                  "📅 Date: ${data['date']} at ${data['time']}\n"
                  "💰 Total Price: R${priceCtrl.text}\n\n"
                  "To secure your slot, please pay a non-refundable deposit of R100.\n\n"
                  "Banking Details:\n"
                  "Bank: Capitec\n"
                  "Name: Mrs K Siwela\n"
                  "Account: 1867785194\n"
                  "Type: Savings\n\n"
                  "Please send proof of payment. We can't wait to see you! 💗";

              final String url = "https://api.whatsapp.com/send?phone=${data['phoneNumber'] ?? ""}&text=${Uri.encodeComponent(msg)}";
              if (kIsWeb) js.context.callMethod('open', [url, '_blank']);
              else launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              Navigator.pop(context);
            },
            child: const Text("Confirm & Send WhatsApp"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Login'), backgroundColor: Colors.pink.shade400),
        body: Center(child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_outline, size: 60, color: Colors.pink),
            const SizedBox(height: 20),
            TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400), onPressed: () { if (_pass.text == '2478') setState(() => _auth = true); }, child: const Text('Login', style: TextStyle(color: Colors.white)))
          ]),
        )),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings Manager'), backgroundColor: Colors.pink.shade400),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Text(data['clientName'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${data['service']}\n${data['location']}\n${data['date']} at ${data['time']}\nStatus: ${data['status']}"),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _showEditDialog(doc)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                ]),
              ),
            );
          }).toList());
        },
      ),
    );
  }
}
