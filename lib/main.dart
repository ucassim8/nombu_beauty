import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math; 
import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(NombuBeautyApp());
}

class NombuBeautyApp extends StatefulWidget {
  @override
  State<NombuBeautyApp> createState() => _NombuBeautyAppState();
}

class _NombuBeautyAppState extends State<NombuBeautyApp> {
  final List<Map<String, dynamic>> basketItems = [];

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
      home: BookingPoliciesScreen(basketItems: basketItems),
    );
  }
}

// ------------------------- SPINNING LOGO COMPONENT -------------------------
class SpinningLogo extends StatefulWidget {
  final Widget child;
  const SpinningLogo({super.key, required this.child});

  @override
  State<SpinningLogo> createState() => _SpinningLogoState();
}

class _SpinningLogoState extends State<SpinningLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spinAnimation;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOverlayActive = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500), 
      vsync: this,
    );

    _spinAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 8.0 * math.pi).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 100.0, 
      ),
    ]).animate(_controller);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 4.5).chain(CurveTween(curve: Curves.easeOut)), 
        weight: 15.0, 
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(4.5), 
        weight: 85.0,
      ),
    ]).animate(_controller);
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    setState(() {
      _isOverlayActive = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _reverseAndRemoveOverlay,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final matrix = Matrix4.identity()
                  ..setEntry(3, 2, 0.002) 
                  ..rotateX(_spinAnimation.value); 

                return Transform.scale(
                  scale: _scaleAnimation.value,
                  alignment: Alignment.center,
                  child: Transform(
                    transform: matrix,
                    alignment: Alignment.center,
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: _reverseAndRemoveOverlay,
                        child: Container(
                          width: 90,  
                          height: 90, 
                          alignment: Alignment.center, 
                          key: ValueKey(_spinAnimation.value),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE8B4B8).withOpacity(1.0), 
                                blurRadius: 20, 
                                spreadRadius: 8, 
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 70,  
                            height: 70,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/Logonombu.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward(from: 0.0);
  }

  void _reverseAndRemoveOverlay() async {
    if (_overlayEntry == null) return;
    await _controller.reverse(); 
    _overlayEntry?.remove();
    _overlayEntry = null;
    _controller.reset();
    if (mounted) {
      setState(() {
        _isOverlayActive = false;
      });
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _showOverlay,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: _isOverlayActive ? 0.0 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}

// ------------------------- BOOKING POLICIES -------------------------
class BookingPoliciesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> basketItems;
  BookingPoliciesScreen({required this.basketItems});

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
* Clients arriving more than 15 minutes late may need to reschedule and the deposit will be forfeited.
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
                  context, MaterialPageRoute(builder: (_) => SplashScreen(basketItems: basketItems))),
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
  final List<Map<String, dynamic>> basketItems;
  SplashScreen({required this.basketItems});

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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(basketItems: widget.basketItems)));
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
class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> basketItems;
  HomeScreen({required this.basketItems});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Hair Services', 'icon': Icons.content_cut},
    {'name': 'Hair Laundry', 'icon': Icons.local_laundry_service},
    {'name': 'Makeup', 'icon': Icons.brush},
    {'name': 'Lashes', 'icon': Icons.visibility},
    {'name': 'Admin Dashboard', 'icon': Icons.admin_panel_settings},
  ];

  final String instagramUrl = "https://www.instagram.com/nombu.beauty?igsh=MzRlODBiNWFlZA==";
  final String tiktokUrl = "https://www.tiktok.com/@nombu.beauty?_r=1&_t=ZS-96uL017nPM7";

  void _launchSocial(String url) async {
    if (kIsWeb) {
      js.context.callMethod('open', [url, '_blank']);
    } else {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SpinningLogo(
              child: ClipOval(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    'assets/Logonombu.jpg', 
                    fit: BoxFit.cover, 
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Nombu Beauty',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(1, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ], 
        ), 
        backgroundColor: Colors.pink.shade400,
        elevation: 5,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BasketScreen(basketItems: widget.basketItems)),
                  ).then((_) => setState(() {}));
                },
              ),
              if (widget.basketItems.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${widget.basketItems.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
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
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ServiceScreen(category: category['name'], basketItems: widget.basketItems)),
                        ).then((_) => setState(() {}));
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Follow Our Pages:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colors.pink.shade700, 
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, size: 28),
                      color: Colors.pink.shade800,
                      tooltip: 'Instagram',
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(),
                      onPressed: () => _launchSocial(instagramUrl),
                    ),
                    const SizedBox(width: 16),
                    Transform.translate(
                      offset: const Offset(0, -1.5),
                      child: IconButton(
                        icon: const Icon(Icons.music_note, size: 30),
                        color: Colors.pink.shade800,
                        tooltip: 'TikTok',
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(),
                        onPressed: () => _launchSocial(tiktokUrl),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------- SERVICE SCREEN (LIVE FIRESTORE STREAM WITH FALLBACKS) -------------------------
class ServiceScreen extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> basketItems;
  ServiceScreen({required this.category, required this.basketItems});

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category), 
        backgroundColor: Colors.pink.shade400,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_basket, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BasketScreen(basketItems: widget.basketItems)),
              ).then((_) => setState(() {}));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading services.', style: TextStyle(color: Colors.pink.shade900)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.pink.shade400),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final rawCategory = data['category'] ?? data['Category'] ?? '';
            final docCategory = rawCategory.toString().trim().toLowerCase();
            final targetCategory = widget.category.trim().toLowerCase();
            return docCategory == targetCategory;
          }).toList();

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No services found in this category.',
                style: TextStyle(color: Colors.pink.shade900, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              final String serviceName = (data['name'] ?? data['Name'] ?? '').toString();
              final priceVal = data['price'] ?? data['Price'] ?? data['Price '] ?? 0;
              final int servicePrice = (priceVal as num?)?.toInt() ?? 0;

              final serviceMap = {
                'name': serviceName,
                'price': servicePrice,
              };

              final isInBasket = widget.basketItems.any((item) => item['name'] == serviceName);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('R$servicePrice', style: TextStyle(color: Colors.pink.shade700, fontWeight: FontWeight.bold)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInBasket ? Colors.grey : Colors.pink.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      setState(() {
                        if (isInBasket) {
                          widget.basketItems.removeWhere((item) => item['name'] == serviceName);
                        } else {
                          widget.basketItems.add(serviceMap);
                        }
                      });
                    },
                    child: Text(isInBasket ? 'Remove' : 'Add to Basket', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ------------------------- BASKET / CHECKOUT SCREEN -------------------------
class BasketScreen extends StatefulWidget {
  final List<Map<String, dynamic>> basketItems;
  BasketScreen({required this.basketItems});

  @override
  _BasketScreenState createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  final Map<String, List<String>> provinceLocations = {
    'Pretoria': ['Montana', 'Hammanskraal'],
    'Limpopo': ['Polokwane'],
  };

  String? selectedProvince, selectedLocation, clientName, clientPhone;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isAfterHours = false;

  int get baseTotalPrice => widget.basketItems.fold(0, (sum, item) => sum + (item['price'] as int));
  int get finalPrice => baseTotalPrice + (isAfterHours ? 100 : 0);

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
        isAfterHours = (picked.hour < 8 || picked.hour >= 18);
      });
    }
  }

  void triggerWhatsApp() {
    if (widget.basketItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your basket is empty!')));
      return;
    }
    if (clientName == null || clientPhone == null || selectedProvince == null || 
        selectedLocation == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all fields!')));
      return;
    }

    String formattedDate = "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
    String formattedTime = selectedTime!.format(context);

    String servicesText = widget.basketItems.map((item) => "- ${item['name']} (R${item['price']})").join("\n");
    String servicesSummary = widget.basketItems.map((item) => item['name']).join(", ");

    String message = 'Hello NOMBU Beauty 🌸\n\n'
        'I\'d like to request a booking for the following basket:\n\n'
        '$servicesText\n\n'
        'Name: $clientName\n'
        'Phone: $clientPhone\n'
        'Location: $selectedLocation\n'
        'Date: $formattedDate at $formattedTime\n'
        '${isAfterHours ? "After Hours: Yes (R100 fee applied)\n" : ""}'
        'Estimated Total Price: R$finalPrice\n\n'
        'Final price to be confirmed by stylist.\n\n'
        'I will send my reference photo below if needed. Thank you.';

    final String webUrl = "https://api.whatsapp.com/send?phone=27672412217&text=${Uri.encodeComponent(message)}";
    
    if (kIsWeb) js.context.callMethod('open', [webUrl, '_blank']);
    else launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);

    FirebaseFirestore.instance.collection('bookings').add({
      'clientName': clientName,
      'phoneNumber': clientPhone,
      'service': servicesSummary, 
      'location': '$selectedLocation, $selectedProvince',
      'date': formattedDate,
      'time': formattedTime,
      'afterHours': isAfterHours,
      'price': finalPrice,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    widget.basketItems.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Basket Summary'), backgroundColor: Colors.pink.shade400),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          if (widget.basketItems.isEmpty)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Your basket is empty. Go add some styling services! 🌸', style: TextStyle(color: Colors.pink.shade900)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.basketItems.length,
              itemBuilder: (context, idx) {
                final item = widget.basketItems[idx];
                return ListTile(
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('R${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  leading: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => setState(() => widget.basketItems.removeAt(idx)),
                  ),
                );
              },
            ),
          const Divider(thickness: 2),
          const SizedBox(height: 10),
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
          SwitchListTile(
            title: const Text("After Hours (R100 Fee)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
            subtitle: Text(isAfterHours ? "Applied based on time selection." : "Slots before 8AM or after 6PM"),
            value: isAfterHours,
            activeColor: Colors.pink,
            onChanged: null, 
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
            child: Text('Book Basket (R$finalPrice)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    );
  }
}

// ------------------------- ADMIN DASHBOARD -------------------------
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _auth = false;
  final TextEditingController _pass = TextEditingController();
  int? _selectedRevenueYear;

  final List<Map<String, String>> premiumQuotes = [
    {"q": "You are doing amazing things today, my love! Let's conquer this dashboard.", "a": "Hubby"},
    {"q": "Just a reminder that you're the hardest worker I know, and I'm so proud of you.", "a": "Hubby"},
    {"q": "Take a deep breath, you've got this beautiful! 🌸", "a": "Hubby"},
    {"q": "Sending you a million kisses before you start your admin tasks. 💋", "a": "Hubby"},
    {"q": "My favorite entrepreneur. Go shine today! 👑", "a": "Hubby"},
    {"q": "The best way to predict the future is to create it. Time to build the empire!", "a": "Motivation"},
    {"q": "You are entirely up to you. Believe in your talent and your grind.", "a": "Motivation"},
    {"q": "Behind every successful business is a woman who simply refused to give up.", "a": "Boss Babe Energy ✨"},
    {"q": "Quality is never an accident; it is always the result of intelligent effort.", "a": "Business Mindset"},
    {"q": "You are prettier than all the makeup and wigs in the world. Now let's handle business!", "a": "Hubby"},
    {"q": "Invest in your dreams. Grind now. Shine forever. 💎", "a": "Motivation"},
    {"q": "Success doesn't just find you. You have to go out and get it.", "a": "Motivation"},
    {"q": "Never doubt your capacity to build something magnificent here.", "a": "Reminder"},
    {"q": "Your passion, dedication, and beautiful heart make you unstoppable.", "a": "Hubby"},
    {"q": "Great things are done by a series of small things brought together.", "a": "Vincent van Gogh"},
    {"q": "Make today so awesome that yesterday gets jealous. 🌟", "a": "Motivation"},
    {"q": "I love watching you grow your business and chase your dreams.", "a": "Hubby"},
    {"q": "Focus on your goals, blur out the noise. You're built for this.", "a": "Reminder"},
    {"q": "Consistency is what transforms average into excellence.", "a": "Business Mindset"},
    {"q": "If anyone can turn a vision into reality, it's absolutely you.", "a": "Hubby"},
    {"q": "Dream big, work hard, stay focused, and surround yourself with good people.", "a": "Motivation"},
    {"q": "Your work is going to fill a large part of your life, love what you build.", "a": "Steve Jobs"},
    {"q": "I'm always in your corner, cheering you on through every step of this journey.", "a": "Hubby"},
    {"q": "Action is the foundational key to all success.", "a": "Pablo Picasso"},
    {"q": "Go dominate the day, gorgeous. I believe in you completely! ❤️", "a": "Hubby"}
  ];

  DateTime _parseBookingDate(String dateStr) {
    try {
      List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (e) {
      print("Error parsing date: $dateStr");
    }
    return DateTime(2099); 
  }

  bool _isDateInPast(String dateStr) {
    final bookingDate = _parseBookingDate(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return bookingDate.isBefore(today);
  }

  Future<void> _checkOverdueBookingsAndNudge() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('bookings').get();
      int overdueCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'Pending';
        final dateStr = data['date'] ?? '';

        if (status == 'Approved' && _isDateInPast(dateStr)) {
          overdueCount++;
        }
      }

      if (overdueCount > 0 && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.assignment_late, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 10),
                const Text("Pending Completion", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              "Hey Baby 🌸 You have $overdueCount approved booking${overdueCount > 1 ? 's' : ''} from past dates that haven't been marked completed yet.\n\n"
              "Please check the Active list and tap the double check mark (✔✔) for appointments that were finished so revenue updates!",
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400),
                onPressed: () => Navigator.pop(context),
                child: const Text("Got It! 💕", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Error checking overdue bookings: $e");
    }
  }

  void _fetchAndShowQuote() {
    final random = math.Random();
    final selected = premiumQuotes[random.nextInt(premiumQuotes.length)];
    String finalQuote = selected["q"]!;
    String author = selected["a"]!;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: true, 
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 16,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Colors.pink.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.pink.shade400, size: 45),
                  const SizedBox(height: 16),
                  Text(
                    "Hey Beautiful! ✨",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '"$finalQuote"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "- $author",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink.shade300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _checkOverdueBookingsAndNudge();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Let's Get To Work! 💕"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _showEditDialog(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    TextEditingController serviceCtrl = TextEditingController(text: data['service']);
    TextEditingController priceCtrl = TextEditingController(text: data['price'].toString());
    TextEditingController locCtrl = TextEditingController(text: data['location']);
    TextEditingController dateCtrl = TextEditingController(text: data['date']);
    TextEditingController timeCtrl = TextEditingController(text: data['time']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit & Approve"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: serviceCtrl, decoration: const InputDecoration(labelText: "Service")),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price (R)"), keyboardType: TextInputType.number),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: "Location")),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: "Date")),
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Time")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              doc.reference.update({
                'service': serviceCtrl.text, 
                'price': int.parse(priceCtrl.text), 
                'location': locCtrl.text,
                'date': dateCtrl.text,
                'time': timeCtrl.text,
                'status': 'Approved'
              });
              
              String msg = "Hello ${data['clientName']} 🌸,\n\n"
                  "Your booking for ${serviceCtrl.text} at NOMBU Beauty has been Approved!\n\n"
                  "Booking Details:\n"
                  "📍 Location: ${locCtrl.text}\n"
                  "📅 Date: ${dateCtrl.text} at ${timeCtrl.text}\n"
                  "💰 Total Price: R${priceCtrl.text}\n\n"
                  "To secure your slot, please pay a non-refundable deposit of R100.\n\n"
                  "Banking Details:\n"
                  "Bank: Capitec\nName: Mrs K Siwela\nAccount: 1867785194\nType: Savings\n\n"
                  "Please send proof of payment. We can't wait to see you! 💗";

              String rawPhone = data['phoneNumber'] ?? "";
              String cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), ''); 

              if (cleanPhone.startsWith('270')) {
                cleanPhone = '27' + cleanPhone.substring(3);
              } else if (cleanPhone.startsWith('0')) {
                cleanPhone = '27' + cleanPhone.substring(1);
              } else if (!cleanPhone.startsWith('27')) {
                cleanPhone = '27' + cleanPhone;
              }

              final String url = "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(msg)}";
              
              if (kIsWeb) js.context.callMethod('open', [url, '_blank']);
              else launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              
              Navigator.pop(context);
            },
            child: const Text("Approve & WhatsApp"),
          ),
        ],
      ),
    );
  }

  void _showAddOrEditServiceDialog(DocumentSnapshot? doc) {
    final bool isEditing = doc != null;
    final Map<String, dynamic> data = isEditing ? (doc.data() as Map<String, dynamic>? ?? {}) : {};

    final initialName = (data['name'] ?? data['Name'] ?? '').toString();
    final initialPrice = (data['price'] ?? data['Price'] ?? data['Price '] ?? '').toString();
    final initialCategory = (data['category'] ?? data['Category'] ?? 'Hair Services').toString();

    TextEditingController nameCtrl = TextEditingController(text: initialName);
    TextEditingController priceCtrl = TextEditingController(text: initialPrice);

    List<String> categories = ['Hair Services', 'Hair Laundry', 'Makeup', 'Lashes'];
    String selectedCategory = categories.contains(initialCategory) ? initialCategory : categories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? "Edit Service" : "Add New Service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Service Name"),
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: "Price (R)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: "Category"),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedCategory = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400),
              onPressed: () async {
                int parsedPrice = int.tryParse(priceCtrl.text) ?? 0;

                final updatedData = {
                  'name': nameCtrl.text.trim(),
                  'price': parsedPrice,
                  'category': selectedCategory,
                };

                if (isEditing && doc != null) {
                  await doc.reference.set(updatedData, SetOptions(merge: true));
                } else {
                  await FirebaseFirestore.instance.collection('services').add(updatedData);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? "Update" : "Save", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------- CATEGORIZED SERVICES MANAGER -------------------------
  Widget _buildServicesManager() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('services').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        final categoriesList = ['Hair Services', 'Hair Laundry', 'Makeup', 'Lashes'];

        Map<String, List<DocumentSnapshot>> groupedServices = {
          for (var cat in categoriesList) cat: []
        };

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final rawCat = (data['category'] ?? data['Category'] ?? 'Hair Services').toString();

          String matchedCategory = categoriesList.firstWhere(
            (c) => c.toLowerCase() == rawCat.trim().toLowerCase(),
            orElse: () => 'Hair Services',
          );

          groupedServices[matchedCategory]!.add(doc);
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.pink.shade400,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add New Service", style: TextStyle(color: Colors.white)),
            onPressed: () => _showAddOrEditServiceDialog(null),
          ),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: categoriesList.map((categoryName) {
              final categoryDocs = groupedServices[categoryName] ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
                child: ExpansionTile(
                  initiallyExpanded: false,
                  title: Text(
                    "$categoryName (${categoryDocs.length})",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.pink.shade800,
                    ),
                  ),
                  children: categoryDocs.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "No services under $categoryName yet.",
                              style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                            ),
                          )
                        ]
                      : categoryDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final serviceName = (data['name'] ?? data['Name'] ?? 'Unnamed').toString();
                          final priceVal = data['price'] ?? data['Price'] ?? data['Price '] ?? 0;

                          return ListTile(
                            title: Text(serviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              "R$priceVal",
                              style: TextStyle(color: Colors.pink.shade700, fontWeight: FontWeight.bold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showAddOrEditServiceDialog(doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => doc.reference.delete(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400), 
              onPressed: () { 
                if (_pass.text == '2478') {
                  setState(() {
                    _auth = true;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fetchAndShowQuote();
                  });
                } 
              },
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ]),
        )),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings & Menu Manager'),
          backgroundColor: Colors.pink.shade400,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                setState(() {
                  _auth = false;
                  _pass.clear();
                });
              },
            )
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: "Active"),
              Tab(icon: Icon(Icons.history), text: "History"),
              Tab(icon: Icon(Icons.edit_note), text: "Services"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return _buildBookingList(snapshot.data!.docs, false);
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return _buildBookingList(snapshot.data!.docs, true);
              },
            ),
            _buildServicesManager(),
          ],
        ),
      ),
    );
  }         

  Widget _buildBookingList(List<DocumentSnapshot> docs, bool isHistory) {
    if (!isHistory) {
      List<DocumentSnapshot> activeList = docs.where((doc) {
        String status = (doc.data() as Map<String, dynamic>)['status'] ?? 'Pending';
        return status == 'Pending' || status == 'Approved';
      }).toList();

      activeList.sort((a, b) {
        Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
        Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;

        String statusA = dataA['status'] ?? 'Pending';
        String statusB = dataB['status'] ?? 'Pending';

        if (statusA == 'Pending' && statusB != 'Pending') return -1;
        if (statusB == 'Pending' && statusA != 'Pending') return 1;

        if (statusA == 'Pending' && statusB == 'Pending') {
          Timestamp tA = dataA['timestamp'] ?? Timestamp.now();
          Timestamp tB = dataB['timestamp'] ?? Timestamp.now();
          return tB.compareTo(tA);
        }

        DateTime dateA = _parseBookingDate(dataA['date'] ?? "");
        DateTime dateB = _parseBookingDate(dataB['date'] ?? "");
        return dateA.compareTo(dateB);
      });

      if (activeList.isEmpty) {
        return Center(
          child: Text('No active client bookings!', style: TextStyle(color: Colors.pink.shade900, fontSize: 16)),
        );
      }

      return ListView.builder(
        itemCount: activeList.length,
        itemBuilder: (context, index) => _buildBookingCard(activeList[index], false),
      );
    }

    List<DocumentSnapshot> completedList = docs.where((doc) => ((doc.data() as Map<String, dynamic>)['status'] == 'Completed')).toList();
    List<DocumentSnapshot> cancelledList = docs.where((doc) => ((doc.data() as Map<String, dynamic>)['status'] == 'Cancelled')).toList();

    // Group earnings by year and month
    Map<int, Map<String, int>> earningsByYear = {};
    List<String> monthNames = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    for (var doc in completedList) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      var priceVal = data['price'];
      int price = 0;
      if (priceVal is int) price = priceVal;
      else if (priceVal is String) price = int.tryParse(priceVal) ?? 0;

      String dateStr = data['date'] ?? "";
      List<String> parts = dateStr.split('/');
      
      if (parts.length == 3) {
        int monthIdx = int.tryParse(parts[1]) ?? 0;
        int year = int.tryParse(parts[2]) ?? DateTime.now().year;

        if (monthIdx >= 1 && monthIdx <= 12) {
          earningsByYear.putIfAbsent(year, () => {});
          String monthName = monthNames[monthIdx];
          earningsByYear[year]![monthName] = (earningsByYear[year]![monthName] ?? 0) + price;
        }
      }
    }

    List<int> availableYears = earningsByYear.keys.toList()..sort((a, b) => b.compareTo(a));
    if (availableYears.isEmpty) availableYears.add(DateTime.now().year);

    int activeYear = availableYears.contains(_selectedRevenueYear) ? _selectedRevenueYear! : availableYears.first;
    Map<String, int> selectedYearEarnings = earningsByYear[activeYear] ?? {};

    var historySort = (DocumentSnapshot a, DocumentSnapshot b) {
      Timestamp tA = (a.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
      Timestamp tB = (b.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
      return tB.compareTo(tA);
    };
    completedList.sort(historySort);
    cancelledList.sort(historySort);

    if (completedList.isEmpty && cancelledList.isEmpty) {
      return Center(
        child: Text('No history matches found.', style: TextStyle(color: Colors.pink.shade900, fontSize: 16)),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // ------------------------- COMBINED REVENUE BREAKDOWN -------------------------
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), 
            side: BorderSide(color: Colors.green.shade200)
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.green.shade100,
                          child: const Icon(Icons.analytics, color: Colors.green, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Monthly Revenue",
                          style: TextStyle(fontSize: 15, color: Colors.green.shade900, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    
                    // Year Selector Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: DropdownButton<int>(
                        value: activeYear,
                        underline: const SizedBox(),
                        isDense: true,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade800),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 13),
                        onChanged: (int? newYear) {
                          if (newYear != null) {
                            setState(() {
                              _selectedRevenueYear = newYear;
                            });
                          }
                        },
                        items: availableYears.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text("$year"),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Horizontal Carousel Cards
                selectedYearEarnings.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("No revenue recorded for $activeYear.", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                      )
                    : SizedBox(
                        height: 75,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedYearEarnings.entries.length,
                          itemBuilder: (context, idx) {
                            final entry = selectedYearEarnings.entries.elementAt(idx);
                            return Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200),
                                boxShadow: [
                                  BoxShadow(color: Colors.green.shade100.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    entry.key, 
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "R${entry.value}", 
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800)
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Text("Completed Appointments (${completedList.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
        if (completedList.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("No completed appointments yet.", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
          )
        else
          ...completedList.map((doc) => _buildBookingCard(doc, true)),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(thickness: 1.5),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.orange),
              const SizedBox(width: 8),
              Text("Cancelled Appointments (${cancelledList.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
        ),
        if (cancelledList.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("No cancelled appointments yet.", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
          )
        else
          ...cancelledList.map((doc) => _buildBookingCard(doc, true)),
      ],
    );
  }

  Widget _buildBookingCard(DocumentSnapshot doc, bool isHistory) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String status = data['status'] ?? 'Pending';
    String dateStr = data['date'] ?? '';

    bool isOverdue = !isHistory && status == 'Approved' && _isDateInPast(dateStr);

    Color badgeColor;
    Color textColor;
    if (status == 'Pending') {
      badgeColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    } else if (status == 'Approved') {
      badgeColor = isOverdue ? Colors.amber.shade100 : Colors.blue.shade100;
      textColor = isOverdue ? Colors.amber.shade900 : Colors.blue.shade800;
    } else if (status == 'Completed') {
      badgeColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    } else {
      badgeColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isOverdue ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isOverdue
            ? BorderSide(color: Colors.amber.shade700, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  data['clientName'] ?? 'No Name', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    isOverdue ? "Needs Completion Check ⚠️" : status, 
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${data['service'] ?? 'No Service'}\n"
                    "📍 ${data['location'] ?? 'No Location'}\n"
                    "📅 ${data['date'] ?? ''} at ${data['time'] ?? ''}\n"
                    "💰 Price: R${data['price'] ?? 0}",
                    style: TextStyle(height: 1.4, color: Colors.grey.shade800, fontSize: 14),
                  ),
                ),
                
                if (!isHistory)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(),
                        onPressed: () => _showEditDialog(doc),
                      ),
                      
                      if (status == 'Pending')
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(),
                          onPressed: () => _showEditDialog(doc),
                        )
                      else if (status == 'Approved')
                        IconButton(
                          icon: Icon(
                            Icons.done_all, 
                            color: isOverdue ? Colors.amber.shade800 : Colors.purple,
                            size: isOverdue ? 28 : 24,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(),
                          onPressed: () => doc.reference.update({'status': 'Completed'}),
                        ),

                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.orange),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(),
                        onPressed: () => doc.reference.update({'status': 'Cancelled'}),
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(),
                        onPressed: () => doc.reference.delete(),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
