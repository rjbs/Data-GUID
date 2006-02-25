#!perl

use strict;
use warnings;

use Test::More tests => 14;

BEGIN { use_ok('Data::GUID'); }

my $guid = Data::GUID->new;
isa_ok($guid, 'Data::GUID');

my $hex = qr/[0-9A-F]/i;

like(
  $guid->as_string,
  qr/\A$hex{8}-(?:$hex{4}-){3}$hex{12}\z/,
  "GUID as_string looks OK",
);

like(
  "$guid",
  qr/\A$hex{8}-(?:$hex{4}-){3}$hex{12}\z/,
  "stringified GUID looks OK",
);

like(
  $guid->as_hex,
  qr/\A0x$hex{32}\z/,
  "GUID as_hex looks OK",
);

my $base64 = qr{[A-Z0-9+/=]}i;

like(
  $guid->as_base64,
  qr/\A$base64{24}\z/,
  "GUID as_hex looks OK",
);

ok(
  ($guid <=> $guid) == 0,
  "guid is equal to itself",
);

{
  my $other_guid = Data::GUID->new;

  ok(
    ($guid <=> $other_guid) != 0,
    "guid is not equal to a new guid",
  );
}

for my $type (qw(hex string base64)) {
  my $as   = "as_$type";
  my $from = "from_$type";
  my $copy = Data::GUID->$from($guid->$as);
  isa_ok($copy, 'Data::GUID', "guid from $type");
  is(
    $guid <=> $copy,
    0,
    "original guid is equal to copy round-tripped via $type",
  );
}

