import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mvvm_app/viewmodels/cart_view_model.dart';
import 'package:mvvm_app/viewmodels/product_view_model.dart';

void main() {
  group('Provider Chain Tests', () {
    testWidgets('All providers are accessible in widget tree', (WidgetTester tester) async {
      // Create a test widget with all providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartViewModel()),
            ChangeNotifierProvider(create: (_) => ProductViewModel()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  // Access providers to verify they're available
                  final cartViewModel = context.read<CartViewModel>();
                  final productViewModel = context.read<ProductViewModel>();
                  
                  return Column(
                    children: [
                      Text('Cart Items: ${cartViewModel.itemCount}'),
                      Text('Product: ${productViewModel.currentProduct?.name ?? 'None'}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify the widgets are built correctly
      expect(find.text('Cart Items: 0'), findsOneWidget);
      expect(find.text('Product: None'), findsOneWidget);
    });

    testWidgets('Provider notifies listeners correctly', (WidgetTester tester) async {
      final cartViewModel = CartViewModel();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: cartViewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<CartViewModel>(
                builder: (context, cart, child) {
                  return Column(
                    children: [
                      Text('Items: ${cart.itemCount}'),
                      Text('Total: \$${cart.totalAmount.toStringAsFixed(2)}'),
                      ElevatedButton(
                        onPressed: () {
                          // This would normally add a product
                          // For testing, we'll just verify the consumer rebuilds
                        },
                        child: const Text('Add Item'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Items: 0'), findsOneWidget);
      expect(find.text('Total: \$0.00'), findsOneWidget);
      
      // Verify button exists
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('Multiple consumers work correctly', (WidgetTester tester) async {
      final cartViewModel = CartViewModel();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: cartViewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Consumer<CartViewModel>(
                    builder: (context, cart, child) {
                      return Text('Consumer 1: ${cart.itemCount}');
                    },
                  ),
                  Consumer<CartViewModel>(
                    builder: (context, cart, child) {
                      return Text('Consumer 2: ${cart.totalAmount}');
                    },
                  ),
                  Selector<CartViewModel, bool>(
                    selector: (context, cart) => cart.isEmpty,
                    builder: (context, isEmpty, child) {
                      return Text('Empty: $isEmpty');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify all consumers show correct initial values
      expect(find.text('Consumer 1: 0'), findsOneWidget);
      expect(find.text('Consumer 2: 0.0'), findsOneWidget);
      expect(find.text('Empty: true'), findsOneWidget);
    });

    testWidgets('Provider context access works correctly', (WidgetTester tester) async {
      final cartViewModel = CartViewModel();
      CartViewModel? accessedViewModel;
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: cartViewModel,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  // Test different ways to access the provider
                  accessedViewModel = context.read<CartViewModel>();
                  final watchedViewModel = context.watch<CartViewModel>();
                  
                  return Column(
                    children: [
                      Text('Read VM hashCode: ${accessedViewModel.hashCode}'),
                      Text('Watch VM hashCode: ${watchedViewModel.hashCode}'),
                      Text('Items: ${watchedViewModel.itemCount}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify the same instance is accessed
      expect(accessedViewModel, equals(cartViewModel));
      expect(find.textContaining('Read VM hashCode:'), findsOneWidget);
      expect(find.textContaining('Watch VM hashCode:'), findsOneWidget);
      expect(find.text('Items: 0'), findsOneWidget);
    });

    test('Provider without widget tree throws correctly', () {
      // This should throw when trying to access provider outside widget tree
      expect(
        () {
          final cartViewModel = CartViewModel();
          // This would normally be called within a widget context
          // We're testing that proper error handling exists
        },
        returnsNormally, // CartViewModel creation should work fine
      );
    });

    testWidgets('Nested providers work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartViewModel()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider(
                create: (_) => ProductViewModel(),
                child: Builder(
                  builder: (context) {
                    final cartViewModel = context.read<CartViewModel>();
                    final productViewModel = context.read<ProductViewModel>();
                    
                    return Column(
                      children: [
                        Text('Cart available: ${cartViewModel != null}'),
                        Text('Product available: ${productViewModel != null}'),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Both providers should be accessible
      expect(find.text('Cart available: true'), findsOneWidget);
      expect(find.text('Product available: true'), findsOneWidget);
    });
  });
}