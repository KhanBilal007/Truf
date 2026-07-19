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
import 'package:turfverse/features/auth/widgets/auth_validators.dart';
import 'package:turfverse/features/owner/providers/owner_provider.dart';
import 'package:turfverse/features/turf/models/turf.dart';

class AddEditTurfScreen extends ConsumerWidget {
  const AddEditTurfScreen({this.turfId, super.key});
  final String? turfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (turfId == null) return const _TurfForm();
    return ref
        .watch(ownerTurfProvider(turfId!))
        .when(
          loading: () => const PremiumPage(
            title: 'Edit Turf',
            subtitle: 'Loading your turf.',
            child: SizedBox(height: 320, child: LoadingWidget()),
          ),
          error: (error, stackTrace) => PremiumPage(
            title: 'Edit Turf',
            subtitle: 'Manage your box cricket ground.',
            child: ErrorStateWidget(message: error.toString()),
          ),
          data: (turf) => _TurfForm(turf: turf),
        );
  }
}

class _TurfForm extends ConsumerStatefulWidget {
  const _TurfForm({this.turf});
  final Turf? turf;

  @override
  ConsumerState<_TurfForm> createState() => _TurfFormState();
}

class _TurfFormState extends ConsumerState<_TurfForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _area;
  late final TextEditingController _address;
  late final TextEditingController _price;
  late final TextEditingController _description;
  late final TextEditingController _amenities;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final turf = widget.turf;
    _name = TextEditingController(text: turf?.name);
    _city = TextEditingController(text: turf?.city);
    _area = TextEditingController(text: turf?.area);
    _address = TextEditingController(text: turf?.address);
    _price = TextEditingController(text: turf?.pricePerHour.toString());
    _description = TextEditingController(text: turf?.description);
    _amenities = TextEditingController(text: turf?.amenities.join(', '));
    _active = turf?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _city,
      _area,
      _address,
      _price,
      _description,
      _amenities,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await ref
        .read(ownerControllerProvider.notifier)
        .saveTurf(
          turfId: widget.turf?.id,
          name: _name.text,
          city: _city.text,
          area: _area.text,
          address: _address.text,
          price: double.parse(_price.text),
          description: _description.text,
          amenities: _amenities.text
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
          isActive: _active,
        );
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Turf saved successfully.')));
      context.go(AppRoutes.ownerTurfs);
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
      title: widget.turf == null ? 'Add Turf' : 'Edit Turf',
      subtitle: 'Add and maintain your box cricket ground details.',
      icon: Icons.add_business_outlined,
      child: PremiumCard(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(
                'Turf Name',
                _name,
                Icons.stadium_outlined,
                required: true,
              ),
              _field(
                'City',
                _city,
                Icons.location_city_outlined,
                required: true,
              ),
              _field('Area', _area, Icons.location_on_outlined, required: true),
              _field('Full Address', _address, Icons.map_outlined),
              _field(
                'Price Per Hour',
                _price,
                Icons.payments_outlined,
                number: true,
                validator: (value) {
                  final number = double.tryParse(value ?? '');
                  return number == null || number < 0
                      ? 'Enter a valid price.'
                      : null;
                },
              ),
              _field(
                'Description',
                _description,
                Icons.notes_rounded,
                lines: 3,
              ),
              _field(
                'Amenities',
                _amenities,
                Icons.checklist_rounded,
                hint: 'Floodlights, Parking, Washroom, Refreshments',
                lines: 2,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active Turf'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Save Turf',
                isLoading: loading,
                onPressed: _save,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Cancel',
                onPressed: loading
                    ? null
                    : () => context.go(AppRoutes.ownerTurfs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool required = false,
    bool number = false,
    int lines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomTextField(
        label: label,
        hint: hint,
        controller: controller,
        prefixIcon: icon,
        maxLines: lines,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        validator:
            validator ??
            (required
                ? (value) => AuthValidators.requiredField(value, label)
                : null),
      ),
    );
  }
}
