import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboardmodel.dart';
import 'theme.dart';

class DashboardViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  UserModel? _user;
  UserModel? get user => _user;

  String _journalText = '';
  String get journalText => _journalText;

  DashboardViewModel() {
    _init();
  }

  void _init() {
    final u = FirebaseAuth.instance.currentUser;
    final name = u?.displayName ?? 'Ahmad';
    _user = UserModel(
      displayName: name,
      email: u?.email ?? '',
      initial: name.isNotEmpty ? name[0].toUpperCase() : 'A',
    );
    notifyListeners();
  }

  void setIndex(int i) {
    _selectedIndex = i;
    notifyListeners();
  }

  void setJournal(String v) {
    _journalText = v;
    notifyListeners();
  }

  void toggleRoutine(int i) {
    routines[i].isDone = !routines[i].isDone;
    notifyListeners();
  }

  void toggleTask(int i) {
    tasks[i].isDone = !tasks[i].isDone;
    notifyListeners();
  }

  void toggleChecklist(int i) {
    checklists[i].isDone = !checklists[i].isDone;
    notifyListeners();
  }

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> signOut(VoidCallback cb) async {
    await FirebaseAuth.instance.signOut();
    cb();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  final List<AddressModel> addresses = const [
    AddressModel(label: 'Office',      address: 'No. 12, Jalan Teknologi, Skudai',    icon: Icons.business_outlined,         color: C.blue),
    AddressModel(label: 'Home',        address: 'No. 5, Taman Sentosa, Johor Bahru',  icon: Icons.home_outlined,             color: C.teal),
    AddressModel(label: 'Bank',        address: 'Maybank, Jalan Dhoby, JB',           icon: Icons.account_balance_outlined,  color: C.amber),
    AddressModel(label: 'Hospital',    address: 'Hospital Sultan Ismail, Johor',      icon: Icons.local_hospital_outlined,   color: C.red),
    AddressModel(label: 'Supermarket', address: 'Aeon Mall, Tebrau City',             icon: Icons.shopping_cart_outlined,    color: C.green),
  ];

  final List<TaskModel> tasks = [
    TaskModel(title: 'Call Dr. Ahmad for appointment'),
    TaskModel(title: 'Pick up prescription'),
    TaskModel(title: 'Submit medical claim', isDone: true),
    TaskModel(title: 'Buy groceries for mum'),
  ];

  final List<MedicineModel> medicines = const [
    MedicineModel(name: 'Amlodipine', time: '8:00 AM',  dose: '5mg',     color: C.red),
    MedicineModel(name: 'Metformin',  time: '1:00 PM',  dose: '500mg',   color: C.blue),
    MedicineModel(name: 'Vitamin D',  time: '8:00 PM',  dose: '1000IU',  color: C.amber),
  ];

  final List<MemoryModel> memories = const [
    MemoryModel(title: 'Family Gathering', date: 'Raya 2024',  color: C.amber,  icon: Icons.celebration_outlined),
    MemoryModel(title: 'Hospital Visit',   date: 'March 2024', color: C.blue,   icon: Icons.local_hospital_outlined),
    MemoryModel(title: "Dad's Birthday",   date: 'Jan 2024',   color: C.teal,   icon: Icons.cake_outlined),
    MemoryModel(title: 'Trip to KL',       date: 'Dec 2023',   color: C.purple, icon: Icons.flight_outlined),
  ];

  final List<TaskModel> checklists = [
    TaskModel(title: 'Blood pressure meds taken'),
    TaskModel(title: 'Breakfast eaten'),
    TaskModel(title: '8 glasses of water', isDone: true),
    TaskModel(title: '30-min walk'),
    TaskModel(title: 'Evening prayer'),
  ];

  final List<ContactModel> contacts = const [
    ContactModel(name: 'Dr. Siti Rahimah', phone: '+60 12-345 6789', relation: 'Cardiologist', color: C.red),
    ContactModel(name: 'Ahmad bin Ali',    phone: '+60 11-234 5678', relation: 'Son',           color: C.blue),
    ContactModel(name: 'Klinik Desa',      phone: '+60 7-555 1234',  relation: 'Clinic',        color: C.teal),
    ContactModel(name: 'Ambulans',         phone: '999',             relation: 'Emergency',     color: C.red),
  ];

  final List<ReminderModel> reminders = const [
    ReminderModel(title: 'Doctor Appointment',  time: 'Today, 2:00 PM',      color: C.red),
    ReminderModel(title: 'Take Evening Meds',   time: 'Today, 8:00 PM',      color: C.blue),
    ReminderModel(title: 'Blood Pressure Check',time: 'Tomorrow, 8:00 AM',   color: C.teal),
  ];

  final List<RoutineModel> routines = [
    RoutineModel(label: 'Wake up & subuh',       icon: Icons.wb_sunny_outlined),
    RoutineModel(label: 'Morning meds',          icon: Icons.medication_outlined),
    RoutineModel(label: 'Breakfast',             icon: Icons.restaurant_outlined),
    RoutineModel(label: 'Morning walk',          icon: Icons.directions_walk_outlined),
    RoutineModel(label: 'Check blood pressure',  icon: Icons.favorite_outline),
    RoutineModel(label: 'Evening prayers',       icon: Icons.star_outline),
  ];
}