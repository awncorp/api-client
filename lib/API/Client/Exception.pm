# Client Exception Class
package API::Client::Exception;

use namespace::autoclean -except => 'has';

use Data::Object::Class;
use Data::Object::Class::Syntax;
use Data::Object::Signatures;

use Data::Object::Library qw(
    InstanceOf
    Int
    Str
);

extends 'Data::Object::Exception';

# VERSION

our $MESSAGE = "%s response received while processing request %s %s";

# ATTRIBUTES

has code   => ro;
has method => ro;
has tx     => ro;
has url    => ro;

# CONSTRAINTS

req code   => Int;
req method => Str;
req tx     => InstanceOf['Mojo::Transaction'];
req url    => InstanceOf['Mojo::URL'];

# MODIFIERS

alt message => lazy;

# DEFAULTS

def message => method {

    sprintf "$MESSAGE\n", map "@{[$self->$_]}", qw(code method url);

};

1;
