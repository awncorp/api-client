# Client Credentials Class
package API::Client::Credentials;

use Data::Object::Class;
use Data::Object::Signatures;

# VERSION

# METHODS

method process (("InstanceOf['Mojo::Transaction']") $tx) {

    return $tx;

}

1;
