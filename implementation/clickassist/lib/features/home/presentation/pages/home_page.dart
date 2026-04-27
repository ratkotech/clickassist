import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../widgets/home_header.dart';
import '../widgets/home_placeholder_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.pageTop,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              SizedBox(height: AppSpacing.xxl),
              HomePlaceholderCard(),
            ],
          ),
        ),
      ),
    );
  }
}