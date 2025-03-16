from django.db import models
from datetime import datetime


class FieldMetadata(models.Model):
    MODEL_CHOICES = [
        ('Patient', 'Patient'),
        ('Uchastki', 'Uchastki'),
        # Добавьте другие модели по мере необходимости
    ]
    
    FIELD_TYPE_CHOICES = [
        ('text', 'Text'),
        ('number', 'Number'),
        ('date', 'Date'),
        ('select', 'Select'),
        ('foreign_key', 'Foreign Key'),
    ]

    model_name = models.CharField(max_length=100, choices=MODEL_CHOICES)
    field_name = models.CharField(max_length=100)
    verbose_name = models.CharField(max_length=100)
    field_type = models.CharField(max_length=20, choices=FIELD_TYPE_CHOICES)
    required = models.BooleanField(default=True)
    order = models.IntegerField(default=0)
    choices = models.JSONField(null=True, blank=True)
    related_model = models.CharField(max_length=100, null=True, blank=True)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"{self.model_name}.{self.field_name}"


class Uchastki(models.Model):
    name = models.CharField(max_length=100, verbose_name='Название участка')
    code = models.CharField(max_length=100, verbose_name='Код участка')
    create_date = models.DateField(auto_now_add=True, blank=True, verbose_name='Дата создания')
    update_date = models.DateField(auto_now=True, blank=True, null=True, verbose_name='Дата изменения')

    def __str__(self):
        return (f'{self.id} - {self.name}')


class Patient(models.Model):
    class Category(models.TextChoices):
        PENSIONER = 'Пенсионер', 'Пенсионер'
        WORKING = 'Работающий', 'Работающий'
        STUDENT = 'Студент', 'Студент'
        SCHOOLCHILD = 'Школьник', 'Школьник'
        INVALID = 'Инвалид', 'Инвалид'
        ALL = 'Все записи', ''

    name = models.CharField(max_length=100, verbose_name='Имя')
    surname = models.CharField(max_length=100, verbose_name='Фамилия')
    patronymic = models.CharField(max_length=100, verbose_name='Отчество', null=True, blank=True)
    date_of_birth = models.DateField(verbose_name='Дата рождения')
    date_of_death = models.DateField(verbose_name='Дата смерти', null=True, blank=True)
    age = models.IntegerField(verbose_name='Возраст')
    address = models.CharField(max_length=100, verbose_name='Адрес', null=True, blank=True)
    phone = models.CharField(max_length=100, verbose_name='Телефон', null=True, blank=True)
    snils = models.CharField(max_length=100, verbose_name='СНИЛС', null=True, blank=True)
    ychastok = models.ForeignKey(Uchastki, on_delete=models.CASCADE, verbose_name='Участок', null=True, blank=True)
    MO_prikrepl = models.CharField(max_length=100, verbose_name='МО прикрепления', null=True, blank=True)
    lgota = models.CharField(max_length=100, verbose_name='Льгота', null=True, blank=True)
    category = models.CharField(
        null=True,
        blank=True,
        max_length=100,
        choices=Category.choices,
        verbose_name='Категория'
    )                                

    def __str__(self):
        return self.name + ' ' + self.surname + ' ' + self.patronymic + ' ' + self.date_of_birth.strftime('%Y-%m-%d')
    

class D_ychet(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    start_date = models.DateField()
    end_date = models.DateField()
    diagnosis = models.CharField(max_length=100)
    last_visit = models.DateField()

    def __str__(self):
        return self.patient + ' ' + self.start_date + ' ' + self.end_date + ' ' + self.diagnosis + ' ' + self.last_visit


class Profosmotr(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    start_date = models.DateField()
    end_date = models.DateField()
    diagnosis = models.CharField(max_length=100)
    gr_zd = models.CharField(max_length=100)

    def __str__(self):
        return self.patient + ' ' + self.start_date + ' ' + self.end_date + ' ' + self.diagnosis + ' ' + self.gr_zd


class DeathData(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    place_of_death = models.CharField(max_length=100)
    LPU_death = models.CharField(max_length=100)
    department_death = models.CharField(max_length=100)
    start_date = models.DateField()
    end_date = models.DateField()
    diagnosis = models.CharField(max_length=100)
    death_cause = models.CharField(max_length=100)
    SMP_date = models.DateField()
    SMP_diagnosis = models.CharField(max_length=100)
    death_certificate = models.CharField(max_length=100)
    death_certificate_date = models.DateField()

    def __str__(self):
        return self.patient + ' ' + self.place_of_death + ' ' + self.LPU_death + ' ' + self.department_death + ' ' + self.start_date + ' ' + self.end_date + ' ' + self.diagnosis + ' ' + self.death_cause + ' ' + self.SMP_date + ' ' + self.SMP_diagnosis + ' ' + self.death_certificate + ' ' + self.death_certificate_date


class Vaccination(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    date = models.DateField()
    vaccine = models.CharField(max_length=100)

    def __str__(self):
        return self.patient + ' ' + self.date + ' ' + self.vaccine
