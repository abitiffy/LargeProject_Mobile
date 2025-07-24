import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
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
        brightness: Brightness.light,
        useMaterial3: true,

        // Primary branding color
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF0B0E2A),        // Dark blue
          onPrimary: Colors.white,
          secondary: const Color(0xFFD8D7D0),      // Muted gray-beige
          onSecondary: const Color(0xFF0B0E2A),
          background: const Color(0xFFF4F0E6),     // Light cream
          onBackground: const Color(0xFF0B0E2A),
          surface: const Color(0xFFD8D7D0),
          onSurface: const Color(0xFF0B0E2A),
        ),

        scaffoldBackgroundColor: const Color(0xFFF4F0E6),

        appBarTheme: const AppBarTheme(
          foregroundColor: Color(0xFFD8D7D0),
          backgroundColor: Color(0xFF0B0E2A),
          elevation: 0,
        ),

        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0B0E2A)),
          bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF0B0E2A)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B0E2A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),

        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF0B0E2A), // Navy blue
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[400],
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/logout': (_) => const LogoutScreen(),
        '/sleep': (_) => const SleepPage(),
        '/work': (_) => const WorkScreen(),
        '/leisure': (_) => const LeisurePage(),
        '/edithistoricalrecord':(_) => const EditHistoricalRecord(),
        '/edittoday':(_) => const EditTodaysStuff(),
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
      body: Container(
        padding: const EdgeInsets.fromLTRB(20,80,20,40),
        alignment: Alignment.center,
        child: Column(children: [
          const Text(
            'LOGIN',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
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
  String? userID;

  Future<void> loadUserActivities() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('UserID');

    if (userID == null) {
      setState(() {
        error = 'User ID not found.';
        isLoading = false;
      });
      return;
    }}

  Future<void> retrieveData() async {
    try {
      loadUserActivities();
      final response = await http.post(
        Uri.parse('https://cop4331group3.xyz/api/activities/retrievehomepagedata'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'UserID': userID}),//TODO: not sure if this is gonna work
      );



      if (response.statusCode == 200) {
        //print('Raw response body: ${response.body}');
        //print('Status: ${response.statusCode}');
        //print('Body: "${response.body}"');
        //print('Headers: ${response.headers}');
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
    retrieveData();
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(20,80,20,40),
        alignment: Alignment.center,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
            ? Text(error)
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'HOME',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const Text("Welcome"),

            Text("You have ${(data?['recordedDailyWorkMinutes']?? 0).toStringAsFixed(2)} minutes in work"),
            Text("You have ${(data?['recordedDailyLeisureMinutes']?? 0).toStringAsFixed(2)} minutes in leisure"),
            Text("You have ${(data?['recordedDailySleepMinutes']?? 0).toStringAsFixed(2)} minutes in sleep"),
            Text("You have ${(data?['totalDailyPts']?? 0).toStringAsFixed(2)} points"),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/edittoday'), child: const Text("Edit today's points")),
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
    RecordPage(),
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
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items:
        const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: 'Play'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),

        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: const Color(0xFF0B0E2A),
        selectedItemColor: const Color(0xFF0B0E2A),
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF0B0E2A),
      ),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String error = '';


  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      // Replace with your actual API call
      final response = await http.post(
        Uri.parse('https://cop4331group3.xyz/api/activities/displayleaderboard'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'UserID': '687efa0963cfd7fb076a74d2'}),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        setState(() {
          users = body['users'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load leaderboard';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(20,80,20,40),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Text(
              'LEADERBOARD',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red))
              else
                Table(
                  border: TableBorder.all(color: const Color(0xffd8d7d0)),
                  columnWidths: const {
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: const Color(0xffd8d7d0)),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'First Name', textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Last Name', textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Weekly Points', textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    if (users.isEmpty)
                      const TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No leaderboard data available.',
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(),
                          SizedBox(),
                        ],
                      )
                    else
                      ...users.map<TableRow>((user) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(user['firstName'] ?? '',
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(user['lastName'] ?? '',
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  user['weeklyPts']?.toStringAsFixed(2) ?? '0',
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        );
                      }).toList()
                  ],
                ),
          ],
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
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> activities = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadUserActivities();
  }

  Future<void> loadUserActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('UserID');

    if (userID == null) {
      setState(() {
        error = 'User ID not found.';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://cop4331group3.xyz/api/activities/retrievehistory'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'UserID': userID}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          activities = data['activities'] ?? [];
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
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void handleEdit(String activityId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ActivityID', activityId);
    Navigator.pushNamed(context, '/edithistoricalrecord');
  }

  List<FlSpot> toSpots(List<num> values) {
    return values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<num> work = [];
    List<num> leisure = [];
    List<num> sleep = [];
    List<num> points = [];
    work = activities.map<num>((a) => (a['recordedDailyWorkMinutes'] ?? 0) as num).toList();
    leisure = activities.map<num>((a) => (a['recordedDailyLeisureMinutes'] ?? 0) as num).toList();
    sleep = activities.map<num>((a) => (a['recordedDailySleepMinutes'] ?? 0) as num).toList();
    points = activities.map<num>((a) => (a['totalDailyPts'] ?? 0) as num).toList();
    final labels = activities.map((a) {
      final timestamp = a['recordTimestamp'];
      if (timestamp != null) {
        final dt = DateTime.tryParse(timestamp);
        if (dt != null) return '${dt.month}/${dt.day}';
      }
      return '';
    }).toList();

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20,80,20,40),
          alignment: Alignment.center,
          child: Column(
            children: [
              const Text('ACTIVITY HISTORY', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width * 0.8,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(spots: toSpots(work), isCurved: true, color: Colors.blue, barWidth: 2, dotData: FlDotData(show: false)),
                      //LineChartBarData(spots: toSpots(leisure), isCurved: true, color: Colors.purple, barWidth: 2, dotData: FlDotData(show: false)),
                      //LineChartBarData(spots: toSpots(sleep), isCurved: true, color: Colors.green, barWidth: 2, dotData: FlDotData(show: false)),
                      //LineChartBarData(spots: toSpots(points), isCurved: true, color: Colors.orange, barWidth: 2, dotData: FlDotData(show: false)),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,//TODO: used to be true
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Text(labels[index], style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false, interval: 60),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width * 0.8,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      //LineChartBarData(spots: toSpots(work), isCurved: true, color: Colors.blue, barWidth: 2, dotData: FlDotData(show: false)),
                      LineChartBarData(spots: toSpots(leisure), isCurved: true, color: Colors.purple, barWidth: 2, dotData: FlDotData(show: false)),
                      //LineChartBarData(spots: toSpots(sleep), isCurved: true, color: Colors.green, barWidth: 2, dotData: FlDotData(show: false)),
                      //LineChartBarData(spots: toSpots(points), isCurved: true, color: Colors.orange, barWidth: 2, dotData: FlDotData(show: false)),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Text(labels[index], style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false, interval: 60),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width * 0.8,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      //LineChartBarData(spots: toSpots(work), isCurved: true, color: Colors.blue, barWidth: 2, dotData: FlDotData(show: false)),
                      //LineChartBarData(spots: toSpots(leisure), isCurved: true, color: Colors.purple, barWidth: 2, dotData: FlDotData(show: false)),
                      LineChartBarData(spots: toSpots(sleep), isCurved: true, color: Colors.green, barWidth: 2, dotData: FlDotData(show: false)),
                      //LineChartBarData(spots: toSpots(points), isCurved: true, color: Colors.orange, barWidth: 2, dotData: FlDotData(show: false)),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Text(labels[index], style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false, interval: 60),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width * 0.8,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      //LineChartBarData(spots: toSpots(work), isCurved: true, color: Colors.blue, barWidth: 2, dotData: FlDotData(show: false)),
                      //LineChartBarData(spots: toSpots(leisure), isCurved: true, color: Colors.purple, barWidth: 2, dotData: FlDotData(show: false)),
                      //LineChartBarData(spots: toSpots(sleep), isCurved: true, color: Colors.green, barWidth: 2, dotData: FlDotData(show: false)),
                      LineChartBarData(spots: toSpots(points), isCurved: true, color: Colors.orange, barWidth: 2, dotData: FlDotData(show: false)),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Text(labels[index], style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false, interval: 60),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Daily Activity Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(color: const Color(0xffd8d7d0)),
                columnWidths: const {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(),
                  5: FixedColumnWidth(80),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: const Color(0xffd8d7d0)),
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('Date', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('Work', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('Leisure', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('Sleep', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('Pts', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('Edit', textAlign: TextAlign.center)),
                    ],
                  ),
                  if (activities.isEmpty)
                    const TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('No history data available.', textAlign: TextAlign.center),
                      ),
                      SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox(),
                    ])
                  else
                    ...activities.map((activity) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(activity['recordTimestamp'] ?? '', textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('${(activity['recordedDailyWorkMinutes'] ?? 0).toStringAsFixed(2)}', textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('${(activity['recordedDailyLeisureMinutes'] ?? 0).toStringAsFixed(2)}', textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('${(activity['recordedDailySleepMinutes'] ?? 0).toStringAsFixed(2)}', textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('${(activity['totalDailyPts'] ?? 0).toStringAsFixed(2)}', textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () => handleEdit(activity['_id']),
                              child: const Icon(Icons.edit),
                            ),
                          ),
                        ],
                      );
                    }).toList()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'CHOOSE YOUR ACTIVITY',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 16,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sleep');
                    },
                    child: const Text('SLEEP'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/work');
                    },
                    child: const Text('WORK'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/leisure');
                    },
                    child: const Text('LEISURE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  int timer = 0;
  Timer? timeInterval;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("UserID");
    });
  }

  void startTimer() {
    timeInterval?.cancel(); // Prevent multiple intervals
    timeInterval = Timer.periodic(const Duration(seconds: 1), (timerTick) {
      setState(() {
        timer++;
      });
    });
  }

  void pauseTimer() {
    timeInterval?.cancel();
  }

  void resetTimer() {
    timeInterval?.cancel();
    setState(() {
      timer = 0;
    });
  }

  Future<void> endTimer() async {
    if (userId == null) return;

    final response = await http.post(
      Uri.parse("https://cop4331group3.xyz/api/activities/timerupdateforday"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "UserID": userId,
        "timerTime": timer / 60,
        "timerType": "Sleep",
      }),
    );

    if (response.statusCode != 200) {
      debugPrint("Failed to submit sleep timer");
    }
  }

  @override
  void dispose() {
    timeInterval?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Sleep Timer", style: TextStyle(fontSize: 32)),
              const SizedBox(height: 16),
              Text(
                "$timer seconds",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: startTimer,
                    child: const Text("Start"),
                  ),
                  ElevatedButton(
                    onPressed: pauseTimer,
                    child: const Text("Pause"),
                  ),
                  ElevatedButton(
                    onPressed: resetTimer,
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: endTimer,
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  int timer = 0;
  Timer? timeInterval;
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('UserID');
    });
  }

  void startTimer() {
    timeInterval = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        timer++;
      });
    });
  }

  void pauseTimer() {
    timeInterval?.cancel();
  }

  void resetTimer() {
    pauseTimer();
    setState(() {
      timer = 0;
    });
  }

  Future<void> endTimer(String? userID, double timerTime, String timerType) async {
    if (userID == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://cop4331group3.xyz/api/activities/timerupdateforday'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'UserID': userID,
          'timerTime': timerTime,
          'timerType': timerType,
        }),
      );

      final result = jsonDecode(response.body);
      print("Submitted successfully: $result");
    } catch (e) {
      print('Error submitting timer: $e');
    }
  }

  @override
  void dispose() {
    timeInterval?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Work',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Timer: $timer seconds', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(onPressed: startTimer, child: const Text('Start')),
                ElevatedButton(onPressed: pauseTimer, child: const Text('Pause')),
                ElevatedButton(onPressed: resetTimer, child: const Text('Reset')),
                ElevatedButton(
                  onPressed: () => endTimer(userId, timer / 60, 'Work'),
                  child: const Text('SUBMIT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LeisurePage extends StatefulWidget {
  const LeisurePage({super.key});

  @override
  State<LeisurePage> createState() => _LeisurePageState();
}

class _LeisurePageState extends State<LeisurePage> {
  int _timer = 0;
  Timer? _timeInterval;
  String? _userID;

  @override
  void initState() {
    super.initState();
    _loadUserID();
  }

  Future<void> _loadUserID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userID = prefs.getString('UserID');
    });
  }

  void _startTimer() {
    _timeInterval?.cancel();
    _timeInterval = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timer++;
      });
    });
  }

  void _pauseTimer() {
    _timeInterval?.cancel();
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _timer = 0;
    });
  }

  Future<void> _endTimer() async {
    if (_userID == null) return;

    final response = await http.post(
      Uri.parse('https://cop4331group3.xyz/api/activities/timerupdateforday'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserID': _userID,
        'timerTime': _timer / 60,
        'timerType': 'Leisure',
      }),
    );

    if (response.statusCode != 200) {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _timeInterval?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Leisure',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'Timer: $_timer',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton(onPressed: _startTimer, child: const Text('Start')),
                  ElevatedButton(onPressed: _pauseTimer, child: const Text('Pause')),
                  ElevatedButton(onPressed: _resetTimer, child: const Text('Reset')),
                  ElevatedButton(
                    onPressed: _endTimer,
                    child: const Text('SUBMIT'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}





class EditHistoricalRecord extends StatefulWidget {
  const EditHistoricalRecord({super.key});

  @override
  State<EditHistoricalRecord> createState() => _EditHistoricalRecordState();
}

class _EditHistoricalRecordState extends State<EditHistoricalRecord> {
  final TextEditingController workController = TextEditingController();
  final TextEditingController leisureController = TextEditingController();
  final TextEditingController sleepController = TextEditingController();

  String? activityID;
  String? error;
  String? success;

  @override
  void initState() {
    super.initState();
    loadActivityID();
  }

  Future<void> loadActivityID() async {
    final prefs = await SharedPreferences.getInstance();
    final storedID = prefs.getString('ActivityID');

    if (storedID == null) {
      setState(() => error = 'No activity selected for editing.');
      return;
    }

    setState(() => activityID = storedID);
    fetchHistoricalData(storedID);
  }

  Future<void> fetchHistoricalData(String id) async {
    try {
      final res = await http.post(
        Uri.parse('https://cop4331group3.xyz/api/activities/retrievetoedithistory'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ActivityID': id}),
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP error! status: ${res.statusCode}');
      }

      final data = json.decode(res.body);
      setState(() {
        workController.text = data['recordedDailyWorkMinutes']?.toStringAsFixed(2) ?? '';
        leisureController.text = data['recordedDailyLeisureMinutes']?.toStringAsFixed(2) ?? '';
        sleepController.text = data['recordedDailySleepMinutes']?.toStringAsFixed(2) ?? '';
      });
    } catch (e) {
      setState(() => error = 'Failed to load activity data.');
    }
  }

  Future<void> handleSubmit() async {
    try {
      final res = await http.post(
        Uri.parse('https://cop4331group3.xyz/api/activities/edithistoricalcategories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ActivityID': activityID,
          'updatedWorkMinutes': workController.text,
          'updatedLeisureMinutes': leisureController.text,
          'updatedSleepMinutes': sleepController.text,
        }),
      );

      final data = json.decode(res.body);
      if (res.statusCode != 200) {
        throw Exception(data['error'] ?? 'Something went wrong');
      }

      setState(() => success = 'Successfully updated historical record!');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ActivityID');

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/history');
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Edit Historical Record',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              const Text("Work Minutes"),
              TextField(
                controller: workController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              const Text("Leisure Minutes"),
              TextField(
                controller: leisureController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              const Text("Sleep Minutes"),
              TextField(
                controller: sleepController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: handleSubmit,
                child: const Text('Submit'),
              ),

              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ),

              if (success != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(success!, style: const TextStyle(color: Colors.green)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class EditTodaysStuff extends StatefulWidget {
  const EditTodaysStuff({super.key});

  @override
  State<EditTodaysStuff> createState() => _EditTodaysStuffState();
}

class _EditTodaysStuffState extends State<EditTodaysStuff> {
  String? error;
  String? success;

  TextEditingController workController = TextEditingController();
  TextEditingController leisureController = TextEditingController();
  TextEditingController sleepController = TextEditingController();

  String? userID;

  @override
  void initState() {
    super.initState();
    _loadUserIDAndFetchData();
  }

  Future<void> _loadUserIDAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('UserID');
    if (userID != null) {
      _fetchTodayFields();
    } else {
      setState(() => error = "No user ID found.");
    }
  }

  Future<void> _fetchTodayFields() async {
    try {
      final res = await http.post(
        Uri.parse("https://cop4331group3.xyz/api/activities/retrievetodayeditfields"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"UserID": userID}),
      );

      if (res.statusCode != 200) throw Exception("Status: ${res.statusCode}");

      final data = jsonDecode(res.body);

      setState(() {
        workController.text = data['recordedDailyWorkMinutes']?.toStringAsFixed(2) ?? "";
        leisureController.text = data['recordedDailyLeisureMinutes']?.toStringAsFixed(2) ?? "";
        sleepController.text = data['recordedDailySleepMinutes']?.toStringAsFixed(2) ?? "";
      });
    } catch (e) {
      setState(() => error = "Failed to load today's minutes.");
    }
  }

  Future<void> _handleSubmit() async {
    try {
      final res = await http.post(
        Uri.parse("https://cop4331group3.xyz/api/activities/editcategories"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserID": userID,
          "updatedWorkMinutes": workController.text,
          "updatedLeisureMinutes": leisureController.text,
          "updatedSleepMinutes": sleepController.text,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw Exception(data['error'] ?? "Something went wrong");
      }

      setState(() => success = "Successfully updated categories!");

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacementNamed("/dashboard");
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Edit Today's Stuff",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const Text("Work Minutes"),
              TextField(
                controller: workController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
              const Text("Leisure Minutes"),
              TextField(
                controller: leisureController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
              const Text("Sleep Minutes"),
              TextField(
                controller: sleepController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text("Submit"),
              ),

              if (error != null) ...[
                const SizedBox(height: 20),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
              if (success != null) ...[
                const SizedBox(height: 20),
                Text(success!, style: const TextStyle(color: Colors.green)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}



