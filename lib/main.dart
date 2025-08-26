import 'package:flutter/material.dart';

import 'database_service.dart';
import 'mood_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Journal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbService = DatabaseService();
  final descriptionController = TextEditingController();
  int _scale = 3;

  //TODO - Insert showBottomSheet
  void showBottomSheet(String functionTitle, Function()? onPressed) {
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Select an emoji that represents your feeling'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.sentiment_very_dissatisfied),
                  iconSize: 48,
                  color: Colors.red,
                  onPressed: () {
                    _scale = 1;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.sentiment_dissatisfied),
                  iconSize: 48,
                  color: Colors.orange,
                  onPressed: () {
                    _scale = 2;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.sentiment_neutral),
                  iconSize: 48,
                  color: Colors.blue,
                  onPressed: () {
                    _scale = 3;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.sentiment_satisfied),
                  iconSize: 48,
                  color: Colors.purple,
                  onPressed: () {
                    _scale = 4;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.sentiment_very_satisfied),
                  iconSize: 48,
                  color: Colors.green,
                  onPressed: () {
                    _scale = 5;
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onPressed, child: Text(functionTitle)),
          ],
        ),
      ),
    );
  }

  void addMood() {
    showBottomSheet('Add Mood', () async {
      var mood = MoodModel(
        id: 0,
        scale: _scale,
        description: descriptionController.text,
        createdOn: '',
      );
      dbService.insertMood(mood);
      //update ui
      setState(() {});
      //Clear controller
      descriptionController.clear();
      Navigator.of(context).pop();
    });
  }

  void editMood(MoodModel mood) {
    descriptionController.text = mood.description;
    showBottomSheet('Edit Mood', () async {
      var updatedMood = MoodModel(
        id: mood.id,
        scale: _scale,
        description: descriptionController.text,
        createdOn: mood.createdOn,
      );
      dbService.editMood(updatedMood);
      descriptionController.clear();
      setState(() {});
      Navigator.of(context).pop();
    });
  }

  void deleteMood(int id) {
    dbService.deleteMood(id);
    setState(() {});
  }

  //TODO - Modify the build function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo SQL')),
      body: FutureBuilder<List<MoodModel>>(
        future: dbService.getMood(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No record found'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: emojiIcon(snapshot.data![index].scale),
                  title: Text(snapshot.data![index].description),
                  subtitle: Text(snapshot.data![index].createdOn),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editMood(snapshot.data![index]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteMood(snapshot.data![index].id),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const Center(child: Text('No record found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => addMood(),
      ),
    );
  }

  Icon emojiIcon(int scale) {
    switch (scale) {
      case 1:
        return Icon(
          Icons.sentiment_very_dissatisfied,
          size: 48,
          color: Colors.red,
        );
      case 2:
        return Icon(
          Icons.sentiment_dissatisfied,
          size: 48,
          color: Colors.orange,
        );
      case 3:
        return Icon(Icons.sentiment_neutral, size: 48, color: Colors.blue);
      case 4:
        return Icon(
          Icons.sentiment_satisfied,
          size: 48,
          color: Colors.deepPurpleAccent,
        );
      default:
        return Icon(
          Icons.sentiment_very_satisfied,
          size: 48,
          color: Colors.green,
        );
    }
  }
}
