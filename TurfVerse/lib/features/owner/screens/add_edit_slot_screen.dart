import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/owner/providers/owner_provider.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class AddEditSlotScreen extends ConsumerWidget {
  const AddEditSlotScreen({this.turfId, this.slotId, super.key});
  final String? turfId;
  final String? slotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (slotId == null) return _SlotForm(turfId: turfId!);
    return ref
        .watch(ownerSlotProvider(slotId!))
        .when(
          loading: () => const PremiumPage(
            title: 'Edit Slot',
            subtitle: 'Loading slot details.',
            child: SizedBox(height: 320, child: LoadingWidget()),
          ),
          error: (error, stackTrace) => PremiumPage(
            title: 'Edit Slot',
            subtitle: 'Manage booking availability.',
            child: ErrorStateWidget(message: error.toString()),
          ),
          data: (slot) => _SlotForm(turfId: slot.turfId, slot: slot),
        );
  }
}

class _SlotForm extends ConsumerStatefulWidget {
  const _SlotForm({required this.turfId, this.slot});
  final String turfId;
  final TurfSlot? slot;

  @override
  ConsumerState<_SlotForm> createState() => _SlotFormState();
}

class _SlotFormState extends ConsumerState<_SlotForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  late final TextEditingController _priceController;
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  late bool _available;

  @override
  void initState() {
    super.initState();
    final slot = widget.slot;
    _date = slot?.slotDate;
    _dateController.text = slot == null ? '' : formatDate(slot.slotDate);
    _start = slot == null ? null : _parseTime(slot.startTime);
    _end = slot == null ? null : _parseTime(slot.endTime);
    _startController.text = slot == null ? '' : formatTime(slot.startTime);
    _endController.text = slot == null ? '' : formatTime(slot.endTime);
    _priceController = TextEditingController(text: slot?.price.toString());
    _available = slot?.isAvailable ?? true;
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _sqlTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (value != null) {
      setState(() {
        _date = value;
        _dateController.text = formatDate(value);
      });
    }
  }

  Future<void> _pickTime(bool start) async {
    final value = await showTimePicker(
      context: context,
      initialTime: start
          ? (_start ?? const TimeOfDay(hour: 18, minute: 0))
          : (_end ?? const TimeOfDay(hour: 19, minute: 0)),
    );
    if (value != null) {
      setState(() {
        if (start) {
          _start = value;
          _startController.text = value.format(context);
        } else {
          _end = value;
          _endController.text = value.format(context);
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final startMinutes = _start!.hour * 60 + _start!.minute;
    final endMinutes = _end!.hour * 60 + _end!.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }
    final saved = await ref
        .read(ownerControllerProvider.notifier)
        .saveSlot(
          slotId: widget.slot?.id,
          turfId: widget.turfId,
          date: _date!,
          startTime: _sqlTime(_start!),
          endTime: _sqlTime(_end!),
          price: double.parse(_priceController.text),
          isAvailable: _available,
        );
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Slot saved successfully.')));
      context.go('${AppRoutes.ownerTurfSlotsBase}/${widget.turfId}');
    } else {
      final error = ref.read(ownerControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(ownerControllerProvider).isLoading;
    return PremiumPage(
      title: widget.slot == null ? 'Add Slot' : 'Edit Slot',
      subtitle: 'Manage turf availability and pricing.',
      icon: Icons.edit_calendar_outlined,
      child: PremiumCard(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _pickerField('Slot Date', _dateController, _pickDate),
              _pickerField(
                'Start Time',
                _startController,
                () => _pickTime(true),
              ),
              _pickerField('End Time', _endController, () => _pickTime(false)),
              CustomTextField(
                label: 'Price',
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.payments_outlined,
                validator: (value) {
                  final number = double.tryParse(value ?? '');
                  return number == null || number <= 0
                      ? 'Price must be greater than 0.'
                      : null;
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available'),
                value: _available,
                onChanged: (value) => setState(() => _available = value),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Save Slot',
                isLoading: loading,
                onPressed: _save,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Cancel',
                onPressed: loading
                    ? null
                    : () => context.go(
                        '${AppRoutes.ownerTurfSlotsBase}/${widget.turfId}',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerField(
    String label,
    TextEditingController controller,
    VoidCallback onPick,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomTextField(
        label: label,
        controller: controller,
        prefixIcon: Icons.schedule_outlined,
        suffixIcon: IconButton(
          onPressed: onPick,
          icon: const Icon(Icons.edit_outlined),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? '$label is required.' : null,
      ),
    );
  }
}
