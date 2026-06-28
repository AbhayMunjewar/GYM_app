import os
import logging
from django.conf import settings
from django.core.files.storage import FileSystemStorage

logger = logging.getLogger(__name__)

class SaaSStorageService:
    """
    SaaS unified Storage Service.
    Saves files locally by default, or pushes to AWS S3 if credentials are provided in settings.
    """
    
    @staticmethod
    def is_s3_configured():
        return bool(
            getattr(settings, 'AWS_ACCESS_KEY_ID', '') and
            getattr(settings, 'AWS_SECRET_ACCESS_KEY', '') and
            getattr(settings, 'AWS_STORAGE_BUCKET_NAME', '')
        )

    @classmethod
    def save_file(cls, file_obj, relative_path):
        """
        Saves file dynamically.
        relative_path is a path like 'profile_images/myphoto.jpg'.
        Returns the public URL of the saved file.
        """
        if cls.is_s3_configured():
            try:
                import boto3
                s3_client = boto3.client(
                    's3',
                    aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                    aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
                    region_name=settings.AWS_S3_REGION_NAME
                )
                bucket_name = settings.AWS_STORAGE_BUCKET_NAME
                
                # Upload to S3
                s3_client.upload_fileobj(
                    file_obj,
                    bucket_name,
                    relative_path,
                    ExtraArgs={'ACL': 'public-read', 'ContentType': getattr(file_obj, 'content_type', 'image/jpeg')}
                )
                
                # Construct public S3 URL
                s3_url = f"https://{bucket_name}.s3.{settings.AWS_S3_REGION_NAME}.amazonaws.com/{relative_path}"
                logger.info(f"File uploaded to AWS S3 successfully: {s3_url}")
                return s3_url
            except Exception as e:
                logger.error(f"S3 upload failed: {str(e)}. Falling back to local storage.")

        # Fallback to Local Storage
        fs = FileSystemStorage()
        saved_name = fs.save(relative_path, file_obj)
        local_url = fs.url(saved_name)
        logger.info(f"File saved locally: {local_url}")
        return local_url
