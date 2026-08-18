import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Torch Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D2FF),
          secondary: Color(0xFF9D4EDD),
          surface: Color(0xFF161F30),
          background: Color(0xFF0B0F19),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const TorchHomePage(),
    );
  }
}

class TorchHomePage extends StatefulWidget {
  const TorchHomePage({super.key});

  @override
  State<TorchHomePage> createState() => _TorchHomePageState();
}

class _TorchHomePageState extends State<TorchHomePage> with SingleTickerProviderStateMixin {
  static const platform = MethodChannel('com.tourchlite.tourch_lite/torch');

  bool isFlashlightOn = false;
  bool isServiceRunning = false;
  bool isDisclosureAccepted = false;
  
  bool isStrobeActive = false;
  Timer? _strobeTimer;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _initChannelHandler();
    _loadSettings();
  }

  @override
  void dispose() {
    _strobeTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _initChannelHandler() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onTorchStateChanged") {
        final bool isOn = call.arguments as bool;
        setState(() {
          isFlashlightOn = isOn;
        });
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('disclosure_accepted') ?? false;
    final serviceEnabled = prefs.getBool('bg_service_enabled') ?? false;

    // Verify service status from Kotlin (in case OS stopped it)
    bool running = false;
    bool torchOn = false;
    try {
      running = await platform.invokeMethod('isServiceRunning') ?? false;
      torchOn = await platform.invokeMethod('isFlashlightOn') ?? false;
    } catch (e) {
      debugPrint("Error checking service state: $e");
    }

    setState(() {
      isDisclosureAccepted = accepted;
      isServiceRunning = running && serviceEnabled;
      isFlashlightOn = torchOn;
    });

    // If the preference says it should be enabled but it isn't running natively, sync it
    if (serviceEnabled && !running) {
      _startBgService();
    }
  }

  Future<void> _toggleFlashlight() async {
    if (isStrobeActive) {
      _strobeTimer?.cancel();
      setState(() {
        isStrobeActive = false;
      });
    }

    HapticFeedback.mediumImpact();

    final targetState = !isFlashlightOn;
    setState(() {
      isFlashlightOn = targetState;
    });

    try {
      await platform.invokeMethod('toggleFlashlight', {'enable': targetState});
    } catch (e) {
      debugPrint("Error toggling flashlight: $e");
      // Revert UI state on failure
      setState(() {
        isFlashlightOn = !targetState;
      });
    }
  }

  void _toggleStrobe() {
    if (isStrobeActive) {
      _strobeTimer?.cancel();
      setState(() {
        isStrobeActive = false;
        isFlashlightOn = false;
      });
      try {
        platform.invokeMethod('toggleFlashlight', {'enable': false});
      } catch (e) {
        debugPrint("Error stopping strobe: $e");
      }
    } else {
      setState(() {
        isStrobeActive = true;
        isFlashlightOn = true;
      });
      _strobeTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        final nextState = !isFlashlightOn;
        setState(() {
          isFlashlightOn = nextState;
        });
        try {
          platform.invokeMethod('toggleFlashlight', {'enable': nextState});
        } catch (e) {
          debugPrint("Error in strobe interval toggle: $e");
        }
      });
    }
  }

  Future<void> _toggleService(bool value) async {
    if (value) {
      if (!isDisclosureAccepted) {
        final accepted = await _showDisclosureDialog();
        if (!accepted) return;
      }
      await _startBgService();
    } else {
      await _stopBgService();
    }
  }

  Future<void> _startBgService() async {
    try {
      await platform.invokeMethod('startService');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('bg_service_enabled', true);
      setState(() {
        isServiceRunning = true;
      });
    } catch (e) {
      debugPrint("Error starting service: $e");
    }
  }

  Future<void> _stopBgService() async {
    try {
      await platform.invokeMethod('stopService');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('bg_service_enabled', false);
      setState(() {
        isServiceRunning = false;
      });
    } catch (e) {
      debugPrint("Error stopping service: $e");
    }
  }

  Future<bool> _showDisclosureDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF161F30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.security, color: Color(0xFF00D2FF)),
                SizedBox(width: 10),
                Text(
                  "ZAROORI SOOCHNA / NOTICE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Hindi:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D2FF)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Yeh app lock button double-press gesture ko detect karne ke liye background mein chalta hai. Iske liye hum ek constant notification service chalate hain. Hum aapka koi bhi private data collect ya share nahi karte hain. Kya aap is service ko chalu karna chahte hain?",
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                  Divider(height: 24, color: Colors.white24),
                  Text(
                    "English:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9D4EDD)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "This app runs a background service to detect the double-press lock button shortcut. A persistent notification will remain in your status bar. We do NOT collect or share any of your personal data. Do you consent to start this service?",
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("DECLINE", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D2FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("AGREE & CONTINUE"),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('disclosure_accepted', true);
      setState(() {
        isDisclosureAccepted = true;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glow Gradient when torch is ON
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: isFlashlightOn ? 1.2 : 0.6,
                colors: isFlashlightOn
                    ? [
                        const Color(0x3000D2FF),
                        const Color(0x109D4EDD),
                        const Color(0xFF0B0F19),
                      ]
                    : [
                        const Color(0xFF161F30).withOpacity(0.3),
                        const Color(0xFF0B0F19),
                      ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Bar / Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TOURCH LITE",
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Bright LED Flashlight",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isServiceRunning ? const Color(0x2000D2FF) : const Color(0x20FF3B30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isServiceRunning ? const Color(0xFF00D2FF) : const Color(0xFFFF3B30),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isServiceRunning ? "BG ACTIVE" : "BG INACTIVE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isServiceRunning ? const Color(0xFF00D2FF) : const Color(0xFFFF3B30),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Main Glowing Bulb Representation
                  Center(
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFlashlightOn ? const Color(0xFF00D2FF) : const Color(0xFF1E293B),
                            boxShadow: isFlashlightOn
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00D2FF).withOpacity(0.5),
                                      blurRadius: 30 * _glowAnimation.value,
                                      spreadRadius: 5 * _glowAnimation.value,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF9D4EDD).withOpacity(0.3),
                                      blurRadius: 60 * _glowAnimation.value,
                                      spreadRadius: 10 * _glowAnimation.value,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            isFlashlightOn ? Icons.lightbulb : Icons.lightbulb_outline,
                            size: 70,
                            color: isFlashlightOn ? Colors.black : Colors.white24,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Tactile Power Toggle Button
                  Center(
                    child: GestureDetector(
                      onTap: _toggleFlashlight,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isFlashlightOn
                                ? [const Color(0xFF00D2FF), const Color(0xFF0066FF)]
                                : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isFlashlightOn
                                  ? const Color(0x6000D2FF)
                                  : Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                          border: Border.all(
                            color: isFlashlightOn ? Colors.white : Colors.white12,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.power_settings_new,
                          size: 45,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "Tap to turn ON  •  works instantly, no setup needed",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.white38),
                  ),

                  const SizedBox(height: 16),

                  // Secondary Controls Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSecondaryControl(
                        icon: Icons.phone_android_rounded,
                        label: "Screen Light",
                        isActive: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ScreenLightPage()),
                          );
                        },
                      ),
                      const SizedBox(width: 32),
                      _buildSecondaryControl(
                        icon: isStrobeActive ? Icons.flash_on : Icons.flash_off,
                        label: "SOS Blink",
                        isActive: isStrobeActive,
                        activeColor: const Color(0xFF9D4EDD),
                        onTap: _toggleStrobe,
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Background Gesture Settings Panel
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161F30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Double-press Power",
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0x209D4EDD),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "BONUS",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF9D4EDD),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Optional shortcut. Torch above works instantly without this.",
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              activeColor: const Color(0xFF00D2FF),
                              activeTrackColor: const Color(0x4000D2FF),
                              value: isServiceRunning,
                              onChanged: _toggleService,
                            ),
                          ],
                        ),
                        
                        if (isServiceRunning) ...[
                          const Divider(height: 24, color: Colors.white10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.info_outline, size: 16, color: Color(0xFF00D2FF)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Bonus ON. Double-press the power button to toggle the torch even when locked. If it doesn't respond on your phone, see setup below — the main torch button always works.",
                                  style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Settings Info & Expansion Card
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      collapsedBackgroundColor: const Color(0xFF111827),
                      backgroundColor: const Color(0xFF111827),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Colors.white10),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Colors.white10),
                      ),
                      iconColor: const Color(0xFF00D2FF),
                      collapsedIconColor: Colors.grey,
                      title: Row(
                        children: const [
                          Icon(Icons.settings_suggest, color: Color(0xFF00D2FF), size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Setup for double-press bonus (optional)",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(color: Colors.white10),
                              const SizedBox(height: 4),
                              _buildInstructionItem(
                                "1. Disable System Camera Shortcut",
                                "Bohot se phones mein power button double click se camera khul jata hai. Isko phone ki settings se band karein:\nSettings -> Gestures -> Double press power button -> Set to 'None' / 'Off'.",
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionItem(
                                "2. Disable Battery Optimization",
                                "Background service active rahe iske liye app ko battery optimization se exempt karein:\nSettings -> Apps -> Tourch Lite -> Battery -> 'Unrestricted' / 'Don't Optimize'.",
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Empty space for AD Banner Integration
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1424),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "ADVERTISEMENT BANNER PLACEHOLDER",
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color: Colors.white24,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF00D2FF)),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildSecondaryControl({
    required IconData icon,
    required String label,
    required bool isActive,
    Color activeColor = const Color(0xFF00D2FF),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? activeColor.withOpacity(0.2) : const Color(0xFF161F30),
              border: Border.all(
                color: isActive ? activeColor : Colors.white10,
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 24,
              color: isActive ? activeColor : Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? activeColor : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class ScreenLightPage extends StatefulWidget {
  const ScreenLightPage({super.key});

  @override
  State<ScreenLightPage> createState() => _ScreenLightPageState();
}

class _ScreenLightPageState extends State<ScreenLightPage> {
  static const platform = MethodChannel('com.tourchlite.tourch_lite/torch');

  @override
  void initState() {
    super.initState();
    try {
      platform.invokeMethod('setBrightness', {'value': 1.0});
    } catch (e) {
      debugPrint("Error setting brightness: $e");
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    try {
      platform.invokeMethod('setBrightness', {'value': -1.0});
    } catch (e) {
      debugPrint("Error resetting brightness: $e");
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            const SizedBox.expand(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wb_sunny_rounded,
                    size: 80,
                    color: Colors.amber.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "SCREEN LIGHT IS ON",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap anywhere to Turn OFF\n(बंद करने के लिए कहीं भी टच करें)",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black.withOpacity(0.5), size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
