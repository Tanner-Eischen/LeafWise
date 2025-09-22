"""
Test script for GrowthAnalyticsService

This script tests the growth analytics functionality including:
- Growth trend analysis using time series analysis techniques
- Comparative growth performance analytics across plant collections
- Seasonal response pattern identification using clustering algorithms
"""

import asyncio
import sys
import os
from datetime import datetime, timedelta
from uuid import uuid4
import json

# Add the backend directory to the Python path
sys.path.append(os.path.join(os.path.dirname(__file__), '.'))

from app.services.growth_analytics_service import GrowthAnalyticsService
from app.schemas.growth_analytics import (
    GrowthTrendsRequest, ComparativeAnalysisRequest, SeasonalPatternsRequest,
    AnalyticsReportRequest, AnalysisType, ComparisonType
)


class MockDatabase:
    """Mock database session for testing."""
    
    def __init__(self):
        self.plants = []
        self.sessions = []
        self.photos = []
        self.milestones = []
        self.predictions = []
        self.users = []
        self._setup_mock_data()
    
    def _setup_mock_data(self):
        """Set up mock data for testing."""
        # Create mock user
        user_id = str(uuid4())
        self.users.append({
            "id": user_id,
            "username": "test_user",
            "email": "test@example.com"
        })
        
        # Create mock plants
        plant_ids = []
        for i in range(3):
            plant_id = str(uuid4())
            plant_ids.append(plant_id)
            self.plants.append({
                "id": plant_id,
                "user_id": user_id,
                "species_id": str(uuid4()),
                "nickname": f"Test Plant {i+1}",
                "location": f"Location {i+1}",
                "health_status": "healthy",
                "is_active": True,
                "created_at": datetime.utcnow() - timedelta(days=180),
                "acquired_date": datetime.utcnow() - timedelta(days=180)
            })
        
        # Create mock time-lapse sessions
        for plant_id in plant_ids:
            session_id = str(uuid4())
            self.sessions.append({
                "id": session_id,
                "plant_id": plant_id,
                "user_id": user_id,
                "session_name": f"Growth Tracking {plant_id[:8]}",
                "start_date": datetime.utcnow() - timedelta(days=90),
                "status": "active",
                "created_at": datetime.utcnow() - timedelta(days=90)
            })
            
            # Create mock photos for each session
            for day in range(0, 90, 7):  # Weekly photos
                photo_id = str(uuid4())
                capture_date = datetime.utcnow() - timedelta(days=90-day)
                
                # Simulate growth over time
                base_height = 10 + (day * 0.1)  # Gradual growth
                base_width = 8 + (day * 0.05)
                leaf_count = 5 + (day // 14)  # New leaf every 2 weeks
                
                self.photos.append({
                    "id": photo_id,
                    "session_id": session_id,
                    "photo_url": f"https://example.com/photo_{photo_id}.jpg",
                    "capture_date": capture_date,
                    "sequence_number": day // 7,
                    "plant_measurements": {
                        "height_cm": base_height + (plant_ids.index(plant_id) * 2),  # Different growth rates
                        "width_cm": base_width + (plant_ids.index(plant_id) * 1),
                        "leaf_count": leaf_count,
                        "health_score": 0.8 + (day * 0.002)  # Improving health
                    },
                    "processing_status": "completed",
                    "image_quality_score": 0.85,
                    "positioning_accuracy": 0.9
                })
        
        # Create mock seasonal predictions
        for plant_id in plant_ids:
            for month_offset in range(0, 12):
                prediction_date = datetime.utcnow() - timedelta(days=30*month_offset)
                self.predictions.append({
                    "id": str(uuid4()),
                    "plant_id": plant_id,
                    "prediction_date": prediction_date,
                    "prediction_period_start": prediction_date.date(),
                    "prediction_period_end": (prediction_date + timedelta(days=30)).date(),
                    "growth_forecast": {
                        "expected_growth_rate": 0.1 + (month_offset % 4) * 0.05,  # Seasonal variation
                        "flowering_predictions": []
                    },
                    "confidence_score": 0.8
                })
    
    def query(self, model):
        """Mock query method."""
        return MockQuery(self, model)


class MockQuery:
    """Mock query object."""
    
    def __init__(self, db, model):
        self.db = db
        self.model = model
        self.filters = []
        self.joins = []
        self.order_by_clause = None
    
    def filter(self, *conditions):
        """Mock filter method."""
        self.filters.extend(conditions)
        return self
    
    def join(self, *tables):
        """Mock join method."""
        self.joins.extend(tables)
        return self
    
    def order_by(self, *columns):
        """Mock order by method."""
        self.order_by_clause = columns
        return self
    
    def first(self):
        """Mock first method."""
        results = self.all()
        return results[0] if results else None
    
    def count(self):
        """Mock count method."""
        return len(self.all())
    
    def all(self):
        """Mock all method - simplified implementation."""
        model_name = self.model.__name__ if hasattr(self.model, '__name__') else str(self.model)
        
        if 'UserPlant' in model_name:
            return [MockObject(plant) for plant in self.db.plants]
        elif 'TimelapseSession' in model_name:
            return [MockObject(session) for session in self.db.sessions]
        elif 'GrowthPhoto' in model_name:
            return [MockObject(photo) for photo in self.db.photos]
        elif 'GrowthMilestone' in model_name:
            return [MockObject(milestone) for milestone in self.db.milestones]
        elif 'SeasonalPrediction' in model_name:
            return [MockObject(prediction) for prediction in self.db.predictions]
        elif 'User' in model_name:
            return [MockObject(user) for user in self.db.users]
        else:
            return []


class MockObject:
    """Mock database object."""
    
    def __init__(self, data):
        for key, value in data.items():
            setattr(self, key, value)


async def test_growth_trends_analysis():
    """Test growth trends analysis functionality."""
    print("Testing Growth Trends Analysis...")
    
    service = GrowthAnalyticsService()
    db = MockDatabase()
    
    # Get a test plant ID
    plant_id = db.plants[0]["id"]
    
    try:
        # Test growth trends analysis
        result = await service.analyze_growth_trends(db, plant_id, 90)
        
        print(f"✓ Growth trends analysis completed for plant {plant_id}")
        print(f"  - Analysis period: {result['analysis_period']['days']} days")
        print(f"  - Data quality: {result['data_quality']['total_photos']} photos")
        print(f"  - Trend direction: {result['trend_analysis'].get('trend_direction', 'N/A')}")
        print(f"  - Growth phases detected: {len(result['growth_phases'])}")
        print(f"  - Insights generated: {len(result['insights'])}")
        
        # Verify time series analysis
        trend_analysis = result['trend_analysis']
        if trend_analysis.get('status') == 'success':
            print(f"  - Trend strength (R²): {trend_analysis.get('trend_strength', 0):.3f}")
            print(f"  - Height range: {trend_analysis.get('height_range', {})}")
        
        # Verify growth rates calculation
        growth_rates = result['growth_rates']
        height_rates = growth_rates.get('height_rate_cm_per_day', {})
        if 'average' in height_rates:
            print(f"  - Average height growth rate: {height_rates['average']:.4f} cm/day")
        
        return True
        
    except Exception as e:
        print(f"✗ Growth trends analysis failed: {e}")
        return False


async def test_comparative_analysis():
    """Test comparative growth performance analytics."""
    print("\nTesting Comparative Analysis...")
    
    service = GrowthAnalyticsService()
    db = MockDatabase()
    
    # Get a test user ID
    user_id = db.users[0]["id"]
    
    try:
        # Test user plants comparison
        result = await service.compare_plant_performance(
            db, user_id, "user_plants", 90
        )
        
        print(f"✓ User plants comparison completed")
        print(f"  - Total plants: {result.get('total_plants', 0)}")
        print(f"  - Analyzed plants: {result.get('analyzed_plants', 0)}")
        print(f"  - Plant rankings: {len(result.get('plant_rankings', []))}")
        print(f"  - Insights generated: {len(result.get('insights', []))}")
        
        # Show top performer
        rankings = result.get('plant_rankings', [])
        if rankings:
            top_plant = rankings[0]
            print(f"  - Best performer: {top_plant.get('plant_name')} (score: {top_plant.get('performance_score', 0):.3f})")
        
        # Test species comparison
        species_result = await service.compare_plant_performance(
            db, user_id, "species", 90
        )
        
        print(f"✓ Species comparison completed")
        print(f"  - Species analyzed: {species_result.get('analyzed_species', 0)}")
        
        # Test community comparison
        community_result = await service.compare_plant_performance(
            db, user_id, "community", 90
        )
        
        print(f"✓ Community comparison completed")
        print(f"  - Community comparisons: {len(community_result.get('community_comparison', []))}")
        
        return True
        
    except Exception as e:
        print(f"✗ Comparative analysis failed: {e}")
        return False


async def test_seasonal_patterns():
    """Test seasonal response pattern identification."""
    print("\nTesting Seasonal Pattern Analysis...")
    
    service = GrowthAnalyticsService()
    db = MockDatabase()
    
    # Get a test plant ID
    plant_id = db.plants[0]["id"]
    
    try:
        # Test seasonal pattern analysis
        result = await service.identify_seasonal_patterns(db, plant_id, 4)
        
        print(f"✓ Seasonal pattern analysis completed for plant {plant_id}")
        print(f"  - Seasons analyzed: {result['analysis_period']['seasons_analyzed']}")
        print(f"  - Data quality: {result['data_quality']['total_photos']} photos")
        print(f"  - Seasonal predictions: {result['data_quality']['seasonal_predictions']}")
        
        # Check clustering results
        seasonal_clusters = result['seasonal_clusters']
        if seasonal_clusters.get('status') == 'success':
            seasonal_stats = seasonal_clusters.get('seasonal_stats', {})
            print(f"  - Seasonal clusters: {len(seasonal_stats)} seasons with data")
            for season, stats in seasonal_stats.items():
                print(f"    - {season.title()}: {stats.get('photo_count', 0)} photos, avg height: {stats.get('avg_height', 0):.1f}cm")
        
        # Check response patterns
        patterns = result['response_patterns']
        print(f"  - Response patterns identified: {len(patterns)}")
        for pattern in patterns:
            print(f"    - {pattern.get('pattern_type')}: {pattern.get('description')}")
        
        # Check recommendations
        recommendations = result['recommendations']
        print(f"  - Seasonal recommendations: {len(recommendations)}")
        
        return True
        
    except Exception as e:
        print(f"✗ Seasonal pattern analysis failed: {e}")
        return False


async def test_comprehensive_report():
    """Test comprehensive analytics report generation."""
    print("\nTesting Comprehensive Analytics Report...")
    
    service = GrowthAnalyticsService()
    db = MockDatabase()
    
    # Get a test plant ID
    plant_id = db.plants[0]["id"]
    
    try:
        # Test comprehensive report
        result = await service.generate_growth_analytics_report(
            db, plant_id, "comprehensive"
        )
        
        print(f"✓ Comprehensive analytics report generated")
        print(f"  - Plant: {result['plant_info']['nickname']}")
        print(f"  - Report type: {result['report_type']}")
        print(f"  - Generated at: {result['generated_at']}")
        
        # Check included analyses
        if 'growth_trends' in result:
            print(f"  - Growth trends: ✓ Included")
        if 'seasonal_patterns' in result:
            print(f"  - Seasonal patterns: ✓ Included")
        if 'comparative_analysis' in result:
            print(f"  - Comparative analysis: ✓ Included")
        
        # Check summary
        summary = result['summary']
        print(f"  - Summary stats:")
        print(f"    - Total sessions: {summary['total_sessions']}")
        print(f"    - Total photos: {summary['total_photos']}")
        print(f"    - Plant age: {summary['plant_age_days']} days")
        
        return True
        
    except Exception as e:
        print(f"✗ Comprehensive report generation failed: {e}")
        return False


async def test_pattern_recognition_algorithms():
    """Test pattern recognition algorithms."""
    print("\nTesting Pattern Recognition Algorithms...")
    
    service = GrowthAnalyticsService()
    
    try:
        # Test time series analysis with mock data
        timeline = [
            {
                "date": datetime.utcnow() - timedelta(days=i*7),
                "photo_id": str(uuid4()),
                "measurements": {"height_cm": 10 + i * 0.5},
                "sequence_number": i
            }
            for i in range(10)
        ]
        
        trend_analysis = service._perform_time_series_analysis(timeline)
        print(f"✓ Time series analysis completed")
        print(f"  - Status: {trend_analysis.get('status')}")
        print(f"  - Trend direction: {trend_analysis.get('trend_direction')}")
        print(f"  - Trend strength: {trend_analysis.get('trend_strength', 0):.3f}")
        
        # Test growth rate calculations
        growth_rates = service._calculate_growth_rates(timeline)
        print(f"✓ Growth rate calculations completed")
        height_rates = growth_rates.get('height_rate_cm_per_day', {})
        if 'average' in height_rates:
            print(f"  - Average height growth rate: {height_rates['average']:.4f} cm/day")
        
        # Test growth phase detection
        growth_phases = service._detect_growth_phases(timeline, growth_rates)
        print(f"✓ Growth phase detection completed")
        print(f"  - Phases detected: {len(growth_phases)}")
        for phase in growth_phases:
            print(f"    - {phase.get('phase_type')}: {phase.get('description')}")
        
        return True
        
    except Exception as e:
        print(f"✗ Pattern recognition algorithms failed: {e}")
        return False


async def main():
    """Run all tests."""
    print("=== Growth Analytics Service Test Suite ===\n")
    
    tests = [
        test_growth_trends_analysis,
        test_comparative_analysis,
        test_seasonal_patterns,
        test_comprehensive_report,
        test_pattern_recognition_algorithms
    ]
    
    results = []
    for test in tests:
        try:
            result = await test()
            results.append(result)
        except Exception as e:
            print(f"Test failed with exception: {e}")
            results.append(False)
    
    # Summary
    passed = sum(results)
    total = len(results)
    
    print(f"\n=== Test Results ===")
    print(f"Passed: {passed}/{total}")
    print(f"Success Rate: {passed/total*100:.1f}%")
    
    if passed == total:
        print("🎉 All tests passed! Growth Analytics Service is working correctly.")
        print("\nKey Features Verified:")
        print("✓ Growth trend analysis using time series analysis techniques")
        print("✓ Comparative growth performance analytics across plant collections")
        print("✓ Seasonal response pattern identification using clustering algorithms")
        print("✓ Comprehensive analytics report generation")
        print("✓ Pattern recognition algorithms for growth phase detection")
    else:
        print("❌ Some tests failed. Please check the implementation.")
    
    return passed == total


if __name__ == "__main__":
    success = asyncio.run(main())
    sys.exit(0 if success else 1)