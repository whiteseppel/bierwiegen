// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_round.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameRound {

 double get target; List<double> get measurements;
/// Create a copy of GameRound
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameRoundCopyWith<GameRound> get copyWith => _$GameRoundCopyWithImpl<GameRound>(this as GameRound, _$identity);

  /// Serializes this GameRound to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameRound&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.measurements, measurements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(measurements));

@override
String toString() {
  return 'GameRound(target: $target, measurements: $measurements)';
}


}

/// @nodoc
abstract mixin class $GameRoundCopyWith<$Res>  {
  factory $GameRoundCopyWith(GameRound value, $Res Function(GameRound) _then) = _$GameRoundCopyWithImpl;
@useResult
$Res call({
 double target, List<double> measurements
});




}
/// @nodoc
class _$GameRoundCopyWithImpl<$Res>
    implements $GameRoundCopyWith<$Res> {
  _$GameRoundCopyWithImpl(this._self, this._then);

  final GameRound _self;
  final $Res Function(GameRound) _then;

/// Create a copy of GameRound
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? measurements = null,}) {
  return _then(_self.copyWith(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as double,measurements: null == measurements ? _self.measurements : measurements // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [GameRound].
extension GameRoundPatterns on GameRound {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameRound value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameRound() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameRound value)  $default,){
final _that = this;
switch (_that) {
case _GameRound():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameRound value)?  $default,){
final _that = this;
switch (_that) {
case _GameRound() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double target,  List<double> measurements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameRound() when $default != null:
return $default(_that.target,_that.measurements);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double target,  List<double> measurements)  $default,) {final _that = this;
switch (_that) {
case _GameRound():
return $default(_that.target,_that.measurements);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double target,  List<double> measurements)?  $default,) {final _that = this;
switch (_that) {
case _GameRound() when $default != null:
return $default(_that.target,_that.measurements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameRound extends GameRound {
  const _GameRound(this.target, final  List<double> measurements): _measurements = measurements,super._();
  factory _GameRound.fromJson(Map<String, dynamic> json) => _$GameRoundFromJson(json);

@override final  double target;
 final  List<double> _measurements;
@override List<double> get measurements {
  if (_measurements is EqualUnmodifiableListView) return _measurements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_measurements);
}


/// Create a copy of GameRound
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameRoundCopyWith<_GameRound> get copyWith => __$GameRoundCopyWithImpl<_GameRound>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameRoundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameRound&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other._measurements, _measurements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,target,const DeepCollectionEquality().hash(_measurements));

@override
String toString() {
  return 'GameRound(target: $target, measurements: $measurements)';
}


}

/// @nodoc
abstract mixin class _$GameRoundCopyWith<$Res> implements $GameRoundCopyWith<$Res> {
  factory _$GameRoundCopyWith(_GameRound value, $Res Function(_GameRound) _then) = __$GameRoundCopyWithImpl;
@override @useResult
$Res call({
 double target, List<double> measurements
});




}
/// @nodoc
class __$GameRoundCopyWithImpl<$Res>
    implements _$GameRoundCopyWith<$Res> {
  __$GameRoundCopyWithImpl(this._self, this._then);

  final _GameRound _self;
  final $Res Function(_GameRound) _then;

/// Create a copy of GameRound
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? measurements = null,}) {
  return _then(_GameRound(
null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as double,null == measurements ? _self._measurements : measurements // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

// dart format on
