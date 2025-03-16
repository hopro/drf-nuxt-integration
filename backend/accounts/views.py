from django.shortcuts import render
from django.contrib.auth.models import User
from django.core.mail import send_mail
from django.contrib.auth import get_user_model
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from rest_framework import generics, status, viewsets
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, JSONParser
from rest_framework_simplejwt.tokens import UntypedToken
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from rest_framework.views import APIView
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes
from rest_framework.permissions import IsAuthenticated

from .serializers import UserProfileSerializer, UserCreateSerializer, PasswordResetSerializer, PasswordResetConfirmSerializer
from .models import CustomUser

import logging
import sys
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    handlers=[logging.StreamHandler()])
logger = logging.getLogger(__name__)


class UserProfileView(generics.RetrieveUpdateDestroyAPIView):
    """
    Представление API для профиля пользователя.

    Это представление обрабатывает GET-запросы для получения профиля пользователя.
    Использует `UserProfileSerializer` для сериализации данных пользователя.
    Доступ к этому эндпоинту требует аутентификации.
    """
    permission_classes = [IsAuthenticated]
    queryset = CustomUser.objects.all()
    serializer_class = UserProfileSerializer
    parser_classes = [MultiPartParser, JSONParser] 

    def get_object(self):
        return self.request.user


class UserCreateView(generics.CreateAPIView):
    """
    Представление API для получения списка пользователей.

    Это представление обрабатывает GET-запросы для получения списка всех пользователей.
    Использует `UserSerializer` для сериализации данных пользователей.
    Доступ к этому эндпоинту не требует аутентификации или разрешений.
    """
    permission_classes = []
    queryset = CustomUser.objects.all()
    serializer_class = UserCreateSerializer


class PasswordResetView(generics.GenericAPIView):
    """
    Представление API для сброса пароля.

    Это представление обрабатывает POST-запросы для отправки ссылки для сброса пароля.
    Использует `PasswordResetSerializer` для валидации данных запроса.
    Доступ к этому эндпоинту не требует аутентификации или разрешений.
    """
    permission_classes = []
    serializer_class = PasswordResetSerializer
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Получаем валидированные данные
        validated_data = serializer.validated_data
        email = validated_data['email']
        
        # Получаем пользователя
        user = CustomUser.objects.get(email=email)
        
        # Генерируем токен и UID
        token = default_token_generator.make_token(user)
        uid = urlsafe_base64_encode(force_bytes(user.pk))
        api_url = '10.10.40.36:3001'
        reset_url = f'http://{api_url}/accounts/ConfirmResetPassword?uidb={uid}&token={token}'
        html_message = render_to_string('accounts/password_reset_email.html', {'reset_url': reset_url, 'username': user.username})
        plain_message = strip_tags(html_message)

        send_mail(
            'Сброс пароля',
            plain_message,
            'glinnik.it@yandex.ru',
            [user.email],
            fail_silently=False,
            html_message=html_message,
        )

        return Response({"message": "Ссылка для сброса пароля отправлена."}, status=status.HTTP_200_OK)


class PasswordResetConfirmView(generics.GenericAPIView):
    """
    Представление API для подтверждения сброса пароля.

    Это представление обрабатывает POST-запросы для подтверждения сброса пароля.
    Использует `PasswordResetConfirmSerializer` для валидации данных запроса.
    Доступ к этому эндпоинту не требует аутентификации или разрешений.
    """
    permission_classes = [] 
    serializer_class = PasswordResetConfirmSerializer
    def post(self, request, uidb64, token, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        new_password = request.data.get('new_password')
        try:
            uid = force_bytes(urlsafe_base64_decode(uidb64))
            user = CustomUser.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            user = None
            return Response({"error": "Некорректная ссылка для сброса пароля. Пользователь не найден."}, status=status.HTTP_400_BAD_REQUEST)

        if default_token_generator.check_token(user, token):
            user.set_password(new_password)
            user.save()
            return Response({"message": "Пароль успешно изменен." + new_password}, status=status.HTTP_200_OK)
        else:
            return Response({"error": "Некорректная ссылка для сброса пароля. Токен недействителен."}, status=status.HTTP_400_BAD_REQUEST)
        