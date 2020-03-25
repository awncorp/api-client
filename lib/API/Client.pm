package API::Client;

use 5.014;

use strict;
use warnings;

use registry;
use routines;

use Data::Object::Class;
use Data::Object::ClassHas;
use FlightRecorder;
use Mojo::Transaction;
use Mojo::UserAgent;
use Mojo::URL;

with 'Data::Object::Role::Buildable';
with 'Data::Object::Role::Stashable';
with 'Data::Object::Role::Throwable';

# VERSION

# ATTRIBUTES

has 'debug' => (
  is => 'ro',
  isa => 'Bool',
  def => 0,
);

has 'fatal' => (
  is => 'ro',
  isa => 'Bool',
  def => 0,
);

has 'logger' => (
  is => 'ro',
  isa => 'InstanceOf["FlightRecorder"]',
  new => 1,
);

fun new_logger($self) {
  FlightRecorder->new
}

has 'name' => (
  is => 'ro',
  isa => 'Str',
  new => 1,
);

fun new_name($self) {
  "@{[ref($self)]} (@{[$self->version]})"
}

has 'retries' => (
  is => 'ro',
  isa => 'Int',
  def => 0,
);

has 'timeout' => (
  is => 'ro',
  isa => 'Int',
  def => 10,
);

has 'url' => (
  is => 'ro',
  isa => 'InstanceOf["Mojo::URL"]',
  req => 1,
);

has 'user_agent' => (
  is => 'ro',
  isa => 'InstanceOf["Mojo::UserAgent"]',
  new => 1,
);

fun new_user_agent($self) {
  Mojo::UserAgent->new
}

has 'version' => (
  is => 'ro',
  isa => 'Str',
  new => 1,
);

fun new_version($self) {
  $self->VERSION || 0.01
}

# BUILD

method build_args($args) {
  if (!$args->{url}) {
    $args->{url} = join('/', @{$self->base(%$args)}) if $self->can('base');
  }
  if (!ref $args->{url}) {
    $args->{url} = Mojo::URL->new($args->{url}) if $args->{url};
  }

  return $args;
}

# METHODS

method create(Any %args) {

  return $self->dispatch(%args, method => 'post');
}

method delete(Any %args) {

  return $self->dispatch(%args, method => 'delete');
}

method dispatch(Str :$method = 'get', Any %args) {
  my $log = $self->logger->info("@{[uc($method)]} @{[$self->url->to_string]}");

  my $result = $self->execute(%args, method => $method);

  $log->end;

  return $result;
}

method fetch(Any %args) {

  return $self->dispatch(%args, method => 'get');
}

method patch(Any %args) {

  return $self->dispatch(%args, method => 'patch');
}

method update(Any %args) {

  return $self->dispatch(%args, method => 'put');
}

method prepare(Object $ua, Object $tx, Any %args) {
  $self->set_auth($ua, $tx, %args);
  $self->set_headers($ua, $tx, %args);
  $self->set_identity($ua, $tx, %args);

  return $self;
}

method process(Object $ua, Object $tx, Any %args) {

  return $self;
}

method resource(Str @segments) {
  my $url;

  if (@segments) {
    $url = $self->url->clone;

    $url->path->merge(
      join '/', @{$self->url->path->parts}, @segments
    );
  }

  my $object = ref($self)->new(
    %{$self->serialize}, ($url ? ('url', $url) : ())
  );

  return $object;
}

method serialize() {

  return {
    debug => $self->debug,
    fatal => $self->fatal,
    name => $self->name,
    retries => $self->retries,
    timeout => $self->timeout,
    url => $self->url->to_string,
  };
}

method set_auth($ua, $tx, %args) {
  if ($self->can('auth')) {
    $tx->req->url->userinfo(join ':', @{$self->auth});
  }

  return $self;
}

method set_headers($ua, $tx, %args) {
  if ($self->can('headers')) {
    $tx->req->headers->header(@$_) for @{$self->headers};
  } else {
    $tx->req->headers->header('Content-Type' => 'application/json');
  }

  return $self;
}

method set_identity($ua, $tx, %args) {
  $tx->req->headers->header('User-Agent' => $self->name);

  return $self;
}

method execute(Str :$method = 'get', Str :$path = '', Any %args) {
  delete $args{method};

  my $ua = $self->user_agent;
  my $url = $self->url->clone;

  my $query = $args{query} || {};
  my $headers = $args{headers} || {};

  $url->path(join '/', $url->path, $path) if $path;
  $url->query($url->query->merge(%$query)) if keys %$query;

  my @args;

  # data handlers
  for my $type (sort keys %{$ua->transactor->generators}) {
    push @args, $type, delete $args{$type} if $args{$type};
  }

  # handle raw body value
  push @args, delete $args{body} if exists $args{body};

  # transaction prepare hook
  $ua->on(prepare => fun ($ua, $tx) {
    $self->prepare($ua, $tx, %args);
  });

  # client timeouts
  $ua->max_redirects(0);
  $ua->connect_timeout($self->timeout);
  $ua->request_timeout($self->timeout);

  # transaction
  my ($ok, $tx, $req, $res);

  # times to retry failures
  my $retries = $self->retries;

  # transaction retry loop
  for (my $i = 0; $i < ($retries || 1); $i++) {
    # execute transaction
    $tx = $ua->start($ua->build_tx($method, $url, $headers, @args));
    $self->process($ua, $tx, %args);

    # transaction objects
    $req = $tx->req;
    $res = $tx->res;

    # determine success/failure
    $ok = $res->code ? $res->code !~ /(4|5)\d\d/ : 0;

    # log activity
    if ($req && $res) {
      my $log = $self->logger;
      my $msg = join " ", "attempt", ("#".($i+1)), ": $method", $url->to_string;

      $log->debug("req: $msg")->data({
        request => $req->to_string =~ s/\s*$/\n\n\n/r
      });

      $log->debug("res: $msg")->data({
        response => $res->to_string =~ s/\s*$/\n\n\n/r
      });

      # output to the console where applicable
      $log->info("res: $msg [@{[$res->code]}]");
      $log->output if $self->debug;
    }

    # no retry necessary
    last if $ok;
  }

  # throw exception if fatal is truthy
  if ($req && $res && $self->fatal && !$ok) {
    my $code = $res->code;

    $self->stash(tx => $tx);
    $self->throw([$code, uc "${code}_http_response"]);
  }

  # return transaction
  return $tx;
}

1;
