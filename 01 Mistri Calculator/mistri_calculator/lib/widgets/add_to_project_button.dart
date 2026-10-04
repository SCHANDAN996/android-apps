import 'package:flutter/material.dart';
import '../core/constants/strings.dart';
import '../core/models/project_item.dart';
import '../core/services/storage_service.dart';
import '../core/theme/app_theme.dart';
import '../screens/project_screen.dart';

/// "Add to My House" — keeps the result on screen in the user's project.
///
/// Once added it turns into a tick, so the same result can't be added twice;
/// a new [result] brings the button back.
class AddToProjectButton extends StatefulWidget {
  final StorageService storage;

  /// The result currently on screen — only its identity is used.
  final Object result;
  final ProjectItem Function() buildItem;

  const AddToProjectButton({
    super.key,
    required this.storage,
    required this.result,
    required this.buildItem,
  });

  @override
  State<AddToProjectButton> createState() => _AddToProjectButtonState();
}

class _AddToProjectButtonState extends State<AddToProjectButton> {
  Object? _addedFor;

  bool get _added => identical(_addedFor, widget.result);

  Future<void> _add() async {
    final result = widget.result;
    setState(() => _addedFor = result);
    await widget.storage.addProjectItem(widget.buildItem());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('addedToProject')),
        action: SnackBarAction(
          label: AppStrings.get('view'),
          textColor: AppColors.accentLight,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectScreen(storage: widget.storage),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: _added ? null : _add,
        icon: Icon(_added ? Icons.check_rounded : Icons.home_work_outlined),
        label: Text(
          AppStrings.get(_added ? 'addedToProject' : 'addToProject'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
