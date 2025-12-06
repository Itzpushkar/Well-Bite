import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityTab extends StatefulWidget {
  final Color background;

  const CommunityTab({Key? key, required this.background}) : super(key: key);

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab>
    with SingleTickerProviderStateMixin {
  final TextEditingController _tipController = TextEditingController();
  final List<String> defaultTips = [
    '💧 Drink enough water daily.',
    '🥗 Eat a balanced diet.',
    '🏃‍♂️ Exercise regularly.',
    '😴 Sleep 8 hours.',
    '🧘‍♂️ Meditate daily.',
  ];

  bool isHover = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  Future<void> _submitTip() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _tipController.text.trim().isEmpty) return;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    await FirebaseFirestore.instance.collection('community_posts').add({
      'userId': user.uid,
      'name': userData['name'] ?? 'Anonymous',
      'tip': _tipController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _tipController.clear();
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete the post?'),
        actions: [
          ElevatedButton(
            onPressed: ()  {
              Navigator.of(context).pop();

            },

            child: const Text('No', style: TextStyle(color: Colors.black),),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseFirestore.instance
                  .collection('community_posts')
                  .doc(docId)
                  .delete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: null,
      backgroundColor: widget.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔽 Posts
            Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id;
                        final currentUser = FirebaseAuth.instance.currentUser;
                        final isOwnPost = currentUser != null && currentUser.uid == data['userId'];

                        return ScaleTransition(
                          scale: _animation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🧍 User image (left)
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: AssetImage('assets/user.png'),
                                ),
                                const SizedBox(width: 12),

                                // 📦 Content container (right)
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                data['name'] ?? 'User',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            if (isOwnPost)
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, size: 20),
                                                onPressed: () => _showDeleteDialog(docId),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          data['tip'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatTimestamp(data['timestamp']),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },

                  );
                },
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(

                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ✍️ Input and send row (now comes first)
                      Row(
                        children: [
                          // ✏️ Text input (takes most of the width)
                          Expanded(

                            child: Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.only(left: 16, right:16, top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  )
                                ],
                              ),
                              child: TextField(
                                controller: _tipController,
                                decoration: InputDecoration(
                                  hintText: 'Write your tip...',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  suffixIcon: MouseRegion(
                                    onEnter: (_) => setState(() => isHover = true),
                                    onExit: (_) => setState(() => isHover = false),
                                    child: GestureDetector(
                                      onTap: _submitTip,
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 4, bottom: 6, left: 1),
                                        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top:6),
                                        decoration: BoxDecoration(
                                          color: isHover ? Colors.green.withOpacity(0.1) : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.send,
                                          color: isHover ? Colors.green[800] : Colors.green,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              ),
                            ),
                          ),


                          const SizedBox(width: 10),


                        ],
                      ),


                      const SizedBox(height: 14),

                      // 💡 Default tips with chip style (now below input)
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: defaultTips.map((tip) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: ActionChip(
                                  backgroundColor: Colors.teal.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  label: Text(tip),
                                  onPressed: () {
                                    _tipController.text = tip;
                                  },
                                  elevation: 2,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final dt = timestamp.toDate();
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
