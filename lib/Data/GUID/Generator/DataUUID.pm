use strict;
use warnings;
package Data::GUID::Generator::DataUUID;

use Carp ();
use Data::UUID;
use Data::GUID::Object::DataUUID;
use Sub::Install;

my $default;
sub _self {
  return $_[0] if ref $_[0];
  return $default ||= $_[0]->new;
}

sub new {
  my ($class) = @_;

  my $uuid_gen = Data::UUID->new;
  my $self = bless \$uuid_gen => $class;

  return $self;
}

sub new_guid {
  my $self = $_[0]->_self;

  my $uuid_value = $self->_uuid_gen->create;
  $self->from_data_uuid($uuid_value);
}

sub _uuid_gen { ${ $_[0] } }

sub from_data_uuid {
  my ($invocant, $value) = @_;
  my $gen = $invocant->_self->_uuid_gen;

  return Data::GUID::Object::DataUUID->_construct($gen, $value);
}

my ($hex, $base64, %type);

BEGIN { # because %type must be populated for method/exporter generation
  $hex    = qr/[0-9A-F]/i;
  $base64 = qr{[A-Z0-9+/=]}i;

  %type = ( # uuid_method  validation_regex
    string => [ 'string',     qr/\A$hex{8}-?(?:$hex{4}-?){3}$hex{12}\z/, ],
    hex    => [ 'hexstring',  qr/\A0x$hex{32}\z/,                        ],
    base64 => [ 'b64string',  qr/\A$base64{24}\z/,                       ],
  );
}

# provided for test scripts
sub __type_regex { shift; $type{$_[0]}[1] }

sub _install_from_method {
  my ($type, $alien_method, $regex) = @_;
  my $alien_from_method = "from_$alien_method";

  my $our_from_code = sub { 
    my ($inv, $string) = @_;
    my $self = $inv->_self;

    $string ||= q{}; # to avoid (undef =~) warning
    Carp::croak qq{"$string" is not a valid $type GUID} if $string !~ $regex;

    $self->from_data_uuid( $self->_uuid_gen->$alien_from_method($string) );
  };

  Sub::Install::install_sub({ code => $our_from_code, as => "from_$type" });
}

BEGIN {
  while (my ($type, $profile) = each %type) {
    _install_from_method($type, @$profile);
  }
}

sub _from_multitype {
  my ($class, $what, $types) = @_;
  sub {
    my ($class, $value) = @_;
    return $value if eval { $value->isa('Data::GUID') };

    my $value_string = defined $value ? qq{"$value"} : 'undef';

    # The only good ref is a blessed ref, and only into our denomination!
    if (my $ref = ref $value) {
      Carp::croak "a $ref reference is not a valid GUID $what"
    }
    
    for my $type (@$types) {
      my $from = "from_$type";
      my $guid = eval { $class->$from($value); };
      return $guid if $guid;
    }

    Carp::croak "$value_string is not a valid GUID $what";
  }
}

=head2 C< from_any_string >

  my $string = get_string_from_ether;

  my $guid = Data::GUID->from_any_string($string);

This method returns a Data::GUID object for the given string, trying all known
string interpretations.  An exception is thrown if the value is not a valid
GUID string.

=cut

BEGIN { # possibly unnecessary -- rjbs, 2006-03-11
  Sub::Install::install_sub({
    code => __PACKAGE__->_from_multitype('string', [ keys %type ]),
    as   => 'from_any_string',
  });
}

=head2 C< best_guess >

  my $value = get_value_from_ether;

  my $guid = Data::GUID->best_guess($value);

This method returns a Data::GUID object for the given value, trying everything
it can.  It works like C<L</from_any_string>>, but will also accept Data::UUID
values.  (In effect, this means that any sixteen byte value is acceptable.)

=cut

BEGIN { # possibly unnecessary -- rjbs, 2006-03-11
  Sub::Install::install_sub({
    code => __PACKAGE__->_from_multitype('value', [(keys %type), 'data_uuid']),
    as   => 'best_guess',
  });
}

1;
