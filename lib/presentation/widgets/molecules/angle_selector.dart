import 'package:flutter/material.dart';
import 'package:zylix/presentation/shared/color.dart';

class AngleSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const AngleSelector({super.key,required this.selected, required this.onChanged});

  static const _options = [
    (label: '90° ↻', value: 90),
    (label: '180°', value: 180),
    (label: '90° ↺', value: 270),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((opt) {
        final isSelected = opt.value == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(opt.value),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColor.primaryColor
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
