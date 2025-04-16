from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Incident, IncidentImage, IncidentComment, IncidentAudio

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'role', 'phone_number', 'is_verified')
        read_only_fields = ('id', 'is_verified')

class IncidentImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = IncidentImage
        fields = ('id', 'image', 'uploaded_at')
        read_only_fields = ('id', 'uploaded_at')

class IncidentCommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = IncidentComment
        fields = ('id', 'user', 'comment', 'created_at')
        read_only_fields = ('id', 'user', 'created_at')

class IncidentAudioSerializer(serializers.ModelSerializer):
    class Meta:
        model = IncidentAudio
        fields = ('id', 'audio', 'uploaded_at')
        read_only_fields = ('id', 'uploaded_at')

class IncidentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    images = IncidentImageSerializer(many=True, read_only=True)
    audios = IncidentAudioSerializer(many=True, read_only=True)
    comments = IncidentCommentSerializer(many=True, read_only=True)
    
    class Meta:
        model = Incident
        fields = (
            'id', 'user', 'title', 'description', 'category', 'status',
            'latitude', 'longitude', 'address', 'created_at', 'updated_at',
            'is_offline', 'images', 'audios', 'comments'
        )
        read_only_fields = ('id', 'user', 'created_at', 'updated_at', 'is_offline')

class IncidentCreateSerializer(serializers.ModelSerializer):
    images = serializers.ListField(
        child=serializers.ImageField(),
        write_only=True,
        required=False
    )
    audios = serializers.ListField(
        child=serializers.FileField(),
        write_only=True,
        required=False
    )
    
    class Meta:
        model = Incident
        fields = (
            'title', 'description', 'category', 'latitude',
            'longitude', 'address', 'images', 'audios'
        )
    
    def create(self, validated_data):
        images_data = validated_data.pop('images', [])
        audios_data = validated_data.pop('audios', [])
        incident = Incident.objects.create(**validated_data)
        
        for image_data in images_data:
            IncidentImage.objects.create(incident=incident, image=image_data)
            
        for audio_data in audios_data:
            IncidentAudio.objects.create(incident=incident, audio=audio_data)
        
        return incident

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'phone_number')
    
    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user 