import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../models/club.dart';

class MyBagScreen extends StatelessWidget {
  const MyBagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = BogeybeastGolfScope.of(context);
    final theme = Theme.of(context);
    final List<Club> clubs = store.clubs;
    final int totalCount = clubs.length + 1; // +1 for putter

    return Scaffold(
      appBar: AppBar(
        title: Text('My Bag ($totalCount)'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClubEditor(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: clubs.length + 1, // +1 for putter
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          if (index == clubs.length) {
            return const _PutterTile();
          }
          final Club club = clubs[index];
          return Dismissible(
            key: ValueKey<String>(club.id ?? '${club.name}_$index'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                    context: context,
                    builder: (BuildContext ctx) => AlertDialog(
                      title: const Text('Remove club?'),
                      content:
                          Text('Remove ${club.name} from your bag?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'Remove',
                            style: TextStyle(
                              color: Theme.of(ctx).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) ??
                  false;
            },
            onDismissed: (_) {
              BogeybeastGolfScope.of(context).removeClub(club);
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
            ),
            child: GestureDetector(
              onTap: () => _showClubEditor(context, club: club),
              child: _ClubTile(club: club),
            ),
          );
        },
      ),
    );
  }

  void _showClubEditor(BuildContext context, {Club? club}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClubEditorSheet(
        club: club,
        onSave: (Club edited) {
          final store = BogeybeastGolfScope.of(context);
          if (club != null) {
            store.updateClub(club, edited);
          } else {
            store.addClub(edited);
          }
        },
      ),
    );
  }
}

class _PutterTile extends StatelessWidget {
  const _PutterTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF243024),
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Text(
        'Putter',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  const _ClubTile({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasDistances =
        club.carryDistance != null || club.totalDistance != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243024)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  club.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasDistances) ...<Widget>[
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      if (club.carryDistance != null) ...<Widget>[
                        _DistanceLabel(
                            label: 'Carry', value: '${club.carryDistance}m'),
                        const SizedBox(width: 12),
                      ],
                      if (club.totalDistance != null)
                        _DistanceLabel(
                            label: 'Total', value: '${club.totalDistance}m'),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.edit_outlined,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _DistanceLabel extends StatelessWidget {
  const _DistanceLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ClubEditorSheet extends StatefulWidget {
  const _ClubEditorSheet({this.club, required this.onSave});

  final Club? club;
  final ValueChanged<Club> onSave;

  @override
  State<_ClubEditorSheet> createState() => _ClubEditorSheetState();
}

class _ClubEditorSheetState extends State<_ClubEditorSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _carryCtrl;
  late final TextEditingController _totalCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.club?.name ?? '');
    _carryCtrl = TextEditingController(
      text: widget.club?.carryDistance?.toString() ?? '',
    );
    _totalCtrl = TextEditingController(
      text: widget.club?.totalDistance?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _carryCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final String name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    widget.onSave(Club(
      id: widget.club?.id,
      name: name,
      carryDistance: int.tryParse(_carryCtrl.text.trim()),
      totalDistance: int.tryParse(_totalCtrl.text.trim()),
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    final bool isEditing = widget.club != null;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: Color(0xFF243024)),
          left: BorderSide(color: Color(0xFF243024)),
          right: BorderSide(color: Color(0xFF243024)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEditing ? 'Edit Club' : 'Add Club',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Club name',
              hintText: 'e.g. Driver, 7i, PW',
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: !isEditing,
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _carryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Carry (m)',
                    hintText: 'Optional',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _totalCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Total (m)',
                    hintText: 'Optional',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Text(isEditing ? 'Save' : 'Add Club'),
          ),
        ],
      ),
    );
  }
}
