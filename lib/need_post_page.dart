import 'package:flutter/material.dart';

class NeedPostPage extends StatefulWidget {
  final bool isCustomer;
  const NeedPostPage({super.key, required this.isCustomer});

  @override
  State<NeedPostPage> createState() => _NeedPostPageState();
}

class _NeedPostPageState extends State<NeedPostPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String imagePath = '';
  String location = 'Auto-fetched location';
  String selectedTime = 'Today';
  String selectedCategory = 'Others';

  List<String> timeOptions = ['In 2 hours', 'Today', 'Tomorrow'];
  List<String> categoryOptions = [
    'Tuitions',
    'House Help',
    'Pickles / Snacks',
    'Craft Work',
    'Tailoring',
    'Others'
  ];

  List<Map<String, String>> availableNeeds = [
    {
      'title': 'Need Maths Tuition',
      'description': 'Urgent need for class 9 student',
      'location': 'Hyderabad',
      'time': 'Today'
    },
    {
      'title': 'Blouse Stitching',
      'description': '3 pieces within 3 days',
      'location': 'Warangal',
      'time': 'Tomorrow'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCustomer ? 'Post a Need' : 'Available Needs'),
      ),
      body: widget.isCustomer ? buildPostForm() : buildAvailableNeeds(),
    );
  }

  Widget buildPostForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) => title = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
            ),
            const SizedBox(height: 10),
            Text('Image: (optional, mock upload)'),
            ElevatedButton(
              onPressed: () => setState(() => imagePath = 'mock_image.png'),
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 10),
            Text('Location: $location'),
            DropdownButtonFormField(
              value: selectedTime,
              items: timeOptions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => selectedTime = val!),
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            DropdownButtonFormField(
              value: selectedCategory,
              items: categoryOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => selectedCategory = val!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Posted Successfully!')),
                  );
                }
              },
              child: const Text('Post Need'),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAvailableNeeds() {
    return ListView.builder(
      itemCount: availableNeeds.length,
      itemBuilder: (context, index) {
        final item = availableNeeds[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item['description']!),
                Text('Location: ${item['location']}'),
                Text('Time: ${item['time']}'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          availableNeeds.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}