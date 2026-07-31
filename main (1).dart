
import 'package:flutter/material.dart';

void main() {
  runApp(const HealSpaceApp());
}

class HealSpaceApp extends StatelessWidget {
  const HealSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealSpace',
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB8E7E1), Color(0xFFEAF6F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_rounded,size: 90,color: Color(0xFF4DB6AC)),
              SizedBox(height: 16),
              Text("HealSpace",style: TextStyle(fontSize: 34,fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.self_improvement,size: 100,color: Color(0xFF4DB6AC)),
              const SizedBox(height: 20),
              const Text("Welcome to HealSpace",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text(
                "A place where nobody feels alone.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MoodCheckScreen()),
                  );
                },
                child: const Text("Continue"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MoodCheckScreen extends StatefulWidget {
  const MoodCheckScreen({super.key});

  @override
  State<MoodCheckScreen> createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends State<MoodCheckScreen> {
  final moods = ["😊 Happy","😔 Sad","😰 Stressed","😴 Exhausted","😞 Lonely","😡 Frustrated","❤️ Loved","😌 Peaceful"];
  int selected = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("How are you feeling?")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: moods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (_, i) => Card(
                  color: selected == i ? Colors.teal : null,
                  child: InkWell(
                    onTap: ()=>setState(()=>selected=i),
                    child: Center(
                      child: Text(
                        moods[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected == i ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: selected == -1 ? null : () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                );
              },
              child: const Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    CommunityScreen(),
    AIFriendScreen(),
    VideosScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v)=>setState(()=>index=v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.groups), label: "Community"),
          NavigationDestination(icon: Icon(Icons.chat_bubble), label: "AI Friend"),
          NavigationDestination(icon: Icon(Icons.play_circle), label: "Videos"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      "🫂 AI Friend",
      "🌍 Community",
      "📖 Stories",
      "💖 KindQuest",
      "📊 Tracker",
      "🧘 Calm Room",
      "🚨 Emergency",
      "🏆 Success Stories"
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("HealSpace")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (_, i) => Card(
          child: Center(child: Text(cards[i], textAlign: TextAlign.center)),
        ),
      ),
    );
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text("Anonymous Community")));
}

class AIFriendScreen extends StatelessWidget {
  const AIFriendScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text("AI Friend Chat")));
}

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text("Motivational Videos")));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text("Profile")));
}
