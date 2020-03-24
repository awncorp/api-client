# NAME

API::Client

# ABSTRACT

HTTP API Thin-Client Abstraction

# SYNOPSIS

    package main;

    use API::Client;

    my $client = API::Client->new(url => 'https://httpbin.org');

    # $client->resource('post');

    # $client->update(json => {...});

# DESCRIPTION

This package provides an abstraction and method for rapidly developing HTTP API
clients.

# INTEGRATES

This package integrates behaviors from:

[Data::Object::Role::Buildable](https://metacpan.org/pod/Data%3A%3AObject%3A%3ARole%3A%3ABuildable)

[Data::Object::Role::Stashable](https://metacpan.org/pod/Data%3A%3AObject%3A%3ARole%3A%3AStashable)

[Data::Object::Role::Throwable](https://metacpan.org/pod/Data%3A%3AObject%3A%3ARole%3A%3AThrowable)

# LIBRARIES

This package uses type constraints from:

[Types::Standard](https://metacpan.org/pod/Types%3A%3AStandard)

# ATTRIBUTES

This package has the following attributes:

## debug

    debug(Bool)

This attribute is read-only, accepts `(Bool)` values, and is optional.

## fatal

    fatal(Bool)

This attribute is read-only, accepts `(Bool)` values, and is optional.

## logger

    logger(InstanceOf["FlightRecorder"])

This attribute is read-only, accepts `(InstanceOf["FlightRecorder"])` values, and is optional.

## name

    name(Str)

This attribute is read-only, accepts `(Str)` values, and is optional.

## retries

    retries(Int)

This attribute is read-only, accepts `(Int)` values, and is optional.

## timeout

    timeout(Int)

This attribute is read-only, accepts `(Int)` values, and is optional.

## url

    url(InstanceOf["Mojo::URL"])

This attribute is read-only, accepts `(InstanceOf["Mojo::URL"])` values, and is optional.

## user\_agent

    user_agent(InstanceOf["Mojo::UserAgent"])

This attribute is read-only, accepts `(InstanceOf["Mojo::UserAgent"])` values, and is optional.

## version

    version(Str)

This attribute is read-only, accepts `(Str)` values, and is optional.

# METHODS

This package implements the following methods:

## create

    create(Any %args) : InstanceOf["Mojo::Transaction"]

The create method issues a `POST` request to the API resource represented by
the object.

- create example #1

        # given: synopsis

        $client->resource('post')->create(
          json => {active => 1}
        );

## delete

    delete(Any %args) : InstanceOf["Mojo::Transaction"]

The delete method issues a `DELETE` request to the API resource represented by
the object.

- delete example #1

        # given: synopsis

        $client->resource('delete')->delete;

## dispatch

    dispatch(Str :$method = 'get', Any %args) : InstanceOf["Mojo::Transaction"]

The dispatch method issues a request to the API resource represented by the
object.

- dispatch example #1

        # given: synopsis

        $client->resource('get')->dispatch;

- dispatch example #2

        # given: synopsis

        $client->resource('post')->dispatch(
          method => 'post', body => 'active=1'
        );

- dispatch example #3

        # given: synopsis

        $client->resource('get')->dispatch(
          method => 'get', query => {active => 1}
        );

- dispatch example #4

        # given: synopsis

        $client->resource('post')->dispatch(
          method => 'post', json => {active => 1}
        );

- dispatch example #5

        # given: synopsis

        $client->resource('post')->dispatch(
          method => 'post', form => {active => 1}
        );

- dispatch example #6

        # given: synopsis

        $client->resource('put')->dispatch(
          method => 'put', json => {active => 1}
        );

- dispatch example #7

        # given: synopsis

        $client->resource('patch')->dispatch(
          method => 'patch', json => {active => 1}
        );

- dispatch example #8

        # given: synopsis

        $client->resource('delete')->dispatch(
          method => 'delete', json => {active => 1}
        );

## fetch

    fetch(Any %args) : InstanceOf["Mojo::Transaction"]

The fetch method issues a `GET` request to the API resource represented by the
object.

- fetch example #1

        # given: synopsis

        $client->resource('get')->fetch;

## patch

    patch(Any %args) : InstanceOf["Mojo::Transaction"]

The patch method issues a `PATCH` request to the API resource represented by
the object.

- patch example #1

        # given: synopsis

        $client->resource('patch')->patch(
          json => {active => 1}
        );

## prepare

    prepare(Object $ua, Object $tx, Any %args) : Object

The prepare method acts as a `before` hook triggered before each request where
you can modify the transactor objects.

- prepare example #1

        # given: synopsis

        require Mojo::UserAgent;
        require Mojo::Transaction::HTTP;

        $client->prepare(
          Mojo::UserAgent->new,
          Mojo::Transaction::HTTP->new
        );

## process

    process(Object $ua, Object $tx, Any %args) : Object

The process method acts as an `after` hook triggered after each response where
you can modify the transactor objects.

- process example #1

        # given: synopsis

        require Mojo::UserAgent;
        require Mojo::Transaction::HTTP;

        $client->process(
          Mojo::UserAgent->new,
          Mojo::Transaction::HTTP->new
        );

## resource

    resource(Str @segments) : Object

The resource method returns a new instance of the object for the API resource
endpoint specified.

- resource example #1

        # given: synopsis

        $client->resource('status', 200);

## serialize

    serialize() : HashRef

The serialize method serializes and returns the object as a `hashref`.

- serialize example #1

        # given: synopsis

        $client->serialize;

## update

    update(Any %args) : InstanceOf["Mojo::Transaction"]

The update method issues a `PUT` request to the API resource represented by
the object.

- update example #1

        # given: synopsis

        $client->resource('put')->update(
          json => {active => 1}
        );

# AUTHOR

Al Newkirk, `awncorp@cpan.org`

# LICENSE

Copyright (C) 2011-2019, Al Newkirk, et al.

This is free software; you can redistribute it and/or modify it under the terms
of the The Apache License, Version 2.0, as elucidated in the ["license
file"](https://github.com/iamalnewkirk/api-client/blob/master/LICENSE).

# PROJECT

[Wiki](https://github.com/iamalnewkirk/api-client/wiki)

[Project](https://github.com/iamalnewkirk/api-client)

[Initiatives](https://github.com/iamalnewkirk/api-client/projects)

[Milestones](https://github.com/iamalnewkirk/api-client/milestones)

[Contributing](https://github.com/iamalnewkirk/api-client/blob/master/CONTRIBUTE.md)

[Issues](https://github.com/iamalnewkirk/api-client/issues)
