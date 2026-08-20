import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/feature/home/widget/home_navbar.dart';

void main() {
  testWidgets('navbar shrink-wraps and leaves room for the page body', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var selectedIndex = 0;
    const bodyKey = Key('page-body');

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            body: const SizedBox.expand(key: bodyKey),
            bottomNavigationBar: HomeNavBar(
              currentIndex: selectedIndex,
              onTap: (index) => selectedIndex = index,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(HomeNavBar)).height, lessThan(120));
    expect(tester.getSize(find.byKey(bodyKey)).height, greaterThan(650));

    await tester.tap(find.text('Settings'));
    expect(selectedIndex, 1);
    expect(tester.takeException(), isNull);
  });
}
