class SupabaseService {
  // Mock implementation only (Supabase removed)

  static Future<void> initialize() async {
    // no-op
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 'demo1',
        'title': 'Demo Product',
        'description': 'Just for UI testing',
        'price': 10.0,
        'image_url': 'https://via.placeholder.com/150',
      },
      {
        'id': 'demo2',
        'title': 'Another Product',
        'description': 'More mock data',
        'price': 15.0,
        'image_url': 'https://via.placeholder.com/150/AAAAAA/000000?text=Product+2',
      },
    ];
  }

  static Future<void> createOrder(Map<String, dynamic> orderData) async {
    // Simulate order creation delay
    await Future.delayed(const Duration(milliseconds: 500));
    print('Mock order created: \$orderData');
  }

  static Future<void> signIn(String email, String password) async {
    // Simulate login success
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock login for \$email');
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock logout');
  }
}