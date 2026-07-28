// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$LogDaoMixin on DatabaseAccessor<AppDatabase> {
  $LogEntriesTable get logEntries => attachedDatabase.logEntries;
  LogDaoManager get managers => LogDaoManager(this);
}

class LogDaoManager {
  final _$LogDaoMixin _db;
  LogDaoManager(this._db);
  $$LogEntriesTableTableManager get logEntries =>
      $$LogEntriesTableTableManager(_db.attachedDatabase, _db.logEntries);
}

mixin _$DeviceDaoMixin on DatabaseAccessor<AppDatabase> {
  $FavoriteDevicesTable get favoriteDevices => attachedDatabase.favoriteDevices;
  $ConnectionHistoryTable get connectionHistory =>
      attachedDatabase.connectionHistory;
  DeviceDaoManager get managers => DeviceDaoManager(this);
}

class DeviceDaoManager {
  final _$DeviceDaoMixin _db;
  DeviceDaoManager(this._db);
  $$FavoriteDevicesTableTableManager get favoriteDevices =>
      $$FavoriteDevicesTableTableManager(
          _db.attachedDatabase, _db.favoriteDevices);
  $$ConnectionHistoryTableTableManager get connectionHistory =>
      $$ConnectionHistoryTableTableManager(
          _db.attachedDatabase, _db.connectionHistory);
}

