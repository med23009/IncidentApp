import requests
import json

# URL de base
BASE_URL = 'http://127.0.0.1:8000'

# 1. Obtenir le token
def get_token():
    url = f'{BASE_URL}/api/token/'
    data = {
        'username': 'mohamed',
        'password': 'sidi'
    }
    response = requests.post(url, json=data)
    if response.status_code == 200:
        return response.json()['access']
    else:
        print(f"Erreur lors de l'obtention du token: {response.status_code}")
        print(response.text)
        return None

# 2. Créer un incident
def create_incident(token):
    url = f'{BASE_URL}/api/incidents/'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    data = {
        'title': 'Test Incident',
        'description': 'Ceci est un test de création d\'incident',
        'category': 'fire',
        'latitude': 48.8566,
        'longitude': 2.3522,
        'address': 'Paris, France'
    }
    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 201:
        print("Incident créé avec succès!")
        print(response.json())
    else:
        print(f"Erreur lors de la création de l'incident: {response.status_code}")
        print(response.text)

if __name__ == '__main__':
    token = get_token()
    if token:
        create_incident(token) 