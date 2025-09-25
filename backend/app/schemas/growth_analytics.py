"""Growth Analytics Schemas - Minimal version to avoid recursion errors
Contains basic request/response schemas for growth analytics endpoints"""


# Simple constants instead of Enums to avoid Pydantic recursion
class AnalysisType:
    GROWTH_RATE = "growth_rate"
    HEALTH_TRENDS = "health_trends"
    SEASONAL_PATTERNS = "seasonal_patterns"
    COMPARATIVE = "comparative"


class ComparisonType:
    PLANT_TO_PLANT = "plant_to_plant"
    SEASONAL = "seasonal"
    HISTORICAL = "historical"


# Minimal request schemas - plain Python classes to avoid Pydantic recursion
class GrowthTrendsRequest:
    def __init__(self, plant_id: str = None, analysis_type: str = None):
        self.plant_id = plant_id
        self.analysis_type = analysis_type


class ComparativeAnalysisRequest:
    def __init__(self, plant_ids: list = None, comparison_type: str = None):
        self.plant_ids = plant_ids or []
        self.comparison_type = comparison_type


class SeasonalPatternsRequest:
    def __init__(self, plant_id: str = None, year: int = None):
        self.plant_id = plant_id
        self.year = year


class AnalyticsReportRequest:
    def __init__(self, plant_id: str = None, report_type: str = None):
        self.plant_id = plant_id
        self.report_type = report_type


# Minimal response schemas - plain Python classes to avoid Pydantic recursion
class GrowthTrendsResponse:
    def __init__(self, trends: dict = None, analysis_type: str = None):
        self.trends = trends or {}
        self.analysis_type = analysis_type


class ComparativeAnalysisResponse:
    def __init__(self, comparison_data: dict = None, comparison_type: str = None):
        self.comparison_data = comparison_data or {}
        self.comparison_type = comparison_type


class SeasonalPatternsResponse:
    def __init__(self, patterns: dict = None, year: int = None):
        self.patterns = patterns or {}
        self.year = year


class AnalyticsReportResponse:
    def __init__(self, report_data: dict = None, report_type: str = None):
        self.report_data = report_data or {}
        self.report_type = report_type