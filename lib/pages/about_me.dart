import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMe extends StatelessWidget {
  const AboutMe({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About me'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: const Text('My Portfolio'),
                onTap: () => launchUrl(
                  Uri(path: 'https://parbhatsharma.in/'),
                ),
              ),
              InkWell(
                child: const Text('Twitter'),
                onTap: () => launchUrl(
                  Uri(path: 'https://twitter.com/ParbhatSharma29'),
                ),
              ),
              InkWell(
                child: const Text('LinkedIn'),
                onTap: () => launchUrl(
                  Uri(
                      path:
                          'https://www.linkedin.com/in/parbhat-sharma-7750b4270/'),
                ),
              ),
              Center(
                child: Text(
                  'Developed by Parbhat Sharma',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
