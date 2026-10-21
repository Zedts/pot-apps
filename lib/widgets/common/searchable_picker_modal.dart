import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';

/// Reusable searchable bottom-sheet picker modal and field for selecting
/// items (stalls, couriers, products, etc.) with real-time text filtering.
class SearchablePickerModal<T> extends StatefulWidget {
  final String title;
  final String searchPlaceholder;
  final List<T> items;
  final String Function(T) itemLabel;
  final String? Function(T)? itemSublabel;
  final T? selectedItem;
  final bool Function(T, T)? equalityChecker;

  const SearchablePickerModal({
    super.key,
    required this.title,
    required this.searchPlaceholder,
    required this.items,
    required this.itemLabel,
    this.itemSublabel,
    this.selectedItem,
    this.equalityChecker,
  });

  /// Shows the searchable picker bottom sheet and returns the selected item, or `null` if cancelled.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String searchPlaceholder,
    required List<T> items,
    required String Function(T) itemLabel,
    String? Function(T)? itemSublabel,
    T? selectedItem,
    bool Function(T, T)? equalityChecker,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SearchablePickerModal<T>(
        title: title,
        searchPlaceholder: searchPlaceholder,
        items: items,
        itemLabel: itemLabel,
        itemSublabel: itemSublabel,
        selectedItem: selectedItem,
        equalityChecker: equalityChecker,
      ),
    );
  }

  @override
  State<SearchablePickerModal<T>> createState() => _SearchablePickerModalState<T>();
}

class _SearchablePickerModalState<T> extends State<SearchablePickerModal<T>> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    if (_query.trim().isEmpty) return widget.items;
    final q = _query.trim().toLowerCase();
    return widget.items.where((item) {
      final label = widget.itemLabel(item).toLowerCase();
      final sublabel = widget.itemSublabel?.call(item)?.toLowerCase() ?? '';
      return label.contains(q) || sublabel.contains(q);
    }).toList();
  }

  bool _isSelected(T item) {
    if (widget.selectedItem == null) return false;
    if (widget.equalityChecker != null) {
      return widget.equalityChecker!(item, widget.selectedItem as T);
    }
    return item == widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filtered = _filteredItems;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: PotColors.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PotColors.warmBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Title & Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: PotColors.textDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: PotColors.warmBorder.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: PotColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: PotColors.pureWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PotColors.warmBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.search_normal,
                    size: 17,
                    color: PotColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _query = val),
                      style: const TextStyle(
                        fontSize: 13,
                        color: PotColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.searchPlaceholder,
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: PotColors.textMuted.withValues(alpha: 0.8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: PotColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: PotColors.warmBorder),

          // List Items
          Flexible(
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    child: Center(
                      child: Text(
                        _query.isEmpty
                            ? 'Tidak ada pilihan yang tersedia.'
                            : 'Tidak ada hasil untuk "$_query"',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PotColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isSelected = _isSelected(item);
                      final label = widget.itemLabel(item);
                      final sublabel = widget.itemSublabel?.call(item);

                      return InkWell(
                        onTap: () => Navigator.of(context).pop(item),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? PotColors.accentRed.withValues(alpha: 0.08)
                                : PotColors.pureWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? PotColors.primaryRed.withValues(alpha: 0.4)
                                  : PotColors.warmBorder,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected
                                            ? PotColors.primaryRed
                                            : PotColors.textDark,
                                      ),
                                    ),
                                    if (sublabel != null && sublabel.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        sublabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: PotColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: PotColors.primaryRed,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// A form field container that opens [SearchablePickerModal] on tap.
class SearchablePickerField<T> extends StatelessWidget {
  final String label;
  final String title;
  final String placeholder;
  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final String? Function(T)? itemSublabel;
  final ValueChanged<T?> onChanged;
  final bool Function(T, T)? equalityChecker;
  final IconData? prefixIcon;
  final bool enabled;

  const SearchablePickerField({
    super.key,
    required this.label,
    required this.title,
    required this.placeholder,
    required this.items,
    required this.value,
    required this.itemLabel,
    this.itemSublabel,
    required this.onChanged,
    this.equalityChecker,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final displayLabel = hasValue ? itemLabel(value as T) : placeholder;
    final displaySublabel = hasValue ? itemSublabel?.call(value as T) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: PotColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: enabled
              ? () async {
                  final picked = await SearchablePickerModal.show<T>(
                    context: context,
                    title: title,
                    searchPlaceholder: placeholder,
                    items: items,
                    itemLabel: itemLabel,
                    itemSublabel: itemSublabel,
                    selectedItem: value,
                    equalityChecker: equalityChecker,
                  );
                  if (picked != null) {
                    onChanged(picked);
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: enabled ? PotColors.pureWhite : PotColors.cardCream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PotColors.warmBorder),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    size: 18,
                    color: hasValue ? PotColors.primaryRed : PotColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                          color: hasValue ? PotColors.textDark : PotColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (displaySublabel != null && displaySublabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          displaySublabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: PotColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Iconsax.arrow_down_1,
                  size: 16,
                  color: PotColors.primaryRed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
