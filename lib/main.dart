import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'chat_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'lang_strings.dart';
import 'translations.dart';
//import 'package:share_plus/share_plus.dart';
import 'theme_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'animations.dart';
import 'theme.dart';
import 'intro_slide.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
//import 'package:permission_handler/permission_handler.dart';


// ✅ Global Variables (keep them exactly as they are)
String customerName = '';
String customerAge = '';
String customerPhone = '';
String customerLocation = '';
bool isVendorLoggedIn = false;
List<Map<String, String>> vendors = [];
List<Map<String, String>> recentlyViewedVendors = [];

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.yellow[700],
  scaffoldBackgroundColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow[600],
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.grey[900],
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amber[800],
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
);

// 🔤 Simple in-app language manager (no extra imports)
class AppLanguage {
  static final ValueNotifier<String> currentLang = ValueNotifier<String>('en');

  static final Map<String, Map<String, String>> translations = {
    'en': {
      'welcome': 'Welcome',
      'change_language': 'Change Language',
      'dark_mode': 'Dark Mode',
      'invite_friends': 'Invite Friends',
      'logout': 'Logout',
    },
    'hi': {
      'welcome': 'स्वागत है',
      'change_language': 'भाषा बदलें',
      'dark_mode': 'डार्क मोड',
      'invite_friends': 'दोस्तों को आमंत्रित करें',
      'logout': 'लॉगआउट',
    },
  };

  static String tr(String key) {
    return translations[currentLang.value]?[key] ?? key;
  }
}

//Future<void> requestPermissions() async {
 // await [
   // Permission.camera,
   // Permission.storage,
  //  Permission.location,
  //].request();
//}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 // ✅ Request permissions first
 // await requestPermissions();
  
  // ✅ Firebase init for both web and mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCMqwm_-KXcRe8YqAagarsBBsc_lh0G4G0",
        authDomain: "localservicesapp-9cc3e.firebaseapp.com",
        projectId: "localservicesapp-9cc3e",
        storageBucket: "localservicesapp-9cc3e.appspot.com",
        messagingSenderId: "899887915588",
        appId: "1:899887915588:web:ed4c679955e2a9112a9211",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
            create: (_) => ThemeProvider()), // ✅ only ThemeProvider now
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppLanguage.currentLang, // ✅ listens to lang changes
          builder: (context, lang, _) {
            return MaterialApp(
              title: 'Local Services App',
              debugShowCheckedModeBanner: false,
              theme: lightTheme, // ✅ use your custom light
              darkTheme: darkTheme, // ✅ use your custom dark
              themeMode: themeProvider.themeMode, // ✅ toggle globally
              home: const FirstPage(), // ✅ LogoPage stays light separately
            );
          },
        );
      },
    );
  }
}

// ✅ Global SnackBar helper with slide + fade animation
void showAppSnackBar(BuildContext context, String message, Color bgColor) {
  final snackBar = SnackBar(
    content: TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(1, 0), end: Offset.zero),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        double progress = 1 - offset.dx; // 0 → 1 as it slides in
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: offset * 200, // Slide distance
            child: child,
          ),
        );
      },
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// ✅ 1. FIRST PAGE
class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _bounceController;
  late AnimationController _buttonGlowController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _buttonGlowAnimation;

  // Particle animation controller
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  final List<String> _letters = [];
  int _currentLetterIndex = 0;
  final String _fullText = "VR LOCAL";
  bool _showTagline = false;

  @override
  void initState() {
    super.initState();

    // Glow animation for VR LOCAL text
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.0,
      upperBound: 6.0,
    )..repeat(reverse: true);

    // Bounce animation for emoji
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Magical glow animation for button
    _buttonGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _buttonGlowAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _buttonGlowController, curve: Curves.easeInOut),
    );

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )
      ..addListener(_updateParticles)
      ..repeat();

    // Reveal VR LOCAL letters one by one
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_currentLetterIndex < _fullText.length) {
        setState(() {
          _letters.add(_fullText[_currentLetterIndex]);
          _currentLetterIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _showTagline = true;
          });
        });
      }
    });
  }

  void _updateParticles() {
    // Add a new particle occasionally at top and bottom
    if (_random.nextDouble() < 0.05) {
      bool fromTop = _random.nextBool();
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: fromTop ? 0.0 : 1.0,
        size: _random.nextDouble() * 3 + 2,
        isLine: _random.nextBool(),
        fromTop: fromTop,
      ));
    }

    // Update existing particles
    for (var p in _particles) {
      double direction = p.fromTop ? 1 : -1;
      p.y += direction * 0.002; // slow drift
      p.opacity = (1 - (p.life / p.maxLife)).clamp(0.0, 1.0);
      p.life++;
    }

    // Remove dead particles
    _particles.removeWhere((p) => p.life > p.maxLife);

    setState(() {});
  }

  @override
  void dispose() {
    _glowController.dispose();
    _bounceController.dispose();
    _buttonGlowController.dispose();
    _particleController.dispose();
    super.dispose();
  }
void _goNext() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Already logged in → fetch user role from Firestore
    final docCustomer = await FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .get();

    final docVendor = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(user.uid)
        .get();

    bool isCustomer = false;
    bool isVendorLoggedInLocal = false;
    Map<String, dynamic> vendorData = {};

    if (docCustomer.exists) {
      isCustomer = true;
    } else if (docVendor.exists) {
      isVendorLoggedInLocal = true;
      vendorData = {
        'vendorId': docVendor['uid'],
        'name': docVendor['name'] ?? '',
        // add more minimal fields if needed
      };
    }

    // Navigate directly to CategoriesPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesPage(
          isCustomer: isCustomer,
          isVendorLoggedIn: isVendorLoggedInLocal,
          vendor: vendorData,
        ),
      ),
    );
  } else {
    // Not logged in → normal intro flow
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const IntroPage()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // ✅ Added Theme wrapper to force light mode
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 153, 51),
        body: Stack(
          children: [
            // Particle painter
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ParticlePainter(_particles),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bouncing human animation
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: const Text(
                          "👩‍💼",
                          style: TextStyle(fontSize: 100),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Glowing VR LOCAL text
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return Text(
                        _letters.join(),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: _glowController.value,
                              color: Colors.white,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Tagline fade-in
                  AnimatedOpacity(
                    opacity: _showTagline ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: AnimatedSlide(
                      offset: _showTagline ? Offset.zero : const Offset(0, 0.5),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      child: const Text(
                        '- We are local!',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Magical glowing Get Started button
                  AnimatedBuilder(
                    animation: _buttonGlowAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: _buttonGlowAnimation.value,
                              spreadRadius: _buttonGlowAnimation.value / 2,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child:ElevatedButton(
 onPressed: _goNext, 
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    backgroundColor: Colors.white,
    foregroundColor: Colors.teal[800],
  ),
  child: const Text('Get Started!'),
),

                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ); // ✅ closed Theme wrapper
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double opacity = 1.0;
  bool isLine;
  bool fromTop;
  int life = 0;
  int maxLife = 200;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.isLine,
    required this.fromTop,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final tealPaint = Paint()
      ..color = Colors.tealAccent.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final whitePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (var p in particles) {
      Paint paint = p.isLine
          ? (p.fromTop ? tealPaint : whitePaint)
          : (p.fromTop ? whitePaint : tealPaint);

      paint.color = paint.color.withOpacity(p.opacity);

      if (p.isLine) {
        // Draw streak line
        double length = p.size * 4;
        canvas.drawLine(
          Offset(p.x * size.width, p.y * size.height),
          Offset(p.x * size.width,
              p.y * size.height + (p.fromTop ? length : -length)),
          paint..strokeWidth = 1.2,
        );
      } else {
        // Draw circle particle
        canvas.drawCircle(
          Offset(p.x * size.width, p.y * size.height),
          p.size,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// ✅ 2. WELCOME OPTIONS PAGE

class WelcomeOptionsPage extends StatefulWidget {
  const WelcomeOptionsPage({super.key});

  @override
  State<WelcomeOptionsPage> createState() => _WelcomeOptionsPageState();
}

class _WelcomeOptionsPageState extends State<WelcomeOptionsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Delay animation start so it's visible after page loads
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Route _professionalTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        );
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        );
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 183, 102),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'WELCOME!!',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    const Text('Are you a Vendor?'),
                    const SizedBox(height: 10),
                    AnimatedAppButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          _professionalTransition(
                              const VendorRegistrationPage()),
                        );
                      },
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'SIGN UP',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            _professionalTransition(
                                const VendorRegistrationPage()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text('Are you a Customer?'),
                    const SizedBox(height: 10),
                    AnimatedAppButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          _professionalTransition(CustomerSignUpPage()),
                        );
                      },
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'START',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            _professionalTransition(CustomerSignUpPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/// ✅ 3. CUSTOMER INFO PAGE
class CustomerSignUpPage extends StatefulWidget {
  const CustomerSignUpPage({super.key});

  @override
  State<CustomerSignUpPage> createState() => _CustomerSignUpPageState();
}

class _CustomerSignUpPageState extends State<CustomerSignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // ✅ New controllers
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final locationController = TextEditingController();

  bool isLogin = false; // ✅ Toggle between Login and Signup
  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // 🔹 LOGIN
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // ✅ Use centralized navigation
        await _goNext();
      } else {
        // 🔹 SIGNUP
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final uid = userCredential.user!.uid;

        // ✅ Save customer to Firestore
        final data = {
          'email': emailController.text.trim(),
          'uid': uid,
          'role': 'customer',
          'name': nameController.text.trim(),
          'age': ageController.text.trim(),
          'location': locationController.text.trim(),
          'createdAt': Timestamp.now(),
          'profileCompleted': false, // ✅ NEW
        };

        await FirebaseFirestore.instance
            .collection('customers')
            .doc(uid)
            .set(data, SetOptions(merge: true));

        // ✅ Admin special case
        if (emailController.text.trim() == "rishithareddy1@gmail.com") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminPage()),
          );
        } else {
          // ✅ Use centralized navigation for normal customers
          await _goNext();
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'email-already-in-use') {
        message = "Email already in use";
      } else if (e.code == 'weak-password') {
        message = "Password too weak";
      } else if (e.code == 'user-not-found') {
        message = "No user found";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password";
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ✅ Centralized navigation for first login / profile completion
  Future<void> _goNext() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(uid)
        .get();
    final data = doc.data() ?? {};

    if (!mounted) return;

    if (data['profileCompleted'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CustomerDashboardPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerEditPage(forceFill: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Customer Login' : 'Customer Sign Up'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 chars'
                    : null,
              ),
              const SizedBox(height: 25),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 40),
                      ),
                      onPressed: _submit,
                      child: Text(isLogin ? 'Login' : 'Sign Up'),
                    ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  setState(() => isLogin = !isLogin);
                },
                child: Text(isLogin
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//customer edit page
class CustomerEditPage extends StatefulWidget {
  final bool forceFill;
  const CustomerEditPage({super.key, this.forceFill = false});

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  bool isSaving = false; // ✅ loading spinner state

  @override
  void initState() {
    super.initState();
    _enableOfflineSupport();
    _loadProfile();
  }

  // ✅ Enable Firestore offline persistence
  void _enableOfflineSupport() {
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('customers').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nameController.text = data["name"] ?? "";
        phoneController.text = data["phone"] ?? "";
        addressController.text = data["address"] ?? "";
        ageController.text = data["age"] ?? "";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (nameController.text.isEmpty ||
        phoneController.text.length != 10 ||
        addressController.text.isEmpty ||
        ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    if (phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone must be 10 digits.")),
      );
      return;
    }

    setState(() => isSaving = true); // ✅ Show spinner

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('customers').doc(uid).set({
        "name": nameController.text,
        "phone": phoneController.text,
        "address": addressController.text,
        "age": ageController.text,
        "profileCompleted": true,
      }, SetOptions(merge: true));

      if (mounted) {
        // ✅ Use centralized navigation instead of direct pushReplacement
        await _goNext();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
    } finally {
      if (mounted) setState(() => isSaving = false); // ✅ Hide spinner
    }
  }

  // ✅ Centralized navigation for first login / profile completion
  Future<void> _goNext() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(uid)
        .get();
    final data = doc.data() ?? {};

    if (!mounted) return;

    if (data['profileCompleted'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CustomerDashboardPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerEditPage(forceFill: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone (10 digits)"),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextField(
              controller: ageController, // ✅ new input
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Age"),
            ),
            const SizedBox(height: 20),
            isSaving
                ? const Center(child: CircularProgressIndicator()) // ✅ Spinner
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text("Save & Continue"),
                  ),
          ],
        ),
      ),
    );
  }
}

