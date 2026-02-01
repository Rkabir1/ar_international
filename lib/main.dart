import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// ১. গ্লোবাল থিম ও ব্রান্ডিং
class ARBranding {
  static const Color primaryCharcoal = Color(0xFF2C3E50); 
  static const Color logoRed = Color(0xFFE74C3C); 
  static const Color bgGrey = Color(0xFFF4F7F6);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase connection failed: $e");
  }
  runApp(const ARInternationalApp());
}

class ARInternationalApp extends StatelessWidget {
  const ARInternationalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR International',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: ARBranding.primaryCharcoal,
        scaffoldBackgroundColor: ARBranding.bgGrey,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ২. ইউজার রোলস
enum UserRole { owner, staff, agent }

// ৩. মডার্ন লগইন স্ক্রিন
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _handleLogin() {
    UserRole selectedRole = UserRole.agent; 
    if (_userController.text == "admin") selectedRole = UserRole.owner;
    if (_userController.text == "staff") selectedRole = UserRole.staff;

    Navigator.push(context, MaterialPageRoute(
      builder: (context) => MainDashboard(role: selectedRole)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ARBranding.bgGrey,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png', 
                  height: 100, 
                  errorBuilder: (c, e, s) => const Icon(Icons.flight_takeoff, size: 80, color: ARBranding.logoRed)
                ),
                const SizedBox(height: 10),
                const Text("AR INTERNATIONAL", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ARBranding.primaryCharcoal, letterSpacing: 0.5)),
                const Text("Enterprise Management Portal", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 40),
                _buildTextField("User ID", "Enter your ID", _userController, false),
                const SizedBox(height: 20),
                _buildTextField("Password", "••••••••", _passController, true),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ARBranding.logoRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _handleLogin,
                    child: const Text("LOGIN TO PANEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 25),
                const Text("GLOBAL TRAVEL EXCELLENCE", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isPass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPass,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

// ৪. মেইন ড্যাশবোর্ড
class MainDashboard extends StatelessWidget {
  final UserRole role;
  const MainDashboard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ARBranding.primaryCharcoal,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 35, errorBuilder: (c, e, s) => const Icon(Icons.flight, color: Colors.white)),
            const SizedBox(width: 10),
            Text("${role.name.toUpperCase()} PANEL", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pop(context)),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Quick Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildStatsGrid(),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Document Submissions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (role != UserRole.agent) 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.sync, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text("Live Sync", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            _buildFileList(),
          ],
        ),
      ),
      floatingActionButton: role == UserRole.agent 
        ? FloatingActionButton.extended(
            backgroundColor: ARBranding.logoRed,
            onPressed: () {}, 
            label: const Text("Upload Document", style: TextStyle(color: Colors.white)), 
            icon: const Icon(Icons.add_a_photo, color: Colors.white))
        : null,
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _statCard("Total Clients", "128", Colors.blue),
        _statCard("Pending Files", "14", ARBranding.logoRed),
        if (role == UserRole.owner) _statCard("Total Cash", "৳ 12.5L", Colors.green),
        if (role == UserRole.owner) _statCard("Net Profit", "৳ 3.2L", Colors.teal),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: ARBranding.bgGrey, child: Icon(Icons.picture_as_pdf, color: ARBranding.logoRed)),
            title: Text("Client_Passport_00${index + 1}.pdf", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("By: Dhaka Agent | 08:45 PM", style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.cloud_download, color: Colors.blueGrey),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: ARBranding.primaryCharcoal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flight_takeoff, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                const Text("AR INTERNATIONAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.home), title: const Text("Dashboard"), onTap: () {}),
          ListTile(leading: const Icon(Icons.folder_shared), title: const Text("Client Archives"), onTap: () {}),
          if (role != UserRole.agent) ListTile(leading: const Icon(Icons.account_balance_wallet), title: const Text("Accounts & Cash"), onTap: () {}),
          const Divider(),
          ListTile(leading: const Icon(Icons.settings), title: const Text("Settings"), onTap: () {}),
        ],
      ),
    );
  }
}
