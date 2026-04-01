import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; 
import 'firebase_options.dart'; 

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

// ------------------------- MAIN -------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
* A non-refundable deposit of R100 is required to secure your appointment. This deposit will go towards your total cost.
* No Walk-ins will be accepted.

Cancellation & Rescheduling
* We require 24 hours notice for cancellation or rescheduling.
* Cancellations made within 24 hours will result in a forfeited deposit.

Late Policy
* Clients arriving more than an hour late may need to reschedule and the deposit will be forfeited.
* If we can still accommodate your appointment despite tardiness, a late fee of R50 will apply.

Refund & Satisfaction Policy
* No refunds on services. If you have any concerns, please notify us so we can address them.
* The remaining balance after the deposit is due at the time of the service.

By booking an appointment, you agree to abide by our salon policies. Thank you for trusting us with your wig care!💗
@NOMBU BEAUTY
                  ''',
                  style: TextStyle(fontSize: 14, color: Colors.pink.shade700),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => SplashScreen())),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.pink.shade100, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.jpg', width: 120, height: 120),
                const SizedBox(height: 16),
                Text('NOMBU Beauty',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade800)),
                const SizedBox(height: 8),
                Text('Your beauty, your way 🌸',
                    style: TextStyle(fontSize: 14, color: Colors.pink.shade400)),
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
            const SizedBox(width: 8),
            const Text('NOMBU Beauty',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1),
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                if (category['name'] == 'Admin Dashboard') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AdminDashboard()));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ServiceScreen(category: category['name'])));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.pink.shade100, Colors.pink.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.pink.shade200.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'], size: 50, color: Colors.pink.shade800),
                    const SizedBox(height: 12),
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

// ------------------------- SERVICE SCREEN -------------------------
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
  int? selectedPrice;
  bool afterHours = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? selectedProvince;
  String? selectedLocation;
  String? clientName;
  String? phoneNumber;

  final Map<String, List<String>> provinceLocations = {
    'Pretoria': ['Montana', 'Hammanskraal'],
    'Limpopo': ['Polokwane'],
  };

  final String stylistWhatsapp = '27672412217'; 

  bool get requiresFullBooking =>
      (widget.category == 'Hair Services' || widget.category == 'Makeup');
  bool get isHairLaundry => widget.category == 'Hair Laundry';

  Future<void> pickDateTime() async {
    DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      TimeOfDay? time;
      if (requiresFullBooking || isHairLaundry) {
        time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time == null) return;
      }
      setState(() {
        selectedDate = date;
        selectedTime = time ?? const TimeOfDay(hour: 0, minute: 0);
      });
    }
  }

  // FIX: Launch WhatsApp first to satisfy browser security
  Future<void> handleBooking() async {
    if (selectedService == null ||
        clientName == null ||
        phoneNumber == null ||
        selectedProvince == null ||
        selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    if ((requiresFullBooking || isHairLaundry) && selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date/time')),
      );
      return;
    }

    BookingRequest booking = BookingRequest(
      service: selectedService!,
      category: widget.category,
      date: selectedDate ?? DateTime.now(),
      time: selectedTime ?? const TimeOfDay(hour: 0, minute: 0),
      afterHours: afterHours,
      clientName: clientName!,
      phoneNumber: phoneNumber!,
      location: selectedLocation!,
      price: selectedPrice ?? 0,
    );

    // 1. Launch WhatsApp immediately (before any await calls)
    await sendWhatsAppRequest(booking);

    // 2. Save to Firebase in the background
    FirebaseFirestore.instance.collection('bookings').add({
      'service': booking.service,
      'category': booking.category,
      'date': "${booking.date.day}/${booking.date.month}/${booking.date.year}",
      'time': '${booking.time.hour}:${booking.time.minute.toString().padLeft(2, '0')}',
      'afterHours': booking.afterHours,
      'clientName': booking.clientName,
      'phoneNumber': booking.phoneNumber,
      'location': booking.location,
      'price': booking.price,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking request processed!')),
    );
  }

  Future<void> sendWhatsAppRequest(BookingRequest booking) async {
    int estimatedPrice = booking.price;
    if (booking.afterHours) estimatedPrice += 100;

    String message = 'Hello NOMBU Beauty 🌸\n\nI\'d like to request a booking.\n\n'
        'Name: ${booking.clientName}\nService: ${booking.service}\nCategory: ${booking.category}\nLocation: ${booking.location}\n';

    if (requiresFullBooking || isHairLaundry) {
      String dateStr = '${booking.date.day}/${booking.date.month}/${booking.date.year}';
      String timeStr = '${booking.time.hour}:${booking.time.minute.toString().padLeft(2, '0')}';
      message += (booking.category == 'Hair Laundry' ? 'Drop-off ' : '') + 'Date: $dateStr\nTime: $timeStr\n';
    }

    message += '\nEstimated Price: R$estimatedPrice\nFinal price to be confirmed.\n\nThank you.';

    final Uri whatsappUri = Uri.parse('https://wa.me/$stylistWhatsapp?text=${Uri.encodeFull(message)}');

    // Use external application mode which is more reliable on mobile and web
    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
       // Fallback to JS for desktop browsers that block the above
       if (kIsWeb) js.context.callMethod('open', [whatsappUri.toString()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categoryServices = services[widget.category]!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.category), backgroundColor: Colors.pink.shade400),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                  labelText: 'Your Name',
                  filled: true,
                  fillColor: Colors.pink.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              onChanged: (val) => clientName = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                  labelText: 'WhatsApp Number',
                  filled: true,
                  fillColor: Colors.pink.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              keyboardType: TextInputType.phone,
              onChanged: (val) => phoneNumber = val,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Province', filled: true, fillColor: Colors.pink.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              value: selectedProvince,
              items: provinceLocations.keys.map((prov) => DropdownMenuItem<String>(value: prov, child: Text(prov))).toList(),
              onChanged: (val) => setState(() { selectedProvince = val; selectedLocation = null; }),
            ),
            const SizedBox(height: 16),
            if (selectedProvince != null)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Select Location', filled: true, fillColor: Colors.pink.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                value: selectedLocation,
                items: provinceLocations[selectedProvince]!.map((loc) => DropdownMenuItem<String>(value: loc, child: Text(loc))).toList(),
                onChanged: (val) => setState(() => selectedLocation = val),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select a service', filled: true, fillColor: Colors.pink.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              value: selectedService,
              items: categoryServices.map((s) => DropdownMenuItem<String>(value: s['name'], child: Text('${s['name']} - R${s['price']}'))).toList(),
              onChanged: (val) => setState(() {
                  selectedService = val;
                  selectedPrice = categoryServices.firstWhere((s) => s['name'] == val)['price'];
                }),
            ),
            const SizedBox(height: 16),
            if (requiresFullBooking)
              Row(
                children: [
                  Checkbox(value: afterHours, onChanged: (val) => setState(() => afterHours = val!)),
                  const Text('After-hours (+R100)'),
                ],
              ),
            if (requiresFullBooking || isHairLaundry)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: pickDateTime,
                child: Text(selectedDate == null ? 'Select Date & Time' : 'Selected: ${selectedDate!.day}/${selectedDate!.month} ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: handleBooking,
              child: const Text('Send Booking Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
  final TextEditingController _passwordController = TextEditingController();
  bool _authenticated = false;

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Access'), backgroundColor: Colors.pink.shade400),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Enter password')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_passwordController.text == '2478') {
                    setState(() => _authenticated = true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong password')));
                  }
                },
                child: const Text('Enter'))
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: Colors.pink.shade400),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;
          if (bookings.isEmpty) return const Center(child: Text('No bookings found.'));

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  title: Text('${booking['clientName']} - ${booking['service']}'),
                  subtitle: Text('Status: ${booking['status']} | R${booking['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => requestPayment(booking)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => cancelBooking(booking)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> requestPayment(DocumentSnapshot booking) async {
    // Fix: Process WhatsApp Launch FIRST
    String rawPhone = booking['phoneNumber'];
    String cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '27' + cleanPhone.substring(1);
    } else if (!cleanPhone.startsWith('27')) {
      cleanPhone = '27' + cleanPhone;
    }

    String message = 'Hello ${booking['clientName']} 🌸\n\n'
        'Your booking is confirmed!\n\n'
        'Service: ${booking['service']}\n'
        'Date: ${booking['date']} at ${booking['time']}\n'
        'Price: R${booking['price']}\n\n'
        'Deposit: R100\n'
        'EFT: Capitec | Mrs K Siwela | 1867785194 | Savings\n\n'
        'Thank you 💗';

    final Uri url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeFull(message)}');

    // Launch WhatsApp
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (kIsWeb) js.context.callMethod('open', [url.toString()]);
    }

    // Update Firebase status in background
    FirebaseFirestore.instance.collection('bookings').doc(booking.id).update({'status': 'Approved'});
  }

  Future<void> cancelBooking(DocumentSnapshot booking) async {
    await FirebaseFirestore.instance.collection('bookings').doc(booking.id).delete();
  }
}

class BookingRequest {
  final String service, category, clientName, phoneNumber, location;
  final DateTime date;
  final TimeOfDay time;
  final bool afterHours;
  final int price;
  BookingRequest({required this.service, required this.category, required this.date, required this.time, required this.afterHours, required this.clientName, required this.phoneNumber, required this.location, required this.price});
}

