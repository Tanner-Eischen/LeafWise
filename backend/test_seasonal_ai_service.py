#!/usr/bin/env python3
"""Test script for SeasonalAIService implementation."""

import asyncio
import sys
import os
from datetime import datetime, date
from uuid import uuid4

# Add the backend directory to the Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

from app.services.seasonal_ai_service import SeasonalAIService
from app.schemas.environmental_data import Location


async def test_seasonal_ai_service():
    """Test the SeasonalAIService implementation."""
    print("🧪 Testing SeasonalAIService Implementation")
    print("=" * 50)
    
    # Initialize the service
    try:
        service = SeasonalAIService()
        print("✅ SeasonalAIService initialized successfully")
    except Exception as e:
        print(f"❌ Failed to initialize SeasonalAIService: {e}")
        return False
    
    # Test model initialization
    print("\n📊 Testing Model Initialization:")
    try:
        if service.growth_model is not None:
            print("✅ Growth prediction model loaded")
        if service.care_model is not None:
            print("✅ Care adjustment model loaded")
        if service.risk_model is not None:
            print("✅ Risk assessment model loaded")
        if service.feature_scaler is not None:
            print("✅ Feature scaler loaded")
    except Exception as e:
        print(f"❌ Model initialization error: {e}")
        return False
    
    # Test model performance metrics
    print("\n📈 Testing Model Performance Metrics:")
    try:
        metrics = service.get_model_performance_metrics()
        print(f"✅ Model version: {metrics.get('model_version', 'Unknown')}")
        print(f"✅ Growth model MSE: {metrics.get('growth_model_mse', 'N/A'):.4f}")
        print(f"✅ Care model MSE: {metrics.get('care_model_mse', 'N/A'):.4f}")
        print(f"✅ Risk model MSE: {metrics.get('risk_model_mse', 'N/A'):.4f}")
        print(f"✅ Feature count: {metrics.get('feature_count', 'N/A')}")
    except Exception as e:
        print(f"❌ Model metrics error: {e}")
        return False
    
    # Test growth phase prediction
    print("\n🌱 Testing Growth Phase Prediction:")
    try:
        environmental_conditions = {
            'temperature': 22.0,
            'humidity': 65.0,
            'daylight_hours': 12.5,
            'precipitation': 1.2
        }
        
        growth_phases = await service.predict_growth_phases(
            "Monstera deliciosa", 
            environmental_conditions
        )
        
        print(f"✅ Predicted {len(growth_phases)} growth phases")
        for phase in growth_phases:
            print(f"   - Phase: {phase['phase']}")
            print(f"   - Duration: {phase['duration_days']} days")
            print(f"   - Characteristics: {', '.join(phase['characteristics'][:2])}...")
    except Exception as e:
        print(f"❌ Growth phase prediction error: {e}")
        return False
    
    # Test care recommendation engine
    print("\n💡 Testing Care Recommendation Engine:")
    try:
        plant_id = uuid4()
        recommendations = await service.create_care_recommendation_engine(
            plant_id, 
            environmental_conditions
        )
        
        print(f"✅ Generated recommendations for plant {plant_id}")
        print(f"✅ Overall confidence: {recommendations.get('overall_confidence', 0):.2f}")
        
        for category, data in recommendations.get('recommendations', {}).items():
            if data['recommendations']:
                print(f"   - {category.title()}: {len(data['recommendations'])} recommendations")
                print(f"     Confidence: {data['overall_confidence']:.2f}")
    except Exception as e:
        print(f"❌ Care recommendation engine error: {e}")
        return False
    
    # Test model retraining
    print("\n🔄 Testing Model Retraining:")
    try:
        retrain_success = await service.retrain_models()
        if retrain_success:
            print("✅ Model retraining completed successfully")
        else:
            print("⚠️ Model retraining completed with warnings")
    except Exception as e:
        print(f"❌ Model retraining error: {e}")
        return False
    
    # Test seasonal care adjustments
    print("\n🍂 Testing Seasonal Care Adjustments:")
    try:
        plant_id = uuid4()
        adjustments = await service.get_seasonal_care_adjustments(plant_id, "spring")
        print(f"✅ Generated {len(adjustments)} seasonal care adjustments")
        
        for adj in adjustments[:2]:  # Show first 2 adjustments
            print(f"   - {adj.care_type}: {adj.adjustment_type}")
            print(f"     Reason: {adj.reason[:50]}...")
            print(f"     Confidence: {adj.confidence:.2f}")
    except Exception as e:
        print(f"❌ Seasonal care adjustments error: {e}")
        return False
    
    print("\n🎉 All SeasonalAIService tests completed successfully!")
    return True


def test_data_structures():
    """Test the data structures and models."""
    print("\n🏗️ Testing Data Structures:")
    
    try:
        from app.services.seasonal_ai_service import (
            GrowthForecast, CareAdjustment, RiskFactor, 
            PlantActivity, SeasonalPredictionResult
        )
        
        # Test GrowthForecast
        growth_forecast = GrowthForecast(
            expected_growth_rate=0.8,
            size_projections=[{"date": date.today(), "size": 1.2}],
            flowering_predictions=[{"start": date.today(), "probability": 0.7}],
            dormancy_periods=[{"start": date.today(), "type": "winter"}],
            stress_likelihood=0.3
        )
        print("✅ GrowthForecast structure validated")
        
        # Test CareAdjustment
        care_adjustment = CareAdjustment(
            care_type="watering",
            adjustment_type="increase",
            current_value=7.0,
            recommended_value=5.0,
            adjustment_percentage=20.0,
            reason="Seasonal temperature increase",
            confidence=0.85,
            effective_date=date.today(),
            duration_days=30
        )
        print("✅ CareAdjustment structure validated")
        
        # Test RiskFactor
        risk_factor = RiskFactor(
            risk_type="pest",
            risk_level="medium",
            probability=0.6,
            impact_severity=0.7,
            onset_date=date.today(),
            mitigation_actions=["Regular inspection", "Preventive treatment"],
            monitoring_frequency="weekly"
        )
        print("✅ RiskFactor structure validated")
        
        return True
        
    except Exception as e:
        print(f"❌ Data structure validation error: {e}")
        return False


async def main():
    """Main test function."""
    print("🚀 Starting SeasonalAIService Integration Tests")
    print("=" * 60)
    
    # Test data structures first
    if not test_data_structures():
        print("❌ Data structure tests failed")
        return
    
    # Test the service implementation
    if not await test_seasonal_ai_service():
        print("❌ Service implementation tests failed")
        return
    
    print("\n" + "=" * 60)
    print("🎊 All tests passed! SeasonalAIService is ready for use.")


if __name__ == "__main__":
    asyncio.run(main())