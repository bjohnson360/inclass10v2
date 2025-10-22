import 'package:flutter/material.dart';
import 'models.dart';
import 'repos.dart';
import 'db.dart';

class CardsScreen extends StatefulWidget {
  final FolderModel folder;
  const CardsScreen({super.key, required this.folder});
  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final cardsRepo = CardRepository();
  final foldersRepo = FolderRepository();
  List<PlayingCard> cards = [];
  List<PlayingCard> deckForSuit = []; // unassigned cards of same suit

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final c = await cardsRepo.getByFolder(widget.folder.id!);
    final d = await cardsRepo.getUnassignedBySuit(widget.folder.name);
    setState(() { cards = c; deckForSuit = d; });
    await foldersRepo.updatePreviewToFirst(widget.folder.id!);
  }

  Future<void> _addCard(PlayingCard pc) async {
    final count = cards.length;
    if (count >= 6) {
      _showError('This folder can only hold 6 cards.');
      return;
    }
    await cardsRepo.assignToFolder(cardId: pc.id!, folderId: widget.folder.id!);
    await _refresh();
  }

  Future<void> _removeCard(PlayingCard pc) async {
    await cardsRepo.unassign(pc.id!);
    await _refresh();
  }

  void _showError(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Limit reached'),
      content: Text(msg),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final needsMin = cards.length < 3;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folder.name} (${cards.length})'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: deckForSuit.isEmpty ? null : () => _pickFromDeck(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (needsMin)
            const MaterialBanner(
              content: Text('You need at least 3 cards in this folder.'),
              actions: [SizedBox.shrink()],
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .8,
              ),
              itemCount: cards.length,
              itemBuilder: (context, i) {
                final pc = cards[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(child: Image.network(pc.imageUrl, fit: BoxFit.cover)),
                      ListTile(
                        title: Text(pc.name),
                        subtitle: Text(pc.suit),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeCard(pc),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromDeck() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: deckForSuit.length,
        itemBuilder: (context, i) {
          final pc = deckForSuit[i];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(pc.imageUrl)),
            title: Text('${pc.name} of ${pc.suit}'),
            onTap: () async {
              Navigator.pop(context);
              await _addCard(pc);
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
      ),
    );
  }
}
