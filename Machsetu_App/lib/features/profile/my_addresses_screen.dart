import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'address_form_screen.dart';
import 'data/address_store.dart';

/// Saved delivery addresses — add, edit, delete, and pick the default one.
class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key, this.selectMode = false});

  /// When true the page acts as a picker (opened from checkout), so tapping a
  /// card returns that address instead of opening the editor.
  final bool selectMode;

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final _store = AddressStore.instance;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _store.load(force: force);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result.ok ? null : result.message;
    });
  }

  Future<void> _openEditor([SavedAddress? existing]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddressFormScreen(existing: existing)),
    );
    if (saved == true && mounted) setState(() {});
  }

  Future<void> _delete(SavedAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this address?'),
        content: Text(
          '"${address.label}" will be removed from your account. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await _store.remove(address.id);
    if (!mounted) return;
    setState(() {});
    _toast(result.ok ? 'Address deleted' : (result.message ?? 'Delete failed'));
  }

  Future<void> _makeDefault(SavedAddress address) async {
    final result = await _store.makeDefault(address.id);
    if (!mounted) return;
    setState(() {});
    if (!result.ok) _toast(result.message ?? 'Could not update');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final addresses = _store.addresses;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Select Address' : 'My Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-address-fab',
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add address'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(message: _error!, onRetry: () => _load(force: true))
          : addresses.isEmpty
          ? _EmptyState(onAdd: () => _openEditor())
          : RefreshIndicator(
              onRefresh: () => _load(force: true),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: addresses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return _AddressCard(
                    address: address,
                    selectMode: widget.selectMode,
                    onTap: widget.selectMode
                        ? () => Navigator.of(context).pop(address)
                        : () => _openEditor(address),
                    onEdit: () => _openEditor(address),
                    onDelete: () => _delete(address),
                    onMakeDefault: address.isDefault
                        ? null
                        : () => _makeDefault(address),
                  );
                },
              ),
            ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selectMode,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onMakeDefault,
  });

  final SavedAddress address;
  final bool selectMode;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMakeDefault;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: address.isDefault ? AppColors.brandBlue : AppColors.border,
            width: address.isDefault ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _iconFor(address.label),
                  size: 18,
                  color: AppColors.brandBlue,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    address.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        fontSize: 9.5,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (selectMode)
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textMuted,
                  )
                else
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                        case 'default':
                          onMakeDefault?.call();
                        case 'delete':
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (onMakeDefault != null)
                        const PopupMenuItem(
                          value: 'default',
                          child: Text('Set as default'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                address.multiLine,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (address.contactName.isNotEmpty ||
                address.contactPhone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      [
                        address.contactName,
                        address.contactPhone,
                      ].where((p) => p.isNotEmpty).join(' - '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(String label) {
    final value = label.toLowerCase();
    if (value.contains('home')) return Icons.home_outlined;
    if (value.contains('factory') || value.contains('plant')) {
      return Icons.factory_outlined;
    }
    if (value.contains('office') || value.contains('work')) {
      return Icons.apartment_outlined;
    }
    if (value.contains('warehouse') || value.contains('godown')) {
      return Icons.warehouse_outlined;
    }
    return Icons.location_on_outlined;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 34,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No addresses saved',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add the site where machines should be delivered and installed. '
              'You can save more than one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add your first address'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