//VENDOR REGISTRATION PAGE

class VendorRegistrationPage extends StatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  State<VendorRegistrationPage> createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final areaController = TextEditingController();
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final availableDaysController = TextEditingController();
  final timingController = TextEditingController();
  final specialTimingController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedCategory;
  bool isLogin = false;
  bool isLoading = false;

  Future<void> _registerVendor() async {
    if (nameController.text.isEmpty ||
        selectedCategory == null ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // ✅ Validate phone number here
    if (phoneController.text.isEmpty ||
        phoneController.text.length != 10 ||
        !RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit phone number')),
      );
      return; // stop registration if invalid
    }
    setState(() => isLoading = true);
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // ✅ Save with BOTH your emoji keys AND plain keys so dashboard reads them reliably
      final data = {
        // ---- your original emoji keys ----
        '👤name': nameController.text.trim(),
        // Add to both emoji and plain keys
        '📞phone': phoneController.text.trim(),
        'phone': phoneController.text.trim(),

        '📦category': selectedCategory,
        '🌏area': areaController.text.trim(),
        '📍fullAddress': addressController.text.trim(),
        '💵priceRange': priceController.text.trim(),
        '🗓️availableDays': availableDaysController.text.trim(),
        '🕒generalTiming': timingController.text.trim(),
        '⏱️specialTiming': specialTimingController.text.trim(),
        '✉️email': emailController.text.trim(),

        // ---- plain, normalized keys (for dashboard/use later) ----
        'name': nameController.text.trim(),
        'category': selectedCategory,
        'area': areaController.text.trim(),
        'fullAddress': addressController.text.trim(),
        'priceRange': priceController.text.trim(),
        'availableDays': availableDaysController.text.trim(),
        'generalTiming': timingController.text.trim(),
        'specialTiming': specialTimingController.text.trim(),
        'email': emailController.text.trim(),
        // Convenience keys some pages expect:
        'service': selectedCategory,
        'location': areaController.text.trim(),

        // meta
        'uid': uid,
        'timestamp': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('vendors').doc(uid).set(data);

      _navigateToDashboard();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loginVendor() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _navigateToDashboard();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _navigateToDashboard() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Pass at least uid; dashboard will fetch full, authoritative data.
    final vendorData = {
      'uid': uid,
      'name': nameController.text,
      'email': emailController.text,
    };

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => VendorDashboardPage(vendor: vendorData),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Vendor Login' : 'Register as Vendor'),
        backgroundColor: const Color.fromARGB(255, 255, 204, 153),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!isLogin) ...[
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: '👤Business person Name'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: '📞Phone Number',
                  hintText: '10-digit phone number',
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: const [
                  DropdownMenuItem(
                      value: '🧺Laundry', child: Text('🧺Laundry')),
                  DropdownMenuItem(
                      value: '👔Ironing', child: Text('👔Ironing')),
                  DropdownMenuItem(
                      value: '🎁Handmade Gifts',
                      child: Text('🎁Handmade Gifts')),
                  DropdownMenuItem(
                      value: '🎵Music Class', child: Text('🎵Music Class')),
                  DropdownMenuItem(value: 'Mehendi', child: Text('Mehendi')),
                  DropdownMenuItem(
                      value: '💆‍♀Beauty & Wellness',
                      child: Text('💆‍♀Beauty & Wellness')),
                  DropdownMenuItem(
                      value: '📸Photography', child: Text('📸Photography')),
                  DropdownMenuItem(
                      value: '💡Electricians', child: Text('💡Electricians')),
                  DropdownMenuItem(
                      value: '🔧Mechanics', child: Text('🔧Mechanics')),
                  DropdownMenuItem(
                      value: '🧹Cleaning Services',
                      child: Text('🧹Cleaning Services')),
                  DropdownMenuItem(value: '🎂Baking', child: Text('🎂Baking')),
                  DropdownMenuItem(
                      value: '🪴Gardening', child: Text('🪴Gardening')),
                  DropdownMenuItem(
                      value: '🖥Computer Repair',
                      child: Text('🖥Computer Repair')),
                  DropdownMenuItem(
                      value: '🚚Packing & Moving',
                      child: Text('🚚Packing & Moving')),
                  DropdownMenuItem(
                      value: '📦Delivery Services',
                      child: Text('📦Delivery Services')),
                  DropdownMenuItem(
                      value: '🧘Yoga & Fitness',
                      child: Text('🧘Yoga & Fitness')),
                  DropdownMenuItem(value: '📚Tutor', child: Text('📚Tutor')),
                  DropdownMenuItem(
                      value: '💃Dance Class', child: Text('💃Dance Class')),
                  DropdownMenuItem(value: '🥋Karate', child: Text('🥋Karate')),
                  DropdownMenuItem(value: '🪡Tailor', child: Text('🪡Tailor')),
                ],
                onChanged: (value) => setState(() => selectedCategory = value),
                decoration: const InputDecoration(labelText: '📦Service Type'),
              ),
              const SizedBox(height: 10),
              TextField(
                  controller: areaController,
                  decoration: const InputDecoration(
                      labelText: '🌏Area',
                      hintText: 'e.g. banjara hills, hyderabad')),
              const SizedBox(height: 10),
              TextField(
                  controller: addressController,
                  decoration:
                      const InputDecoration(labelText: '📍Full Address')),
              const SizedBox(height: 10),
              TextField(
                  controller: priceController,
                  decoration:
                      const InputDecoration(labelText: '💵Price Range')),
              const SizedBox(height: 10),
              TextField(
                  controller: availableDaysController,
                  decoration: const InputDecoration(
                      labelText: '🗓️Available Days',
                      hintText: 'e.g. Monday-Saturday')),
              const SizedBox(height: 10),
              TextField(
                  controller: timingController,
                  decoration: const InputDecoration(
                      labelText: '🕒General Timing',
                      hintText: 'e.g. 9:00 am - 6:00 pm')),
              const SizedBox(height: 10),
              TextField(
                  controller: specialTimingController,
                  decoration: const InputDecoration(
                      labelText: '⏱️Special Timing',
                      hintText: 'e.g. Sunday-2:00am-4:00pm')),
              const SizedBox(height: 10),
            ],
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: '✉️Email')),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '🔑Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: isLogin ? _loginVendor : _registerVendor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 204, 153),
                      foregroundColor: Colors.black,
                    ),
                    child: Text(isLogin ? 'Login' : 'Register'),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() => isLogin = !isLogin);
              },
              child: Text(isLogin
                  ? "Don't have an account? Register"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}

//CategoriesPage
class CategoriesPage extends StatelessWidget {
  final bool isCustomer;
  final bool isVendorLoggedIn; // ✅ clear single variable name
  final Map<String, dynamic> vendor; // keeping as you had it

  const CategoriesPage({
    super.key,
    required this.isCustomer,
    required this.isVendorLoggedIn, // ✅ use the same name everywhere
    required this.vendor,
  });

  final List<String> categories = const [
    '🧺Laundry',
    '👔Ironing',
    '🎁Handmade Gifts',
    '🎵Music Class',
    'Mehendi',
    ' 💆‍♀️Beauty & Wellness',
    '📸Photography',
    '💡Electricians',
    '🔧Mechanics',
    '🧹Cleaning Services',
    '🎂Baking',
    '🪴Gardening',
    '🖥️Computer Repair',
    '🚚Packing & Moving',
    '📦Delivery Services',
    '🧘Yoga & Fitness',
    '📚Tutor',
    '💃Dance Class',
    '🥋Karate',
    '🪡Tailor',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'categories')),
        backgroundColor: const Color.fromARGB(255, 255, 153, 51),
        actions: [
          IconButton(
            icon:
                Icon(isCustomer ? Icons.add_circle_outline : Icons.assignment),
            tooltip: isCustomer ? 'Post a Need' : 'Availability',
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please login to continue")),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => isCustomer
                      ? PostNeedPage(
                          isCustomer: true,
                          customerName: user.displayName ?? "Unknown",
                        )
                      : AvailableNeedsPage(
                          vendorId: user.uid,
                        ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => isVendorLoggedIn
                      ? VendorDashboardPage(vendor: vendor)
                      : const CustomerDashboardPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3 / 2,
          ),
          itemBuilder: (context, index) {
            return BounceInWidget(
              delayMilliseconds: index * 150,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorListPage(
                        category: categories[index],
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 230, 204),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal, width: 1),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    categories[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // ✅ Floating button visible ONLY for vendors
      floatingActionButton: isVendorLoggedIn
          ? Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 255, 204, 153),
                  child: const Icon(Icons.circle, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VendorStatusUpdatePage(),
                      ),
                    );
                  },
                ),
              ),
            )
          : null,
    );
  }
}

/// ✅ 5. VENDOR DASHBOARD WITH EDIT OPTION
//DOOOPPEEEEEEE
class VendorDashboardPage extends StatefulWidget {
  final Map<String, dynamic> vendor;

  const VendorDashboardPage({super.key, required this.vendor});

