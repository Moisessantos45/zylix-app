import 'package:flutter/material.dart';
import 'package:zylix/presentation/widgets/info_card.dart';

class InfoItem {
  final IconData icon;
  final String title;
  final String value;
  final bool isLink;
  final bool isLast;

  InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    this.isLink = false,
    this.isLast = false,
  });
}

class InfoSection extends StatelessWidget {
  final String title;
  final List<InfoItem> items;
  const InfoSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items.map((item) {
              return InfoCard(
                icon: item.icon,
                title: item.title,
                value: item.value,
                isLink: item.isLink,
                isLast: item.isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
