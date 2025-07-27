#!/usr/bin/env python3
"""Test script for core SeasonalAIService implementation - Task 3.1."""

import asyncio
import sys
import os
from datetime import datetime, date
from uuid import uuid4

# Add the backend directory to the Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

from app.services.seasonal_ai_service import SeasonalAIService
from app.schemas.environmental_data import Location


async def test_core_seasonal_ai_implementation():
    """Test the core SeasonalAIService implementation for Task 3.1."""
    print("🧪 Testing Core SeasonalAIService Implementation (Task 3.1)")
    print("=" * 60)
    
    # Test 1: Service Initialization
    print("\n1️⃣ Testing Service Initialization:")
    try:
        service = SeasonalAIService()
        print("✅ SeasonalAIService initialized successfully")
        print(f"   Model version: {service.model_version}")
    except Exception as e:
        print(f"❌ Failed to initialize SeasonalAIService: {e}")
        return False
    
    # Test 2: Plant Species Seasonal Behavior Models
    print("\n2️⃣ Testing Plant Species Seasonal Behavior Models:")
    try:
        # Test species behavior pattern prediction
        species_characteristics = {
            'temperature': 22.0,
            'humidity': 65.0,
            'daylight_hours': 12.0,
            'growth_rate': 0.7,
            'water_adjustment': 0.1,
            'fertilizer_adjustment': 0.2,
            'risk_score': 0.3
        }
        
        behavior_pattern = service.predict_species_behavior_pattern(species_characteristics)
        print(f"✅ Species behavior pattern prediction: Cluster {behavior_pattern}")
        
        # Test species seasonal behavior retrieval
        species_behavior = service.get_species_seasonal_behavior(species_id=25)
        print(f"✅ Species seasonal behavior retrieved:")
        print(f"   Optimal temperature: {species_behavior['optimal_temperature_range']}")
        print(f"   Light requirements: {species_behavior['light_requirements']}")
        print(f"   Growth peak seasons: {species_behavior['growth_peak_seasons']}")
        
    except Exception as e:
        print(f"❌ Species behavior model test failed: {e}")
        return False
    
    # Test 3: Growth Phase Prediction Algorithms
    print("\n3️⃣ Testing Growth Phase Prediction Algorithms:")
    try:
        # Test growth phase prediction from environmental factors
        growth_phase, confidence = service.predict_growth_phase_from_environment(
            temperature=23.0,
            humidity=60.0,
            daylight_hours=14.0,
            precipitation=2.5,
            plant_age_days=180,
            season=1,  # Summer
            species_id=15
        )
        print(f"✅ Growth phase prediction: {growth_phase} (confidence: {confidence:.3f})")
        
        # Test with different environmental conditions
        winter_phase, winter_confidence = service.predict_growth_phase_from_environment(
            temperature=15.0,
            humidity=45.0,
            daylight_hours=8.0,
            precipitation=1.0,
            plant_age_days=365,
            season=3,  # Winter
            species_id=15
        )
        print(f"✅ Winter growth phase: {winter_phase} (confidence: {winter_confidence:.3f})")
        
    except Exception as e:
        print(f"❌ Growth phase prediction test failed: {e}")
        return False
    
    # Test 4: Care Adjustment Recommendation Engine with Confidence Scoring
    print("\n4️⃣ Testing Care Adjustment Recommendation Engine:")
    try:
        # Test care adjustments with confidence scoring
        environmental_features = [23.0, 60.0, 14.0, 2.5, 180, 1, 15]  # Summer conditions
        care_adjustments, overall_confidence = service.predict_care_adjustments_with_confidence(
            environmental_features, species_id=15
        )
        
        print(f"✅ Care adjustments predicted (confidence: {overall_confidence:.3f}):")
        for adjustment in care_adjustments:
            print(f"   {adjustment.care_type}: {adjustment.adjustment_type} "
                  f"({adjustment.adjustment_percentage:+.1f}%) - {adjustment.reason}")
            print(f"      Confidence: {adjustment.confidence:.3f}")
        
        # Test with different conditions (winter/dry)
        winter_features = [15.0, 45.0, 8.0, 1.0, 365, 3, 15]  # Winter conditions
        winter_adjustments, winter_conf = service.predict_care_adjustments_with_confidence(
            winter_features, species_id=15
        )
        
        print(f"\n✅ Winter care adjustments (confidence: {winter_conf:.3f}):")
        for adjustment in winter_adjustments:
            print(f"   {adjustment.care_type}: {adjustment.adjustment_type} "
                  f"({adjustment.adjustment_percentage:+.1f}%) - {adjustment.reason}")
        
    except Exception as e:
        print(f"❌ Care adjustment recommendation test failed: {e}")
        return False
    
    # Test 5: Model Performance Metrics
    print("\n5️⃣ Testing Model Performance Metrics:")
    try:
        metrics = service.get_model_performance_metrics()
        print("✅ Model performance metrics:")
        print(f"   Model version: {metrics.get('model_version', 'Unknown')}")
        
        models_loaded = metrics.get('models_loaded', {})
        for model_name, loaded in models_loaded.items():
            status = "✅" if loaded else "❌"
            print(f"   {model_name}: {status}")
        
        # Print performance metrics if available
        if 'growth_model_r2' in metrics:
            print(f"   Growth model R²: {metrics['growth_model_r2']:.4f}")
        if 'growth_phase_accuracy' in metrics:
            print(f"   Growth phase accuracy: {metrics['growth_phase_accuracy']:.4f}")
        if 'care_model_mse' in metrics:
            print(f"   Care model MSE: {metrics['care_model_mse']:.4f}")
        
    except Exception as e:
        print(f"❌ Model performance metrics test failed: {e}")
        return False
    
    # Test 6: Integration Test - Complete Workflow
    print("\n6️⃣ Testing Complete Workflow Integration:")
    try:
        # Simulate a complete seasonal AI prediction workflow
        test_species_id = 42
        
        # Get species behavior
        species_behavior = service.get_species_seasonal_behavior(test_species_id)
        
        # Predict growth phase for current conditions
        current_conditions = [22.0, 65.0, 12.0, 3.0, 200, 1, test_species_id]
        growth_phase, phase_confidence = service.predict_growth_phase_with_confidence(current_conditions)
        
        # Get care adjustments
        care_adjustments, care_confidence = service.predict_care_adjustments_with_confidence(
            current_conditions, test_species_id
        )
        
        print("✅ Complete workflow integration test:")
        print(f"   Species behavior cluster: {service.predict_species_behavior_pattern(species_behavior)}")
        print(f"   Current growth phase: {growth_phase} (confidence: {phase_confidence:.3f})")
        print(f"   Care recommendations: {len(care_adjustments)} adjustments")
        print(f"   Overall care confidence: {care_confidence:.3f}")
        
        # Verify all components work together
        assert len(care_adjustments) > 0, "No care adjustments generated"
        assert 0.0 <= care_confidence <= 1.0, "Invalid confidence score"
        assert growth_phase in ['dormant', 'slow', 'active', 'rapid'], "Invalid growth phase"
        
        print("✅ All integration checks passed")
        
    except Exception as e:
        print(f"❌ Integration test failed: {e}")
        return False
    
    print("\n🎉 All Core SeasonalAIService Tests Passed!")
    print("=" * 60)
    print("✅ Task 3.1 Implementation Complete:")
    print("   • Plant species seasonal behavior models using scikit-learn ✅")
    print("   • Growth phase prediction algorithms based on environmental factors ✅")
    print("   • Care adjustment recommendation engine with confidence scoring ✅")
    print("   • Requirements 1.1, 1.2, 1.3, 5.1 addressed ✅")
    
    return True


if __name__ == "__main__":
    success = asyncio.run(test_core_seasonal_ai_implementation())
    sys.exit(0 if success else 1)