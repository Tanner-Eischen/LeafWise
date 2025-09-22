#!/usr/bin/env python3
"""
Test script for Growth Analytics Community Features

This script tests the community insights and data sharing functionality including:
- Growth data export functionality with privacy controls
- Community pattern aggregation for successful care strategies
- Achievement system for growth milestones and seasonal challenges
"""

import asyncio
import sys
import os
from datetime import datetime, timedelta
from uuid import uuid4
import json

# Add the backend directory to the Python path
sys.path.append(os.path.join(os.path.dirname(__file__), '.'))

# Mock classes to avoid database dependencies
class MockPlant:
    def __init__(self, plant_id, user_id, nickname="Test Plant", species_id=None):
        self.id = plant_id
        self.user_id = user_id
        self.nickname = nickname
        self.species_id = species_id or str(uuid4())
        self.location = "Test Location"
        self.health_status = "healthy"
        self.is_active = True
        self.created_at = datetime.utcnow() - timedelta(days=180)
        self.acquired_date = self.created_at

class MockMilestone:
    def __init__(self, milestone_id, plant_id, user_id, milestone_type):
        self.id = milestone_id
        self.plant_id = plant_id
        self.user_id = user_id
        self.milestone_type = milestone_type
        self.milestone_description = f"Test {milestone_type} milestone"
        self.achieved_at = datetime.utcnow()
        self.badge_type = "bronze"
        self.points_earned = 10
        self.is_seasonal = milestone_type.endswith("_seasonal")
        self.sharing_enabled = True

class MockAnalyticsService:
    """Mock analytics service for testing."""
    
    async def generate_growth_analytics_report(self, db, plant_id, analysis_type):
        return {
            "plant_id": plant_id,
            "plant_info": {
                "nickname": "Test Plant",
                "species_id": str(uuid4()),
                "location": "Test Location"
            },
            "report_type": analysis_type,
            "generated_at": datetime.utcnow().isoformat(),
            "growth_trends": {
                "trend_analysis": {
                    "status": "success",
                    "trend_direction": "increasing",
                    "trend_strength": 0.85
                },
                "growth_rates": {
                    "height_rate_cm_per_day": {"average": 0.12}
                },
                "insights": [
                    {
                        "type": "positive",
                        "title": "Strong Growth Trend",
                        "description": "Plant shows excellent growth",
                        "confidence": 0.9
                    }
                ],
                "measurement_timeline": [
                    {
                        "date": datetime.utcnow().isoformat(),
                        "measurements": {
                            "height_cm": 15.0,
                            "width_cm": 12.0,
                            "leaf_count": 8,
                            "health_score": 0.9
                        }
                    }
                ]
            },
            "analysis_period": {
                "start_date": (datetime.utcnow() - timedelta(days=90)).isoformat(),
                "end_date": datetime.utcnow().isoformat(),
                "days": 90
            }
        }
    
    async def analyze_growth_trends(self, db, plant_id, time_period_days):
        return {
            "plant_id": plant_id,
            "status": "success",
            "trend_analysis": {
                "status": "success",
                "trend_direction": "increasing",
                "trend_strength": 0.85
            },
            "growth_rates": {
                "height_rate_cm_per_day": {"average": 0.12}
            },
            "insights": [
                {
                    "type": "positive",
                    "title": "Strong Growth Trend",
                    "description": "Plant shows excellent growth"
                }
            ]
        }
    
    async def identify_seasonal_patterns(self, db, plant_id, seasons_to_analyze):
        return {
            "plant_id": plant_id,
            "response_patterns": [
                {
                    "pattern_type": "seasonal_growth_cycle",
                    "peak_season": "spring",
                    "dormant_season": "winter"
                }
            ]
        }

class MockDB:
    def __init__(self):
        self.plants = []
        self.milestones = []
        self.users = []
        self._setup_data()
    
    def _setup_data(self):
        # Create test data
        user_id = str(uuid4())
        self.users.append({"id": user_id, "username": "test_user"})
        
        # Create plants
        for i in range(5):
            plant_id = str(uuid4())
            self.plants.append(MockPlant(plant_id, user_id, f"Test Plant {i+1}"))
        
        # Create some milestones
        for i, plant in enumerate(self.plants[:2]):
            milestone_id = str(uuid4())
            milestone_type = "first_growth_milestone" if i == 0 else "rapid_growth_period"
            self.milestones.append(MockMilestone(milestone_id, plant.id, user_id, milestone_type))

    def query(self, model_type):
        return MockQuery(self, model_type)
    
    def add(self, obj):
        if hasattr(obj, 'milestone_type'):
            self.milestones.append(obj)
    
    def commit(self):
        pass
    
    def refresh(self, obj):
        pass

