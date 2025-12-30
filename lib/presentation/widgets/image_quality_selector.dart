import 'package:flutter/material.dart';
import 'package:zylix/presentation/shared/color.dart';

class ImageQualitySelector extends StatelessWidget {
  final double quantity;
  final String select;
  final Function(double value) onChanged;
  final Function(String value, double quality) onTap;
  const ImageQualitySelector({
    super.key,
    required this.quantity,
    required this.select,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text("Image Quality: $quantity%"),
          Slider(
            activeColor: AppColor.primaryColor,
            inactiveColor: AppColor.backgroundLight,
            value: quantity.toDouble(),
            min: 10,
            max: 100,
            divisions: 9,
            label: quantity.toString(),
            onChanged: onChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCardItem("Web", "Low", select == "Low", () {
                  onTap("Low", 40);
                }),
              ),
              Expanded(
                child: _buildCardItem(
                  "Standard",
                  "Medium",
                  select == "Medium",
                  () {
                    onTap("Medium", 60);
                  },
                ),
              ),
              Expanded(
                child: _buildCardItem("Print", "High", select == "High", () {
                  onTap("High", 80);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
    String title,
    String subTitle,
    bool active,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: AppColor.backgroundLight.withAlpha(200),
          border: active
              ? Border.all(width: 2, color: AppColor.primaryColor)
              : Border.all(width: 0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [Text(title), Text(subTitle)]),
      ),
    );
  }
}
