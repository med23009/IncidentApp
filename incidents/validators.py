from django.core.exceptions import ValidationError
from django.conf import settings
import os

def validate_audio_extension(value):
    ext = os.path.splitext(value.name)[1][1:].lower()
    if ext not in settings.ALLOWED_AUDIO_EXTENSIONS:
        raise ValidationError(
            f'Format de fichier non supporté. Les formats autorisés sont: {", ".join(settings.ALLOWED_AUDIO_EXTENSIONS)}'
        )

def validate_image_extension(value):
    ext = os.path.splitext(value.name)[1][1:].lower()
    if ext not in settings.ALLOWED_IMAGE_EXTENSIONS:
        raise ValidationError(
            f'Format de fichier non supporté. Les formats autorisés sont: {", ".join(settings.ALLOWED_IMAGE_EXTENSIONS)}'
        ) 