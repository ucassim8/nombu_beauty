import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:async';

void main() => runApp(NombuBeautyApp());

class NombuBeautyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOMBU Beauty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
  primarySwatch: Colors.pink,
  scaffoldBackgroundColor: Color(0xFFFDE6EB),
  // remove: fontFamily: 'PlayfairDisplay', 'Montserrat'
),
      home: SplashScreen(),
    );
  }
}

// ----------------- SPLASH SCREEN -----------------
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
    Timer(Duration(seconds: 3), () {
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Logonombu.jpg',
                width: 80,
                height: 80,
              ),
              SizedBox(width: 12),
              Text(
                'NOMBU Beauty',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- BOOKING MODEL -----------------
class BookingRequest {
  final String service;
  final DateTime date;
  final TimeOfDay time;
  final bool afterHours;
  final File? photo;
  String status;

  BookingRequest({
    required this.service,
    required this.date,
    required this.time,
    required this.afterHours,
    this.photo,
    this.status = 'Pending',
  });
}

List<BookingRequest> bookingRequests = [];

// ----------------- HOME SCREEN -----------------
class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Hair Services', 'icon': Icons.content_cut},
    {'name': 'Hair Laundry', 'icon': Icons.local_laundry_service},
    {'name': 'Makeup', 'icon': Icons.brush},
    {'name': 'Admin Dashboard', 'icon': Icons.dashboard},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/Logonombu.jpg', width: 40, height: 40),
            SizedBox(width: 8),
            Text('NOMBU Beauty')
          ],
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        int columns = 2;
        if (constraints.maxWidth > 1200) columns = 4;
        else if (constraints.maxWidth > 800) columns = 3;

        return Padding(
          padding: EdgeInsets.all(12),
          child: GridView.builder(
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (categories[index]['name'] == 'Admin Dashboard') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AdminDashboard()));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ServiceScreen(category: categories[index]['name'])));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.pinkAccent, Colors.pink.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.pink.shade100,
                          offset: Offset(4, 4),
                          blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(categories[index]['icon'], size: 50, color: Colors.white),
                      SizedBox(height: 12),
                      Text(categories[index]['name'],
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ----------------- SERVICE SCREEN -----------------
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
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  final String whatsappNumber = '0672412217';

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = File(image.path));
  }

  Future<void> pickDateTime() async {
    DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(now.year + 1));
    if (date != null) {
      final TimeOfDay? time =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) setState(() {
        selectedDate = date;
        selectedTime = time;
      });
    }
  }

  void sendWhatsAppRequest() async {
    if (selectedService == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please complete all fields')));
      return;
    }

    bookingRequests.add(BookingRequest(
        service: selectedService!,
        date: selectedDate!,
        time: selectedTime!,
        afterHours: afterHours,
        photo: selectedImage));

    int estimatedPrice = selectedPrice!;
    if (afterHours) estimatedPrice += 100;

    String dateStr =
        '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
    String timeStr =
        '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}';
    String message =
        'Hello NOMBU Beauty 🌸\n\nI\'d like to request a booking.\n\nService: $selectedService\nDate: $dateStr\nTime: $timeStr\n\nEstimated Price: R$estimatedPrice\nFinal price to be confirmed by stylist.\n\nI will send my reference hairstyle/photo.\n\nThank you.';

    String url = 'https://wa.me/$whatsappNumber?text=${Uri.encodeFull(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categoryServices = services[widget.category]!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: buildServiceSelection(categoryServices)),
                      SizedBox(width: 40),
                      Expanded(child: buildBookingOptions()),
                    ],
                  )
                : Column(
                    children: [
                      buildServiceSelection(categoryServices),
                      SizedBox(height: 20),
                      buildBookingOptions(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget buildServiceSelection(List<Map<String, dynamic>> categoryServices) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categoryServices
          .map((s) => ChoiceChip(
                label: Text('${s['name']} - R${s['price']}'),
                selected: selectedService == s['name'],
                onSelected: (_) {
                  setState(() {
                    selectedService = s['name'];
                    selectedPrice = s['price'];
                  });
                },
                selectedColor: Colors.pinkAccent,
                backgroundColor: Colors.pink.shade100,
                labelStyle: TextStyle(
                    color:
                        selectedService == s['name'] ? Colors.white : Colors.black),
              ))
          .toList(),
    );
  }

  Widget buildBookingOptions() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: afterHours,
              onChanged: (val) => setState(() => afterHours = val!),
            ),
            Text('After-hours (+R100)'),
          ],
        ),
        SizedBox(height: 12),
        ElevatedButton(
          onPressed: pickDateTime,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(selectedDate == null
              ? 'Select Date & Time'
              : 'Selected: ${selectedDate!.day}/${selectedDate!.month} ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'),
        ),
        SizedBox(height: 12),
        ElevatedButton(
          onPressed: pickImage,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade300,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(selectedImage == null
              ? 'Upload Reference Photo (Optional)'
              : 'Photo Selected'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: sendWhatsAppRequest,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('Send Booking Request via WhatsApp'),
        ),
      ],
    );
  }
}

// ----------------- ADMIN DASHBOARD -----------------
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _passwordController = TextEditingController();
  bool _authenticated = false;

  void _checkPassword() {
    if (_passwordController.text == '2478') {
      setState(() {
        _authenticated = true;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Wrong password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return Scaffold(
        appBar: AppBar(title: Text('Admin Dashboard')),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Enter password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _checkPassword, child: Text('Enter')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: bookingRequests.isEmpty
          ? Center(child: Text('No booking requests yet'))
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 800;
                return GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 2 : 1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3),
                  itemCount: bookingRequests.length,
                  itemBuilder: (context, index) {
                    BookingRequest req = bookingRequests[index];
                    Color tagColor = req.status == 'Pending'
                        ? Colors.orange
                        : req.status == 'Confirmed'
                            ? Colors.green
                            : Colors.red;

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: req.photo != null
                            ? Image.file(req.photo!, width: 50, height: 50)
                            : Icon(Icons.image_not_supported),
                        title: Text('${req.service}'),
                        subtitle: Text(
                            '${req.date.day}/${req.date.month}/${req.date.year} ${req.time.hour}:${req.time.minute.toString().padLeft(2, '0')}\nAfter-hours: ${req.afterHours ? "Yes" : "No"}'),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: tagColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(req.status,
                              style: TextStyle(color: Colors.white)),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text('Update Status'),
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        IconButton(
                                            icon:
                                                Icon(Icons.check, color: Colors.green),
                                            onPressed: () {
                                              setState(() {
                                                req.status = 'Confirmed';
                                              });
                                              Navigator.pop(context);
                                            }),
                                        IconButton(
                                            icon: Icon(Icons.close, color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                req.status = 'Declined';
                                              });
                                              Navigator.pop(context);
                                            }),
                                      ],
                                    ),
                                  ));
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
