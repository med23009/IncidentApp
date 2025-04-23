from django.db import models
from django.utils.translation import gettext_lazy as _
from .validators import validate_image_extension, validate_audio_extension
from django.conf import settings

class Incident(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='incidents')
    title = models.CharField(max_length=200)
    description = models.TextField()
    category = models.CharField(max_length=50)
    status = models.CharField(max_length=50, default='pending')
    latitude = models.FloatField()
    longitude = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_offline = models.BooleanField(default=False)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = _('Incident')
        verbose_name_plural = _('Incidents')

class IncidentImage(models.Model):
    incident = models.ForeignKey(Incident, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='incident_images/', validators=[validate_image_extension])
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = _('Image d\'incident')
        verbose_name_plural = _('Images d\'incidents')

class IncidentAudio(models.Model):
    incident = models.ForeignKey(Incident, on_delete=models.CASCADE, related_name='audios')
    audio = models.FileField(upload_to='incident_audios/', validators=[validate_audio_extension])
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = _('Enregistrement vocal')
        verbose_name_plural = _('Enregistrements vocaux')

class IncidentComment(models.Model):
    incident = models.ForeignKey(Incident, on_delete=models.CASCADE, related_name='comments')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['created_at']
        verbose_name = _('Commentaire')
        verbose_name_plural = _('Commentaires')
