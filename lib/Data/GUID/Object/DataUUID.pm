use warnings;
use strict;
package Data::GUID::Object::DataUUID;
# use base 'Data::GUID';

use Carp ();
use Data::UUID;
use Sub::Install;

sub _construct {
  my ($class, $ug, $value) = @_;

  my $length = do { use bytes; defined $value ? length $value : 0; };
  Carp::croak "given value is not a valid Data::UUID value" if $length != 16;
  bless [ $ug, $value ] => $class;
}

sub as_base64 { $_[0][0]->to_b64string($_[0][1])            }
sub as_binary { $_[0][1]                                    }
sub as_hex    { $_[0][0]->to_hexstring($_[0][1])            }
sub as_string { $_[0][0]->to_string($_[0][1])               }

# XXX: I hate this whole "comparing GUIDs" notion. -- rjbs, 2009-05-30
sub compare_to_guid {
  my ($self, $other) = @_;

  my $other_binary = eval {
    $other->isa('Data::GUID') || $other->isa('Data::GUID::Object::DataUUID')
  } ? $other->as_binary : $other;

  $self->[0]->compare($self->as_binary, $other_binary);
}

use overload
  q{""} => 'as_string',
  '<=>' => sub { ($_[2] ? -1 : 1) * $_[0]->compare_to_guid($_[1]) },
  fallback => 1;

1;
