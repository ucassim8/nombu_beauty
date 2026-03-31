// whatsapp_launcher.dart
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

export 'whatsapp_launcher_stub.dart'
    if (dart.library.html) 'whatsapp_launcher_web.dart';
