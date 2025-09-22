// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environmental_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EnvironmentalDataImpl _$$EnvironmentalDataImplFromJson(
        Map<String, dynamic> json) =>
    _$EnvironmentalDataImpl(
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      climateData:
          ClimateData.fromJson(json['climateData'] as Map<String, dynamic>),
      daylightPatterns: DaylightPatterns.fromJson(
          json['daylightPatterns'] as Map<String, dynamic>),
      weatherForecast: WeatherForecast.fromJson(
          json['weatherForecast'] as Map<String, dynamic>),
      pestRiskData: json['pestRiskData'] == null
          ? null
          : PestRiskData.fromJson(json['pestRiskData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$EnvironmentalDataImplToJson(
        _$EnvironmentalDataImpl instance) =>
    <String, dynamic>{
      'location': instance.location,
      'climateData': instance.climateData,
      'daylightPatterns': instance.daylightPatterns,
      'weatherForecast': instance.weatherForecast,
      'pestRiskData': instance.pestRiskData,
    };

_$LocationImpl _$$LocationImplFromJson(Map<String, dynamic> json) =>
    _$LocationImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$$LocationImplToJson(_$LocationImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'city': instance.city,
      'region': instance.region,
      'country': instance.country,
      'timezone': instance.timezone,
    };

_$ClimateDataImpl _$$ClimateDataImplFromJson(Map<String, dynamic> json) =>
    _$ClimateDataImpl(
      temperatureHistory: (json['temperatureHistory'] as List<dynamic>)
          .map((e) => TemperatureData.fromJson(e as Map<String, dynamic>))
          .toList(),
      precipitationHistory: (json['precipitationHistory'] as List<dynamic>)
          .map((e) => PrecipitationData.fromJson(e as Map<String, dynamic>))
          .toList(),
      humidityHistory: (json['humidityHistory'] as List<dynamic>)
          .map((e) => HumidityData.fromJson(e as Map<String, dynamic>))
          .toList(),
      climateZone: json['climateZone'] as String,
    );

Map<String, dynamic> _$$ClimateDataImplToJson(_$ClimateDataImpl instance) =>
    <String, dynamic>{
      'temperatureHistory': instance.temperatureHistory,
      'precipitationHistory': instance.precipitationHistory,
      'humidityHistory': instance.humidityHistory,
      'climateZone': instance.climateZone,
    };

_$TemperatureDataImpl _$$TemperatureDataImplFromJson(
        Map<String, dynamic> json) =>
    _$TemperatureDataImpl(
      date: DateTime.parse(json['date'] as String),
      averageTemp: (json['averageTemp'] as num).toDouble(),
      minTemp: (json['minTemp'] as num).toDouble(),
      maxTemp: (json['maxTemp'] as num).toDouble(),
    );

Map<String, dynamic> _$$TemperatureDataImplToJson(
        _$TemperatureDataImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'averageTemp': instance.averageTemp,
      'minTemp': instance.minTemp,
      'maxTemp': instance.maxTemp,
    };

_$PrecipitationDataImpl _$$PrecipitationDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PrecipitationDataImpl(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
    );

Map<String, dynamic> _$$PrecipitationDataImplToJson(
        _$PrecipitationDataImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'type': instance.type,
    };

_$HumidityDataImpl _$$HumidityDataImplFromJson(Map<String, dynamic> json) =>
    _$HumidityDataImpl(
      date: DateTime.parse(json['date'] as String),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$$HumidityDataImplToJson(_$HumidityDataImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'percentage': instance.percentage,
    };

_$DaylightPatternsImpl _$$DaylightPatternsImplFromJson(
        Map<String, dynamic> json) =>
    _$DaylightPatternsImpl(
      yearlyPattern: (json['yearlyPattern'] as List<dynamic>)
          .map((e) => DaylightData.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$DaylightPatternsImplToJson(
        _$DaylightPatternsImpl instance) =>
    <String, dynamic>{
      'yearlyPattern': instance.yearlyPattern,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

_$DaylightDataImpl _$$DaylightDataImplFromJson(Map<String, dynamic> json) =>
    _$DaylightDataImpl(
      date: DateTime.parse(json['date'] as String),
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
      daylightHours: (json['daylightHours'] as num).toDouble(),
    );

Map<String, dynamic> _$$DaylightDataImplToJson(_$DaylightDataImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'sunrise': instance.sunrise.toIso8601String(),
      'sunset': instance.sunset.toIso8601String(),
      'daylightHours': instance.daylightHours,
    };

_$WeatherForecastImpl _$$WeatherForecastImplFromJson(
        Map<String, dynamic> json) =>
    _$WeatherForecastImpl(
      dailyForecasts: (json['dailyForecasts'] as List<dynamic>)
          .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$WeatherForecastImplToJson(
        _$WeatherForecastImpl instance) =>
    <String, dynamic>{
      'dailyForecasts': instance.dailyForecasts,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

_$DailyForecastImpl _$$DailyForecastImplFromJson(Map<String, dynamic> json) =>
    _$DailyForecastImpl(
      date: DateTime.parse(json['date'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      conditions: json['conditions'] as String,
    );

Map<String, dynamic> _$$DailyForecastImplToJson(_$DailyForecastImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'precipitation': instance.precipitation,
      'conditions': instance.conditions,
    };

_$PestRiskDataImpl _$$PestRiskDataImplFromJson(Map<String, dynamic> json) =>
    _$PestRiskDataImpl(
      risks: (json['risks'] as List<dynamic>)
          .map((e) => PestRisk.fromJson(e as Map<String, dynamic>))
          .toList(),
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
    );

Map<String, dynamic> _$$PestRiskDataImplToJson(_$PestRiskDataImpl instance) =>
    <String, dynamic>{
      'risks': instance.risks,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
    };

_$PestRiskImpl _$$PestRiskImplFromJson(Map<String, dynamic> json) =>
    _$PestRiskImpl(
      pestType: json['pestType'] as String,
      riskLevel: (json['riskLevel'] as num).toDouble(),
      description: json['description'] as String,
      preventionMethods: (json['preventionMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$PestRiskImplToJson(_$PestRiskImpl instance) =>
    <String, dynamic>{
      'pestType': instance.pestType,
      'riskLevel': instance.riskLevel,
      'description': instance.description,
      'preventionMethods': instance.preventionMethods,
    };
