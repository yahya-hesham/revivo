import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revivo/core/constants/app_assets.dart';
import 'package:revivo/features/dashboard/presentation/widgets/main_layout.dart';

void main() {
  testWidgets('MainLayout switches between tabs and preserves tab state',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainLayout(
          tabs: const [
            NavTabItem(
              label: 'Garage',
              iconPath: AppAssets.navGarage,
              screen: _CounterTab(name: 'Garage'),
            ),
            NavTabItem(
              label: 'Alerts',
              iconPath: AppAssets.navAlerts,
              screen: _CounterTab(name: 'Alerts'),
            ),
            NavTabItem(
              label: 'Account',
              iconPath: AppAssets.navAccount,
              screen: _CounterTab(name: 'Account'),
            ),
          ],
        ),
      ),
    );

    // Starts on Garage tab
    expect(find.text('Garage: 0'), findsOneWidget);

    // Increment Garage counter to 1
    await tester.tap(find.byKey(const Key('inc_Garage')));
    await tester.pump();
    expect(find.text('Garage: 1'), findsOneWidget);

    // Switch to Alerts tab
    await tester.tap(find.text('Alerts'));
    await tester.pump();
    expect(find.text('Alerts: 0'), findsOneWidget);

    // Switch to Account tab
    await tester.tap(find.text('Account'));
    await tester.pump();
    expect(find.text('Account: 0'), findsOneWidget);

    // Return to Garage — IndexedStack preserved state (still 1)
    await tester.tap(find.text('Garage'));
    await tester.pump();
    expect(find.text('Garage: 1'), findsOneWidget);
  });
}

class _CounterTab extends StatefulWidget {
  const _CounterTab({required this.name});
  final String name;

  @override
  State<_CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<_CounterTab> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${widget.name}: $_count'),
          TextButton(
            key: Key('inc_${widget.name}'),
            onPressed: () => setState(() => _count++),
            child: const Text('+1'),
          ),
        ],
      ),
    );
  }
}
