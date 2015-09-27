# Client Core Class
package API::Client::Core;

use namespace::autoclean -except => 'has';

use Data::Object::Class;
use Data::Object::Class::Syntax;
use Data::Object::Signatures;

use Data::Object::Library qw(
    InstanceOf
    Int
);

use API::Client::Exception;

use Mojo::Transaction;
use Mojo::UserAgent;
use Mojo::URL;

# VERSION

# ATTRIBUTES

has debug      => rw;
has fatal      => rw;
has retries    => rw;
has timeout    => rw;
has url        => ro;
has user_agent => ro;

# CONSTRAINTS

opt debug      => Int;
opt fatal      => Int;
opt retries    => Int;
opt timeout    => Int;
opt url        => InstanceOf['Mojo::URL'];
opt user_agent => InstanceOf['Mojo::UserAgent'];

# DEFAULTS

def debug      => 0;
def fatal      => 0;
def retries    => 0;
def timeout    => 10;
def user_agent => method { Mojo::UserAgent->new };

# DELEGATES

my @methods = qw(
    DELETE
    GET
    HEAD
    OPTIONS
    PATCH
    POST
    PUT
);

around [@methods] => fun ($orig, $self, %args) {
    my $retries = $self->retries;
    my $ua      = $self->user_agent;

    # client timeouts
    $ua->max_redirects(0);
    $ua->connect_timeout($self->timeout);
    $ua->request_timeout($self->timeout);

    # request defaults
    $ua->on(start => fun ($ua, $tx) {
        $self->PREPARE($ua, $tx, %args);
    });

    # retry entry point
    RETRY:

    # execute transaction
    my $tx  = $self->$orig(%args);
    my $ok  = $tx->res->code !~ /(4|5)\d\d/;

    # fetch transaction objects
    my $req = $tx->req;
    my $res = $tx->res;

    # attempt logging where applicable
    if ($self->debug) {
        my $reqstr = $req->to_string;
        my $resstr = $res->to_string;

        $reqstr =~ s/\s*$/\n\n\n/;
        $resstr =~ s/\s*$/\n\n\n/;

        print STDOUT $reqstr;
        print STDOUT $resstr;
    }

    # retry transaction where applicable
    goto RETRY if $retries-- > 0 and not $ok;

    # throw exception if fatal is enabled
    if ($self->fatal and not $ok) {
        API::Client::Exception->throw(
            tx     => $tx,
            code   => $res->code,
            method => $req->method,
            url    => $req->url,
        );
    }

    # return JSON
    return $res->json;
};

# METHODS

method DELETE (Str :$path = '', HashRef :$data = {}, HashRef :$query = {}) {
    my $ua  = $self->user_agent;
    my $url = $self->url->clone;

    $url->path(join '/', $url->path, $path)  if $path;
    $url->query($url->query->merge(%$query)) if keys %$query;

    return $ua->delete($url, ({}, keys(%$data) ? (json => $data) : ()));
}

fun DESTROY {
    ; # Protect subclasses using AUTOLOAD
}

method GET (Str :$path = '', HashRef :$data = {}, HashRef :$query = {}) {
    my $ua  = $self->user_agent;
    my $url = $self->url->clone;

    $url->path(join '/', $url->path, $path)  if $path;
    $url->query($url->query->merge(%$query)) if keys %$query;

    return $ua->get($url, ({}, keys(%$data) ? (json => $data) : ()));
}

method HEAD (Str :$path = '', HashRef :$data = {}, HashRef :$query = {}) {
    my $url = $self->url->clone;
    my $ua  = $self->user_agent;

    $url->path(join '/', $url->path, $path)  if $path;
    $url->query($url->query->merge(%$query)) if keys %$query;

    return $ua->head($url, ({}, keys(%$data) ? (json => $data) : ()));
}

method OPTIONS (Str :$path = '', HashRef :$data = {}, HashRef :$query = {}) {
    my $url = $self->url->clone;
    my $ua  = $self->user_agent;

    $url->path(join '/', $url->path, $path)  if $path;
    $url->query($url->query->merge(%$query)) if keys %$query;

    return $ua->options($url, ({}, keys(%$data) ? (json => $data) : ()));
}

method PATCH (Str :$path = '', HashRef :$data = {}, HashRef :$query = {}) {
    my $url = $self->url->clone;
    my $ua  = $self->user_agent;

    $url->path(join '/', $url->path, $path)  if $path;
    $url->query($url->query->merge(%$query)) if keys %$query;

    return $ua->patch($url, ({}, keys(%$data) ? (json => $data) : ()));
}

method POST (Str :$path = '', HashRef :$data = {}, HashRef :$query = {}) {
    my $url = $self->url->clone;
    my $ua  = $self->user_agent;

    $url->path(join '/', $url->path, $path)  if $path;
    $url->query($url->query->merge(%$query)) if keys %$query;

    return $ua->post($url, ({}, keys(%$data) ? (json => $data) : ()));
}

method PUT (Str :$path = '', HashRef :$data = {}, HashRef :$query = {}) {
    my $url = $self->url->clone;
    my $ua  = $self->user_agent;

    $url->path(join '/', $url->path, $path)  if $path;
    $url->query($url->query->merge(%$query)) if keys %$query;

    return $ua->put($url, ({}, keys(%$data) ? (json => $data) : ()));
}

1;
