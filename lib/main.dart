Import 'dart:async';
Import 'package:flutter/material.dart';
Import 'package:url_launcher/url_launcher.dart';
Import 'package:cloud_firestore/cloud_firestore.dart';
Import 'package:firebase_core/firebase_core.dart';
Import 'package:flutter/foundation.dart';
Import 'firebase_options.dart';
Import 'package:google_fonts/google_fonts.dart';
Import 'dart:math' as math; 
Import 'dart:json';
Import 'package:http/http.dart' as http;

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  RunApp(NombuBeautyApp());
}

class NombuBeautyApp extends StatefulWidget {
  @override
  State<NombuBeautyApp> createState() => _NombuBeautyAppState();
}

class _NombuBeautyAppState extends State<NombuBeautyApp> {
  final List<Map<String, dynamic>> basketItems = [];

  @override
  Widget build(BuildContext context) {
    Return MaterialApp(
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
  Const SpinningLogo({super.key, required this.child});

  @override
  State<SpinningLogo> createState() => _SpinningLogoState();
}

class _SpinningLogoState extends State<SpinningLogo> with SingleTickerProviderStateMixin {
  Late AnimationController _controller;
  Late Animation<double> _spinAnimation;
  Late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  Bool _isOverlayActive = false;

  @override
  void initState() {
    Super.initState();
    
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

  Void _showOverlay() {
    If (_overlayEntry != null) return;

    SetState(() {
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
                Final matrix = Matrix4.identity()
                  ..setEntry(3, 2, 0.002) 
                  ..rotateX(_spinAnimation.value); 

                Return Transform.scale(
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

  Void _reverseAndRemoveOverlay() async {
    If (_overlayEntry == null) return;
    Await _controller.reverse(); 
    _overlayEntry?.remove();
    _overlayEntry = null;
    _controller.reset();
    If (mounted) {
      SetState(() {
        _isOverlayActive = false;
      });
    }
  }

  @override
  Void dispose() {
    _overlayEntry?.remove();
    _controller.dispose();
    Super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Return CompositedTransformTarget(
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
    Return Scaffold(
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
  Late AnimationController _controller;
  Late Animation<double> _animation;

  @override
  void initState() {
    Super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(basketItems: widget.basketItems)));
    });
  }

  @override
  Void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    Return Scaffold(
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

  Void _launchSocial(String url) async {
    If (kIsWeb) {
      Js.context.callMethod('open', [url, '_blank']);
    } else {
      Final Uri uri = Uri.parse(url);
      If (await canLaunchUrl(uri)) {
        Await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Return Scaffold(
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
              If (widget.basketItems.isNotEmpty)
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
                  CrossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  Final category = categories[index];
                  Return GestureDetector(
                    onTap: () {
                      If (category['name'] == 'Admin Dashboard') {
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
    Return Scaffold(
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
          If (snapshot.hasError) {
            Return Center(
              child: Text('Error loading services.', style: TextStyle(color: Colors.pink.shade900)),
            );
          }

          If (snapshot.connectionState == ConnectionState.waiting) {
            Return Center(
              child: CircularProgressIndicator(color: Colors.pink.shade400),
            );
          }

          Final allDocs = snapshot.data?.docs ?? [];

          Final docs = allDocs.where((doc) {
            Final data = doc.data() as Map<String, dynamic>;
            Final rawCategory = data['category'] ?? data['Category'] ?? '';
            Final docCategory = rawCategory.toString().trim().toLowerCase();
            Final targetCategory = widget.category.trim().toLowerCase();
            Return docCategory == targetCategory;
          }).toList();

          If (docs.isEmpty) {
            Return Center(
              child: Text(
                'No services found in this category.',
                style: TextStyle(color: Colors.pink.shade900, fontSize: 16),
              ),
            );
          }

          Return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              Final data = docs[index].data() as Map<String, dynamic>;
              
              Final String serviceName = (data['name'] ?? data['Name'] ?? '').toString();
              Final priceVal = data['price'] ?? data['Price'] ?? data['Price '] ?? 0;
              Final int servicePrice = (priceVal as num?)?.toInt() ?? 0;

              Final serviceMap = {
                'name': serviceName,
                'price': servicePrice,
              };

              Final isInBasket = widget.basketItems.any((item) => item['name'] == serviceName);

              Return Card(
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
                      SetState(() {
                        If (isInBasket) {
                          Widget.basketItems.removeWhere((item) => item['name'] == serviceName);
                        } else {
                          Widget.basketItems.add(serviceMap);
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
  Bool isAfterHours = false;

  Int get baseTotalPrice => widget.basketItems.fold(0, (sum, item) => sum + (item['price'] as int));
  Int get finalPrice => baseTotalPrice + (isAfterHours ? 100 : 0);

  Future<void> _selectDate(BuildContext context) async {
    Final DateTime? picked = await showDatePicker(
      Context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2027),
    );
    If (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    Final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    If (picked != null) {
      SetState(() {
        SelectedTime = picked;
        IsAfterHours = (picked.hour < 8 || picked.hour >= 18);
      });
    }
  }

  // Check if slot is already approved in Firestore
  Future<bool> _isSlotAlreadyBooked(String date, String time) async {
    Final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: 'Approved')
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .get();

    Return snapshot.docs.isNotEmpty;
  }

  Void triggerWhatsApp() async {
    If (widget.basketItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your basket is empty!')));
      Return;
    }
    If (clientName == null || clientPhone == null || selectedProvince == null || 
        SelectedLocation == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all fields!')));
      Return;
    }

    String formattedDate = "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
    String formattedTime = selectedTime!.format(context);

    Bool isBooked = await _isSlotAlreadyBooked(formattedDate, formattedTime);
    If (isBooked) {
      If (mounted) {
        ShowDialog(
          Context: context,
          Builder: (context) => AlertDialog(
            Shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            Title: const Text("Slot Unavailable 🌸", style: TextStyle(fontWeight: FontWeight.bold)),
            Content: Text("Sorry! $formattedDate at $formattedTime is already booked.\n\nPlease select another date or time slot."),
            Actions: [
              ElevatedButton(
                Style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400),
                OnPressed: () => Navigator.pop(context),
                Child: const Text("Got It", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
      Return;
    }

    String servicesSummary = widget.basketItems.map((item) => item['name']).join(", ");

    // 1. Save locally to Firestore bookings collection
    Await FirebaseFirestore.instance.collection('bookings').add({
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

    // 2. Ping your Render Cloud Backend to trigger WhatsApp alert & pause AI
    Try {
      Await http.post(
        Uri.parse('https://nombu-backend.onrender.com/new-booking'),
        Headers: {"Content-Type": "application/json"},
        Body: jsonEncode({
          'clientName': clientName,
          'phoneNumber': clientPhone,
          'service': servicesSummary,
          'location': '$selectedLocation, $selectedProvince',
          'date': formattedDate,
          'time': formattedTime,
          'price': finalPrice,
        }),
      );
    } catch (e) {
      Print("Cloud alert error: $e");
    }

    Widget.basketItems.clear();

    If (mounted) {
      ShowDialog(
        Context: context,
        Builder: (context) => AlertDialog(
          Shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          Title: const Text("Booking Requested! 🌸", style: TextStyle(fontWeight: FontWeight.bold)),
          Content: const Text("Your booking has been successfully submitted to management. A stylist will review and message you shortly!"),
          Actions: [
            ElevatedButton(
              Style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400),
              OnPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Return to home
              },
              Child: const Text("Okay", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Return Scaffold(
      appBar: AppBar(title: const Text('My Basket Summary'), backgroundColor: Colors.pink.shade400),
      body: SingleChildScrollView(
        Padding: const EdgeInsets.all(20),
        child: Column(children: [
          If (widget.basketItems.isEmpty)
            Card(
              Elevation: 2,
              Child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Your basket is empty. Go add some styling services! 🌸', style: TextStyle(color: Colors.pink.shade900)),
              ),
            )
          else
            ListView.builder(
              ShrinkWrap: true,
              Physics: const NeverScrollableScrollPhysics(),
              ItemCount: widget.basketItems.length,
              ItemBuilder: (context, idx) {
                Final item = widget.basketItems[idx];
                Return ListTile(
                  Title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Trailing: Text('R${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Leading: IconButton(
                    Icon: const Icon(Icons.remove_circle, color: Colors.red),
                    OnPressed: () => setState(() => widget.basketItems.removeAt(idx)),
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
            Decoration: InputDecoration(labelText: 'Select Province', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            Items: provinceLocations.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            OnChanged: (val) => setState(() { selectedProvince = val; selectedLocation = null; }),
          ),
          const SizedBox(height: 15),
          If (selectedProvince != null)
            DropdownButtonFormField<String>(
              Decoration: InputDecoration(labelText: 'Select Location', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              Value: selectedLocation,
              Items: provinceLocations[selectedProvince]!.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              OnChanged: (val) => setState(() => selectedLocation = val),
            ),
          const SizedBox(height: 15),
          SwitchListTile(
            Title: const Text("After Hours (R100 Fee)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
            Subtitle: Text(isAfterHours ? "Applied based on time selection." : "Slots before 8AM or after 6PM"),
            Value: isAfterHours,
            ActiveColor: Colors.pink,
            OnChanged: null, 
          ),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.calendar_today, color: Colors.pink), label: Text(selectedDate == null ? "Date" : "${selectedDate!.day}/${selectedDate!.month}"), onPressed: () => _selectDate(context))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.access_time, color: Colors.pink), label: Text(selectedTime == null ? "Time" : selectedTime!.format(context)), onPressed: () => _selectTime(context))),
          ]),
          const SizedBox(height: 35),
          ElevatedButton(
            Style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            OnPressed: triggerWhatsApp,
            Child: Text('Book Basket (R$finalPrice)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    );
  }
}

// ------------------------- ADMIN DASHBOARD -------------------------
class AdminDashboard extends StatefulWidget {
  Const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Bool _auth = false;
  Final TextEditingController _pass = TextEditingController();
  Int? _selectedRevenueYear;

  Final List<Map<String, String>> premiumQuotes = [
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
    Try {
      List<String> parts = dateStr.split('/');
      If (parts.length == 3) {
        Return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (e) {
      Print("Error parsing date: $dateStr");
    }
    Return DateTime(2099); 
  }

  Bool _isDateInPast(String dateStr) {
    Final bookingDate = _parseBookingDate(dateStr);
    Final now = DateTime.now();
    Final today = DateTime(now.year, now.month, now.day);
    Return bookingDate.isBefore(today);
  }

  Future<void> _checkOverdueBookingsAndNudge() async {
    Try {
      Final snapshot = await FirebaseFirestore.instance.collection('bookings').get();
      Int overdueCount = 0;

      For (var doc in snapshot.docs) {
        Final data = doc.data();
        Final status = data['status'] ?? 'Pending';
        Final dateStr = data['date'] ?? '';

        If (status == 'Approved' && _isDateInPast(dateStr)) {
          OverdueCount++;
        }
      }

      If (overdueCount > 0 && mounted) {
        ShowDialog(
          Context: context,
          Builder: (context) => AlertDialog(
            Shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            Title: Row(
              Children: [
                Icon(Icons.assignment_late, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 10),
                const Text("Pending Completion", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Content: Text(
              "Hey Baby 🌸 You have $overdueCount approved booking${overdueCount > 1 ? 's' : ''} from past dates that haven't been marked completed yet.\n\n"
              "Please check the Active list and tap the double check mark (✔✔) for appointments that were finished so revenue updates!",
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            Actions: [
              ElevatedButton(
                Style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400),
                OnPressed: () => Navigator.pop(context),
                Child: const Text("Got It! 💕", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Print("Error checking overdue bookings: $e");
    }
  }

  Void _fetchAndShowQuote() {
    Final random = math.Random();
    Final selected = premiumQuotes[random.nextInt(premiumQuotes.length)];
    String finalQuote = selected["q"]!;
    String author = selected["a"]!;

    If (mounted) {
      ShowDialog(
        Context: context,
        BarrierDismissible: true, 
        Builder: (BuildContext context) {
          Return Dialog(
            Shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            Elevation: 16,
            Child: Container(
              Padding: const EdgeInsets.all(24),
              Decoration: BoxDecoration(
                Radius: BorderRadius.circular(24),
                Gradient: LinearGradient(
                  Colors: [Colors.pink.shade50, Colors.white],
                  Begin: Alignment.topLeft,
                  End: Alignment.bottomRight,
                ),
              ),
              Child: Column(
                MainAxisSize: MainAxisSize.min,
                Children: [
                  Icon(Icons.favorite, color: Colors.pink.shade400, size: 45),
                  const SizedBox(height: 16),
                  Text(
                    "Hey Beautiful! ✨",
                    Style: GoogleFonts.playfairDisplay(
                      FontSize: 22,
                      FontWeight: FontWeight.bold,
                      Color: Colors.pink.shade800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '"$finalQuote"',
                    TextAlign: TextAlign.center,
                    Style: GoogleFonts.lato(
                      FontSize: 16,
                      FontStyle: FontStyle.italic,
                      Color: Colors.grey.shade800,
                      Height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "- $author",
                    Style: TextStyle(
                      FontSize: 13,
                      FontWeight: FontWeight.w600,
                      Color: Colors.pink.shade300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    OnPressed: () {
                      Navigator.of(context).pop();
                      _checkOverdueBookingsAndNudge();
                    },
                    Style: ElevatedButton.styleFrom(
                      BackgroundColor: Colors.pink.shade400,
                      ForegroundColor: Colors.white,
                      Shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      Padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    Child: const Text("Let's Get To Work! 💕"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Void _showEditDialog(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    TextEditingController serviceCtrl = TextEditingController(text: data['service']);
    TextEditingController priceCtrl = TextEditingController(text: data['price'].toString());
    TextEditingController locCtrl = TextEditingController(text: data['location']);
    TextEditingController dateCtrl = TextEditingController(text: data['date']);
    TextEditingController timeCtrl = TextEditingController(text: data['time']);

    ShowDialog(
      Context: context,
      Builder: (context) => AlertDialog(
        Title: const Text("Edit & Approve"),
        Content: SingleChildScrollView(
          Child: Column(
            MainAxisSize: MainAxisSize.min,
            Children: [
              TextField(controller: serviceCtrl, decoration: const InputDecoration(labelText: "Service")),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price (R)"), keyboardType: TextInputType.number),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: "Location")),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: "Date")),
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Time")),
            ],
          ),
        ),
        Actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            OnPressed: () async {
              Doc.reference.update({
                'service': serviceCtrl.text, 
                'price': int.parse(priceCtrl.text), 
                'location': locCtrl.text,
                'date': dateCtrl.text,
                'time': timeCtrl.text,
                'status': 'Approved'
              });

              String rawPhone = data['phoneNumber'] ?? "";
              String cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), ''); 

              If (cleanPhone.startsWith('270')) {
                CleanPhone = '27' + cleanPhone.substring(3);
              } else if (cleanPhone.startsWith('0')) {
                CleanPhone = '27' + cleanPhone.substring(1);
              } else if (!cleanPhone.startsWith('27')) {
                CleanPhone = '27' + cleanPhone;
              }

              // Ping Render Backend to send the approval WhatsApp template
              Try {
                Await http.post(
                  Uri.parse('https://nombu-backend.onrender.com/approve-booking'),
                  Headers: {"Content-Type": "application/json"},
                  Body: jsonEncode({
                    'clientPhone': cleanPhone,
                    'clientName': data['clientName'],
                    'serviceName': serviceCtrl.text,
                    'appointmentDate': dateCtrl.text,
                    'appointmentTime': timeCtrl.text,
                  }),
                );
              } catch (e) {
                Print("Approval request error: $e");
              }
              
              If (context.mounted) Navigator.pop(context);
            },
            Child: const Text("Approve & Send WhatsApp"),
          ),
        ],
      ),
    );
  }

  Void _showAddOrEditServiceDialog(DocumentSnapshot? doc) {
    Final bool isEditing = doc != null;
    Final Map<String, dynamic> data = isEditing ? (doc.data() as Map<String, dynamic>? ?? {}) : {};

    Final initialName = (data['name'] ?? data['Name'] ?? '').toString();
    Final initialPrice = (data['price'] ?? data['Price'] ?? data['Price '] ?? '').toString();
    Final initialCategory = (data['category'] ?? data['Category'] ?? 'Hair Services').toString();

    TextEditingController nameCtrl = TextEditingController(text: initialName);
    TextEditingController priceCtrl = TextEditingController(text: initialPrice);

    List<String> categories = ['Hair Services', 'Hair Laundry', 'Makeup', 'Lashes'];
    String selectedCategory = categories.contains(initialCategory) ? initialCategory : categories.first;

    ShowDialog(
      Context: context,
      Builder: (context) => StatefulBuilder(
        Builder: (context, setDialogState) => AlertDialog(
          Title: Text(isEditing ? "Edit Service" : "Add New Service"),
          Content: Column(
            MainAxisSize: MainAxisSize.min,
            Children: [
              TextField(
                Controller: nameCtrl,
                Decoration: const InputDecoration(labelText: "Service Name"),
              ),
              TextField(
                Controller: priceCtrl,
                Decoration: const InputDecoration(labelText: "Price (R)"),
                KeyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                Value: selectedCategory,
                Decoration: const InputDecoration(labelText: "Category"),
                Items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                OnChanged: (val) {
                  If (val != null) setDialogState(() => selectedCategory = val);
                },
              ),
            ],
          ),
          Actions: [
            TextButton(
              OnPressed: () => Navigator.pop(context),
              Child: const Text("Cancel"),
            ),
            ElevatedButton(
              Style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400),
              OnPressed: () async {
                Int parsedPrice = int.tryParse(priceCtrl.text) ?? 0;

                Final updatedData = {
                  'name': nameCtrl.text.trim(),
                  'price': parsedPrice,
                  'category': selectedCategory,
                };

                If (isEditing && doc != null) {
                  Await doc.reference.set(updatedData, SetOptions(merge: true));
                } else {
                  Await FirebaseFirestore.instance.collection('services').add(updatedData);
                }

                If (context.mounted) Navigator.pop(context);
              },
              Child: Text(isEditing ? "Update" : "Save", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------- CATEGORIZED SERVICES MANAGER -------------------------
  Widget _buildServicesManager() {
    Return StreamBuilder<QuerySnapshot>(
      Stream: FirebaseFirestore.instance.collection('services').snapshots(),
      Builder: (context, snapshot) {
        If (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        Final docs = snapshot.data!.docs;

        Final categoriesList = ['Hair Services', 'Hair Laundry', 'Makeup', 'Lashes'];

        Map<String, List<DocumentSnapshot>> groupedServices = {
          For (var cat in categoriesList) cat: []
        };

        For (var doc in docs) {
          Final data = doc.data() as Map<String, dynamic>;
          Final rawCat = (data['category'] ?? data['Category'] ?? 'Hair Services').toString();

          String matchedCategory = categoriesList.firstWhere(
            (c) => c.toLowerCase() == rawCat.trim().toLowerCase(),
            OrElse: () => 'Hair Services',
          );

          GroupedServices[matchedCategory]!.add(doc);
        }

        Return Scaffold(
          FloatingActionButton: FloatingActionButton.extended(
            BackgroundColor: Colors.pink.shade400,
            Icon: const Icon(Icons.add, color: Colors.white),
            Label: const Text("Add New Service", style: TextStyle(color: Colors.white)),
            OnPressed: () => _showAddOrEditServiceDialog(null),
          ),
          Body: ListView(
            Padding: const EdgeInsets.all(12),
            Children: categoriesList.map((categoryName) {
              Final categoryDocs = groupedServices[categoryName] ?? [];

              Return Card(
                Margin: const EdgeInsets.only(bottom: 12),
                Shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                Elevation: 2,
                Child: ExpansionTile(
                  InitiallyExpanded: false, 
                  Title: Text(
                    "$categoryName (${categoryDocs.length})",
                    Style: TextStyle(
                      FontWeight: FontWeight.bold,
                      FontSize: 16,
                      Color: Colors.pink.shade800,
                    ),
                  ),
                  Children: categoryDocs.isEmpty
                      ? [
                          Padding(
                            Padding: const EdgeInsets.all(16.0),
                            Child: Text(
                              "No services under $categoryName yet.",
                              Style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                            ),
                          )
                        ]
                      : categoryDocs.map((doc) {
                          Final data = doc.data() as Map<String, dynamic>;
                          Final serviceName = (data['name'] ?? data['Name'] ?? 'Unnamed').toString();
                          Final priceVal = data['price'] ?? data['Price'] ?? data['Price '] ?? 0;

                          Return ListTile(
                            Title: Text(serviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Subtitle: Text(
                              "R$priceVal",
                              Style: TextStyle(color: Colors.pink.shade700, fontWeight: FontWeight.bold),
                            ),
                            Trailing: Row(
                              MainAxisSize: MainAxisSize.min,
                              Children: [
                                IconButton(
                                  Icon: const Icon(Icons.edit, color: Colors.blue),
                                  OnPressed: () => _showAddOrEditServiceDialog(doc),
                                ),
                                IconButton(
                                  Icon: const Icon(Icons.delete, color: Colors.red),
                                  OnPressed: () => doc.reference.delete(),
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
    If (!_auth) {
      Return Scaffold(
        AppBar: AppBar(title: const Text('Admin Login'), backgroundColor: Colors.pink.shade400),
        Body: Center(child: Padding(
          Padding: const EdgeInsets.all(30.0),
          Child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_outline, size: 60, color: Colors.pink),
            const SizedBox(height: 20),
            TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              Style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade400), 
              OnPressed: () { 
                If (_pass.text == '2478') {
                  SetState(() {
                    _auth = true;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fetchAndShowQuote();
                  });
                } 
              },
              Child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ]),
        )),
      );
    }

    Return DefaultTabController(
      Length: 3,
      Child: Scaffold(
        AppBar: AppBar(
          Title: const Text('Bookings & Menu Manager'),
          BackgroundColor: Colors.pink.shade400,
          Actions: [
            IconButton(
              Icon: const Icon(Icons.logout),
              OnPressed: () {
                SetState(() {
                  _auth = false;
                  _pass.clear();
                });
              },
            )
          ],
          Bottom: const TabBar(
            LabelColor: Colors.white,
            UnselectedLabelColor: Colors.white70,
            IndicatorColor: Colors.white,
            Tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: "Active"),
              Tab(icon: Icon(Icons.history), text: "History"),
              Tab(icon: Icon(Icons.edit_note), text: "Services"),
            ],
          ),
        ),
        Body: TabBarView(
          Children: [
            StreamBuilder<QuerySnapshot>(
              Stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              Builder: (context, snapshot) {
                If (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                Return _buildBookingList(snapshot.data!.docs, false);
              },
            ),
            StreamBuilder<QuerySnapshot>(
              Stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              Builder: (context, snapshot) {
                If (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                Return _buildBookingList(snapshot.data!.docs, true);
              },
            ),
            _buildServicesManager(),
          ],
        ),
      ),
    );
  }         

  Widget _buildBookingList(List<DocumentSnapshot> docs, bool isHistory) {
    If (!isHistory) {
      List<DocumentSnapshot> activeList = docs.where((doc) {
        String status = (doc.data() as Map<String, dynamic>)['status'] ?? 'Pending';
        Return status == 'Pending' || status == 'Approved';
      }).toList();

      ActiveList.sort((a, b) {
        Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
        Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;

        String statusA = dataA['status'] ?? 'Pending';
        String statusB = dataB['status'] ?? 'Pending';

        If (statusA == 'Pending' && statusB != 'Pending') return -1;
        If (statusB == 'Pending' && statusA != 'Pending') return 1;

        If (statusA == 'Pending' && statusB == 'Pending') {
          Timestamp tA = dataA['timestamp'] ?? Timestamp.now();
          Timestamp tB = dataB['timestamp'] ?? Timestamp.now();
          Return tB.compareTo(tA);
        }

        DateTime dateA = _parseBookingDate(dataA['date'] ?? "");
        DateTime dateB = _parseBookingDate(dataB['date'] ?? "");
        Return dateA.compareTo(dateB);
      });

      If (activeList.isEmpty) {
        Return Center(
          Child: Text('No active client bookings!', style: TextStyle(color: Colors.pink.shade900, fontSize: 16)),
        );
      }

      Return ListView.builder(
        ItemCount: activeList.length,
        ItemBuilder: (context, index) => _buildBookingCard(activeList[index], false),
      );
    }

    List<DocumentSnapshot> completedList = docs.where((doc) => ((doc.data() as Map<String, dynamic>)['status'] == 'Completed')).toList();
    List<DocumentSnapshot> cancelledList = docs.where((doc) => ((doc.data() as Map<String, dynamic>)['status'] == 'Cancelled')).toList();

    // Group earnings by year and month
    Map<int, Map<String, int>> earningsByYear = {};
    List<String> monthNames = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    For (var doc in completedList) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      Var priceVal = data['price'];
      Int price = 0;
      If (priceVal is int) price = priceVal;
      else if (priceVal is String) price = int.tryParse(priceVal) ?? 0;

      String dateStr = data['date'] ?? "";
      List<String> parts = dateStr.split('/');
      
      If (parts.length == 3) {
        Int monthIdx = int.tryParse(parts[1]) ?? 0;
        Int year = int.tryParse(parts[2]) ?? DateTime.now().year;

        If (monthIdx >= 1 && monthIdx <= 12) {
          EarningsByYear.putIfAbsent(year, () => {});
          String monthName = monthNames[monthIdx];
          EarningsByYear[year]![monthName] = (earningsByYear[year]![monthName] ?? 0) + price;
        }
      }
    }

    List<int> availableYears = earningsByYear.keys.toList()..sort((a, b) => b.compareTo(a));
    If (availableYears.isEmpty) availableYears.add(DateTime.now().year);

    Int activeYear = availableYears.contains(_selectedRevenueYear) ? _selectedRevenueYear! : availableYears.first;
    Map<String, int> selectedYearEarnings = earningsByYear[activeYear] ?? {};

    Var historySort = (DocumentSnapshot a, DocumentSnapshot b) {
      Timestamp tA = (a.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
      Timestamp tB = (b.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
      Return tB.compareTo(tA);
    };
    CompletedList.sort(historySort);
    CancelledList.sort(historySort);

    If (completedList.isEmpty && cancelledList.isEmpty) {
      Return Center(
        Child: Text('No history matches found.', style: TextStyle(color: Colors.pink.shade900, fontSize: 16)),
      );
    }

    Return ListView(
      Padding: const EdgeInsets.symmetric(vertical: 12),
      Children: [
        // ------------------------- COMBINED REVENUE BREAKDOWN -------------------------
        Card(
          Margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          Color: Colors.green.shade50,
          Shape: RoundedRectangleBorder(
            Radius: BorderRadius.circular(15), 
            Side: BorderSide(color: Colors.green.shade200)
          ),
          Child: Padding(
            Padding: const EdgeInsets.all(16.0),
            Child: Column(
              CrossAxisAlignment: CrossAxisAlignment.start,
              Children: [
                Row(
                  MainAxisAlignment: MainAxisAlignment.spaceBetween,
                  Children: [
                    Row(
                      Children: [
                        CircleAvatar(
                          Radius: 16,
                          BackgroundColor: Colors.green.shade100,
                          Child: const Icon(Icons.analytics, color: Colors.green, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Monthly Revenue",
                          Style: TextStyle(fontSize: 15, color: Colors.green.shade900, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    
                    // Year Selector Dropdown
                    Container(
                      Padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      Decoration: BoxDecoration(
                        Color: Colors.white,
                        Radius: BorderRadius.circular(10),
                        Border: Border.all(color: Colors.green.shade300),
                      ),
                      Child: DropdownButton<int>(
                        Value: activeYear,
                        Underline: const SizedBox(),
                        IsDense: true,
                        Icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade800),
                        Style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 13),
                        OnChanged: (int? newYear) {
                          If (newYear != null) {
                            SetState(() {
                              _selectedRevenueYear = newYear;
                            });
                          }
                        },
                        Items: availableYears.map((int year) {
                          Return DropdownMenuItem<int>(
                            Value: year,
                            Child: Text("$year"),
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
                        Padding: const EdgeInsets.symmetric(vertical: 8.0),
                        Child: Text("No revenue recorded for $activeYear.", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                      )
                    : SizedBox(
                        Height: 75,
                        Child: ListView.builder(
                          ScrollDirection: Axis.horizontal,
                          ItemCount: selectedYearEarnings.entries.length,
                          ItemBuilder: (context, idx) {
                            Final entry = selectedYearEarnings.entries.elementAt(idx);
                            Return Container(
                              Width: 110,
                              Margin: const EdgeInsets.only(right: 10),
                              Padding: const EdgeInsets.all(10),
                              Decoration: BoxDecoration(
                                Color: Colors.white,
                                Radius: BorderRadius.circular(12),
                                Border: Border.all(color: Colors.green.shade200),
                                BoxShadow: [
                                  BoxShadow(color: Colors.green.shade100.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))
                                ],
                              ),
                              Child: Column(
                                MainAxisAlignment: MainAxisAlignment.center,
                                Children: [
                                  Text(
                                    Entry.key, 
                                    Style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "R${entry.value}", 
                                    Style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800)
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
          Padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          Child: Row(
            Children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Text("Completed Appointments (${completedList.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
        If (completedList.isEmpty)
          Padding(
            Padding: const EdgeInsets.all(16.0),
            Child: Text("No completed appointments yet.", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
          )
        else
          ...completedList.map((doc) => _buildBookingCard(doc, true)),

        const Padding(
          Padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          Child: Divider(thickness: 1.5),
        ),

        Padding(
          Padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          Child: Row(
            Children: [
              const Icon(Icons.cancel_outlined, color: Colors.orange),
              const SizedBox(width: 8),
              Text("Cancelled Appointments (${cancelledList.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
        ),
        If (cancelledList.isEmpty)
          Padding(
            Padding: const EdgeInsets.all(16.0),
            Child: Text("No cancelled appointments yet.", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
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

    Bool isOverdue = !isHistory && status == 'Approved' && _isDateInPast(dateStr);

    Color badgeColor;
    Color textColor;
    If (status == 'Pending') {
      BadgeColor = Colors.orange.shade100;
      TextColor = Colors.orange.shade800;
    } else if (status == 'Approved') {
      BadgeColor = isOverdue ? Colors.amber.shade100 : Colors.blue.shade100;
      TextColor = isOverdue ? Colors.amber.shade900 : Colors.blue.shade800;
    } else if (status == 'Completed') {
      BadgeColor = Colors.green.shade100;
      TextColor = Colors.green.shade800;
    } else {
      BadgeColor = Colors.red.shade100;
      TextColor = Colors.red.shade800;
    }

    Return Card(
      Margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      Elevation: isOverdue ? 4 : 2,
      Shape: RoundedRectangleBorder(
        Radius: BorderRadius.circular(15),
        Side: isOverdue
            ? BorderSide(color: Colors.amber.shade700, width: 2)
            : BorderSide.none,
      ),
      Child: Padding(
        Padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        Child: Column(
          CrossAxisAlignment: CrossAxisAlignment.start,
          Children: [
            Row(
              Children: [
                Text(
                  Data['clientName'] ?? 'No Name', 
                  Style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8),
                Container(
                  Padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  Decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                  Child: Text(
                    IsOverdue ? "Needs Completion Check ⚠️" : status, 
                    Style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              CrossAxisAlignment: CrossAxisAlignment.start,
              MainAxisAlignment: MainAxisAlignment.spaceBetween,
              Children: [
                Expanded(
                  Child: Text(
                    "${data['service'] ?? 'No Service'}\n"
                    "📍 ${data['location'] ?? 'No Location'}\n"
                    "📅 ${data['date'] ?? ''} at ${data['time'] ?? ''}\n"
                    "💰 Price: R${data['price'] ?? 0}",
                    Style: TextStyle(height: 1.4, color: Colors.grey.shade800, fontSize: 14),
                  ),
                ),
                
                If (!isHistory)
                  Row(
                    MainAxisSize: MainAxisSize.min,
                    Children: [
                      IconButton(
                        Icon: const Icon(Icons.edit, color: Colors.blue),
                        Padding: const EdgeInsets.symmetric(horizontal: 4),
                        Constraints: const BoxConstraints(),
                        OnPressed: () => _showEditDialog(doc),
                      ),
                      
                      If (status == 'Pending')
                        IconButton(
                          Icon: const Icon(Icons.check_circle, color: Colors.green),
                          Padding: const EdgeInsets.symmetric(horizontal: 4),
                          Constraints: const BoxConstraints(),
                          OnPressed: () => _showEditDialog(doc),
                        )
                      else if (status == 'Approved')
                        IconButton(
                          Icon: Icon(
                            Icons.done_all, 
                            Color: isOverdue ? Colors.amber.shade800 : Colors.purple,
                            Size: isOverdue ? 28 : 24,
                          ),
                          Padding: const EdgeInsets.symmetric(horizontal: 4),
                          Constraints: const BoxConstraints(),
                          OnPressed: () => doc.reference.update({'status': 'Completed'}),
                        ),

                      IconButton(
                        Icon: const Icon(Icons.cancel, color: Colors.orange),
                        Padding: const EdgeInsets.symmetric(horizontal: 4),
                        Constraints: const BoxConstraints(),
                        OnPressed: () => doc.reference.update({'status': 'Cancelled'}),
                      ),
                      
                      IconButton(
                        Icon: const Icon(Icons.delete, color: Colors.red),
                        Padding: const EdgeInsets.symmetric(horizontal: 4),
                        Constraints: const BoxConstraints(),
                        OnPressed: () => doc.reference.delete(),
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
