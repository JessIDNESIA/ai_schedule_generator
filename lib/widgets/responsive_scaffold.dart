import 'package:flutter/material.dart';

/// Responsive scaffold untuk split-panel layout
/// - Mobile (<600px): Single column (input → list → preview)
/// - Tablet (>=600px): Two column (left panel 40%, right panel 60%)
class ResponsiveScaffold extends StatelessWidget {
  final String appBarTitle;
  final Widget? appBarActions;

  // Left panel widgets
  final Widget leftPanel;

  // Right panel widgets (optional)
  final Widget? rightPanel;

  // Mobile bottom sheet content (optional)
  final Widget? mobileBottomContent;

  const ResponsiveScaffold({
    Key? key,
    required this.appBarTitle,
    this.appBarActions,
    required this.leftPanel,
    this.rightPanel,
    this.mobileBottomContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint: 600dp
        final isTablet = constraints.maxWidth >= 600;

        if (isTablet) {
          // TABLET/WEB LAYOUT: Split panel
          return Scaffold(
            appBar: _buildAppBar(context),
            body: Row(
              children: [
                // LEFT PANEL (40%)
                Expanded(
                  flex: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: leftPanel,
                  ),
                ),

                // RIGHT PANEL (60%) - Optional
                if (rightPanel != null)
                  Expanded(
                    flex: 60,
                    child: rightPanel!,
                  )
                else
                  Expanded(
                    flex: 60,
                    child: Center(
                      child: Text(
                        'Right panel content here',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else {
          // MOBILE LAYOUT: Single column
          return Scaffold(
            appBar: _buildAppBar(context),
            body: leftPanel,
            // Bottom sheet untuk right panel content
            bottomSheet: mobileBottomContent,
          );
        }
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(appBarTitle),
      elevation: 0.5,
      actions: appBarActions != null ? [appBarActions!] : null,
    );
  }
}
