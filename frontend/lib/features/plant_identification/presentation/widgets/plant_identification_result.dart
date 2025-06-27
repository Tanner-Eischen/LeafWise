import 'package:flutter/material.dart';
import 'package:plant_social/features/plant_identification/models/plant_identification_models.dart';
import 'package:plant_social/core/theme/app_theme.dart';

class PlantIdentificationResult extends StatelessWidget {
  final PlantIdentification identification;
  final VoidCallback onClose;
  final VoidCallback onSaveToCollection;

  const PlantIdentificationResult({
    super.key,
    required this.identification,
    required this.onClose,
    required this.onSaveToCollection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plant Identified!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(identification.confidence * 100).toInt()}% confidence',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plant names
                    _buildPlantNames(theme),
                    const SizedBox(height: 24),

                    // Confidence indicator
                    _buildConfidenceIndicator(theme),
                    const SizedBox(height: 24),

                    // Care information
                    _buildCareInfo(theme),
                    const SizedBox(height: 24),

                    // Alternative names
                    if (identification.alternativeNames.isNotEmpty)
                      _buildAlternativeNames(theme),

                    // Description
                    if (identification.description != null)
                      _buildDescription(theme),

                    const SizedBox(height: 100), // Space for buttons
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Share identification
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onSaveToCollection,
                      icon: const Icon(Icons.add),
                      label: const Text('Add to Collection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantNames(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          identification.commonName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          identification.scientificName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator(ThemeData theme) {
    final confidence = identification.confidence;
    Color confidenceColor;
    String confidenceText;

    if (confidence >= 0.8) {
      confidenceColor = Colors.green;
      confidenceText = 'High Confidence';
    } else if (confidence >= 0.6) {
      confidenceColor = Colors.orange;
      confidenceText = 'Medium Confidence';
    } else {
      confidenceColor = Colors.red;
      confidenceText = 'Low Confidence';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Confidence: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              confidenceText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: confidenceColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
        ),
      ],
    );
  }

  Widget _buildCareInfo(ThemeData theme) {
    final careInfo = identification.careInfo;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Care Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCareItem(Icons.wb_sunny, 'Light', careInfo.lightRequirement, theme),
        _buildCareItem(Icons.water_drop, 'Water', careInfo.waterFrequency, theme),
        _buildCareItem(Icons.trending_up, 'Care Level', careInfo.careLevel, theme),
        if (careInfo.humidity != null)
          _buildCareItem(Icons.opacity, 'Humidity', careInfo.humidity!, theme),
        if (careInfo.temperature != null)
          _buildCareItem(Icons.thermostat, 'Temperature', careInfo.temperature!, theme),
        if (careInfo.toxicity != null)
          _buildCareItem(Icons.warning, 'Toxicity', careInfo.toxicity!, theme),
      ],
    );
  }

  Widget _buildCareItem(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeNames(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Also known as:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: identification.alternativeNames.map((name) {
            return Chip(
              label: Text(
                name,
                style: theme.textTheme.bodySmall,
              ),
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              side: BorderSide.none,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          identification.description!,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}