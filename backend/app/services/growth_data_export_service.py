"""
Growth Data Export Service for LeafWise Platform

This service handles data export functionality including:
- Growth data export in multiple formats (CSV, PDF, JSON)
- Privacy controls and data filtering
- Sharing URL generation and management
- Export history and tracking

Focused on data export, sharing, and privacy management.
"""

from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
import csv
import json
import io
import uuid
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors

from app.models.timelapse import TimelapseSession, GrowthMilestone
from app.models.growth_photo import GrowthPhoto
from app.models.user_plant import UserPlant


class GrowthDataExportService:
    """Service for exporting and sharing growth data with privacy controls."""
    
    def __init__(self):
        self.export_history = {}
    
    async def export_growth_data(
        self,
        db: Session,
        plant_id: str,
        export_format: str = "csv",
        privacy_level: str = "private",
        date_range: Optional[Tuple[datetime, datetime]] = None,
        include_photos: bool = False
    ) -> Dict[str, Any]:
        """
        Export growth data for a plant in specified format.
        
        Args:
            db: Database session
            plant_id: ID of the plant to export
            export_format: Format for export (csv, pdf, json)
            privacy_level: Privacy level (private, community, public)
            date_range: Optional date range tuple (start, end)
            include_photos: Whether to include photo references
            
        Returns:
            Dictionary containing export results and download information
        """
        plant = db.query(UserPlant).filter(UserPlant.id == plant_id).first()
        if not plant:
            raise ValueError(f"Plant with id {plant_id} not found")
        
        # Get growth data
        growth_data = self.collect_growth_data(db, plant_id, date_range)
        
        if not growth_data:
            return self._empty_export_response(plant_id)
        
        # Apply privacy controls
        filtered_data = self.apply_privacy_controls(growth_data, privacy_level)
        
        # Generate export based on format
        export_result = None
        if export_format.lower() == "csv":
            export_result = self.export_to_csv(filtered_data, plant)
        elif export_format.lower() == "pdf":
            export_result = self.export_to_pdf(filtered_data, plant)
        elif export_format.lower() == "json":
            export_result = self.export_to_json(filtered_data, plant)
        else:
            raise ValueError(f"Unsupported export format: {export_format}")
        
        # Generate sharing URL if needed
        sharing_url = None
        if privacy_level in ["community", "public"]:
            sharing_url = self.generate_sharing_url(plant_id, export_format, privacy_level)
        
        # Store export record
        export_record = self.store_export_record(
            plant_id, export_format, privacy_level, len(filtered_data)
        )
        
        return {
            "plant_id": plant_id,
            "export_format": export_format,
            "privacy_level": privacy_level,
            "data_points": len(filtered_data),
            "export_size_bytes": len(export_result["content"]),
            "sharing_url": sharing_url,
            "export_id": export_record["export_id"],
            "download_content": export_result["content"],
            "filename": export_result["filename"]
        }
    
    def collect_growth_data(
        self,
        db: Session,
        plant_id: str,
        date_range: Optional[Tuple[datetime, datetime]] = None
    ) -> List[Dict[str, Any]]:
        """
        Collect growth data for export.
        
        Args:
            db: Database session
            plant_id: ID of the plant
            date_range: Optional date range filter
            
        Returns:
            List of growth data points
        """
        # Build query for timelapse sessions
        query = db.query(TimelapseSession).filter(TimelapseSession.plant_id == plant_id)
        
        if date_range:
            start_date, end_date = date_range
            query = query.filter(
                TimelapseSession.created_at >= start_date,
                TimelapseSession.created_at <= end_date
            )
        
        sessions = query.order_by(TimelapseSession.created_at).all()
        
        growth_data = []
        for session in sessions:
            # Get photos for this session
            photos = db.query(GrowthPhoto).filter(
                GrowthPhoto.timelapse_session_id == session.id
            ).order_by(GrowthPhoto.captured_at).all()
            
            for photo in photos:
                growth_data.append({
                    "date": photo.captured_at.isoformat(),
                    "height_cm": photo.height_cm or 0,
                    "leaf_count": photo.leaf_count or 0,
                    "health_score": photo.health_score or 0,
                    "session_id": session.id,
                    "photo_id": photo.id,
                    "notes": photo.notes or "",
                    "environmental_conditions": {
                        "temperature": getattr(photo, 'temperature', None),
                        "humidity": getattr(photo, 'humidity', None),
                        "light_level": getattr(photo, 'light_level', None)
                    }
                })
        
        return growth_data
    
    def apply_privacy_controls(
        self,
        growth_data: List[Dict[str, Any]],
        privacy_level: str
    ) -> List[Dict[str, Any]]:
        """
        Apply privacy controls to growth data.
        
        Args:
            growth_data: Raw growth data
            privacy_level: Privacy level to apply
            
        Returns:
            Filtered growth data
        """
        if privacy_level == "private":
            # Include all data for private exports
            return growth_data
        
        elif privacy_level == "community":
            # Remove sensitive information but keep growth metrics
            filtered_data = []
            for data_point in growth_data:
                filtered_point = {
                    "date": data_point["date"],
                    "height_cm": data_point["height_cm"],
                    "leaf_count": data_point["leaf_count"],
                    "health_score": data_point["health_score"]
                }
                filtered_data.append(filtered_point)
            return filtered_data
        
        elif privacy_level == "public":
            # Only include aggregated/anonymized data
            if len(growth_data) < 5:
                return []  # Not enough data for public sharing
            
            # Sample every 5th data point and remove identifying information
            filtered_data = []
            for i, data_point in enumerate(growth_data):
                if i % 5 == 0:  # Sample every 5th point
                    filtered_point = {
                        "relative_day": i // 5,
                        "height_cm": data_point["height_cm"],
                        "health_score": data_point["health_score"]
                    }
                    filtered_data.append(filtered_point)
            return filtered_data
        
        return growth_data
    
    def export_to_csv(self, growth_data: List[Dict[str, Any]], plant: UserPlant) -> Dict[str, Any]:
        """Export growth data to CSV format."""
        output = io.StringIO()
        
        if not growth_data:
            return {"content": "", "filename": f"plant_{plant.id}_growth_data.csv"}
        
        # Get field names from first data point
        fieldnames = list(growth_data[0].keys())
        
        writer = csv.DictWriter(output, fieldnames=fieldnames)
        writer.writeheader()
        
        for data_point in growth_data:
            # Flatten nested dictionaries for CSV
            flattened_point = {}
            for key, value in data_point.items():
                if isinstance(value, dict):
                    for nested_key, nested_value in value.items():
                        flattened_point[f"{key}_{nested_key}"] = nested_value
                else:
                    flattened_point[key] = value
            writer.writerow(flattened_point)
        
        content = output.getvalue()
        output.close()
        
        return {
            "content": content,
            "filename": f"plant_{plant.id}_growth_data.csv"
        }
    
    def export_to_json(self, growth_data: List[Dict[str, Any]], plant: UserPlant) -> Dict[str, Any]:
        """Export growth data to JSON format."""
        export_data = {
            "plant_id": plant.id,
            "plant_name": plant.name,
            "species": plant.species_id,
            "export_date": datetime.utcnow().isoformat(),
            "data_points": len(growth_data),
            "growth_data": growth_data
        }
        
        content = json.dumps(export_data, indent=2, default=str)
        
        return {
            "content": content,
            "filename": f"plant_{plant.id}_growth_data.json"
        }
    
    def export_to_pdf(self, growth_data: List[Dict[str, Any]], plant: UserPlant) -> Dict[str, Any]:
        """Export growth data to PDF format."""
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        styles = getSampleStyleSheet()
        story = []
        
        # Title
        title = Paragraph(f"Growth Report: {plant.name}", styles['Title'])
        story.append(title)
        story.append(Spacer(1, 12))
        
        # Plant information
        plant_info = Paragraph(f"Plant ID: {plant.id}<br/>Species: {plant.species_id}<br/>Export Date: {datetime.utcnow().strftime('%Y-%m-%d')}", styles['Normal'])
        story.append(plant_info)
        story.append(Spacer(1, 12))
        
        # Growth data summary
        if growth_data:
            summary = Paragraph(f"Total Data Points: {len(growth_data)}<br/>Date Range: {growth_data[0]['date']} to {growth_data[-1]['date']}", styles['Normal'])
            story.append(summary)
            story.append(Spacer(1, 12))
            
            # Create table with growth data (first 50 points to avoid huge PDFs)
            table_data = [['Date', 'Height (cm)', 'Leaf Count', 'Health Score']]
            for data_point in growth_data[:50]:
                table_data.append([
                    data_point.get('date', '')[:10],  # Just the date part
                    str(data_point.get('height_cm', 0)),
                    str(data_point.get('leaf_count', 0)),
                    str(data_point.get('health_score', 0))
                ])
            
            table = Table(table_data)
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 14),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                ('GRID', (0, 0), (-1, -1), 1, colors.black)
            ]))
            story.append(table)
        
        doc.build(story)
        content = buffer.getvalue()
        buffer.close()
        
        return {
            "content": content,
            "filename": f"plant_{plant.id}_growth_report.pdf"
        }
    
    def generate_sharing_url(self, plant_id: str, export_format: str, privacy_level: str) -> str:
        """Generate a sharing URL for exported data."""
        share_id = str(uuid.uuid4())
        base_url = "https://leafwise.app/shared"  # This would be configurable
        
        # Store sharing metadata (in a real implementation, this would go to database)
        self.export_history[share_id] = {
            "plant_id": plant_id,
            "export_format": export_format,
            "privacy_level": privacy_level,
            "created_at": datetime.utcnow(),
            "access_count": 0
        }
        
        return f"{base_url}/{share_id}"
    
    def store_export_record(
        self,
        plant_id: str,
        export_format: str,
        privacy_level: str,
        data_points: int
    ) -> Dict[str, Any]:
        """Store export record for tracking and history."""
        export_id = str(uuid.uuid4())
        
        record = {
            "export_id": export_id,
            "plant_id": plant_id,
            "export_format": export_format,
            "privacy_level": privacy_level,
            "data_points": data_points,
            "created_at": datetime.utcnow(),
            "status": "completed"
        }
        
        # In a real implementation, this would be stored in database
        self.export_history[export_id] = record
        
        return record
    
    def get_export_history(self, plant_id: str) -> List[Dict[str, Any]]:
        """Get export history for a plant."""
        history = []
        for export_id, record in self.export_history.items():
            if record.get("plant_id") == plant_id:
                history.append(record)
        
        return sorted(history, key=lambda x: x["created_at"], reverse=True)
    
    def _empty_export_response(self, plant_id: str) -> Dict[str, Any]:
        """Return response for plants with no data to export."""
        return {
            "plant_id": plant_id,
            "status": "no_data",
            "message": "No growth data available for export"
        }


def get_growth_data_export_service() -> GrowthDataExportService:
    """Factory function to get GrowthDataExportService instance."""
    return GrowthDataExportService()