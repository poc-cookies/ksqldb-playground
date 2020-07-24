# UDF

UDF - User-Defined Function

## General

With the ksqlDB API, you can implement custom functions that go beyond the built-in functions. For example, you can create a custom function that applies a pre-trained machine learning model to a stream.

ksqlDB supports these kinds of functions:
- User Defined Scalar Functions (UDFs)
- User Defined Aggregate Functions (UDAFs)
- User Defined Table Functions (UDTFs)

by using custom jars that are uploaded to the `ext/` directory of the ksqlDB installation.

At start up time, ksqlDB scans the jars in the directory looking for any classes that annotated with `@UdfDescription` (UDF), `@UdafDescription` (UDAF), or `@UdtfDescription` (UDTF).

## Functions

The following list of functions is delivered by this project:
- `vwap` - volume-weighted average price

## Build

Run the following command to obtain the Gradle wrapper:

```shell
gradle wrapper
```

Run the following command to build the jar:

```shell
./gradlew build
```

The `copyJar` gradle task will automatically deliver the jar to the `extensions/` directory.

## Tests

Run the following command to invoke the tests:

```shell
./gradlew test
```

## Resources

[Build a User-Defined Function (UDF)](https://kafka-tutorials.confluent.io/udf/ksql.html)

[UDFs](https://docs.ksqldb.io/en/latest/concepts/functions/#udfs)
