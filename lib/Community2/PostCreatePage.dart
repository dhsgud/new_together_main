import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCreatePage extends StatefulWidget {
  final String? userID;

  PostCreatePage({Key? key, this.userID}) : super(key: key);

  @override
  _PostCreatePageState createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => _savePost(context),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }

  void _savePost(BuildContext context) {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("board").add({
        "id": widget.userID ?? Uuid().v4(),
        "title": _titleController.text,
        "description": _descriptionController.text,
        "timestamp": DateTime.now()
      }).then((response) {
        Navigator.pop(context);
      }).catchError((error) {
        print(error);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