  @override
  _VendorDashboardPageState createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  Map<String, dynamic>? vendorData;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadVendor();
  }

  String _firstNonEmpty(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return '';
  }

  Future<void> _loadVendor() async {
    setState(() {
      loading = true;
    });

    try {
      // ✅ robust UID source: passed map OR currently signed-in user
      final uid = (widget.vendor['uid']?.toString().trim().isNotEmpty ?? false)
          ? widget.vendor['uid']
          : FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        setState(() {
          vendorData = null;
        });
      } else {
        final vendorDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(uid)
            .get();

        if (vendorDoc.exists) {
          final raw = vendorDoc.data() ?? {};

          // ✅ normalize keys (works with emoji keys, different casings, etc.)
          final category = _firstNonEmpty(raw, [
            'category',
            '📦category',
            '📦Category',
            'Category',
            'service',
            'serviceCategory'
          ]);

          final name =
              _firstNonEmpty(raw, ['name', '👤name', '👤Name', 'Name']);
          final email = _firstNonEmpty(raw, ['email', '✉️email', 'Email']);
          final area = _firstNonEmpty(raw, ['area', '🌏area', 'Area']);
          final fullAddress = _firstNonEmpty(
              raw, ['fullAddress', '📍fullAddress', 'Full Address']);
          final priceRange = _firstNonEmpty(
              raw, ['priceRange', '💵priceRange', 'Price', '💵Price Range']);
          final availableDays = _firstNonEmpty(
              raw, ['availableDays', '🗓️availableDays', '🗓Available Days']);
          final generalTiming = _firstNonEmpty(
              raw, ['generalTiming', '🕒generalTiming', 'General Timing']);
          final specialTiming = _firstNonEmpty(
              raw, ['specialTiming', '⏱️specialTiming', 'Special Timing']);
          final phone = _firstNonEmpty(raw, ['phone', '📞phone']);

          final normalized = {
            'uid': raw['uid'] ?? uid,
            'name': name,
            'email': email,
            'category': category,
            'service': category, // your UI reads 'service' in subtitle
            'area': area,
            'location': area, // your UI sometimes expects 'location'
            'fullAddress': fullAddress,
            'priceRange': priceRange,
            'availableDays': availableDays,
            'generalTiming': generalTiming,
            'specialTiming': specialTiming,
            'phone': phone,
            // keep capitalized for the second detail card method (if used)
            'Category': category,
          };

          setState(() {
            vendorData = normalized;
          });
        } else {
          setState(() {
            vendorData = null;
          });
        }
      }
    } catch (e) {
      print('Error loading vendor: $e');
      setState(() {
        vendorData = null;
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Vendor Dashboard'),
          backgroundColor:
              const Color.fromARGB(255, 255, 153, 51), // strong saffron,
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Go to Categories',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoriesPage(
                        isCustomer: false,
                        vendor: widget.vendor,
                        isVendorLoggedIn: true),
                  ),
                );
              },
            ),
          ]),
      drawer: TweenAnimationBuilder(
        tween: Tween<double>(begin: -1.0, end: 0.0),
        duration: const Duration(milliseconds: 400), // slowed down a bit
        curve: Curves.easeInOut, // smooth and professional
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(value * MediaQuery.of(context).size.width, 0),
            child: Opacity(
              opacity: 1.0 + value, // fade-in effect
              child: child,
            ),
          );
        },
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Text('Vendor Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 183, 102),
                ),
                accountName: Text(
                  vendorData?['name'] != null &&
                          vendorData!['name'].toString().isNotEmpty
                      ? vendorData!['name']
                      : '👋Hi, Vendor',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text(
                  vendorData?['email'] != null &&
                          vendorData!['email'].toString().isNotEmpty
                      ? vendorData!['email']
                      : 'example@email.com',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    vendorData?['name'] != null &&
                            vendorData!['name'].toString().isNotEmpty
                        ? vendorData!['name'][0].toUpperCase()
                        : '?',
                    style:
                        const TextStyle(fontSize: 30, color: Colors.deepPurple),
                  ),
                ),
              ),
              //ListTile(
              // leading: const Icon(Icons.favorite, color: Colors.red),
              //title: const Text("Favourites"),
              //onTap: () {
              //Navigator.push(
              //context,
              //MaterialPageRoute(
              // builder: (_) => FavoritesPage(
              // userId: widget.vendor['uid'], // ✅ FIXED
              // isVendor: true,
              // ),
              //  ),
              // );
              // },
              // ),
              // ListTile(
              //leading: const Icon(Icons.language),
              // title: Text(tr(context, 'change_language')),
              // trailing: PopupMenuButton<String>(
              //  icon: const Icon(Icons.arrow_drop_down),
              // onSelected: (String value) {
              // Provider.of<LanguageProvider>(context, listen: false)
              // .changeLanguage(value);
              // },
              // itemBuilder: (context) => const [
              ////  PopupMenuItem(value: 'en', child: Text('English')),
//PopupMenuItem(value: 'te', child: Text('తెలుగు')),
              //  PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
              // ],
              // ),
              // ),

              // ✅ Change Language - only English
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: const Text('English'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Only English is available')),
                  );
                },
              ),
              SwitchListTile(
                title: Text(tr(context, 'dark_mode')),
                secondary: const Icon(Icons.brightness_6),
                value: Provider.of<ThemeProvider>(context).isDarkMode,
                onChanged: (bool value) {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(value);
                },
              ),
             ListTile(
  leading: const Icon(Icons.logout),
  title: Text(tr(context, 'logout')),
  onTap: () async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Logout
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FirstPage()),
        );
      }
    }
  },
),

              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Invite Friends'),
                onTap: () async {
                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 300));
                 // await Share.share(
                   // "Im using this free Local Services App to grow my business and reach more customers in my area. You should definitely try it – it's free and useful!"
                   // "నేను ఈ ఫ్రీ లోకల్ సర్వీసెస్ యాప్ వాడి, నా ఏరియాలో కస్టమర్లను పెంచుకోగలిగాను. మీరు కూడా తప్పకుండా ప్రయత్నించండి – ఉచితం, ఉపయోగకరం!"
                   // "Install Now! using below link-'myapp.in'",
                 // );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ThankYouPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (vendorData == null)
              ? const Center(child: Text('No vendor details found.'))
              : Column(
                  children: [
                    _buildDetailCard(context, vendorData!, _loadVendor),
                    const SizedBox(height: 20),
                  ],
                ),
    );
  }

  Widget _buildDetailCard(BuildContext context,
      Map<String, dynamic>? vendorData, VoidCallback reloadCallback) {
    if (vendorData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              vendorData['name'] != null && vendorData['name'].isNotEmpty
                  ? vendorData['name'][0].toUpperCase()
                  : '?',
              style: const TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
          title: Text(
            vendorData['name'] ?? 'No name',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Service: ${vendorData['service'] ?? 'Not provided'}',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VendorEditPage(
                    docId: vendorData['uid'],
                  ),
                ),
              ).then((_) {
                reloadCallback();
              });
            },
          ),
        ),
      ),
    );
  }
}

// (Keeping your second function name the same; it will work with the normalized map.)
Widget _buildDetailCard(BuildContext context, Map<String, dynamic> vendorData,
    VoidCallback reloadCallback) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Card(
      elevation: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Name: ${vendorData['name'] ?? ''}"),
          Text("Email: ${vendorData['email'] ?? ''}"),
          Text("Phone: ${vendorData['phone'] ?? ''}"),
          Text("Category: ${vendorData['Category'] ?? ''}"),
          Text("Location: ${vendorData['location'] ?? ''}"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: reloadCallback,
            child: const Text('Reload Data'),
          ),
        ],
      ),
    ),
  );
}

/// ✅ 6. EDIT VENDOR PAGE

class VendorEditPage extends StatefulWidget {
  final String docId; // ✅ This comes from vendor list page
  const VendorEditPage({super.key, required this.docId});

  @override
  State<VendorEditPage> createState() => _VendorEditPageState();
}

class _VendorEditPageState extends State<VendorEditPage> {
  final List<String> Service = [
    '🧺Laundry',
    '👔Ironing',
    '🎁Handmade Gifts',
    '🎵Music Class',
    'Mehendi',
    ' 💆‍♀️Beauty & Wellness',
    '📸Photography',
    '💡Electricians',
    '🔧Mechanics',
    '🧹Cleaning Services',
    '🎂Baking',
    '🪴Gardening',
    '🖥️Computer Repair',
    '🚚Packing & Moving',
    '📦Delivery Services',
    '🧘Yoga & Fitness',
    '📚Tutor',
    '💃Dance Class',
    '🥋Karate',
    '🪡Tailor',
  ];

  //final List<String> Blanks = ["", "", "", "", ""]; // ✅ unchanged

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController availableDaysController = TextEditingController();
  final TextEditingController timingController = TextEditingController();
  final TextEditingController specialTimingController = TextEditingController();

  String? selectedService;

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    var doc = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.docId)
        .get();

    if (doc.exists) {
      var data = doc.data()!;
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      //selectedService = data['service'] ?? Service.first;
      areaController.text = data['area'] ?? '';
      addressController.text = data['fullAddress'] ?? '';
      priceController.text = data['priceRange'] ?? '';
      availableDaysController.text = data['availableDays'] ?? '';
      timingController.text = data['generalTiming'] ?? '';
      specialTimingController.text = data['specialTiming'] ?? '';
      setState(() {});
    }
  }

  Future<void> _updateVendor() async {
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.docId) // ✅ update by doc.id
        .update({
      'name': nameController.text,
      'email': emailController.text,
      //'service': selectedService ?? Service.first,
      'area': areaController.text,
      'fullAddress': addressController.text,
      'priceRange': priceController.text,
      'availableDays': availableDaysController.text,
      'generalTiming': timingController.text,
      'specialTiming': specialTimingController.text,
    });

    Navigator.pop(context); // go back after save
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vendor'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              //DropdownButtonFormField<String>(
              //value: selectedService,
              //decoration: const InputDecoration(labelText: 'Service'),
              //items: Service.map((service) {
              // return DropdownMenuItem(
              //value: service,
              //child: Text(service),
              // );
              //}).toList(),
              //onChanged: (value) {
              //setState(() {
              //selectedService = value;
//});
              //},
              // ),
              const SizedBox(height: 20),
              TextField(
                  controller: areaController,
                  decoration: const InputDecoration(labelText: 'Area')),
              const SizedBox(height: 10),
              TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'fullAddress')),
              const SizedBox(height: 10),
              TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'PriceRange')),
              const SizedBox(height: 10),
              TextField(
                  controller: availableDaysController,
                  decoration:
                      const InputDecoration(labelText: 'Available Days')),
              const SizedBox(height: 10),
              TextField(
                  controller: timingController,
                  decoration:
                      const InputDecoration(labelText: 'generalTiming')),
              const SizedBox(height: 10),
              TextField(
                  controller: specialTimingController,
                  decoration:
                      const InputDecoration(labelText: 'Special Timing')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateVendor,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 230, 204)),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//VENDOR STATUS UPDATE PAGE

class VendorStatusUpdatePage extends StatefulWidget {
  const VendorStatusUpdatePage({super.key});

  @override
  State<VendorStatusUpdatePage> createState() => _VendorStatusUpdatePageState();
}

class _VendorStatusUpdatePageState extends State<VendorStatusUpdatePage> {
  String? _selectedStatus;
  final TextEditingController _customController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {"label": "✅ Available Today", "color": "green"},
    {"label": "❌ Not Available Today", "color": "red"},
    {"label": "🕒 Busy, back later", "color": "orange"},
    {
      "label": "🎉 Special Offer Today!",
      "color": "const Color.fromARGB(255, 223, 203, 26);"
    },
    {"label": "✍️ Custom", "color": "blue"},
  ];

  Future<void> _saveStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String message;
    String color;

    if (_selectedStatus == "✍️ Custom") {
      if (_customController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a custom message")),
        );
        return;
      }
      message = _customController.text.trim();
      color = "blue";
    } else {
      final option =
          _statusOptions.firstWhere((opt) => opt["label"] == _selectedStatus);
      message = option["label"];
      color = option["color"];
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection("vendors")
          .doc(user.uid)
          .update({
        "status": {
          "message": message,
          "color": color,
          "timestamp": FieldValue.serverTimestamp(),
        }
      });

      Navigator.pop(context); // ✅ go back after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving status: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Status"),
        backgroundColor: const Color.fromARGB(255, 255, 204, 153),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose your availability status",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- Status options ---
            ..._statusOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option["label"]),
                value: option["label"],
                groupValue: _selectedStatus,
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val;
                  });
                },
              );
            }),

            if (_selectedStatus == "✍️ Custom")
              TextField(
                controller: _customController,
                decoration: const InputDecoration(
                  labelText: "Enter custom status",
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 20),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 204, 153),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Save Status"),
                  ),
          ],
        ),
      ),
    );
  }
}

/// ✅ 7. CUSTOMER DASHBOARD

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isLoading = true;

  // ✅ CHANGED: Added state for drawer display
  String customerName = ''; // ✅ CHANGED
  String customerEmail = ''; // ✅ CHANGED

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

