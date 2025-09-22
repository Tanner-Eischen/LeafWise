// Light calibration module for converting between different light measurement units
// This module provides functionality to convert lux to PPFD for different light sources

/// Class for calibrating and converting light measurements
class LightCalibration {
  // Conversion factors from lux to PPFD (μmol/m²/s) for different light sources
  // These values are approximate and based on typical spectral distributions
  final Map<String, double> _luxToPpfdFactors = {
    'sunlight': 0.0185, // Full spectrum sunlight
    'overcast': 0.0200, // Overcast daylight
    'shade': 0.0210, // Shade
    'led_full_spectrum': 0.0140, // Full spectrum LED grow light
    'led_red_blue': 0.0120, // Red/Blue LED grow light
    'fluorescent': 0.0135, // Fluorescent grow light
    'hps': 0.0128, // High Pressure Sodium
    'mh': 0.0145, // Metal Halide
    'incandescent': 0.0100, // Incandescent bulb
    'cfl': 0.0130, // Compact Fluorescent Light
  };
  
  /// Convert lux to PPFD (Photosynthetic Photon Flux Density) in μmol/m²/s
  /// 
  /// [lux] The light intensity in lux
  /// [lightSource] The type of light source (default: 'sunlight')
  /// 
  /// Returns the PPFD value in μmol/m²/s
  double luxToPpfd(double lux, {String lightSource = 'sunlight'}) {
    final factor = _luxToPpfdFactors[lightSource] ?? _luxToPpfdFactors['sunlight']!;
    return lux * factor;
  }
  
  /// Get the available light source types for conversion
  List<String> get availableLightSources => _luxToPpfdFactors.keys.toList();
  
  /// Get the conversion factor for a specific light source
  double getConversionFactor(String lightSource) {
    return _luxToPpfdFactors[lightSource] ?? _luxToPpfdFactors['sunlight']!;
  }
  
  /// Get a description of the light intensity based on PPFD value
  /// 
  /// [ppfd] The PPFD value in μmol/m²/s
  /// 
  /// Returns a description of the light intensity
  String getLightIntensityDescription(double ppfd) {
    if (ppfd < 10) {
      return 'Very Low - Insufficient for most plants';
    } else if (ppfd < 50) {
      return 'Low - Suitable for shade plants';
    } else if (ppfd < 150) {
      return 'Medium-Low - Good for foliage plants';
    } else if (ppfd < 300) {
      return 'Medium - Suitable for most houseplants';
    } else if (ppfd < 600) {
      return 'Medium-High - Good for flowering plants';
    } else if (ppfd < 900) {
      return 'High - Suitable for most fruiting plants';
    } else {
      return 'Very High - Full sunlight, suitable for high-light plants';
    }
  }
  
  /// Get plant recommendations based on PPFD value
  /// 
  /// [ppfd] The PPFD value in μmol/m²/s
  /// 
  /// Returns a list of plant types suitable for the light intensity
  List<String> getPlantRecommendations(double ppfd) {
    if (ppfd < 10) {
      return ['Few plants can thrive in this light'];
    } else if (ppfd < 50) {
      return ['Snake Plant', 'ZZ Plant', 'Pothos', 'Peace Lily', 'Cast Iron Plant'];
    } else if (ppfd < 150) {
      return ['Philodendron', 'Ferns', 'Calathea', 'Anthurium', 'Dracaena'];
    } else if (ppfd < 300) {
      return ['Spider Plant', 'African Violet', 'Monstera', 'Orchids', 'Bromeliads'];
    } else if (ppfd < 600) {
      return ['Succulents', 'Herbs', 'Citrus', 'Hibiscus', 'Croton'];
    } else if (ppfd < 900) {
      return ['Tomatoes', 'Peppers', 'Roses', 'Sunflowers', 'Most Vegetables'];
    } else {
      return ['Cacti', 'Desert Plants', 'Full Sun Vegetables', 'Fruit Trees', 'Sun-loving Flowers'];
    }
  }
  
  /// Get plant recommendation as a single string based on PPFD value
  /// 
  /// [ppfd] The PPFD value in μmol/m²/s
  /// 
  /// Returns a string with plant recommendations suitable for the light intensity
  String getPlantRecommendation(double ppfd) {
    final recommendations = getPlantRecommendations(ppfd);
    return recommendations.join(', ');
  }
}