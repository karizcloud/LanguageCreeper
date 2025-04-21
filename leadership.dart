import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';

class LeadershipBoard extends StatefulWidget {
  @override
  _LeadershipBoardState createState() => _LeadershipBoardState();
}

class _LeadershipBoardState extends State<LeadershipBoard> {
  List<Map<String, dynamic>> players = [];

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  void fetchLeaderboard() async {
    final snapshot = await FirebaseFirestore.instance.collection('names').get();
    final fetchedPlayers = snapshot.docs
        .map((doc) => {
      'name': doc['name'] ?? 'Unknown',
      'score': doc['score'] ?? 0,
    })
        .toList();

    fetchedPlayers.sort((a, b) => b['score'].compareTo(a['score'])); // Sort by highest score

    setState(() {
      players = fetchedPlayers;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBFADA),
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Color(0xFF1A4D2E),
      ),
      body: players.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 20),

          // Top 3 Players
          if (players.length >= 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTopPlayer(players[1], Colors.grey, 2),
                _buildTopPlayer(players[0], Colors.amber, 1),
                _buildTopPlayer(players[2], Colors.brown, 3),
              ],
            ),
          SizedBox(height: 20),

          // Remaining Players
          Expanded(
            child: ListView.builder(
              itemCount: players.length - 3,
              itemBuilder: (context, index) {
                final player = players[index + 3];
                return FadeInUp(
                  duration: Duration(milliseconds: 300 * (index + 1)),
                  child: Card(
                    color: Color(0xFF2C4711),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF3DB72A),
                        child: Text(
                          '${index + 4}',
                          style: TextStyle(color: Color(0xFF2C4711)),
                        ),
                      ),
                      title: Text(
                        player['name'],
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        '${player['score']} pts',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlayer(Map<String, dynamic> player, Color color, int rank) {
    return ElasticIn(
      duration: Duration(milliseconds: 600 * rank),
      child: Column(
        children: [
          Container(
            height: rank == 1 ? 120 : 100,
            width: rank == 1 ? 100 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                player['name'][0],
                style: TextStyle(fontSize: 30, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            player['name'],
            style: TextStyle(color: Color(0xFF2C4711), fontSize: rank == 1 ? 20 : 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '${player['score']} pts',
            style: TextStyle(color: Color(0xFF2C4711), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
