from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.contrib.auth import get_user_model
from .models import Incident, IncidentImage, IncidentComment

User = get_user_model()

class UserTests(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'phone_number': '+1234567890'
        }
        self.admin_user = User.objects.create_superuser(
            username='admin',
            email='admin@example.com',
            password='adminpass123',
            role='admin'
        )

    def test_user_registration(self):
        url = reverse('user-register')
        response = self.client.post(url, self.user_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(User.objects.count(), 2)

    def test_user_login(self):
        User.objects.create_user(**self.user_data)
        url = reverse('token_obtain_pair')
        response = self.client.post(url, {
            'username': 'testuser',
            'password': 'testpass123'
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)

class IncidentTests(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.admin_user = User.objects.create_superuser(
            username='admin',
            email='admin@example.com',
            password='adminpass123',
            role='admin'
        )
        self.incident_data = {
            'title': 'Test Incident',
            'description': 'Test Description',
            'category': 'fire',
            'latitude': 48.8566,
            'longitude': 2.3522,
            'address': 'Paris, France'
        }

    def test_create_incident(self):
        self.client.force_authenticate(user=self.user)
        url = reverse('incident-list')
        response = self.client.post(url, self.incident_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Incident.objects.count(), 1)

    def test_list_incidents(self):
        self.client.force_authenticate(user=self.user)
        Incident.objects.create(user=self.user, **self.incident_data)
        url = reverse('incident-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_update_incident_status(self):
        self.client.force_authenticate(user=self.admin_user)
        incident = Incident.objects.create(user=self.user, **self.incident_data)
        url = reverse('incident-update-status', args=[incident.id])
        response = self.client.post(url, {'status': 'in_progress'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Incident.objects.get(id=incident.id).status, 'in_progress')

class CommentTests(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.incident = Incident.objects.create(
            user=self.user,
            title='Test Incident',
            description='Test Description',
            category='fire',
            latitude=48.8566,
            longitude=2.3522,
            address='Paris, France'
        )

    def test_add_comment(self):
        self.client.force_authenticate(user=self.user)
        url = reverse('incident-add-comment', args=[self.incident.id])
        response = self.client.post(url, {'comment': 'Test Comment'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(IncidentComment.objects.count(), 1)