// ✅ CHANGED: Load name and email from Firestore
  Future<void> _loadCustomerData() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          customerName = data['name'] ?? ''; // ✅ CHANGED
          customerEmail = data['email'] ?? ''; // ✅ CHANGED
          nameController.text = customerName;
          ageController.text = data['age'] ?? '';
          addressController.text = data['address'] ?? '';
          phoneController.text = data['phone'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error loading profile: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> saveEdits() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('customers').doc(uid).set({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'profileCompleted': true,
      }, SetOptions(merge: true));

      if (!mounted) return;

      // ✅ Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      // ✅ Redirect back to CategoriesPage (no freeze)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CategoriesPage(
            isCustomer: true,
            isVendorLoggedIn: false,
            vendor: {},
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
    }
  }

  Future<void> handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const FirstPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        backgroundColor: const Color.fromARGB(255, 255, 153, 51),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoriesPage(
                            isCustomer: true,
                            isVendorLoggedIn: false,
                            vendor: {},
                          )),
                  (route) => false);
            },
          )
        ],
      ),

      // your drawer will remain here ↓
      //DRAWER
      drawer: TweenAnimationBuilder(
        tween: Tween<double>(begin: -1.0, end: 0.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(value * MediaQuery.of(context).size.width, 0),
            child: Opacity(
              opacity: 1.0 + value,
              child: child,
            ),
          );
        },
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(child: Text('Welcome')),
              UserAccountsDrawerHeader(
                accountName: Text(
                  customerName.isNotEmpty
                      ? customerName
                      : 'Customer', // ✅ CHANGED
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                accountEmail: Text(
                  customerEmail.isNotEmpty
                      ? customerEmail
                      : 'example@email.com', // ✅ CHANGED
                  style: const TextStyle(fontSize: 16),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    customerName.isNotEmpty
                        ? customerName[0].toUpperCase()
                        : '?', // ✅ CHANGED
                    style:
                        const TextStyle(fontSize: 30, color: Colors.deepPurple),
                  ),
                ),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 183, 102)),
              ),
              // ✅ ADMIN OPTION (only visible if email matches)
              if (FirebaseAuth.instance.currentUser?.email ==
                  "rishithareddy1@gmail.com")
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings,
                      color: Colors.deepPurple),
                  title: const Text("Admin Dashboard"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminPage()),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.orange),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsPage()),
                  );
                },
              ),

              //ListTile(
              //leading: const Icon(Icons.favorite, color: Colors.red),
              // title: const Text("Favourites"),
              // onTap: () {
              // Navigator.push(
              //  context,
              //   MaterialPageRoute(
              // builder: (context) => FavoritesPage(
              // userId: FirebaseAuth
              //     .instance.currentUser!.uid, // customer UID
              //  isVendor: false,
              //  ),
              //   ),
              // );
              //  },
              //  ),

              ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLanguage.tr('change_language')), // ✅ dynamic
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String value) {
                    AppLanguage.currentLang.value =
                        value; // ✅ updates instantly
                  },
                  itemBuilder: (BuildContext context) => const [
                    PopupMenuItem(value: 'en', child: Text('English')),
                    PopupMenuItem(value: 'hi', child: Text('हिंदी')),
                  ],
                ),
              ),

              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: Text(AppLanguage.tr('dark_mode')), // ✅ translatable
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                  );
                },
              ),

// Inside your ListTile:

              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Invite Friends'),
                onTap: () async {
                  // Close drawer or current screen
                  Navigator.pop(context);

                  // Wait for drawer to close
                  await Future.delayed(const Duration(milliseconds: 300));

                  // Share the message
                 // await Share.share(
                  //  " Discover Services Around You - Fast, Easy, and Free!"
                  //  "Use our free Local Services App to:"
                  //  "⭐Find trusted vendors in your area for tailoring, snacks, tuition & more"
                    //"📞Chat or call vendors directly - no middlemen"
                   // "🤝Support local talent around you"
                   // "Try now - it's 100% free and made for your convenience!"
                   /// "మీ ప్రదేశంలోని సేవలు - తేలికగా, వేగంగా, ఉచితంగా!"
                    //"ఈ ఉచిత స్థానిక సేవల యాప్ ద్వారా:"
                   // "⭐ మీ ప్రదేశంలోని నమ్మకమైన సేవలందించే వారిని కనుగొనండి"
                   // "📞 వారితో నేరుగా చాట్ చేయండి లేదా కాల్ చేయండి"
                    //"🤝 మీ చుట్టూ ఉన్న స్థానిక ప్రతిభను ప్రోత్సహించండి"
                   // "ఇప్పుడు ప్రయత్నించండి - ఇది పూర్తిగా ఉచితం!"
                    ////"Install Now! using below link-'myapp.in'",
                 // );

                  // Navigate to Thank You page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ThankYouPage()),
                  );
                },
              ),
             ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Logout'),
  onTap: () async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await handleLogout();
    }
  },
),

            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
              controller: nameController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              )),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            readOnly: true,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: '🎂 Age',
              prefixIcon: Icon(Icons.cake),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: addressController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: '🏠 Address',
              prefixIcon: Icon(Icons.home),
              border: OutlineInputBorder(),
            ),
          ),
        ]),
      ),
    );
  }
}

