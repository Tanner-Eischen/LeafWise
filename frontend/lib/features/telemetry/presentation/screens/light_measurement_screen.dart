import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/modules/light_meter/index.dart';

/// Light Measurement Screen
///
/// This screen allows users to measure light intensity using the device's
/// ambient light sensor or camera. It displays the current light reading in
/// lux and estimated PPFD values, and allows users to save readings to the
/// telemetry history.
class LightMeasurementScreen extends ConsumerStatefulWidget {
  const LightMeasurementScreen({super.key});

  @override
  ConsumerState<LightMeasurementScreen> createState() =>
      _LightMeasurementScreenState();
}

class _LightMeasurementScreenState
    extends ConsumerState<LightMeasurementScreen> {
  double? _currentLux;
  double? _currentPpfd;
  bool _isMeasuring = false;
  String _selectedLightSource = 'sunlight';
  String? _selectedPlantId;
  String? _locationTag;
  String _errorMessage = '';

  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  /// Measures light using the preferred strategy
  Future<void> _measureLight() async {
    setState(() {
      _isMeasuring = true;
      _errorMessage = '';
    });

    try {
      final lightMeter = LightMeter();

      // Get the best available strategy
      final bestStrategy = await lightMeter.getBestAvailableStrategy();
      await lightMeter.initialize(bestStrategy);

      // Measure light using the current strategy
      final luxValue = await lightMeter.measureLux();

      // Convert lux to PPFD based on selected light source
      final ppfdValue = lightMeter.luxToPpfd(
        luxValue,
        lightSource: _selectedLightSource,
      );

      setState(() {
        _currentLux = luxValue;
        _currentPpfd = ppfdValue;
        _isMeasuring = false;
      });

      // Clean up resources
      await lightMeter.dispose();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error measuring light: ${e.toString()}';
        _isMeasuring = false;
      });
    }
  }

  /// Saves the current reading to history
  Future<void> _saveReading() async {
    if (_currentLux == null || _currentPpfd == null) return;

    // TODO: Implement saving to telemetry history
    // Create a reading object with current values
    final reading = {
      'lux': _currentLux,
      'ppfd': _currentPpfd,
      'source': await LightMeter().getCurrentStrategyName(),
      'timestamp': DateTime.now().toIso8601String(),
      'location_tag': _locationTag,
      'light_source': _selectedLightSource,
      'plant_id': _selectedPlantId,
    };

    // Here we would save the reading to a database or state management

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reading saved to history')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Light Measurement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Light source selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Light Source',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLightSource,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'sunlight', child: Text('Sunlight')),
                        DropdownMenuItem(value: 'overcast', child: Text('Overcast Daylight')),
                        DropdownMenuItem(value: 'shade', child: Text('Shade')),
                        DropdownMenuItem(value: 'led_full_spectrum', child: Text('LED Full Spectrum')),
                        DropdownMenuItem(value: 'led_red_blue', child: Text('LED Red/Blue')),
                        DropdownMenuItem(value: 'fluorescent', child: Text('Fluorescent')),
                        DropdownMenuItem(value: 'incandescent', child: Text('Incandescent')),
                        DropdownMenuItem(value: 'cfl', child: Text('CFL')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedLightSource = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location (Optional)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g., South window, Kitchen counter',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _locationTag = value.isEmpty ? null : value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Measurement button
            ElevatedButton(
              onPressed: _isMeasuring ? null : _measureLight,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isMeasuring
                  ? const CircularProgressIndicator()
                  : const Text('MEASURE LIGHT'),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],

            if (_currentLux != null && _currentPpfd != null) ...[
              const SizedBox(height: 24),

              // Results card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Measurement Results',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow(
                        'Light Intensity',
                        '${_currentLux!.toStringAsFixed(1)} lux',
                        isHighlight: true,
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'PPFD (Converted)',
                        '${_currentPpfd!.toStringAsFixed(1)} μmol/m²/s',
                        isHighlight: true,
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        'Light Source',
                        _getLightSourceDisplayName(_selectedLightSource),
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        'Light Quality',
                        LightMeter().getLightIntensityDescription(
                          _currentPpfd!,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        'Suitable Plants',
                        LightMeter().getPlantRecommendation(_currentPpfd!),
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        'Measured At', 
                        _formatTimestamp(DateTime.now()),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveReading,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text('SAVE TO HISTORY'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isHighlight ? Theme.of(context).primaryColor : null,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlight ? 16 : 14,
              color: isHighlight ? Theme.of(context).primaryColor : null,
            ),
          ),
        ),
      ],
    );
  }

  /// Get display name for light source
  String _getLightSourceDisplayName(String lightSource) {
    const displayNames = {
      'sunlight': 'Sunlight',
      'overcast': 'Overcast Daylight',
      'shade': 'Shade',
      'led_full_spectrum': 'LED Full Spectrum',
      'led_red_blue': 'LED Red/Blue',
      'fluorescent': 'Fluorescent',
      'hps': 'High Pressure Sodium',
      'mh': 'Metal Halide',
      'incandescent': 'Incandescent',
      'cfl': 'Compact Fluorescent',
    };
    return displayNames[lightSource] ?? lightSource;
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}
