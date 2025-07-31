import 'package:flutter/material.dart';
import 'package:lammah/core/utils/auth_string.dart';

class PolicyOfServiceWidget extends StatelessWidget {
  const PolicyOfServiceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSectionTitle(AuthString.intr),
            _buildSectionContent(AuthString.servicetext0),
            const SizedBox(height: 20),

            _buildSectionTitle(AuthString.res),
            _buildSectionContent(AuthString.servicetext),
            const SizedBox(height: 20),

            _buildSectionTitle(AuthString.idea),
            _buildSectionContent(AuthString.servicetext1),
            const SizedBox(height: 20),

            _buildSectionTitle(AuthString.end),
            _buildSectionContent(AuthString.servicetext2),
            const SizedBox(height: 20),

            _buildSectionTitle(AuthString.free),
            _buildSectionContent(AuthString.servicetext3),
            const SizedBox(height: 20),

            _buildSectionTitle(AuthString.resService),
            _buildSectionContent(AuthString.sendService),
            const SizedBox(height: 40),

            Center(
              child: Text(
                AuthString.noteService,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
      child: Text(
        content,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }
}
