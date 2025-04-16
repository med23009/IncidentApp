from django.conf import settings
import os

def get_upload_path(instance, filename):
    """Génère un chemin d'upload unique pour les fichiers médias"""
    if hasattr(instance, 'user'):
        user_id = instance.user.id
    else:
        user_id = instance.incident.user.id
    
    # Crée un chemin basé sur le type de fichier et l'utilisateur
    if isinstance(instance, settings.INCIDENT_IMAGE_MODEL):
        return f'incidents/{user_id}/images/{filename}'
    else:
        return f'incidents/{user_id}/other/{filename}'

def delete_old_file(path):
    """Supprime l'ancien fichier lors de la mise à jour"""
    if os.path.isfile(path):
        os.remove(path) 