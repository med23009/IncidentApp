from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.contrib.auth import authenticate
from django.core.exceptions import ValidationError
from .serializers import RegisterSerializer, LoginSerializer, UserSerializer

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            serializer = RegisterSerializer(data=request.data)
            if serializer.is_valid():
                user = serializer.save()
                refresh = RefreshToken.for_user(user)
                return Response({
                    'user': UserSerializer(user).data,
                    'refresh': str(refresh),
                    'access': str(refresh.access_token),
                }, status=status.HTTP_201_CREATED)
            return Response({
                'status': 'error',
                'message': 'Données invalides',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
        except ValidationError as e:
            return Response({
                'status': 'error',
                'message': 'Erreur de validation',
                'errors': e.messages
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({
                'status': 'error',
                'message': 'Une erreur est survenue lors de l\'inscription',
                'errors': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            serializer = LoginSerializer(data=request.data)
            if serializer.is_valid():
                user = authenticate(
                    email=serializer.validated_data['email'],
                    password=serializer.validated_data['password']
                )
                if user:
                    if not user.is_active:
                        return Response({
                            'status': 'error',
                            'message': 'Votre compte est désactivé'
                        }, status=status.HTTP_403_FORBIDDEN)
                    refresh = RefreshToken.for_user(user)
                    return Response({
                        'status': 'success',
                        'user': UserSerializer(user).data,
                        'refresh': str(refresh),
                        'access': str(refresh.access_token),
                    })
                return Response({
                    'status': 'error',
                    'message': 'Email ou mot de passe incorrect'
                }, status=status.HTTP_401_UNAUTHORIZED)
            return Response({
                'status': 'error',
                'message': 'Données invalides',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({
                'status': 'error',
                'message': 'Une erreur est survenue lors de la connexion',
                'errors': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            if not refresh_token:
                return Response({
                    'status': 'error',
                    'message': 'Le token de rafraîchissement est requis'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({
                'status': 'success',
                'message': 'Déconnexion réussie'
            }, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                'status': 'error',
                'message': 'Une erreur est survenue lors de la déconnexion',
                'errors': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)

class UserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            serializer = UserSerializer(request.user)
            return Response({
                'status': 'success',
                'data': serializer.data
            })
        except Exception as e:
            return Response({
                'status': 'error',
                'message': 'Une erreur est survenue lors de la récupération des données utilisateur',
                'errors': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR) 