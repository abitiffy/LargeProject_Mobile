import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

const String baseUrl = 'https://cop4331group3.xyz/api/users';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/logout': (_) => const LogoutScreen(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String error = '';

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', body['token']);
      await prefs.setString('UserID', body['UserID']);
      await prefs.setString('firstName', body['firstName']);
      await prefs.setString('lastName', body['lastName']);
      await prefs.setInt('valid', body['valid']);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() => error = body['error'] ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: login, child: const Text('Login')),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Register instead')),
          if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
        ]),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String error = '';

  Future<void> register() async {
    if (passCtrl.text != confirmCtrl.text) {
      setState(() => error = 'Passwords do not match');
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstCtrl.text.trim(),
        'lastName': lastCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'password': passCtrl.text,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', body['token']);
      await prefs.setString('UserID', body['UserID']);
      await prefs.setString('firstName', body['firstName']);
      await prefs.setString('lastName', body['lastName']);
      await prefs.setInt('valid', body['valid']);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() => error = body['error'] ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: firstCtrl, decoration: const InputDecoration(labelText: 'First Name')),
          TextField(controller: lastCtrl, decoration: const InputDecoration(labelText: 'Last Name')),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          TextField(controller: confirmCtrl, decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: register, child: const Text('Register')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
          if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
        ]),
      ),
    );
  }
}

class DashboardContents extends StatefulWidget {
  const DashboardContents({super.key});

  @override
  State<DashboardContents> createState() => _DashboardContentsState();
}

class _DashboardContentsState extends State<DashboardContents> {
  String error = '';
  Map<String, dynamic>? data; // nullable to check if it's loaded
  bool isLoading = true;

  Future<void> retrieveData() async {
    try {
      final response = await http.post(
        Uri.parse('https://cop4331group3.xyz/api/activities/retrievehistory'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'UserID': '68636ea8c7cdc121c9e613ed'}),
      );



      if (response.statusCode == 200) {
        print('Raw response body: ${response.body}');
        print('Status: ${response.statusCode}');
        print('Body: "${response.body}"');
        print('Headers: ${response.headers}');
        final jsonBody = json.decode(response.body);
        setState(() {
          data = jsonBody;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Exception: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveData(); // only run once
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
            ? Text(error)
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome"),

            Text("You have ${data?['recordedDailyWorkMinutes']} minutes in work"),
            Text("You have ${data?['recordedLeisureMinutes']} minutes in leisure"),
            Text("You have ${data?['recordedSleepMinutes']} minutes in sleep"),
          ],
        ),
      ),
    );
  }
}
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardContents(),
    LeaderboardScreen(),
    SelectScreen(),
    HistoryScreen(),
    LogoutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BottomNavigationBar Sample')),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Play'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Logout'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
