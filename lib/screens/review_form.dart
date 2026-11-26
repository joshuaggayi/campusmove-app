import 'package:flutter/material.dart';

import '../db.dart';
import '../session.dart';
import '../widgets.dart';

/// Functionality 3: rating and comment form, shown in a bottom sheet.
/// Pops with `true` once the review has been saved.
class ReviewForm extends StatefulWidget {
  final int routeId;

  const ReviewForm({super.key, required this.routeId});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _comment = TextEditingController();
  int _rating = 0;
  String _tag = kReviewTags.first;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Tap a star to give a rating.');
      return;
    }
    if (_comment.text.trim().isEmpty) {
      setState(() => _error = 'Write a short comment.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    await AppDatabase.instance.addReview(
      routeId: widget.routeId,
      userId: session.user!.id,
      rating: _rating,
      comment: _comment.text,
      tag: _tag,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rate this route',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            StarPicker(
              rating: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final t in kReviewTags)
                  ChoiceChip(
                    label: Text(t),
                    selected: _tag == t,
                    onSelected: (_) => setState(() => _tag = t),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comment,
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Comment on safety, fare or crowding',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Submit review'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