//MY POSTED NEEDS PAGE AND WHO ACCEPTED
class MyPostedNeedsPage extends StatelessWidget {
  const MyPostedNeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Posted Needs')),
      backgroundColor:
          const Color.fromARGB(255, 255, 153, 51), // strong saffron,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posted_needs')
            .where('customerId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('You haven’t posted any needs.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'No Title';
              final description = data['description'] ?? 'No Description';
              final status = data['status'] ?? 'pending';
              final vendorName = data['vendorName'] ?? '';
              final vendorContact = data['vendorContact'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(description),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                        style: TextStyle(
                          color: status == 'accepted'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (status == 'accepted')
                        Text(
                          'By: $vendorName\n$vendorContact',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.right,
                        ),
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
}

//ACCEPTED NEEDS PAGE FOR VENDOR IN DASHBOARD
class MyAcceptedNeedsPage extends StatelessWidget {
  const MyAcceptedNeedsPage({super.key, required Map<String, dynamic> vendor});

  @override
  Widget build(BuildContext context) {
    final vendorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Needs I Accepted')),
      backgroundColor:
          const Color.fromARGB(255, 255, 153, 51), // strong saffron
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posted_needs')
            .where('vendorId', isEqualTo: vendorId)
            .where('status', isEqualTo: 'accepted')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
                child: Text('You haven’t accepted any needs yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'No Title';
              final description = data['description'] ?? 'No Description';
              final customerName = data['customerName'] ?? '';
              final customerContact = data['customerContact'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(description),
                  trailing: Text(
                    'Customer:\n$customerName\n$customerContact',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
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

/// ✅ 8. VENDOR LIST PAGE
class VendorListPage extends StatefulWidget {
  final String category;
  const VendorListPage({super.key, required this.category});

  @override
  _VendorListPageState createState() => _VendorListPageState();
}

class _VendorListPageState extends State<VendorListPage> {
  List<Map<String, dynamic>> filteredVendors = [];

//  @override
//  void initState() {
//    super.initState();
//    fetchVendorsFromFirestore();
//  }

  Future<void> fetchVendorsFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('vendors').get();

      final allVendors = snapshot.docs.map((doc) {
        return {
          "docId": doc.id, // ✅ include Firestore docId
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      // ✅ ADDED: remove soft-deleted vendors (deleted == true)
      final notDeleted =
          allVendors.where((vendor) => vendor['deleted'] != true).toList();

      // Filter by category
      final vendorsForCategory = notDeleted
          .where((vendor) =>
              vendor['category'] != null &&
              vendor['category'] == widget.category)
          .toList();

      setState(() {
        filteredVendors = vendorsForCategory;
      });
    } catch (e) {
      print("Error fetching vendors: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort vendors by their avg rating (descending)
    final sortedVendors = [...filteredVendors]..sort((a, b) {
        final totalA = (a['totalRating'] ?? 0) as num;
        final countA = (a['ratingCount'] ?? 0) as num;
        final avgA = countA > 0 ? totalA / countA : 0.0;

        final totalB = (b['totalRating'] ?? 0) as num;
        final countB = (b['ratingCount'] ?? 0) as num;
        final avgB = countB > 0 ? totalB / countB : 0.0;

        // Higher rating first
        return avgB.compareTo(avgA);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('Vendors - ${widget.category}'),
        backgroundColor: const Color.fromARGB(255, 255, 183, 102),
      ),
      body: Column(
        children: [
          Expanded(
            // 🔹 CHANGED: wrapped ListView in StreamBuilder for live updates
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('vendors').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 🔹 Prepare vendor list locally
                final allVendors = snapshot.data!.docs.map((doc) {
                  return {
                    "docId": doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  };
                }).toList();

                final notDeleted = allVendors
                    .where((vendor) => vendor['deleted'] != true)
                    .toList();

                final filteredVendorsStream = notDeleted
                    .where((vendor) =>
                        vendor['category'] != null &&
                        vendor['category'] == widget.category)
                    .toList();

                // 🔹 Sort by average rating descending
                filteredVendorsStream.sort((a, b) {
                  final totalA = (a['totalRating'] ?? 0) as num;
                  final countA = (a['ratingCount'] ?? 0) as num;
                  final avgA = countA > 0 ? totalA / countA : 0.0;

                  final totalB = (b['totalRating'] ?? 0) as num;
                  final countB = (b['ratingCount'] ?? 0) as num;
                  final avgB = countB > 0 ? totalB / countB : 0.0;

                  return avgB.compareTo(avgA);
                });

                if (filteredVendorsStream.isEmpty) {
                  return const Center(child: Text('No vendors found'));
                }

                return ListView.builder(
                  itemCount: filteredVendorsStream.length,
                  itemBuilder: (context, index) {
                    var vendor = filteredVendorsStream[index];

                    // ⭐ Everything below stays exactly as in your current code
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 3,
                                  color: (() {
                                    // 1) Prefer explicit color string if present (statusColor: "green"/"red"/"orange"/"blue")
                                    final sc = (vendor['statusColor'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                    if (sc == 'green') return Colors.green;
                                    if (sc == 'red') return Colors.red;
                                    if (sc == 'orange') return Colors.orange;
                                    if (sc == 'blue') return Colors.blue;

                                    // 2) Otherwise, derive from the status label text (with or without emojis)
                                    final s = (vendor['status'] ??
                                            vendor['statusLabel'] ??
                                            '')
                                        .toString()
                                        .toLowerCase();

                                    // normalize (so emojis / punctuation don't break matching)
                                    // we only rely on keywords:
                                    if (s.contains('available') &&
                                        !s.contains('not')) return Colors.green;
                                    if (s.contains('not') &&
                                        s.contains('available'))
                                      return Colors.red;
                                    if (s.contains('busy'))
                                      return Colors.orange;
                                    if (s.contains('offer')) return Colors.blue;

                                    // 3) default
                                    return Colors.grey;
                                  })(),
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.orange.shade200,
                                child: Text(
                                  (vendor['name'] != null &&
                                          (vendor['name'] as String).isNotEmpty)
                                      ? (vendor['name'] as String)
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),

                            // "OFFER" badge if special offer
                            if (((vendor['status'] ??
                                        vendor['statusLabel'] ??
                                        '')
                                    .toString()
                                    .toLowerCase()
                                    .contains('offer')) ||
                                ((vendor['statusColor'] ?? '')
                                        .toString()
                                        .toLowerCase() ==
                                    'blue'))
                              Positioned(
                                right: -2,
                                bottom: -6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'OFFER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          vendor['name'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (vendor['area'] != null &&
                                vendor['area']!.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(vendor['area'] ?? ''),
                                ],
                              ),
                            if (vendor['priceRange'] != null ||
                                vendor['price'] != null)
                              Row(
                                children: [
                                  const Icon(Icons.currency_rupee,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                      '${vendor['priceRange'] ?? vendor['price']} onwards'),
                                ],
                              ),
                            // ✅ Add this INSIDE children (not outside!)
                            if (vendor['badges'] is List &&
                                vendor['badges'].isNotEmpty)
                              Wrap(
                                spacing: 6,
                                children: (vendor['badges'] as List)
                                    .map((badge) => Chip(
                                          label: Text(badge),
                                          backgroundColor:
                                              Colors.green.shade100,
                                          labelStyle: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))
                                    .toList(),
                              ),
                          ],
                        ),
// ⭐ Compact rating badge with count
                        trailing: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('vendors')
                              .doc(vendor['docId'])
                              .collection('reviews')
                              .snapshots(),
                          builder: (context, reviewSnapshot) {
                            double avgRating = 0;
                            int reviewCount = 0;

                            if (reviewSnapshot.hasData &&
                                reviewSnapshot.data!.docs.isNotEmpty) {
                              reviewCount = reviewSnapshot.data!.docs.length;

                              final total =
                                  reviewSnapshot.data!.docs.fold<double>(
                                0,
                                (sum, doc) =>
                                    sum +
                                    ((doc.data() as Map<String, dynamic>)[
                                            'rating'] ??
                                        0),
                              );

                              avgRating = total / reviewCount;
                            }

                            if (reviewCount == 0)
                              return const SizedBox.shrink();

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: Colors.white),
                                  const SizedBox(width: 3),
                                  Text(
                                    avgRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "($reviewCount)",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VendorProfilePage(
                                vendor: vendor,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} // ✅ SubmitReviewPage — MUST be above VendorProfilePage if in the same file
// ✅ SubmitReviewPage — MUST be above VendorProfilePage if in the same file

class SubmitReviewPage extends StatefulWidget {
  final String vendorId;
  final String serviceName;
  final String vendorName;

  const SubmitReviewPage({
    super.key,
    required this.vendorId,
    required this.serviceName,
    required this.vendorName,
  });

  @override
  State<SubmitReviewPage> createState() => _SubmitReviewPageState();
}

class _SubmitReviewPageState extends State<SubmitReviewPage> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    final reviewText = _reviewController.text.trim();
    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final vendorRef = FirebaseFirestore.instance
          .collection('vendors')
          .doc(widget.serviceName)
          .collection('list')
          .doc(widget.vendorId);

      await vendorRef.collection('reviews').add({
        'rating': _rating,
        'review': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
        'customerName': customerName.isNotEmpty ? customerName : 'Anonymous',
        'customerLocation':
            customerLocation.isNotEmpty ? customerLocation : 'Unknown',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rate & Review")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              "Vendor: ${widget.vendorName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Your Rating:", style: TextStyle(fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text("Your Review:", style: TextStyle(fontSize: 16)),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Share your experience...",
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Submit Review"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ VendorProfilePage
// ✅ VendorProfilePage
class VendorProfilePage extends StatelessWidget {
  final Map<String, dynamic> vendor; // ✅ change here
  final bool isVendorLoggedIn;

  const VendorProfilePage({
    super.key,
    required this.vendor,
    this.isVendorLoggedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    final vendorOwnerId = vendor['uid'] ?? '';
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isOwnProfile = currentUserId == vendorOwnerId;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor:
              const Color.fromARGB(255, 255, 153, 51)), // strong saffron),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
                child: CircleAvatar(
                    radius: 40, child: Icon(Icons.person, size: 40))),
            const SizedBox(height: 20),
            Text('Vendor Name: ${vendor['name']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Service: ${vendor['service']}'),
            const SizedBox(height: 20),
            // ✅ ADD BADGES DISPLAY HERE
            if (vendor['badges'] != null && vendor['badges'] is List)
              Wrap(
                spacing: 6,
                children: (vendor['badges'] as List)
                    .map((badge) => Chip(
                          label: Text(badge.toString()),
                          backgroundColor: Colors.green.shade100,
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ))
                    .toList(),
              ),
            // ✅ END OF BADGES
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LocationAvailabilityPage(vendor: vendor),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 183, 102)),
                  child: const Text('Location & Availability'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final customerDoc = await FirebaseFirestore.instance
                        .collection('customers')
                        .doc(user.uid)
                        .get();

                    if (customerDoc.exists) {
                      // ✅ Customer → full reviews page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewsPage(
                            vendorId: vendor['uid'],
                            vendorName: vendor['name'] ?? "Vendor",
                            isCustomer: true,
                          ),
                        ),
                      );
                    } else {
                      // ✅ Vendor → read-only reviews page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReadOnlyReviewsPage(
                            vendorId: vendor['uid'],
                            vendorName: vendor['name'] ?? "Vendor",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Ratings & Reviews"),
                ),
                if (!isOwnProfile)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chat),
                        tooltip: 'Chat with vendor',
                        onPressed: () {
                          final chatId =
                              generateChatId(currentUserId, vendorOwnerId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chatId,
                                senderId:
                                    currentUserId, // 👈 logged-in customer
                                peerId:
                                    vendorOwnerId, // 👈 vendor you are chatting with
                                peerName: vendor['name'] ??
                                    'Vendor', // 👈 vendor's display nam
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, size: 30),
                        tooltip: 'Call vendor',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CallVendorPage(vendorId: vendorOwnerId),
                            ),
                          );
                        },
                      ),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String generateChatId(String user1, String user2) {
  final sortedIds = [user1, user2]..sort();
  return '${sortedIds[0]}_${sortedIds[1]}';
}

//call vendor
class CallVendorPage extends StatelessWidget {
  final String vendorId;

  const CallVendorPage({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Phone Number'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('vendors')
            .doc(vendorId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Vendor not found'));
          }

          final vendorData = snapshot.data!.data() as Map<String, dynamic>;
          final phone = vendorData['phone'] ?? '';

          if (phone.isEmpty) {
            return const Center(child: Text('Phone number not available'));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Phone number: $phone',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final Uri uri = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch call')),
                      );
                    }
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//vendors reviews  page

class ReadOnlyReviewsPage extends StatefulWidget {
  final String vendorId;
  final String vendorName;

  const ReadOnlyReviewsPage({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  State<ReadOnlyReviewsPage> createState() =>
      _ReadOnlyReviewsPageState(); // ✅ added
}

class _ReadOnlyReviewsPageState extends State<ReadOnlyReviewsPage> {
  List<DocumentSnapshot> reviewsDocs = []; // ✅ Infinite scroll
  bool isLoadingMore = false; // ✅ Infinite scroll
  bool isLoadingInitial = true; // ✅ Infinite scroll
  DocumentSnapshot? lastDoc; // ✅ Infinite scroll
  late ScrollController _scrollController; // ✅ Infinite scroll

  @override
  void initState() {
    // ✅ Infinite scroll
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !isLoadingMore) {
        _loadMoreReviews();
      }
    });
    _fetchInitialReviews();
  }

  Future<void> _fetchInitialReviews() async {
    // ✅ Infinite scroll
    final snapshot = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.vendorId)
        .collection('reviews')
        .orderBy("timestamp", descending: true)
        .limit(20)
        .get();

    setState(() {
      reviewsDocs = snapshot.docs;
      if (snapshot.docs.isNotEmpty) lastDoc = snapshot.docs.last;
      isLoadingInitial = false;
    });
  }

  Future<void> _loadMoreReviews() async {
    // ✅ Infinite scroll
    if (lastDoc == null) return;
    setState(() => isLoadingMore = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.vendorId)
        .collection('reviews')
        .orderBy("timestamp", descending: true)
        .startAfterDocument(lastDoc!)
        .limit(20)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        reviewsDocs.addAll(snapshot.docs);
        lastDoc = snapshot.docs.last;
      });
    }
    setState(() => isLoadingMore = false);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ratings & Reviews - vendorName"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vendors') // ✅ NEW (was 'reviews')
            .doc(widget.vendorId) // ✅ NEW (added vendor doc)
            .collection('reviews') // ✅ NEW (subcollection)
            .orderBy("timestamp", descending: true) // ✅ NEW
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No reviews yet."));
          }

          final reviews = snapshot.data!.docs;

          // ✅ Calculate average rating
          double avgRating = 0;
          for (var r in reviews) {
            final data = r.data() as Map<String, dynamic>;
            avgRating += (data['rating'] ?? 0).toDouble();
          }
          avgRating = avgRating / reviews.length;

          return Column(
            children: [
              // ✅ Average Rating UI
              Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Average Rating",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < avgRating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${avgRating.toStringAsFixed(1)} / 5.0 (${reviews.length} reviews)",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review =
                        reviews[index].data() as Map<String, dynamic>;
                    final reviewer = review['userName'] ??
                        "Anonymous"; // ✅ NEW (was reviewerName)
                    final rating = review['rating'] ?? 0;
                    final comment = review['review'] ?? "";
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(reviewer,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(comment),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//LOCATION AVAILABILITY

class LocationAvailabilityPage extends StatelessWidget {
  final Map<String, dynamic> vendor;
  const LocationAvailabilityPage({super.key, required this.vendor});

  Future<void> _openInGoogleMaps(String address) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map for $address';
    }
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value != null && value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = vendor['address'] ?? vendor['fullAddress'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location & Availability'),
        backgroundColor: const Color.fromARGB(255, 255, 183, 102),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoRow('Area', vendor['area']),
          GestureDetector(
            onTap: () {
              if (address != null && address.isNotEmpty) {
                _openInGoogleMaps(address);
              }
            },
            child: _infoRow(
              'Full Address',
              address,
            ),
          ),
          _infoRow('Available Days', vendor['availableDays']),
          _infoRow(
              'General Timing', vendor['timing'] ?? vendor['generalTiming']),
          _infoRow('Special Timing', vendor['specialTiming']),
        ]),
      ),
    );
  }
}

/// ✅ 11. RATINGS & REVIEWS PAGE
/// ✅ 11. RATINGS & REVIEWS PAGE
class ReviewsPage extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final bool isCustomer;

  const ReviewsPage({
    super.key,
    required this.vendorId,
    required this.vendorName,
    required this.isCustomer,
  });

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final TextEditingController _reviewController = TextEditingController();
  int _selectedStars = 0;

  List<DocumentSnapshot> reviewsDocs = [];
  bool isLoadingMore = false;
  bool isLoadingInitial = true;
  DocumentSnapshot? lastDoc;
  late ScrollController _scrollController;

  double avgRating = 0.0;
  int reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !isLoadingMore) {
        _loadMoreReviews();
      }
    });
    _fetchInitialReviews();
  }

  Future<void> _fetchInitialReviews() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("vendors")
          .doc(widget.vendorId)
          .collection("reviews")
          .orderBy("timestamp", descending: true)
          .limit(20)
          .get();

      _calculateAverage(snapshot.docs);

      setState(() {
        reviewsDocs = snapshot.docs;
        if (snapshot.docs.isNotEmpty) {
          lastDoc = snapshot.docs.last;
        }
        isLoadingInitial = false;
      });
    } catch (e) {
      setState(() => isLoadingInitial = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _calculateAverage(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) {
      setState(() {
        avgRating = 0;
        reviewCount = 0;
      });
      return;
    }

    double total = 0;
    for (var doc in docs) {
      total += (doc['rating'] ?? 0);
    }
    setState(() {
      avgRating = total / docs.length;
      reviewCount = docs.length;
    });
  }

  Future<void> _loadMoreReviews() async {
    if (lastDoc == null) return;
    setState(() => isLoadingMore = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("vendors")
          .doc(widget.vendorId)
          .collection("reviews")
          .orderBy("timestamp", descending: true)
          .startAfterDocument(lastDoc!)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        reviewsDocs.addAll(snapshot.docs);
        lastDoc = snapshot.docs.last;
        _calculateAverage(reviewsDocs); // recalc avg with all loaded reviews
      }
      setState(() => isLoadingMore = false);
    } catch (e) {
      setState(() => isLoadingMore = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load more: $e")));
    }
  }

  Future<void> _submitReview() async {
    if (_selectedStars == 0 || _reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please give stars and write a review")));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FocusScope.of(context).unfocus();

    final reviewData = {
      "userId": user.uid,
      "userName": user.email ?? "Anonymous",
      "rating": _selectedStars,
      "review": _reviewController.text.trim(),
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      final vendorRef =
          FirebaseFirestore.instance.collection("vendors").doc(widget.vendorId);

      setState(() {
        _reviewController.clear();
        _selectedStars = 0;
      });

      final newReviewRef =
          await vendorRef.collection("reviews").add(reviewData);

      final newSnapshot = await newReviewRef.get();
      setState(() {
        reviewsDocs.insert(0, newSnapshot);
        _calculateAverage(reviewsDocs);
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to submit review: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ratings & Reviews - ${widget.vendorName}"),
        backgroundColor: const Color.fromARGB(255, 255, 204, 153),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoadingInitial
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    "⭐ ${avgRating.toStringAsFixed(1)}  ($reviewCount reviews)",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 16),
            if (widget.isCustomer) ...[
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_selectedStars == index + 1) {
                          _selectedStars = 0;
                        } else {
                          _selectedStars = index + 1;
                        }
                      });
                    },
                  );
                }),
              ),
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  hintText: "Write your review...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 204, 153),
                  foregroundColor: Colors.black,
                ),
                child: const Text("Submit Review"),
              ),
              const Divider(height: 30),
            ],
            Expanded(
              child: reviewsDocs.isEmpty
                  ? const Center(child: Text("No reviews yet"))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: reviewsDocs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == reviewsDocs.length) {
                          return isLoadingMore
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : const SizedBox();
                        }
                        final data =
                            reviewsDocs[index].data() as Map<String, dynamic>;
                        final time = data["timestamp"] != null
                            ? DateFormat("dd MMM yyyy, hh:mm a").format(
                                (data["timestamp"] as Timestamp).toDate())
                            : "Just now";
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              data["userName"] ?? "Anonymous",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < ((data["rating"] ?? 0) as int)
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(data["review"] ?? ""),
                                const SizedBox(height: 4),
                                Text(
                                  time,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

//favourites page
class FavoritesPage extends StatelessWidget {
  final String userId;
  final bool isVendor;
  const FavoritesPage({Key? key, required this.userId, required this.isVendor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites ❤️"),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("favorites")
            .doc(userId)
            .collection("vendors")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No favorites yet"));
          }

          final favs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, index) {
              final fav = favs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: Text(fav["name"] ?? "Unknown"),
                subtitle: Text(fav["category"] ?? ""),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------- Post a Need (Customer or Vendor) --------------------
class PostNeedPage extends StatefulWidget {
  final bool isCustomer;
  final String? customerName;

  const PostNeedPage({
    super.key,
    required this.isCustomer,
    this.customerName,
  });

  @override
  State<PostNeedPage> createState() => _PostNeedPageState();
}

class _PostNeedPageState extends State<PostNeedPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  final timeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    locationController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> _postNeed() async {
    final user = FirebaseAuth.instance.currentUser;

    if (!widget.isCustomer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only customers can post needs.')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ generate docRef with id
      final docRef = FirebaseFirestore.instance.collection('needs').doc();

      await docRef.set({
        'docId': docRef.id,
        'userId': user.uid,
        'customerId': user.uid,
        'customerName': widget.customerName ?? 'Unknown',
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'location': locationController.text.trim(),
        'time': timeController.text.trim(),
        'postedBy': widget.customerName ?? 'Unknown',
        'isAccepted': false,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ✅ Instead of showing snackbar here, pop FIRST
      if (mounted) {
        Navigator.pop(context, true); // return success flag
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCustomer ? 'Post a Need' : 'Post a Service'),
        backgroundColor: const Color.fromARGB(255, 255, 153, 51),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description')),
            TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location')),
            TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time')),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _postNeed,
                    child: const Text('Post Need'),
                  ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Available Needs (Vendor) --------------------
class AvailableNeedsPage extends StatefulWidget {
  final String vendorId; // vendor's UID

  const AvailableNeedsPage({super.key, required this.vendorId});

  @override
  State<AvailableNeedsPage> createState() => _AvailableNeedsPageState();
}

class _AvailableNeedsPageState extends State<AvailableNeedsPage> {
  // Get Firestore stream of needs
  Stream<QuerySnapshot> getAvailableNeeds() {
    final now = DateTime.now();
    final sixHoursAgo =
        Timestamp.fromDate(now.subtract(const Duration(hours: 6)));

    return FirebaseFirestore.instance
        .collection('needs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Accept need + notify customer
  Future<void> acceptNeed(
      String docId, String customerId, String needTitle) async {
    try {
      await FirebaseFirestore.instance.collection('needs').doc(docId).update({
        'status': 'vendor_accepted', // ✅ CHANGED from 'accepted'
        'acceptedBy': widget.vendorId,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // ✅ ADDED: Store notification for customer with confirmNeeded
      await FirebaseFirestore.instance.collection('Notifications').add({
        'toUserId': customerId,
        'fromUserId': widget.vendorId,
        'needId': docId,
        'message': "Vendor accepted your need \"$needTitle\". Confirm?",
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'confirmNeeded': true, // ✅ ADDED
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Need accepted & customer notified")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    }
  }

  // Launch phone call
  Future<void> callNumber(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Needs'),
        backgroundColor: const Color.fromARGB(255, 255, 153, 51),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAvailableNeeds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No available needs'));
          }

          final now = DateTime.now();
          final needs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Hide if accepted for more than 6 hours
            if (data['status'] == 'accepted' && data['acceptedAt'] != null) {
              final acceptedAt = (data['acceptedAt'] as Timestamp).toDate();
              if (now.difference(acceptedAt).inHours >= 6) {
                return false;
              }
            }

            return data['status'] == 'pending' ||
                data['status'] ==
                    'vendor_accepted' || // ✅ ADDED vendor_accepted
                data['status'] == 'accepted';
          }).toList();

          if (needs.isEmpty) {
            return const Center(child: Text('No available needs'));
          }

          return ListView.builder(
            itemCount: needs.length,
            itemBuilder: (context, index) {
              final doc = needs[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Untitled';
              final desc = data['description'] ?? '';
              final location = data['location'] ?? '';
              final time = data['time'] ?? '';
              final phone = data['phone'] ?? '';
              final status = data['status'] ?? 'pending';
              final postedAt = (data['timestamp'] as Timestamp?)?.toDate();
              final postedAtStr = postedAt != null
                  ? DateFormat('dd MMM yyyy hh:mm a').format(postedAt)
                  : 'Unknown';

              final customerId = data['customerId'];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📌 $title",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("📝 $desc"),
                      Text("⏰ $time"),
                      Text("📍 $location"),
                      Text("📅 Posted: $postedAtStr"),
                      Text(
                        "Status: ${status == 'vendor_accepted' ? "PENDING CONFIRMATION" : status.toUpperCase()}", // ✅ ADDED friendly label
                        style: TextStyle(
                          color: status == 'pending'
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.call),
                            label: const Text('Call'),
                            onPressed: phone.isNotEmpty
                                ? () => callNumber(phone)
                                : null,
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.chat),
                            label: const Text('Chat'),
                            onPressed: () {
                              final needId = doc.id;
                              final customerName =
                                  data['customerName'] ?? "Customer";
                              final needTitle = data['title'] ?? "";
                              final chatId =
                                  getChatId(widget.vendorId, customerId);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chatId: chatId,
                                    senderId: widget.vendorId,
                                    peerName: "$customerName – $needTitle",
                                    peerId: data['customerId'],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (status == 'pending')
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('Accept'),
                              onPressed: () =>
                                  acceptNeed(doc.id, customerId, title),
                            ),
                        ],
                      ),
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

  String getChatId(String u1, String u2) {
    return (u1.compareTo(u2) < 0) ? '${u1}$u2' : '${u2}$u1';
  }
}
//notifications page when accept needs

//notifications page when accept needs

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Notifications"),
          backgroundColor: Colors.orange,
        ),
        body: const Center(child: Text("Please log in to see notifications.")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Notifications")
            .where("toUserId", isEqualTo: uid) // ✅ show only MY notifications
            // no orderBy → avoid composite-index requirement
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Notifications"));
          }

          // copy and sort DESC by timestamp in memory
          final notifications = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final ta = (a.data() as Map<String, dynamic>)["timestamp"];
              final tb = (b.data() as Map<String, dynamic>)["timestamp"];
              if (ta == null && tb == null) return 0;
              if (ta == null) return 1; // nulls last
              if (tb == null) return -1;
              return (tb as Timestamp).compareTo(ta as Timestamp);
            });

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;

              final vendorId = data["fromUserId"]; // vendor who accepted
              final needId = data["needId"]; // need doc id
              final message = (data["message"] ?? "") as String;
              final title = (data["title"] ?? "Need update") as String;
              final ts = data["timestamp"] as Timestamp?;
              final timeText = ts != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                          ts.millisecondsSinceEpoch)
                      .toString()
                      .substring(0, 16)
                  : "";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.notifications, color: Colors.orange),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message),

                      // ✅ Customer confirmation UI (only if needed)
                      if (data["confirmNeeded"] == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: const Text(
                                "Confirm",
                                style: TextStyle(color: Colors.green),
                              ),
                              onPressed: () async {
                                if (needId == null) return;

                                // finalize acceptance
                                await FirebaseFirestore.instance
                                    .collection("needs")
                                    .doc(needId)
                                    .update({
                                  "status": "accepted",
                                });

                                // mark notification as resolved
                                await FirebaseFirestore.instance
                                    .collection("Notifications")
                                    .doc(doc.id)
                                    .update({
                                  "confirmNeeded": false,
                                  "message": "You confirmed this vendor ✅",
                                });
                              },
                            ),
                            TextButton(
                              child: const Text(
                                "Reject",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                if (needId == null) return;

                                // revert acceptance
                                await FirebaseFirestore.instance
                                    .collection("needs")
                                    .doc(needId)
                                    .update({
                                  "status": "pending",
                                  "acceptedBy": null,
                                  "acceptedAt": null,
                                });

                                // mark notification as resolved
                                await FirebaseFirestore.instance
                                    .collection("Notifications")
                                    .doc(doc.id)
                                    .update({
                                  "confirmNeeded": false,
                                  "message": "You rejected this vendor ❌",
                                });
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                        ),
                        onPressed: vendorId == null
                            ? null
                            : () async {
                                // fetch vendor and open profile
                                final vendorSnap = await FirebaseFirestore
                                    .instance
                                    .collection("vendors")
                                    .doc(vendorId)
                                    .get();

                                if (!vendorSnap.exists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Vendor not found")),
                                  );
                                  return;
                                }

                                final vendorData =
                                    vendorSnap.data() as Map<String, dynamic>;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VendorProfilePage(
                                      vendor: {
                                        ...vendorData,
                                        "vendorId": vendorId,
                                        "docId": vendorSnap.id,
                                      },
                                      isVendorLoggedIn: false,
                                    ),
                                  ),
                                );
                              },
                        child: const Text(
                          "Profile",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      if (timeText.isNotEmpty)
                        Text(timeText, style: const TextStyle(fontSize: 10)),
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
}

// 🔐 Firebase Authentication: Sign Up
Future<String?> signUpWithEmail(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return null; // Success
  } on FirebaseAuthException catch (e) {
    return e.message; // Error
  }
}

// 🔐 Firebase Authentication: Sign In
Future<String?> signInWithEmail(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return null;
  } on FirebaseAuthException catch (e) {
    return e.message;
  }
}

// 👤 Save Vendor/Customer Data to Firestore
Future<void> saveUserData(
    String uid, Map<String, dynamic> data, bool isVendor) async {
  final collection = isVendor ? 'vendors' : 'users';
  await FirebaseFirestore.instance.collection(collection).doc(uid).set(data);
}

// 🧾 Add Review to Vendor's Profile
Future<void> addReview(
    String vendorId, String reviewText, String customerName) async {
  await FirebaseFirestore.instance
      .collection('vendors')
      .doc(vendorId)
      .collection('reviews')
      .add({
    'text': reviewText,
    'by': customerName,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

// 💬 Send Chat Message
Future<void> sendMessage(String chatId, String senderId, String message) async {
  await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add({
    'senderId': senderId,
    'text': message,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

// 📂 Upload Image to Firebase Storage
Future<String> uploadImage(File file, String folderName) async {
  final ref =
      FirebaseStorage.instance.ref().child('$folderName/${DateTime.now()}.jpg');
  await ref.putFile(file);
  return await ref.getDownloadURL();
}

// 🖼 Pick Image from Gallery
//Future<File?> pickImage() async {
  //final picker = ImagePicker();
 // final pickedFile = await picker.pickImage(source: ImageSource.gallery);
 // if (pickedFile != null) {
  //  return File(pickedFile.path);
 // }
 // return null;
//}

// 🔍 Search Vendors by Category
Future<List<Map<String, dynamic>>> fetchVendorsByCategory(
    String category) async {
  final query = await FirebaseFirestore.instance
      .collection('vendors')
      .where('service', isEqualTo: category)
      .get();
  return query.docs.map((doc) => doc.data()).toList();
}

// 🚪 Logout Current User
Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
}
//chatscreen

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String senderId;
  final String peerName;
  final String peerId; // ✅ Add peer/vendor id

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.senderId,
    required this.peerName,
    required this.peerId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false; // ⭐ Added

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() => _isTyping = false); // ⭐ Reset typing

    try {
      // 🔹 ADDED: store message in Firestore
      final msgDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': text,
        'senderId': widget.senderId,
        'receiverId': widget.peerId, // ✅ store receiver
        'timestamp': FieldValue.serverTimestamp(),
        'edited': false,
      });

      // ⭐ NEW: update lastMessage for chat overview (optional, useful for chat lists)
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .set({
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': widget.senderId,
        'receiverId': widget.peerId,
      }, SetOptions(merge: true));

      // 3️⃣ NEW: add notification for the receiver
      await FirebaseFirestore.instance.collection("Notifications").add({
        "title": "New Message",
        "message": text,
        "toUserId": widget.peerId, // receiver gets it
        "fromUserId": widget.senderId,
        "chatId": widget.chatId,
        "timestamp": FieldValue.serverTimestamp(),
        "confirmNeeded": false, // only for needs
      });
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    }
  }

  // 🔹 MODIFIED: delete only locally for user
  Future<void> _deleteMessageLocally(String messageId) async {
    // Option 1: mark a hidden field for this user instead of deleting globally
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId)
        .set({
      'deletedFor': FieldValue.arrayUnion([widget.senderId]), // ⭐ NEW
    }, SetOptions(merge: true));
  }

  // ✅ ADDED: edit message dialog remains same
  Future<void> _editMessage(String messageId, String oldText) async {
    TextEditingController editController = TextEditingController(text: oldText);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: "Update your message"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .doc(messageId)
                    .update({
                  'text': newText,
                  'edited': true, // ✅ ADDED: mark as edited
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
        backgroundColor: const Color.fromARGB(255, 255, 230, 204),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Clear Chat"),
                    content:
                        const Text("Are you sure you want to clear this chat?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Clear"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  // 🔹 MODIFIED: clear only locally by marking deletedFor
                  final msgs = await messagesRef.get();
                  for (var doc in msgs.docs) {
                    await _deleteMessageLocally(doc.id);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Chat cleared locally")),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text("Clear Chat"),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final messageId = messages[index].id;
                    final isMe = msg['senderId'] == widget.senderId;

                    // ⭐ NEW: skip if message deleted for this user
                    if ((msg['deletedFor'] ?? []).contains(widget.senderId)) {
                      return const SizedBox.shrink();
                    }

                    final timestamp = msg['timestamp'] != null
                        ? (msg['timestamp'] as Timestamp).toDate()
                        : null;
                    final canEdit = isMe &&
                        timestamp != null &&
                        DateTime.now().difference(timestamp).inMinutes < 20;

                    return GestureDetector(
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.copy),
                                title: const Text("Copy"),
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: msg['text']));
                                  Navigator.pop(context);
                                },
                              ),
                              if (canEdit)
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text("Edit"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _editMessage(messageId, msg['text']);
                                  },
                                ),
                              // 🔹 MODIFIED: delete only locally
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text("Delete"),
                                onTap: () {
                                  _deleteMessageLocally(messageId);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFFDCF8C6)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                  )
                                ],
                              ),
                              child: Text(
                                msg['text'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            if (timestamp != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, right: 4),
                                child: Text(
                                  "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[600]),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF075E54)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔁 Language getter function
String tr(BuildContext context, String key) {
  final langCode =
      Provider.of<LanguageProvider>(context).currentLocale.languageCode;
  return localizedStrings[langCode]?[key] ?? key;
}

//THANKYOU PAGE FOR INVITE FRIENDS BUTTON
class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanks for Sharing!'),
        backgroundColor: Color.fromARGB(255, 255, 183, 102),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.favorite, color: Colors.pink, size: 80),
              SizedBox(height: 20),
              Text(
                'You just helped someone discover a great local service! 💖\n\nThank you for supporting small businesses!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//ANIMATION TO APP BUTTONS
class AnimatedAppButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const AnimatedAppButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  _AnimatedAppButtonState createState() => _AnimatedAppButtonState();
}

class _AnimatedAppButtonState extends State<AnimatedAppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

//INTRO PAGE
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 153, 51),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(_createSmoothRoute(const SecondSlide()));
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const PersistentAnimatedGlowBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Vendor Icon added here with animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Icon(
                      Icons.storefront, // vendor/shop icon
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildGradientTitle(
                        "Welcome to VR Local! - Trusted local services"),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildGradientSubtitle(
                      "#Verified vendors   #Real reviews   #Safe services"),
                ),
                const SizedBox(height: 20),
                _buildDots(0, context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecondSlide extends StatelessWidget {
  const SecondSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 153, 51),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(_createSmoothRoute(const IntroPage()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(_createSmoothRoute(const ThirdSlide()));
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const PersistentAnimatedGlowBackground(),
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)), // slide up
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0.8, end: 1.2),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: 1 + 0.1 * (scale - 1),
                        child: const Icon(
                          Icons.search,
                          size: 70,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildGradientTitle("Find & Connect in Seconds"),
                  const SizedBox(height: 10),
                  _buildGradientSubtitle(
                      "Search, chat or call — book a trusted local helper in seconds"),
                  const SizedBox(height: 20),
                  _buildDots(1, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThirdSlide extends StatelessWidget {
  const ThirdSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 153, 51),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(_createSmoothRoute(const SecondSlide()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(_createSmoothRoute(const FourthSlide()));
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const PersistentAnimatedGlowBackground(),
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)), // slide up
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.groups, // 👥 Community icon
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  _buildGradientTitle("Support Your Community"),
                  const SizedBox(height: 10),
                  _buildGradientSubtitle(
                    "Discover women-led & home businesses nearby",
                  ),
                  const SizedBox(height: 20),
                  _buildDots(2, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FourthSlide extends StatelessWidget {
  const FourthSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 153, 51),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(_createSmoothRoute(const ThirdSlide()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(_createSmoothRoute(const FifthSlide()));
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const PersistentAnimatedGlowBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, size: 60, color: Colors.white),
                const SizedBox(height: 15),
                _buildGradientTitle("Simple Scheduling & Reminders"),
                const SizedBox(height: 10),
                _buildGradientSubtitle(
                    "Schedule appointments easily and get automatic reminders."),
                const SizedBox(height: 20),
                _buildDots(4, context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FifthSlide extends StatelessWidget {
  const FifthSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 153, 51),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(_createSmoothRoute(const FourthSlide()));
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const PersistentAnimatedGlowBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.compare_arrows, size: 60, color: Colors.white),
                const SizedBox(height: 15),
                _buildGradientTitle("Compare & Choose Your Vendor"),
                const SizedBox(height: 10),
                _buildGradientSubtitle(
                    "Check prices, nearby locations, ratings, and reviews — pick the best for you."),
                const SizedBox(height: 20),
                _buildDots(5, context),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WelcomeOptionsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Start"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== CUSTOM TITLE/SUBTITLE BUILDERS =====
Widget _buildGradientTitle(String text) {
  return ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)], // Gold to deep orange
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(offset: Offset(0, 2), blurRadius: 6, color: Colors.black38),
          Shadow(
              offset: Offset(0, 0), blurRadius: 12, color: Colors.orangeAccent),
        ],
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _buildGradientSubtitle(String text) {
  return ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [Colors.white, Color(0xFFFFE0B2)], // White to light peach
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(bounds),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        shadows: [
          Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black26),
        ],
      ),
      textAlign: TextAlign.center,
    ),
  );
}

