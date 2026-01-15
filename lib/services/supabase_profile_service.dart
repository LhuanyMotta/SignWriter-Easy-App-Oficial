import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileService {
  final SupabaseClient _client;

  SupabaseProfileService(this._client);

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return {
      'id': response['id'],
      'name': response['name'],
      'email': response['email'],
      'nivel': response['nivel'],
      'createdAt': response['created_at'],
      'updatedAt': response['updated_at'],
    };
  }

  Future<void> upsertProfile({
    required String id,
    required String name,
    required String email,
  }) async {
    await _client.from('profiles').upsert({
      'id': id,
      'name': name,
      'email': email,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProfileName({
    required String id,
    required String name,
  }) async {
    await _client.from('profiles').update({
      'name': name,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}
