import 'package:flutter/material.dart';

class ArtfulDrawerTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String routeName;
  final bool selected;
  final Color foregroundColor;
  final WidgetBuilder backgroundBuilder;
  final bool showBackground;

  const ArtfulDrawerTileWidget({
    @required this.icon,
    @required this.title,
    @required this.routeName,
    @required this.selected,
    @required this.foregroundColor,
    @required this.backgroundBuilder,
    @required this.showBackground,
  });

  @override
  Widget build(BuildContext context) {
    final canvasColor = Theme.of(context).canvasColor;
    return SizedBox(
      height: 72,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          showBackground
              ? SizedBox.expand(
                  child: backgroundBuilder(context),
                )
              : const SizedBox(),
          showBackground
              ? SizedBox.expand(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [canvasColor, canvasColor.withAlpha(0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          ListTileTheme(
            style: ListTileStyle.drawer,
            selectedColor: foregroundColor,
            textColor: foregroundColor,
            iconColor: selected ? foregroundColor : foregroundColor.withOpacity(0.7),
            child: ListTile(
              leading: Icon(icon),
              title: Text(title, style: TextStyle(fontWeight: selected ? FontWeight.w900 : FontWeight.w100)),
              selected: selected,
              onTap: selected
                  ? null
                  : () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.pushReplacementNamed(routeName);
                    },
            ),
          ),
        ],
      ),
    );
  }
}
