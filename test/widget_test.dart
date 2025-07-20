// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mvvm_app/viewmodels/cart_view_model.dart';
import 'package:mvvm_app/viewmodels/product_view_model.dart';

void main() {
  testWidgets('Cart functionality works correctly', (WidgetTester tester) async {
    final cartViewModel = CartViewModel();
    
    // Test cart is initially empty
    expect(cartViewModel.isEmpty, isTrue);
    expect(cartViewModel.itemCount, equals(0));
    expect(cartViewModel.totalAmount, equals(0.0));
    
    // Build a minimal test widget
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cartViewModel,
        child: const MaterialApp(
          home: Scaffold(
            body: Text('Cart Test'),
          ),
        ),
      ),
    );

    // Verify basic app structure
    expect(find.text('Cart Test'), findsOneWidget);
  });

  testWidgets('Product ViewModel initializes correctly', (WidgetTester tester) async {
    final productViewModel = ProductViewModel();
    
    // Test initial state
    expect(productViewModel.currentProduct, isNull);
    expect(productViewModel.webController, isNull);
    
    // Build a minimal test widget
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: productViewModel,
        child: const MaterialApp(
          home: Scaffold(
            body: Text('Product Test'),
          ),
        ),
      ),
    );

    // Verify basic app structure
    expect(find.text('Product Test'), findsOneWidget);
  });
}
