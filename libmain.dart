import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

void main() => runApp(NombuBeautyApp());

class NombuBeautyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOMBU Beauty',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Color(0xFFFDE6EB),
      ),
      home: HomeScreen(),
    );
  }
}

// Model for booking request
class BookingRequest {
  final String service;
  final DateTime date;
  final TimeOfDay time;
  final bool afterHours;
  final File? photo;
  String status; // Pending / Confirmed / Declined

  BookingRequest({
    required this.service,
    required this.date,
    required this.time,
    required this.afterHours,
    this.photo,
    this.status = 'Pending',
  });
}

// Global list to store requests
List<BookingRequest> bookingRequests = [];

class HomeScreen extends StatelessWidget {
  final List<String> categories = [
    'Hair Services',
    'Hair Laundry',
    'Makeup',
    'Admin Dashboard'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NOMBU Beauty')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(categories[index],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                if (categories[index] == 'Admin Dashboard') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminDashboard()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceScreen(category: categories[index]),
                    ),
                  );
                }
              },
            ),
          );
        },
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
  int? selectedPrice;
  bool afterHours = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  File? selectedImage;

  final ImagePicker _picker = ImagePicker();
  final String whatsappNumber = '0672412217';

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> pickDateTime() async {
    DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      final TimeOfDay? time =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) {
        setState(() {
          selectedDate = date;
          selectedTime = time;
        });
      }
    }
  }

  void sendWhatsAppRequest() async {
    if (selectedService == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    // Save locally
    bookingRequests.add(
      BookingRequest(
        service: selectedService!,
        date: selectedDate!,
        time: selectedTime!,
        afterHours: afterHours,
        photo: selectedImage,
      ),
    );

    int estimatedPrice = selectedPrice!;
    if (afterHours) estimatedPrice += 100;

    String dateStr =
        '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
    String timeStr =
        '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}';
    String message =
        'Hello NOMBU Beauty 🌸\n\nI\'d like to request a booking.\n\nService: $selectedService\nDate: $dateStr\nTime: $timeStr\n\nEstimated Price: R$estimatedPrice\nFinal price to be confirmed by stylist.\n\nI will send my reference hairstyle photo.\n\nThank you.';

    String url = 'https://wa.me/$whatsappNumber?text=${Uri.encodeFull(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categoryServices = services[widget.category]!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              hint: Text('Select a service'),
              value: selectedService,
              items: categoryServices
                  .map((s) => DropdownMenuItem(
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
            SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: afterHours,
                  onChanged: (val) {
                    setState(() {
                      afterHours = val!;
                    });
                  },
                ),
                Text('After-hours (+R100)'),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: pickDateTime,
              child: Text(selectedDate == null
                  ? 'Select Date & Time'
                  : 'Selected: ${selectedDate!.day}/${selectedDate!.month} ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: pickImage,
              child: Text(selectedImage == null
                  ? 'Upload Reference Photo (Optional)'
                  : 'Photo Selected'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendWhatsAppRequest,
              child: Text('Send Booking Request via WhatsApp'),
            ),
          ],
        ),
      ),
    );
  }
}

// Admin Dashboard
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wrong password')),
      );
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
          : ListView.builder(
              itemCount: bookingRequests.length,
              itemBuilder: (context, index) {
                BookingRequest req = bookingRequests[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('${req.service} (${req.status})'),
                    subtitle: Text(
                        '${req.date.day}/${req.date.month}/${req.date.year} ${req.time.hour}:${req.time.minute.toString().padLeft(2, '0')}\nAfter-hours: ${req.afterHours ? "Yes" : "No"}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              req.status = 'Confirmed';
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              req.status = 'Declined';
                            });
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      if (req.photo != null) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Reference Photo'),
                            content: Image.file(req.photo!),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Close'))
                            ],
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