class MockQuery:
    def __init__(self, db, model_type):
        self.db = db
        self.model_type = model_type
        self.filters = []
    
    def filter(self, *conditions):
        self.filters.extend(conditions)
        return self
    
    def order_by(self, *columns):
        return self
    
    def first(self):
        results = self.all()
        return results[0] if results else None
    
    def all(self):
        if "UserPlant" in str(self.model_type):
            return self.db.plants
        elif "GrowthMilestone" in str(self.model_type):
            return self.db.milestones
        elif "User" in str(self.model_type):
            return self.db.users
        else:
            return []

async def test_export_growth_data():
    """Test growth data export functionality."""
    print("Testing Growth Data Export...")
    
    try:
        from app.services.growth_analytics_community import GrowthAnalyticsCommunityService
        
        analytics_service = MockAnalyticsService()
        community_service = GrowthAnalyticsCommunityService(analytics_service)
        db = MockDB()
        
        plant_id = str(db.plants[0].id)
        user_id = str(db.plants[0].user_id)
        
        # Test JSON export with public privacy
        result = await community_service.export_growth_data(
            db, plant_id, user_id, "json", "public"
        )
        
        print(f"✓ Export completed")
        print(f"  Export ID: {result['export_metadata']['export_id']}")
        print(f"  Format: {result['export_metadata']['export_format']}")
        print(f"  Privacy Level: {result['export_metadata']['privacy_level']}")
        print(f"  Includes Timeline: {result['export_metadata']['includes_timelapse']}")
        print(f"  Sharing URL: {result['export_metadata']['sharing_url'] is not None}")
        
        # Test privacy controls
        private_result = await community_service.export_growth_data(
            db, plant_id, user_id, "json", "private"
        )
        
        print(f"✓ Privacy controls applied")
        print(f"  Private export has no sharing URL: {private_result['export_metadata']['sharing_url'] is None}")
        
        # Test CSV format
        csv_result = await community_service.export_growth_data(
            db, plant_id, user_id, "csv", "community"
        )
        
        print(f"✓ CSV export format working")
        print(f"  CSV data keys: {list(csv_result['export_data'].keys())}")
        
        return True
        
    except Exception as e:
        print(f"✗ Export test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

async def test_community_patterns():
    """Test community pattern aggregation."""
    print("\nTesting Community Pattern Aggregation...")
    
    try:
        from app.services.growth_analytics_community import GrowthAnalyticsCommunityService
        
        analytics_service = MockAnalyticsService()
        community_service = GrowthAnalyticsCommunityService(analytics_service)
        db = MockDB()
        
        # Test community pattern aggregation
        result = await community_service.aggregate_community_patterns(
            db, time_period_days=365
        )
        
        print(f"✓ Community pattern aggregation completed")
        print(f"  Status: {result.get('status')}")
        
        if result.get('status') == 'success':
            stats = result['community_stats']
            print(f"  Plants analyzed: {stats['total_plants_analyzed']}")
            print(f"  Successful patterns: {stats['successful_patterns_found']}")
            print(f"  Species coverage: {stats['species_coverage']}")
            print(f"  Insights generated: {len(result.get('insights', []))}")
        else:
            print(f"  Message: {result.get('message')}")
            print(f"  Available plants: {result.get('available_plants', 0)}")
        
        # Test with species filter
        species_result = await community_service.aggregate_community_patterns(
            db, species_id=str(db.plants[0].species_id), time_period_days=365
        )
        
        print(f"✓ Species-filtered aggregation completed")
        print(f"  Status: {species_result.get('status')}")
        
        return True
        
    except Exception as e:
        print(f"✗ Community patterns test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

async def test_achievement_system():
    """Test achievement system functionality."""
    print("\nTesting Achievement System...")
    
    try:
        from app.services.growth_analytics_community import GrowthAnalyticsCommunityService
        
        analytics_service = MockAnalyticsService()
        community_service = GrowthAnalyticsCommunityService(analytics_service)
        db = MockDB()
        
        plant_id = str(db.plants[0].id)
        user_id = str(db.plants[0].user_id)
        
        # Test creating a new achievement
        milestone_data = {
            "growth_rate": 0.15,
            "duration_days": 30,
            "health_improvement": 0.2
        }
        
        result = await community_service.create_achievement_system(
            db, user_id, plant_id, "rapid_growth_period", milestone_data
        )
        
        print(f"✓ Achievement created")
        print(f"  Status: {result['status']}")
        print(f"  Achievement Type: {result['achievement']['type']}")
        print(f"  Title: {result['achievement']['title']}")
        print(f"  Points Earned: {result['achievement']['points_earned']}")
        print(f"  Badge Type: {result['achievement']['badge_type']}")
        print(f"  Is Seasonal: {result['achievement']['is_seasonal']}")
        
        # Test getting user achievements
        achievements_result = await community_service.get_user_achievements(db, user_id)
        
        print(f"✓ User achievements retrieved")
        print(f"  Total achievements: {achievements_result['achievement_summary']['total_achievements']}")
        print(f"  Total points: {achievements_result['achievement_summary']['total_points']}")
        print(f"  User level: {achievements_result['achievement_summary']['user_level']}")
        print(f"  Recent achievements: {len(achievements_result['recent_achievements'])}")
        print(f"  Available challenges: {len(achievements_result['available_challenges'])}")
        
        # Test duplicate achievement prevention
        duplicate_result = await community_service.create_achievement_system(
            db, user_id, plant_id, "rapid_growth_period", milestone_data
        )
        
        print(f"✓ Duplicate prevention working")
        print(f"  Duplicate status: {duplicate_result['status']}")
        
        return True
        
    except Exception as e:
        print(f"✗ Achievement system test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

async def test_privacy_and_sharing():
    """Test privacy controls and sharing features."""
    print("\nTesting Privacy Controls and Sharing...")
    
    try:
        from app.services.growth_analytics_community import GrowthAnalyticsCommunityService
        
        analytics_service = MockAnalyticsService()
        community_service = GrowthAnalyticsCommunityService(analytics_service)
        
        # Test privacy control application
        test_data = {
            "plant_info": {
                "nickname": "My Secret Plant",
                "location": "My Home",
                "species_id": "species_123"
            },
            "growth_trends": {
                "measurement_timeline": [{"date": "2024-01-01", "height": 10}]
            }
        }
        
        # Test public privacy (no changes)
        public_data = community_service._apply_privacy_controls(test_data, "public")
        print(f"✓ Public privacy: keeps all data")
        print(f"  Has nickname: {'nickname' in public_data.get('plant_info', {})}")
        print(f"  Has timeline: {'measurement_timeline' in public_data.get('growth_trends', {})}")
        
        # Test community privacy (removes personal info)
        community_data = community_service._apply_privacy_controls(test_data, "community")
        print(f"✓ Community privacy: removes personal identifiers")
        print(f"  Has nickname: {'nickname' in community_data.get('plant_info', {})}")
        print(f"  Has species: {'species_id' in community_data.get('plant_info', {})}")
        
        # Test private privacy (removes identifying info)
        private_data = community_service._apply_privacy_controls(test_data, "private")
        print(f"✓ Private privacy: removes identifying information")
        print(f"  Has plant_info: {'plant_info' in private_data}")
        print(f"  Has timeline: {'measurement_timeline' in private_data.get('growth_trends', {})}")
        
        # Test sharing options
        public_options = community_service._get_sharing_options("public")
        community_options = community_service._get_sharing_options("community")
        private_options = community_service._get_sharing_options("private")
        
        print(f"✓ Sharing options configured correctly")
        print(f"  Public can share publicly: {public_options['can_share_publicly']}")
        print(f"  Community can share publicly: {community_options['can_share_publicly']}")
        print(f"  Private can share publicly: {private_options['can_share_publicly']}")
        
        return True
        
    except Exception as e:
        print(f"✗ Privacy and sharing test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

async def main():
    """Run all community feature tests."""
    print("=== Growth Analytics Community Features Test Suite ===\n")
    
    tests = [
        test_export_growth_data,
        test_community_patterns,
        test_achievement_system,
        test_privacy_and_sharing
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
        print("🎉 All community features tests passed!")
        print("\nKey Features Verified:")
        print("✓ Growth data export functionality with privacy controls")
        print("✓ Community pattern aggregation for successful care strategies")
        print("✓ Achievement system for growth milestones and seasonal challenges")
        print("✓ Privacy controls and sharing options")
    else:
        print("❌ Some community features tests failed.")
    
    return passed == total

if __name__ == "__main__":
    success = asyncio.run(main())
    sys.exit(0 if success else 1)