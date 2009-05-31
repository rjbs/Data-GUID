use warnings;
use strict;
package Data::GUID::Object::DataUUID;
# use base 'Data::GUID';

use Carp ();
use Data::UUID;
use Sub::Install;

sub _construct {
  my ($class, $value) = @_;

  my $length = do { use bytes; defined $value ? length $value : 0; };
  Carp::croak "given value is not a valid Data::UUID value" if $length != 16;
  bless \$value => $class;
}

sub as_base64 { Data::UUID->to_b64string($_[0]->as_binary) }
sub as_binary { ${ $_[0] }                                 }
sub as_hex    { Data::UUID->to_hexstring($_[0]->as_binary) }
sub as_string { Data::UUID->to_string($_[0]->as_binary)    }

# XXX: I hate this whole "comparing GUIDs" notion. -- rjbs, 2009-05-30
sub compare_to_guid {
  my ($self, $other) = @_;

  my $other_binary
    = eval { $other->isa('Data::GUID') } ? $other->as_binary : $other;

  Data::UUID->compare($self->as_binary, $other_binary);
}

use overload
  q{""} => 'as_string',
  '<=>' => sub { ($_[2] ? -1 : 1) * $_[0]->compare_to_guid($_[1]) },
  fallback => 1;

1;
