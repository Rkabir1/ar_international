import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ARInternationalApp());
}

class ARInternationalApp extends StatelessWidget {
  const ARInternationalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AR International',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) return const Dashboard();
        return const LoginScreen();
      },
    );
  }
}

// --- লগইন স্ক্রিন ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Icon(Icons.flight_takeoff, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text("AR INTERNATIONAL", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 40),
              TextField(controller: _email, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
              const SizedBox(height: 20),
              TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
              const SizedBox(height: 30),
              _loading 
                ? const CircularProgressIndicator() 
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                    child: const Text("LOGIN"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ড্যাশবোর্ড স্ক্রিন (পুরো লজিক সহ) ---
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _name = TextEditingController();
  final _passport = TextEditingController();
  final _payment = TextEditingController();
  File? _image;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  // ডেটা সেভ এবং ইমেজ আপলোড লজিক
  Future<void> _saveData() async {
    if (_name.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("সব তথ্য দিন এবং ছবি সিলেক্ট করুন")));
      return;
    }
    setState(() => _isSaving = true);
    try {
      // ১. ইমেজ আপলোড করা
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('clients/$fileName');
      await ref.putFile(_image!);
      String downloadUrl = await ref.getDownloadURL();

      // ২. ফায়ারস্টোরে ডেটা রাখা
      await FirebaseFirestore.instance.collection('clients').add({
        'name': _name.text,
        'passport': _passport.text,
        'payment': _payment.text,
        'imageUrl': downloadUrl,
        'date': DateFormat('dd-MM-yyyy').format(DateTime.now()),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _name.clear(); _passport.clear(); _payment.clear();
      setState(() => _image = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("সফলভাবে সেভ হয়েছে!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // PDF রিসিট জেনারেশন লজিক
  void _printReceipt(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text("AR INTERNATIONAL", style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold))),
              pw.Center(child: pw.Text("Money Receipt", style: pw.TextStyle(fontSize: 18))),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text("Date: ${data['date']}"),
              pw.Text("Client Name: ${data['name']}"),
              pw.Text("Passport No: ${data['passport']}"),
              pw.Text("Payment Amount: ${data['payment']} BDT"),
              pw.SizedBox(height: 50),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Client Signature"),
                  pw.Text("Authorized Signature"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR International Panel"),
        actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    TextField(controller: _name, decoration: const InputDecoration(labelText: "Client Name")),
                    TextField(controller: _passport, decoration: const InputDecoration(labelText: "Passport Number")),
                    TextField(controller: _payment, decoration: const InputDecoration(labelText: "Payment Amount"), keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _image == null 
                      ? TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text("Select Document Image"))
                      : Image.file(_image!, height: 100),
                    const SizedBox(height: 15),
                    _isSaving 
                      ? const CircularProgressIndicator() 
                      : ElevatedButton(onPressed: _saveData, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text("SAVE TO DATABASE")),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('clients').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(data['imageUrl'])),
                        title: Text(data['name']),
                        subtitle: Text("Passport: ${data['passport']}"),
                        trailing: IconButton(icon: const Icon(Icons.print, color: Colors.indigo), onPressed: () => _printReceipt(data)),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
