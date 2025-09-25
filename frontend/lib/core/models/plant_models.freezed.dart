// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plant_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Plant _$PlantFromJson(Map<String, dynamic> json) {
  return _Plant.fromJson(json);
}

/// @nodoc
mixin _$Plant {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get scientificName => throw _privateConstructorUsedError;
  String? get commonName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String>? get careInstructions => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Plant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantCopyWith<Plant> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantCopyWith<$Res> {
  factory $PlantCopyWith(Plant value, $Res Function(Plant) then) =
      _$PlantCopyWithImpl<$Res, Plant>;
  @useResult
  $Res call(
      {String id,
      String name,
      String scientificName,
      String? commonName,
      String? description,
      String? imageUrl,
      List<String>? careInstructions,
      Map<String, dynamic>? metadata,
      bool isFavorite,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PlantCopyWithImpl<$Res, $Val extends Plant>
    implements $PlantCopyWith<$Res> {
  _$PlantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? scientificName = null,
    Object? commonName = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? careInstructions = freezed,
    Object? metadata = freezed,
    Object? isFavorite = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      scientificName: null == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: freezed == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      careInstructions: freezed == careInstructions
          ? _value.careInstructions
          : careInstructions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantImplCopyWith<$Res> implements $PlantCopyWith<$Res> {
  factory _$$PlantImplCopyWith(
          _$PlantImpl value, $Res Function(_$PlantImpl) then) =
      __$$PlantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String scientificName,
      String? commonName,
      String? description,
      String? imageUrl,
      List<String>? careInstructions,
      Map<String, dynamic>? metadata,
      bool isFavorite,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PlantImplCopyWithImpl<$Res>
    extends _$PlantCopyWithImpl<$Res, _$PlantImpl>
    implements _$$PlantImplCopyWith<$Res> {
  __$$PlantImplCopyWithImpl(
      _$PlantImpl _value, $Res Function(_$PlantImpl) _then)
      : super(_value, _then);

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? scientificName = null,
    Object? commonName = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? careInstructions = freezed,
    Object? metadata = freezed,
    Object? isFavorite = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PlantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      scientificName: null == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: freezed == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      careInstructions: freezed == careInstructions
          ? _value._careInstructions
          : careInstructions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantImpl implements _Plant {
  const _$PlantImpl(
      {required this.id,
      required this.name,
      required this.scientificName,
      this.commonName,
      this.description,
      this.imageUrl,
      final List<String>? careInstructions,
      final Map<String, dynamic>? metadata,
      this.isFavorite = false,
      this.createdAt,
      this.updatedAt})
      : _careInstructions = careInstructions,
        _metadata = metadata;

  factory _$PlantImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String scientificName;
  @override
  final String? commonName;
  @override
  final String? description;
  @override
  final String? imageUrl;
  final List<String>? _careInstructions;
  @override
  List<String>? get careInstructions {
    final value = _careInstructions;
    if (value == null) return null;
    if (_careInstructions is EqualUnmodifiableListView)
      return _careInstructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Plant(id: $id, name: $name, scientificName: $scientificName, commonName: $commonName, description: $description, imageUrl: $imageUrl, careInstructions: $careInstructions, metadata: $metadata, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.scientificName, scientificName) ||
                other.scientificName == scientificName) &&
            (identical(other.commonName, commonName) ||
                other.commonName == commonName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._careInstructions, _careInstructions) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      scientificName,
      commonName,
      description,
      imageUrl,
      const DeepCollectionEquality().hash(_careInstructions),
      const DeepCollectionEquality().hash(_metadata),
      isFavorite,
      createdAt,
      updatedAt);

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantImplCopyWith<_$PlantImpl> get copyWith =>
      __$$PlantImplCopyWithImpl<_$PlantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantImplToJson(
      this,
    );
  }
}

abstract class _Plant implements Plant {
  const factory _Plant(
      {required final String id,
      required final String name,
      required final String scientificName,
      final String? commonName,
      final String? description,
      final String? imageUrl,
      final List<String>? careInstructions,
      final Map<String, dynamic>? metadata,
      final bool isFavorite,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$PlantImpl;

  factory _Plant.fromJson(Map<String, dynamic> json) = _$PlantImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get scientificName;
  @override
  String? get commonName;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  List<String>? get careInstructions;
  @override
  Map<String, dynamic>? get metadata;
  @override
  bool get isFavorite;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Plant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantImplCopyWith<_$PlantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlantSpecies _$PlantSpeciesFromJson(Map<String, dynamic> json) {
  return _PlantSpecies.fromJson(json);
}

/// @nodoc
mixin _$PlantSpecies {
  String get id => throw _privateConstructorUsedError;
  String get scientificName => throw _privateConstructorUsedError;
  String get commonName => throw _privateConstructorUsedError;
  String? get family => throw _privateConstructorUsedError;
  String? get genus => throw _privateConstructorUsedError;
  String? get species => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;
  Map<String, dynamic>? get careRequirements =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get characteristics =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlantSpecies to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlantSpecies
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantSpeciesCopyWith<PlantSpecies> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantSpeciesCopyWith<$Res> {
  factory $PlantSpeciesCopyWith(
          PlantSpecies value, $Res Function(PlantSpecies) then) =
      _$PlantSpeciesCopyWithImpl<$Res, PlantSpecies>;
  @useResult
  $Res call(
      {String id,
      String scientificName,
      String commonName,
      String? family,
      String? genus,
      String? species,
      String? description,
      List<String>? images,
      Map<String, dynamic>? careRequirements,
      Map<String, dynamic>? characteristics,
      DateTime? createdAt});
}

/// @nodoc
class _$PlantSpeciesCopyWithImpl<$Res, $Val extends PlantSpecies>
    implements $PlantSpeciesCopyWith<$Res> {
  _$PlantSpeciesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantSpecies
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scientificName = null,
    Object? commonName = null,
    Object? family = freezed,
    Object? genus = freezed,
    Object? species = freezed,
    Object? description = freezed,
    Object? images = freezed,
    Object? careRequirements = freezed,
    Object? characteristics = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      scientificName: null == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: null == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String,
      family: freezed == family
          ? _value.family
          : family // ignore: cast_nullable_to_non_nullable
              as String?,
      genus: freezed == genus
          ? _value.genus
          : genus // ignore: cast_nullable_to_non_nullable
              as String?,
      species: freezed == species
          ? _value.species
          : species // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      careRequirements: freezed == careRequirements
          ? _value.careRequirements
          : careRequirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      characteristics: freezed == characteristics
          ? _value.characteristics
          : characteristics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantSpeciesImplCopyWith<$Res>
    implements $PlantSpeciesCopyWith<$Res> {
  factory _$$PlantSpeciesImplCopyWith(
          _$PlantSpeciesImpl value, $Res Function(_$PlantSpeciesImpl) then) =
      __$$PlantSpeciesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String scientificName,
      String commonName,
      String? family,
      String? genus,
      String? species,
      String? description,
      List<String>? images,
      Map<String, dynamic>? careRequirements,
      Map<String, dynamic>? characteristics,
      DateTime? createdAt});
}

/// @nodoc
class __$$PlantSpeciesImplCopyWithImpl<$Res>
    extends _$PlantSpeciesCopyWithImpl<$Res, _$PlantSpeciesImpl>
    implements _$$PlantSpeciesImplCopyWith<$Res> {
  __$$PlantSpeciesImplCopyWithImpl(
      _$PlantSpeciesImpl _value, $Res Function(_$PlantSpeciesImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantSpecies
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scientificName = null,
    Object? commonName = null,
    Object? family = freezed,
    Object? genus = freezed,
    Object? species = freezed,
    Object? description = freezed,
    Object? images = freezed,
    Object? careRequirements = freezed,
    Object? characteristics = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$PlantSpeciesImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      scientificName: null == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: null == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String,
      family: freezed == family
          ? _value.family
          : family // ignore: cast_nullable_to_non_nullable
              as String?,
      genus: freezed == genus
          ? _value.genus
          : genus // ignore: cast_nullable_to_non_nullable
              as String?,
      species: freezed == species
          ? _value.species
          : species // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      careRequirements: freezed == careRequirements
          ? _value._careRequirements
          : careRequirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      characteristics: freezed == characteristics
          ? _value._characteristics
          : characteristics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantSpeciesImpl implements _PlantSpecies {
  const _$PlantSpeciesImpl(
      {required this.id,
      required this.scientificName,
      required this.commonName,
      this.family,
      this.genus,
      this.species,
      this.description,
      final List<String>? images,
      final Map<String, dynamic>? careRequirements,
      final Map<String, dynamic>? characteristics,
      this.createdAt})
      : _images = images,
        _careRequirements = careRequirements,
        _characteristics = characteristics;

  factory _$PlantSpeciesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantSpeciesImplFromJson(json);

  @override
  final String id;
  @override
  final String scientificName;
  @override
  final String commonName;
  @override
  final String? family;
  @override
  final String? genus;
  @override
  final String? species;
  @override
  final String? description;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _careRequirements;
  @override
  Map<String, dynamic>? get careRequirements {
    final value = _careRequirements;
    if (value == null) return null;
    if (_careRequirements is EqualUnmodifiableMapView) return _careRequirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _characteristics;
  @override
  Map<String, dynamic>? get characteristics {
    final value = _characteristics;
    if (value == null) return null;
    if (_characteristics is EqualUnmodifiableMapView) return _characteristics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PlantSpecies(id: $id, scientificName: $scientificName, commonName: $commonName, family: $family, genus: $genus, species: $species, description: $description, images: $images, careRequirements: $careRequirements, characteristics: $characteristics, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantSpeciesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scientificName, scientificName) ||
                other.scientificName == scientificName) &&
            (identical(other.commonName, commonName) ||
                other.commonName == commonName) &&
            (identical(other.family, family) || other.family == family) &&
            (identical(other.genus, genus) || other.genus == genus) &&
            (identical(other.species, species) || other.species == species) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality()
                .equals(other._careRequirements, _careRequirements) &&
            const DeepCollectionEquality()
                .equals(other._characteristics, _characteristics) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      scientificName,
      commonName,
      family,
      genus,
      species,
      description,
      const DeepCollectionEquality().hash(_images),
      const DeepCollectionEquality().hash(_careRequirements),
      const DeepCollectionEquality().hash(_characteristics),
      createdAt);

  /// Create a copy of PlantSpecies
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantSpeciesImplCopyWith<_$PlantSpeciesImpl> get copyWith =>
      __$$PlantSpeciesImplCopyWithImpl<_$PlantSpeciesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantSpeciesImplToJson(
      this,
    );
  }
}

abstract class _PlantSpecies implements PlantSpecies {
  const factory _PlantSpecies(
      {required final String id,
      required final String scientificName,
      required final String commonName,
      final String? family,
      final String? genus,
      final String? species,
      final String? description,
      final List<String>? images,
      final Map<String, dynamic>? careRequirements,
      final Map<String, dynamic>? characteristics,
      final DateTime? createdAt}) = _$PlantSpeciesImpl;

  factory _PlantSpecies.fromJson(Map<String, dynamic> json) =
      _$PlantSpeciesImpl.fromJson;

  @override
  String get id;
  @override
  String get scientificName;
  @override
  String get commonName;
  @override
  String? get family;
  @override
  String? get genus;
  @override
  String? get species;
  @override
  String? get description;
  @override
  List<String>? get images;
  @override
  Map<String, dynamic>? get careRequirements;
  @override
  Map<String, dynamic>? get characteristics;
  @override
  DateTime? get createdAt;

  /// Create a copy of PlantSpecies
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantSpeciesImplCopyWith<_$PlantSpeciesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlantIdentificationResult _$PlantIdentificationResultFromJson(
    Map<String, dynamic> json) {
  return _PlantIdentificationResult.fromJson(json);
}

/// @nodoc
mixin _$PlantIdentificationResult {
  String get id => throw _privateConstructorUsedError;
  String get plantId => throw _privateConstructorUsedError;
  String get scientificName => throw _privateConstructorUsedError;
  String get commonName => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get additionalInfo =>
      throw _privateConstructorUsedError;
  DateTime? get identifiedAt => throw _privateConstructorUsedError;

  /// Serializes this PlantIdentificationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlantIdentificationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantIdentificationResultCopyWith<PlantIdentificationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantIdentificationResultCopyWith<$Res> {
  factory $PlantIdentificationResultCopyWith(PlantIdentificationResult value,
          $Res Function(PlantIdentificationResult) then) =
      _$PlantIdentificationResultCopyWithImpl<$Res, PlantIdentificationResult>;
  @useResult
  $Res call(
      {String id,
      String plantId,
      String scientificName,
      String commonName,
      double confidence,
      String? imageUrl,
      Map<String, dynamic>? additionalInfo,
      DateTime? identifiedAt});
}

/// @nodoc
class _$PlantIdentificationResultCopyWithImpl<$Res,
        $Val extends PlantIdentificationResult>
    implements $PlantIdentificationResultCopyWith<$Res> {
  _$PlantIdentificationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantIdentificationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? scientificName = null,
    Object? commonName = null,
    Object? confidence = null,
    Object? imageUrl = freezed,
    Object? additionalInfo = freezed,
    Object? identifiedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      scientificName: null == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: null == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalInfo: freezed == additionalInfo
          ? _value.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      identifiedAt: freezed == identifiedAt
          ? _value.identifiedAt
          : identifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantIdentificationResultImplCopyWith<$Res>
    implements $PlantIdentificationResultCopyWith<$Res> {
  factory _$$PlantIdentificationResultImplCopyWith(
          _$PlantIdentificationResultImpl value,
          $Res Function(_$PlantIdentificationResultImpl) then) =
      __$$PlantIdentificationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String plantId,
      String scientificName,
      String commonName,
      double confidence,
      String? imageUrl,
      Map<String, dynamic>? additionalInfo,
      DateTime? identifiedAt});
}

/// @nodoc
class __$$PlantIdentificationResultImplCopyWithImpl<$Res>
    extends _$PlantIdentificationResultCopyWithImpl<$Res,
        _$PlantIdentificationResultImpl>
    implements _$$PlantIdentificationResultImplCopyWith<$Res> {
  __$$PlantIdentificationResultImplCopyWithImpl(
      _$PlantIdentificationResultImpl _value,
      $Res Function(_$PlantIdentificationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantIdentificationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? scientificName = null,
    Object? commonName = null,
    Object? confidence = null,
    Object? imageUrl = freezed,
    Object? additionalInfo = freezed,
    Object? identifiedAt = freezed,
  }) {
    return _then(_$PlantIdentificationResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      scientificName: null == scientificName
          ? _value.scientificName
          : scientificName // ignore: cast_nullable_to_non_nullable
              as String,
      commonName: null == commonName
          ? _value.commonName
          : commonName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalInfo: freezed == additionalInfo
          ? _value._additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      identifiedAt: freezed == identifiedAt
          ? _value.identifiedAt
          : identifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantIdentificationResultImpl implements _PlantIdentificationResult {
  const _$PlantIdentificationResultImpl(
      {required this.id,
      required this.plantId,
      required this.scientificName,
      required this.commonName,
      required this.confidence,
      this.imageUrl,
      final Map<String, dynamic>? additionalInfo,
      this.identifiedAt})
      : _additionalInfo = additionalInfo;

  factory _$PlantIdentificationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantIdentificationResultImplFromJson(json);

  @override
  final String id;
  @override
  final String plantId;
  @override
  final String scientificName;
  @override
  final String commonName;
  @override
  final double confidence;
  @override
  final String? imageUrl;
  final Map<String, dynamic>? _additionalInfo;
  @override
  Map<String, dynamic>? get additionalInfo {
    final value = _additionalInfo;
    if (value == null) return null;
    if (_additionalInfo is EqualUnmodifiableMapView) return _additionalInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? identifiedAt;

  @override
  String toString() {
    return 'PlantIdentificationResult(id: $id, plantId: $plantId, scientificName: $scientificName, commonName: $commonName, confidence: $confidence, imageUrl: $imageUrl, additionalInfo: $additionalInfo, identifiedAt: $identifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantIdentificationResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.scientificName, scientificName) ||
                other.scientificName == scientificName) &&
            (identical(other.commonName, commonName) ||
                other.commonName == commonName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._additionalInfo, _additionalInfo) &&
            (identical(other.identifiedAt, identifiedAt) ||
                other.identifiedAt == identifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      plantId,
      scientificName,
      commonName,
      confidence,
      imageUrl,
      const DeepCollectionEquality().hash(_additionalInfo),
      identifiedAt);

  /// Create a copy of PlantIdentificationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantIdentificationResultImplCopyWith<_$PlantIdentificationResultImpl>
      get copyWith => __$$PlantIdentificationResultImplCopyWithImpl<
          _$PlantIdentificationResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantIdentificationResultImplToJson(
      this,
    );
  }
}

abstract class _PlantIdentificationResult implements PlantIdentificationResult {
  const factory _PlantIdentificationResult(
      {required final String id,
      required final String plantId,
      required final String scientificName,
      required final String commonName,
      required final double confidence,
      final String? imageUrl,
      final Map<String, dynamic>? additionalInfo,
      final DateTime? identifiedAt}) = _$PlantIdentificationResultImpl;

  factory _PlantIdentificationResult.fromJson(Map<String, dynamic> json) =
      _$PlantIdentificationResultImpl.fromJson;

  @override
  String get id;
  @override
  String get plantId;
  @override
  String get scientificName;
  @override
  String get commonName;
  @override
  double get confidence;
  @override
  String? get imageUrl;
  @override
  Map<String, dynamic>? get additionalInfo;
  @override
  DateTime? get identifiedAt;

  /// Create a copy of PlantIdentificationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantIdentificationResultImplCopyWith<_$PlantIdentificationResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PlantCareEntry _$PlantCareEntryFromJson(Map<String, dynamic> json) {
  return _PlantCareEntry.fromJson(json);
}

/// @nodoc
mixin _$PlantCareEntry {
  String get id => throw _privateConstructorUsedError;
  String get plantId => throw _privateConstructorUsedError;
  String get careType => throw _privateConstructorUsedError;
  DateTime get careDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlantCareEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlantCareEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantCareEntryCopyWith<PlantCareEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantCareEntryCopyWith<$Res> {
  factory $PlantCareEntryCopyWith(
          PlantCareEntry value, $Res Function(PlantCareEntry) then) =
      _$PlantCareEntryCopyWithImpl<$Res, PlantCareEntry>;
  @useResult
  $Res call(
      {String id,
      String plantId,
      String careType,
      DateTime careDate,
      String? notes,
      String? imageUrl,
      Map<String, dynamic>? metadata,
      DateTime? createdAt});
}

/// @nodoc
class _$PlantCareEntryCopyWithImpl<$Res, $Val extends PlantCareEntry>
    implements $PlantCareEntryCopyWith<$Res> {
  _$PlantCareEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantCareEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? careType = null,
    Object? careDate = null,
    Object? notes = freezed,
    Object? imageUrl = freezed,
    Object? metadata = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      careType: null == careType
          ? _value.careType
          : careType // ignore: cast_nullable_to_non_nullable
              as String,
      careDate: null == careDate
          ? _value.careDate
          : careDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantCareEntryImplCopyWith<$Res>
    implements $PlantCareEntryCopyWith<$Res> {
  factory _$$PlantCareEntryImplCopyWith(_$PlantCareEntryImpl value,
          $Res Function(_$PlantCareEntryImpl) then) =
      __$$PlantCareEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String plantId,
      String careType,
      DateTime careDate,
      String? notes,
      String? imageUrl,
      Map<String, dynamic>? metadata,
      DateTime? createdAt});
}

/// @nodoc
class __$$PlantCareEntryImplCopyWithImpl<$Res>
    extends _$PlantCareEntryCopyWithImpl<$Res, _$PlantCareEntryImpl>
    implements _$$PlantCareEntryImplCopyWith<$Res> {
  __$$PlantCareEntryImplCopyWithImpl(
      _$PlantCareEntryImpl _value, $Res Function(_$PlantCareEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantCareEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? careType = null,
    Object? careDate = null,
    Object? notes = freezed,
    Object? imageUrl = freezed,
    Object? metadata = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$PlantCareEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      careType: null == careType
          ? _value.careType
          : careType // ignore: cast_nullable_to_non_nullable
              as String,
      careDate: null == careDate
          ? _value.careDate
          : careDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantCareEntryImpl implements _PlantCareEntry {
  const _$PlantCareEntryImpl(
      {required this.id,
      required this.plantId,
      required this.careType,
      required this.careDate,
      this.notes,
      this.imageUrl,
      final Map<String, dynamic>? metadata,
      this.createdAt})
      : _metadata = metadata;

  factory _$PlantCareEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantCareEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String plantId;
  @override
  final String careType;
  @override
  final DateTime careDate;
  @override
  final String? notes;
  @override
  final String? imageUrl;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PlantCareEntry(id: $id, plantId: $plantId, careType: $careType, careDate: $careDate, notes: $notes, imageUrl: $imageUrl, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantCareEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.careType, careType) ||
                other.careType == careType) &&
            (identical(other.careDate, careDate) ||
                other.careDate == careDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      plantId,
      careType,
      careDate,
      notes,
      imageUrl,
      const DeepCollectionEquality().hash(_metadata),
      createdAt);

  /// Create a copy of PlantCareEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantCareEntryImplCopyWith<_$PlantCareEntryImpl> get copyWith =>
      __$$PlantCareEntryImplCopyWithImpl<_$PlantCareEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantCareEntryImplToJson(
      this,
    );
  }
}

abstract class _PlantCareEntry implements PlantCareEntry {
  const factory _PlantCareEntry(
      {required final String id,
      required final String plantId,
      required final String careType,
      required final DateTime careDate,
      final String? notes,
      final String? imageUrl,
      final Map<String, dynamic>? metadata,
      final DateTime? createdAt}) = _$PlantCareEntryImpl;

  factory _PlantCareEntry.fromJson(Map<String, dynamic> json) =
      _$PlantCareEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get plantId;
  @override
  String get careType;
  @override
  DateTime get careDate;
  @override
  String? get notes;
  @override
  String? get imageUrl;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime? get createdAt;

  /// Create a copy of PlantCareEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantCareEntryImplCopyWith<_$PlantCareEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlantCareReminder _$PlantCareReminderFromJson(Map<String, dynamic> json) {
  return _PlantCareReminder.fromJson(json);
}

/// @nodoc
mixin _$PlantCareReminder {
  String get id => throw _privateConstructorUsedError;
  String get plantId => throw _privateConstructorUsedError;
  String get careType => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  bool get isOverdue => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlantCareReminder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlantCareReminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlantCareReminderCopyWith<PlantCareReminder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlantCareReminderCopyWith<$Res> {
  factory $PlantCareReminderCopyWith(
          PlantCareReminder value, $Res Function(PlantCareReminder) then) =
      _$PlantCareReminderCopyWithImpl<$Res, PlantCareReminder>;
  @useResult
  $Res call(
      {String id,
      String plantId,
      String careType,
      DateTime dueDate,
      String? description,
      bool isCompleted,
      bool isOverdue,
      DateTime? completedAt,
      DateTime? createdAt});
}

/// @nodoc
class _$PlantCareReminderCopyWithImpl<$Res, $Val extends PlantCareReminder>
    implements $PlantCareReminderCopyWith<$Res> {
  _$PlantCareReminderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlantCareReminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? careType = null,
    Object? dueDate = null,
    Object? description = freezed,
    Object? isCompleted = null,
    Object? isOverdue = null,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      careType: null == careType
          ? _value.careType
          : careType // ignore: cast_nullable_to_non_nullable
              as String,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isOverdue: null == isOverdue
          ? _value.isOverdue
          : isOverdue // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlantCareReminderImplCopyWith<$Res>
    implements $PlantCareReminderCopyWith<$Res> {
  factory _$$PlantCareReminderImplCopyWith(_$PlantCareReminderImpl value,
          $Res Function(_$PlantCareReminderImpl) then) =
      __$$PlantCareReminderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String plantId,
      String careType,
      DateTime dueDate,
      String? description,
      bool isCompleted,
      bool isOverdue,
      DateTime? completedAt,
      DateTime? createdAt});
}

/// @nodoc
class __$$PlantCareReminderImplCopyWithImpl<$Res>
    extends _$PlantCareReminderCopyWithImpl<$Res, _$PlantCareReminderImpl>
    implements _$$PlantCareReminderImplCopyWith<$Res> {
  __$$PlantCareReminderImplCopyWithImpl(_$PlantCareReminderImpl _value,
      $Res Function(_$PlantCareReminderImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlantCareReminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plantId = null,
    Object? careType = null,
    Object? dueDate = null,
    Object? description = freezed,
    Object? isCompleted = null,
    Object? isOverdue = null,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$PlantCareReminderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      plantId: null == plantId
          ? _value.plantId
          : plantId // ignore: cast_nullable_to_non_nullable
              as String,
      careType: null == careType
          ? _value.careType
          : careType // ignore: cast_nullable_to_non_nullable
              as String,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isOverdue: null == isOverdue
          ? _value.isOverdue
          : isOverdue // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlantCareReminderImpl implements _PlantCareReminder {
  const _$PlantCareReminderImpl(
      {required this.id,
      required this.plantId,
      required this.careType,
      required this.dueDate,
      this.description,
      this.isCompleted = false,
      this.isOverdue = false,
      this.completedAt,
      this.createdAt});

  factory _$PlantCareReminderImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlantCareReminderImplFromJson(json);

  @override
  final String id;
  @override
  final String plantId;
  @override
  final String careType;
  @override
  final DateTime dueDate;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final bool isOverdue;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PlantCareReminder(id: $id, plantId: $plantId, careType: $careType, dueDate: $dueDate, description: $description, isCompleted: $isCompleted, isOverdue: $isOverdue, completedAt: $completedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlantCareReminderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.plantId, plantId) || other.plantId == plantId) &&
            (identical(other.careType, careType) ||
                other.careType == careType) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.isOverdue, isOverdue) ||
                other.isOverdue == isOverdue) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, plantId, careType, dueDate,
      description, isCompleted, isOverdue, completedAt, createdAt);

  /// Create a copy of PlantCareReminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlantCareReminderImplCopyWith<_$PlantCareReminderImpl> get copyWith =>
      __$$PlantCareReminderImplCopyWithImpl<_$PlantCareReminderImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlantCareReminderImplToJson(
      this,
    );
  }
}

abstract class _PlantCareReminder implements PlantCareReminder {
  const factory _PlantCareReminder(
      {required final String id,
      required final String plantId,
      required final String careType,
      required final DateTime dueDate,
      final String? description,
      final bool isCompleted,
      final bool isOverdue,
      final DateTime? completedAt,
      final DateTime? createdAt}) = _$PlantCareReminderImpl;

  factory _PlantCareReminder.fromJson(Map<String, dynamic> json) =
      _$PlantCareReminderImpl.fromJson;

  @override
  String get id;
  @override
  String get plantId;
  @override
  String get careType;
  @override
  DateTime get dueDate;
  @override
  String? get description;
  @override
  bool get isCompleted;
  @override
  bool get isOverdue;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of PlantCareReminder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlantCareReminderImplCopyWith<_$PlantCareReminderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
