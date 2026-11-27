import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/styles/colors.dart';
import '../../../../core/widgets/custom_svg_picture.dart';

class NavTabItem {
  const NavTabItem({
    required this.label,
    required this.iconPath,
    required this.screen,
  });

  final String label;
  final String iconPath;
  final Widget screen;
}

/// Authenticated 3-tab shell matching Figma `Navigation` (`3:54`).
/// Uses [IndexedStack] so switching tabs preserves scroll position and Cubit state.
class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
  });

  final List<NavTabItem> tabs;
  final int initialIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.isDark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: widget.tabs.map((tab) => tab.screen).toList(growable: false),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppConstants.screenHorizontalPadding,
            AppConstants.space8,
            AppConstants.screenHorizontalPadding,
            AppConstants.space12,
          ),
          child: Container(
            height: AppConstants.bottomNavHeight,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppConstants.borderRadius20,
              border: Border.all(
                color: isDark
                    ? scheme.outline
                    : AppColors.line.withValues(alpha: 0.6),
              ),
              boxShadow: isDark ? null : const [AppConstants.floatingShadow],
            ),
            child: Row(
              children: [
                for (var i = 0; i < widget.tabs.length; i++)
                  Expanded(
                    child: _NavBarItem(
                      item: widget.tabs[i],
                      isSelected: i == _currentIndex,
                      onTap: () {
                        if (_currentIndex != i) {
                          setState(() => _currentIndex = i);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavTabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.isDark;
    final activeColor = isDark ? AppColors.accent : AppColors.teal;
    final inactiveColor = scheme.onSurfaceVariant;
    final color = isSelected ? activeColor : inactiveColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppConstants.borderRadius20,
        child: SizedBox(
          height: AppConstants.bottomNavHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSvgPicture(
                assetPath: item.iconPath,
                width: 24,
                height: 24,
                color: color,
              ),
              const SizedBox(height: AppConstants.space4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
