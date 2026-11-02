import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../content/areas.dart';
import '../content/catalog.dart';

/// इलाका चुनने की नीचे से खुलने वाली सूची। चुना गया इलाका लौटाता है।
Future<String?> showAreaPicker(BuildContext context, {String? selected}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.s),
                child: Text('अपना इलाका चुनें', style: AppText.h3),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: varanasiAreas.length,
                  itemBuilder: (context, i) {
                    final area = varanasiAreas[i];
                    final isSelected = area == selected;
                    return ListTile(
                      title: Text(area, style: AppText.body),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                      onTap: () => Navigator.of(context).pop(area),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// फ़ॉर्म में इलाके का खाना: दबाने पर [showAreaPicker] खुलता है।
class AreaField extends StatelessWidget {
  const AreaField({super.key, required this.value, required this.onChanged, this.errorText});

  /// ख़ाली हो तो "इलाका चुनें" दिखता है।
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showAreaPicker(context, selected: value.isEmpty ? null : value);
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'इलाका',
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.expand_more),
        ),
        isEmpty: value.isEmpty,
        child: Text(value.isEmpty ? '' : value, style: AppText.body),
      ),
    );
  }
}

/// सिस्टम के kW चुनने की चिप पंक्ति (1, 2, 3, 4, 5, 5+)।
class KwSelector extends StatelessWidget {
  const KwSelector({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpace.s,
      runSpacing: AppSpace.s,
      children: [
        for (final kw in Catalog.kwOptions)
          ChoiceChip(
            label: Text(Catalog.kwLabel(kw)),
            selected: value == kw,
            onSelected: (_) => onChanged(kw),
            selectedColor: AppColors.primarySoft,
            labelStyle: TextStyle(
              color: value == kw ? AppColors.primaryDark : AppColors.text,
              fontWeight: value == kw ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

/// किसी सूची में से एक चुनने की चिप पंक्ति (दिक्कत, समय आदि)।
class OptionChips extends StatelessWidget {
  const OptionChips({super.key, required this.options, required this.selected, required this.onChanged});

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpace.s,
      runSpacing: AppSpace.s,
      children: [
        for (final o in options)
          ChoiceChip(
            label: Text(o),
            selected: selected == o,
            onSelected: (_) => onChanged(o),
            selectedColor: AppColors.primarySoft,
            labelStyle: TextStyle(
              color: selected == o ? AppColors.primaryDark : AppColors.text,
              fontWeight: selected == o ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
