import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});
  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _clubCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _clubCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final uid = context.read<AuthProvider>().firebaseUser?.uid;
      print("CURRENT USER ID: $uid");
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to add events')),
        );
        return;
      }

      final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      final event = EventModel(
        id: '',
        title: _titleCtrl.text.trim(),
        clubName: _clubCtrl.text.trim(),
        date: _selectedDate,
        time: timeString,
        status: AttendanceStatus.attending,
        createdBy: uid,
        createdAt: DateTime.now(),
      );

      await context.read<EventProvider>().createEvent(event);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50)),
            SizedBox(width: 8),
            Text('Event added!',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 17)),
          ]),
          content: Text(
            '"${_titleCtrl.text}" has been added to your calendar.',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done',
                style: TextStyle(fontFamily: 'Poppins',
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving event: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Event',
          style: TextStyle(fontFamily: 'Poppins',
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildField(
                controller: _titleCtrl,
                label: 'Event title',
                icon: Icons.event_rounded,
                validator: (val) => (val == null || val.isEmpty)
                  ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _clubCtrl,
                label: 'Club name',
                icon: Icons.group_rounded,
                validator: (val) => (val == null || val.isEmpty)
                  ? 'Please enter a club name' : null,
              ),
              const SizedBox(height: 12),
              _buildTappableField(
                label: 'Date',
                icon: Icons.calendar_today_rounded,
                value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              _buildTappableField(
                label: 'Time',
                icon: Icons.access_time_rounded,
                value: _selectedTime.format(context),
                onTap: _pickTime,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add to calendar',
                      style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935))),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5)),
      ),
      validator: validator,
    );
  }

  Widget _buildTappableField({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 11,
                  color: Color(0xFF6B6B6B))),
                Text(value, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 14,
                  color: Color(0xFF1A1A2E))),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFAAAAAA), size: 20),
          ],
        ),
      ),
    );
  }
}