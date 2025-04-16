from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from django.core.mail import send_mail
from django.conf import settings
from django.apps import apps

@receiver(post_save)
def notify_admin_on_new_incident(sender, instance, created, **kwargs):
    if sender.__name__ == 'Incident' and created and not instance.is_offline:
        User = apps.get_model('incidents', 'User')
        admin_users = User.objects.filter(role='admin', is_active=True)
        admin_emails = [admin.email for admin in admin_users if admin.email]
        
        if admin_emails:
            subject = f'Nouvel incident signalé: {instance.title}'
            message = f'''
            Un nouvel incident a été signalé:
            
            Titre: {instance.title}
            Catégorie: {instance.get_category_display()}
            Description: {instance.description}
            Localisation: {instance.address}
            
            Connectez-vous à l'administration pour plus de détails.
            '''
            
            send_mail(
                subject,
                message,
                settings.DEFAULT_FROM_EMAIL,
                admin_emails,
                fail_silently=True,
            )

@receiver(pre_save)
def update_incident_status(sender, instance, **kwargs):
    if sender.__name__ == 'Incident' and instance.pk:
        Incident = apps.get_model('incidents', 'Incident')
        try:
            old_instance = Incident.objects.get(pk=instance.pk)
            if old_instance.status != instance.status:
                subject = f'Statut de votre incident mis à jour: {instance.title}'
                message = f'''
                Le statut de votre incident a été mis à jour:
                
                Titre: {instance.title}
                Nouveau statut: {instance.get_status_display()}
                
                Connectez-vous à l'application pour plus de détails.
                '''
                
                send_mail(
                    subject,
                    message,
                    settings.DEFAULT_FROM_EMAIL,
                    [instance.user.email],
                    fail_silently=True,
                )
        except Incident.DoesNotExist:
            pass 