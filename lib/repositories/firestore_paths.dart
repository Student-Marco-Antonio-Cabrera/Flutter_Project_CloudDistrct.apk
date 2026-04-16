class FirestorePaths {
  const FirestorePaths._();

  static String user(String userId) => 'users/$userId';

  static String address(String userId, String addressId) =>
      '${user(userId)}/addresses/$addressId';

  static String cart(String userId, String cartItemId) =>
      '${user(userId)}/cart/$cartItemId';

  static String order(String userId, String orderId) =>
      '${user(userId)}/orders/$orderId';

  static String product(String productId) => 'products/$productId';
}
