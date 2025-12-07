import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final String? titleOnConfirm;
  final String titleOnCancel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onClose;
  final bool isScrollable;
  final ValueNotifier<bool>? isConfirmEnabledNotifier;
  final bool isLoading;

  const ConfirmationDialog({
    super.key,
    this.title = 'Confirmación',
    required this.child,
    this.titleOnConfirm,
    this.titleOnCancel = 'Cancelar',
    required this.onConfirm,
    required this.onCancel,
    required this.onClose,
    this.isScrollable = false,
    this.isConfirmEnabledNotifier,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      backgroundColor: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.4,
              maxHeight: constraints.maxHeight * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.grey, height: 1.5),
                const SizedBox(height: 16),
                Flexible(
                  child: isScrollable
                      ? SingleChildScrollView(child: child)
                      : child,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(titleOnCancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (titleOnConfirm != null)
                      Expanded(
                        child: isConfirmEnabledNotifier != null
                            ? ValueListenableBuilder<bool>(
                                valueListenable: isConfirmEnabledNotifier!,
                                builder: (context, isEnabled, child) {
                                  return ElevatedButton(
                                    onPressed: isEnabled ? onConfirm : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(titleOnConfirm!),
                                  );
                                },
                              )
                            : ElevatedButton(
                                onPressed: onConfirm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(titleOnConfirm!),
                              ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Función para mostrar el diálogo
void showConfirmationDialog(
  BuildContext context, {
  String title = 'Confirmación',
  Widget? child,
  String? content,
  String? confirmText,
  String? cancelText,
  String closeText = 'Cerrar',
  required VoidCallback onConfirm,
  required VoidCallback onCancel,
  required VoidCallback onClose,
  bool isScrollable = false,
  ValueNotifier<bool>? isConfirmEnabledNotifier,
  bool isLoading = false,
}) {
  final dialogChild =
      child ?? (content != null ? Text(content) : const Text('¿Estás seguro?'));
  showDialog(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: title,
      child: dialogChild,
      titleOnConfirm: confirmText,
      titleOnCancel: cancelText ?? 'Cancelar',
      onConfirm: onConfirm,
      onCancel: onCancel,
      onClose: onClose,
      isScrollable: isScrollable,
      isConfirmEnabledNotifier: isConfirmEnabledNotifier,
      isLoading: isLoading,
    ),
  );
}
