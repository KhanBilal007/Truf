import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';

final reportControllerProvider =
    NotifierProvider<ReportController, AsyncValue<void>>(ReportController.new);

class ReportController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> submit({required String type, required String message}) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(supabaseServiceProvider);
      final user = service.currentUser;
      if (user == null) throw const AuthException('Log in to submit a report.');
      await service.client.from('reports').insert({
        'user_id': user.id,
        'report_type': type,
        'message': message.trim(),
        'status': 'open',
      });
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
