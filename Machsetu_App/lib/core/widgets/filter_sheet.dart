import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/home/data/machines.dart';
import '../services/machine_filter.dart';
import '../theme/app_colors.dart';

/// Bottom sheet that edits a [MachineFilter].
///
/// Returns the new filter on Apply, or null when dismissed. The option lists
/// are derived from the catalogue actually loaded, so a filter can never
/// offer a value that would return nothing.
Future<MachineFilter?> showFilterSheet({
  required BuildContext context,
  required MachineFilter current,
  required List<Machine> machines,
}) {
  return showModalBottomSheet<MachineFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _FilterSheet(current: current, machines: machines),
  );
}

/// Compact sort-only chooser, used where a full sheet would be overkill.
Future<MachineSort?> showSortSheet({
  required BuildContext context,
  required MachineSort current,
}) {
  return showModalBottomSheet<MachineSort>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sort results',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
          // ListTile rather than RadioListTile: the sheet pops on tap, so the
          // deprecated group-value plumbing buys nothing.
          for (final option in MachineSort.values)
            ListTile(
              leading: Icon(
                option == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: option == current
                    ? AppColors.brandBlue
                    : AppColors.textMuted,
              ),
              title: Text(option.label),
              onTap: () => Navigator.of(sheetContext).pop(option),
            ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current, required this.machines});

  final MachineFilter current;
  final List<Machine> machines;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late MachineFilter _draft = widget.current;
  late final _min = TextEditingController(
    text: widget.current.minPrice?.toString() ?? '',
  );
  late final _max = TextEditingController(
    text: widget.current.maxPrice?.toString() ?? '',
  );

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Set<String> _toggled(Set<String> set, String value) {
    final next = {...set};
    if (!next.remove(value)) next.add(value);
    return next;
  }

  MachineFilter get _resolved {
    final minText = _min.text.replaceAll(RegExp(r'[^0-9]'), '');
    final maxText = _max.text.replaceAll(RegExp(r'[^0-9]'), '');
    return _draft.copyWith(
      minPrice: minText.isEmpty ? null : int.tryParse(minText),
      maxPrice: maxText.isEmpty ? null : int.tryParse(maxText),
      clearMin: minText.isEmpty,
      clearMax: maxText.isEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = MachineFilter.categoriesOf(widget.machines);
    final conditions = MachineFilter.conditionsOf(widget.machines);
    final brands = MachineFilter.brandsOf(widget.machines);
    final matches = _resolved.apply(widget.machines).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          const _SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                if (_resolved.activeCount > 0)
                  TextButton(
                    onPressed: () {
                      _min.clear();
                      _max.clear();
                      setState(() => _draft = _draft.cleared());
                    },
                    child: const Text('Clear all'),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              children: [
                const _Label('Sort by'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in MachineSort.values)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: _draft.sort == option,
                        onSelected: (_) => setState(
                          () => _draft = _draft.copyWith(sort: option),
                        ),
                      ),
                  ],
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const _Label('Category'),
                  const SizedBox(height: 8),
                  _ChipGroup(
                    options: categories,
                    selected: _draft.categories,
                    onToggle: (value) => setState(
                      () => _draft = _draft.copyWith(
                        categories: _toggled(_draft.categories, value),
                      ),
                    ),
                  ),
                ],
                if (conditions.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const _Label('Condition'),
                  const SizedBox(height: 8),
                  _ChipGroup(
                    options: conditions,
                    selected: _draft.conditions,
                    onToggle: (value) => setState(
                      () => _draft = _draft.copyWith(
                        conditions: _toggled(_draft.conditions, value),
                      ),
                    ),
                  ),
                ],
                if (brands.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const _Label('Brand'),
                  const SizedBox(height: 8),
                  _ChipGroup(
                    options: brands,
                    selected: _draft.brands,
                    onToggle: (value) => setState(
                      () => _draft = _draft.copyWith(
                        brands: _toggled(_draft.brands, value),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                const _Label('Budget (₹)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PriceBox(
                        controller: _min,
                        hint: 'Min',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'to',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    Expanded(
                      child: _PriceBox(
                        controller: _max,
                        hint: 'Max',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Machines listed as "price on request" are hidden once a '
                  'budget is set.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_resolved),
                  child: Text(
                    matches == 0
                        ? 'No machines match'
                        : 'Show $matches machine${matches == 1 ? '' : 's'}',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      height: 4,
      width: 42,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: (_) => onToggle(option),
          ),
      ],
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: '₹ ',
        isDense: true,
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