// ===== DOTS WIDGET =====
Widget _buildDots(int activeIndex, BuildContext context) {
  const total = 5;
  final pages = [
    const IntroPage(),
    const SecondSlide(),
    const ThirdSlide(),
    const FourthSlide(),
    const FifthSlide(),
  ];
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(total, (index) {
      final isActive = index == activeIndex;
      return GestureDetector(
        onTap: () {
          if (index != activeIndex) {
            Navigator.of(context)
                .pushReplacement(_createSmoothRoute(pages[index]));
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange])
                : const LinearGradient(colors: [Colors.grey, Colors.grey]),
            shape: BoxShape.circle,
          ),
        ),
      );
    }),
  );
}

// ===== FADE-IN SAME-PAGE TRANSITION =====
Route _createSmoothRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

// ===== PERSISTENT ANIMATED GLOW BACKGROUND =====
class PersistentAnimatedGlowBackground extends StatefulWidget {
  const PersistentAnimatedGlowBackground({super.key});

  @override
  State<PersistentAnimatedGlowBackground> createState() =>
      _PersistentAnimatedGlowBackgroundState();
}

class _PersistentAnimatedGlowBackgroundState
    extends State<PersistentAnimatedGlowBackground>
    with SingleTickerProviderStateMixin {
  static late final AnimationController _controller;
  static bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (!_initialized) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
      )..repeat(reverse: true);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale = 1 + (_controller.value * 0.2);
        return Center(
          child: Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
              ),
              width: MediaQuery.of(context).size.width * 1.5,
              height: MediaQuery.of(context).size.width * 1.5,
            ),
          ),
        );
      },
    );
  }
}