class $LogEntriesTable extends LogEntries
    with TableInfo<$LogEntriesTable, LogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceNameMeta =
      const VerificationMeta('deviceName');
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
      'device_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serviceUuidMeta =
      const VerificationMeta('serviceUuid');
  @override
  late final GeneratedColumn<String> serviceUuid = GeneratedColumn<String>(
      'service_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _characteristicUuidMeta =
      const VerificationMeta('characteristicUuid');
  @override
  late final GeneratedColumn<String> characteristicUuid =
      GeneratedColumn<String>('characteristic_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dataHexMeta =
      const VerificationMeta('dataHex');
  @override
  late final GeneratedColumn<String> dataHex = GeneratedColumn<String>(
      'data_hex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _errorDetailMeta =
      const VerificationMeta('errorDetail');
  @override
  late final GeneratedColumn<String> errorDetail = GeneratedColumn<String>(
      'error_detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        timestamp,
        deviceId,
        deviceName,
        eventType,
        direction,
        serviceUuid,
        characteristicUuid,
        dataHex,
        description,
        errorDetail
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
          _deviceNameMeta,
          deviceName.isAcceptableOrUnknown(
              data['device_name']!, _deviceNameMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    }
    if (data.containsKey('service_uuid')) {
      context.handle(
          _serviceUuidMeta,
          serviceUuid.isAcceptableOrUnknown(
              data['service_uuid']!, _serviceUuidMeta));
    }
    if (data.containsKey('characteristic_uuid')) {
      context.handle(
          _characteristicUuidMeta,
          characteristicUuid.isAcceptableOrUnknown(
              data['characteristic_uuid']!, _characteristicUuidMeta));
    }
    if (data.containsKey('data_hex')) {
      context.handle(_dataHexMeta,
          dataHex.isAcceptableOrUnknown(data['data_hex']!, _dataHexMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('error_detail')) {
      context.handle(
          _errorDetailMeta,
          errorDetail.isAcceptableOrUnknown(
              data['error_detail']!, _errorDetailMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      deviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_name']),
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction']),
      serviceUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_uuid']),
      characteristicUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}characteristic_uuid']),
      dataHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_hex']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      errorDetail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_detail']),
    );
  }

  @override
  $LogEntriesTable createAlias(String alias) {
    return $LogEntriesTable(attachedDatabase, alias);
  }
}

class LogEntry extends DataClass implements Insertable<LogEntry> {
  final int id;
  final String timestamp;
  final String deviceId;
  final String? deviceName;
  final String eventType;
  final String? direction;
  final String? serviceUuid;
  final String? characteristicUuid;
  final String? dataHex;
  final String description;
  final String? errorDetail;
  const LogEntry(
      {required this.id,
      required this.timestamp,
      required this.deviceId,
      this.deviceName,
      required this.eventType,
      this.direction,
      this.serviceUuid,
      this.characteristicUuid,
      this.dataHex,
      required this.description,
      this.errorDetail});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<String>(timestamp);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deviceName != null) {
      map['device_name'] = Variable<String>(deviceName);
    }
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || direction != null) {
      map['direction'] = Variable<String>(direction);
    }
    if (!nullToAbsent || serviceUuid != null) {
      map['service_uuid'] = Variable<String>(serviceUuid);
    }
    if (!nullToAbsent || characteristicUuid != null) {
      map['characteristic_uuid'] = Variable<String>(characteristicUuid);
    }
    if (!nullToAbsent || dataHex != null) {
      map['data_hex'] = Variable<String>(dataHex);
    }
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || errorDetail != null) {
      map['error_detail'] = Variable<String>(errorDetail);
    }
    return map;
  }

  LogEntriesCompanion toCompanion(bool nullToAbsent) {
    return LogEntriesCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      deviceId: Value(deviceId),
      deviceName: deviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceName),
      eventType: Value(eventType),
      direction: direction == null && nullToAbsent
          ? const Value.absent()
          : Value(direction),
      serviceUuid: serviceUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceUuid),
      characteristicUuid: characteristicUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(characteristicUuid),
      dataHex: dataHex == null && nullToAbsent
          ? const Value.absent()
          : Value(dataHex),
      description: Value(description),
      errorDetail: errorDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(errorDetail),
    );
  }

  factory LogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogEntry(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceName: serializer.fromJson<String?>(json['deviceName']),
      eventType: serializer.fromJson<String>(json['eventType']),
      direction: serializer.fromJson<String?>(json['direction']),
      serviceUuid: serializer.fromJson<String?>(json['serviceUuid']),
      characteristicUuid:
          serializer.fromJson<String?>(json['characteristicUuid']),
      dataHex: serializer.fromJson<String?>(json['dataHex']),
      description: serializer.fromJson<String>(json['description']),
      errorDetail: serializer.fromJson<String?>(json['errorDetail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<String>(timestamp),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceName': serializer.toJson<String?>(deviceName),
      'eventType': serializer.toJson<String>(eventType),
      'direction': serializer.toJson<String?>(direction),
      'serviceUuid': serializer.toJson<String?>(serviceUuid),
      'characteristicUuid': serializer.toJson<String?>(characteristicUuid),
      'dataHex': serializer.toJson<String?>(dataHex),
      'description': serializer.toJson<String>(description),
      'errorDetail': serializer.toJson<String?>(errorDetail),
    };
  }

  LogEntry copyWith(
          {int? id,
          String? timestamp,
          String? deviceId,
          Value<String?> deviceName = const Value.absent(),
          String? eventType,
          Value<String?> direction = const Value.absent(),
          Value<String?> serviceUuid = const Value.absent(),
          Value<String?> characteristicUuid = const Value.absent(),
          Value<String?> dataHex = const Value.absent(),
          String? description,
          Value<String?> errorDetail = const Value.absent()}) =>
      LogEntry(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        deviceId: deviceId ?? this.deviceId,
        deviceName: deviceName.present ? deviceName.value : this.deviceName,
        eventType: eventType ?? this.eventType,
        direction: direction.present ? direction.value : this.direction,
        serviceUuid: serviceUuid.present ? serviceUuid.value : this.serviceUuid,
        characteristicUuid: characteristicUuid.present
            ? characteristicUuid.value
            : this.characteristicUuid,
        dataHex: dataHex.present ? dataHex.value : this.dataHex,
        description: description ?? this.description,
        errorDetail: errorDetail.present ? errorDetail.value : this.errorDetail,
      );
  LogEntry copyWithCompanion(LogEntriesCompanion data) {
    return LogEntry(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceName:
          data.deviceName.present ? data.deviceName.value : this.deviceName,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      direction: data.direction.present ? data.direction.value : this.direction,
      serviceUuid:
          data.serviceUuid.present ? data.serviceUuid.value : this.serviceUuid,
      characteristicUuid: data.characteristicUuid.present
          ? data.characteristicUuid.value
          : this.characteristicUuid,
      dataHex: data.dataHex.present ? data.dataHex.value : this.dataHex,
      description:
          data.description.present ? data.description.value : this.description,
      errorDetail:
          data.errorDetail.present ? data.errorDetail.value : this.errorDetail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogEntry(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('eventType: $eventType, ')
          ..write('direction: $direction, ')
          ..write('serviceUuid: $serviceUuid, ')
          ..write('characteristicUuid: $characteristicUuid, ')
          ..write('dataHex: $dataHex, ')
          ..write('description: $description, ')
          ..write('errorDetail: $errorDetail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      timestamp,
      deviceId,
      deviceName,
      eventType,
      direction,
      serviceUuid,
      characteristicUuid,
      dataHex,
      description,
      errorDetail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogEntry &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.deviceId == this.deviceId &&
          other.deviceName == this.deviceName &&
          other.eventType == this.eventType &&
          other.direction == this.direction &&
          other.serviceUuid == this.serviceUuid &&
          other.characteristicUuid == this.characteristicUuid &&
          other.dataHex == this.dataHex &&
          other.description == this.description &&
          other.errorDetail == this.errorDetail);
}

class LogEntriesCompanion extends UpdateCompanion<LogEntry> {
  final Value<int> id;
  final Value<String> timestamp;
  final Value<String> deviceId;
  final Value<String?> deviceName;
  final Value<String> eventType;
  final Value<String?> direction;
  final Value<String?> serviceUuid;
  final Value<String?> characteristicUuid;
  final Value<String?> dataHex;
  final Value<String> description;
  final Value<String?> errorDetail;
  const LogEntriesCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.eventType = const Value.absent(),
    this.direction = const Value.absent(),
    this.serviceUuid = const Value.absent(),
    this.characteristicUuid = const Value.absent(),
    this.dataHex = const Value.absent(),
    this.description = const Value.absent(),
    this.errorDetail = const Value.absent(),
  });
  LogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String timestamp,
    required String deviceId,
    this.deviceName = const Value.absent(),
    required String eventType,
    this.direction = const Value.absent(),
    this.serviceUuid = const Value.absent(),
    this.characteristicUuid = const Value.absent(),
    this.dataHex = const Value.absent(),
    required String description,
    this.errorDetail = const Value.absent(),
  })  : timestamp = Value(timestamp),
        deviceId = Value(deviceId),
        eventType = Value(eventType),
        description = Value(description);
  static Insertable<LogEntry> custom({
    Expression<int>? id,
    Expression<String>? timestamp,
    Expression<String>? deviceId,
    Expression<String>? deviceName,
    Expression<String>? eventType,
    Expression<String>? direction,
    Expression<String>? serviceUuid,
    Expression<String>? characteristicUuid,
    Expression<String>? dataHex,
    Expression<String>? description,
    Expression<String>? errorDetail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      if (eventType != null) 'event_type': eventType,
      if (direction != null) 'direction': direction,
      if (serviceUuid != null) 'service_uuid': serviceUuid,
      if (characteristicUuid != null) 'characteristic_uuid': characteristicUuid,
      if (dataHex != null) 'data_hex': dataHex,
      if (description != null) 'description': description,
      if (errorDetail != null) 'error_detail': errorDetail,
    });
  }

  LogEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? timestamp,
      Value<String>? deviceId,
      Value<String?>? deviceName,
      Value<String>? eventType,
      Value<String?>? direction,
      Value<String?>? serviceUuid,
      Value<String?>? characteristicUuid,
      Value<String?>? dataHex,
      Value<String>? description,
      Value<String?>? errorDetail}) {
    return LogEntriesCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      eventType: eventType ?? this.eventType,
      direction: direction ?? this.direction,
      serviceUuid: serviceUuid ?? this.serviceUuid,
      characteristicUuid: characteristicUuid ?? this.characteristicUuid,
      dataHex: dataHex ?? this.dataHex,
      description: description ?? this.description,
      errorDetail: errorDetail ?? this.errorDetail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (serviceUuid.present) {
      map['service_uuid'] = Variable<String>(serviceUuid.value);
    }
    if (characteristicUuid.present) {
      map['characteristic_uuid'] = Variable<String>(characteristicUuid.value);
    }
    if (dataHex.present) {
      map['data_hex'] = Variable<String>(dataHex.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (errorDetail.present) {
      map['error_detail'] = Variable<String>(errorDetail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('eventType: $eventType, ')
          ..write('direction: $direction, ')
          ..write('serviceUuid: $serviceUuid, ')
          ..write('characteristicUuid: $characteristicUuid, ')
          ..write('dataHex: $dataHex, ')
          ..write('description: $description, ')
          ..write('errorDetail: $errorDetail')
          ..write(')'))
        .toString();
  }
}

class $FavoriteDevicesTable extends FavoriteDevices
    with TableInfo<$FavoriteDevicesTable, FavoriteDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _macAddressMeta =
      const VerificationMeta('macAddress');
  @override
  late final GeneratedColumn<String> macAddress = GeneratedColumn<String>(
      'mac_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSeenMeta =
      const VerificationMeta('lastSeen');
  @override
  late final GeneratedColumn<String> lastSeen = GeneratedColumn<String>(
      'last_seen', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceJsonMeta =
      const VerificationMeta('deviceJson');
  @override
  late final GeneratedColumn<String> deviceJson = GeneratedColumn<String>(
      'device_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [deviceId, name, macAddress, lastSeen, deviceJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_devices';
  @override
  VerificationContext validateIntegrity(Insertable<FavoriteDevice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mac_address')) {
      context.handle(
          _macAddressMeta,
          macAddress.isAcceptableOrUnknown(
              data['mac_address']!, _macAddressMeta));
    } else if (isInserting) {
      context.missing(_macAddressMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(_lastSeenMeta,
          lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta));
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    if (data.containsKey('device_json')) {
      context.handle(
          _deviceJsonMeta,
          deviceJson.isAcceptableOrUnknown(
              data['device_json']!, _deviceJsonMeta));
    } else if (isInserting) {
      context.missing(_deviceJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  FavoriteDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteDevice(
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      macAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mac_address'])!,
      lastSeen: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_seen'])!,
      deviceJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_json'])!,
    );
  }

  @override
  $FavoriteDevicesTable createAlias(String alias) {
    return $FavoriteDevicesTable(attachedDatabase, alias);
  }
}

class FavoriteDevice extends DataClass implements Insertable<FavoriteDevice> {
  final String deviceId;
  final String name;
  final String macAddress;
  final String lastSeen;
  final String deviceJson;
  const FavoriteDevice(
      {required this.deviceId,
      required this.name,
      required this.macAddress,
      required this.lastSeen,
      required this.deviceJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    map['mac_address'] = Variable<String>(macAddress);
    map['last_seen'] = Variable<String>(lastSeen);
    map['device_json'] = Variable<String>(deviceJson);
    return map;
  }

  FavoriteDevicesCompanion toCompanion(bool nullToAbsent) {
    return FavoriteDevicesCompanion(
      deviceId: Value(deviceId),
      name: Value(name),
      macAddress: Value(macAddress),
      lastSeen: Value(lastSeen),
      deviceJson: Value(deviceJson),
    );
  }

  factory FavoriteDevice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteDevice(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      macAddress: serializer.fromJson<String>(json['macAddress']),
      lastSeen: serializer.fromJson<String>(json['lastSeen']),
      deviceJson: serializer.fromJson<String>(json['deviceJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'macAddress': serializer.toJson<String>(macAddress),
      'lastSeen': serializer.toJson<String>(lastSeen),
      'deviceJson': serializer.toJson<String>(deviceJson),
    };
  }

  FavoriteDevice copyWith(
          {String? deviceId,
          String? name,
          String? macAddress,
          String? lastSeen,
          String? deviceJson}) =>
      FavoriteDevice(
        deviceId: deviceId ?? this.deviceId,
        name: name ?? this.name,
        macAddress: macAddress ?? this.macAddress,
        lastSeen: lastSeen ?? this.lastSeen,
        deviceJson: deviceJson ?? this.deviceJson,
      );
  FavoriteDevice copyWithCompanion(FavoriteDevicesCompanion data) {
    return FavoriteDevice(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      macAddress:
          data.macAddress.present ? data.macAddress.value : this.macAddress,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      deviceJson:
          data.deviceJson.present ? data.deviceJson.value : this.deviceJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteDevice(')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('macAddress: $macAddress, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('deviceJson: $deviceJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(deviceId, name, macAddress, lastSeen, deviceJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteDevice &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.macAddress == this.macAddress &&
          other.lastSeen == this.lastSeen &&
          other.deviceJson == this.deviceJson);
}

class FavoriteDevicesCompanion extends UpdateCompanion<FavoriteDevice> {
  final Value<String> deviceId;
  final Value<String> name;
  final Value<String> macAddress;
  final Value<String> lastSeen;
  final Value<String> deviceJson;
  final Value<int> rowid;
  const FavoriteDevicesCompanion({
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.macAddress = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.deviceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteDevicesCompanion.insert({
    required String deviceId,
    required String name,
    required String macAddress,
    required String lastSeen,
    required String deviceJson,
    this.rowid = const Value.absent(),
  })  : deviceId = Value(deviceId),
        name = Value(name),
        macAddress = Value(macAddress),
        lastSeen = Value(lastSeen),
        deviceJson = Value(deviceJson);
  static Insertable<FavoriteDevice> custom({
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? macAddress,
    Expression<String>? lastSeen,
    Expression<String>? deviceJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (macAddress != null) 'mac_address': macAddress,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (deviceJson != null) 'device_json': deviceJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteDevicesCompanion copyWith(
      {Value<String>? deviceId,
      Value<String>? name,
      Value<String>? macAddress,
      Value<String>? lastSeen,
      Value<String>? deviceJson,
      Value<int>? rowid}) {
    return FavoriteDevicesCompanion(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      lastSeen: lastSeen ?? this.lastSeen,
      deviceJson: deviceJson ?? this.deviceJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (macAddress.present) {
      map['mac_address'] = Variable<String>(macAddress.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<String>(lastSeen.value);
    }
    if (deviceJson.present) {
      map['device_json'] = Variable<String>(deviceJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteDevicesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('macAddress: $macAddress, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('deviceJson: $deviceJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConnectionHistoryTable extends ConnectionHistory
    with TableInfo<$ConnectionHistoryTable, ConnectionHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _macAddressMeta =
      const VerificationMeta('macAddress');
  @override
  late final GeneratedColumn<String> macAddress = GeneratedColumn<String>(
      'mac_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _connectedAtMeta =
      const VerificationMeta('connectedAt');
  @override
  late final GeneratedColumn<String> connectedAt = GeneratedColumn<String>(
      'connected_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _disconnectedAtMeta =
      const VerificationMeta('disconnectedAt');
  @override
  late final GeneratedColumn<String> disconnectedAt = GeneratedColumn<String>(
      'disconnected_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, deviceId, name, macAddress, connectedAt, disconnectedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connection_history';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConnectionHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mac_address')) {
      context.handle(
          _macAddressMeta,
          macAddress.isAcceptableOrUnknown(
              data['mac_address']!, _macAddressMeta));
    } else if (isInserting) {
      context.missing(_macAddressMeta);
    }
    if (data.containsKey('connected_at')) {
      context.handle(
          _connectedAtMeta,
          connectedAt.isAcceptableOrUnknown(
              data['connected_at']!, _connectedAtMeta));
    } else if (isInserting) {
      context.missing(_connectedAtMeta);
    }
    if (data.containsKey('disconnected_at')) {
      context.handle(
          _disconnectedAtMeta,
          disconnectedAt.isAcceptableOrUnknown(
              data['disconnected_at']!, _disconnectedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConnectionHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConnectionHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      macAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mac_address'])!,
      connectedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}connected_at'])!,
      disconnectedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}disconnected_at']),
    );
  }

  @override
  $ConnectionHistoryTable createAlias(String alias) {
    return $ConnectionHistoryTable(attachedDatabase, alias);
  }
}

class ConnectionHistoryData extends DataClass
    implements Insertable<ConnectionHistoryData> {
  final int id;
  final String deviceId;
  final String name;
  final String macAddress;
  final String connectedAt;
  final String? disconnectedAt;
  const ConnectionHistoryData(
      {required this.id,
      required this.deviceId,
      required this.name,
      required this.macAddress,
      required this.connectedAt,
      this.disconnectedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    map['mac_address'] = Variable<String>(macAddress);
    map['connected_at'] = Variable<String>(connectedAt);
    if (!nullToAbsent || disconnectedAt != null) {
      map['disconnected_at'] = Variable<String>(disconnectedAt);
    }
    return map;
  }

  ConnectionHistoryCompanion toCompanion(bool nullToAbsent) {
    return ConnectionHistoryCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      name: Value(name),
      macAddress: Value(macAddress),
      connectedAt: Value(connectedAt),
      disconnectedAt: disconnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(disconnectedAt),
    );
  }

  factory ConnectionHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConnectionHistoryData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      macAddress: serializer.fromJson<String>(json['macAddress']),
      connectedAt: serializer.fromJson<String>(json['connectedAt']),
      disconnectedAt: serializer.fromJson<String?>(json['disconnectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'macAddress': serializer.toJson<String>(macAddress),
      'connectedAt': serializer.toJson<String>(connectedAt),
      'disconnectedAt': serializer.toJson<String?>(disconnectedAt),
    };
  }

  ConnectionHistoryData copyWith(
          {int? id,
          String? deviceId,
          String? name,
          String? macAddress,
          String? connectedAt,
          Value<String?> disconnectedAt = const Value.absent()}) =>
      ConnectionHistoryData(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        name: name ?? this.name,
        macAddress: macAddress ?? this.macAddress,
        connectedAt: connectedAt ?? this.connectedAt,
        disconnectedAt:
            disconnectedAt.present ? disconnectedAt.value : this.disconnectedAt,
      );
  ConnectionHistoryData copyWithCompanion(ConnectionHistoryCompanion data) {
    return ConnectionHistoryData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      macAddress:
          data.macAddress.present ? data.macAddress.value : this.macAddress,
      connectedAt:
          data.connectedAt.present ? data.connectedAt.value : this.connectedAt,
      disconnectedAt: data.disconnectedAt.present
          ? data.disconnectedAt.value
          : this.disconnectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionHistoryData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('macAddress: $macAddress, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('disconnectedAt: $disconnectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, name, macAddress, connectedAt, disconnectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionHistoryData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.macAddress == this.macAddress &&
          other.connectedAt == this.connectedAt &&
          other.disconnectedAt == this.disconnectedAt);
}

class ConnectionHistoryCompanion
    extends UpdateCompanion<ConnectionHistoryData> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<String> macAddress;
  final Value<String> connectedAt;
  final Value<String?> disconnectedAt;
  const ConnectionHistoryCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.macAddress = const Value.absent(),
    this.connectedAt = const Value.absent(),
    this.disconnectedAt = const Value.absent(),
  });
  ConnectionHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required String name,
    required String macAddress,
    required String connectedAt,
    this.disconnectedAt = const Value.absent(),
  })  : deviceId = Value(deviceId),
        name = Value(name),
        macAddress = Value(macAddress),
        connectedAt = Value(connectedAt);
  static Insertable<ConnectionHistoryData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? macAddress,
    Expression<String>? connectedAt,
    Expression<String>? disconnectedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (macAddress != null) 'mac_address': macAddress,
      if (connectedAt != null) 'connected_at': connectedAt,
      if (disconnectedAt != null) 'disconnected_at': disconnectedAt,
    });
  }

  ConnectionHistoryCompanion copyWith(
      {Value<int>? id,
      Value<String>? deviceId,
      Value<String>? name,
      Value<String>? macAddress,
      Value<String>? connectedAt,
      Value<String?>? disconnectedAt}) {
    return ConnectionHistoryCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      connectedAt: connectedAt ?? this.connectedAt,
      disconnectedAt: disconnectedAt ?? this.disconnectedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (macAddress.present) {
      map['mac_address'] = Variable<String>(macAddress.value);
    }
    if (connectedAt.present) {
      map['connected_at'] = Variable<String>(connectedAt.value);
    }
    if (disconnectedAt.present) {
      map['disconnected_at'] = Variable<String>(disconnectedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionHistoryCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('macAddress: $macAddress, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('disconnectedAt: $disconnectedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LogEntriesTable logEntries = $LogEntriesTable(this);
  late final $FavoriteDevicesTable favoriteDevices =
      $FavoriteDevicesTable(this);
  late final $ConnectionHistoryTable connectionHistory =
      $ConnectionHistoryTable(this);
  late final LogDao logDao = LogDao(this as AppDatabase);
  late final DeviceDao deviceDao = DeviceDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [logEntries, favoriteDevices, connectionHistory];
}

typedef $$LogEntriesTableCreateCompanionBuilder = LogEntriesCompanion Function({
  Value<int> id,
  required String timestamp,
  required String deviceId,
  Value<String?> deviceName,
  required String eventType,
  Value<String?> direction,
  Value<String?> serviceUuid,
  Value<String?> characteristicUuid,
  Value<String?> dataHex,
  required String description,
  Value<String?> errorDetail,
});
typedef $$LogEntriesTableUpdateCompanionBuilder = LogEntriesCompanion Function({
  Value<int> id,
  Value<String> timestamp,
  Value<String> deviceId,
  Value<String?> deviceName,
  Value<String> eventType,
  Value<String?> direction,
  Value<String?> serviceUuid,
  Value<String?> characteristicUuid,
  Value<String?> dataHex,
  Value<String> description,
  Value<String?> errorDetail,
});

class $$LogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceUuid => $composableBuilder(
      column: $table.serviceUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get characteristicUuid => $composableBuilder(
      column: $table.characteristicUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataHex => $composableBuilder(
      column: $table.dataHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorDetail => $composableBuilder(
      column: $table.errorDetail, builder: (column) => ColumnFilters(column));
}

class $$LogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceUuid => $composableBuilder(
      column: $table.serviceUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get characteristicUuid => $composableBuilder(
      column: $table.characteristicUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataHex => $composableBuilder(
      column: $table.dataHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorDetail => $composableBuilder(
      column: $table.errorDetail, builder: (column) => ColumnOrderings(column));
}

class $$LogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get serviceUuid => $composableBuilder(
      column: $table.serviceUuid, builder: (column) => column);

  GeneratedColumn<String> get characteristicUuid => $composableBuilder(
      column: $table.characteristicUuid, builder: (column) => column);

  GeneratedColumn<String> get dataHex =>
      $composableBuilder(column: $table.dataHex, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get errorDetail => $composableBuilder(
      column: $table.errorDetail, builder: (column) => column);
}

class $$LogEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LogEntriesTable,
    LogEntry,
    $$LogEntriesTableFilterComposer,
    $$LogEntriesTableOrderingComposer,
    $$LogEntriesTableAnnotationComposer,
    $$LogEntriesTableCreateCompanionBuilder,
    $$LogEntriesTableUpdateCompanionBuilder,
    (LogEntry, BaseReferences<_$AppDatabase, $LogEntriesTable, LogEntry>),
    LogEntry,
    PrefetchHooks Function()> {
  $$LogEntriesTableTableManager(_$AppDatabase db, $LogEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> timestamp = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> deviceName = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String?> direction = const Value.absent(),
            Value<String?> serviceUuid = const Value.absent(),
            Value<String?> characteristicUuid = const Value.absent(),
            Value<String?> dataHex = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> errorDetail = const Value.absent(),
          }) =>
              LogEntriesCompanion(
            id: id,
            timestamp: timestamp,
            deviceId: deviceId,
            deviceName: deviceName,
            eventType: eventType,
            direction: direction,
            serviceUuid: serviceUuid,
            characteristicUuid: characteristicUuid,
            dataHex: dataHex,
            description: description,
            errorDetail: errorDetail,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String timestamp,
            required String deviceId,
            Value<String?> deviceName = const Value.absent(),
            required String eventType,
            Value<String?> direction = const Value.absent(),
            Value<String?> serviceUuid = const Value.absent(),
            Value<String?> characteristicUuid = const Value.absent(),
            Value<String?> dataHex = const Value.absent(),
            required String description,
            Value<String?> errorDetail = const Value.absent(),
          }) =>
              LogEntriesCompanion.insert(
            id: id,
            timestamp: timestamp,
            deviceId: deviceId,
            deviceName: deviceName,
            eventType: eventType,
            direction: direction,
            serviceUuid: serviceUuid,
            characteristicUuid: characteristicUuid,
            dataHex: dataHex,
            description: description,
            errorDetail: errorDetail,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LogEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LogEntriesTable,
    LogEntry,
    $$LogEntriesTableFilterComposer,
    $$LogEntriesTableOrderingComposer,
    $$LogEntriesTableAnnotationComposer,
    $$LogEntriesTableCreateCompanionBuilder,
    $$LogEntriesTableUpdateCompanionBuilder,
    (LogEntry, BaseReferences<_$AppDatabase, $LogEntriesTable, LogEntry>),
    LogEntry,
    PrefetchHooks Function()>;
typedef $$FavoriteDevicesTableCreateCompanionBuilder = FavoriteDevicesCompanion
    Function({
  required String deviceId,
  required String name,
  required String macAddress,
  required String lastSeen,
  required String deviceJson,
  Value<int> rowid,
});
typedef $$FavoriteDevicesTableUpdateCompanionBuilder = FavoriteDevicesCompanion
    Function({
  Value<String> deviceId,
  Value<String> name,
  Value<String> macAddress,
  Value<String> lastSeen,
  Value<String> deviceJson,
  Value<int> rowid,
});

class $$FavoriteDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteDevicesTable> {
  $$FavoriteDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get macAddress => $composableBuilder(
      column: $table.macAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSeen => $composableBuilder(
      column: $table.lastSeen, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceJson => $composableBuilder(
      column: $table.deviceJson, builder: (column) => ColumnFilters(column));
}

class $$FavoriteDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteDevicesTable> {
  $$FavoriteDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get macAddress => $composableBuilder(
      column: $table.macAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSeen => $composableBuilder(
      column: $table.lastSeen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceJson => $composableBuilder(
      column: $table.deviceJson, builder: (column) => ColumnOrderings(column));
}

class $$FavoriteDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteDevicesTable> {
  $$FavoriteDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get macAddress => $composableBuilder(
      column: $table.macAddress, builder: (column) => column);

  GeneratedColumn<String> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<String> get deviceJson => $composableBuilder(
      column: $table.deviceJson, builder: (column) => column);
}

class $$FavoriteDevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavoriteDevicesTable,
    FavoriteDevice,
    $$FavoriteDevicesTableFilterComposer,
    $$FavoriteDevicesTableOrderingComposer,
    $$FavoriteDevicesTableAnnotationComposer,
    $$FavoriteDevicesTableCreateCompanionBuilder,
    $$FavoriteDevicesTableUpdateCompanionBuilder,
    (
      FavoriteDevice,
      BaseReferences<_$AppDatabase, $FavoriteDevicesTable, FavoriteDevice>
    ),
    FavoriteDevice,
    PrefetchHooks Function()> {
  $$FavoriteDevicesTableTableManager(
      _$AppDatabase db, $FavoriteDevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> deviceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> macAddress = const Value.absent(),
            Value<String> lastSeen = const Value.absent(),
            Value<String> deviceJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoriteDevicesCompanion(
            deviceId: deviceId,
            name: name,
            macAddress: macAddress,
            lastSeen: lastSeen,
            deviceJson: deviceJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String deviceId,
            required String name,
            required String macAddress,
            required String lastSeen,
            required String deviceJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoriteDevicesCompanion.insert(
            deviceId: deviceId,
            name: name,
            macAddress: macAddress,
            lastSeen: lastSeen,
            deviceJson: deviceJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoriteDevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavoriteDevicesTable,
    FavoriteDevice,
    $$FavoriteDevicesTableFilterComposer,
    $$FavoriteDevicesTableOrderingComposer,
    $$FavoriteDevicesTableAnnotationComposer,
    $$FavoriteDevicesTableCreateCompanionBuilder,
    $$FavoriteDevicesTableUpdateCompanionBuilder,
    (
      FavoriteDevice,
      BaseReferences<_$AppDatabase, $FavoriteDevicesTable, FavoriteDevice>
    ),
    FavoriteDevice,
    PrefetchHooks Function()>;
typedef $$ConnectionHistoryTableCreateCompanionBuilder
    = ConnectionHistoryCompanion Function({
  Value<int> id,
  required String deviceId,
  required String name,
  required String macAddress,
  required String connectedAt,
  Value<String?> disconnectedAt,
});
typedef $$ConnectionHistoryTableUpdateCompanionBuilder
    = ConnectionHistoryCompanion Function({
  Value<int> id,
  Value<String> deviceId,
  Value<String> name,
  Value<String> macAddress,
  Value<String> connectedAt,
  Value<String?> disconnectedAt,
});

class $$ConnectionHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ConnectionHistoryTable> {
  $$ConnectionHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get macAddress => $composableBuilder(
      column: $table.macAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get connectedAt => $composableBuilder(
      column: $table.connectedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get disconnectedAt => $composableBuilder(
      column: $table.disconnectedAt,
      builder: (column) => ColumnFilters(column));
}

class $$ConnectionHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ConnectionHistoryTable> {
  $$ConnectionHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get macAddress => $composableBuilder(
      column: $table.macAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get connectedAt => $composableBuilder(
      column: $table.connectedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get disconnectedAt => $composableBuilder(
      column: $table.disconnectedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ConnectionHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConnectionHistoryTable> {
  $$ConnectionHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get macAddress => $composableBuilder(
      column: $table.macAddress, builder: (column) => column);

  GeneratedColumn<String> get connectedAt => $composableBuilder(
      column: $table.connectedAt, builder: (column) => column);

  GeneratedColumn<String> get disconnectedAt => $composableBuilder(
      column: $table.disconnectedAt, builder: (column) => column);
}

class $$ConnectionHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConnectionHistoryTable,
    ConnectionHistoryData,
    $$ConnectionHistoryTableFilterComposer,
    $$ConnectionHistoryTableOrderingComposer,
    $$ConnectionHistoryTableAnnotationComposer,
    $$ConnectionHistoryTableCreateCompanionBuilder,
    $$ConnectionHistoryTableUpdateCompanionBuilder,
    (
      ConnectionHistoryData,
      BaseReferences<_$AppDatabase, $ConnectionHistoryTable,
          ConnectionHistoryData>
    ),
    ConnectionHistoryData,
    PrefetchHooks Function()> {
  $$ConnectionHistoryTableTableManager(
      _$AppDatabase db, $ConnectionHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConnectionHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConnectionHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConnectionHistoryTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> macAddress = const Value.absent(),
            Value<String> connectedAt = const Value.absent(),
            Value<String?> disconnectedAt = const Value.absent(),
          }) =>
              ConnectionHistoryCompanion(
            id: id,
            deviceId: deviceId,
            name: name,
            macAddress: macAddress,
            connectedAt: connectedAt,
            disconnectedAt: disconnectedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String deviceId,
            required String name,
            required String macAddress,
            required String connectedAt,
            Value<String?> disconnectedAt = const Value.absent(),
          }) =>
              ConnectionHistoryCompanion.insert(
            id: id,
            deviceId: deviceId,
            name: name,
            macAddress: macAddress,
            connectedAt: connectedAt,
            disconnectedAt: disconnectedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConnectionHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConnectionHistoryTable,
    ConnectionHistoryData,
    $$ConnectionHistoryTableFilterComposer,
    $$ConnectionHistoryTableOrderingComposer,
    $$ConnectionHistoryTableAnnotationComposer,
    $$ConnectionHistoryTableCreateCompanionBuilder,
    $$ConnectionHistoryTableUpdateCompanionBuilder,
    (
      ConnectionHistoryData,
      BaseReferences<_$AppDatabase, $ConnectionHistoryTable,
          ConnectionHistoryData>
    ),
    ConnectionHistoryData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LogEntriesTableTableManager get logEntries =>
      $$LogEntriesTableTableManager(_db, _db.logEntries);
  $$FavoriteDevicesTableTableManager get favoriteDevices =>
      $$FavoriteDevicesTableTableManager(_db, _db.favoriteDevices);
  $$ConnectionHistoryTableTableManager get connectionHistory =>
      $$ConnectionHistoryTableTableManager(_db, _db.connectionHistory);
}
