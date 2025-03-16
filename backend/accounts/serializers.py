from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError as DjangoValidationError

import re
from django.contrib.auth.models import User
from .models import CustomUser

User = get_user_model()


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ('username', 'email', 'bith_date', 'mobile_phone', 'avatar', 'address', 'comment')
        extra_kwargs = {'password': {'write_only': True}, 'password_confirm': {'write_only': True}}


class UserCreateSerializer(serializers.ModelSerializer):
    password_confirm = serializers.CharField(write_only=True, required=True, label='Пароль еще раз')
    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'password_confirm')
        extra_kwargs = {'password': {'write_only': True}, 'password_confirm': {'write_only': True}}

    def validate(self, attrs):
        if User.objects.filter(email=attrs['email']).exists():
            raise serializers.ValidationError({'email': 'Пользователь с таким email уже зарегистрирован'})
        
        if attrs['password'] != attrs['password_confirm']:
                        raise serializers.ValidationError({
                'password': 'Пароли не совпадают.',
                'password_confirm': 'Пароли не совпадают.'
            })
        return attrs
    
    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        return user

    def validate_password(self, value):        
        # if not re.fullmatch(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$", value):
        #     raise serializers.ValidationError('Пароль должен содержать строчные и прописные буквы, цифры и спецсимволы ' + value)
        try:
            validate_password(value)
        except DjangoValidationError as e:
            raise serializers.ValidationError(e.messages)

        return value
    

class PasswordResetSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)

    def validate_email(self, value):
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError('Пользователь с таким email не зарегистрирован')
        return value
    

class PasswordResetConfirmSerializer(serializers.Serializer):
    new_password = serializers.CharField(required=True, label='Новый пароль')
    new_confirm_password = serializers.CharField(required=True, label='Повторите новый пароль')

    def validate_new_password(self, value):
        if value != self.initial_data['new_confirm_password']:
            raise serializers.ValidationError('Пароли не совпадают')
        try:
            validate_password(value)
        except DjangoValidationError as e:
            raise serializers.ValidationError(e.messages)
        return value
