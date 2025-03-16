from rest_framework import serializers
from django.apps import apps
from .models import FieldMetadata, Patient, D_ychet, Profosmotr, DeathData, Vaccination, Uchastki


class FieldMetadataSerializer(serializers.ModelSerializer):
    class Meta:
        model = FieldMetadata
        fields = '__all__'


class UchastkiSerializer(serializers.ModelSerializer):
    class Meta:
        model = Uchastki
        fields = ['id', 'name', 'code'] 


class PatientSerializer(serializers.ModelSerializer):
    uchastok_name = serializers.CharField(source='ychastok.name', read_only=True)
    uchastok_code = serializers.CharField(source='ychastok.code', read_only=True)
    class Meta:
        model = Patient
        fields = '__all__'


class D_ychetSerializer(serializers.ModelSerializer):
    class Meta:
        model = D_ychet
        fields = '__all__'


class ProfosmotrSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profosmotr
        fields = '__all__'


class DeathDataSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeathData
        fields = '__all__'


class VaccinationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vaccination
        fields = '__all__'

