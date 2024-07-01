import 'package:flutter/material.dart';

class SyllableGridPage extends StatelessWidget {
  final List<String> syllables = [
    "ka", "ki", "ku", "ke", "ko",
    "ba", "bi", "bu", "be", "bo",
    "ta", "ti", "tu", "te", "to",
    "da", "di", "du", "de", "do",
    "la", "li", "lu", "le", "lo",
    "ma", "mi", "mu", "me", "mo",
    "na", "ni", "nu", "ne", "no",
    "pa", "pi", "pu", "pe", "po",
    "sa", "si", "su", "se", "so",
    "ya", "yi", "yu", "ye", "yo",
    "ra", "ri", "ru", "re", "ro",
    "wa", "wi", "wu", "we", "wo"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Indonesian Syllable Grid'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Syllables:',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: syllables.length,
                itemBuilder: (context, index) {
                  return _buildCard(syllables[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String syllable) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          syllable,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
