import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMe extends StatelessWidget {
  const AboutMe({super.key});

  void _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url),
            mode: LaunchMode.platformDefault,
            webViewConfiguration: WebViewConfiguration(enableJavaScript: true));
      } else {
        throw 'Could not launch $url';
      }
    } catch (error) {
      throw new Error();
    }
  }

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
              ElevatedButton(
                onPressed: () => _launchUrl('https://parbhatsharma.in/'),
                child: Text('Parbhat Sharma\'s Portfolio'),
              ),
              ElevatedButton(
                onPressed: () =>
                    _launchUrl('https://twitter.com/ParbhatSharma29'),
                child: Text('Parbhat Sharma\'s Twitter'),
              ),
              ElevatedButton(
                onPressed: () => _launchUrl(
                    'https://www.linkedin.com/in/parbhat-sharma-7750b4270/'),
                child: Text('Parbhat Sharma\'s LinkedIn'),
              ),
              Spacer(),
              Center(
                child: Text(
                  'Developed by Parbhat Sharma',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
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
