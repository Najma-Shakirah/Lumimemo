import 'package:flutter/material.dart';
import 'theme.dart';

class UserModel {
  final String displayName;
  final String email;
  final String initial;
  const UserModel({required this.displayName, required this.email, required this.initial});
}

class AddressModel {
  final String label;
  final String address;
  final IconData icon;
  final Color color;
  const AddressModel({required this.label, required this.address, required this.icon, required this.color});
}

class TaskModel {
  final String title;
  bool isDone;
  TaskModel({required this.title, this.isDone = false});
}

class MedicineModel {
  final String name;
  final String time;
  final String dose;
  final Color color;
  const MedicineModel({required this.name, required this.time, required this.dose, required this.color});
}

class MemoryModel {
  final String title;
  final String date;
  final Color color;
  final IconData icon;
  const MemoryModel({required this.title, required this.date, required this.color, required this.icon});
}

class ContactModel {
  final String name;
  final String phone;
  final String relation;
  final Color color;
  const ContactModel({required this.name, required this.phone, required this.relation, required this.color});
}

class ReminderModel {
  final String title;
  final String time;
  final Color color;
  const ReminderModel({required this.title, required this.time, required this.color});
}

class RoutineModel {
  final String label;
  final IconData icon;
  bool isDone;
  RoutineModel({required this.label, required this.icon, this.isDone = false});
}