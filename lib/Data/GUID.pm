package Data::GUID;

use warnings;
use strict;

use Data::UUID;

=head1 NAME

Data::GUID - globally unique identifiers

=head1 VERSION

version 0.00

 $Id$

=cut

our $VERSION = '0.00';

=head1 SYNOPSIS

  use Data::GUID;

  my $guid = Data::GUID->new;

  my $string = $guid->as_string; # or "$guid"

  my $other_guid = Data::GUID->from_string($string);

  if (($guid <=> $other_guid) == 0) {
    print "They're the same!\n";
  }

=head1 DESCRIPTION

Data::GUID provides a simple interface for generating and using globally unique
identifiers.

=head1 GETTING A NEW GUID

=head2 C< new >

  my $guid = Data::GUID->new;

This method returns a new globally unique identifier.

=cut

sub _guid_from_uuid {
  my ($class, $uuid) = @_;
  bless \$uuid => $class;
}

my $_uuid_gen = Data::UUID->new;
sub new {
  my ($class) = @_;

  return $class->_guid_from_uuid($_uuid_gen->create);
}

=head1 GUIDS FROM STRINGS

These method returns a new Data::GUID object for the given GUID value.

=head2 C< from_string >

  my $guid = Data::GUID->from_string("B0470602-A64B-11DA-8632-93EBF1C0E05A");

=head2 C< from_hex >

  # note that a hex guid is a guid string without hyphens and with a leading 0x
  my $guid = Data::GUID->from_hex("0xB0470602A64B11DA863293EBF1C0E05A");

=head2 C< from_base64 >

  my $guid = Data::GUID->from_base64("sEcGAqZLEdqGMpPr8cDgWg==");

=cut

my %from = (
  string => 'string',
  hex    => 'hexstring',
  base64 => 'b64string',
);

do {
  no strict 'refs';
  while (my ($our_method, $alien_method) = each %from) {
    my $our_from_method   = "from_$our_method";
    my $alien_from_method = "from_$alien_method";
    *$our_from_method = sub { 
      my ($class, $string) = @_;
      $class->_guid_from_uuid( $_uuid_gen->$alien_from_method($string) );
    };

    my $our_to_method   = "as_$our_method";
    my $alien_to_method = "to_$alien_method";
    *$our_to_method = sub { 
      my ($self) = @_;
      $_uuid_gen->$alien_to_method( $self->as_binary );
    };
  }
};

=head1 GUIDS INTO STRINGS

These methods return string representations of a GUID.

=head2 C< as_string >

This method is also used to stringify Data::GUID objects.

=head2 C< as_hex >

=head2 C< as_base64 >

=cut

=head1 OTHER METHODS

=head2 C< as_binary >

This method returns the packed binary representation of the GUID.

=cut

sub as_binary {
  my ($self) = @_;
  $$self;
}

=head2 C< compare_to_guid >

This method compares a GUID to another GUID and returns -1, 0, or 1, as do
other comparison routines.

=cut

sub compare_to_guid {
  my ($self, $other) = @_;
  return ($self->as_binary <=> $other)
    unless (eval { $other->isa('Data::GUID') });

  $_uuid_gen->compare($self->as_binary, $other->as_binary);
}

use overload
  q{""} => 'as_string',
  '<=>' => sub { ($_[2] ? -1 : 1) * $_[0]->compare_to_guid($_[1]) },
  fallback => 1;

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 TODO

=over

=item * add namespace support

=item * remove dependency on wretched Data::UUID

=back

=head1 BUGS

Please report any bugs or feature requests to
C<bug-data-guid@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2006 Ricardo Signes, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
