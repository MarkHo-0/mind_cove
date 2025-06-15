import 'package:flutter/material.dart';

Future<void> showLocationMaker(BuildContext parentContext, TextEditingController inputController) async {
  return showModalBottomSheet<void>(
    context: parentContext,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter Location', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16.0),
            TextField(
              autofocus: true,
              decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'e.g., Paris, France'),
              controller: inputController,
              onSubmitted: (value) {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 16.0),
            FutureBuilder<List<String>>(
              future: loadPreviousLocations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
                  return SizedBox.shrink();
                }

                final locations = snapshot.data!;
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: locations.length,
                    itemBuilder: (listContext, index) {
                      return ListTile(
                        title: Text(locations[index]),
                        onTap: () {
                          inputController.text = locations[index];
                          Navigator.of(listContext).pop();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<List<String>> loadPreviousLocations() async {
  // TODO: Replace with actual logic to load previous locations from a database.
  await Future.delayed(Duration(milliseconds: 300));
  return ["Kowloon, Hong Kong", "Paris, France", "New York, USA", "Tokyo, Japan"];
}
