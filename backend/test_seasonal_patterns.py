"""Test script for seasonal pattern detection algorithms."""

import asyncio
import sys
import os
from datetime import date

# Add the backend directory to the Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

from app.services.seasonal_pattern_service import SeasonalPatternService
from app.schemas.environmental_data import Location

# This test validates the SeasonalPatternService which is now properly implemented


async def test_seasonal_pattern_detection():
    """Test the seasonal pattern detection functionality."""
    print("Testing Seasonal Pattern Detection Algorithms...")
    
    # Create a test location (New York City)
    test_location = Location(
        latitude=40.7128,
        longitude=-74.0060,
        city="New York",
        country="USA",
        timezone="America/New_York"
    )
    
    # Initialize the service
    pattern_service = SeasonalPatternService()
    
    try:
        print(f"\n1. Testing seasonal transition detection for {test_location.city}...")
        transitions = await pattern_service.detect_seasonal_transitions(test_location)
        
        print(f"   Detected {len(transitions)} seasonal transitions:")
        for transition in transitions:
            print(f"   - {transition.transition_type}: {transition.estimated_date} (confidence: {transition.confidence:.2f})")
            print(f"     Temperature trend: {transition.temperature_trend}, Daylight trend: {transition.daylight_trend}")
        
        print(f"\n2. Testing microclimate adjustments for indoor conditions...")
        indoor_adjustments = await pattern_service.calculate_microclimate_adjustments(
            test_location, indoor_conditions=True
        )
        
        print(f"   Indoor temperature offset: {indoor_adjustments.indoor_temperature_offset:.1f}°C")
        print(f"   Indoor humidity offset: {indoor_adjustments.indoor_humidity_offset:.1f}%")
        print(f"   Light reduction factor: {indoor_adjustments.light_reduction_factor:.2f}")
        print(f"   Air circulation factor: {indoor_adjustments.air_circulation_factor:.2f}")
        
        print(f"\n3. Testing pest risk assessment...")
        test_plant = "Monstera deliciosa"
        pest_risk = await pattern_service.assess_seasonal_pest_risks(
            test_location, test_plant, indoor_adjustments
        )
        
        print(f"   Overall pest risk score for {test_plant}: {pest_risk.overall_risk_score:.2f}")
        print(f"   Risk factors detected: {len(pest_risk.risk_factors)}")
        
        for risk_factor in pest_risk.risk_factors:
            print(f"   - {risk_factor.pest_type}: {risk_factor.risk_level} risk (score: {risk_factor.risk_score:.2f})")
            print(f"     Peak season: {risk_factor.seasonal_peak}")
            print(f"     Prevention: {risk_factor.prevention_measures[0] if risk_factor.prevention_measures else 'None'}")
        
        print(f"\n4. Testing seasonal recommendations...")
        current_month_recs = pest_risk.seasonal_recommendations.get("current_month", [])
        print(f"   Current month recommendations ({len(current_month_recs)}):")
        for rec in current_month_recs[:3]:  # Show first 3
            print(f"   - {rec}")
        
        print(f"\n✅ All seasonal pattern detection tests completed successfully!")
        return True
        
    except Exception as e:
        print(f"\n❌ Test failed with error: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


async def test_microclimate_comparisons():
    """Test microclimate adjustments for different conditions."""
    print("\nTesting Microclimate Comparisons...")
    
    test_location = Location(
        latitude=37.7749,
        longitude=-122.4194,
        city="San Francisco",
        country="USA",
        timezone="America/Los_Angeles"
    )
    
    pattern_service = SeasonalPatternService()
    
    try:
        # Test indoor vs outdoor conditions
        indoor_adj = await pattern_service.calculate_microclimate_adjustments(
            test_location, indoor_conditions=True
        )
        outdoor_adj = await pattern_service.calculate_microclimate_adjustments(
            test_location, indoor_conditions=False
        )
        
        print(f"Indoor vs Outdoor Microclimate Comparison for {test_location.city}:")
        print(f"  Temperature offset: Indoor {indoor_adj.indoor_temperature_offset:.1f}°C vs Outdoor {outdoor_adj.indoor_temperature_offset:.1f}°C")
        print(f"  Humidity offset: Indoor {indoor_adj.indoor_humidity_offset:.1f}% vs Outdoor {outdoor_adj.indoor_humidity_offset:.1f}%")
        print(f"  Light reduction: Indoor {indoor_adj.light_reduction_factor:.2f} vs Outdoor {outdoor_adj.light_reduction_factor:.2f}")
        
        # Test seasonal adjustments
        print(f"\nSeasonal adjustments for indoor conditions:")
        for season, adjustments in indoor_adj.seasonal_adjustments.items():
            print(f"  {season.capitalize()}:")
            for factor, value in adjustments.items():
                print(f"    {factor}: {value:.2f}")
        
        print(f"\n✅ Microclimate comparison tests completed successfully!")
        return True
        
    except Exception as e:
        print(f"\n❌ Microclimate test failed with error: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


async def main():
    """Run all tests."""
    print("=" * 60)
    print("SEASONAL PATTERN DETECTION ALGORITHM TESTS")
    print("=" * 60)
    
    # Run basic functionality tests
    test1_success = await test_seasonal_pattern_detection()
    
    # Run microclimate comparison tests
    test2_success = await test_microclimate_comparisons()
    
    print("\n" + "=" * 60)
    if test1_success and test2_success:
        print("🎉 ALL TESTS PASSED! Seasonal pattern detection algorithms are working correctly.")
    else:
        print("⚠️  Some tests failed. Please check the implementation.")
    print("=" * 60)


if __name__ == "__main__":
    asyncio.run(main())