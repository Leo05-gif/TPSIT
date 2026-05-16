import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models/ClubModel.dart';
import '../Models/ClubMembershipModel.dart';
import '../Models/UserModel.dart';
import '../Models/UserTokenModel.dart';
import '../Models/LocalDatabase.dart';
import '../Requests/ClubRequests.dart';
import '../Pages/OptionsPage.dart';
import '../Pages/CreateClubPage.dart';
import '../Pages/ClubPage.dart';

class MainPage extends StatefulWidget {
  final UserModel user;
  final UserTokenModel token;

  const MainPage({super.key, required this.user, required this.token});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<ClubModel> _clubs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    setState(() => _loading = true);
    try {
      final res  = await ClubRequests().get(widget.token.token);
      final body = jsonDecode(res.body);

      if (body['success'] == true) {
        final db     = LocalDatabase();
        final List   raw   = body['data'];
        final clubs  = <ClubModel>[];

        for (final row in raw) {
          final club = ClubModel.fromMap(row);
          await db.upsertClub(club);
          await db.upsertMembership(ClubMembershipModel(
            userId:   widget.user.id,
            clubId:   club.id,
            joinedIn: DateTime.parse(row['joined_in'] as String),
          ));
          clubs.add(club);
        }

        setState(() => _clubs = clubs);
      } else {
        await _loadFromLocal();
      }
    } catch (_) {
      await _loadFromLocal();
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadFromLocal() async {
    final clubs = await LocalDatabase().getAllClubs();
    setState(() => _clubs = clubs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Clubs'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OptionsPage(user: widget.user, token: widget.token),
              ),
            ),
            child: Text(widget.user.username),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadClubs,
              child: _clubs.isEmpty
                  ? const Center(child: Text('No clubs yet. Create one!'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _clubs.length,
                      itemBuilder: (context, index) {
                        final club    = _clubs[index];
                        final isOwner = club.ownerId == widget.user.id;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final changed = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => ClubPage(
                                    club: club,
                                    user: widget.user,
                                    token: widget.token,
                                    isOwner: isOwner,
                                  ),
                                ),
                              );
                              if (changed == true) _loadClubs();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                club.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            if (isOwner)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Owner',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          club.description,
                                          style: const TextStyle(
                                              fontSize: 13, color: Colors.grey),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => CreateClubPage(user: widget.user, token: widget.token),
            ),
          );
          if (created == true) _loadClubs();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}