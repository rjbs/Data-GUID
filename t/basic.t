#!perl

use strict;
use warnings;

use Test::More tests => 25;

BEGIN { use_ok('Data::GUID'); }

my $guid = Data::GUID->new;
isa_ok($guid, 'Data::GUID');

like(
  $guid->as_string,
  Data::GUID->__type_regex('string'),
  "GUID as_string looks OK",
);

like(
  "$guid",
  Data::GUID->__type_regex('string'),
  "stringified GUID looks OK",
);

like(
  $guid->as_hex,
  Data::GUID->__type_regex('hex'),
  "GUID as_hex looks OK",
);

like(
  $guid->as_base64,
  Data::GUID->__type_regex('base64'),
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

{
  my $non_guid_value = 10;

  is(
    (($non_guid_value <=> $guid) * +1),
    (($guid <=> $non_guid_value) * -1),
    "guid on rhs of unbalanced <=> is (x * -1)",
  );
}

{
  my $uuid = Data::UUID->new->create;

  isa_ok(
    Data::GUID->from_data_uuid($uuid),
    'Data::GUID',
    "from_data_uuid",
  );

  for my $value (undef, '', 'foo') {
    eval { Data::GUID->from_data_uuid($value) };
    like($@, qr/not a valid Data::UUID/, "invalid Data::UUID value rejected");
  }
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

  my $guid_str_method = "guid_$type";
  my $guid_str = Data::GUID->$guid_str_method;

  eval { Data::GUID->$from("invalid"); };
  like($@, qr/not a valid $type/, "invalid input to $from croaks");

  like($guid_str, Data::GUID->__type_regex($type), "guid_$type method ok");
}

