// lib/services/supabase_service_io.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Access supabase client
  static SupabaseClient get client => Supabase.instance.client;

  // Call from main() to initialize if desired (usually done in main.dart)
  static Future<void> initialize() async {
    // Optional: Supabase initialization here if needed
    return;
  }

  // AUTH - sign up
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userMetadata,
  }) {
    return client.auth.signUp(
      email: email,
      password: password,
      userMetadata: userMetadata, // replace old 'options'
    );
  }

  // AUTH - sign in
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // AUTH - sign out
  static Future<void> signOut() => client.auth.signOut();

  // DB - select from table
  static Future<PostgrestResponse> selectFrom(String table,
      {String? select, Map<String, dynamic>? eq}) async {
    var query = client.from(table).select(select ?? '*');
    if (eq != null) {
      eq.forEach((k, v) {
        query = query.eq(k, v);
      });
    }
    return await query; // no .execute()
  }

  // DB - upsert
  static Future<PostgrestResponse> upsert(String table, Map<String, dynamic> row) async {
    return await client.from(table).upsert(row).select(); // .select() returns inserted/updated rows
  }

  // DB - update
  static Future<PostgrestResponse> update(String table, Map<String, dynamic> values,
      {required String eqColumn, required dynamic eqValue}) async {
    return await client.from(table).update(values).eq(eqColumn, eqValue).select();
  }

  // DB - delete
  static Future<PostgrestResponse> delete(String table,
      {required String eqColumn, required dynamic eqValue}) async {
    return await client.from(table).delete().eq(eqColumn, eqValue).select();
  }
}
