import 'package:flutter/material.dart';
import '../../../constants.dart';

class FileInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const FileInfoCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: defaultPadding),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white), // Adjust the text style if necessary
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
