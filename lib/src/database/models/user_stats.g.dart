// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserStatsCollection on Isar {
  IsarCollection<UserStats> get userStats => this.collection();
}

const UserStatsSchema = CollectionSchema(
  name: r'UserStats',
  id: 3718987168289318233,
  properties: {
    r'currentStreak': PropertySchema(
      id: 0,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'highestStreak': PropertySchema(
      id: 1,
      name: r'highestStreak',
      type: IsarType.long,
    ),
    r'totalCompleted': PropertySchema(
      id: 2,
      name: r'totalCompleted',
      type: IsarType.long,
    )
  },
  estimateSize: _userStatsEstimateSize,
  serialize: _userStatsSerialize,
  deserialize: _userStatsDeserialize,
  deserializeProp: _userStatsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userStatsGetId,
  getLinks: _userStatsGetLinks,
  attach: _userStatsAttach,
  version: '3.1.0+1',
);

int _userStatsEstimateSize(
  UserStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _userStatsSerialize(
  UserStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentStreak);
  writer.writeLong(offsets[1], object.highestStreak);
  writer.writeLong(offsets[2], object.totalCompleted);
}

UserStats _userStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserStats(
    currentStreak: reader.readLongOrNull(offsets[0]) ?? 0,
    highestStreak: reader.readLongOrNull(offsets[1]) ?? 0,
    id: id,
    totalCompleted: reader.readLongOrNull(offsets[2]) ?? 0,
  );
  return object;
}

P _userStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userStatsGetId(UserStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userStatsGetLinks(UserStats object) {
  return [];
}

void _userStatsAttach(IsarCollection<dynamic> col, Id id, UserStats object) {
  object.id = id;
}

extension UserStatsQueryWhereSort
    on QueryBuilder<UserStats, UserStats, QWhere> {
  QueryBuilder<UserStats, UserStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserStatsQueryWhere
    on QueryBuilder<UserStats, UserStats, QWhereClause> {
  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserStatsQueryFilter
    on QueryBuilder<UserStats, UserStats, QFilterCondition> {
  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      highestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'highestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      highestStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'highestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      highestStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'highestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      highestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'highestStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      totalCompletedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      totalCompletedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      totalCompletedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
      totalCompletedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCompleted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserStatsQueryObject
    on QueryBuilder<UserStats, UserStats, QFilterCondition> {}

extension UserStatsQueryLinks
    on QueryBuilder<UserStats, UserStats, QFilterCondition> {}

extension UserStatsQuerySortBy on QueryBuilder<UserStats, UserStats, QSortBy> {
  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByHighestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByHighestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highestStreak', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByTotalCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCompleted', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByTotalCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCompleted', Sort.desc);
    });
  }
}

extension UserStatsQuerySortThenBy
    on QueryBuilder<UserStats, UserStats, QSortThenBy> {
  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByHighestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByHighestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highestStreak', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByTotalCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCompleted', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByTotalCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCompleted', Sort.desc);
    });
  }
}

extension UserStatsQueryWhereDistinct
    on QueryBuilder<UserStats, UserStats, QDistinct> {
  QueryBuilder<UserStats, UserStats, QDistinct> distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<UserStats, UserStats, QDistinct> distinctByHighestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highestStreak');
    });
  }

  QueryBuilder<UserStats, UserStats, QDistinct> distinctByTotalCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCompleted');
    });
  }
}

extension UserStatsQueryProperty
    on QueryBuilder<UserStats, UserStats, QQueryProperty> {
  QueryBuilder<UserStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserStats, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<UserStats, int, QQueryOperations> highestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highestStreak');
    });
  }

  QueryBuilder<UserStats, int, QQueryOperations> totalCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCompleted');
    });
  }
}
