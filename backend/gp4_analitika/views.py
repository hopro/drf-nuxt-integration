from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.filters import OrderingFilter
from django.apps import apps
from rest_framework import pagination, status, filters
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend

from .models import FieldMetadata, Patient, D_ychet, Profosmotr, DeathData, Vaccination, Uchastki
from .serializers import PatientSerializer, D_ychetSerializer, ProfosmotrSerializer, DeathDataSerializer, VaccinationSerializer, UchastkiSerializer
from .filters import PatientFilter, UchastkiFilter


def get_model_headers(model_name):
    model = apps.get_model('gp4_analitika', model_name)
    headers = []
    for field in model._meta.fields:
        headers.append({
            "title": field.verbose_name,
            "key": field.name
        })
    return headers


def get_table_metadata_new(model_name):
    metadata = []
    for field_meta in FieldMetadata.objects.filter(model_name=model_name).order_by('order'):
        item = {
            "key": field_meta.field_name,
            "title": field_meta.verbose_name,
            "type": field_meta.field_type,
            "required": field_meta.required,
            "choices": field_meta.choices,
            "related_model": field_meta.related_model
        }
        metadata.append(item)
    return metadata


def get_table_metadata(model_name, ordering_fields=[]):
    model = apps.get_model('gp4_analitika', model_name)
    metadata = []
    for field in model._meta.fields:
        field_info = {
            "title": field.verbose_name,
            "key": field.name,
            "type": field.get_internal_type(),
            "ordering_field": field.name in ordering_fields,  # Проверяем, доступно ли поле для сортировки
            "choices": None,  # По умолчанию choices отсутствует
            "related_model": None  # По умолчанию related_model отсутствует
        }

        # Если у поля есть choices, добавляем их в метаданные
        if hasattr(field, 'choices') and field.choices:
            field_info["choices"] = [
                {"value": choice[0], "label": choice[1]}  # Форматируем choices в удобный вид
                for choice in field.choices
            ]

        # Если поле является ForeignKey, добавляем информацию о связанной модели
        if field.get_internal_type() == 'ForeignKey':
            field_info["related_model"] = field.related_model.__name__  # Название связанной модели

        metadata.append(field_info)
    return metadata


class PatientPagination(pagination.PageNumberPagination):
    page_size = 10  # Количество элементов на странице
    page_size_query_param = 'page_size'  # Параметр для изменения количества элементов на странице
    max_page_size = 100  # Максимальное количество элементов на странице


class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all()
    serializer_class = PatientSerializer
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_class = PatientFilter
    pagination_class = PatientPagination
    ordering_fields = ['id', 
                       'name', 
                       'surname', 
                       'patronymic', 
                       'date_of_birth', 
                       'date_of_death', 
                       'age', 
                       'address', 
                       'phone', 
                       'snils', 
                       'MO_prikrepl', 
                       'lgota', 
                       'category', 
                       'ychastok',]

    def list(self, request, *args, **kwargs):
        response = super().list(request, *args, **kwargs)
        metadata = get_table_metadata('Patient', ['id', 'fio', 'date_of_birth', 'gender', 'address'])
        response.data['metadata'] = metadata
        return response

class D_ychetViewSet(viewsets.ModelViewSet):
    queryset = D_ychet.objects.all()
    serializer_class = D_ychetSerializer


class ProfosmotrViewSet(viewsets.ModelViewSet):
    queryset = Profosmotr.objects.all()
    serializer_class = ProfosmotrSerializer


class DeathDataViewSet(viewsets.ModelViewSet):
    queryset = DeathData.objects.all()
    serializer_class = DeathDataSerializer


class VaccinationViewSet(viewsets.ModelViewSet):
    queryset = Vaccination.objects.all()
    serializer_class = VaccinationSerializer


class UchastkiViewSet(viewsets.ModelViewSet):
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_class = UchastkiFilter
    queryset = Uchastki.objects.all()
    serializer_class = UchastkiSerializer
