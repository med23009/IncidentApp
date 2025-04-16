from django.contrib import admin
from .models import Incident, IncidentImage, IncidentComment

@admin.register(Incident)
class IncidentAdmin(admin.ModelAdmin):
    list_display = ('title', 'user', 'category', 'status', 'created_at')
    list_filter = ('category', 'status')
    search_fields = ('title', 'description', 'address')

@admin.register(IncidentImage)
class IncidentImageAdmin(admin.ModelAdmin):
    list_display = ('incident', 'uploaded_at')
    list_filter = ('uploaded_at',)

@admin.register(IncidentComment)
class IncidentCommentAdmin(admin.ModelAdmin):
    list_display = ('incident', 'user', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('comment',)
