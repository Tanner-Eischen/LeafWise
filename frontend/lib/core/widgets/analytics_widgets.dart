import 'package:flutter/material.dart';

/// Collection of rich analytics widgets for displaying comprehensive backend data
class AnalyticsWidgets {
  
  /// Enhanced ML Health Analytics Card
  static Widget buildMLHealthAnalyticsCard({
    required ThemeData theme,
    required Map<String, dynamic> healthData,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: theme.primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'ML Plant Health Analytics',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 16),
              
              // Overall Health Score
              _buildHealthScoreDisplay(theme, healthData),
              const SizedBox(height: 16),
              
              // Feature Scores
              _buildFeatureScores(theme, healthData),
              const SizedBox(height: 16),
              
              // Risk Assessment
              _buildRiskAssessment(theme, healthData),
              const SizedBox(height: 12),
              
              // Confidence Indicators
              _buildConfidenceIndicators(theme, healthData),
            ],
          ),
        ),
      ),
    );
  }

  /// Enhanced RAG Insights Card
  static Widget buildRAGInsightsCard({
    required ThemeData theme,
    required Map<String, dynamic> ragData,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy, color: theme.primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'RAG Knowledge Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 16),
              
              // RAG Statistics Row
              _buildRAGStatsRow(theme, ragData),
              const SizedBox(height: 16),
              
              // Knowledge Coverage
              _buildKnowledgeCoverage(theme, ragData),
              const SizedBox(height: 16),
              
              // Recent Queries
              _buildRecentQueries(theme, ragData),
              const SizedBox(height: 12),
              
              // Response Quality
              _buildResponseQualityIndicator(theme, ragData),
            ],
          ),
        ),
      ),
    );
  }

  /// Enhanced Community Analytics Card
  static Widget buildCommunityAnalyticsCard({
    required ThemeData theme,
    required Map<String, dynamic> communityData,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.group, color: theme.primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Community Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 16),
              
              // Matching Score
              _buildMatchingScore(theme, communityData),
              const SizedBox(height: 16),
              
              // Interest Alignment
              _buildInterestAlignment(theme, communityData),
              const SizedBox(height: 16),
              
              // Community Influence
              _buildCommunityInfluence(theme, communityData),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for building sub-components
  static Widget _buildHealthScoreDisplay(ThemeData theme, Map<String, dynamic> data) {
    final healthScore = data['overall_health_score'] ?? 0.85;
    final riskLevel = data['risk_level'] ?? 'low';
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Health Score',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${(healthScore * 100).toInt()}%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getHealthColor(healthScore),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _getHealthIcon(healthScore),
                    color: _getHealthColor(healthScore),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getRiskColor(riskLevel).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getRiskColor(riskLevel).withOpacity(0.3)),
          ),
          child: Text(
            '${riskLevel.toUpperCase()} RISK',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getRiskColor(riskLevel),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildFeatureScores(ThemeData theme, Map<String, dynamic> data) {
    final features = data['feature_scores'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Factors',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...features.entries.take(4).map((entry) {
          final score = entry.value as double? ?? 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatFeatureName(entry.key),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: score,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getHealthColor(score),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 35,
                  child: Text(
                    '${(score * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  static Widget _buildRiskAssessment(ThemeData theme, Map<String, dynamic> data) {
    final risks = data['risk_factors'] as List<dynamic>? ?? [];
    
    if (risks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'No risk factors detected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk Factors',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...risks.take(2).map((risk) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    risk.toString(),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  static Widget _buildConfidenceIndicators(ThemeData theme, Map<String, dynamic> data) {
    final modelConfidence = data['model_confidence'] ?? 0.87;
    final dataQuality = data['data_quality_score'] ?? 0.92;
    
    return Row(
      children: [
        Expanded(
          child: _buildMiniMetric(theme, 'Confidence', '${(modelConfidence * 100).toInt()}%'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMiniMetric(theme, 'Data Quality', '${(dataQuality * 100).toInt()}%'),
        ),
      ],
    );
  }

  static Widget _buildRAGStatsRow(ThemeData theme, Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniMetric(theme, 'Total Queries', '${data['total_queries'] ?? 0}'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniMetric(theme, 'Success Rate', '${data['success_rate'] ?? 0}%'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniMetric(theme, 'Avg Response', '${data['avg_response_time'] ?? 0}ms'),
        ),
      ],
    );
  }

  static Widget _buildKnowledgeCoverage(ThemeData theme, Map<String, dynamic> data) {
    final coverage = data['knowledge_coverage'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Knowledge Coverage',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...coverage.entries.take(3).map((entry) {
          final percentage = entry.value as double? ?? 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  static Widget _buildRecentQueries(ThemeData theme, Map<String, dynamic> data) {
    final queries = data['recent_queries'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Query Topics',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: queries.take(4).map<Widget>((query) {
            return Chip(
              label: Text(
                query.toString(),
                style: theme.textTheme.bodySmall,
              ),
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildResponseQualityIndicator(ThemeData theme, Map<String, dynamic> data) {
    final quality = data['response_quality'] ?? 0.94;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response Quality',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < (quality * 5).round() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${(quality * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildMatchingScore(ThemeData theme, Map<String, dynamic> data) {
    final score = data['avg_similarity_score'] ?? 0.76;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Community Matching Score',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(score * 100).toInt()}%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        CircularProgressIndicator(
          value: score,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
      ],
    );
  }

  static Widget _buildInterestAlignment(ThemeData theme, Map<String, dynamic> data) {
    final interests = data['top_interests'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Shared Interests',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: interests.take(3).map<Widget>((interest) {
            final interestData = interest as Map<String, dynamic>;
            return Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    interestData['interest'] ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${interestData['percentage'] ?? 0}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildCommunityInfluence(ThemeData theme, Map<String, dynamic> data) {
    final influence = data['influence_score'] ?? 0.0;
    
    return Row(
      children: [
        Expanded(
          child: _buildMiniMetric(theme, 'Influence Score', influence.toStringAsFixed(1)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMiniMetric(theme, 'Similar Users', '${data['total_matches'] ?? 0}'),
        ),
      ],
    );
  }

  static Widget _buildMiniMetric(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper functions
  static Color _getHealthColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  static IconData _getHealthIcon(double score) {
    if (score >= 0.8) return Icons.health_and_safety;
    if (score >= 0.6) return Icons.warning;
    return Icons.error;
  }

  static Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String _formatFeatureName(String key) {
    return key.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }
}
