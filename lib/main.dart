import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() => runApp(NombuBeautyApp());

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
      home: SplashScreen(),
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
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.jpg', width: 120, height: 120),
                SizedBox(height: 16),
                Text(
                  'NOMBU Beauty',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your beauty, your way 🌸',
                  style: TextStyle(fontSize: 14, color: Colors.pink.shade400),
                ),
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
            SizedBox(width: 8),
            Text(
              'NOMBU Beauty',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.pink.shade400,
        elevation: 5,
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
                    MaterialPageRoute(builder: (_) => AdminDashboard()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ServiceScreen(category: category['name']),
                    ),
                  );
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
                    Text(
                      category['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade700,
                      ),
                    ),
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

  // ------------------------- User Info -------------------------
  String? name;
  String? phone;

  String? selectedService;
  int? selectedPrice;
  bool afterHours = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // --- Location selection ---
  String? selectedProvince;
  String? selectedLocation;

  final Map<String, List<String>> provinceLocations = {
    'Pretoria': ['Montana', 'Hammanskraal'],
    'Limpopo': ['Polokwane'],
  };

  final String whatsappNumber = '+27672412217';

  // ------------------------- Blocked Dates -------------------------
  List<DateTime> blockedDates = [];

  bool get requiresFullBooking =>
      (widget.category == 'Hair Services' || widget.category == 'Makeup');
  bool get isHairLaundry => widget.category == 'Hair Laundry';

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      phone = prefs.getString('phone') ?? '';
    });
  }

  Future<void> saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name ?? '');
    prefs.setString('phone', phone ?? '');
  }

  // Pick date & time
  Future<void> pickDateTime() async {
    DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      selectableDayPredicate: (d) {
        for (var b in blockedDates) {
          if (d.year == b.year && d.month == b.month && d.day == b.day) {
            return false;
          }
        }
        return true;
      },
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
        selectedTime = time ?? TimeOfDay(hour: 0, minute: 0);
      });
    }
  }

  // Send WhatsApp booking
  void sendWhatsAppRequest() async {
    if (name == null || name!.isEmpty || phone == null || phone!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter your name and phone')));
      return;
    }
    if (selectedService == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a service')));
      return;
    }
    if (selectedProvince == null || selectedLocation == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a location')));
      return;
    }

    int estimatedPrice = selectedPrice ?? 0;
    if (afterHours) estimatedPrice += 100;

    String message =
        'Hello NOMBU Beauty 🌸\n\nName: $name\nPhone: $phone\n'
        'Service: $selectedService\nCategory: ${widget.category}\n'
        'Location: $selectedLocation\n';

    if (requiresFullBooking || isHairLaundry) {
      String dateStr =
          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
      String timeStr =
          '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}';
      message += (isHairLaundry ? 'Drop-off ' : '') +
          'Date: $dateStr\nTime: $timeStr\n';
    }

    message +=
        '\nEstimated Price: R$estimatedPrice\nFinal price to be confirmed by stylist.\n\nThank you.';

    String url = 'https://wa.me/$whatsappNumber?text=${Uri.encodeFull(message)}';
    if (await canLaunch(url)) await launch(url);

    saveUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categoryServices = services[widget.category]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.pink.shade400,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Name & Phone
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: Colors.pink.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              controller: TextEditingController(text: name),
              onChanged: (val) => name = val,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone',
                filled: true,
                fillColor: Colors.pink.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              controller: TextEditingController(text: phone),
              onChanged: (val) => phone = val,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            // Province Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Province',
                filled: true,
                fillColor: Colors.pink.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedProvince,
              items: provinceLocations.keys
                  .map((prov) => DropdownMenuItem<String>(
                        value: prov,
                        child: Text(prov),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedProvince = val;
                  selectedLocation = null;
                });
              },
            ),
            SizedBox(height: 16),

            // Location Dropdown
            if (selectedProvince != null)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Location',
                  filled: true,
                  fillColor: Colors.pink.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedLocation,
                items: provinceLocations[selectedProvince]!
                    .map((loc) => DropdownMenuItem<String>(
                          value: loc,
                          child: Text(loc),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedLocation = val;
                  });
                },
              ),
            SizedBox(height: 16),

            // Service Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select a service',
                filled: true,
                fillColor: Colors.pink.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedService,
              items: categoryServices
                  .map((s) => DropdownMenuItem<String>(
                        value: s['name'],
                        child: Text('${s['name']} - R${s['price']}'),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedService = val;
                  selectedPrice = categoryServices
                      .firstWhere((s) => s['name'] == val)['price'];
                });
              },
            ),
            SizedBox(height: 16),

            if (requiresFullBooking)
              Row(
                children: [
                  Checkbox(
                      value: afterHours,
                      onChanged: (val) => setState(() => afterHours = val!)),
                  Text('After-hours (+R100)'),
                ],
              ),

            if (requiresFullBooking || isHairLaundry)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: pickDateTime,
                child: Text(
                  selectedDate == null
                      ? (isHairLaundry
                          ? 'Select Drop-off Date & Time'
                          : 'Select Date & Time')
                      : 'Selected: ${selectedDate!.day}/${selectedDate!.month} ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                ),
              ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: sendWhatsAppRequest,
              child: Text(
                'Send Booking Request via WhatsApp',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