//ADMIN PAGE
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String adminEmail = "rishithareddy1@gmail.com"; // ✅ Your admin email
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  void _checkAdmin() {
    final user = _auth.currentUser;
    if (user != null && user.email == adminEmail) {
      setState(() => isAdmin = true);
    }
  }

  Stream<int> _getCount(String collection) {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snap) => snap.size);
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text("Unauthorized")),
        body:
            const Center(child: Text("You are not allowed to view this page.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.deepPurple.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ✅ Clickable cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            FirestoreListPage(collection: "vendors")),
                  ),
                  child: _buildCountCard(
                      "Vendors", _getCount("vendors"), Icons.store),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            FirestoreListPage(collection: "customers")),
                  ),
                  child: _buildCountCard(
                      "Customers", _getCount("customers"), Icons.people),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FirestoreListPage(collection: "needs")),
                  ),
                  child: _buildCountCard(
                      "Needs", _getCount("needs"), Icons.list_alt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(String title, Stream<int> countStream, IconData icon) {
    return StreamBuilder<int>(
      stream: countStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: Colors.deepPurple.shade50,
          child: Container(
            width: 110,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, size: 30, color: Colors.deepPurple),
                const SizedBox(height: 8),
                Text(
                  snapshot.data.toString(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(title,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ✅ Generic List Page with Pagination
class FirestoreListPage extends StatefulWidget {
  final String collection;
  const FirestoreListPage({super.key, required this.collection});

  @override
  State<FirestoreListPage> createState() => _FirestoreListPageState();
}

class _FirestoreListPageState extends State<FirestoreListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int _limit = 10;
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _docs = [];

  @override
  void initState() {
    super.initState();
    _fetchDocs();
  }

  Future<void> _fetchDocs() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    Query query = _firestore.collection(widget.collection).limit(_limit);
    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _docs.addAll(snapshot.docs);
    }
    if (snapshot.docs.length < _limit) {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("${widget.collection} List")),
        // 🔄 CHANGED: switched from one-time ListView on _docs to real-time StreamBuilder
        body: StreamBuilder<QuerySnapshot>(
            // 🔄 CHANGED
            stream: _firestore
                .collection(widget.collection)
                .snapshots(), // 🔄 CHANGED
            builder: (context, snapshot) {
              // 🔄 CHANGED
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 🔄 CHANGED
                return const Center(
                    child: CircularProgressIndicator()); // 🔄 CHANGED
              } // 🔄 CHANGED
              if (!snapshot.hasData) {
                // 🔄 CHANGED
                return const Center(
                    child: CircularProgressIndicator()); // 🔄 CHANGED
              } // 🔄 CHANGED
              final docs = snapshot.data!.docs; // 🔄 CHANGED
              if (docs.isEmpty) {
                // 🔄 CHANGED
                return const Center(child: Text("No more data")); // 🔄 CHANGED
              } // 🔄 CHANGED
              return ListView.builder(
                // 🔄 CHANGED
                itemCount: docs.length, // 🔄 CHANGED
                itemBuilder: (context, index) {
                  // 🔄 CHANGED
                  final doc = docs[index]; // 🔄 CHANGED
                  final data = doc.data() as Map<String, dynamic>; // 🔄 CHANGED

                  // ✅ Helpers
                  String _fmtTime(DateTime dt) {
                    final h = dt.hour.toString().padLeft(2, '0');
                    final m = dt.minute.toString().padLeft(2, '0');
                    return "$h:$m";
                  }

                  final isDeleted = data["deleted"] == true;
                  DateTime? _blockedUntil;
                  if (data["blockedUntil"] is Timestamp) {
                    _blockedUntil =
                        (data["blockedUntil"] as Timestamp).toDate();
                  } else if (data["blockedUntil"] is DateTime) {
                    _blockedUntil = data["blockedUntil"] as DateTime;
                  } else {
                    _blockedUntil = null;
                  }
                  final bool isBlocked = _blockedUntil != null &&
                      _blockedUntil!.isAfter(DateTime.now());

                  // ✅ Common Actions (Block/Unblock 30m, Delete-mark, Badges)
                  Widget _buildActions() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Block / Unblock (30 min OR Permanent)
                        IconButton(
                          icon: Icon(
                            isBlocked ? Icons.lock_open : Icons.lock,
                            color: isBlocked ? Colors.green : Colors.red,
                          ),
                          onPressed: () async {
                            final bool newBlock = !isBlocked;

                            if (newBlock) {
                              // ask temporary or permanent
                              final choice = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Block User"),
                                  content: const Text("Choose block type"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, "temp"),
                                      child: const Text("30 Min Block"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, "perm"),
                                      child: const Text("Permanent Block"),
                                    ),
                                  ],
                                ),
                              );

                              if (choice == "temp") {
                                final until = DateTime.now()
                                    .add(const Duration(minutes: 30));
                                await _firestore
                                    .collection(widget.collection)
                                    .doc(doc.id)
                                    .set({
                                  "blockedUntil": until,
                                }, SetOptions(merge: true));
                                setState(() {
                                  data["blockedUntil"] =
                                      Timestamp.fromDate(until);
                                });
                              } else if (choice == "perm") {
                                final until = DateTime(9999, 12, 31);
                                await _firestore
                                    .collection(widget.collection)
                                    .doc(doc.id)
                                    .set({
                                  "blockedUntil": until,
                                }, SetOptions(merge: true));
                                setState(() {
                                  data["blockedUntil"] =
                                      Timestamp.fromDate(until);
                                });
                              }
                            } else {
                              // unblock
                              await _firestore
                                  .collection(widget.collection)
                                  .doc(doc.id)
                                  .set({
                                "blockedUntil": null,
                              }, SetOptions(merge: true));
                              setState(() {
                                data["blockedUntil"] = null;
                              });
                            }
                          },
                        ),

                        // Delete (soft delete)
                        IconButton(
                          icon: Icon(
                            data["deleted"] == true
                                ? Icons.restore
                                : Icons.delete, // ✅ show Restore if deleted
                            color: data["deleted"] == true
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                          onPressed: () async {
                            if (data["deleted"] == true) {
                              // ✅ Restore flow
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Confirm Restore"),
                                  content: const Text(
                                      "Do you want to restore this vendor?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("Cancel")),
                                    ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text("Restore")),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _firestore
                                    .collection(widget.collection)
                                    .doc(doc.id)
                                    .set({
                                  "deleted": false,
                                }, SetOptions(merge: true));

                                setState(() {
                                  data["deleted"] = false;
                                });
                              }
                            } else {
                              // ✅ Delete flow
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: const Text(
                                      "Do you want to delete this vendor?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("Cancel")),
                                    ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text("Delete")),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _firestore
                                    .collection(widget.collection)
                                    .doc(doc.id)
                                    .set({
                                  "deleted": true,
                                }, SetOptions(merge: true));

                                setState(() {
                                  data["deleted"] = true;
                                });
                              }
                            }
                          },
                        ),

                        // Badges
                        IconButton(
                          icon:
                              const Icon(Icons.badge, color: Colors.deepPurple),
                          onPressed: () async {
                            final badges = [
                              "✅ Trusted",
                              "⭐ Top Rated",
                              "👩 Women-led",
                              "🎓 Student-led",
                              "👴 Elderly-led"
                            ];
                            final currentBadges =
                                List<String>.from(data["badges"] ?? []);

                            final selected = await showDialog<List<String>>(
                              context: context,
                              builder: (ctx) {
                                final tempSelected =
                                    Set<String>.from(currentBadges);
                                return StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    title: const Text("Assign Badges"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: badges.map((b) {
                                        final isSelected =
                                            tempSelected.contains(b);
                                        return CheckboxListTile(
                                          value: isSelected,
                                          title: Text(b),
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                tempSelected.add(b);
                                              } else {
                                                tempSelected.remove(b);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, null),
                                          child: const Text("Cancel")),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(
                                            ctx, tempSelected.toList()),
                                        child: const Text("Save"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (selected != null) {
                              await _firestore
                                  .collection(widget.collection)
                                  .doc(doc.id)
                                  .set({
                                "badges": selected,
                              }, SetOptions(merge: true));
                              setState(() {
                                data["badges"] = selected;
                              });
                            }
                          },
                        ),
                      ],
                    );
                  }

                  // ✅ Special format for "needs"
                  if (widget.collection == "needs") {
                    final fieldsToShow = {
                      "title": "Title",
                      "description": "Description",
                      "time": "Time",
                      "location": "Location",
                      "status": "Status",
                    };

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isBlocked ? Colors.red.shade50 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...fieldsToShow.entries.map((entry) {
                              final rawValue = data[entry.key];
                              String value;
                              if (rawValue is Timestamp) {
                                final dt = rawValue.toDate();
                                value =
                                    "${dt.day}-${dt.month}-${dt.year} ${dt.hour}:${dt.minute}";
                              } else {
                                value = rawValue?.toString() ?? "—";
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text("${entry.value}: $value",
                                    style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            if (data["badges"] != null &&
                                (data["badges"] as List).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children:
                                    (data["badges"] as List).map<Widget>((b) {
                                  final badgeColor =
                                      b.toString().contains("Trusted")
                                          ? Colors.green.shade200
                                          : b.toString().contains("Top Rated")
                                              ? Colors.amber.shade200
                                              : Colors.blue.shade200;
                                  return Chip(
                                    label: Text(b.toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    backgroundColor: badgeColor,
                                    avatar: const Icon(Icons.verified,
                                        size: 16, color: Colors.black87),
                                  );
                                }).toList(),
                              ),
                            ],
                            if (isBlocked)
                              Text(
                                  "🚫 Blocked until ${_fmtTime(_blockedUntil!)}",
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            if (isDeleted)
                              const Text("❌ Deleted",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            if (!isDeleted) _buildActions(),
                          ],
                        ),
                      ),
                    );
                  }

                  // ✅ Special format for "customers"
                  if (widget.collection == "customers") {
                    final fieldsToShow = {
                      "name": "Name",
                      "email": "Email",
                      "phone": "Phone",
                      "location": "Location",
                      "createdAt": "Joined On",
                    };

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isBlocked ? Colors.red.shade50 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...fieldsToShow.entries.map((entry) {
                              final value = data[entry.key] ?? "—";
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text("${entry.value}: $value",
                                    style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            if (data["badges"] != null &&
                                (data["badges"] as List).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children:
                                    (data["badges"] as List).map<Widget>((b) {
                                  final badgeColor =
                                      b.toString().contains("Trusted")
                                          ? Colors.green.shade200
                                          : b.toString().contains("Top Rated")
                                              ? Colors.amber.shade200
                                              : Colors.blue.shade200;
                                  return Chip(
                                    label: Text(b.toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    backgroundColor: badgeColor,
                                    avatar: const Icon(Icons.verified,
                                        size: 16, color: Colors.black87),
                                  );
                                }).toList(),
                              ),
                            ],
                            if (isBlocked)
                              Text(
                                  "🚫 Blocked until ${_fmtTime(_blockedUntil!)}",
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            if (isDeleted)
                              const Text("❌ Deleted",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            if (!isDeleted) _buildActions(),
                          ],
                        ),
                      ),
                    );
                  }

                  // ✅ Default format (vendors, etc.)
                  final fieldsToShow = {
                    "name": "Name",
                    "email": "Email",
                    "category": "Category",
                    "service": "Service",
                    "location": "Location",
                    "area": "Area",
                    "priceRange": "Price Range",
                    "generalTiming": "General Timing",
                    "specialTiming": "Special Timing",
                    "availableDays": "Available Days",
                    "fullAddress": "Full Address",
                  };

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isBlocked ? Colors.red.shade50 : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...fieldsToShow.entries.map((entry) {
                            final value = data[entry.key];
                            if (value == null || value.toString().isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text("${entry.value}: $value",
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          if (data["badges"] != null &&
                              (data["badges"] as List).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children:
                                  (data["badges"] as List).map<Widget>((b) {
                                final badgeColor =
                                    b.toString().contains("Trusted")
                                        ? Colors.green.shade200
                                        : b.toString().contains("Top Rated")
                                            ? Colors.amber.shade200
                                            : Colors.blue.shade200;
                                return Chip(
                                  label: Text(b.toString(),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  backgroundColor: badgeColor,
                                  avatar: const Icon(Icons.verified,
                                      size: 16, color: Colors.black87),
                                );
                              }).toList(),
                            ),
                          ],
                          if (isBlocked)
                            Text("🚫 Blocked until ${_fmtTime(_blockedUntil!)}",
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          if (isDeleted)
                            const Text("❌ Deleted",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                          if (!isDeleted) _buildActions(),
                        ],
                      ),
                    ),
                  );
                }, // 🔄 CHANGED
              ); // 🔄 CHANGED
            })); // 🔄 CHANGED
  }
}
