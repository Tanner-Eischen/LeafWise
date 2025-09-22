import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/features/care_plans/models/care_plan_models.dart';
import 'package:leafwise/features/care_plans/providers/care_plan_provider.dart';
import 'package:leafwise/features/plant_care/models/plant_care_models.dart';
import 'package:leafwise/features/plant_care/providers/plant_care_provider.dart';
import 'package:leafwise/core/widgets/loading_widget.dart';


/// Care Plan Generation Screen
///
/// Provides UI for generating new AI-powered care plans with customization options.
/// Features:
/// - Plant selection and context input
/// - Environmental data integration
/// - Generation progress with loading states
/// - Preview and confirmation of generated plans
class CarePlanGenerationScreen extends ConsumerStatefulWidget {
  final String? userPlantId;

  const CarePlanGenerationScreen({super.key, this.userPlantId});

  @override
  ConsumerState<CarePlanGenerationScreen> createState() =>
      _CarePlanGenerationScreenState();
}

class _CarePlanGenerationScreenState
    extends ConsumerState<CarePlanGenerationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _selectedPlantId;
  final List<String> _selectedFactors = [];
  bool _includeEnvironmentalData = true;
  bool _includeHistoricalData = true;
  bool _enableAdaptiveLearning = true;

  late AnimationController _loadingAnimationController;
  late Animation<double> _loadingAnimation;

  CarePlanGenerationResponse? _generatedPlan;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _selectedPlantId = widget.userPlantId;

    _loadingAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Load user plants if not specified
    if (widget.userPlantId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(plantCareProvider.notifier).loadUserPlants();
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carePlanState = ref.watch(carePlanProvider);
    final plantCareState = ref.watch(plantCareProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Care Plan'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _showPreview && _generatedPlan != null
          ? _buildPreviewView(theme)
          : _buildGenerationForm(theme, carePlanState, plantCareState),
    );
  }

  Widget _buildGenerationForm(
    ThemeData theme,
    CarePlanState carePlanState,
    PlantCareState plantCareState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(theme),
            const SizedBox(height: 24),

            // Plant selection
            if (widget.userPlantId == null)
              _buildPlantSelection(plantCareState, theme),

            const SizedBox(height: 20),

            // Generation options
            _buildGenerationOptions(theme),
            const SizedBox(height: 20),

            // Environmental factors
            _buildEnvironmentalFactors(theme),
            const SizedBox(height: 20),

            // Additional notes
            _buildAdditionalNotes(theme),
            const SizedBox(height: 32),

            // Generate button
            _buildGenerateButton(carePlanState, theme),

            // Loading state
            if (carePlanState.isGenerating) _buildLoadingState(theme),

            // Error state
            if (carePlanState.generateError != null)
              _buildErrorState(carePlanState.generateError!, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withAlpha(26),
            theme.primaryColor.withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI-Powered Care Plan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate personalized care recommendations\nbased on your plant\'s specific needs',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantSelection(PlantCareState plantCareState, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Plant',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (plantCareState.isLoadingPlants)
          const Center(child: LoadingWidget())
        else if (plantCareState.userPlants.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No plants found. Add a plant first to generate care plans.',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPlantId,
                hint: const Text('Choose a plant'),
                isExpanded: true,
                items: plantCareState.userPlants.map((plant) {
                  return DropdownMenuItem<String>(
                    value: plant.id,
                    child: Row(
                      children: [
                        Icon(Icons.eco, color: theme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                plant.nickname,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (plant.species != null)
                                Text(
                                  plant.species!.commonName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPlantId = value;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGenerationOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generation Options',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildOptionTile(
          'Include Environmental Data',
          'Use current weather and seasonal data',
          Icons.wb_sunny,
          _includeEnvironmentalData,
          (value) => setState(() => _includeEnvironmentalData = value),
          theme,
        ),
        _buildOptionTile(
          'Include Historical Data',
          'Consider past care logs and plant performance',
          Icons.history,
          _includeHistoricalData,
          (value) => setState(() => _includeHistoricalData = value),
          theme,
        ),
        _buildOptionTile(
          'Enable Adaptive Learning',
          'Allow AI to learn from your care patterns',
          Icons.psychology,
          _enableAdaptiveLearning,
          (value) => setState(() => _enableAdaptiveLearning = value),
          theme,
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        secondary: Icon(
          icon,
          color: value ? theme.primaryColor : Colors.grey[400],
        ),
        value: value,
        onChanged: onChanged,
        activeColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildEnvironmentalFactors(ThemeData theme) {
    final factors = [
      'Temperature',
      'Humidity',
      'Light Exposure',
      'Air Quality',
      'Seasonal Changes',
      'Location Climate',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Focus Areas',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select specific factors to emphasize in the care plan',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: factors.map((factor) {
            final isSelected = _selectedFactors.contains(factor);
            return FilterChip(
              label: Text(factor),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFactors.add(factor);
                  } else {
                    _selectedFactors.remove(factor);
                  }
                });
              },
              selectedColor: theme.primaryColor.withAlpha(51),
              checkmarkColor: theme.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalNotes(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Any specific concerns or preferences for your plant care',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'e.g., "Plant seems droopy lately" or "Prefer morning watering"',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(CarePlanState carePlanState, ThemeData theme) {
    final canGenerate = _selectedPlantId != null && !carePlanState.isGenerating;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canGenerate ? _generateCarePlan : null,
        icon: carePlanState.isGenerating
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(
          carePlanState.isGenerating ? 'Generating...' : 'Generate Care Plan',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _loadingAnimationController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _loadingAnimation.value,
                backgroundColor: theme.primaryColor.withAlpha(51),
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Generating your personalized care plan...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment as our AI analyzes your plant\'s needs and environmental data.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(51)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 16),
          Text(
            'Error Generating Care Plan',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red[700]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showPreview = false;
                _generatedPlan = null;
              });
              ref.read(carePlanProvider.notifier).clearGenerateError();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView(ThemeData theme) {
    if (_generatedPlan == null) {
      return Center(
        child: Text('No plan to preview.', style: theme.textTheme.titleMedium),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated Care Plan Preview',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generated Care Plan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generatedPlan!.carePlan.rationale.explanation ?? 'No description available',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recommended Schedule:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '- Watering: Every ${_generatedPlan!.carePlan.watering.intervalDays} days (${_generatedPlan!.carePlan.watering.amountMl}ml)',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '- Fertilizer: Every ${_generatedPlan!.carePlan.fertilizer.intervalDays} days (${_generatedPlan!.carePlan.fertilizer.type})',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '- Light: ${_generatedPlan!.carePlan.lightTarget.ppfdMin}-${_generatedPlan!.carePlan.lightTarget.ppfdMax} PPFD',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rationale:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generatedPlan!.carePlan.rationale.explanation ?? 'No explanation available',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confidence Score: ${(_generatedPlan!.carePlan.rationale.confidence * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showPreview = false;
                      _generatedPlan = null;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Revise'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_generatedPlan != null) {
                      await ref
                          .read(carePlanProvider.notifier)
                          .acknowledgeCarePlan(planId: _generatedPlan!.carePlan.id);
                      if (mounted) {
                        Navigator.of(
                          context,
                        ).pop(); // Go back to display screen
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Accept Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateCarePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPlantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a plant.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _loadingAnimationController.repeat();

    final request = CarePlanGenerationRequest(
      userPlantId: _selectedPlantId!,
      notes: _notesController.text.trim(),
      includeEnvironmentalData: _includeEnvironmentalData,
      includeHistoricalData: _includeHistoricalData,
      enableAdaptiveLearning: _enableAdaptiveLearning,
      focusAreas: _selectedFactors,
    );

    try {
      final generatedPlan = await ref
          .read(carePlanProvider.notifier)
          .generateCarePlan(request: request);
      setState(() {
        _generatedPlan = generatedPlan;
        _showPreview = true;
      });
    } catch (e) {
      // Error handling is done by the provider, just ensure UI reflects it
    } finally {
      _loadingAnimationController.stop();
      _loadingAnimationController.reset();
    }
  }
}