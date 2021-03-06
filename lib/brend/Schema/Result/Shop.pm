use utf8;
package brend::Schema::Result::Shop;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

brend::Schema::Result::Shop

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<shop>

=cut

__PACKAGE__->table("shop");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 shop

  data_type: 'text'
  is_nullable: 1

=head2 info

  data_type: 'text'
  is_nullable: 1

=head2 active_till

  data_type: 'integer'
  is_nullable: 1

=head2 contact_mail

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 site

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 social

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 logo

  data_type: 'text'
  is_nullable: 1

=head2 address

  data_type: 'text'
  is_nullable: 1

=head2 type

  data_type: 'integer'
  is_nullable: 1

=head2 country

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 manager

  data_type: 'integer'
  is_nullable: 1

=head2 alias

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "shop",
  { data_type => "text", is_nullable => 1 },
  "info",
  { data_type => "text", is_nullable => 1 },
  "active_till",
  { data_type => "integer", is_nullable => 1 },
  "contact_mail",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "site",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "social",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "logo",
  { data_type => "text", is_nullable => 1 },
  "address",
  { data_type => "text", is_nullable => 1 },
  "type",
  { data_type => "integer", is_nullable => 1 },
  "country",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "manager",
  { data_type => "integer", is_nullable => 1 },
  "alias",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07027 @ 2012-09-04 10:57:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IRWz4QKQNjyqgXktC3bfKg
__PACKAGE__->belongs_to(
	manager => 'brend::Schema::Result::User'
);

__PACKAGE__->has_many(
	shop_blog => 'brend::Schema::Result::ShopBlog',
	'shop'
);

__PACKAGE__->has_many(
	things => 'brend::Schema::Result::Thing',
	'shop'
);

__PACKAGE__->has_many(
	collections => 'brend::Schema::Result::Collection',
	'shop'
);

__PACKAGE__->has_many(
	discounts => 'brend::Schema::Result::Discount',
	'shop'
);

__PACKAGE__->belongs_to(
	type => 'brend::Schema::Result::ShopType'
);
# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
