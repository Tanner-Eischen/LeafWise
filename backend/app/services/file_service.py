"""File upload and media management service.

This module handles file uploads, media processing, and storage
for the messaging and story features.
"""

import os
import uuid
import mimetypes
from typing import Optional, Tuple
from pathlib import Path
from fastapi import UploadFile, HTTPException, status
from PIL import Image
import aiofiles

from app.core.config import settings


class FileService:
    """Service for handling file uploads and media processing."""
    
    def __init__(self):
        self.upload_dir = Path("uploads")
        self.max_file_size = 50 * 1024 * 1024  # 50MB
        self.allowed_image_types = {"image/jpeg", "image/png", "image/gif", "image/webp"}
        self.allowed_video_types = {"video/mp4", "video/quicktime", "video/x-msvideo"}
        self.allowed_audio_types = {"audio/mpeg", "audio/wav", "audio/ogg"}
        
        # Create upload directories
        self._create_upload_directories()
    
    def _create_upload_directories(self) -> None:
        """Create necessary upload directories."""
        directories = [
            self.upload_dir / "images",
            self.upload_dir / "videos", 
            self.upload_dir / "audio",
            self.upload_dir / "thumbnails"
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
    
    async def upload_media_file(
        self, 
        file: UploadFile
    ) -> Tuple[str, int, Optional[int]]:
        """Upload a media file and return URL, file size, and duration.
        
        Args:
            file: The uploaded file
            
        Returns:
            Tuple of (media_url, file_size, duration)
            
        Raises:
            HTTPException: If file validation fails
        """
        # Validate file
        await self._validate_file(file)
        
        # Generate unique filename
        file_extension = Path(file.filename).suffix.lower()
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        
        # Determine file type and subdirectory
        content_type = file.content_type
        if content_type in self.allowed_image_types:
            subdirectory = "images"
        elif content_type in self.allowed_video_types:
            subdirectory = "videos"
        elif content_type in self.allowed_audio_types:
            subdirectory = "audio"
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unsupported file type"
            )
        
        # Save file
        file_path = self.upload_dir / subdirectory / unique_filename
        file_size = await self._save_file(file, file_path)
        
        # Process file based on type
        duration = None
        if content_type in self.allowed_image_types:
            await self._process_image(file_path)
        elif content_type in self.allowed_video_types:
            duration = await self._process_video(file_path)
        elif content_type in self.allowed_audio_types:
            duration = await self._process_audio(file_path)
        
        # Return relative URL for the file
        media_url = f"/uploads/{subdirectory}/{unique_filename}"
        
        return media_url, file_size, duration
    
    async def _validate_file(self, file: UploadFile) -> None:
        """Validate uploaded file.
        
        Args:
            file: The uploaded file
            
        Raises:
            HTTPException: If validation fails
        """
        if not file.filename:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No file provided"
            )
        
        # Check file size
        file.file.seek(0, 2)  # Seek to end
        file_size = file.file.tell()
        file.file.seek(0)  # Reset to beginning
        
        if file_size > self.max_file_size:
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail=f"File too large. Maximum size is {self.max_file_size // (1024*1024)}MB"
            )
        
        # Check content type
        content_type = file.content_type
        allowed_types = (
            self.allowed_image_types | 
            self.allowed_video_types | 
            self.allowed_audio_types
        )
        
        if content_type not in allowed_types:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unsupported file type: {content_type}"
            )
    
    async def _save_file(self, file: UploadFile, file_path: Path) -> int:
        """Save uploaded file to disk.
        
        Args:
            file: The uploaded file
            file_path: Path where to save the file
            
        Returns:
            File size in bytes
        """
        file_size = 0
        
        async with aiofiles.open(file_path, 'wb') as f:
            while chunk := await file.read(8192):  # Read in 8KB chunks
                await f.write(chunk)
                file_size += len(chunk)
        
        return file_size
    
    async def _process_image(self, file_path: Path) -> None:
        """Process uploaded image (resize, optimize).
        
        Args:
            file_path: Path to the image file
        """
        try:
            with Image.open(file_path) as img:
                # Convert to RGB if necessary
                if img.mode in ('RGBA', 'LA', 'P'):
                    img = img.convert('RGB')
                
                # Resize if too large (max 1920x1920)
                max_size = (1920, 1920)
                if img.size[0] > max_size[0] or img.size[1] > max_size[1]:
                    img.thumbnail(max_size, Image.Resampling.LANCZOS)
                
                # Save optimized version
                img.save(file_path, optimize=True, quality=85)
                
                # Create thumbnail
                thumbnail_path = (
                    self.upload_dir / "thumbnails" / 
                    f"thumb_{file_path.name}"
                )
                img.thumbnail((300, 300), Image.Resampling.LANCZOS)
                img.save(thumbnail_path, optimize=True, quality=80)
                
        except Exception as e:
            # If image processing fails, keep original file
            print(f"Image processing failed for {file_path}: {e}")
    
    async def _process_video(self, file_path: Path) -> Optional[int]:
        """Process uploaded video (get duration, create thumbnail).
        
        Args:
            file_path: Path to the video file
            
        Returns:
            Video duration in seconds
        """
        # For now, return None as duration
        # In a production app, you'd use ffmpeg to get duration and create thumbnails
        return None
    
    async def _process_audio(self, file_path: Path) -> Optional[int]:
        """Process uploaded audio (get duration).
        
        Args:
            file_path: Path to the audio file
            
        Returns:
            Audio duration in seconds
        """
        # For now, return None as duration
        # In a production app, you'd use ffmpeg or similar to get duration
        return None
    
    async def delete_file(self, file_url: str) -> bool:
        """Delete a file from storage.
        
        Args:
            file_url: URL of the file to delete
            
        Returns:
            True if file was deleted, False otherwise
        """
        try:
            # Convert URL to file path
            if file_url.startswith("/uploads/"):
                relative_path = file_url[1:]  # Remove leading slash
                file_path = Path(relative_path)
                
                if file_path.exists():
                    file_path.unlink()
                    
                    # Also delete thumbnail if it exists
                    if file_path.parent.name in ["images", "videos"]:
                        thumbnail_path = (
                            self.upload_dir / "thumbnails" / 
                            f"thumb_{file_path.name}"
                        )
                        if thumbnail_path.exists():
                            thumbnail_path.unlink()
                    
                    return True
            
            return False
            
        except Exception as e:
            print(f"Error deleting file {file_url}: {e}")
            return False


# Global instance
file_service = FileService()


# Convenience functions for backward compatibility
async def upload_media_file(file: UploadFile) -> Tuple[str, int, Optional[int]]:
    """Upload a media file.
    
    Args:
        file: The uploaded file
        
    Returns:
        Tuple of (media_url, file_size, duration)
    """
    return await file_service.upload_media_file(file)


async def delete_media_file(file_url: str) -> bool:
    """Delete a media file.
    
    Args:
        file_url: URL of the file to delete
        
    Returns:
        True if file was deleted, False otherwise
    """
    return await file_service.delete_file(file_url)